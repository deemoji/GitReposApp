//
//  ReposListViewModel.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 02.12.2024.
//

import Foundation
import Combine

protocol ReposListViewModel {
    
    // Output
    var repos: AnyPublisher<[ReposListItem], Never> { get }
    var isLoading: AnyPublisher<Bool, Never> { get }
    var error: AnyPublisher<Error, Never> { get }
    
    // Input
    func switchFilter(_ filter: ReposFilter)
    func loadNextPosts()
    func setDeletedItemAt(index: Int)
    func switchFavorite(forItemAt index: Int)
}

final class ReposListViewModelImpl: ReposListViewModel {
    
    var repos: AnyPublisher<[ReposListItem], Never> {
        _repos.map { repos in
            repos.map { repo in
                ReposListItem(id: repo.id, name: repo.name, details: repo.details, iconUrl: repo.userImageUrl, isFavorite: repo.isFavorite)
            }
        }.eraseToAnyPublisher()
    }
    var isLoading: AnyPublisher<Bool, Never> {
        _isLoading.eraseToAnyPublisher()
    }
    var error: AnyPublisher<Error, Never> {
        _error.eraseToAnyPublisher()
    }
    
    private let interactor: ReposListInteractor
    
    private let _repos = CurrentValueSubject<[Repository], Never>([])
    private let _isLoading = CurrentValueSubject<Bool, Never>(false)
    private let _error = PassthroughSubject<Error, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(interactor: ReposListInteractor) {
        self.interactor = interactor
    }
    
    func switchFilter(_ filter: ReposFilter) {
        interactor.switchFilter(filter)
        _repos.send([])
        _isLoading.send(false)
    }
    
    func loadNextPosts() {
        guard !_isLoading.value else {
            return
        }
        _isLoading.send(true)
        interactor
            .nextRepos()
            .catch({ [weak self] in
                self?._error.send($0)
                return Empty<[Repository], Never>()
            })
            .sink(receiveCompletion: { [weak self] _ in
            self?._isLoading.send(false)
        }, receiveValue: { [weak self] in
            if let self {
                self._repos.send(self._repos.value + $0)
            }
        })
        .store(in: &cancellables)
    }
    
    func setDeletedItemAt(index: Int) {
        var currentRepos = _repos.value
        let repoToDelete = currentRepos.remove(at: index)
        
        _repos.send(currentRepos)
        
        interactor.setDeleted(withId: repoToDelete.id)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    currentRepos.insert(repoToDelete, at: index)
                    self?._repos.send(currentRepos)
                    print(error.localizedDescription)
                    self?._error.send(error)
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }

    func switchFavorite(forItemAt index: Int) {
        var currentRepos = _repos.value
        var repo = currentRepos[index]
        repo.isFavorite = !repo.isFavorite
        currentRepos[index] = repo
        _repos.send(currentRepos)
        let completion: ((Subscribers.Completion<Error>) -> Void) = { [weak self] in
            if case .failure(let error) = $0 {
                repo.isFavorite = !repo.isFavorite
                currentRepos[index] = repo
                print(error.localizedDescription)
                self?._repos.send(currentRepos)
            }
        }
        if repo.isFavorite {
            interactor.saveFavorite(withId: repo.id).sink(receiveCompletion: completion, receiveValue: {}).store(in: &cancellables)
        } else {
            interactor.removeFavorite(withId: repo.id).sink(receiveCompletion: completion, receiveValue: {}).store(in: &cancellables)
        }
    }
    
}

//
//  ReposListViewController.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 03.12.2024.
//

import UIKit
import Combine

final class ReposListViewController: UIViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<Int, ReposListItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, ReposListItem>
    
    static func create(with viewModel: ReposListViewModel, imageLoader: ImageLoader? = nil) -> ReposListViewController {
        let reposListVC = ReposListViewController(nibName: "ReposListViewController", bundle: nil)
        reposListVC.viewModel = viewModel
        reposListVC.imageLoader = imageLoader
        return reposListVC
    }
    
    var viewModel: ReposListViewModel!
    var imageLoader: ImageLoader?
    lazy private var dataSource: DataSource = {
        let dataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReposListCell.identifier) as? ReposListCell else {
                return UITableViewCell()
            }
            cell.configure(with: item) { [weak self] in
                
                self?.viewModel.switchFavorite(forItemAt: indexPath.row)
            }
            let url = item.iconUrl
            cell.setIcon(nil)
            self?.imageLoader?.loadImage(from: item.iconUrl, completion: { [weak self] in
                guard let self else { return }
                if(item.iconUrl == url) {
                    cell.setIcon($0)
                }
                
            })
            return cell
        }
        return dataSource
    }()
    
    private var isLoading: Bool = false
    private var cancellables: Set<AnyCancellable> = .init()
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    private let activityIndicator: UIActivityIndicatorView = {
        var activity = UIActivityIndicatorView(style: .medium)
        activity.hidesWhenStopped = true
        return activity
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
        viewModel.loadNextPosts()
    }
    
    private func setupViews() {
        self.title = "Git Repositories"
        setupTableView()
        setupSegmentedControl()
    }
    private func setupTableView() {
        tableView.register(UINib(nibName: ReposListCell.identifier, bundle: nil), forCellReuseIdentifier: ReposListCell.identifier)
        tableView.delegate = self
    }
    
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        let filters = ReposFilter.allCases
        for i in 0..<filters.count {
            segmentedControl.insertSegment(action: UIAction(title: filters[i].rawValue, handler: { [weak self] _ in
                self?.viewModel.switchFilter(filters[i])
                self?.viewModel.loadNextPosts()
            }), at: i, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 0
    }
    
    private func bindViewModel() {
        viewModel.repos.sink { [weak self] in
            self?.update($0)
        }.store(in: &cancellables)
        viewModel.isLoading.sink { [weak self] in
            self?.tableView.estimatedSectionFooterHeight = $0 ? 60.0 : 0.0
        }.store(in: &cancellables)
        viewModel.error.sink {
            print($0.localizedDescription)
        }.store(in: &cancellables)
    }
}

// MARK:  - Table View Delegates
extension ReposListViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            viewModel.loadNextPosts()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.startAnimating()
        return activity
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = UIContextualAction(style: .destructive, title: "Delete") { [weak self] contextualAction, view, boolValue in
            self?.viewModel.setDeletedItemAt(index: indexPath.row)
        }
        item.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [item])
    }
    
}

extension ReposListViewController {
    func update(_ items: [ReposListItem]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

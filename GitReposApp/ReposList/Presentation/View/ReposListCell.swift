//
//  ReposListCell.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 03.12.2024.
//

import UIKit

final class ReposListCell: UITableViewCell {
    
    static let identifier: String = "ReposListCell"

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    private var isFavorited: Bool = false
    
    private var action: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
    }
    @objc func favoriteButtonPressed() {
        action?()
    }
}

extension ReposListCell {
    func configure(with item: ReposListItem, buttonAction: @escaping () -> Void) {
        nameLabel.text = item.name
        detailsLabel.text = item.details
        favoriteButton.setImage(UIImage(systemName: item.isFavorite ? "heart.fill" : "heart"), for: .normal)
        isFavorited = item.isFavorite
        action = buttonAction
    }
    
    func setIcon(_ image: UIImage?) {
        icon.image = image
    }
}

//
//  CustomTableViewCell.swift
//  UITableView APP
//
//  Created by Егор Грива on 03.02.2020.
//  Copyright © 2020 Егор Грива. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet{
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet var cosmosView: CosmosView! {
        didSet{
            cosmosView.settings.updateOnTouch = false
        }
    }
    
}

//
//  PhotoTableViewCell.swift
//  Tumblr
//
//  Created by Chengjiu Hong on 1/30/17.
//  Copyright © 2017 Chengjiu Hong. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var postImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

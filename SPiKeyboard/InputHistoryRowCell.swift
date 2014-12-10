//
//  InputHistoryRowCell.swift
//  SPi
//
//  Created by GuoChen on 10/12/2014.
//  Copyright (c) 2014 guoc. All rights reserved.
//

import UIKit

class InputHistoryRowCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var candidateLabel: UILabel!
    @IBOutlet weak var shuangpinLabel: UILabel!
    @IBOutlet weak var shengmuLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

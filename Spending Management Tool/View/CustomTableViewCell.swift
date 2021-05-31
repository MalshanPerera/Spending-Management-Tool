//
//  CustomTableViewCell.swift
//  Spending Management Tool
//
//  Created by Malshan Perera on 5/13/21.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var budgetLabel: UILabel!
    @IBOutlet var noteLabel: UILabel!
    
    static let identifier = "CustomTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "CustomTableViewCell", bundle: nil)
    }
    
    public func configure(name: String, budget: String, note: String){
        nameLabel.text = name
        budgetLabel.text = budget
        noteLabel.text = note
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

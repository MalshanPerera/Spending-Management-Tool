//
//  ExpenseTableViewCell.swift
//  Spending Management Tool
//
//  Created by Malshan Perera on 5/15/21.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var occurenceLabel: UILabel!
    @IBOutlet weak var noteLable: UILabel!
    @IBOutlet weak var addToCalenderImage: UIImageView!
    @IBOutlet weak var progressBar: ProgressBar!
    
    
    static let identifier = "ExpenseTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ExpenseTableViewCell", bundle: nil)
    }
    
    public func configure(name: String, budget: Double, occurence: Int16, note: String, dueDate: String, progress: Double, isReminder: Bool, overallBudget: Double){
        nameLabel.text = name
        budgetLabel.text = "£\(budget)"
        noteLable.text = note
        occurenceLabel.text = getOcuurence(occurence)
        progressBar.progress = CGFloat(getProgress(budget: budget, overallBudget: overallBudget))
        
        if isReminder {
            addToCalenderImage.isHidden = false
        }else{
            addToCalenderImage.isHidden = true
        }
    }
    
    func getOcuurence(_ value: Int16 = 0) -> String{
        var occurence = ""
        
        if Int(value) == 0 {
            occurence = "One-Off"
        }
        if Int(value) == 1 {
            occurence = "Daily"
        }
        if Int(value) == 2 {
            occurence = "Weekly"
        }
        if Int(value) == 3 {
            occurence = "Monthly"
        }
        
        return occurence
    }
    
    func getProgress(budget: Double = 0.0, overallBudget: Double = 0.0) -> Double{
        return budget / overallBudget
        
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

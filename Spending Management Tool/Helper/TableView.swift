//
//  TableView.swift
//  Spending Management Tool
//
//  Created by Malshan Perera on 5/19/21.
//

import Foundation
import UIKit

extension UITableView {
    
    func hasRowAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}

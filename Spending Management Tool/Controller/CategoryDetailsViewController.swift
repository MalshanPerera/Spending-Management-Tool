//
//  CategoryDetailsViewController.swift
//  Spending Management Tool
//
//  Created by Malshan Perera on 5/13/21.
//

import UIKit
import CoreData

class CategoryDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var expenseNameLabel: UILabel!
    @IBOutlet weak var totalBudgetLabel: UILabel!
    @IBOutlet weak var spentLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var pieChartView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var expenseTable: UITableView!
    
    @IBOutlet weak var pieChartViewOne: UIView!
    @IBOutlet weak var pieChartLabelOne: UILabel!
    @IBOutlet weak var pieChartViewTwo: UIView!
    @IBOutlet weak var pieChartLabelTwo: UILabel!
    @IBOutlet weak var pieChartViewThree: UIView!
    @IBOutlet weak var pieChartLabelThree: UILabel!
    @IBOutlet weak var pieChartViewFour: UIView!
    @IBOutlet weak var pieChartLabelFour: UILabel!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var expensesList: [Expense] = []
    let colorList: [UIColor] = [.blue, .red, .yellow, .green]
    var monthlyBudget: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (categoryItem == nil) {
            mainView.isHidden = true
        }else{
            mainView.isHidden = false
        }
        
        expenseTable.register(ExpenseTableViewCell.nib(), forCellReuseIdentifier: ExpenseTableViewCell.identifier)
        expenseTable.delegate = self
        expenseTable.dataSource = self
        
        // Hide all the pie chart legends
        hideLabelAndView()
        
        // Create Pie Chart
        displayPieChart()

        configureView()
    }
    
    func hideLabelAndView(){
        pieChartViewOne.alpha = 0.0
        pieChartLabelOne.alpha = 0.0
        
        pieChartViewTwo.alpha = 0.0
        pieChartLabelTwo.alpha = 0.0
        
        pieChartViewThree.alpha = 0.0
        pieChartLabelThree.alpha = 0.0
        
        pieChartViewFour.alpha = 0.0
        pieChartLabelFour.alpha = 0.0
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let category = categoryItem {
            
            expensesList = []
            
            for expense in category.expense! {
                let e = expense as! Expense
                expensesList.append(e)
            }
            
            let spentValue = expensesList.reduce(0, {$0 + $1.amount})
            
            if let label = expenseNameLabel {
                label.text = category.name
            }
            if let label = totalBudgetLabel {
                label.text = "£ \(String(category.monthly_budget))"
            }
            if let label = spentLabel {
                label.text = "£ \(spentValue)"
            }
            if let label = remainingLabel {
                label.text = "£ \(String(category.monthly_budget - spentValue))"
            }
            
            monthlyBudget = category.monthly_budget
        }
    }
    
    var categoryItem: Category? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExpense" {
            let controller = segue.destination as! AddExpenseViewController
            controller.selectedCategory = categoryItem
        }
        else if segue.identifier == "editExpense" {
            if let indexPath = expenseTable.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = segue.destination as! AddExpenseViewController
                controller.selectedCategory = categoryItem
                controller.editingExpense = object
            }
        }
    }
    
    func displayPieChart() {
        let chartView = PieChartView()
        chartView.frame = CGRect(x: 0, y: 0, width: pieChartView.frame.size.width, height: 220)

        // Sort the list and get 4 values
        let sortedList = expensesList.sorted(by: {$0.amount > $1.amount}).prefix(4)
        
        for (index, item) in sortedList.enumerated() {
            // Set Name and Color of the legend and show legend if there is one
            switch index {
            case 0:
                pieChartViewOne.layer.backgroundColor = colorList[index].cgColor
                pieChartLabelOne.text = item.name
                pieChartViewOne.alpha = 1.0
                pieChartLabelOne.alpha = 1.0
            case 1:
                pieChartViewTwo.layer.backgroundColor = colorList[index].cgColor
                pieChartLabelTwo.text = item.name
                pieChartViewTwo.alpha = 1.0
                pieChartLabelTwo.alpha = 1.0
            case 2:
                pieChartViewThree.layer.backgroundColor = colorList[index].cgColor
                pieChartLabelThree.text = item.name
                pieChartViewThree.alpha = 1.0
                pieChartLabelThree.alpha = 1.0
            case 3:
                pieChartViewFour.layer.backgroundColor = colorList[index].cgColor
                pieChartLabelFour.text = item.name
                pieChartViewFour.alpha = 1.0
                pieChartLabelFour.alpha = 1.0
            default:
                print("No View or Label")
            }
            chartView.segments.append(Segment(color: colorList[index], value: CGFloat(item.amount)))
        }
        pieChartView.addSubview(chartView)
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.identifier, for: indexPath) as! ExpenseTableViewCell
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(customCell, withEvent: event)
        return customCell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: ExpenseTableViewCell, withEvent event: Expense) {
        cell.configure(name: event.name ?? "", budget: event.amount, occurence: event.occurrence, note: "\(event.notes ?? "")", dueDate: "\(event.date ?? Date.init())", progress: 0.5, isReminder: event.expense_due, overallBudget: monthlyBudget)
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Expense> {
                
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Get the selected Category Details
        if categoryItem != nil {
            // Setting a predicate
            let predicate = NSPredicate(format: "%K == %@", "category", categoryItem!)
            fetchRequest.predicate = predicate
        }
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "amount", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "\(UUID().uuidString)-category")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Expense>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        expenseTable.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                expenseTable.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                expenseTable.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                expenseTable.insertRows(at: [newIndexPath!], with: .fade)
                configureView()
                displayPieChart()
            case .delete:
                expenseTable.deleteRows(at: [indexPath!], with: .fade)
                configureView()
                displayPieChart()
            case .update:
                configureCell(expenseTable.cellForRow(at: indexPath!)! as! ExpenseTableViewCell, withEvent: anObject as! Expense)
                configureView()
                displayPieChart()
            case .move:
                configureCell(expenseTable.cellForRow(at: indexPath!)! as! ExpenseTableViewCell, withEvent: anObject as! Expense)
                expenseTable.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        expenseTable.endUpdates()
    }
}

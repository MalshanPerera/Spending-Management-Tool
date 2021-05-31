//
//  CategoryListViewController.swift
//  Spending Management Tool
//
//  Created by Malshan Perera on 5/13/21.
//

import UIKit
import CoreData

class CategoryListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var isTrue = false

    @IBOutlet var table: UITableView!
    
    var categoryDetailViewController: CategoryDetailsViewController? = nil
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the controller in the selected tile
        if let split = splitViewController {
            let controllers = split.viewControllers
            categoryDetailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? CategoryDetailsViewController
        }
        
        // Register Custom Cell
        table.register(CustomTableViewCell.nib(), forCellReuseIdentifier: CustomTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Auto Select the cell
        autoSelectTableRow()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    // Change the color of the cell
    func getColor(colorId: Int16) -> UIColor {
        
        var color: UIColor = .white
        
        if (colorId == 0) {
            color = .systemPink
        }
        if (colorId == 1) {
            color = .systemBlue
        }
        if (colorId == 2) {
            color = .systemYellow
        }
        if (colorId == 3) {
            color = .systemGreen
        }
        if (colorId == 4) {
            color = .systemTeal
        }
        if (colorId == 5) {
            color = .systemPurple
        }
        if (colorId == 6) {
            color = .systemOrange
        }
        
        return color
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showExpenseDetails" {

            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! CategoryDetailsViewController
                controller.categoryItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                categoryDetailViewController = controller
            }
        }
        
        if segue.identifier == "editCategory" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = segue.destination as! AddCategoryViewController
                controller.editingCategory = object as Category
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = fetchedResultsController.object(at: indexPath)
        let count = category.count + 1
        var _c = NSManagedObject()
        _c = category as Category
        _c.setValue(count, forKey: "count")
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
        }
        
        self.performSegue(withIdentifier: "showExpenseDetails", sender: indexPath.row)
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customCell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as! CustomTableViewCell
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(customCell, withEvent: event)
        return customCell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
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

    func configureCell(_ cell: CustomTableViewCell, withEvent event: Category) {
        cell.configure(name: event.name ?? "None", budget: "Budget £\(event.monthly_budget)", note: "Note: \(event.notes ?? "None")" )
        cell.backgroundColor = getColor(colorId: event.color)
    }

    // MARK: - Fetched results controller

    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()

        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "count", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
        }

        return fetchedResultsController
    }()
    
    var _fetchedResultsController: NSFetchedResultsController<Category>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }
        
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)! as! CustomTableViewCell, withEvent: anObject as! Category)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)! as! CustomTableViewCell, withEvent: anObject as! Category)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        autoSelectTableRow()
    }
    
    func autoSelectTableRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        if tableView.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                self.performSegue(withIdentifier: "showExpenseDetails", sender: object)
            }
        } else {
            let empty = {}
            self.performSegue(withIdentifier: "showExpenseDetails", sender: empty)
        }
    }
        
    @IBAction func sortOnClick(_ sender: UIBarButtonItem) {
        isTrue = !isTrue
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()

        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: isTrue)
        fetchRequest.sortDescriptors = [sortDescriptor]

        // Initialize Fetched Results Controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
        }

    }
}

//
//  AddExpenseViewController.swift
//  Spending Management Tool
//
//  Created by Malshan Perera on 5/14/21.
//

import Foundation
import UIKit
import CoreData
import UserNotifications
import EventKit

class AddExpenseViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    var selectedCategory: Category?
    let eventStore : EKEventStore = EKEventStore()
    var selectedDate: Date?
    var duteDate: Date?
    var editingMode: Bool = false
    
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var amountTf: UITextField!
    @IBOutlet weak var addNoteTf: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var addToCalenderBtn: UISwitch!
    @IBOutlet weak var occurenceBtn: UISegmentedControl!
    @IBOutlet weak var addExpenseBtn: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapper = UITapGestureRecognizer(target: self.view, action:#selector(self.view.endEditing(_:)))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
        
        configureView()
    }
    
    var editingExpense: Expense? {
        didSet {
            // Update the view.
            editingMode = true
            configureView()
        }
    }
    
    func configureView(){
        if let expense = editingExpense{
            if let field = nameTf{
                field.text = expense.name
            }
            if let field = amountTf{
                field.text = "\(expense.amount)"
            }
            if let field = addNoteTf{
                field.text = expense.notes
            }
            if let picker = datePicker{
                picker.date = expense.date!
            }
            if let _switch = addToCalenderBtn{
                _switch.isOn = expense.expense_due
            }
            if let segment = occurenceBtn{
                segment.selectedSegmentIndex = Int(expense.occurrence)
            }
        }
    }
    
    @IBAction func onDateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @IBAction func dueDateOnChanged(_ sender: UIDatePicker) {
        duteDate = sender.date
    }
    
    @IBAction func onClickAddExpense(_ sender: UIButton) {
        //get access to the appDelgate
        if editingMode {
            var newExp = NSManagedObject()
            newExp = editingExpense! as Expense
            newExp.setValue(nameTf.text ?? "NONE", forKey: "name")
            newExp.setValue(Double(amountTf.text ?? "0.0") ?? 0.0, forKey: "amount")
            newExp.setValue(addNoteTf.text ?? "NONE", forKey: "notes")
            newExp.setValue(datePicker.date , forKey: "date")
            newExp.setValue(addToCalenderBtn.isOn , forKey: "expense_due")
            newExp.setValue(Int16(occurenceBtn.selectedSegmentIndex) , forKey: "occurrence")
            if addToCalenderBtn.isOn  {
                // Delete the calender details
                if editingMode && editingExpense!.eventId != ""{
                    deleteCalenderEvent(event: eventStore.event(withIdentifier: editingExpense!.eventId!)!)
                }
                // Create a reminder
                newExp.setValue( self.createReminder(newExp as! Expense) , forKey: "eventId")
            }else{
                if let expense = editingExpense{
                    if(expense.eventId != "" && expense.eventId != nil){
                        deleteCalenderEvent(event: eventStore.event(withIdentifier: expense.eventId!)!)
                    }
                }
                
                newExp.setValue("", forKey: "eventId")
            }
            do {
                try context.save()
            } catch let error as NSError {
                print(error)
            }
            dismissModule()
            return
        }
        
        // New Expense
        let newExp = Expense(context: context)
        newExp.name = nameTf.text
        newExp.amount = Double(amountTf.text ?? "0.0") ?? 0.0
        newExp.date = datePicker.date
        newExp.notes = addNoteTf.text
        newExp.occurrence = Int16(occurenceBtn.selectedSegmentIndex)
        newExp.expense_due = addToCalenderBtn.isOn
        selectedCategory?.addToExpense(newExp)
        if newExp.expense_due  {
            newExp.eventId = self.createReminder(newExp)
        }
        do {
            try context.save()
        } catch _ as NSError {
            let alert = UIAlertController(title: "Error", message: "An error occured while saving the task.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        dismissModule()
    }
    
    func createReminder(_ expense: Expense) -> String {
        let semaphore = DispatchSemaphore(value: 0)
        var eventId = ""
        eventStore.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                
                let event:EKEvent = EKEvent(eventStore: self.eventStore)
                let reminder:EKReminder = EKReminder(eventStore: self.eventStore)
                
                event.title = "\(expense.name ?? "")"
                event.startDate = expense.date
                event.endDate = expense.date
                event.notes = expense.notes
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                reminder.calendar = self.eventStore.defaultCalendarForNewReminders()

                var occurence: EKRecurrenceFrequency? = nil
                
                switch expense.occurrence {
                case 1:
                    occurence = EKRecurrenceFrequency.daily
                case 2:
                    occurence = EKRecurrenceFrequency.weekly
                case 3:
                    occurence = EKRecurrenceFrequency.monthly
                default:
                    occurence = nil
                }
                
                if occurence != nil {
                    let ek: EKRecurrenceRule = EKRecurrenceRule.init(recurrenceWith: occurence!, interval: 1, end: EKRecurrenceEnd(end: self.dueDatePicker.date))
                    event.recurrenceRules = [ek]
                }
                
                do {
                    try self.eventStore.save(event, span: .thisEvent)
                    eventId = event.eventIdentifier
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
                print("Saved Event")
            }
            else{
                print("failed to save event with error : \(error) or access not granted")
            }
            semaphore.signal()
        }
        semaphore.wait()
        return eventId
    }
    
    func deleteCalenderEvent(event:EKEvent){
        do {
            event.recurrenceRules?.removeAll()
            try self.eventStore.save(event, span: .futureEvents)
            try eventStore.remove(event, span: .futureEvents, commit: true)
        } catch  {
            print("COULD NOT DELETE OLD EVENT")
        }
        
    }
    
    // Dismiss Popover
    func dismissModule() {
        dismiss(animated: true, completion: nil)
    }
}

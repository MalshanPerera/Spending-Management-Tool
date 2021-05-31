//
//  AddCategoryViewController.swift
//  Spending Management Tool
//
//  Created by Malshan Perera on 5/12/21.
//

import UIKit

class AddCategoryViewController: UIViewController {
    
    var colorBtnList: [UIButton] = []
    var colorInt: Int16 = 0
    var editingMode: Bool = false

    @IBOutlet weak var categoryNameTf: UITextField!
    @IBOutlet weak var budgetTf: UITextField!
    @IBOutlet weak var noteTf: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var pinkBtn: UIButton!
    @IBOutlet weak var blueBtn: UIButton!
    @IBOutlet weak var yellowBtn: UIButton!
    @IBOutlet weak var greenBtn: UIButton!
    @IBOutlet weak var cyanBtn: UIButton!
    @IBOutlet weak var redBtn: UIButton!
    @IBOutlet weak var orangeBtn: UIButton!
    
    var editingCategory: Category? {
        didSet {
            // Update the view.
            editingMode = true
            configureView()
        }
    }
    
    func configureView() {
        if editingMode {
            self.navigationItem.title = "Edit Project"
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        
        if editingCategory != nil {
            if categoryNameTf != nil {
                categoryNameTf.text = editingCategory?.name
            }
            if budgetTf != nil {
                budgetTf.text = "\(editingCategory?.monthly_budget ?? 0.0)"
            }
            if noteTf != nil {
                noteTf.text = editingCategory?.notes
            }
            
            switch editingCategory?.color {
            case 0:
                if pinkBtn != nil {
                    getColorBtn(button: pinkBtn)
                }
            case 1:
                if blueBtn != nil {
                    getColorBtn(button: blueBtn)
                }
            case 2:
                if yellowBtn != nil {
                    getColorBtn(button: yellowBtn)
                }
            case 3:
                if greenBtn != nil {
                    getColorBtn(button: greenBtn)
                }
            case 4:
                if cyanBtn != nil {
                    getColorBtn(button: cyanBtn)
                }
            case 5:
                if redBtn != nil {
                    getColorBtn(button: redBtn)
                }
            case 6:
                if orangeBtn != nil {
                    getColorBtn(button: orangeBtn)
                }
            default:
                print("No Color")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addColorBtnToList()
        configureView()
    }
    
    // Add all the color buttons into a list
    func addColorBtnToList() {
        colorBtnList.append(pinkBtn)
        colorBtnList.append(blueBtn)
        colorBtnList.append(yellowBtn)
        colorBtnList.append(greenBtn)
        colorBtnList.append(cyanBtn)
        colorBtnList.append(redBtn)
        colorBtnList.append(orangeBtn)
    }
    
    @IBAction func onColorChanged(_ sender: UIButton) {
        // Get the tag of the selected button
        switch sender.tag {
        case 0:
            getColorBtn(button: pinkBtn)
            colorInt = Colors.pink.rawValue
        case 1:
            getColorBtn(button: blueBtn)
            colorInt = Colors.blue.rawValue
        case 2:
            getColorBtn(button: yellowBtn)
            colorInt = Colors.yellow.rawValue
        case 3:
            getColorBtn(button: greenBtn)
            colorInt = Colors.green.rawValue
        case 4:
            getColorBtn(button: cyanBtn)
            colorInt = Colors.teal.rawValue
        case 5:
            getColorBtn(button: redBtn)
            colorInt = Colors.purple.rawValue
        case 6:
            getColorBtn(button: orangeBtn)
            colorInt = Colors.orange.rawValue
        default:
            print("No Button")
        }
    }
    
    @IBAction func onClickAdd(_ sender: UIButton) {
        saveCategory()
    }
    
    // Get the selected button to change the shadow color
    func getColorBtn(button: UIButton) {
        for colorBtn in colorBtnList {
            if (colorBtn.isEqual(button)) {
                updateLayerProperties(button: colorBtn, opacity: 0.5)
            }else{
                updateLayerProperties(button: colorBtn, opacity: 0.0)
            }
        }
    }
    
    // Change the Shadow Color to show the selected color
    func updateLayerProperties(button: UIButton, opacity: CGFloat) {
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: opacity).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowOpacity = 1.0
        button.layer.masksToBounds = false
    }
    
    func saveCategory() {
        //get access to the appDelgate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if editingMode {
            let editedCategory = editingCategory!
            editedCategory.setValue(categoryNameTf.text, forKey: "name")
            editedCategory.setValue(Double(budgetTf.text ?? "0.0") ?? 0.0, forKey: "monthly_budget")
            editedCategory.setValue(colorInt, forKey: "color")
            editedCategory.setValue(noteTf.text, forKey: "notes")
        }else{
            let category: Category = Category(context: managedContext)
            category.name = categoryNameTf.text
            category.monthly_budget = Double(budgetTf.text ?? "0.0") ?? 0.0
            category.color = colorInt
            category.notes = noteTf.text
        }
        
        do {
            try managedContext.save()
        }catch let error as NSError{
            print("COULD NOT SAVE. \(error), \(error.userInfo)")
        }
        
        dismissPopOver()
    }
    
    // Dismiss Popover
    func dismissPopOver() {
        dismiss(animated: true, completion: nil)
    }
}

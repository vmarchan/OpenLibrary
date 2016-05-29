//
//  ViewController.swift
//  OpenLibrary
//
//  Created by Veronica Marchan on 22/5/16.
//  Copyright © 2016 vmarchan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var isbnCode: UITextField!
    @IBOutlet var imgBook: UIImageView!
    @IBOutlet var lblTitleBook: UILabel!
    @IBOutlet var lblAuthorBook: UILabel!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblAuthor: UILabel!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var imgWidth: NSLayoutConstraint!
    @IBOutlet var codePicker: UIPickerView!
    
    
    let baseUrl = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    let pickerData = ["0385472579", "978-84-376-0494-7", "0201558025", "9780980200447", "0451526538"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isbnCode.delegate = self
        self.codePicker.delegate = self
        self.codePicker.dataSource = self
        
        self.initStates()

        self.imgBook.layer.shadowColor = UIColor.grayColor().CGColor
        self.imgBook.layer.shadowOpacity = 0.5
        self.imgBook.layer.shadowOffset = CGSizeZero
        self.imgBook.layer.shadowRadius = 5
        
        //Keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    func initStates() -> Void{
        self.lblAuthorBook.text = ""
        self.lblTitleBook.text = ""
        self.imgBook.hidden = true
        self.imgWidth.constant = 0.0
        self.errorLabel.text = ""
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.view.endEditing(true)
        
        self.isbnCode.text = ""
        self.initStates()
        
    }
    
    @IBAction func searchAction(sender: AnyObject) {

        self.view.endEditing(true)
        
        if (self.isbnCode.text?.characters.count == 0) {
            let alert = UIAlertController(title: "¡Atención!", message: "Para realizar la búsqueda correctamente debe introducir el código ISBN", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic")
            }))
            
            presentViewController(alert, animated:true, completion:nil)
            
        } else {
            self.initStates()
            let isbn = self.isbnCode.text
            let urls = self.baseUrl + isbn!
            let url = NSURL(string: urls)
            let session = NSURLSession.sharedSession()
            let bloque = { (datos : NSData?, resp : NSURLResponse?, error : NSError?) -> Void in
                
                if (error != nil) {
                    //alert
                    let alertError = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertError.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                        print("Handle Ok logic")
                    }))
                    self.presentViewController(alertError, animated:true, completion:nil)
                } else {
                    let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
                    dispatch_async(dispatch_get_main_queue(), {
                        let data = texto?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                        
                        do {
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves)
                            
                            let cont = json as! NSDictionary
                            
                            if let key = self.isbnCode.text {
                                let bookKey = "ISBN:\(key)"
                                
                                //Get context if ISBN code exists
                                if let cont1 = cont[bookKey] as? NSDictionary {
                                    self.imgBook.hidden = false
                                    self.imgWidth.constant = 114.0
                                    
                                    //Set title if exists
                                    if let title : String = cont1["title"] as? String {
                                        self.lblTitleBook.text = title
                                    }
                                    
                                    //Set authors list if exist
                                    if let cont2 = cont1["authors"] as? NSArray {
                                        for author in cont2 {
                                            let name = author["name"] as! String
                                            if ((self.lblAuthorBook.text?.isEmpty) != nil) {
                                                self.lblAuthorBook.text = name
                                            } else {
                                                self.lblAuthorBook.text = "\(self.lblAuthorBook.text), \(name)"
                                            }
                                            
                                        }
                                    }
                                    
                                    //Set image if exists
                                    if let cont3 = cont1["cover"] as? NSDictionary {
                                        if let largeCover = cont3["large"] as? String {
                                            if let imgURL = NSURL(string: largeCover) {
                                                if let data = NSData(contentsOfURL: imgURL) {
                                                    self.imgBook.image = UIImage(data: data)
                                                }
                                            }

                                        } else if let mediumCover = cont3["medium"] as? String {
                                            if let imgURL = NSURL(string: mediumCover) {
                                                if let data = NSData(contentsOfURL: imgURL) {
                                                    self.imgBook.image = UIImage(data: data)
                                                }
                                            }

                                        } else if let smallCover = cont3["small"] as? String {
                                            if let imgURL = NSURL(string: smallCover) {
                                                if let data = NSData(contentsOfURL: imgURL) {
                                                    self.imgBook.image = UIImage(data: data)
                                                }
                                            }
                                            
                                        } else {
                                            self.imgBook.image = UIImage(named: "no-disponible")
                                        }
                                    } else {
                                        self.imgBook.image = UIImage(named: "no-disponible")
                                    }
                                } else {
                                    self.errorLabel.text = "Book is not found"
                                }
                            }
                        } catch let error as NSError {
                            print ("Filed to load: \(error)")
                            self.errorLabel.text = error.localizedDescription
                        }
                    })
                    
                }
            }
            let dt = session.dataTaskWithURL(url!, completionHandler:bloque)
            dt.resume()
        }
        
    }
    
    //PickerView methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.isbnCode.text = self.pickerData[row]
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.searchAction(self)
        return false
    }

}


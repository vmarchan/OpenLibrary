//
//  ViewController.swift
//  OpenLibrary
//
//  Created by Veronica Marchan on 22/5/16.
//  Copyright © 2016 vmarchan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet var isbnCode: UITextField!
    @IBOutlet var searchResponse: UITextView!
    
    let baseUrl = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.searchResponse.delegate = self
        self.isbnCode.delegate = self
        
//        self.searchResponse.layer.borderWidth = 1.0
//        self.searchResponse.layer.cornerRadius = 5.0
//        self.searchResponse.layer.shadowColor = UIColor.grayColor().CGColor
//        self.searchResponse.layer.shadowRadius = 1.0
//        self.searchResponse.layer.shadowOffset = CGSizeMake(1.0, 1.0)
//        self.searchResponse.layer.shadowOpacity = 0.5

        //Keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @IBAction func cancelAction(sender: AnyObject) {
        self.searchResponse.text = ""
        self.isbnCode.text = ""
    }
    
    @IBAction func searchAction(sender: AnyObject) {

        if (self.isbnCode.text?.characters.count == 0) {
            let alert = UIAlertController(title: "¡Atención!", message: "Para realizar la búsqueda correctamente debe introducir el código ISBN", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                print("Handle Ok logic")
            }))
            
            presentViewController(alert, animated:true, completion:nil)
            
        } else {
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
                        self.searchResponse.text = texto! as String
                    })
                    
                }
            }
            let dt = session.dataTaskWithURL(url!, completionHandler:bloque)
            dt.resume()
        }
        
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


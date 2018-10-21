//
//  PostViewController.swift
//  melb-instgram
//
//  Created by 彭艳筠 on 2018/10/18.
//  Copyright © 2018年 彭艳筠. All rights reserved.
//

//import Foundation
import UIKit

class PostViewController:UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image=postImage
        
    }
    
    @IBOutlet weak var textField:UITextField!
    @IBOutlet weak var imageView:UIImageView!
    var postImage:UIImage!
    
    @IBAction func post(_ sender:UIButton){
        let text = textField.text
        showAlert(msg: "Post successfully :)")
    }
    
    func showAlert(msg:String){
        let alertController = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
}

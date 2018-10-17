//
//  CameraController.swift
//  melb-instgram
//
//  Created by 彭艳筠 on 2018/10/12.
//  Copyright © 2018年 彭艳筠. All rights reserved.
//

import Foundation
import UIKit

class PhotoViewController:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    var originalImage:UIImage!
    
//    override func viewDidAppear(_ animated: Bool) {
////        self.imageView.image = self.originalImage
//    }
    

    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func showOriginalImage(_ originalImage:UIImage) {
        self.imageView.image = self.originalImage
    }
    
    
    @IBAction func showFilterImage(_ sender: Any) {
    }
    
    
}

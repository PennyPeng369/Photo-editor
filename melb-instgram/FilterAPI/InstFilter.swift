//
//  InstFilter.swift
//  melb-instgram
//
//  Created by 彭艳筠 on 2018/10/20.
//  Copyright © 2018年 彭艳筠. All rights reserved.
//

import UIKit

class InstFilter{
    
    //    var originalImage:UIImage!
    //    var currentImage:UIImage!
    
    var filter:CIFilter!
    var brightnessFilter:CIFilter!
    var contrastFilter:CIFilter!
    
    lazy var context: CIContext = {
        return CIContext(options: nil)
    }()
    
    init() {
        brightnessFilter=CIFilter(name:"CIColorControls")
        contrastFilter=CIFilter(name: "CIColorControls")
        //        self.currentImage=image
        //        self.originalImage=image
    }
    
    func filterAuto(image:UIImage!) -> UIImage? {
        var inputImage = CIImage(image: image)
        let newImage:UIImage?
        let filters = inputImage?.autoAdjustmentFilters() as! [CIFilter]
        for filter:CIFilter in filters {
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            inputImage = filter.outputImage
        }
        if let inputImage=inputImage{
            //            let newImage=UIImage(ciImage: inputImage)
            let cgImage = context.createCGImage(inputImage, from: inputImage.extent)
            newImage = UIImage(cgImage: cgImage!)
        }else{
            print("No image to operate :(")
            newImage=nil
        }
        return newImage
    }
    
    func filterChrome(image:UIImage!) -> UIImage?{
        self.filter=CIFilter(name: "CIPhotoEffectChrome")
        return filterOutImage(image:image)
    }
    
    func filterFade(image:UIImage!) -> UIImage?{
        self.filter=CIFilter(name: "CIPhotoEffectFade")
        return filterOutImage(image:image)
    }
    
    func filterNoir(image:UIImage!) -> UIImage?{
        self.filter=CIFilter(name: "CIPhotoEffectNoir")
        return filterOutImage(image:image)
    }
    
    func showOriginal(image:UIImage!) -> UIImage?{
        return image
    }
    
    func filterOutImage(image:UIImage!) -> UIImage?{
        let inputImage = CIImage(image: image) //change original image, which means filters cant's overlap (no multi-filters)
        self.filter.setValue(inputImage, forKey: kCIInputImageKey)
        let outputImage = self.filter.outputImage
        let newImage:UIImage?
        if let outputImage=outputImage{
            //            let newImage=UIImage(ciImage: outputImage)
            let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
            newImage = UIImage(cgImage: cgImage!)
        }else{
            newImage=nil
            print("No image to operate :(")
        }
        return newImage
    }
    
    func brightnessChange(image:UIImage!,value:Double)->UIImage?{
        let ciImage=CIImage(image:image)
        brightnessFilter.setValue(ciImage, forKey: "inputImage")
        brightnessFilter.setValue(NSNumber(value:value), forKey: "inputBrightness")
        let outputImage = brightnessFilter.outputImage //outputImage is CIImage, not UIImage
        let newImage:UIImage?
        if let outputImage=outputImage{
            //          let newImage=UIImage(ciImage: outputImage)
            let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
            newImage = UIImage(cgImage: cgImage!)
        }else{
            newImage=nil
            print("No image to operate :(")
        }
        return newImage
    }
    
    func contrastChange(image:UIImage!,value:Double)->UIImage?{
        let ciImage=CIImage(image: image)
        contrastFilter.setValue(ciImage, forKey: "inputImage")
        contrastFilter.setValue(NSNumber(value: value), forKey: "inputContrast")
        let outputImage = contrastFilter.outputImage
        let newImage:UIImage?
        if let outputImage=outputImage{
            //            let newImage=UIImage(ciImage: outputImage)
            let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
            newImage = UIImage(cgImage: cgImage!)
        }else{
            newImage=nil
            print("No image to operate :(")
        }
        return newImage
    }
}

let testImage=UIImage(named: "test.jpg")
let instFilter=InstFilter()
let filteredImage=instFilter.filterChrome(image: testImage)
let brightImage=instFilter.brightnessChange(image:filteredImage,value: 0.2)
let contrastImage=instFilter.contrastChange(image:brightImage,value: 1)

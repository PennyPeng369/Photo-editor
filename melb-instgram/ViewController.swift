//
//  ViewController.swift
//  melb-instgram
//
//  Created by 彭艳筠 on 2018/10/12.
//  Copyright © 2018年 彭艳筠. All rights reserved.
//

import UIKit

extension UIImage{
    func fixedOrientation() -> UIImage {
        // No-op if the orientation is already correct
        if (imageOrientation == UIImage.Orientation.up) {
            return self
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
        
        if (imageOrientation == UIImage.Orientation.down
            || imageOrientation == UIImage.Orientation.downMirrored) {
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        }
        
        if (imageOrientation == UIImage.Orientation.left
            || imageOrientation == UIImage.Orientation.leftMirrored) {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
        }
        
        if (imageOrientation == UIImage.Orientation.right
            || imageOrientation == UIImage.Orientation.rightMirrored) {
            transform = transform.translatedBy(x: 0, y: size.height);
            transform = transform.rotated(by: CGFloat(-1 * Double.pi/2))
        }
        
        if (imageOrientation == UIImage.Orientation.upMirrored
            || imageOrientation == UIImage.Orientation.downMirrored) {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if (imageOrientation == UIImage.Orientation.leftMirrored
            || imageOrientation == UIImage.Orientation.rightMirrored) {
            transform = transform.translatedBy(x: size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                      bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: cgImage!.colorSpace!,
                                      bitmapInfo: cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        
        if (imageOrientation == UIImage.Orientation.left
            || imageOrientation == UIImage.Orientation.leftMirrored
            || imageOrientation == UIImage.Orientation.right
            || imageOrientation == UIImage.Orientation.rightMirrored
            ) {
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.height,height:size.width))
        } else {
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.width,height:size.height))
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg:CGImage = ctx.makeImage()!
        let imgEnd:UIImage = UIImage(cgImage: cgimg)
        return imgEnd
    }
    
    func crop(ratio: CGFloat) -> UIImage {
        //计算最终尺寸
        var newSize:CGSize!
        if size.width/size.height > ratio {
            newSize = CGSize(width: size.height * ratio, height: size.height)
        }else{
            newSize = CGSize(width: size.width, height: size.width / ratio)
        }
        
        ////图片绘制区域
        var rect = CGRect.zero
        rect.size.width  = size.width
        rect.size.height = size.height
        rect.origin.x    = (newSize.width - size.width ) / 2.0
        rect.origin.y    = (newSize.height - size.height ) / 2.0
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}

extension UIImageView{
    func imageFrame()->CGRect{
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else{return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        }else{
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }
}

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate {
    var originalImage:UIImage!
    var currentImage:UIImage!
    var filteredImage:UIImage!
    var croppedImage:UIImage!
    var filter:CIFilter!
    var brightnessFilter:CIFilter!
    var contrastFilter:CIFilter!
    var gridImageView:UIImageView!
//    var originalImageView:UIImageView!
    var cropArea:CGRect{
        get{
//            let factor = imageView.image!.size.width/view.frame.width
            print(imageView.image!.size.width)
            print(view.frame.width)
            let scale = 1/scrollView.zoomScale
            let frame = imageView.imageFrame()
            let factorWidth = imageView.image!.size.width/frame.width
            let factorHeight = imageView.image!.size.height/frame.height
            let x = (scrollView.contentOffset.x + cropAreaView.frame.origin.x - frame.origin.x)  * factorWidth
            print(scrollView.contentOffset.x)
            print(cropAreaView.frame.origin.x)
            print(frame.origin.x)
            let y = (scrollView.contentOffset.y + cropAreaView.frame.origin.y - frame.origin.y-80) * factorHeight
            print(scrollView.contentOffset.y)
            print(cropAreaView.frame.origin.y)
            print(frame.origin.y)
            let width = cropAreaView.frame.size.width  * factorWidth
            let height = cropAreaView.frame.size.height  * factorHeight
            print(cropAreaView.frame.size.width)
            print(cropAreaView.frame.size.height)
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    lazy var context: CIContext = {
        return CIContext(options: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideSliders()
        brightnessSlider.isContinuous=false
        brightnessSlider.minimumValue = -0.5
        brightnessSlider.maximumValue = 0.5
        brightnessSlider.value = 0.0
        brightnessFilter=CIFilter(name:"CIColorControls")
        contrastSlider.isContinuous=false
        contrastSlider.minimumValue = 0.5
        contrastSlider.maximumValue = 3
        contrastSlider.value = 1.7
        contrastFilter=CIFilter(name: "CIColorControls")
        gridImageView=UIImageView(frame:CGRect(x:0, y:85, width:400, height:500))
        gridImageView.image=UIImage(named:"grid.png")
    }
        
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
        }
    }
    @IBOutlet var cropAreaView: CropAreaView!
    
    
    @IBAction func cameraView(_ sender: UIButton) {
        hideSliders()
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let picker=UIImagePickerController()
            picker.delegate=self
            picker.sourceType = .camera
            picker.cameraOverlayView = gridImageView
            picker.cameraViewTransform = picker.cameraViewTransform.translatedBy(x:0,y:44)
//            picker.allowsEditing=true
//            picker.cameraFlashMode = .on
            self.present(picker,animated:true,completion:nil)
        }else{
            showAlert(msg: "Cannot find a camera :(")
        }
    }
    
    @IBAction func albumView(_ sender: Any) {
        hideSliders()
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let picker=UIImagePickerController()
            picker.delegate=self
            picker.sourceType = .photoLibrary
//            picker.allowsEditing=true
            self.present(picker,animated:true,completion:nil)
        }else{
            showAlert(msg: "Cannot find an album :(")
        }
    }
    
    @IBAction func filterAuto(_ sender: Any) {
        hideSliders()
        let newImage=forFilterAuto(image: croppedImage)
        self.imageView.image=newImage
        self.currentImage=newImage
        //Update filteredImage
        let newFilteredImage=forFilterAuto(image: originalImage)
        self.filteredImage=newFilteredImage
    }
    
    func  forFilterAuto(image:UIImage!) -> UIImage? {
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
            showAlert(msg: "No image to operate :(")
            newImage=nil
        }
        return newImage
    }
    
    @IBAction func filterChrome(_ sender: Any) {
        hideSliders()
        self.filter=CIFilter(name: "CIPhotoEffectChrome")
        filterOutImage()
    }
    
    @IBAction func filterFade(_ sender: Any) {
        hideSliders()
        self.filter=CIFilter(name: "CIPhotoEffectFade")
        filterOutImage()
    }
    
    @IBAction func filterNoir(_ sender: Any) {
        hideSliders()
        self.filter=CIFilter(name: "CIPhotoEffectNoir")
        filterOutImage()
    }
    
    @IBAction func showOriginal(_ sender: Any) {
        hideSliders()
        self.imageView.image=self.originalImage
        self.currentImage=self.originalImage
        self.croppedImage=self.originalImage
        self.filteredImage=self.originalImage
    }
    
    @IBAction func brightnessChange(_ sender: UISlider) {
        brightnessSlider.isHidden=false
        contrastSlider.isHidden=true
        let ciImage=CIImage(image: currentImage)
        brightnessFilter.setValue(ciImage, forKey: "inputImage")
    }
    
    @IBAction func brightnessValueChanged(_ sender: UISlider) {
        brightnessFilter.setValue(NSNumber(value: sender.value), forKey: "inputBrightness")
        let outputImage = brightnessFilter.outputImage
        if let outputImage=outputImage{
//            let newImage=UIImage(ciImage: outputImage)
            let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
            let newImage = UIImage(cgImage: cgImage!)
            self.imageView.image=newImage
            self.currentImage=newImage
            self.brightnessSlider.value=sender.value
        }else{
            showAlert(msg: "No image to operate :(")
        }
    }

    @IBAction func contrastChange(_ sender: UIButton) {
        brightnessSlider.isHidden=true
        contrastSlider.isHidden=false
        let ciImage=CIImage(image: currentImage)
        contrastFilter.setValue(ciImage, forKey: "inputImage")
    }
    
    @IBAction func contrastValueChanges(_ sender: UISlider) {
        
        contrastFilter.setValue(NSNumber(value: sender.value), forKey: "inputContrast");
        let outputImage = contrastFilter.outputImage;
        if let outputImage=outputImage{
//            let newImage=UIImage(ciImage: outputImage)
            let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
            let newImage = UIImage(cgImage: cgImage!)
            self.imageView.image=newImage
            self.currentImage=newImage
            
            self.contrastSlider.value=sender.value
        }else{
            showAlert(msg: "No image to operate :(")
        }
    }
    
    @IBAction func cropImage(_ sender: UIButton) {
        hideSliders()
        let croppedCGImage = imageView.image?.cgImage?.cropping(to: cropArea)
        let croppedImage = UIImage(cgImage: croppedCGImage!)
        imageView.image = croppedImage
        self.currentImage=croppedImage
        self.filteredImage=croppedImage
        self.croppedImage=croppedImage
        self.originalImage=croppedImage
        scrollView.maximumZoomScale=1
        scrollView.minimumZoomScale=1
        scrollView.zoomScale = 1
        cropAreaView.alpha=0
    }
    
    @IBAction func goBack(_ sender: Any) {
        
    }
    
    @IBAction func goNext(_ sender: Any) {
        performSegue(withIdentifier: "goToPost", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender:Any?) {
        if segue.identifier == "goToPost", let postController = segue.destination as? PostViewController {
            postController.postImage = currentImage as? UIImage // sender 为 performSegue 方法设置的值
        }
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func showAlert(msg:String){
        let alertController = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    func filterOutImage(){
        let newImage=forFilterOutImage(image: croppedImage)
        self.imageView.image=newImage
        self.currentImage=newImage
        //Update filteredImage
        let newFilteredImage = forFilterOutImage(image: originalImage)
        self.filteredImage=newFilteredImage
    }
    
    func forFilterOutImage(image:UIImage!)->UIImage?{
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
            showAlert(msg: "No image to operate :(")
        }
        return newImage
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image=info[UIImagePickerController.InfoKey.originalImage] as! UIImage // as! downcasting 向下类型转换
        image=image.fixedOrientation()  //pickered image has left 90 degree rotation error...so we need to fix orientation
        cropAreaView.alpha=0.35
        self.imageView.image=image
        self.originalImage=image
        self.filteredImage=image
        self.croppedImage=image
        self.currentImage=image
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 3.0
        //        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        picker.dismiss(animated: true,completion:nil)
    }
    
    func hideSliders(){
        brightnessSlider.isHidden=true
        contrastSlider.isHidden=true
    }
}

class CropAreaView: UIView {
    override func point(inside point: CGPoint, with event:   UIEvent?) -> Bool {
        return false
    }
}


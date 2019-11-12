//
//  ViewController.swift
//  ImageModifier
//
//  Created by Дмитрий Ю on 05.11.2019.
//  Copyright © 2019 Дмитрий Ю. All rights reserved.
//

import UIKit


@IBDesignable
class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var buferImage : UIImage?
    var transformImage : UIImage?
    var colorMas : [UIColor]? = []
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var image : UIImageView!
    
    @IBAction func transformR (_ sender : UILongPressGestureRecognizer) {
        image.image = buferImage!
        if sender.state == .ended {
            image.image = transformImage!
        }
    }
    
    
    @IBAction func openGallery (_ sender : UIButton) {

        let alertController: UIAlertController = UIAlertController(title: nil, message: "Источник изображения:", preferredStyle: .actionSheet)
        let gallaryAction = UIAlertAction(title: "Галерея", style: .default){
            UIAlertAction in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(gallaryAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
      
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        buferImage = (info[.editedImage] as! UIImage)
        //image.contentMode = .scaleAspectFit
        image.image  = transformImageR(in: (info[.editedImage] as! UIImage))
        transformImage = image.image
        picker.dismiss(animated: true, completion: nil)
   }
    
    
    @IBAction func saveImage (_ sender : UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
//=================================================================================================
    
    func findColors(_ image: UIImage) -> [UIColor] {
        let pixelsWide = Int(image.size.width)
        let pixelsHigh = Int(image.size.height)

        guard let pixelData = image.cgImage?.dataProvider?.data else { return [] }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        var imageColors: [UIColor] = []
        for x in 0..<pixelsWide {
            for y in 0..<pixelsHigh {
                let point = CGPoint(x: x, y: y)
                let pixelInfo: Int = ((pixelsWide * Int(point.y)) + Int(point.x)) * 4
                let color = UIColor(red: CGFloat(data[pixelInfo]) / 255.0,
                                    green: CGFloat(data[pixelInfo + 1]) / 255.0,
                                    blue: CGFloat(data[pixelInfo + 2]) / 255.0,
                                    alpha: CGFloat(data[pixelInfo + 3]) / 255.0)
                imageColors.append(color)
            }
        }
        return imageColors
    }
   

    struct RGBA32: Equatable {
        private var color: UInt32

        var redComponent: UInt8 {
            return UInt8((color >> 24) & 255)
        }

        var greenComponent: UInt8 {
            return UInt8((color >> 16) & 255)
        }

        var blueComponent: UInt8 {
            return UInt8((color >> 8) & 255)
        }

        var alphaComponent: UInt8 {
            return UInt8((color >> 0) & 255)
        }

        init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            let red   = UInt32(red)
            let green = UInt32(green)
            let blue  = UInt32(blue)
            let alpha = UInt32(alpha)
            color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
        }

        static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
        static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
        static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
        static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
        static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
        static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
        static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
        static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)

        static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

        static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
            return lhs.color == rhs.color
        }
    }
    
    
    func transformImageR(in image: UIImage) -> UIImage? {
        
        
        guard let inputCGImage = image.cgImage else { print("unable to get cgImage"); return nil }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo


        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("Cannot create context!"); return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let buffer = context.data else { print("Cannot get context data!"); return nil }

        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)

        for row in 0 ..< Int(height) {
            for column in 0 ..< Int(width) {
                let offset = row * width + column

                if pixelBuffer[offset].redComponent >= 0 && pixelBuffer[offset].redComponent <= 255 && pixelBuffer[offset].greenComponent >= 0 && pixelBuffer[offset].greenComponent <= 255 &&
                    pixelBuffer[offset].blueComponent >= 0 && pixelBuffer[offset].blueComponent <= 255 {
                    //pixelBuffer[offset] = .magenta
                    pixelBuffer[offset] = .init(red: UInt8(Int.random(in: 0...255)),
                                                green: pixelBuffer[offset].greenComponent,
                                                blue: pixelBuffer[offset].blueComponent,
                                                alpha: 255)
                }
            }
        }

        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)

        return outputImage
    }
    
    
}



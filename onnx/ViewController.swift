//
//  ViewController.swift
//  onnx
//
//  Created by 柚木努 on 2020/02/27.
//  Copyright © 2020 柚木努. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var previewImage: UIImageView!
    var picker: UIImagePickerController! = UIImagePickerController()
    var image:UIImage?
    let classes = ["plane", "car", "bird", "cat",
                   "deer", "dog", "frog", "horse", "ship", "truck"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    @IBAction func predictionButton(_ sender: UIButton) {
        
        guard let _image = image else{
            print("image is invalid")
            return
        }
        print(_image.size)
        
        
        
        
        
        
//        coreMLRequest(image: _image)
        
        
        let net = CNN_ONNX() 
        

        guard let model = try? VNCoreMLModel(for: net.model) else{
            print("error model")
            return
        }
         //リクエスト
        let request = VNCoreMLRequest(model: model){
            request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            // 確率を整数にする
            let conf = Int(results[0].confidence)
            // 候補の１番目
            let name = results[0].identifier

            print("conf = \(conf)")
            print("classification = \(self.classes[Int(name)!])")
//            if conf >= 50{
//                self.label.text = "\(name) です。確率は\(conf)% \n"
//            }
//            else{
//                self.label.text = "もしかしたら、\(name) かも。確率は\(conf)% \n"
//            }

        }

        // 画像のリサイズ
//        request.imageCropAndScaleOption = .centerCrop

        // CIImageに変換
        guard let ciImage = CIImage(image: _image) else {
            return
        }

        // 画像の向き
        let orientation = CGImagePropertyOrientation(
            rawValue: UInt32(_image.imageOrientation.rawValue))!

        // ハンドラを実行
//        let handler = VNImageRequestHandler(
//            cgImage: _image.cgImage!)
        let handler = VNImageRequestHandler(
            ciImage: ciImage, orientation: orientation)

        do{
            try handler.perform([request])

        }catch {
            print("error handler")
        }


        
        
    }
    
//    func coreMLRequest(image: UIImage){
//        let imgSize: Int = 32
//        let imageShape: CGSize = CGSize(width: imgSize, height: imgSize)
//
//        //(280, 280)の画像サイズを(28, 28)にリサイズして、更にpixelBufferに変換。
//        let imagePixel = image.resize(to: imageShape).getPixelBuffer()
//
//        //(1, 28, 28)のMLMultiArrayを生成し、pixelBufferに変換した画像を格納する。
//        let mlarray = try! MLMultiArray(shape: [1, NSNumber(value: imgSize), NSNumber(value: imgSize)], dataType: MLMultiArrayDataType.float32 )
//        for i in 0..<imgSize*imgSize {
//            mlarray[i] = imagePixel[i] as NSNumber
//        }
//
//        //プロジェクトに追加したCore MLのモデル（"MNIST.mlmodel"）をロード
//        let CNN = CNN_ONNX()
//
//        //画像データを格納したMLMultiArrayをモデルに入力し、書かれている数字を予測する。
//        //入力用の変数名（input_1）、出力用の変数名（_10）は"MNIST.mlmodel"の詳細で確認した通り。
//        if let prediction = try? CNN.prediction(input: mlarray) {
//            if let first = (prediction.output.sorted{ $0.value > $1.value}).first{
//                print("予測：\(Int(first.key))")
//            }
//        }
//    }
    
    
    @IBAction func imageButton(_ sender: UIButton) {
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.delegate = self
        picker.navigationBar.tintColor = UIColor.white
        picker.navigationBar.barTintColor = UIColor.gray
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let uiimage = info[.originalImage] as? UIImage{
            
            image = uiimage
            previewImage.image = uiimage
            
        }
        picker.dismiss(animated: true, completion: nil)

        
    }
    
    
}
//
//extension UIImage {
////画像を指定のサイズにリサイズする（参考サイトのコードそのまま）。
//func resize(to newSize: CGSize) -> UIImage {
//    UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), true, 1.0)
//    self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
//    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
//    UIGraphicsEndImageContext()
//    return resizedImage
//}
//
////画像をpixelBufferに変換。ただし参考サイトのコードを一部変更して、
////ピクセル値を二値化はせずに0.0〜1.0の値として扱う（元々のモデルに合わせる）
//    func getPixelBuffer() -> [Float]{
//        guard let cgImage = self.cgImage else {
//            return []
//        }
//        let bytesPerRow = cgImage.bytesPerRow
//        let width = cgImage.width
//        let height = cgImage.height
//        let bytesPerPixel = 4
//        let pixelData = cgImage.dataProvider!.data! as Data
//        var buf : [Float] = []
//
//        for j in 0..<height {
//            for i in 0..<width {
//                let pixelInfo = bytesPerRow * j + i * bytesPerPixel
//                let r = CGFloat(pixelData[pixelInfo])
//                let g = CGFloat(pixelData[pixelInfo+1])
//                let b = CGFloat(pixelData[pixelInfo+2])
//
//                let v: Float = floor(Float(r + g + b)/3.0)/255.0
//
//                buf.append(v)
//            }
//        }
//        return buf
//    }
//
//}


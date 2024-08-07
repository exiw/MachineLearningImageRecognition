//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Emre Konukpay on 3.08.2024.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func changeClicked(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        
        if let ciImage = CIImage(image: imageView.image!){
            chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage)
    }
    
    func recognizeImage(image: CIImage){
        
        
        resultLabel.text = "Finding ..."
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model){
            let request = VNCoreMLRequest(model:model) { (vnrequest,error) in
                if let results = vnrequest.results as? [VNClassificationObservation]{
                    if results.count > 0 {
                        DispatchQueue.main.async {
                                            
                                            var resultText = ""
                                            let topResultsCount = min(3, results.count) 
                                            for i in 0..<topResultsCount {
                                                let result = results[i]
                                                let confidenceLevel = (result.confidence) * 100
                                                let rounded = Int(confidenceLevel * 100) / 100
                                                resultText += "\(rounded)% it's \(result.identifier)\n"
                                            }
                                            self.resultLabel.text = resultText
                                        }
                                    }
                                }
                            }

                let handler = VNImageRequestHandler(ciImage: image)
                    DispatchQueue.global(qos: .userInteractive).async {
                     do{
                        try handler.perform([request])
                     }
                     catch{
                        print("error")
                     }
                    
                }
            }
        }
       
    }



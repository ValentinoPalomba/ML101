//
//  ViewController.swift
//  ML101
//
//  Created by Giuseppe Giaquinto on 30/03/2020.
//  Copyright © 2020 Giuseppe Giaquinto. All rights reserved.
//

import UIKit
import CoreML
import Vision
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var rectSfumato: UIView!
    @IBOutlet weak var sfondoCani: UIImageView!
    
   
    @IBOutlet var resultsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsLabel.alpha = 0.0
        rectSfumato.layer.cornerRadius = 31
        rectSfumato.clipsToBounds = true
        rectSfumato.layer.masksToBounds = false
        rectSfumato.layer.shadowRadius = 9
        rectSfumato.layer.shadowOpacity = 0.5
        rectSfumato.layer.shadowOffset = CGSize(width: 2, height: 2)
        rectSfumato.layer.shadowColor = UIColor.black.cgColor
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func choosePhoto(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            else{
                print("Camera not avaiable!")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { (action: UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        picker.dismiss(animated: true, completion: nil)
        
        classify(image: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    func showResults(){
        resultsLabel.alpha = 1.0
    }
    
    
    
    /* Parte Aggiunta Machine Learning, Qui Dichiaro la richiesta da fare al modello */
    
     lazy var vnRequest : VNCoreMLRequest = {
            let model = try! VNCoreMLModel(for: DogModel().model)
            let request = VNCoreMLRequest(model: model) { [weak self] request , _ in
                self?.processingResult(for: request)
            }
            request.imageCropAndScaleOption = .centerCrop
            return request
    }()
    
    /* Classify function used to make the image respect property and orientation of ML model*/
    
    func classify(image : UIImage){
           DispatchQueue.global(qos: .userInitiated).async {
               let ciImage = CIImage(image: image)!
                let imageOrientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: imageOrientation)
                try! handler.perform([self.vnRequest])
           }
               
           
       }
    
       
    func processingResult(for request: VNRequest){
           DispatchQueue.main.async {
               let results = (request.results! as! [VNClassificationObservation]).prefix(2)
               self.resultsLabel.text = results.map { result in
                   let formatter = NumberFormatter()
                   formatter.maximumFractionDigits = 1
                
                    let percentage = formatter.string(from: result.confidence * 100 as NSNumber)!
                let integerPercentage = (result.confidence*100 as Float)
                if Int(integerPercentage) > 30 {
                    return "Your dog is \(result.identifier.components(separatedBy: CharacterSet.decimalDigits).joined()) \(percentage)%"
                }
                else{
                   return "Dog not recognized"
                }
               }.joined()
            self.showResults()
           }
           
           
       }

    
    
    
    
}


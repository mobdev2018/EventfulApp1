//
//  PhotoViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/20/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PhotoViewController: UIViewController {
    var eventKey = ""
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var backgroundImage: UIImage
    
    init(image: UIImage) {
        self.backgroundImage = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.contentMode = UIViewContentMode.scaleAspectFit
        backgroundImageView.image = backgroundImage
        view.addSubview(backgroundImageView)
        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
        cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        let nextButton = UIButton(frame: CGRect(x: 320, y: 600, width: 30, height: 30))
        nextButton.backgroundColor = UIColor.clear
        nextButton.setImage(#imageLiteral(resourceName: "next"), for: UIControlState())
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        view.addSubview(nextButton)
    }
    
    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Takes you to AddPostViewController
    @objc func nextPressed()
    {
        print("Next Button pressed")
        
        // Setting nil to the player so video will stop playing
        let alertController = UIAlertController(title: "Add To The Hype??", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let addAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.handleAddToStory()
        }
        alertController.addAction(addAction)
        let cancelAction = UIAlertAction(title: "No", style: .default) { (_) in
            self.handleDontAddToStory()
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated:true, completion: nil)
        
    }
    
    func handleAddToStory(){
        print("Attempting to add to story")
        print(self.eventKey)
        let dateFormatter = ISO8601DateFormatter()
        let timeStamp = dateFormatter.string(from: Date())
        let uid = User.current.uid
        let storageRef = Storage.storage().reference().child("event_stories").child(self.eventKey).child(uid).child(timeStamp + ".PNG")
        StorageService.uploadImage(backgroundImage , at: storageRef) { (downloadUrl) in
            guard let downloadUrl = downloadUrl else {
                return
            }
            
            let videoUrlString = downloadUrl.absoluteString
            print(videoUrlString)
            PostService.create(for: self.eventKey, for: videoUrlString)
            
        }
        //svprogresshud insert here
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    func handleDontAddToStory(){
        _ = self.navigationController?.popViewController(animated: true)
        
    }

    
    
    
    
    
}

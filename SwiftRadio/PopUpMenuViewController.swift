//
//  PopUpMenuViewController.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/9/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit

class PopUpMenuViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var backgroundView: UIImageView!
    
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var webButton: UIButton!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
    }
    
    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Round corners
        popupView.layer.cornerRadius = 10
        instagramButton.layer.cornerRadius = 10
        facebookButton.layer.cornerRadius = 10
        webButton.layer.cornerRadius = 10

        
        // Set background color to clear
        view.backgroundColor = UIColor.clear
        
        // Add gesture recognizer to dismiss view when touched
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeButtonPressed))
        backgroundView.isUserInteractionEnabled = true
        backgroundView.addGestureRecognizer(gestureRecognizer)
    }
    
    //*****************************************************************
    // MARK: - IBActions
    //*****************************************************************

    @IBAction func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
   
    @IBAction func websiteButtonPressed(_ sender: UIButton) {
        navigate(url: "http://www.wowrradio.com.au/")
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        navigate(url: "https://www.facebook.com/wowradio.go/")
    }
    
    @IBAction func instagramButtonPressed(_ sender: Any) {
        navigate(url: "https://instagram.com/woowfm?igshid=1bat8hj6n5u36")
    }
    
    
    func navigate(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

//
//  SnapVC.swift
//  SnapchatClone
//
//  Created by Sarthak Goel on 29/06/23.
//

import UIKit
import ImageSlideshow

class SnapVC: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    var selectedSnap : Snap?
    
    var imageInputArray = [AlamofireSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let snap = selectedSnap {
            timeLabel.text = "Time Left: \(snap.timeLeft)"
            
            for imageUrl in snap.imageUrlArray {
                imageInputArray.append(AlamofireSource(urlString: imageUrl)!)
            }
            
            let imageSlideShow = ImageSlideshow(frame: CGRect(x: 10, y: 10, width: self.view.frame.width * 0.95, height: self.view.frame.height * 0.9))
            imageSlideShow.backgroundColor = .white
            
            let pageIndicator = UIPageControl()
            pageIndicator.currentPageIndicatorTintColor = .lightGray
            pageIndicator.pageIndicatorTintColor = .black
            imageSlideShow.pageIndicator = pageIndicator
            
            imageSlideShow.contentScaleMode = .scaleAspectFit
            imageSlideShow.setImageInputs(imageInputArray)
            
            self.view.addSubview(imageSlideShow)
            self.view.bringSubviewToFront(timeLabel)
        }
    }
}

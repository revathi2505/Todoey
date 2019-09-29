//
//  TopNewsVC.swift
//  GUO Media
//
//  Created by Easyway_Mac2 on 08/07/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import AVKit

class TopNewsVC: UIViewController {
    
    @IBOutlet var topNewsCollectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var previousButton: UIButton!
    
    var parentNewsVC: NewsVC?
    var parentLibraryVC: LibraryVC?
    private let cellId = "TOPNEWS"
    private var timer: Timer?
    
    var topNewsHeadlines: [Headline]? {
        didSet {
            stopTimer()
            
            self.topNewsCollectionView.reloadData()
            pageControl.currentPage = 0
            
            if let headlineCount = self.topNewsHeadlines?.count {
                pageControl.numberOfPages = headlineCount
                if headlineCount > 1 {
                    self.startTimer()
                }
                nextButton.isHidden = headlineCount <= 1
                previousButton.isHidden = headlineCount <= 1
                pageControl.isHidden = headlineCount <= 1
            }
        }
    }
    
    private func registerCells() {
        topNewsCollectionView.register(UINib(nibName: "TopCell", bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerCells()
        // Do any additional setup after loading the view.
    }
    
    private func moveButtonsOffPage() {
        previousButton.isHidden = pageControl.currentPage == 0 ? true : false
        nextButton.isHidden = pageControl.currentPage == topNewsHeadlines?.count ? true : false
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x/self.topNewsCollectionView.frame.size.width)
        pageControl.currentPage = pageNumber
        moveButtonsOffPage()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        if pageControl.currentPage == ((topNewsHeadlines?.count) ?? 0) - 1 {
            pageControl.currentPage = 0
            let indexPath = IndexPath(item:0 , section: 0)
            topNewsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            let indexPath = IndexPath(item:pageControl.currentPage + 1 , section: 0)
            topNewsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            pageControl.currentPage = pageControl.currentPage + 1
        }
        
        moveButtonsOffPage()
    }
    
    @IBAction func previousButtonTapped(_ sender: UIButton) {
        let indexPath = IndexPath(item:pageControl.currentPage - 1 , section: 0)
        pageControl.currentPage = pageControl.currentPage - 1
        topNewsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        moveButtonsOffPage()
    }

    @IBAction func pageControlAction(_ sender: UIPageControl) {
        let page: Int = sender.currentPage
        var frame: CGRect = self.topNewsCollectionView.frame
        frame.origin.x = frame.size.width * CGFloat(page )
        frame.origin.y = 0
        self.topNewsCollectionView.scrollRectToVisible(frame, animated: true)
    }
}

//MARK: Timer action

extension TopNewsVC {
    
    private func startTimer () {
        
        if self.timer == nil {
            self.timer =  Timer.scheduledTimer(
                timeInterval: TimeInterval(3.0),
                target      : self,
                selector    : #selector(self.nextButtonTapped(_:)),
                userInfo    : nil,
                repeats     : true)
            
            //RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
        }
    }
    
    private func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
  
    
}

//MARK: UICollection View

extension TopNewsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = topNewsHeadlines?.count ?? 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = topNewsCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TopNewsCollectionCell
        cell.newsHeadline = topNewsHeadlines?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // check for isVideo if necessary
        
        let cell = topNewsCollectionView.cellForItem(at: indexPath) as! TopNewsCollectionCell
    
        if cell.headlineTitleLabel.text == "" {
            return
        }
        
        if var webUrl = cell.newsHeadline?.url {
            
            if webUrl.caseInsensitiveCompare("NULL") != .orderedSame {
                
                didTapCell(url: webUrl)
            } else {
                if let id = cell.newsHeadline?.newsId {
                    webUrl = newsShareURL + String(id)
                    didTapCell(url: webUrl)
                }
            }
        }
        
    }
}

extension TopNewsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: topNewsCollectionView.frame.width, height: topNewsCollectionView.frame.height)
    }
    
}

extension TopNewsVC: TopNewsCellDelegate {
    
    func didTapPlayVideo(sender: TopNewsCollectionCell) {
    
        if var videoUrlString = sender.newsHeadline?.customImageOrVideo  {
            
            parentNewsVC?.reloadView = true
            parentLibraryVC?.reloadView = true
            
            videoUrlString =   newsVideoUrl + videoUrlString
            videoUrlString = videoUrlString.replacingOccurrences(of: " ", with: "%20")
            
            CommonUtility().playVideoWithUrl(videoUrlString, vc: self)
        }
    }
    
    func didTapCell(url: String) {
        parentNewsVC?.reloadView = true
        parentLibraryVC?.reloadView = true
        
        CommonUtility().openWebViewWithUrl(url, vc: self)
    }
    
}

//
//  BreakingNewsVC.swift
//  GUO Media
//
//  Created by Easyway_Mac2 on 08/07/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class BreakingNewsVC: UIViewController {

    @IBOutlet var breakingNewsCollectionView: UICollectionView!
    
    var breakingNewsHeadlines: [Headline]? {
        didSet {
            breakingNewsCollectionView.backgroundView = nil
            stopTimer()
            DispatchQueue.main.async {
                self.breakingNewsCollectionView.reloadData()
                
                if let headlineCount = self.breakingNewsHeadlines?.count {
                    if headlineCount > 1 {
                        self.counter = 0
                        self.startTimer()
                    }
                }
            }
           
        }
    }
    
    var alertLabel: String = "" {
        didSet {
            stopTimer()
            breakingNewsHeadlines = nil
            breakingNewsCollectionView.setEmptyMessage(alertLabel.localized, color: .white)
        }
    }
    
    var parentNewsVC: NewsVC!
    
    private var timer:Timer?
    private var counter = 0

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

//MARK: UICollectionView Delegate and DataSource

extension BreakingNewsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = breakingNewsHeadlines?.count ?? 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = breakingNewsCollectionView.dequeueReusableCell(withReuseIdentifier: "BNCELL", for: indexPath) as! BreakingNewsCell
        cell.newsHeadline = breakingNewsHeadlines?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = breakingNewsCollectionView.cellForItem(at: indexPath) as! BreakingNewsCell
        
        if let url = cell.newsHeadline?.url {
            
            let webVC = WebViewController()
            
            if url.caseInsensitiveCompare("null") != .orderedSame {
                webVC.webUrl = url
                self.navigationController?.pushViewController(webVC, animated: true)
            } else {
                if let id = cell.newsHeadline?.newsId {
                    webVC.webUrl = newsShareURL + String(id)
                    self.navigationController?.pushViewController(webVC, animated: true)
                }
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize (width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
}

//MARK: TIMER

extension BreakingNewsVC {
  
    private func startTimer () {
        if self.timer == nil {
            if #available(iOS 10.0, *) {
                timer = Timer(timeInterval: 6.0, repeats: true) { [weak self] _ in
                    self?.scrollingTimerAction()
                }
            } else {
                self.timer =  Timer.scheduledTimer(
                    timeInterval: TimeInterval(3.0),
                    target      : self,
                    selector    : #selector(self.scrollingTimerAction),
                    userInfo    : nil,
                    repeats     : true)
            }
            RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
        }
        
    }
    
    private func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    @objc func scrollingTimerAction() {
        
        if counter < breakingNewsHeadlines?.count ?? 0
        {
            let index = IndexPath(item: counter, section: 0)
            self.breakingNewsCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        }
        else
        {
            counter = 0
            let index = IndexPath(item: counter, section: 0)
            self.breakingNewsCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
        }
        counter += 1
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x/self.breakingNewsCollectionView.frame.size.width)
        counter = pageNumber
    }
    
    
}

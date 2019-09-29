//
//  NewsDetailCell.swift
//  GUO Media
//
//  Created by Easyway_Mac2 on 29/07/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import SDWebImage

protocol  NewsDetailCellDelegate: class {
    func addCommentTapped(_ sender: NewsDetailCell)
    func likeButtonTapped(_ sender: NewsDetailCell)
    func newsPlayButtonAction(_ sender: NewsDetailCell, customImageVideo: String)
    func newsShareButtonAction(_ sender: NewsDetailCell)

}

class NewsDetailCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var headlinesImageView: UIImageView!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var playButton: UIButton!
    
    weak var delegate: NewsDetailCellDelegate?
    
    var headline: Headline? {
        didSet{
            guard let newsHeadline = headline else { return }
            
            if newsHeadline.isLanguageEnglish {
                setTitle(newsHeadline.engTitle)
            } else {
                setTitle(newsHeadline.chineseTitle)
            }
            
            if let isVideo = newsHeadline.isVideo {
                playButton.isHidden = isVideo != 1
            }
            
            likeButton.setTitle("\(newsHeadline.likeCount)", for: .normal)
            commentButton.setTitle("\(newsHeadline.commentCount)", for: .normal)
            
            let likeButtonImage: UIImage = (newsHeadline.likeStatus == 0) ? #imageLiteral(resourceName: "heart") : #imageLiteral(resourceName: "heart_rf")
            likeButton.setImage(likeButtonImage, for: .normal)
            
            if var customImageVideo = newsHeadline.customImageOrVideo {
                
                if customImageVideo.caseInsensitiveCompare("null") == .orderedSame {
                    
                    guard var imageUrl = newsHeadline.imageUrl else { return }
                    imageUrl = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    setImageFromUrl(imageUrl)
                } else {
                    
                    customImageVideo =   newsVideoUrl + customImageVideo
                    customImageVideo = customImageVideo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    
                    guard let isVideo = newsHeadline.isVideo else { return }
                    if isVideo == 1 {
                        self.headlinesImageView.image = createThumbnailOfVideoFromRemoteUrl(customImageVideo)
                    } else {
                        setImageFromUrl(customImageVideo)
                    }
                }
            }
        
        }
    }
    
    private func setTitle(_ title: String?) {
        if var title = title {
            title =  title.replacingOccurrences(of: "�", with: "")
            title = removeLastWordFromString(title)
            titleLabel.text = title.htmlToString
        } else {
            titleLabel.text = ""
        } 
    }
    
    private func removeLastWordFromString(_ sentence: String) -> String {
        if sentence.count > 60 {
            let sentence = sentence.prefix(60)
            var split = sentence.components(separatedBy: .whitespaces)
            split.removeLast()
            return split.joined(separator: " ")
        }
        return sentence
    }
    
    private func setImageFromUrl(_ imageUrl: String) {
        headlinesImageView?.sd_setImage(with: URL(string: imageUrl)) { (image, error, cache, urls) in
            if (error != nil) {
                self.headlinesImageView.image = UIImage(named: "everythingNoImage")
            } else {
                self.headlinesImageView.image = image
            }
        }
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        delegate?.addCommentTapped(self)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.likeButtonTapped(self)
    }
    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard var customImageVideo = headline?.customImageOrVideo else { return }
        customImageVideo =   newsVideoUrl + customImageVideo
        customImageVideo = customImageVideo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        delegate?.newsPlayButtonAction(self, customImageVideo: customImageVideo)
    }
    @IBAction func shareButtonTapped(_ sender: Any) {
        delegate?.newsShareButtonAction(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        layer.borderColor = UIColor.lightGray.cgColor
    }

}

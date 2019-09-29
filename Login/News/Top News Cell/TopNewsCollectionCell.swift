//
//  SlideCell.swift
//  GUO Media
//
//  Created by apple on 1/10/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import SDWebImage

protocol TopNewsCellDelegate: class {
    func didTapPlayVideo(sender: TopNewsCollectionCell)
}

class TopNewsCollectionCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var headlineTitleLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    
    weak var delegate: TopNewsCellDelegate?
    
    var isVideo : Int = 0
    
    var newsHeadline: Headline? {
        didSet {
            guard let newsHeadline = newsHeadline else { return }
            
            playButton.isHidden = true

            if newsHeadline.isLanguageEnglish {
                setTitle(newsHeadline.engTitle, description: newsHeadline.engDescription)
            } else {
                setTitle(newsHeadline.chineseTitle, description: newsHeadline.chineseDescription)
            }
            
            if var customImageVideo = newsHeadline.customImageOrVideo {
                
                if customImageVideo.caseInsensitiveCompare("null") == .orderedSame {
                    
                    guard var imageUrl = newsHeadline.imageUrl else { return }
                    imageUrl = imageUrl.replacingOccurrences(of: " ", with: "%20")
                    setImageFromUrl(imageUrl)
                } else {
                    
                    customImageVideo =   newsVideoUrl + customImageVideo
                    customImageVideo = customImageVideo.replacingOccurrences(of: " ", with: "%20")
                    
                    guard let isVideo = newsHeadline.isVideo else { return }
                    if isVideo == 1 {
                        thumbnailThread.async {
                            let thumbnail = createThumbnailOfVideoFromRemoteUrl(customImageVideo)
                            DispatchQueue.main.async {
                                self.imageView.image = thumbnail
                            }
                        }
                    } else {
                        setImageFromUrl(customImageVideo)
                    }
                }
                
            }
            
        }
    }
    
    private func setTitle(_ title: String?, description: String?) {
        if var title = title {
            title =  title.replacingOccurrences(of: "�", with: "")
            title = removeLastWordFromString(title)
            headlineTitleLabel.text = title.htmlToString
        } else {
            headlineTitleLabel.text = ""
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
        imageView?.sd_setImage(with: URL(string: imageUrl)) { (image, error, cache, urls) in
            if (error != nil) {
                self.imageView.image = UIImage(named: "everythingNoImage")
            } else {
                self.imageView.image = image
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView?.image = UIImage(named: "default-postImg")
    }
    
    
    override func awakeFromNib() {
        headlineTitleLabel.font =  CustomFont.slideHeadlineLabelFont
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        delegate?.didTapPlayVideo(sender: self)
    }
    
}

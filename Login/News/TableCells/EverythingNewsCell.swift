//
//  NewsTableCell.swift
//  GUO Media
//
//  Created by Easyway_Mac2 on 11/01/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import SDWebImage


protocol EverythingCellDelegate : class {
    func newsTableCellDidTapMore(_ sender: EverythingNewsCell)
    func newsShareButtonAction(_ sender: EverythingNewsCell)
    func newsPlayButtonAction(_ sender:EverythingNewsCell,isVideo:Int,customImageVideo:String)
    
}

class EverythingNewsCell: UITableViewCell {
    @IBOutlet var headlinesImageView: UIImageView!
    @IBOutlet var headlinesTitleLabel: UILabel!
    @IBOutlet var headlinesSubTitleLabel: UILabel!
    @IBOutlet var mainView: UIView!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var gtranslateButton: UIButton!
    
    @IBOutlet var playButton: UIButton!
    weak var delegate: EverythingCellDelegate?
    
    var webUrl:String?
    var customImageVideoURL : String?
    var isVideo :Int = 0
    let minHeight: CGFloat = UIScreen.main.bounds.height/7
    var newsId : Int?
    var newsHeadline:NewsFeed.Headline? {
        didSet {
            guard let newsHeadline = newsHeadline else { return }
            if let isVideo = newsHeadline.isVideo {
                self.isVideo = isVideo
            }
            
            if newsHeadline.gTranslator ==  1 {
                headlinesTitleLabel.textColor = UIColor.black
                headlinesSubTitleLabel.textColor = UIColor.black
                gtranslateButton.isHidden = false
            } else {
                gtranslateButton.isHidden = true
                headlinesTitleLabel.textColor = UIColor.gray
                headlinesSubTitleLabel.textColor = UIColor.gray
            }
            
            if var title = newsHeadline.title, var description = newsHeadline.description {
                
                if  title.count > 10 {
                    title =  title.replacingOccurrences(of: "�", with: "")
                    title = String(title.prefix(60))
                    headlinesTitleLabel.text = title.htmlToString
                } else {
                    description = String(description.prefix(50))
                    description =  description.replacingOccurrences(of: "�", with: "")
                    headlinesTitleLabel.text = description.htmlToString
                }
                
            } else {
                headlinesTitleLabel.text = ""
            }
            
            if var description = newsHeadline.description, var author = newsHeadline.author {
                description = (description == "NULL" || description == "null") ? "" : description
                description =  description.replacingOccurrences(of: "�", with: "")
                author =  author.replacingOccurrences(of: "By", with: "")
                
                if author == "" || author == "NULL"  || author == "null" || (author.trimmingCharacters(in: .whitespaces) == "") {
                    author = ""
                } else {
                    author =  ("\n" + "By".localized + " " +  author)
                }
                
                author =  author.replacingOccurrences(of: "�", with: "")
                headlinesSubTitleLabel.text = newsHeadline.isExpanded ? (description + author) : author
            } else {
                headlinesSubTitleLabel.text = ""
            }
            
            
            if let customImageVideo = newsHeadline.customImageOrVideo {
                if customImageVideo == "NULL" {
                    customImageVideoURL = nil
                    if var imageUrl = newsHeadline.imageUrl {
                        imageUrl = imageUrl.replacingOccurrences(of: " ", with: "%20")
                        
                        headlinesImageView?.sd_setImage(with: URL(string: imageUrl)) { (image, error, cache, urls) in
                            if (error != nil) {
                                self.headlinesImageView.image = UIImage(named: "everythingNoImage")
                            } else {
                                self.headlinesImageView.image = image
                            }
                        }
                    }
                } else {
                    customImageVideoURL =   newsVideoUrl + customImageVideo
                    customImageVideoURL = customImageVideoURL!.replacingOccurrences(of: " ", with: "%20")
                    
                    if let isVideo = newsHeadline.isVideo {
                        playButton.isHidden = false
                        
                        if isVideo == 1 {
                            
                            self.headlinesImageView.image = createThumbnailOfVideoFromRemoteUrl(url: customImageVideo)
                            
                            self.headlinesImageView.image = createThumbnailOfVideoFromRemoteUrl(url: customImageVideoURL!)
                            
                            playButton.setImage(UIImage(named: "ic_play_video"), for: .normal)
                            
                        } else {
                            playButton?.sd_setImage(with: URL(string: customImageVideoURL!), for: .normal) { (image, error, cache, urls) in
                                if (error != nil) {
                                    self.headlinesImageView.image = UIImage(named: "everythingNoImage")
                                } else {
                                    self.headlinesImageView.image = image
                                }
                            }
                        }
                    }
                    
                }
            }
            
            
            
            
            if let url = newsHeadline.url {
                webUrl = url
            }
            if let newsIdnum = newsHeadline.newsId {
                newsId = newsIdnum
            }
            if var author = newsHeadline.author {
                author =  author.replacingOccurrences(of: "By", with: "")
                
                if author == "" || author == "NULL" || author == "null"  || (author.trimmingCharacters(in: .whitespaces) == "") {
                    author = ""
                } else {
                    author =  ("\n" + "By".localized + " " +  author)
                }
                
                author =  author.replacingOccurrences(of: "�", with: "")
                
                if newsHeadline.isExpanded {
                    moreButton.setTitle("View More".localized, for: .normal)
                    moreButton.titleLabel?.font =  headlinesSubTitleLabelFont
                    
                } else {
                    moreButton.setTitle("", for: .normal)
                  
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.playButton.isHidden = true
        self.headlinesImageView?.image = UIImage(named: "default-postImg")
        gtranslateButton.setTitle("G-Translate".localized, for: .normal)
        gtranslateButton.setTitleColor(UIColor(red: 104/255, green: 122/255, blue: 137/255, alpha: 1.0), for: .normal)
        gtranslateButton.setImage(#imageLiteral(resourceName: "tikicon"), for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headlinesTitleLabel.font =  headlineTitlelabelFont
        headlinesSubTitleLabel.font =  headlinesSubTitleLabelFont
        let height = minHeight - 10
        headlinesImageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        gtranslateButton.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        return CGSize(width: size.width, height: max(size.height, minHeight))
    }
    
    @IBAction func moreTapped(_ sender: Any) {
        delegate?.newsTableCellDidTapMore(self)
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        delegate?.newsShareButtonAction(self)
    }
    
    @IBAction func playButtonAction(_ sender: Any) {
        guard let customImageVideoUrl = customImageVideoURL else { return }
        delegate?.newsPlayButtonAction(self, isVideo: isVideo, customImageVideo: customImageVideoUrl)
    }
}

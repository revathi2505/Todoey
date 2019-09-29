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
    func newsTableCellDidTapViewComments(_ sender: EverythingNewsCell)
    
    func newsShareButtonAction(_ sender: EverythingNewsCell)
    func newsPlayButtonAction(_ sender: EverythingNewsCell, customImageVideo: String)
    
    func addCommentTapped(_ sender: EverythingNewsCell)
    func addLikeDisLikeTapped(_ sender: EverythingNewsCell)
    
    func translateButtonTapped(_ sender: EverythingNewsCell)
}

class EverythingNewsCell: UITableViewCell {
    @IBOutlet var headlineImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet var commentsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var commentsView: UIView!
    @IBOutlet var moreButton: UIButton!
    
    @IBOutlet var viewCommentsButton: UIButton!
    
    @IBOutlet var translateButton: UIButton!
    @IBOutlet var translateButtonHeight: NSLayoutConstraint!
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    
    weak var delegate: EverythingCellDelegate?
    
    var searchKeyword: String?
    
    private let minHeight: CGFloat = UIScreen.main.bounds.height/7
    private var byString: String = "By"
    
    var newsHeadline: Headline? {
        didSet {
            guard let newsHeadline = newsHeadline else { return }
            
            //translateButton.setTitle("Translate".localized, for: .normal)
            
            if let hotNews = newsHeadline.isHotNews {
                if hotNews == 1 {
                    let customRed = UIColor(red: 62/255, green: 13/255, blue: 17/255, alpha: 0.85)
                    titleLabel.textColor =  customRed
                    descriptionLabel.textColor = customRed
                    authorLabel.textColor = customRed
                } else {
                    titleLabel.textColor = .black
                    descriptionLabel.textColor = .black
                    authorLabel.textColor = .black
                }
            }
            
            if newsHeadline.isLanguageEnglish {
                byString = "By"
                //translateButton.setTitle("中文版", for: .normal)
                setTitle(newsHeadline.engTitle)
                setAuthor(newsHeadline.engAuthor)
                setDescription(newsHeadline.engDescription, andIsExpanded: newsHeadline.isExpanded)
            } else {
                byString = "通过"
                //translateButton.setTitle("Translate", for: .normal)
                //translateButton.setTitle("English", for: .normal)
                
                setTitle(newsHeadline.chineseTitle)
                setAuthor(newsHeadline.chineseAuthor)
                setDescription(newsHeadline.chineseDescription, andIsExpanded: newsHeadline.isExpanded)
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
                        
                        guard let assetUrl = URL(string: customImageVideo) else { return }
                        AVAsset(url: assetUrl).generateThumbnailFromUrl(customImageVideo) { [weak self] (image) in
                            DispatchQueue.main.async {
                                guard let image = image else { return }
                                self?.headlineImageView.image = image
                            }
                        }
                        
                    } else {
                        setImageFromUrl(customImageVideo)
                    }
                    
                }
            }
            
            if newsHeadline.isExpanded {
                showCommentView()
            } else {
                hideCommentView()
            }
            
        }
    }
    
     private func setTitle(_ title: String?) {
          if var title = title {
              title =  title.replacingOccurrences(of: "�", with: "")
              title = removeLastWordFromString(title)
              
              if let keyword = searchKeyword {
                  titleLabel.attributedText = setText(targetString: title, searchTerm: keyword)
              } else {
                  titleLabel.text = title.htmlToString
              }
              
          } else {
              titleLabel.text = ""
          }
      }
      
      private func setText(targetString: String, searchTerm: String) -> NSMutableAttributedString? {
      let attributedString = NSMutableAttributedString(string: targetString)
          do {
              let regex = try NSRegularExpression(pattern: searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).folding(options: .diacriticInsensitive, locale: .current), options: .caseInsensitive)
              let range = NSRange(location: 0, length: targetString.utf16.count)
              for match in regex.matches(in: targetString.folding(options: .diacriticInsensitive, locale: .current), options: .withTransparentBounds, range: range) {
                  attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold), range: match.range)
                  attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: match.range)
              }
             return attributedString
          } catch {
              print("Error creating regular expresion: \(error)")
              return nil
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
    
    private func setDescription(_ description: String?, andIsExpanded isExpanded: Bool) {
        if var description = description {
            description = (description.caseInsensitiveCompare("null") == .orderedSame) ? "" : description
            descriptionLabel.text = isExpanded ? description : ""
        } else {
            descriptionLabel.text = ""
        }
    }
    
    private  func setAuthor(_ author: String?) {
        
        if var author = author {
            author =  author.replacingOccurrences(of: "By".localized, with: "")
            if (author.caseInsensitiveCompare("null") == .orderedSame)  || (author.trimmingCharacters(in: .whitespaces) == "") {
                author = ""
            } else {
                author =  (byString + " " +  author)
            }
            author =  author.replacingOccurrences(of: "�", with: "")
            
            authorLabel.text = author
        } else {
            authorLabel.text = ""
        }
    }
    
    
    private func showCommentView() {
        commentsView.isHidden = false
        commentsViewHeightConstraint.constant =  30
        commentsView.layoutIfNeeded()
        
        moreButton.setTitle("View More".localized, for: .normal)
        viewCommentsButton.setTitle("View Comments".localized, for: .normal)
    }
    
    private func hideCommentView() {
        commentsView.isHidden = true
        commentsViewHeightConstraint.constant =  0
        commentsView.layoutIfNeeded()
    }
    
    private func setImageFromUrl(_ imageUrl: String) {
        self.headlineImageView?.sd_setImage(with: URL(string: imageUrl)) { (image, error, cache, urls) in
            if (error != nil) {
                print("SDerror", error)
                self.headlineImageView.image = UIImage(named: "everythingNoImage")
            } else {
                self.headlineImageView.image = image
            }
        }
    }
    
    private func showTranslateView() {
        // translateButton.setTitle("Translate".localized, for: .normal)
        translateButton.setTitleColor(CustomColor.categoryCustomColor_gray, for: .normal)
        titleLabel.textColor = .black
        descriptionLabel.textColor = .black
    }
    
    private func hideTranslateView() {
        titleLabel.textColor = .gray
        descriptionLabel.textColor = .gray
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.playButton.isHidden = true
        self.headlineImageView.image = UIImage(named: "default-postImg")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //titleLabel.font =  CustomFont.headlineTitleFont
        titleLabel.font =  CustomFont.slideHeadlineLabelFont
        descriptionLabel.font =  CustomFont.headlinesSubTitleFont
        authorLabel.font = CustomFont.headlinesSubTitleFont
        let height = minHeight - 20
        headlineImageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        headlineImageView.widthAnchor.constraint(equalToConstant: 250).isActive = true;
        
        
        /*translateButton.layer.masksToBounds = true
        translateButton.layer.borderColor = CustomColor.categoryCustomColor_gray.cgColor
        translateButton.layer.borderWidth = 1.0
        translateButton.layer.cornerRadius = translateButton.frame.height/2*/
        
        headlineImageView.layer.masksToBounds = true;
        headlineImageView.layer.cornerRadius = 15.0;
        
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
        guard var customImageVideo = newsHeadline?.customImageOrVideo else { return }
        customImageVideo =   newsVideoUrl + customImageVideo
        customImageVideo = customImageVideo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        delegate?.newsPlayButtonAction(self, customImageVideo: customImageVideo)
    }
    @IBAction func viewCommentsAction(_ sender: Any) {
        delegate?.newsTableCellDidTapViewComments(self)
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        delegate?.addCommentTapped(self)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.addLikeDisLikeTapped(self)
    }
    
    @IBAction func translateButtonTapped(_ sender: UIButton) {
        delegate?.translateButtonTapped(self)
    }
    
    
}

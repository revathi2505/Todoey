

import UIKit

class BreakingNewsCell: UICollectionViewCell {

    @IBOutlet var headlineLabel: UILabel!
    
    var webUrl: String?
    
    var newsHeadline: Headline? {
        didSet {

            guard let newsHeadline = newsHeadline else { return }
            
            if newsHeadline.isLanguageEnglish {
                setTitle(newsHeadline.engTitle, description: newsHeadline.engDescription)
            } else {
                setTitle(newsHeadline.chineseTitle, description: newsHeadline.chineseDescription)
            }
            
            if let url = newsHeadline.url {
                webUrl = url
            }
            
        }
    }
    
    private func setTitle(_ title: String?, description: String?) {
        if var title = title {
            title =  title.replacingOccurrences(of: "�", with: "")
            title = String(title.prefix(60))
            headlineLabel.text = title.htmlToString
        } else {
            headlineLabel.text = ""
        }
    }

    override func awakeFromNib() {
        headlineLabel.font =  CustomFont.headlinesSubTitleFont
        headlineLabel.textAlignment = .left
    }
    
  
    
}

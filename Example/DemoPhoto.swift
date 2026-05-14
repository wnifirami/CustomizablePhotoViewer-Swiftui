import UIKit

final class DemoPhoto: PhotoViewerPhoto {
    let image:                    UIImage?
    let attributedCaptionTitle:   NSAttributedString?
    let attributedCaptionSummary: NSAttributedString?
    let attributedCaptionCredit:  NSAttributedString?

    init(_ assetName: String,
         title:   String? = nil,
         summary: String? = nil,
         credit:  String? = nil) {
        self.image = UIImage(named: assetName)
        self.attributedCaptionTitle   = title.map   { Self.attributed($0, size: 15, weight: .bold)    }
        self.attributedCaptionSummary = summary.map { Self.attributed($0, size: 13, weight: .regular) }
        self.attributedCaptionCredit  = credit.map  { Self.attributed($0, size: 11, weight: .light, color: .lightGray) }
    }

    private static func attributed(_ text: String,
                                    size: CGFloat,
                                    weight: UIFont.Weight,
                                    color: UIColor = .white) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .foregroundColor: color,
            .font: UIFont.systemFont(ofSize: size, weight: weight)
        ])
    }
}

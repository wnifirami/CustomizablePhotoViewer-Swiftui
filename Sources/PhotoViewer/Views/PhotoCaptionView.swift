import SwiftUI

/// Gradient caption bar — clear → 85 % black, max 30 % of screen height.
struct PhotoCaptionView: View {
    let photo: any PhotoViewerPhoto

    var body: some View {
        if hasContent {
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom)
                VStack(alignment: .leading, spacing: 2) {
                    if let title   = photo.attributedCaptionTitle   { AttributedLabel(title)   }
                    if let summary = photo.attributedCaptionSummary { AttributedLabel(summary) }
                    if let credit  = photo.attributedCaptionCredit  { AttributedLabel(credit)  }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.vertical, 7)
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.30)
        }
    }

    private var hasContent: Bool {
        photo.attributedCaptionTitle   != nil ||
        photo.attributedCaptionSummary != nil ||
        photo.attributedCaptionCredit  != nil
    }
}

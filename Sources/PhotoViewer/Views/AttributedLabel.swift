import SwiftUI

/// Renders an NSAttributedString inside SwiftUI via a non-editable UITextView.
struct AttributedLabel: UIViewRepresentable {
    let string: NSAttributedString
    init(_ string: NSAttributedString) { self.string = string }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor   = .clear
        textView.isEditable        = false
        textView.isSelectable      = false
        textView.isScrollEnabled   = false
        textView.dataDetectorTypes = []
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow,  for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        textView.attributedText = string
    }
}

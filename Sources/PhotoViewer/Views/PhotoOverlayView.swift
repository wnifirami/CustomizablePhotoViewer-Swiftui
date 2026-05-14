import SwiftUI

struct PhotoOverlayView: View {
    var model: PhotoViewerModel
    @Binding var isPresented: Bool

    var body: some View {
        HeroOverlayView(
            photos: (0..<model.dataSource.numberOfPhotos)
                .compactMap { model.dataSource.photo(at: $0) },
            currentIndex:  model.currentIndex,
            configuration: model.configuration,
            onClose: { isPresented = false }
        )
    }
}

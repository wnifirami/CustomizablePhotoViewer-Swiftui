import SwiftUI

private struct PhotoViewerModifier: ViewModifier {
    @Binding var isPresented: Bool
    let photos:        [any PhotoViewerPhoto]
    let initialIndex:  Int
    let configuration: PhotoViewerConfiguration

    @State private var openIndex:          Int? = nil
    @State private var currentViewerIndex: Int  = 0

    func body(content: Content) -> some View {
        ZStack {
            content
            if openIndex != nil {
                PhotoViewerView(
                    photos:              photos,
                    openIndex:           $openIndex,
                    sourceFrameProvider: { _ in .zero },
                    configuration:       configuration,
                    currentVisibleIndex: $currentViewerIndex
                )
                .zIndex(1000)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: openIndex)
        .onChange(of: isPresented) { _, presented in
            if presented {
                currentViewerIndex = initialIndex
                openIndex          = initialIndex
            }
        }
        .onChange(of: openIndex) { _, index in
            if index == nil { isPresented = false }
        }
    }
}

public extension View {
    func photoViewer(
        isPresented:   Binding<Bool>,
        photos:        [any PhotoViewerPhoto],
        initialIndex:  Int = 0,
        configuration: PhotoViewerConfiguration = PhotoViewerConfiguration()
    ) -> some View {
        modifier(PhotoViewerModifier(
            isPresented:   isPresented,
            photos:        photos,
            initialIndex:  initialIndex,
            configuration: configuration))
    }
}

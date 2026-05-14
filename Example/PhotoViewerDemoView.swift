import SwiftUI

struct PhotoViewerDemoView: View {

    @State private var openIndex:          Int?   = nil
    @State private var currentViewerIndex: Int    = 0
    /// Keeps the gallery in sync with the viewer so the carousel is already
    /// scrolled to the right photo when the viewer closes.
    @State private var galleryIndex:       Int    = 0
    /// Frame of the carousel strip in global coordinates.
    @State private var carouselFrame:      CGRect = .zero

    private let photos: [DemoPhoto] = [
        DemoPhoto("kitchen_modern",
                  title:   "Modern Kitchen",
                  summary: "Clean lines and minimalist design.",
                  credit:  "© Studio Interiors"),
        DemoPhoto("kitchen_classic",
                  title:   "Classic Kitchen",
                  summary: "Timeless cabinetry and warm tones.",
                  credit:  "© Heritage Design Co."),
        DemoPhoto("kitchen_scandi",
                  title:   "Scandinavian Kitchen",
                  summary: "Light wood and functional simplicity.",
                  credit:  "© Nordic Living"),
        DemoPhoto("kitchen_industrial",
                  title:   "Industrial Kitchen",
                  summary: "Exposed steel and raw finishes.",
                  credit:  "© Urban Loft Studio"),
        DemoPhoto("kitchen_empty",
                  title:   "Empty Canvas",
                  summary: "Ready for your vision."),
    ]

    var body: some View {
        ZStack {
            gallery
            if openIndex != nil {
                PhotoViewerView(
                    photos:              photos,
                    openIndex:           $openIndex,
                    sourceFrameProvider: { _ in carouselFrame },
                    configuration:       viewerConfiguration,
                    currentVisibleIndex: $currentViewerIndex
                )
                .transition(.identity)
            }
        }
        .onChange(of: currentViewerIndex) { _, newIndex in
            galleryIndex = newIndex
        }
    }

    // MARK: - Gallery

    private var gallery: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tap a photo to open the viewer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)

                    TabView(selection: $galleryIndex) {
                        ForEach(photos.indices, id: \.self) { index in
                            thumbnailCell(index)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 250)
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: .global)
                    } action: { frame in
                        carouselFrame = frame
                    }
                }
                .padding(.top, 12)
            }
            .scrollDisabled(true)
            .navigationTitle("Photo Viewer")
        }
    }

    // MARK: - Thumbnail cell

    private func thumbnailCell(_ index: Int) -> some View {
        Button {
            currentViewerIndex = index
            galleryIndex       = index
            openIndex          = index
        } label: {
            Group {
                if let image = photos[index].image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(.systemGray5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .opacity((openIndex != nil && currentViewerIndex == index) ? 0 : 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Configuration

    private var viewerConfiguration: PhotoViewerConfiguration {
        var configuration = PhotoViewerConfiguration()
        configuration.titleProvider  = { _, index, total in "\(index + 1) / \(total)" }
        configuration.onNavigate     = { _, index in print("→ photo \(index)") }
        configuration.onWillDismiss  = { print("will dismiss") }
        configuration.onDidDismiss   = { print("did dismiss")  }
        return configuration
    }
}

#Preview {
    PhotoViewerDemoView()
}

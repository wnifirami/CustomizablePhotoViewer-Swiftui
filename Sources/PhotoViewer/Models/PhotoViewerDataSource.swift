import Foundation

public protocol PhotoViewerDataSource: AnyObject {
    var numberOfPhotos: Int { get }
    func photo(at index: Int) -> (any PhotoViewerPhoto)?
    func index(of photo: any PhotoViewerPhoto) -> Int?
}

public final class PhotoViewerArrayDataSource: PhotoViewerDataSource {
    private let photos: [any PhotoViewerPhoto]

    public init(photos: [any PhotoViewerPhoto]) {
        self.photos = photos
    }

    public var numberOfPhotos: Int { photos.count }

    public func photo(at index: Int) -> (any PhotoViewerPhoto)? {
        guard index >= 0, index < photos.count else { return nil }
        return photos[index]
    }

    public func index(of photo: any PhotoViewerPhoto) -> Int? {
        photos.firstIndex(where: { $0 === photo })
    }
}

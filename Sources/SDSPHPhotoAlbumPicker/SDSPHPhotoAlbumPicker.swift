//
//  SDSPHPhotoAlbumPicker.swift
//
//  Created by : Tomoaki Yagishita on 2021/04/14
//  © 2021  SmallDeskSoftware
//

import SwiftUI
import Photos

public struct SDSPHPhotoAlbumPicker: View {
    @Binding var isPresented: Bool
    @Binding var selectedAlbums:[PHAssetCollection]

    @State var albums:[PHAssetCollection] = []
    @State var albumThumbs:[[UIImage]] = []
    @State var gridWidth: CGFloat = 200

    let selectionLimit:Int // 0 means infinite, 0< means maximum num of albums
    var columns: [GridItem] = []
    
    public init(isPresented: Binding<Bool>, selection: Binding<[PHAssetCollection]>, limit: Int = 0) {
        self._isPresented = isPresented
        self._selectedAlbums = selection
        self.selectionLimit = limit
        self.columns = [GridItem(.fixed(gridWidth)), GridItem(.fixed(gridWidth)), GridItem(.fixed(gridWidth))]
        if limit > 0 {
            if selectedAlbums.count >= limit {
                adjustSelection()
            }
        }
        
    }

    public var body: some View {
        VStack {
            HStack {
                Text("All Photo Albums").bold()
            }
            .frame(maxWidth: .infinity)
            .overlay(Button(action: { isPresented.toggle() }, label: { Text("Done") }), alignment: .trailing)
            .padding()
            .background(Color.gray.opacity(0.5))
            LazyVGrid(columns: columns) {
                ForEach( Array(zip(albums, albumThumbs)), id: \.0 ) { item in
                    VStack {
                        StackedImageView(elementID: item.0, images: item.1, selectedElementsIDs: selectedAlbums)
                            .frame(minHeight: 100)
                        Text(item.0.localizedTitle ?? "no title")
                            .frame(alignment: .bottom)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let index = selectedAlbums.firstIndex(of: item.0) {
                            selectedAlbums.remove(at: index)
                        } else {
                            selectedAlbums.append(item.0)
                            adjustSelection()
                        }
                    }
                }
                .padding()
            }
            Spacer()
        }
        .onAppear {
            self.retrieveAlbums()
        }
    }
    
    func adjustSelection() {
        guard selectionLimit != 0 else { return }
        DispatchQueue.main.async {
            selectedAlbums = Array(selectedAlbums[(selectedAlbums.count - selectionLimit)..<(selectedAlbums.count)])
        }
    }
    
    func retrieveAlbums() {
        // if already have access right, update albums
        let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        result.enumerateObjects { (album, index, _) in
            DispatchQueue.main.async {
                self.albums.append(album)
                self.retrieveThumbnailsFromAlbum(album) { (images) in
                    self.albumThumbs.append(images)
                }
            }
        }
    }
    
    func retrieveThumbnailsFromAlbum(_ album: PHAssetCollection, completion: (([UIImage]) -> Void)? = nil) {
        let fetchOption = PHFetchOptions()
        fetchOption.fetchLimit = 3
        let fetchResult = PHAsset.fetchAssets(in: album, options: fetchOption)
        var resultImage: [UIImage] = []
        fetchResult.enumerateObjects { (asset, index, _) in
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 500, height: 500),
                                                  contentMode: .aspectFit, options: nil) { (image, info) in
                guard let image = image else { return }
                resultImage.append(image)
            }
        }
        completion?(resultImage)
        
        return
    }
}

struct SDSPHPhotoAlbumPicker_Previews: PreviewProvider {
    static var previews: some View {
        SDSPHPhotoAlbumPicker(isPresented: .constant(true), selection: .constant([]))
    }
}

struct StackedImageView: View {
    let elementID: PHAssetCollection
    let selectedElements: [PHAssetCollection]
    let thumbs: [UIImage]
    
    let offsetRatio: CGFloat = 0.2
    
    init(elementID: PHAssetCollection, images: [UIImage], selectedElementsIDs: [PHAssetCollection]) {
        self.elementID = elementID
        self.selectedElements = selectedElementsIDs
        self.thumbs = images
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geom in
                if thumbs.count > 0 {
                    let offset = min(geom.size.width, geom.size.height) * offsetRatio
                    ForEach( thumbs.indices, id: \.self) { index in
                        Image(uiImage: thumbs[index]).resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(width: CGFloat(geom.size.width - offset * CGFloat(thumbs.count - 1)),
                                   height: CGFloat(geom.size.height - offset * CGFloat(thumbs.count - 1)))
                            .offset(x: CGFloat(index) * offset, y: CGFloat(index) * offset)
                    }
                } else { // empty album image
                    Image("EmptyAlbum", bundle: Bundle.module)
                        .resizable().scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            ZStack(alignment: .bottomTrailing ) {
                Rectangle().fill(Color.gray.opacity(selectedElements.contains(elementID) == true ? 0.4 : 0.0))
                Image(systemName: "checkmark.circle.fill")
                    .renderingMode(.original).font(.body)
                    .opacity(selectedElements.contains(elementID) == true ? 1.0 : 0.0)
            }
        }
    }
}

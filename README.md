# SDSPHPhotoAlbumPicker

![platform](https://img.shields.io/badge/Platform-macOS/platform-iOS-lightgrey)
![iOS](https://img.shields.io/badge/iOS-v14_orLater-blue)
![package manager](https://img.shields.io/badge/SPM-Supported-orange)
![license](https://img.shields.io/badge/license-MIT-lightgrey)

PhotoAlbumPicker for SwiftUI

You can select PhotoAlbums then retrieve selected albums via binding.

This Picker will provide PhotoAlbum(PHAssetCollection)s only. If you want to get photo data, you need to retrieve those additionally.

## At a glance

video will come 

## Code Example
```
struct SDSPHPhotoAlbumPickerExample: View {
    @State private var showPicker:Bool = false
    @State var selectedAlbums:[PHAssetCollection] = []
    
    let logger = Logger(subsystem: "com.smalldesksoftware.SDSPHPhotoAlbumPickerExample", category: "SDSPHPhotoAlbumPickerExample")
    
    var columns: [GridItem] = Array(repeating: .init(.fixed(100)), count: 3)
    @State private var limit = 0
    var body: some View {
        VStack {
            HStack {
                Button(action: { limit = 0 }, label: {
                    Text("max infinity")
                })
                Button(action: { limit = 2 }, label: {
                    Text("max 2")
                })
                Button(action: { limit = 1 }, label: {
                    Text("max 1")
                })

                Spacer()
                Button(action: {
                    showPicker.toggle()
                }, label: {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                })
                Text("limit: \(limit)")
            }
            .padding()
            Spacer()
            Text("Selected Photo album")
                .font(.title)
            List {
                ForEach(Array(selectedAlbums), id: \.self) { album in
                    Text((album as PHAssetCollection).localizedTitle!)
                }
            }
            .padding()
            Spacer()
        }
        .sheet(isPresented: $showPicker) {
            SDSPHPhotoAlbumPicker(isPresented: $showPicker, selection: $selectedAlbums, limit: limit)
        }
    }
}
```

## API
Only one initializer.
```
/// SDSPHPhotoAlbumPicker initializer
/// - Parameters:
///   - isPresented: binding presented flag (change false to close)
///   - selection: binding to PHAssetCollection Array (note: PHAssetCollection is Photo Album)
///   - limit: specify how many albums can be selected (0 means infinity)
public init(isPresented: Binding<Bool>, selection: Binding<[PHAssetCollection]>, limit: Int = 0) {
```


## Installation
Swift Package Manager: URL:https://github.com/tyagishi/SDSPHPhotoAlbumPicker

## Requirements
iOS14

## Note
As this picker is build on top of Photos SDK APIs, you need to add "Privacy - Photo Library Usage Description" in your app's Info.plist

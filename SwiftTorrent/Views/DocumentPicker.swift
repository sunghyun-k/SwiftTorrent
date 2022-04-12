//
//  DocumentPicker.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/12.
//

import SwiftUI
import UniformTypeIdentifiers.UTType

struct DocumentPicker: UIViewControllerRepresentable {
    
    var onDocumentsPicked: ([File]) -> ()
    
    init(onDocumentsPicked: @escaping (_: [File]) -> ()) {
        self.onDocumentsPicked = onDocumentsPicked
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onDocumentsPicked: onDocumentsPicked)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "torrent")!], asCopy: true)
        controller.delegate = context.coordinator
        controller.allowsMultipleSelection = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        
        var onDocumentsPicked: ([File]) -> ()
        
        init(onDocumentsPicked: @escaping ([File]) -> ()) {
            self.onDocumentsPicked = onDocumentsPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let files: [File] = urls.compactMap { url in
                guard let data = try? Data(contentsOf: url) else {
                    return nil
                }
                return File(name: url.lastPathComponent, data: data)
            }
            onDocumentsPicked(files)
        }
        
    }
}

//
//  DocumentPicker.swift
//  SwiftTorrent
//
//  Created by Sunghyun Kim on 2022/04/12.
//

import SwiftUI
import UniformTypeIdentifiers.UTType

struct DocumentPicker: UIViewControllerRepresentable {
    
    var onDocumentsPicked: ([URL]) -> ()
    
    init(onDocumentsPicked: @escaping (_: [URL]) -> ()) {
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
        
        var onDocumentsPicked: ([URL]) -> ()
        
        init(onDocumentsPicked: @escaping ([URL]) -> ()) {
            self.onDocumentsPicked = onDocumentsPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onDocumentsPicked(urls)
        }
        
    }
    
}

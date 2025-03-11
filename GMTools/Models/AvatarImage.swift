//
//  AvatarImage.swift
//  GMTools
//
//  Created by Bobby Walker on 3/9/25.
//

import SwiftUI

struct AvatarImage: Transferable, Equatable {
    let image: Image
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = AvatarImage(data: data) else {
                throw TranferError.importFailed
            }
            
            return image
        }
    }
}

extension AvatarImage {
    init?(data: Data) {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        
        let image = Image(uiImage: uiImage)
        self.init(image: image, data: data)
    }
}

enum TranferError: Error {
    case importFailed
}

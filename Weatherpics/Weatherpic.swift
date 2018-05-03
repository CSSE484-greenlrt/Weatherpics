//
//  Weatherpic.swift
//  Weatherpics
//
//  Created by Ryan Greenlee on 4/20/18.
//  Copyright © 2018 Ryan Greenlee. All rights reserved.
//

import UIKit
import Firebase

class Weatherpic: NSObject {
    var id: String?
    var caption: String
    var imageUrl: String
    var created: Date!
    var uid: String!
    
    let captionKey = "caption"
    let imageUrlKey = "imageUrl"
    let createdKey = "created"
    let uidKey = "uid"
    
    init(caption: String, imageUrl: String) {
        self.caption = caption
        self.imageUrl = imageUrl
        self.created = Date()
        self.uid = (Auth.auth().currentUser?.uid)!
    }
    
    init(documentSnapshot: DocumentSnapshot) {
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        self.caption = data[captionKey] as! String
        self.imageUrl = data[imageUrlKey] as! String
        if (data[createdKey] != nil) {
            self.created = data[createdKey] as! Date
        }
        if (data[uidKey] != nil) {
            self.uid = data[uidKey] as! String
        }
    }
    
    var data: [String: Any] {
        return [captionKey: self.caption,
                imageUrlKey: self.imageUrl,
                createdKey: self.created,
                uidKey: self.uid]
    }
}

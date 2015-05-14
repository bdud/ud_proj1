//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Bill Dawson on 5/14/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit

class RecordedAudio: NSObject {

    var filePathUrl : NSURL!
    var title : String!

    init(filePathUrl : NSURL, title : String) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
   
}

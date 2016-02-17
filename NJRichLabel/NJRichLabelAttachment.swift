//
//  NJRichLabelAttachment.swift
//  NJRichLabel
//
//  Created by 陈剑南 on 16/2/16.
//  Copyright © 2016年 Jimmy Chen. All rights reserved.
//

import Foundation
import UIKit

enum ImageAlignment {
    case Top
    case Center
    case Bottom
}

class NJRichLabelAttachment: NSObject {
   
    
    var content:AnyObject?
    var margin:UIEdgeInsets?
    var fontAscent:CGFloat?
    var fontDescent:CGFloat?
    var maxSize:CGSize?
    var alignment:ImageAlignment?
    
    
    init( content:AnyObject,margin:UIEdgeInsets,alignment:ImageAlignment,maxSize:CGSize) {
        super.init()
        
        self.content = content
        self.margin = margin
        self.alignment = alignment
        self.maxSize = maxSize
    }
    
    func boxSize()->CGSize {
        var contentSize = attachmentSize()
        
        if maxSize?.width>0 && maxSize?.height>0 && contentSize.width>0 && contentSize.height>0 {
            contentSize = calculateContentSize()
        }
        
        return CGSizeMake(contentSize.width + margin!.left + margin!.right,
            contentSize.height + margin!.top  + margin!.bottom)
    
    }
    
    func calculateContentSize()->CGSize{
        let attachmentSize = self.attachmentSize()
        let width           = attachmentSize.width;
        let height          = attachmentSize.height;
        let newWidth        = maxSize!.width;
        let newHeight       = maxSize!.height;
        if width <= newWidth && height <= newHeight{
            return attachmentSize;
        }
        var size:CGSize
        if width / height > newWidth / newHeight {
            size = CGSizeMake(newWidth, newWidth * height / width)
        }else{
            size = CGSizeMake(newHeight * width / height, newHeight);
        }
        return size
 
    }
    
    func attachmentSize() ->CGSize {
        var size = CGSizeZero
        if content!.isKindOfClass(UIImage.self) {
            size = (content as! UIImage).size
        }else if content!.isKindOfClass(UIView.self) {
            size = (content as! UIView).bounds.size
        }
        return size
    }
    
    
}

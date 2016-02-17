//
//  NjRichLabel.swift
//  NJRichLabel
//
//  Created by 陈剑南 on 16/2/16.
//  Copyright © 2016年 Jimmy Chen. All rights reserved.
//

import UIKit
import CoreFoundation



class NJRichLabel: UIView {
    
    let kEllipsesCharacter = "\u{2026}";
    
    var attributeString:NSMutableAttributedString!
    var txtFrame:CTFrameRef!
    
    var font:UIFont?
    var textColor:UIColor?
    var numberOflines:Int?
    var lineBreakMode:CTLineBreakMode?
    var textAligment:CTTextAlignment?
    var lineSpace:CGFloat?
    var paragraphSpacing:CGFloat?
    
    var fontAscent:CGFloat?
    var fontDescent:CGFloat?
    var fontHeight:CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommons()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCommons(){
        attributeString = NSMutableAttributedString()
        
        font = UIFont.systemFontOfSize(16)
        textColor = UIColor.blackColor()
        lineBreakMode = .ByWordWrapping
        lineSpace = 0.0
        paragraphSpacing = 0.0
        textAligment = CTTextAlignment.Center
        
        backgroundColor = UIColor.whiteColor()
        
        resetFont()
    }
    
    
    // MARK:DRAW
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
    
        // Initialize graphics context
        let context = UIGraphicsGetCurrentContext()
        
        // Flip context coordinate
        CGContextSetTextMatrix(context, CGAffineTransformIdentity)
        CGContextTranslateCTM(context, 0, self.bounds.size.height)
        CGContextScaleCTM(context, 1, -1.0)
        
        // Initialize attribute string
         let drawString = setupAttributeString()
        
        // Create the framesetter with the attributed string
        setupTextFrame(drawString, rect: rect)
        
        drawAttachments()
        drawText(drawString, rect: rect, context: context!)
        
        
    }
    
    func setupAttributeString()->NSAttributedString {
        
        if attributeString != nil {
            let drawstring = attributeString.mutableCopy()
            
//            let linebreakMode = lineBreakMode
            if self.lineBreakMode == CTLineBreakMode.ByTruncatingTail {
                lineBreakMode = numberOflines == 1 ? CTLineBreakMode.ByCharWrapping:CTLineBreakMode.ByWordWrapping
            }
            
            var fontLineHeight:CGFloat = (font?.lineHeight)!
            let setting = [
                CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.Alignment, valueSize: sizeof(CTTextAlignment), value: &textAligment),
                CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.LineBreakMode, valueSize: sizeof(CTLineBreakMode), value: &lineBreakMode),
                CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.LineSpacing, valueSize: sizeof(CGFloat), value: &lineSpace),
                CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.ParagraphSpacing, valueSize: sizeof(CGFloat), value: &paragraphSpacing),
                CTParagraphStyleSetting(spec: CTParagraphStyleSpecifier.MinimumLineHeight, valueSize: sizeof(CGFloat), value: &fontLineHeight)]
            
            let paragraphStyle = CTParagraphStyleCreate(setting,sizeof(CTParagraphStyleSetting))
            
//            let style = NSMutableParagraphStyle()
//            
//            style.lineSpacing = lineSpace!
//            style.lineBreakMode = lineBreakMode!
//            style.paragraphSpacing = paragraphSpacing!
//            style.alignment = textAligment!
//            style.minimumLineHeight = fontLineHeight
//                        drawstring.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, drawstring.length))
            drawstring.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, drawstring.length))

            return drawstring as! NSAttributedString
            
        }else {
            return NSAttributedString()
        }
    }
    
    func setupTextFrame(attString:NSAttributedString,rect:CGRect){
        if txtFrame == nil {
            // Create the framesetter with the attributed string.
            let frameSetter = CTFramesetterCreateWithAttributedString(attString)
            let path = CGPathCreateMutable()
            CGPathAddRect(path, nil, rect)
            // Create a frame.
            txtFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        }
    }
    
    func drawText(attString:NSAttributedString,rect:CGRect,context:CGContextRef) {
        if txtFrame != nil {
            
            if numberOflines > 0 {
                
                let ctlines = CTFrameGetLines(txtFrame) as NSArray
                let lines = ctlines as Array
                let numberOfLines = getNumberOfLines()
                
                var lineOrigins = [CGPoint](count: numberOflines!, repeatedValue: CGPointZero)
                let range:CFRange = CFRangeMake(0, 0)
                CTFrameGetLineOrigins(txtFrame, range, &lineOrigins)
                
                for var i = 0; i < numberOfLines; i++ {
                    
                    let lineOrigin = lineOrigins[i]
                    CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y)
                    let line = lines[i] as! CTLineRef
                    
                    var showDrawLine = true
                    
                    if i == numberOflines!-1 && lineBreakMode == .ByTruncatingTail {
                        
                        let lastLineRange =  CTLineGetStringRange(line)
                        
                        if lastLineRange.location + lastLineRange.length < attributeString.length {
                            let truncationType = CTLineTruncationType.End
                            let truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1
                            let tokenAttributes = attributeString.attributesAtIndex(truncationAttributePosition, effectiveRange: nil)
                            let tokenString = NSAttributedString(string: kEllipsesCharacter,attributes: tokenAttributes)
                            
                            let truncationToken = CTLineCreateWithAttributedString(tokenString as CFAttributedStringRef)
                            let truncationString = attributeString.attributedSubstringFromRange(NSMakeRange(lastLineRange.location, lastLineRange.length)).mutableCopy()
                            
                            if lastLineRange.length > 0 {
                                truncationString.deleteCharactersInRange(NSMakeRange(lastLineRange.length-1, 1))
                            }
                            truncationString.appendAttributedString(tokenString)
                            let truncationLine = CTLineCreateWithAttributedString(truncationString as! CFAttributedStringRef)
                            let truncatedLine = CTLineCreateTruncatedLine(truncationLine, Double(rect.size.width), truncationType, truncationToken)
                            
                            CTLineDraw(truncatedLine!, context)
                        }
                        
                        showDrawLine = false
                        
                    }
                    
                    if showDrawLine {
                        CTLineDraw(line, context)
                    }
                }
            }
            else {
                CTFrameDraw(txtFrame, context)
            }
            
        }
    }
    
    func drawAttachments(){
        let context = UIGraphicsGetCurrentContext()
        
        let ctlines = CTFrameGetLines(txtFrame) as NSArray
        let lines = ctlines as Array
        
        let lineCount = CFArrayGetCount(lines)
        var lineOrigins = [CGPoint](count: lineCount, repeatedValue: CGPointZero)
        let range:CFRange = CFRangeMake(0, 0)
        CTFrameGetLineOrigins(txtFrame, range, &lineOrigins)
        let numberOfLines = getNumberOfLines()
        
        for var i = 0; i < numberOfLines; i++ {
            let line = lines[i] as! CTLineRef
            let ctruns = CTLineGetGlyphRuns(line) as NSArray
            let runs = ctruns as Array
            let runCount = CFArrayGetCount(runs)
            let lineOrigin = lineOrigins[i]
            var lineAscent = CGFloat()
            var lineDescent = CGFloat()
            
            CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, nil)
            
            let lineHeight = lineAscent + lineDescent;
            let lineBottomY = lineOrigin.y - lineDescent;
            
            for var j = 0 ; j < runCount ; j++ {
                let run = runs[j] as! CTRunRef
                let runAttributes = CTRunGetAttributes(run) as NSDictionary
//                let delegate =  runAttributes.valueForKey(kCTRunDelegateAttributeName as String)
//                
//                if delegate == nil {
//                    continue
//                }
//                
//                let attributedImage = CTRunDelegateGetRefCon(delegate as! CTRunDelegateRef) as! NJRichLabelAttachment
//
//               
                let  attributedImage:NJRichLabelAttachment
                if  let temp = runAttributes.valueForKey("attachment"){
                    attributedImage = temp as! NJRichLabelAttachment
                }else {
                    continue
                }
                
                var ascent = CGFloat()
                var descent = CGFloat()
                var width = CGFloat(CTRunGetTypographicBounds(run,
                    CFRangeMake(0, 0),
                    &ascent,
                    &descent,
                    nil))
                

                let imageBoxHeight = attributedImage.boxSize().height
                let xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
                
                var imageBoxOriginY = CGFloat()
                
                if attributedImage.alignment == ImageAlignment.Top {
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight)
                }else if attributedImage.alignment == ImageAlignment.Bottom {
                    imageBoxOriginY = lineBottomY
                }else if attributedImage.alignment == ImageAlignment.Center {
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight) / 2.0
                }
                
                let rect = CGRectMake(lineOrigin.x + xOffset, imageBoxOriginY, width, imageBoxHeight);
                var flippedMargins = attributedImage.margin;
                let top = flippedMargins!.top;
                
                let margin = UIEdgeInsetsMake(flippedMargins!.bottom, flippedMargins!.left, top, flippedMargins!.right)
                
                let attatchmentRect = UIEdgeInsetsInsetRect(rect, margin)
                
                if i == numberOfLines - 1 && j >= runCount - 2 && lineBreakMode == CTLineBreakMode.ByTruncatingTail {
                    let attachmentWidth = CGRectGetWidth(attatchmentRect)
                    let kMinEllipsesWidth = attachmentWidth
                    if (CGRectGetWidth(self.bounds) - CGRectGetMinX(attatchmentRect) - attachmentWidth <  kMinEllipsesWidth){
                        continue;
                    }

                }
                
                let content = attributedImage.content
                if content!.isKindOfClass(UIImage.self) {
                    CGContextDrawImage(context, attatchmentRect, (content as! UIImage).CGImage)
                }else if content!.isKindOfClass(UIView.self) {
                    let view = content as! UIView
                    if view.superview == nil {
                        self.addSubview(view)
                        let viewFrame = CGRectMake(attatchmentRect.origin.x,
                            self.bounds.size.height - attatchmentRect.origin.y - attatchmentRect.size.height,
                            attatchmentRect.size.width,
                            attatchmentRect.size.height)
                        view.frame = viewFrame
                    }
                }
                
            }
        }
    
    }
    
    func getNumberOfLines()->Int{
        let lines = CTFrameGetLines(txtFrame)
        return numberOflines > 0 ? min(numberOflines!, CFArrayGetCount(lines)):CFArrayGetCount(lines)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let drawString = setupAttributeString()
        
        if drawString.length == 0 {
            return CGSizeZero
        }
        
        let attributedStringRef = drawString as CFAttributedStringRef
        let framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef)
        var range = CFRangeMake(0, 0)
        
        if numberOflines > 0 {
            
            let path = CGPathCreateMutable()
            CGPathAddRect(path, nil, CGRectMake(0, 0, size.width, size.height))
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
            let lines = CTFrameGetLines(frame)
            
            if CFArrayGetCount(lines) > 0 {
                let lastVisibleLineIndex = min(numberOflines!, CFArrayGetCount(lines)) - 1
                let lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex)
                let rangeToLayout = CTLineGetStringRange(lastVisibleLine as! CTLineRef)
                range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length)
            }
        }
        
        var fitCFRange = CFRangeMake(0, 0)
        let newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,range,nil,size,&fitCFRange)
        
        return newSize
    }
    
    func resetFont(){
        let name = font?.fontName as! NSString
        var fontRef = CTFontCreateWithName(name as! CFStringRef,(font?.pointSize)!,nil)
        fontAscent = CTFontGetAscent(fontRef)
        fontDescent = CTFontGetDescent(fontRef)
        fontHeight = CTFontGetSize(fontRef)
    }
    
    func setText(text:NSString){
        if text.length > 0 {
            let string = NSMutableAttributedString(string:text as String)
            string.addAttribute(NSFontAttributeName, value:font!, range: NSMakeRange(0,string.length))
            string.addAttribute(NSForegroundColorAttributeName, value: textColor!, range: NSMakeRange(0,string.length))
        
            attributeString = NSMutableAttributedString(attributedString: string)
        }else {
            attributeString = NSMutableAttributedString(attributedString: NSAttributedString())
        }
    }
    
    func appendText(text:NSString){
        
        var attrString = NSMutableAttributedString()
        if text.length > 0 {
            let string = NSMutableAttributedString(string:text as String)
            string.addAttribute(NSFontAttributeName, value:font!, range: NSMakeRange(0,string.length))
            string.addAttribute(NSForegroundColorAttributeName, value: textColor!, range: NSMakeRange(0,string.length))
            
            attrString = NSMutableAttributedString(attributedString: string)
        }else {
            attrString = NSMutableAttributedString(attributedString: NSAttributedString())
        }

        attributeString.appendAttributedString(attrString)
        resetTextFrame()
    }

    
    func appendImage(image:UIImage){
        appendImage(image,maxSize: image.size)
    }
    
    func appendImage(image:UIImage,maxSize:CGSize){
       appendImage(image, maxSize: maxSize, margin: UIEdgeInsetsZero)
    }
    
    func appendImage(image:UIImage,maxSize:CGSize,margin:UIEdgeInsets){
       appendImage(image, maxSize: maxSize, margin: margin,alignment:ImageAlignment.Bottom)
    }
    
    func appendImage(image:UIImage,maxSize:CGSize,margin:UIEdgeInsets,alignment:ImageAlignment){
        let attachment = NJRichLabelAttachment(content: image, margin: margin, alignment: alignment, maxSize: maxSize)
        appendAttachment(attachment)
    }
    
    func appendView(view:UIView){
       appendView(view, margin: UIEdgeInsetsZero)
    }
    
    func appendView(view:UIView,margin:UIEdgeInsets){
        appendView(view, margin: margin, alignment: ImageAlignment.Bottom)
    }
    
    func appendView(view:UIView,margin:UIEdgeInsets,alignment:ImageAlignment) {
        let attachment = NJRichLabelAttachment(content: view, margin: margin, alignment: alignment, maxSize: CGSizeZero)
        appendAttachment(attachment)
    }
    
    func appendAttachment(attachment:NJRichLabelAttachment){
        attachment.fontAscent = fontAscent
        attachment.fontDescent = fontDescent
        var objectReplacementChar:unichar = 0xFFFC;
        let objectReplacementString = NSString.init(characters: &objectReplacementChar, length: 1)
        let attachText = NSMutableAttributedString(string:" " as String)
        
        var callbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { (ref) -> Void in
            
            }, getAscent: { (ref) -> CGFloat in
                
//               var attach = Unmanaged<NJRichLabelAttachment>.fromOpaque(COpaquePointer(ref)).takeRetainedValue() as! NJRichLabelAttachment
//                
//                var ascent:CGFloat = 0.0
//                let height = attach.boxSize().height
//                if attach.alignment == ImageAlignment.Top {
//                    ascent = attach.fontAscent!
//                }else if attach.alignment == ImageAlignment.Center {
//                    let fontAscent  = attach.fontAscent;
//                    let fontDescent = attach.fontDescent;
//                    let baseLine = (fontAscent! + fontDescent!) / 2 - fontDescent!;
//                    ascent = height / 2 + baseLine;
//                }else if attach.alignment == ImageAlignment.Bottom {
//                    ascent = height - attach.fontDescent!;
//                }
//                return ascent
                return 50
            }
            , getDescent: { (ref) -> CGFloat in
                
//                let attach = ref as! NJRichLabelAttachment
//                var descent:CGFloat = 0.0
//                let height = attach.boxSize().height
//                if attach.alignment == ImageAlignment.Top {
//                    descent = height - attach.fontAscent!
//                }else if attach.alignment == ImageAlignment.Center {
//                    let fontAscent  = attach.fontAscent;
//                    let fontDescent = attach.fontDescent;
//                    let baseLine = (fontAscent! + fontDescent!) / 2 - fontDescent!;
//                    descent = height / 2 - baseLine;
//                }else if attach.alignment == ImageAlignment.Bottom {
//                    descent = attach.fontDescent!
//                }
//                return descent
                
                return 50

                
            }) { (ref) -> CGFloat in
//                let attach = ref as! NJRichLabelAttachment
//                return attach.boxSize().width
                return 50
        }
    
        var image:NJRichLabelAttachment = attachment
        let delegate = CTRunDelegateCreate(&callbacks,&image)
        attachText.addAttribute(kCTRunDelegateAttributeName as String, value: delegate!, range: NSMakeRange(0, 1))
        attachText.addAttribute("attachment", value: image, range: NSMakeRange(0, 1))
        attributeString.appendAttributedString(attachText)
        resetTextFrame()
    }
    
    func resetTextFrame(){
        
        if txtFrame != nil {
            txtFrame = nil
        }
        
        if NSThread.isMainThread() {
            setNeedsDisplay()
        }
    }

}

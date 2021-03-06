//
//  HTMLBuilder.swift
//  Stepic
//
//  Created by Alexander Karpov on 24.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class HTMLBuilder: NSObject {
    fileprivate override init() {}
    static var sharedBuilder = HTMLBuilder()

    private func stepicStyleString(textColor: UIColor) -> String {
        var res: String = ""
        let colorHexString = textColor.hexString
        res += "<style>"
        res += "\nhtml{-webkit-text-size-adjust: 100%;}"
        res += "\nbody{font-size: 12pt; font-family:Arial, Helvetica, sans-serif; line-height:1.6em; color: #\(colorHexString); }"
        res += "\nh1{font-size: 20pt; font-family:Arial, Helvetica, sans-serif; line-height:1.6em; text-align: center; color: #\(colorHexString)}"
        res += "\nh2{font-size: 17pt; font-family:Arial, Helvetica, sans-serif; line-height:1.6em; text-align: center; color: #\(colorHexString);}"
        res += "\nh3{font-size: 14pt; font-family:Arial, Helvetica, sans-serif; line-height:1.6em; text-align: center; color: #\(colorHexString);}"
        res += "\nimg { max-width: 100%; }"
        res += "\niframe { max-width: 100%; }"

//        res += "\np { white-space: pre-wrap; word-wrap: break-word; max-width: 100%; }"
//        res += "\npre { white-space: pre-wrap; word-wrap: break-word; max-width: 100%; }"

        res += "\n</style>\n"
        res += "\n<link rel=\"stylesheet\" type=\"text/css\" href=\"wysiwyg.css\">"
        return res
    }

    fileprivate var stepicCommentStyleString: String {
        var res: String = ""
        res += "<style>"
        res += "\nhtml{-webkit-text-size-adjust: 100%;}"
        res += "\nbody{font-size: 10pt; font-family:Arial, Helvetica, sans-serif; line-height:1.6em;}"
        res += "\nh1{font-size: 18pt; font-family:Arial, Helvetica, sans-serif; line-height:1.6em; text-align: center;}"
        res += "\nh2{font-size: 14pt; font-family:Arial, Helvetica, sans-serif; line-height:1.6em; text-align: center;}"
        res += "\nh3{font-size: 12pt; font-family:Arial, Helvetica, sans-serif; line-height:1.6em; text-align: center;}"
        res += "\nimg { max-width: 100%; }"

        //        res += "\np { white-space: pre-wrap; word-wrap: break-word; max-width: 100%; }"
        //        res += "\npre { white-space: pre-wrap; word-wrap: break-word; max-width: 100%; }"

        res += "\n</style>\n"
        res += "\n<link rel=\"stylesheet\" type=\"text/css\" href=\"wysiwyg.css\">"
        return res
    }

    fileprivate var stepicBaseURLString: String = ""//"<base href=\"\(StepicApplicationsInfo.stepicURL)\">"

    func buildHTMLStringWith(head: String, body: String, width: Int? = nil, textColor: UIColor = UIColor.mainText) -> String {
        var res = "<html>\n"

        res += "<head>\n\(stepicStyleString(textColor: textColor) + stepicBaseURLString + head)\n</head>\n"

        if let width = width {
            res += "<body style=\"width:\(width))px;\">\n\(addStepikURLWhereNeeded(body: body))\n</body>\n"
        } else {
            res += "<body>\n\(addStepikURLWhereNeeded(body: body))\n</body>\n"
        }

        res += "</html>"
        return res
    }

    func buildCommentHTMLStringWith(head: String, body: String) -> String {
        var res = "<html>\n"

        res += "<head>\n\(stepicCommentStyleString + head)\n</head>\n"

        let bodyOpenTag = "<body>"
        res += "\(bodyOpenTag)\n\(addStepikURLWhereNeeded(body: body))\n</body>\n"

        res += "</html>"
        return res
    }

    func addStepikURLWhereNeeded(body: String) -> String {
        var body = body
        body = fixProtocolRelativeURLs(html: body)

        var links = HTMLParsingUtil.getAllLinksWithText(body).map({return $0.link})
        links += HTMLParsingUtil.getImageSrcLinks(body)
        var linkMap = [String: String]()

        for link in links {
            if link.first == Character("/") {
                linkMap[link] = "\(StepicApplicationsInfo.stepicURL)/\(link)"
            }
        }

        var newBody = body
        for (key, val) in linkMap {
            newBody = newBody.replacingOccurrences(of: "\"\(key)", with: "\"\(val)")
        }

        return newBody
    }

    func fixProtocolRelativeURLs(html: String) -> String {
        return html.replacingOccurrences(of: "src=\"//", with: "src=\"http://")
    }
}

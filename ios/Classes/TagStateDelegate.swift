import Flutter
import RaxelPulse

class TagStateDelegate: NSObject, RPTagsServerStateDelegate {
    private var channel: FlutterMethodChannel?
    
    public init(methodChannel: FlutterMethodChannel) {
        super.init()
        channel = methodChannel
    }
    
    func addTag(_ status: RPTagStatus, tag: RPTag!, timestamp: Int) {
        do {
            let jsonTag = try JSONSerialization.data(withJSONObject: tag.toJSON(), options: .prettyPrinted)
            let strTag = String(data: jsonTag, encoding: .utf8)!
            
            let json: [String : Any?] = [
                "status": String(describing: status),
                "tag": strTag,
                "activationTime": timestamp
            ]
            
            channel?.invokeMethod("onAddTag", arguments: json)
        } catch {}
    }
    
    func deleteTag(_ status: RPTagStatus, tag: RPTag!, timestamp: Int) {
        do {
            let jsonTag = try JSONSerialization.data(withJSONObject: tag.toJSON(), options: .prettyPrinted)
            let strTag = String(data: jsonTag, encoding: .utf8)!
            
            let json: [String : Any?] = [
                "status": String(describing: status),
                "tag": strTag,
                "deactivationTime": timestamp
            ]
            
            channel?.invokeMethod("onTagRemove", arguments: json)
        } catch {}
    }
    
    func removeAll(_ status: RPTagStatus, timestamp: Int) {
        let json: [String : Any?] = [
            "status": String(describing: status),
            "time": timestamp
        ]
        
        channel?.invokeMethod("onAllTagsRemove", arguments: json)
    }
    
    func getTags(_ status: RPTagStatus, tags: Any, timestamp: Int) {
        let _tags = tags as? RPTags
        
        var strTags = [String]()
        
        _tags?.tags.forEach { element in
            do {
                let jsonTag = try JSONSerialization.data(withJSONObject: element.toJSON(), options: .prettyPrinted)
                let strTag = String(data: jsonTag, encoding: .utf8)!
                
                strTags.append(strTag)
            } catch {}
        }
        
        let json: [String : Any?] = [
            "status": String(describing: status),
            "tags": strTags,
            "time": timestamp
        ]
        
        channel?.invokeMethod("onGetTags", arguments: json)
    }
}

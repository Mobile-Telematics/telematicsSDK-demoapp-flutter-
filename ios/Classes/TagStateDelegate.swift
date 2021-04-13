import Flutter
import RaxelPulse

class TagStateDelegate: NSObject, RPTagsServerStateDelegate {
    private var channel: FlutterMethodChannel?
    
    public init(methodChannel: FlutterMethodChannel) {
        super.init()
        channel = methodChannel
    }
    
    func addTag(_ status: RPTagStatus, tag: RPTag!, timestamp: Int) {
        let json: [String : Any?] = [
            "status": String(describing: status),
            "tag": String(data: tag.toJSON() as! Data, encoding: .utf8),
            "activationTime": timestamp
        ]
        
        channel?.invokeMethod("onAddTag", arguments: json)
    }
    
    func deleteTag(_ status: RPTagStatus, tag: RPTag!, timestamp: Int) {
        let json: [String : Any?] = [
            "status": String(describing: status),
            "tag": String(data: tag.toJSON() as! Data, encoding: .utf8),
            "deactivationTime": timestamp
        ]
        
        channel?.invokeMethod("onTagRemove", arguments: json)
    }
    
    func removeAll(_ status: RPTagStatus, timestamp: Int) {
        let json: [String : Any?] = [
            "status": String(describing: status),
            "time": timestamp
        ]
        
        channel?.invokeMethod("onAllTagsRemove", arguments: json)
    }
    
    func getTags(_ status: RPTagStatus, tags: Any!, timestamp: Int) {
        let _tags = tags as? RPTags
        
        var strTags = [String]()

        _tags?.tags.forEach { element in
            let str = String(data: element.toJSON() as! Data, encoding: .utf8)!
            strTags.append(str)
        }
        
        let json: [String : Any?] = [
            "status": String(describing: status),
            "tags": strTags,
            "time": timestamp
        ]
        
        channel?.invokeMethod("onGetTags", arguments: json)
    }
}

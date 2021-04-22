package com.telematicssdk

import org.json.JSONObject
import com.raxeltelematics.v2.sdk.server.model.sdk.TrackTag
import com.raxeltelematics.v2.sdk.server.model.sdk.raw_tags.Tag

fun TrackTag.toJsonString(): String {
    val json = mapOf<String, Any?>(
            "source" to source,
            "tag" to tag,
            "type" to type,
    )

    val jsonObject = JSONObject(json)

    return jsonObject.toString()
}

fun Tag.toJsonString(): String {
    val json = mapOf<String, Any?>(
            "source" to source,
            "tag" to tag,
    )

    val jsonObject = JSONObject(json)

    return jsonObject.toString()
}

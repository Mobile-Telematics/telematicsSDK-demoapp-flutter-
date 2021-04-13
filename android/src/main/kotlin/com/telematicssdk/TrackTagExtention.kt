package com.telematicssdk

import com.raxeltelematics.v2.sdk.server.model.sdk.TrackTag

fun TrackTag.toJsonString(): String {
    return "{\"source\": \"$source\", \"tag\": \"$tag\", \"type\": \"$type\"}";
}
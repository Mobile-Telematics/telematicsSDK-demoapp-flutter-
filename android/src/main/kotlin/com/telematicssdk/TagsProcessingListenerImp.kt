package com.telematicssdk

import com.telematicssdk.tracking.TagsProcessingListener
import com.telematicssdk.tracking.model.database.models.raw_tags.Status
import com.telematicssdk.tracking.server.model.sdk.raw_tags.Tag
import io.flutter.plugin.common.MethodChannel

class TagsProcessingListenerImp(private val channel: MethodChannel) : TagsProcessingListener {
    override fun onTagAdd(status: Status, tag: Tag, activationTime: Long) {
        val json = mapOf<String, Any>(
                "status" to status.name,
                "tag" to tag.toJsonString(),
                "activationTime" to activationTime
        )

        channel.invokeMethod("onTagAdd", json)
    }

    override fun onTagRemove(status: Status, tag: Tag, deactivationTime: Long) {
        val json = mapOf<String, Any>(
                "status" to status.name,
                "tag" to tag.toJsonString(),
                "deactivationTime" to deactivationTime
        )

        channel.invokeMethod("onTagRemove", json)
    }

    override fun onAllTagsRemove(status: Status, deactivatedTagsCount: Int, time: Long) {
        val json = mapOf<String, Any>(
                "status" to status.name,
                "time" to time
        )

        channel.invokeMethod("onAllTagsRemove", json)
    }

    override fun onGetTags(status: Status, tags: Array<Tag>?, time: Long) {
        val json = mapOf<String, Any?>(
                "status" to status.name,
                "tags" to tags?.map { it.toJsonString() },
                "time" to time
        )

        channel.invokeMethod("onGetTags", json)
    }
}

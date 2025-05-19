#
# © 2024-present https://github.com/cengiz-pz
#

@tool
extends EditorPlugin

const PLUGIN_NODE_TYPE_NAME = "NotificationScheduler"
const PLUGIN_PARENT_NODE_TYPE = "Node"
const PLUGIN_NAME: String = "NotificationSchedulerPlugin"
const PLUGIN_VERSION: String = "4.0"
const RESULT_ACTIVITY_CLASS_PATH: String = "org.godotengine.plugin.android.notification.ResultActivity"
const NOTIFICATION_RECEIVER_CLASS_PATH: String = "org.godotengine.plugin.android.notification.NotificationReceiver"
const CANCEL_RECEIVER_CLASS_PATH: String = "org.godotengine.plugin.android.notification.CancelNotificationReceiver"
const PLUGIN_DEPENDENCIES: Array = [ "androidx.appcompat:appcompat:1.7.0" ]

var android_export_plugin: AndroidExportPlugin
var ios_export_plugin: IosExportPlugin


func _enter_tree() -> void:
	add_custom_type(PLUGIN_NODE_TYPE_NAME, PLUGIN_PARENT_NODE_TYPE, preload("%s.gd" % PLUGIN_NODE_TYPE_NAME), preload("icon.png"))
	android_export_plugin = AndroidExportPlugin.new()
	add_export_plugin(android_export_plugin)
	ios_export_plugin = IosExportPlugin.new()
	add_export_plugin(ios_export_plugin)


func _exit_tree() -> void:
	remove_custom_type(PLUGIN_NODE_TYPE_NAME)
	remove_export_plugin(android_export_plugin)
	android_export_plugin = null
	remove_export_plugin(ios_export_plugin)
	ios_export_plugin = null


class AndroidExportPlugin extends EditorExportPlugin:
	var _plugin_name = PLUGIN_NAME


	func _supports_platform(platform: EditorExportPlatform) -> bool:
		if platform is EditorExportPlatformAndroid:
			return true
		return false


	func _get_android_libraries(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		if debug:
			return PackedStringArray(["%s/bin/debug/%s-%s-debug.aar" % [_plugin_name, _plugin_name, PLUGIN_VERSION]])
		else:
			return PackedStringArray(["%s/bin/release/%s-%s-release.aar" % [_plugin_name, _plugin_name, PLUGIN_VERSION]])


	func _get_name() -> String:
		return _plugin_name


	func _get_android_dependencies(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return PackedStringArray(PLUGIN_DEPENDENCIES)


	func _get_android_manifest_application_element_contents(platform: EditorExportPlatform, debug: bool) -> String:
		var __contents: String = ""

		__contents += """
			<activity
				android:name="%s"
				android:theme="@style/Theme.AppCompat.NoActionBar"
				android:excludeFromRecents="true"
				android:launchMode="singleTask"
				android:noHistory="true"
				android:taskAffinity="" />
			""" % RESULT_ACTIVITY_CLASS_PATH

		__contents += """
			<receiver
				android:name="%s"
				android:enabled="true"
				android:exported="true"
				android:process=":godot_notification_receiver" />
			""" % NOTIFICATION_RECEIVER_CLASS_PATH

		__contents += """
			<receiver
				android:name="%s"
				android:enabled="true"
				android:exported="true" />
			""" % CANCEL_RECEIVER_CLASS_PATH

		return __contents


class IosExportPlugin extends EditorExportPlugin:
	var _plugin_name = PLUGIN_NAME


	func _supports_platform(platform: EditorExportPlatform) -> bool:
		if platform is EditorExportPlatformIOS:
			return true
		return false


	func _get_name() -> String:
		return _plugin_name

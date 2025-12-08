package com.example.myappluciano

import io.flutter.embedding.engine.plugins.FlutterPlugin

class UserApiImpl : FlutterPlugin, UserApi {

    private var user: PigeonUser? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        UserApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        UserApi.setUp(binding.binaryMessenger, null)
    }

    override fun getUser(): PigeonUser? {
        return user
    }

    override fun saveUser(user: PigeonUser) {
        this.user = user
    }
}

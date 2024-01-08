import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ProfilePage extends GetView {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: Container(),
    );
  }
}

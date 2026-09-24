import 'package:flutter/material.dart';

import 'profile_screen.dart';

class SettingScreen extends StatelessWidget {
  final bool showAppBar;

  const SettingScreen({
    super.key,
    this.showAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(showAppBar: showAppBar);
  }
}

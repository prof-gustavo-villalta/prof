import 'package:flutter/material.dart';
import '../design_system/app_spacing.dart';
import 'page_header.dart';

class SingleColumnScreen extends StatelessWidget {
  const SingleColumnScreen({
    super.key,
    this.appBarTitle,
    required this.title,
    required this.icon,
    required this.children,
    this.bottomActionBar,
    this.spacingAfterHeader = AppSpacing.section,
    this.padding = AppSpacing.pageInsets,
  });

  final String? appBarTitle;
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? bottomActionBar;
  final double spacingAfterHeader;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTitle == null ? null : AppBar(title: Text(appBarTitle!)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: padding,
                children: [
                  PageHeader(title: title, icon: icon),
                  if (spacingAfterHeader > 0)
                    SizedBox(height: spacingAfterHeader),
                  ...children,
                ],
              ),
            ),
            ?bottomActionBar,
          ],
        ),
      ),
    );
  }
}

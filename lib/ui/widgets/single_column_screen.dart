import 'package:flutter/material.dart';

import '../design_system.dart';
import 'page_header.dart';

enum AppScreenPadding { page, list, none }

extension AppScreenPaddingInsets on AppScreenPadding {
  EdgeInsetsGeometry get insets {
    return switch (this) {
      AppScreenPadding.page => AppSpacing.pageInsets,
      AppScreenPadding.list => AppSpacing.listVertical,
      AppScreenPadding.none => EdgeInsets.zero,
    };
  }
}

class SingleColumnScreen extends StatelessWidget {
  const SingleColumnScreen({
    super.key,
    this.appBarTitle,
    this.title,
    this.icon,
    required this.children,
    this.bottomActionBar,
    this.spacingAfterHeader = AppSpacing.section,
    this.padding,
    this.paddingPreset = AppScreenPadding.page,
  }) : assert(
         (title == null && icon == null) || (title != null && icon != null),
         'title and icon must be provided together.',
       );

  final String? appBarTitle;
  final String? title;
  final IconData? icon;
  final List<Widget> children;
  final Widget? bottomActionBar;
  final double spacingAfterHeader;
  final EdgeInsetsGeometry? padding;
  final AppScreenPadding paddingPreset;

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null && icon != null;
    final horizontalSafeArea = (padding ?? paddingPreset.insets).resolve(
      Directionality.of(context),
    );

    return Scaffold(
      appBar: appBarTitle == null
          ? null
          : AppBar(
              title: Text(
                appBarTitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: padding ?? paddingPreset.insets,
                children: [
                  if (hasHeader) PageHeader(title: title!, icon: icon!),
                  if (hasHeader && spacingAfterHeader > 0)
                    SizedBox(height: spacingAfterHeader),
                  ...children,
                ],
              ),
            ),
            if (bottomActionBar != null)
              Padding(
                padding: EdgeInsets.only(
                  left: horizontalSafeArea.left,
                  right: horizontalSafeArea.right,
                ),
                child: bottomActionBar,
              ),
          ],
        ),
      ),
    );
  }
}

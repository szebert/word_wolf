import 'package:flutter/material.dart';

import '../../app_ui/widgets/app_text.dart';
import '../../l10n/l10n.dart';

class GameCategoryPage extends StatelessWidget {
  const GameCategoryPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const GameCategoryPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          'Category Selection',
          variant: AppTextVariant.titleLarge,
        ),
      ),
      body: Center(
        child: AppText(
          'Category selection page coming soon',
          variant: AppTextVariant.bodyLarge,
        ),
      ),
    );
  }
}

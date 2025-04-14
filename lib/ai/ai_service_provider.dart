import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "bloc/ai_config_bloc.dart";
import "services/ai_service_manager.dart";

/// Service provider that configures and provides the AIServiceManager with API settings
class AIServiceProvider extends StatelessWidget {
  const AIServiceProvider({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AIConfigBloc, AIConfigState>(
      listener: (context, state) {
        if (state.status == AIConfigStatus.loaded) {
          _refreshAIServiceManager(context);
        }
      },
      child: child,
    );
  }

  void _refreshAIServiceManager(BuildContext context) {
    // Refresh the AI service manager's configurations
    context.read<AIServiceManager>().refreshConfigurations();
  }
}

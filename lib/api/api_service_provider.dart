import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "bloc/api_config_bloc.dart";
import "services/ai_service_manager.dart";

/// Service provider that configures and provides the AIServiceManager with API settings
class APIServiceProvider extends StatelessWidget {
  const APIServiceProvider({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<APIConfigBloc, APIConfigState>(
      listener: (context, state) {
        if (state.status == APIConfigStatus.loaded) {
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

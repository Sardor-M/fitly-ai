import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/routes/app_routes.dart';
import '../auth/brand_logo.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
    this.title,
    this.actions,
  });

  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: onBackPressed ?? () => Get.back(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (showBackButton) const SizedBox(width: 12),
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const Expanded(
              child: BrandLogo(size: 28),
            ),
          if (isLoggedIn) ...[
                  IconButton(
                    icon: CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: user.userMetadata?['avatar_url'] != null
                          ? NetworkImage(user.userMetadata!['avatar_url'])
                          : null,
                      onBackgroundImageError: (exception, stackTrace) {
                        /** 
                          Avatar image error
                        */
                        print('Avatar image error: $exception');
                      },
                      child: user.userMetadata?['avatar_url'] == null
                          ? Icon(
                              Icons.person,
                              size: 20,
                              color: theme.colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                    onPressed: () => Get.toNamed(AppRoutes.account),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
          ],
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}


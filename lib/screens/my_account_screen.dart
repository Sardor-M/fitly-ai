import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../models/outfit_history.dart';
import '../services/supabase_outfit_service.dart';
import '../utils/constants.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  List<OutfitHistory> _outfits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOutfitHistory();
  }

  Future<void> _loadOutfitHistory() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final outfits = await SupabaseOutfitService.getUserOutfits(user.id);
      setState(() {
        _outfits = outfits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final session = Supabase.instance.client.auth.currentSession;
    final controller = Get.find<AuthController>();

    if (user == null || session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.onboarding);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    const _pinkColor = Color(0xFFFD2375);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /** 
              Header with logo and user icon
            */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.offAllNamed(AppRoutes.camera),
                    child: Text(
                      AppConstants.appName.toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Icon(Icons.person, color: Colors.black),
                ],
              ),
            ),

            /** 
              Navigation bar with back button and title
            */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'My Account',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /** 
              User Profile Section
            */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: user.userMetadata?['avatar_url'] != null
                          ? NetworkImage(user.userMetadata!['avatar_url'])
                          : null,
                      child: user.userMetadata?['avatar_url'] == null
                          ? Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.grey.shade600,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.userMetadata?['full_name'] as String? ?? 'User',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /** 
              Style History Section
            */
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Style History',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _outfits.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 32,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.history,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No previous analyses yet.\nStart your first style analysis!',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _outfits.length,
                                  itemBuilder: (context, index) {
                                    final outfit = _outfits[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: outfit.imageUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey.shade200,
                                              child: const Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          outfit.style.toUpperCase(),
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          outfit.paletteName ?? 'Style Analysis',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: Text(
                                          _formatDate(outfit.createdAt),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                    const SizedBox(height: 24),
                    /** 
                      Logout Button
                    */
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.signOut(),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pinkColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),  
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
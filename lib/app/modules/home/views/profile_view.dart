import 'package:aperturely_app/app/models/post_model.dart';
import 'package:aperturely_app/app/models/user_model.dart';
import 'package:aperturely_app/app/modules/home/views/dashboard_view.dart';
import 'package:aperturely_app/app/services/auth_service.dart';
import 'package:aperturely_app/app/services/post_service.dart';
import 'package:aperturely_app/app/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    super.key,
    this.user,
    this.isCurrentUser = false,
  });

  final UserModel? user;
  final bool isCurrentUser;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();

  UserModel? _user;
  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      UserModel targetUser = widget.user ?? const UserModel(id: 0, name: '', username: '');
      if (widget.isCurrentUser && widget.user == null) {
        final response = await _authService.getProfile();
        final body = response['body'] as Map<String, dynamic>? ?? {};
        targetUser = UserModel.fromJson(body);
      }

      final posts = await _postService.fetchPosts();
      final filtered = posts.where((post) => post.user.id == targetUser.id).toList();

      setState(() {
        _user = targetUser;
        _posts = filtered;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Profile belum bisa dimuat.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        title: Text(widget.isCurrentUser ? 'Profil Saya' : 'Profil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null || user == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_off_outlined, size: 52, color: AppColors.muted),
                        const SizedBox(height: 16),
                        Text(_error ?? 'Profile tidak ditemukan'),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  color: AppColors.accent,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 28),
                    children: [
                      Container(
                        height: 160,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF111111), Color(0xFF2C241F), Color(0xFF111111)],
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -34),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x180A0A0A),
                                  blurRadius: 24,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: CachedNetworkImage(
                                        imageUrl: user.avatarDisplay,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.displayName,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            user.email?.isNotEmpty == true
                                                ? user.email!
                                                : user.name,
                                            style: const TextStyle(
                                              color: AppColors.muted,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: [
                                              _ProfileStat(label: 'Postingan', value: _posts.length),
                                              _ProfileStat(
                                                label: 'Likes',
                                                value: _posts.fold<int>(
                                                  0,
                                                  (sum, post) => sum + post.likesCount,
                                                ),
                                              ),
                                              _ProfileStat(
                                                label: 'Komentar',
                                                value: _posts.fold<int>(
                                                  0,
                                                  (sum, post) => sum + post.commentsCount,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Postingan',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (_posts.isEmpty)
                              const Text(
                                'Belum ada postingan untuk profile ini.',
                                style: TextStyle(color: AppColors.muted),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _posts.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.8,
                                ),
                                itemBuilder: (context, index) {
                                  final post = _posts[index];
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PostDetailView(
                                          postId: post.id,
                                          initialPost: post,
                                          allPosts: _posts,
                                        ),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: CachedNetworkImage(
                                        imageUrl: post.firstPhoto?.url ??
                                            'https://via.placeholder.com/400x500?text=No+Image',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

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

  int get _totalLikes => _posts.fold<int>(0, (sum, post) => sum + post.likesCount);

  int get _followerCount => _posts.isEmpty ? 0 : 1;

  int get _followingCount => widget.isCurrentUser ? 1 : 0;

  String get _joinedLabel {
    final sourceDate =
        _posts.isNotEmpty ? _posts.map((post) => post.createdAt).reduce((a, b) => a.isBefore(b) ? a : b) : DateTime.now();

    const months = <String>[
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return 'Bergabung ${months[sourceDate.month - 1]} ${sourceDate.year}';
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label akan segera tersedia.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth >= 1100 ? 56.0 : screenWidth >= 700 ? 28.0 : 18.0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
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
                    padding: const EdgeInsets.only(bottom: 32),
                    children: [
                      _ProfileHero(height: screenWidth >= 800 ? 200 : 150),
                      Transform.translate(
                        offset: const Offset(0, -56),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: _ProfileHeaderCard(
                            user: user,
                            postCount: _posts.length,
                            followerCount: _followerCount,
                            followingCount: _followingCount,
                            likedCount: _totalLikes,
                            joinedLabel: _joinedLabel,
                            isCurrentUser: widget.isCurrentUser,
                            onCreatePost: () => _showComingSoon('Fitur buat postingan'),
                            onEditProfile: () => _showComingSoon('Fitur edit profil'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Postingan',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                                fontFamily: 'serif',
                              ),
                            ),
                            const SizedBox(height: 20),
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
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _gridColumnCount(screenWidth),
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: screenWidth >= 700 ? 0.88 : 0.78,
                                ),
                                itemBuilder: (context, index) {
                                  final post = _posts[index];
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PostDetailView(
                                          postId: post.id,
                                          initialPost: post,
                                          allPosts: _posts,
                                        ),
                                      ),
                                    ),
                                    child: _ProfilePostCard(post: post),
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

  int _gridColumnCount(double width) {
    if (width >= 1180) return 4;
    if (width >= 760) return 3;
    return 2;
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF171412),
            Color(0xFF2A221E),
            Color(0xFF171412),
          ],
        ),
        image: DecorationImage(
          image: const NetworkImage(
            'https://www.transparenttextures.com/patterns/carbon-fibre.png',
          ),
          repeat: ImageRepeat.repeat,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.05),
            BlendMode.srcATop,
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.user,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.likedCount,
    required this.joinedLabel,
    required this.isCurrentUser,
    required this.onCreatePost,
    required this.onEditProfile,
  });

  final UserModel user;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final int likedCount;
  final String joinedLabel;
  final bool isCurrentUser;
  final VoidCallback onCreatePost;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 760;

    return Container(
      padding: EdgeInsets.all(isCompact ? 20 : 34),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140A0A0A),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompact) ...[
            _ProfileIdentity(user: user, compact: true),
            const SizedBox(height: 18),
            if (isCurrentUser) _ProfileActions(onCreatePost: onCreatePost, onEditProfile: onEditProfile),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ProfileIdentity(user: user, compact: false),
                ),
                if (isCurrentUser)
                  _ProfileActions(
                    onCreatePost: onCreatePost,
                    onEditProfile: onEditProfile,
                  ),
              ],
            ),
          const SizedBox(height: 22),
          Container(height: 1, color: AppColors.warmGray),
          const SizedBox(height: 18),
          Wrap(
            spacing: 0,
            runSpacing: 12,
            children: [
              _ProfileStat(label: 'POSTINGAN', value: postCount, width: isCompact ? width * 0.37 : null),
              _ProfileStat(label: 'PENGIKUT', value: followerCount, width: isCompact ? width * 0.37 : null),
              _ProfileStat(label: 'MENGIKUTI', value: followingCount, width: isCompact ? width * 0.37 : null),
              _ProfileStat(label: 'DISUKAI', value: likedCount, width: isCompact ? width * 0.37 : null),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: AppColors.warmGray),
          const SizedBox(height: 20),
          Text(
            user.name.isNotEmpty ? user.name : 'Selamat datang',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.black,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.muted),
              const SizedBox(width: 8),
              Text(
                joinedLabel,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({
    required this.user,
    required this.compact,
  });

  final UserModel user;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: CachedNetworkImage(
              imageUrl: user.avatarDisplay,
              width: compact ? 104 : 132,
              height: compact ? 104 : 132,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    fontSize: compact ? 28 : 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '@${user.username.isNotEmpty ? user.username : user.displayName.toLowerCase().replaceAll(' ', '')}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileActions extends StatelessWidget {
  const _ProfileActions({
    required this.onCreatePost,
    required this.onEditProfile,
  });

  final VoidCallback onCreatePost;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: onCreatePost,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Buat Postingan',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onEditProfile,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.black,
            side: const BorderSide(color: AppColors.warmGray),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text(
            'Edit Profil',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _ProfilePostCard extends StatelessWidget {
  const _ProfilePostCard({required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: post.firstPhoto?.url ?? 'https://via.placeholder.com/400x500?text=No+Image',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.68),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_camera_back_outlined, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${post.photos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.label,
    required this.value,
    this.width,
  });

  final String label;
  final int value;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: AppColors.warmGray),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

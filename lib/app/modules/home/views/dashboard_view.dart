import 'package:aperturely_app/app/models/kategori_model.dart';
import 'package:aperturely_app/app/models/komentar_model.dart';
import 'package:aperturely_app/app/models/post_model.dart';
import 'package:aperturely_app/app/models/user_model.dart';
import 'package:aperturely_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:aperturely_app/app/modules/home/views/profile_view.dart';
import 'package:aperturely_app/app/routes/app_routes.dart';
import 'package:aperturely_app/app/services/post_service.dart';
import 'package:aperturely_app/app/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timeago/timeago.dart' as timeago;

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final PostService _postService = PostService();
  final GetStorage _box = GetStorage();

  List<PostModel> _allPosts = [];
  List<PostModel> _visiblePosts = [];
  List<KategoriModel> _categories = [];
  KategoriModel? _selectedCategory;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _postService.fetchPosts(),
        _postService.fetchCategories(),
      ]);

      _allPosts = results[0] as List<PostModel>;
      _categories = results[1] as List<KategoriModel>;
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data dari server. Pastikan Laravel aktif di port 8000.';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final filtered = _allPosts.where((post) {
      final selectedId = _selectedCategory?.id;
      final matchCategory = selectedId == null ||
          post.kategori?.id == selectedId ||
          post.categoryId == selectedId;
      return matchCategory;
    }).toList();

    setState(() {
      _visiblePosts = filtered;
      _isLoading = false;
    });
  }

  int _columnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final token = _box.read<String>('token');
    final isLoggedIn = token?.isNotEmpty == true;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: AppColors.cream.withOpacity(0.94),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 72,
            titleSpacing: 20,
            title: const _BrandHeader(),
            actions: [
              IconButton(
                onPressed: () => _handleProfileTap(isLoggedIn),
                icon: Icon(
                  isLoggedIn ? Icons.account_circle_rounded : Icons.person_outline,
                  color: AppColors.black,
                ),
                tooltip: isLoggedIn ? 'Akun' : 'Masuk',
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 56,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    label: 'Semua',
                    active: _selectedCategory == null,
                    onTap: () {
                      _selectedCategory = null;
                      _applyFilters();
                    },
                  ),
                  ..._categories.map(
                    (category) => _CategoryChip(
                      label: category.name,
                      active: _selectedCategory?.id == category.id,
                      onTap: () {
                        _selectedCategory = category;
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: _DashboardState(
                title: 'Belum bisa memuat feed',
                message: _error!,
                actionLabel: 'Coba lagi',
                onAction: _loadData,
              ),
            )
          else if (_visiblePosts.isEmpty)
            SliverFillRemaining(
              child: _DashboardState(
                title: 'Belum ada hasil',
                message: 'Coba kata kunci lain atau pilih kategori yang berbeda.',
                actionLabel: 'Reset filter',
                onAction: () {
                  _selectedCategory = null;
                  _applyFilters();
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: SliverToBoxAdapter(
                child: MasonryGridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: _columnCount(context),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemCount: _visiblePosts.length,
                  itemBuilder: (context, index) {
                    final post = _visiblePosts[index];
                    return _PostCard(
                      post: post,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PostDetailView(
                            postId: post.id,
                            initialPost: post,
                            allPosts: _allPosts,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleProfileTap(bool isLoggedIn) {
    if (!isLoggedIn) {
      Get.toNamed(Routes.login);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.warmGray,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                _MenuTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Profil Saya',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(Routes.profile);
                  },
                ),
                _MenuTile(
                  icon: Icons.home_outlined,
                  title: 'Beranda',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.offAllNamed(Routes.dashboard);
                  },
                ),
                _MenuTile(
                  icon: Icons.explore_outlined,
                  title: 'Explore',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(Routes.explore);
                  },
                ),
                _MenuTile(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Trending',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(Routes.trending);
                  },
                ),
                _MenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifikasi',
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(Routes.notifications);
                  },
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accentSoft,
                    child: Icon(Icons.person, color: AppColors.accent),
                  ),
                  title: Text(
                    'Kamu sudah masuk',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Akses postingan dan fitur akun dari aplikasi.'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.put(AuthController()).logout();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PostDetailView extends StatefulWidget {
  const PostDetailView({
    super.key,
    required this.postId,
    required this.initialPost,
    required this.allPosts,
  });

  final int postId;
  final PostModel initialPost;
  final List<PostModel> allPosts;

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final PostService _postService = PostService();
  late PostModel _post = widget.initialPost;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await _postService.fetchPostDetail(widget.postId);
      if (mounted) {
        setState(() {
          _post = detail;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<PostModel> get _relatedPosts => widget.allPosts
      .where((item) =>
          item.id != _post.id &&
          ((item.kategori?.id != null &&
                  item.kategori?.id == _post.kategori?.id) ||
              (item.categoryId != null && item.categoryId == _post.categoryId)))
      .take(6)
      .toList();

  @override
  Widget build(BuildContext context) {
    final imageUrls = _post.photos.map((photo) => photo.url).toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        title: const Text('Detail Postingan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: PageView.builder(
                      itemCount: imageUrls.isEmpty ? 1 : imageUrls.length,
                      itemBuilder: (context, index) {
                        final url = imageUrls.isEmpty
                            ? 'https://via.placeholder.com/800x800?text=No+Image'
                            : imageUrls[index];
                        return CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _openUserProfile(_post.user),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage:
                            CachedNetworkImageProvider(_post.user.avatarDisplay),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _openUserProfile(_post.user),
                            child: Text(
                              _post.user.displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          Text(
                            timeago.format(_post.createdAt, locale: 'id'),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_post.kategori != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          _post.kategori!.name,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                if ((_post.caption ?? '').isNotEmpty)
                  Text(
                    _post.caption!,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: AppColors.black,
                    ),
                  ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _StatPill(
                      icon: Icons.favorite_border_rounded,
                      label: '${_post.likesCount} suka',
                    ),
                    _StatPill(
                      icon: Icons.mode_comment_outlined,
                      label: '${_post.commentsCount} komentar',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Komentar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 14),
                if (_post.comments.isEmpty)
                  const Text(
                    'Belum ada komentar di postingan ini.',
                    style: TextStyle(color: AppColors.muted),
                  )
                else
                  ..._post.comments.map((comment) => _CommentTile(comment: comment)),
                if (_relatedPosts.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const Text(
                    'Postingan Serupa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._relatedPosts.map(
                    (post) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: post.firstPhoto?.url ??
                              'https://via.placeholder.com/120x120?text=No+Image',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        post.user.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        post.caption?.trim().isNotEmpty == true
                            ? post.caption!
                            : 'Tanpa caption',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => PostDetailView(
                            postId: post.id,
                            initialPost: post,
                            allPosts: widget.allPosts,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  void _openUserProfile(UserModel user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileView(user: user),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.camera_alt_outlined, color: AppColors.black),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperturely',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'EXPLORE',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: AppColors.black,
        labelStyle: TextStyle(
          color: active ? Colors.white : AppColors.muted,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: AppColors.warmGray),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.black),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: onTap,
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onTap,
  });

  final PostModel post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140A0A0A),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: CachedNetworkImage(
                imageUrl: post.firstPhoto?.url ??
                    'https://via.placeholder.com/600x800?text=No+Image',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProfileView(user: post.user),
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundImage:
                              CachedNetworkImageProvider(post.user.avatarDisplay),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProfileView(user: post.user),
                            ),
                          ),
                          child: Text(
                            post.user.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if ((post.caption ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      post.caption!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.black,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.favorite_border_rounded,
                          size: 16, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text('${post.likesCount}',
                          style: const TextStyle(color: AppColors.muted)),
                      const SizedBox(width: 12),
                      const Icon(Icons.mode_comment_outlined,
                          size: 16, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text('${post.commentsCount}',
                          style: const TextStyle(color: AppColors.muted)),
                    ],
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

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final KomentarModel comment;

  @override
  Widget build(BuildContext context) {
    void openProfile() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProfileView(user: comment.user),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: openProfile,
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage:
                      CachedNetworkImageProvider(comment.user.avatarDisplay),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: openProfile,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${comment.user.displayName} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            TextSpan(
                              text: comment.comment,
                              style: const TextStyle(color: AppColors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeago.format(comment.createdAt, locale: 'id'),
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 42, top: 10),
              child: Column(
                children: comment.replies
                    .map((reply) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CommentTile(comment: reply),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardState extends StatelessWidget {
  const _DashboardState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library_outlined,
                size: 48, color: AppColors.muted),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.6),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

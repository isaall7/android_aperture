import 'package:aperturely_app/app/models/kategori_model.dart';
import 'package:aperturely_app/app/models/post_model.dart';
import 'package:aperturely_app/app/modules/home/views/dashboard_view.dart';
import 'package:aperturely_app/app/modules/home/views/profile_view.dart';
import 'package:aperturely_app/app/services/post_service.dart';
import 'package:aperturely_app/app/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final PostService _postService = PostService();
  final TextEditingController _searchController = TextEditingController();

  List<PostModel> _allPosts = [];
  List<PostModel> _visiblePosts = [];
  List<KategoriModel> _categories = [];
  KategoriModel? _selectedCategory;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
        _postService.fetchPhotoTypes(),
      ]);

      _allPosts = results[0] as List<PostModel>;
      _categories = results[1] as List<KategoriModel>;
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = 'Explore belum bisa memuat tipe foto dan postingan dari API.\n$e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _allPosts.where((post) {
      final haystack = [
        post.caption ?? '',
        post.user.displayName,
        post.kategori?.name ?? '',
      ].join(' ').toLowerCase();
      final matchQuery = query.isEmpty || haystack.contains(query);
      return matchQuery;
    }).toList();

    setState(() {
      _visiblePosts = filtered;
      _isLoading = false;
    });
  }

  Future<void> _selectPhotoType(KategoriModel? type) async {
    setState(() {
      _selectedCategory = type;
      _isLoading = true;
      _error = null;
    });

    try {
      if (type == null) {
        _allPosts = await _postService.fetchPosts();
      } else {
        _allPosts = await _postService.fetchPostsByPhotoType(type.id);
      }
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat postingan untuk tipe foto terpilih.\n$e';
        _isLoading = false;
      });
    }
  }

  void _resetFilters() {
    _searchController.clear();
    _selectedCategory = null;
    _applyFilters();
  }

  int _columns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1280) return 4;
    if (width >= 1000) return 3;
    if (width >= 800) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final useSidebarLayout = width >= 860;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        title: const Text('Explore'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.accent,
        child: ListView(
          padding: EdgeInsets.fromLTRB(useSidebarLayout ? 28 : 16, 18, useSidebarLayout ? 28 : 16, 28),
          children: [
            useSidebarLayout
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 242,
                        child: _ExploreSidebar(
                          searchController: _searchController,
                          categories: _categories,
                          selectedCategory: _selectedCategory,
                          onSearchChanged: (_) => _applyFilters(),
                          onSearchPressed: _applyFilters,
                          onSelectCategory: _selectPhotoType,
                        ),
                      ),
                      const SizedBox(width: 26),
                      Expanded(child: _buildMainContent(context)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ExploreSidebar(
                        searchController: _searchController,
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        onSearchChanged: (_) => _applyFilters(),
                        onSearchPressed: _applyFilters,
                        onSelectCategory: _selectPhotoType,
                      ),
                      const SizedBox(height: 18),
                      _buildMainContent(context),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'Jelajahi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),
            Text(
              '${_visiblePosts.length} postingan',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          )
        else if (_error != null)
          _StateCard(
            title: 'Explore belum tersedia',
            message: _error!,
            actionLabel: 'Muat ulang',
            onTap: _loadData,
          )
        else if (_visiblePosts.isEmpty)
          _StateCard(
            title: 'Tidak ada hasil',
            message: 'Coba kata kunci lain atau pilih tipe foto yang berbeda.',
            actionLabel: 'Reset',
            onTap: _resetFilters,
          )
        else
          MasonryGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: _columns(context),
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            itemCount: _visiblePosts.length,
            itemBuilder: (context, index) {
              final post = _visiblePosts[index];
              return _ExploreCard(
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
      ],
    );
  }
}

class SimplePage extends StatelessWidget {
  const SimplePage({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.accent),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreSidebar extends StatelessWidget {
  const _ExploreSidebar({
    required this.searchController,
    required this.categories,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onSearchPressed,
    required this.onSelectCategory,
  });

  final TextEditingController searchController;
  final List<KategoriModel> categories;
  final KategoriModel? selectedCategory;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchPressed;
  final ValueChanged<KategoriModel?> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120A0A0A),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari postingan...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                  filled: true,
                  fillColor: AppColors.cream,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onSearchPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Cari'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120A0A0A),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Text(
                  'TIPE FOTO',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.warmGray),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _SidebarCategoryItem(
                      label: 'Semua',
                      active: selectedCategory == null,
                      onTap: () => onSelectCategory(null),
                    ),
                    ...categories.map(
                      (category) => _SidebarCategoryItem(
                        label: category.name,
                        active: selectedCategory?.id == category.id,
                        onTap: () => onSelectCategory(category),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarCategoryItem extends StatelessWidget {
  const _SidebarCategoryItem({
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
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? AppColors.accent : AppColors.midGray,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({
    required this.post,
    required this.onTap,
  });

  final PostModel post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = post.firstPhoto?.url ??
        'https://via.placeholder.com/600x800?text=No+Image';

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120A0A0A),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(22)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                if (post.photos.length > 1)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_library_outlined,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.photos.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
                  const SizedBox(height: 10),
                  Text(
                    post.caption?.trim().isNotEmpty == true
                        ? post.caption!
                        : 'Tanpa caption',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.black,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite_border_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likesCount}',
                        style: const TextStyle(color: AppColors.accent),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.mode_comment_outlined,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentsCount}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
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

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.explore_outlined, size: 42, color: AppColors.muted),
          const SizedBox(height: 14),
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
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: Colors.white,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

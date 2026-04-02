import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:aperturely_app/app/models/post_model.dart';
import 'package:aperturely_app/app/models/kategori_model.dart';
import 'package:aperturely_app/app/models/komentar_model.dart';
import 'package:aperturely_app/app/models/foto_model.dart';
import 'package:aperturely_app/app/models/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ──────────────────────────────────────────────
// DESIGN TOKENS
// ──────────────────────────────────────────────

class AppColors {
  static const black      = Color(0xFF0A0A0A);
  static const white      = Color(0xFFFFFFFF);
  static const cream      = Color(0xFFF9F7F4);
  static const warmGray   = Color(0xFFE8E4DF);
  static const midGray    = Color(0xFFB8B3AC);
  static const muted      = Color(0xFF888077);
  static const accent     = Color(0xFFC8533A);
  static const accentHover= Color(0xFFA83F28);
  static const accentSoft = Color(0xFFF5ECE9);
}

// ──────────────────────────────────────────────
// API CONFIG
// ──────────────────────────────────────────────

const String _baseUrl = 'http://127.0.0.1:8000';

// ──────────────────────────────────────────────
// API SERVICE
// ──────────────────────────────────────────────

class ApiService {
  static Future<List<KategoriModel>> fetchKategori() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/api/kategori'),
      headers: {'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List list = data is List ? data : (data['data'] ?? []);
      return list.map((j) => KategoriModel.fromJson(j)).toList();
    }
    throw Exception('Gagal memuat kategori: ${res.statusCode}');
  }

  static Future<List<PostModel>> fetchPosts({int? kategoriId, String? search, int page = 1}) async {
    final params = <String, String>{
      'page': '$page',
      if (kategoriId != null) 'kategori_id': '$kategoriId',
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final uri = Uri.parse('$_baseUrl/api/posts').replace(queryParameters: params);
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List list = data is List ? data : (data['data'] ?? []);
      return list.map((j) => PostModel.fromJson(j)).toList();
    }
    throw Exception('Gagal memuat postingan: ${res.statusCode}');
  }

  static Future<PostModel> fetchPostDetail(int id) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/api/posts/$id'),
      headers: {'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return PostModel.fromJson(data is Map ? data['data'] ?? data : data);
    }
    throw Exception('Gagal memuat detail postingan: ${res.statusCode}');
  }

  static Future<List<PostModel>> fetchRelated(int postId, {int? kategoriId}) async {
    final params = <String, String>{
      if (kategoriId != null) 'kategori_id': '$kategoriId',
      'exclude': '$postId',
      'limit': '10',
    };
    final uri = Uri.parse('$_baseUrl/api/posts').replace(queryParameters: params);
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List list = data is List ? data : (data['data'] ?? []);
      return list
          .map((j) => PostModel.fromJson(j))
          .where((p) => p.id != postId)
          .toList();
    }
    return [];
  }

  static Future<bool> toggleLike(int postId) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/api/posts/$postId/like'),
      headers: {'Accept': 'application/json'},
    );
    return res.statusCode == 200;
  }

  static Future<KomentarModel?> postKomentar({
    required int postId,
    required String comment,
    int? replyId,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/api/posts/$postId/comments'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'comment': comment,
        if (replyId != null) 'reply_id': replyId,
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return KomentarModel.fromJson(data is Map ? data['data'] ?? data : data);
    }
    return null;
  }

  static Future<bool> deleteKomentar(int komentarId) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/api/comments/$komentarId'),
      headers: {'Accept': 'application/json'},
    );
    return res.statusCode == 200 || res.statusCode == 204;
  }
}

// ──────────────────────────────────────────────
// BERANDA SCREEN
// ──────────────────────────────────────────────

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  KategoriModel? _aktifKategori;
  bool _loading = true;
  bool _loadingKategori = true;
  String? _error;
  List<PostModel> _posts = [];
  List<KategoriModel> _kategoriList = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    _loadKategori();
    _loadPosts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadKategori() async {
    try {
      final list = await ApiService.fetchKategori();
      if (mounted) setState(() { _kategoriList = list; _loadingKategori = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingKategori = false);
    }
  }

  Future<void> _loadPosts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final posts = await ApiService.fetchPosts(
        kategoriId: _aktifKategori?.id,
        search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      );
      if (mounted) setState(() { _posts = posts; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _pilihKategori(KategoriModel? k) {
    setState(() => _aktifKategori = k);
    _loadPosts();
  }

  void _bukaDetail(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          postIndex: _posts.indexOf(post),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildFilterBar()),
        ],
        body: _error != null
            ? _buildError()
            : _loading
                ? _buildShimmer()
                : _buildGrid(),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.cream.withOpacity(0.92),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      floating: true,
      snap: true,
      toolbarHeight: 64,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.photo_camera_outlined,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Galeri',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'EXPLORE',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.muted,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.warmGray),
      ),
      actions: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              height: 40,
              constraints: const BoxConstraints(maxWidth: 300),
              decoration: BoxDecoration(
                color: AppColors.warmGray,
                borderRadius: BorderRadius.circular(40),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 14, color: AppColors.black),
                decoration: InputDecoration(
                  hintText: 'Cari postingan…',
                  hintStyle: TextStyle(color: AppColors.muted, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppColors.muted, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _loadPosts(),
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _NavIconBtn(icon: Icons.notifications_outlined, onTap: () {}),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextButton.icon(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Unggah',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  // ── Filter Bar ────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      height: 54,
      color: AppColors.cream,
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
      child: _loadingKategori
          ? _buildKategoriShimmer()
          : ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'Semua',
                  aktif: _aktifKategori == null,
                  onTap: () => _pilihKategori(null),
                ),
                ..._kategoriList.map((k) => _FilterChip(
                      label: k.name,
                      aktif: _aktifKategori?.id == k.id,
                      onTap: () => _pilihKategori(k),
                    )),
              ],
            ),
    );
  }

  Widget _buildKategoriShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Shimmer.fromColors(
          baseColor: AppColors.warmGray,
          highlightColor: const Color(0xFFF0EDE8),
          child: Container(
            width: 80,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warmGray,
              borderRadius: BorderRadius.circular(36),
            ),
          ),
        ),
      ),
    );
  }

  // ── Masonry Grid ──────────────────────────────────────────────
  Widget _buildGrid() {
    if (_posts.isEmpty) return _buildKosong();

    return RefreshIndicator(
      onRefresh: _loadPosts,
      color: AppColors.accent,
      child: MasonryGridView.count(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        crossAxisCount: _crossAxisCount(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: _posts.length,
        itemBuilder: (ctx, i) => _PostCard(
          post: _posts[i],
          index: i,
          onTap: () => _bukaDetail(_posts[i]),
        ),
      ),
    );
  }

  int _crossAxisCount(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w >= 1400) return 5;
    if (w >= 1100) return 4;
    if (w >= 800)  return 3;
    return 2;
  }

  // ── Error State ───────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.midGray, size: 48),
          const SizedBox(height: 16),
          const Text('Gagal memuat data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,
                  color: AppColors.black)),
          const SizedBox(height: 8),
          Text(_error ?? 'Periksa koneksi internet kamu',
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadPosts,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Coba Lagi',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ── Shimmer ───────────────────────────────────────────────────
  Widget _buildShimmer() {
    return MasonryGridView.count(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      crossAxisCount: _crossAxisCount(context),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: 10,
      itemBuilder: (_, i) {
        final heights = [180, 240, 200, 270, 220, 300, 190, 250, 210, 260];
        return Shimmer.fromColors(
          baseColor: AppColors.warmGray,
          highlightColor: const Color(0xFFF0EDE8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: heights[i % heights.length].toDouble(),
                decoration: BoxDecoration(
                  color: AppColors.warmGray,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          width: 24, height: 24,
                          decoration: const BoxDecoration(
                              color: AppColors.warmGray,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Container(width: 80, height: 11,
                          decoration: BoxDecoration(color: AppColors.warmGray,
                              borderRadius: BorderRadius.circular(6))),
                    ]),
                    const SizedBox(height: 8),
                    Container(width: double.infinity, height: 10,
                        decoration: BoxDecoration(color: AppColors.warmGray,
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 6),
                    Container(width: 120, height: 10,
                        decoration: BoxDecoration(color: AppColors.warmGray,
                            borderRadius: BorderRadius.circular(6))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Empty State ───────────────────────────────────────────────
  Widget _buildKosong() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                  blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.photo_camera_outlined,
                color: AppColors.midGray, size: 28),
          ),
          const SizedBox(height: 24),
          const Text('Belum Ada Foto',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500,
                  color: AppColors.black)),
          const SizedBox(height: 8),
          Text('Jadilah yang pertama mengunggah karya terbaikmu',
              style: TextStyle(fontSize: 14, color: AppColors.muted)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Unggah Foto',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// POST CARD WIDGET
// ──────────────────────────────────────────────

class _PostCard extends StatefulWidget {
  final PostModel post;
  final int index;
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.index,
    required this.onTap,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade  = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 60 * (widget.index % 8)), () {
      if (mounted) _ac.forward();
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit:  (_) => setState(() => _hovering = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(_hovering ? 0.15 : 0.07),
                  blurRadius: _hovering ? 36 : 8,
                  offset: Offset(0, _hovering ? 10 : 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildImage(post),
                  _buildBody(post),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(PostModel post) {
    // Gunakan URL foto pertama dari API
    final imageUrl = post.firstPhoto?.url;

    return Stack(
      children: [
        ClipRRect(
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Container(
                    height: 200,
                    color: AppColors.warmGray,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: AppColors.warmGray,
                    child: const Icon(Icons.broken_image_outlined,
                        color: AppColors.midGray, size: 32),
                  ),
                )
              : Container(
                  height: 200,
                  color: AppColors.warmGray,
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: AppColors.midGray, size: 32),
                ),
        ),
        // Multi-photo badge
        if (post.hasMultiPhoto)
          Positioned(
            top: 10, left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.collections_outlined,
                      color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text('${post.photos.length}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        // Hover overlay
        AnimatedOpacity(
          opacity: _hovering ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
            padding: const EdgeInsets.all(14),
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                _OverlayStatBadge(
                  icon: Icons.favorite_border,
                  count: post.likesCount,
                ),
                const SizedBox(width: 8),
                _OverlayStatBadge(
                  icon: Icons.chat_bubble_outline,
                  count: post.commentsCount,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(PostModel post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundImage:
                    CachedNetworkImageProvider(post.user.avatarDisplay),
                backgroundColor: AppColors.warmGray,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  post.user.displayName,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (post.caption != null) ...[
            const SizedBox(height: 7),
            Text(
              post.caption!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.45),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              _StatChip(icon: Icons.favorite_border_rounded,
                  count: post.likesCount, color: AppColors.accent),
              const SizedBox(width: 12),
              _StatChip(icon: Icons.chat_bubble_outline_rounded,
                  count: post.commentsCount, color: AppColors.muted),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// HALAMAN DETAIL POSTINGAN
// ──────────────────────────────────────────────

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  final int postIndex;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.postIndex,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late bool _isLiked;
  late int _likesCount;
  int _currentPhoto = 0;
  final _komentarCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  KomentarModel? _replyTo;
  List<KomentarModel> _komentar = [];
  bool _kirimingKomentar = false;

  List<PostModel> _related = [];
  bool _loadingRelated = false;

  // Detail post yang sudah di-fetch ulang dari API (lebih lengkap)
  PostModel? _detailPost;
  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    _isLiked    = widget.post.isLiked;
    _likesCount = widget.post.likesCount;
    _komentar   = List.from(widget.post.comments);
    _loadDetail();
    _loadRelated();
  }

  @override
  void dispose() {
    _komentarCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  PostModel get _post => _detailPost ?? widget.post;

  Future<void> _loadDetail() async {
    setState(() => _loadingDetail = true);
    try {
      final detail = await ApiService.fetchPostDetail(widget.post.id);
      if (mounted) {
        setState(() {
          _detailPost   = detail;
          _komentar     = List.from(detail.comments);
          _isLiked      = detail.isLiked;
          _likesCount   = detail.likesCount;
          _loadingDetail = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  Future<void> _loadRelated() async {
    setState(() => _loadingRelated = true);
    try {
      final list = await ApiService.fetchRelated(
        widget.post.id,
        kategoriId: widget.post.kategori?.id,
      );
      if (mounted) setState(() { _related = list; _loadingRelated = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingRelated = false);
    }
  }

  Future<void> _toggleLike() async {
    HapticFeedback.lightImpact();
    // Optimistic update
    setState(() {
      _isLiked    = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    final ok = await ApiService.toggleLike(_post.id);
    if (!ok && mounted) {
      // Revert jika gagal
      setState(() {
        _isLiked    = !_isLiked;
        _likesCount += _isLiked ? 1 : -1;
      });
    }
  }

  Future<void> _kirimKomentar() async {
    final text = _komentarCtrl.text.trim();
    if (text.isEmpty || _kirimingKomentar) return;

    setState(() => _kirimingKomentar = true);
    _komentarCtrl.clear();

    final komenBaru = await ApiService.postKomentar(
      postId: _post.id,
      comment: text,
      replyId: _replyTo?.id,
    );

    if (mounted) {
      setState(() {
        _kirimingKomentar = false;
        if (komenBaru != null) {
          if (_replyTo != null) {
            final idx = _komentar.indexWhere((k) => k.id == _replyTo!.id);
            if (idx >= 0) {
              final old = _komentar[idx];
              _komentar[idx] = KomentarModel(
                id: old.id, comment: old.comment, user: old.user,
                createdAt: old.createdAt, replyId: old.replyId,
                replies: [...old.replies, komenBaru],
              );
            }
          } else {
            _komentar.insert(0, komenBaru);
          }
        }
        _replyTo = null;
      });
    }
  }

  Future<void> _hapusKomentar(KomentarModel k) async {
    final ok = await ApiService.deleteKomentar(k.id);
    if (ok && mounted) {
      setState(() => _komentar.removeWhere((c) => c.id == k.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.cream.withOpacity(0.9),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.black, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Postingan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                    color: AppColors.black)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.warmGray),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: isWide
                  ? _buildWideLayout()
                  : _buildNarrowLayout(),
            ),
          ),

          if (!_loadingRelated && _related.isNotEmpty)
            SliverToBoxAdapter(child: _buildRelated()),

          if (_loadingRelated)
            SliverToBoxAdapter(child: _buildRelatedShimmer()),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildFotoSection(maxHeight: MediaQuery.of(context).size.height * 0.88),
        ),
        const SizedBox(width: 32),
        SizedBox(
          width: 420,
          child: _buildSidebar(),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildFotoSection(maxHeight: MediaQuery.of(context).size.width * 0.85),
        const SizedBox(height: 20),
        _buildSidebar(),
      ],
    );
  }

  Widget _buildFotoSection({required double maxHeight}) {
    final post = _post;

    // Ambil URL foto langsung dari FotoModel.url
    final photoUrls = post.photos.map((f) => f.url).toList();
    if (photoUrls.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.warmGray,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              color: AppColors.midGray, size: 40),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2),
              blurRadius: 40, offset: const Offset(0, 12))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (photoUrls.length > 1)
            PageView.builder(
              itemCount: photoUrls.length,
              onPageChanged: (i) => setState(() => _currentPhoto = i),
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: photoUrls[i],
                fit: BoxFit.contain,
                width: double.infinity,
                placeholder: (_, __) => Container(color: AppColors.black),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.warmGray,
                  child: const Icon(Icons.broken_image_outlined,
                      color: AppColors.midGray, size: 40),
                ),
              ),
            )
          else
            CachedNetworkImage(
              imageUrl: photoUrls[0],
              fit: BoxFit.contain,
              width: double.infinity,
              placeholder: (_, __) => Container(color: AppColors.black),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.warmGray,
                child: const Icon(Icons.broken_image_outlined,
                    color: AppColors.midGray, size: 40),
              ),
            ),

          if (post.hasMultiPhoto)
            Positioned(
              top: 14, left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.collections_outlined,
                        color: Colors.white, size: 13),
                    const SizedBox(width: 5),
                    Text('${_currentPhoto + 1} / ${photoUrls.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),

          if (photoUrls.length > 1)
            Positioned(
              bottom: 14,
              left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(photoUrls.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: i == _currentPhoto ? 18 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _currentPhoto
                        ? Colors.white
                        : Colors.white.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final post = _post;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07),
            blurRadius: 16, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSidebarHeader(post),
          _buildAuthorSection(post),
          _buildKomentarList(),
          _buildKomentarForm(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(PostModel post) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.warmGray)),
      ),
      child: Row(
        children: [
          _SidebarActionBtn(
            icon: _isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isLiked ? AppColors.accent : AppColors.muted,
            onTap: _toggleLike,
          ),
          const SizedBox(width: 4),
          _SidebarActionBtn(
            icon: Icons.more_horiz_rounded,
            color: AppColors.muted,
            onTap: () => _showMoreSheet(post),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(34)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              elevation: 0,
            ),
            child: const Text('Simpan',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorSection(PostModel post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundImage:
                    CachedNetworkImageProvider(post.user.avatarDisplay),
                backgroundColor: AppColors.warmGray,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.user.displayName,
                      style: const TextStyle(fontSize: 14.5,
                          fontWeight: FontWeight.w600, color: AppColors.black)),
                  Text(
                    timeago.format(post.createdAt, locale: 'id'),
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ],
          ),
          if (post.caption != null) ...[
            const SizedBox(height: 12),
            Text(post.caption!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.6)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(icon: Icons.favorite_border_rounded,
                  count: _likesCount, color: AppColors.accent),
              const SizedBox(width: 16),
              _StatChip(icon: Icons.chat_bubble_outline_rounded,
                  count: _komentar.length, color: AppColors.muted),
            ],
          ),
          if (post.kategori != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_offer_outlined,
                      size: 12, color: AppColors.accent),
                  const SizedBox(width: 5),
                  Text(post.kategori!.name,
                      style: const TextStyle(fontSize: 12,
                          color: AppColors.accent, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKomentarList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300, minHeight: 60),
      decoration: const BoxDecoration(
        border: Border.symmetric(
            horizontal: BorderSide(color: AppColors.warmGray)),
      ),
      child: _komentar.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Belum ada komentar. Jadilah yang pertama!',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                    textAlign: TextAlign.center),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemCount: _komentar.length,
              itemBuilder: (_, i) => _KomentarItem(
                komentar: _komentar[i],
                onReply: (k) => setState(() {
                  _replyTo = k;
                  _komentarCtrl.clear();
                }),
                onDelete: _hapusKomentar,
              ),
            ),
    );
  }

  Widget _buildKomentarForm() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyTo != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Membalas @${_replyTo!.user.displayName}',
                        style: const TextStyle(fontSize: 12.5,
                            color: AppColors.accent, fontWeight: FontWeight.w500)),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _replyTo = null),
                    child: const Icon(Icons.close, size: 16, color: AppColors.accent),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.warmGray,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: TextField(
                    controller: _komentarCtrl,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.black),
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar…',
                      hintStyle: TextStyle(color: AppColors.muted, fontSize: 13.5),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _kirimKomentar(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _komentarCtrl,
                builder: (_, v, __) => AnimatedOpacity(
                  opacity: v.text.trim().isNotEmpty ? 1 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: (v.text.trim().isNotEmpty && !_kirimingKomentar)
                        ? _kirimKomentar
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(64, 40),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: _kirimingKomentar
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Kirim',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelated() {
    final cat = _post.kategori;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Postingan Serupa',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500,
                      color: AppColors.black)),
              if (cat != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(cat.name,
                      style: const TextStyle(fontSize: 12, color: AppColors.accent,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          MasonryGridView.count(
            crossAxisCount: _relatedCols(context),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _related.length,
            itemBuilder: (_, i) => _PostCard(
              post: _related[i],
              index: i,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(
                      post: _related[i],
                      postIndex: i,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _relatedCols(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w >= 1400) return 5;
    if (w >= 1100) return 4;
    if (w >= 800)  return 3;
    return 2;
  }

  Widget _buildRelatedShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.warmGray,
            highlightColor: const Color(0xFFF0EDE8),
            child: Container(width: 180, height: 22,
                decoration: BoxDecoration(color: AppColors.warmGray,
                    borderRadius: BorderRadius.circular(6))),
          ),
        ],
      ),
    );
  }

  void _showMoreSheet(PostModel post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: AppColors.warmGray,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: AppColors.accent),
              title: const Text('Laporkan Postingan',
                  style: TextStyle(color: AppColors.accent)),
              onTap: () {
                Navigator.pop(context);
                // TODO: buka form laporan
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Bagikan'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// KOMENTAR ITEM
// ──────────────────────────────────────────────

class _KomentarItem extends StatelessWidget {
  final KomentarModel komentar;
  final void Function(KomentarModel) onReply;
  final void Function(KomentarModel) onDelete;

  const _KomentarItem({
    required this.komentar,
    required this.onReply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundImage:
                    CachedNetworkImageProvider(komentar.user.avatarDisplay),
                backgroundColor: AppColors.warmGray,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${komentar.user.displayName} ',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: AppColors.black),
                          ),
                          TextSpan(
                            text: komentar.comment,
                            style: const TextStyle(
                                fontSize: 13.5, color: Color(0xFF444444),
                                fontWeight: FontWeight.normal, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(timeago.format(komentar.createdAt, locale: 'id'),
                            style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => onReply(komentar),
                          child: const Text('Balas',
                              style: TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted)),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => onDelete(komentar),
                          child: const Text('Hapus',
                              style: TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (komentar.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 8),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                      left: BorderSide(color: AppColors.warmGray, width: 2)),
                ),
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  children: komentar.replies
                      .map((r) => _KomentarItem(
                          komentar: r, onReply: onReply, onDelete: onDelete))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SMALL REUSABLE WIDGETS
// ──────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: aktif ? AppColors.black : AppColors.white,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: aktif ? AppColors.black : AppColors.warmGray,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: aktif ? Colors.white : AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _StatChip({required this.icon, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text('$count',
            style: TextStyle(fontSize: 12.5, color: color,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _OverlayStatBadge extends StatelessWidget {
  final IconData icon;
  final int count;

  const _OverlayStatBadge({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text('$count',
              style: const TextStyle(color: Colors.white, fontSize: 11.5,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _NavIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: AppColors.black, size: 22),
      onPressed: onTap,
      splashRadius: 20,
    );
  }
}

class _SidebarActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SidebarActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: 22),
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
        minimumSize: const Size(38, 38),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// ──────────────────────────────────────────────
// MAIN
// ──────────────────────────────────────────────

void main() {
  runApp(const _TestApp());
}

class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galeri',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          background: AppColors.cream,
        ),
        useMaterial3: true,
        fontFamily: 'DM Sans',
      ),
      home: const BerandaScreen(),
    );
  }
}
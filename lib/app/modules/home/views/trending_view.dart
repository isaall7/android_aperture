import 'package:aperturely_app/app/models/post_model.dart';
import 'package:aperturely_app/app/modules/home/views/dashboard_view.dart';
import 'package:aperturely_app/app/modules/home/views/profile_view.dart';
import 'package:aperturely_app/app/services/post_service.dart';
import 'package:aperturely_app/app/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aperturely_app/app/modules/home/views/explore_view.dart';

class TrendingView extends StatefulWidget {
  const TrendingView({super.key});

  @override
  State<TrendingView> createState() => _TrendingViewState();
}

class _TrendingViewState extends State<TrendingView> {
  final PostService _postService = PostService();
  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  Future<void> _loadTrending() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final posts = await _postService.fetchPosts();
      posts.sort(
        (a, b) => ((b.likesCount + (b.commentsCount * 2)))
            .compareTo(a.likesCount + (a.commentsCount * 2)),
      );
      setState(() {
        _posts = posts.take(10).toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Trending belum bisa dimuat dari API.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        title: const Text('Trending'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrending,
        color: AppColors.accent,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.local_fire_department_outlined,
                    color: AppColors.accent,
                    size: 34,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Trending hari ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Postingan dipilih dari kombinasi likes dan komentar, mengikuti pola website.',
                    style: TextStyle(color: Color(0xFFD0CBC4), height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              )
            else if (_error != null)
              SimplePage(
                title: 'Trending',
                description: _error!,
                icon: Icons.local_fire_department_outlined,
              )
            else
              ..._posts.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final post = entry.value;
                final score = post.likesCount + (post.commentsCount * 2);
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: InkWell(
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
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '#$rank',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: post.firstPhoto?.url ??
                                'https://via.placeholder.com/120x120?text=No+Image',
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProfileView(user: post.user),
                                  ),
                                ),
                                child: Text(
                                  post.user.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                post.caption?.trim().isNotEmpty == true
                                    ? post.caption!
                                    : 'Tanpa caption',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.black,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 6,
                                children: [
                                  Text(
                                    '${post.likesCount} suka',
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${post.commentsCount} komentar',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'skor $score',
                                    style: const TextStyle(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
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
              }),
          ],
        ),
      ),
    );
  }
}

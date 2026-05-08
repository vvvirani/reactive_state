import 'package:dio/dio.dart';
import 'package:example/models/post.dart';
import 'package:flutter/material.dart';
import 'package:reactive_state/reactive_state.dart';

class PaginationListViewPage extends StatefulWidget {
  const PaginationListViewPage({super.key});

  @override
  State<PaginationListViewPage> createState() => _PaginationListViewPageState();
}

class _PaginationListViewPageState extends State<PaginationListViewPage> {
  final PostController _postController = PostController();

  @override
  void initState() {
    super.initState();
    _postController.init();
  }

  @override
  void dispose() {
    super.dispose();
    _postController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pagination List View')),
      body: Watch(
        builder: () {
          PaginationState<Post> state = _postController.state;

          return state.isLoading
              ? Center(child: CircularProgressIndicator.adaptive())
              : SingleChildScrollView(
                  controller: _postController.scrollController,
                  child: Column(
                    children: [
                      ListView.separated(
                        itemCount: state.items.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                        ).copyWith(top: 10, bottom: 40),
                        itemBuilder: (context, index) {
                          Post post = state.items[index];
                          return Card(
                            child: ListTile(
                              title: Text(post.title),
                              subtitle: Text(post.body),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 10);
                        },
                      ),
                      if (state.isMoreLoading)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}

class PostController {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),
  );

  late ReactivePagination<Post> _postsPagination;

  final ScrollController _scrollController = ScrollController();

  PostController() {
    _postsPagination = ReactivePagination<Post>(
      perPage: 10,
      fetcher: (int page, int perPage) async {
        final Response<List<dynamic>> res = await _dio.get(
          '/posts',
          queryParameters: {'_page': page, '_limit': perPage},
        );
        return res.data?.map((e) => Post.fromMap(e)).toList() ?? [];
      },
    );
  }

  void init() {
    _postsPagination.init();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final double threshold = 200.0;

    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;

    final bool shouldLoadMore = currentScroll >= (maxScroll - threshold);

    if (shouldLoadMore &&
        !state.isMoreLoading &&
        state.hasMore &&
        !state.isLoading) {
      _postsPagination.fetchMore();
    }
  }

  void dispose() {
    _scrollController.removeListener(_onScroll);
    _postsPagination.refresh();
  }

  PaginationState<Post> get state => _postsPagination.state;

  ScrollController get scrollController => _scrollController;
}

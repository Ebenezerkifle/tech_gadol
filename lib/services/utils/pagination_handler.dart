class PaginationHandler {
  int totalPage;
  int currentPage;
  int limit;

  PaginationHandler({
    this.currentPage = 1,
    this.totalPage = 1,
    this.limit = 10,
  });

  bool get lastPage => currentPage == totalPage;

  PaginationHandler copyWith({var currentPage, var totalPage, var limit}) {
    return PaginationHandler()
      ..currentPage = currentPage ?? this.currentPage
      ..totalPage = totalPage ?? this.totalPage
      ..limit = limit ?? this.limit;
  }

  static String addQueryParameters(
    String url, {
    required Map<String, dynamic> queryParameters,
  }) {
    for (var ele in queryParameters.entries) {
      if (url.contains('?')) {
        url += '&';
      } else {
        url += '?';
      }
      url += '${ele.key}=${ele.value}';
    }
    return url;
  }
}

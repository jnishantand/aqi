import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/providers/newsProvider/newsProviders.dart';
import 'package:getaqi/ui/news/news_details.dart';

class AqiNewsWidget extends ConsumerWidget {
  const AqiNewsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(aqiNewsProvider);

    return newsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading news')),
      data: (newsList) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: news.image.isNotEmpty
                    ? Image.network(news.image, width: 60, fit: BoxFit.cover)
                    : const Icon(Icons.article),
                title: Text(news.title),
                subtitle: Text(news.source),
                onTap: () {
                  // later you can open URL using url_launcher
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NewsWebView(newsUrl: news.url),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

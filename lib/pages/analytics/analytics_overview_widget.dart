import 'package:cached_network_image/cached_network_image.dart';
import 'package:dellenhauer_admin/api_service.dart';
import 'package:dellenhauer_admin/model/article/article_model.dart';
import 'package:dellenhauer_admin/model/requests/analytics_model.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class AnalyticsOverviewWidget extends StatefulWidget {
  final List<AnalyticsModel> articles;
  final String heading;
  final String type;

  const AnalyticsOverviewWidget({
    super.key,
    required this.type,
    required this.articles,
    required this.heading,
  });

  @override
  State<AnalyticsOverviewWidget> createState() =>
      _AnalyticsOverviewWidgetState();
}

class _AnalyticsOverviewWidgetState extends State<AnalyticsOverviewWidget> {
  final ApiService _apiService = ApiService();

  IconData iconData() {
    switch (widget.type) {
      case 'article_opened':
        return FontAwesomeIcons.solidHandPointUp;
      case 'article_liked':
        return FontAwesomeIcons.solidHeart;
      case 'article_view_duration':
        return FontAwesomeIcons.solidEye;
      case 'article_share':
        return FontAwesomeIcons.share;
      case 'channel_join':
        return FontAwesomeIcons.userPlus;
      case 'article_downloaded':
        return FontAwesomeIcons.download;
      default:
        return FontAwesomeIcons.circleXmark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.heading,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5, bottom: 15),
          height: 3,
          width: 50,
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        widget.articles.isNotEmpty
            ? SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount:
                      widget.articles.length > 5 ? 5 : widget.articles.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    if (widget.articles[index].articleId != null &&
                        !widget.articles[index].articleId!
                            .contains('(not set)')) {
                      return buildSingleItem(
                        item: widget.articles[index],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              )
            : SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        iconData(),
                        size: 20,
                        color: kPrimaryColor,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.type == 'channel_join'
                            ? 'No joined channel data'
                            : 'No articles',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget buildSingleItem({
    required AnalyticsModel item,
  }) {
    return FutureBuilder<ArticleModel?>(
      future: _apiService.getSingleData(articleId: item.articleId!),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: snapshot.data!.previewImage!,
                  placeholder: (context, url) {
                    return Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/placeholder.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/placeholder.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data!.headline ?? '',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                          fontFamily: 'Poppins',
                          color: Color(0xff212121),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        snapshot.data!.subheadline ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                          fontFamily: 'Francois',
                          color: Color(0xff818181),
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  iconData(),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  item.count.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          );
        } else if (snapshot.hasData && snapshot.data == null) {
          return Container();
        }
        return Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.7),
          highlightColor: Colors.grey.withOpacity(0.4),
          child: Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 10),
            color: Colors.grey.withOpacity(0.7),
            width: double.infinity,
          ),
        );
      },
    );
  }
}

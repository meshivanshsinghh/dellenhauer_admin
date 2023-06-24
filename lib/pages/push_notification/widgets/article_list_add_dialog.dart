import 'package:dellenhauer_admin/pages/push_notification/model/push_notification_article_model.dart';
import 'package:dellenhauer_admin/pages/push_notification/push_notification_article_provider.dart';
import 'package:dellenhauer_admin/pages/push_notification/widgets/shimmer_image.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ArticleListAddDialog extends StatefulWidget {
  const ArticleListAddDialog({super.key});

  @override
  State<ArticleListAddDialog> createState() => _ArticleListAddDialogState();
}

class _ArticleListAddDialogState extends State<ArticleListAddDialog> {
  late PushNotificationArticleProvider articleProvider;
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<PushNotificationArticleModel>? _searchedArticles;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      articleProvider.attachContext(context);
      articleProvider.setLoading(true);
      articleProvider.getArticleData().whenComplete(() {
        articleProvider.setLoading(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    articleProvider =
        Provider.of<PushNotificationArticleProvider>(context, listen: true);
    return FractionallySizedBox(
      heightFactor: 0.85,
      widthFactor: 0.85,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: articleProvider.loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                )
              : articleProvider.articleData.isEmpty
                  ? emptyPage(FontAwesomeIcons.book, 'No article found...')
                  : Column(
                      children: [
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(
                              height: 50,
                              margin: const EdgeInsets.only(top: 10),
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                cursorColor: kPrimaryColor,
                                focusNode: _focusNode,
                                controller: _textEditingController,
                                style: const TextStyle(color: Colors.black54),
                                onChanged: _updateSearchQuery,
                                decoration: InputDecoration(
                                  suffixIcon: _textEditingController
                                          .text.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _textEditingController.clear();
                                              _focusNode.unfocus();
                                              _searchedArticles = null;
                                            });
                                          },
                                          icon: const Icon(
                                            FontAwesomeIcons.solidCircleXmark,
                                            size: 20,
                                            color: kPrimaryColor,
                                          ),
                                        )
                                      : null,
                                  hintText: 'Search Article here...',
                                  hintStyle: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  fillColor:
                                      const Color.fromRGBO(232, 232, 232, 1),
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  prefixIcon: const Icon(
                                    FontAwesomeIcons.magnifyingGlass,
                                    size: 16,
                                    color: kPrimaryColor,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.redAccent),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            )),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _searchedArticles?.length ??
                                articleProvider.articleData.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              PushNotificationArticleModel currentArticle =
                                  (_searchedArticles ??
                                      articleProvider.articleData)[index];

                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 0, top: 0, bottom: 0, right: 5),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // preview image
                                        Stack(
                                          children: [
                                            SizedBox(
                                                width: 140,
                                                height: 140,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    child: ShimmerImage.network(
                                                      currentArticle
                                                              .previewImage ??
                                                          '',
                                                    ),
                                                  ),
                                                )),
                                            if (currentArticle.video != null)
                                              Positioned(
                                                left: 12,
                                                top: 15,
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    padding: EdgeInsets.only(
                                                      left: currentArticle
                                                                  .video !=
                                                              null
                                                          ? 3
                                                          : 0,
                                                    ),
                                                    child: Icon(
                                                      currentArticle.video !=
                                                              null
                                                          ? CupertinoIcons
                                                              .play_fill
                                                          : CupertinoIcons
                                                              .music_note_2,
                                                      size: 18,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        // text
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                              bottom: 0,
                                              left: 10,
                                              right: 0,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (true) ...[
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      currentArticle.category!
                                                          .map((e) => e.name)
                                                          .toString()
                                                          .replaceAll('(', '')
                                                          .replaceAll(')', ''),
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xff4d4d4d),
                                                        fontFamily: 'Inter',
                                                        fontSize: 12,
                                                        letterSpacing: 0.5,
                                                      ),
                                                      maxLines: 2,
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                ],
                                                Text(
                                                  currentArticle.headline ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.3,
                                                    fontFamily: 'Francois',
                                                    color: Color(0xff212121),
                                                  ),
                                                  maxLines: 2,
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  currentArticle.subheadline ??
                                                      '',
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
                                        ),
                                        // add to list
                                        Checkbox(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          activeColor: kPrimaryColor,
                                          value:
                                              articleProvider.selectedArticle !=
                                                      null &&
                                                  articleProvider
                                                          .selectedArticle!
                                                          .id ==
                                                      currentArticle.id,
                                          onChanged: (value) {
                                            if (value != null &&
                                                value == true) {
                                              articleProvider
                                                  .setSelectedArticle(
                                                currentArticle,
                                              );
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  void _updateSearchQuery(String newQuery) {
    _searchQuery = newQuery;

    if (_searchQuery.isEmpty) {
      _searchedArticles = null;
    } else {
      _searchedArticles = articleProvider.articleData
          .where((article) => article.headline!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {});
  }
}

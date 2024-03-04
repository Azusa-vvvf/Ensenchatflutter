import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';

const locale = Locale("ja", "JP");

//独自のマテリアルカラーを定義
const MaterialColor EnsenColor = const MaterialColor(
  0xFF001E46,
  const <int, Color>{
    50: const Color(0xFF001E46),
    100: const Color(0xFF001E46),
    200: const Color(0xFF001E46),
    300: const Color(0xFF001E46),
    400: const Color(0xFF001E46),
    500: const Color(0xFF001E46),
    600: const Color(0xFF001E46),
    700: const Color(0xFF001E46),
    800: const Color(0xFF001E46),
    900: const Color(0xFF001E46),
  },
);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        // localizations delegateを追加
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // 英語
        const Locale('ja', 'JP'), // 日本語
        // ... 他のlocaleを追加
      ],
      // ...
      title: '沿線ちゃっと',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: EnsenColor,
          accentColor: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF001E46),
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: "NotoSansJP",
        textTheme: TextTheme(
          bodyText1: TextStyle(fontFamily: "NotoSansJP", color: Colors.black),
          bodyText2: TextStyle(fontFamily: "NotoSansJP", color: Colors.black),
          headline6: TextStyle(fontFamily: "NotoSansJP", fontSize: 20, fontWeight: FontWeight.bold),
          subtitle1: TextStyle(fontFamily: "NotoSansJP", color: Colors.black),
          subtitle2: TextStyle(fontFamily: "NotoSansJP", color: Colors.black),
        ),
        primaryTextTheme: TextTheme(
          bodyText1: TextStyle(fontFamily: "NotoSansJP", color: Colors.white),
          bodyText2: TextStyle(fontFamily: "NotoSansJP", color: Colors.white),
          headline6: TextStyle(fontFamily: "NotoSansJP", fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          subtitle1: TextStyle(fontFamily: "NotoSansJP", color: Colors.white),
          subtitle2: TextStyle(fontFamily: "NotoSansJP", color: Colors.white),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
        centerTitle: true,
      ),
      body: _buildTabContent(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'ちゃっと',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: '知恵袋',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: '記事',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      /**case 0:
        return EnsenTab();*/
      case 0:
        return ChatTab();
      case 1:
        return ChieTab();
      case 2:
        return SearchTab();
      case 3:
        return SettingsTab();
      default:
        return Container();
    }
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      /**case 0:
        return "Image:Image.asset(ensenchatlogo.jpg)";*/
      case 0:
        return 'ちゃっと';
      case 1:
        return '知恵袋';
      case 2:
        return '記事';
      case 3:
        return '設定';
      default:
        return '';
    }
  }
}


class ChatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://ensenchat.com/chat/',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}

class ChieTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://ensenchat.com/forum/%e7%9f%a5%e6%81%b5%e8%a2%8b/',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestArticles();
  }

  Future<void> _searchWordPress(String query) async {
    setState(() {
      _isLoading = true;
    });

    if (query.isEmpty) {
      await _fetchLatestArticles();
    } else {
      final response = await http.get(
        Uri.parse('https://ensenchat.com/wp-json/wp/v2/posts?per_page=100&page=1&_embed&search=$query'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = json.decode(response.body);
        });
      } else {
        print('Failed to load search results');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchLatestArticles() async {
    final response = await http.get(
        Uri.parse('https://ensenchat.com/wp-json/wp/v2/posts?per_page=100&page=1&_embed'));

    if (response.statusCode == 200) {
      setState(() {
        _searchResults = json.decode(response.body);
      });
    } else {
      print('Failed to load latest articles');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              //Text('最新記事100件から検索できます'),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '最新記事100件から検索',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _searchWordPress(_searchController.text);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _searchResults.isEmpty
                ? Center(child: Text('結果がありません'))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        var title = _searchResults[index]['title']['rendered'];
                        var imageUrl = _searchResults[index]['_embedded']['wp:featuredmedia'][0]['source_url'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArticleDetail(
                                  articleUrl: _searchResults[index]['link'],
                                  //articleTitle: title,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 191 / 100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}


class SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final packageInfo = snapshot.data;

          return SettingsList(
            sections: [
              SettingsSection(
                title: Text('アカウント'),
                tiles: [
                  SettingsTile(
                    leading: Icon(Icons.login),
                    title: Text('ログイン・アカウント'),
                    onPressed: (BuildContext context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewPageCustom(
                            customUrl: 'https://ensenchat.com/#/',
                            customTitle: '沿線ちゃっとにログイン',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
               SettingsSection(
                title: Text('アプリ情報'),
                tiles: [
                  SettingsTile(
                    title: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info),
                            SizedBox(width: 32),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('沿線ちゃっと'),
                                Text('©2024 沿線ちゃっと編集部'),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SettingsTile(
                    leading: Icon(Icons.android),
                    title: Text('バージョン \n${packageInfo!.version}'),
                    // onPressed: (BuildContext context) {},
                  ),

                  SettingsTile(
                    leading: Icon(Icons.assignment),
                    title: Text('ライセンス'),
                    onPressed: (BuildContext context) {
                      // ライセンスページを表示
                      showLicensePage(
                        context: context,
                      );
                    },
                  ),
                  SettingsTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('開発 ：沿線ちゃっと編集部'),
                    // onPressed: (BuildContext context) {},
                  ),
                ],
              ),
              SettingsSection(
                title: Text('サポート'),
                tiles: [
                  SettingsTile(
                    leading: Icon(Icons.verified),
                    title: Text('沿線ちゃっとのTwitterへ'),
                    onPressed: (BuildContext context) {
                      // 開発者のTwitterページにジャンプする
                      launch('https://twitter.com/ensenchat');
                    },
                  ),
                  SettingsTile(
                    leading: Icon(Icons.assignment),
                    title: Text('利用規約'),
                    onPressed: (BuildContext context) {
                      // 利用規約ページをWebView内で表示
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewPage(
                            url: 'https://ensenchat.com/terms/',
                            title: '利用規約',
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    leading: Icon(Icons.policy),
                    title: Text('プライバシーポリシー'),
                    onPressed: (BuildContext context) {
                      // 利用規約ページをWebView内で表示
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewPage(
                            url: 'https://ensenchat.com/privacy-policy/',
                            title: 'プライバシーポリシー',
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    leading: Icon(Icons.send),
                    title: Text('お問い合わせ'),
                    onPressed: (BuildContext context) {
                      // 利用規約ページをWebView内で表示
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewPage(
                            url: 'https://docs.google.com/forms/d/e/1FAIpQLScc7hW0snL4nCyuLI8mTd71m9y17Vtyxi8nEhWWO0rMiEgW2Q/viewform?embedded=true&pli=1',
                            title: 'お問い合わせ',
                          ),
                        ),
                      );
                    },
                  ),


                ],
              ),

              SettingsSection(
                title: Text('編集者向け'),
                tiles: [
                  SettingsTile(
                    leading: Icon(Icons.edit),
                    title: Text('ログイン'),
                    onPressed: (BuildContext context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewPageWithBack(
                            backUrl: 'https://ensenchat.com/wp-admin/',
                            backTitle: '管理画面',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class WebViewPageCustom extends StatelessWidget {
  final String customUrl;
  final String customTitle;

  WebViewPageCustom({required this.customUrl, required this.customTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customTitle),
      ),
      body: WebView(
        initialUrl: customUrl,
        javascriptMode: JavascriptMode.unrestricted, // JavaScriptを有効にする
      ),
    );
  }
}

class WebViewPageWithBack extends StatefulWidget {
  final String backUrl;
  final String backTitle;

  WebViewPageWithBack({required this.backUrl, required this.backTitle});

  @override
  _WebViewPageWithBackState createState() => _WebViewPageWithBackState();
}

class _WebViewPageWithBackState extends State<WebViewPageWithBack> {
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.backTitle),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (await _webViewController.canGoBack()) {
            _webViewController.goBack();
            return false;
          } else {
            return true;
          }
        },
        child: WebView(
          initialUrl: widget.backUrl,
          javascriptMode: JavascriptMode.unrestricted, // JavaScriptを有効にする
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController;
          },
        ),
      ),
    );
  }
}


class ArticleList extends StatefulWidget {
  @override
  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  final String apiUrl = 'https://ensenchat.com/wp-json/wp/v2/posts?per_page=100&page=1';
  List<Map<String, dynamic>> articles = [];

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          articles = data.map((article) {
            return {
              'title': article['title']['rendered'],
              'url': article['link'],
            };
          }).toList();
        });
      } else {
        print('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Column(
          children: [
            ListTile(
              title: Text(article['title']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetail(articleUrl: article['url']),
                  ),
                );
              },
            ),
            Divider(), // 枠線を追加
          ],
        );
      },
    );
  }
}

class ArticleDetail extends StatelessWidget {
  final String articleUrl;

  ArticleDetail({required this.articleUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('記事'),
      ),
      body: WebView(
        initialUrl: articleUrl,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  WebViewPage({required this.url, required this.title});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _canGoBack()) {
          _goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
        ),
      ),
    );
  }

  Future<bool> _canGoBack() async {
    return await _webViewController.canGoBack();
  }

  void _goBack() {
    _webViewController.goBack();
  }
}
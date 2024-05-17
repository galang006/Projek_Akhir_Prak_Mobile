import 'package:pa_prak_mobile/latest_komik_model.dart';
import 'package:pa_prak_mobile/load_data_source.dart';
import 'package:pa_prak_mobile/page_detail_komik.dart';
import 'package:flutter/material.dart';
import 'package:pa_prak_mobile/page_search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageListLatestKomik extends StatefulWidget {
  const PageListLatestKomik({Key? key}) : super(key: key);
  @override
  State<PageListLatestKomik> createState() => _PageListLatestKomikState();
}

class _PageListLatestKomikState extends State<PageListLatestKomik> {
  int currentPage = 1;
  bool _isLoading = false;
  bool _isDarkTheme = false;
  //
  var appBarColor = Colors.white;
  var titleColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      appBarColor = _isDarkTheme ? Colors.black : Colors.white;
      titleColor = _isDarkTheme ? Colors.white : titleColor = Colors.black;
    });
  }

  Future<void> _saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: TextStyle(
            backgroundColor: appBarColor,
            color: titleColor,
          ),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: titleColor)
          ),
          onSubmitted: (value) {
            // Navigasi ke halaman hasil pencarian
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PageListSearchResult(text: value),
              ),
            );
          },
        ),
        backgroundColor: appBarColor,
        centerTitle: true,
        actions: [
          Switch(
            value: _isDarkTheme,
            onChanged: (value) {
              setState(() {
                _isDarkTheme = value;
                appBarColor = _isDarkTheme ? Colors.black : appBarColor = Colors.white;
                titleColor = _isDarkTheme ? Colors.white : titleColor = Colors.black;
                _saveTheme(_isDarkTheme);
              });
            },
            activeColor: Colors.white,
          ),
        ],
      ),
      //body: Text("Test"),
      body: _isLoading ? _buildLoadingSection() : _buildListLatestKomik(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (currentPage >
              1) // Tampilkan tombol "Back" jika nomor halaman lebih dari 1
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  currentPage--; // Kurangi nomor halaman
                });
                _loadPageKomik(currentPage);
              },
              child: Icon(Icons.arrow_back),
              backgroundColor: Color(0xFF994422),
            ),
          SizedBox(
              width:
                  20), // Berikan sedikit jarak antara tombol "Back" dan "Next"
          FloatingActionButton(
            onPressed: () {
              setState(() {
                currentPage++;
              });
              _loadPageKomik(currentPage);
            },
            child: Icon(Icons.arrow_forward),
            backgroundColor: Color(0xFF994422),
          ),
        ],
      ),
    );
  }

  Widget _buildListLatestKomik() {
    return Container(
      child: FutureBuilder(
        future: ApiDataSource.instance.loadLatestKomik(currentPage.toString()),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            // Jika data ada error maka akan ditampilkan hasil error
            return _buildErrorSection();
          }
          if (snapshot.hasData) {
            // Jika data ada dan berhasil maka akan ditampilkan hasil datanya
            LatestKomikModel latestKomikModel =
                LatestKomikModel.fromJson(snapshot.data);
            return _buildSuccessSection(latestKomikModel);
          }
          return _buildLoadingSection();
        },
      ),
    );
  }

  Widget _buildErrorSection() {
    return Text("Error");
  }

  Widget _buildLoadingSection() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildSuccessSection(LatestKomikModel data) {
    return ListView.builder(
      itemCount: data.data!.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildItemLatestKomik(data.data![index]);
      },
    );
  }

  Widget _buildItemLatestKomik(Data latestKomik) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PageDetailKomik(
                      idKomik: latestKomik.id!,
                    )));
      },
      child: Card(
          color: Color(0xFFF7EFF1),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  child: latestKomik.thumb != null
                      ? Image.network(latestKomik.thumb!)
                      : Placeholder(),
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      latestKomik.title!,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10), // Tambahkan jarak horizontal di sini
                      child: Text(
                        latestKomik.summary!,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
  void _loadPageKomik(int page) async {
    setState(() {
      _isLoading = true;
    });

    await ApiDataSource.instance.loadLatestKomik(currentPage.toString());

    setState(() {
      _isLoading = false;
    });
  }
}

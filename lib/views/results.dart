import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResultsPage extends StatefulWidget {
  final int id;
  const ResultsPage({Key? key, required this.id}) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late Future<Map<String, dynamic>> response;

  Future<Map<String, dynamic>> get(int id) async {
    Uri url = Uri.https('koeg.000webhostapp.com', 'sop/api.php/get',
        {"id": widget.id.toString()});
    http.Response response = await http.get(url);
    return jsonDecode(response.body);
  }

  void reload() {
    setState(() {
      response = get(widget.id);
    });
  }

  @override
  void initState() {
    response = get(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to the HomeScreen
        Navigator.popUntil(context, ModalRoute.withName('/'));

        // Prevent immediate back navigation
        return false;
      },
      child: FutureBuilder<Map<String, dynamic>>(
        future: response,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final images = snapshot.data!['images'];
            final name = snapshot.data!['name'];

            return Scaffold(
                appBar: AppBar(
                  title: Text('$name results'),
                  actions: [
                    IconButton(
                        onPressed: () {
                          reload();
                        },
                        icon: const Icon(Icons.refresh_rounded))
                  ],
                ),
                body: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ListView.builder(
                        itemCount: images.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ImageResults(
                            originId: int.parse(images[index]['origin_Id']),
                            fileName: images[index]['file_Name'],
                            score: int.parse(images[index]['votes']),
                            votesAmount:
                                int.parse(images[index]['votes_amount']),
                          );
                        }),
                  ),
                ));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}

class ImageResults extends StatefulWidget {
  final int originId;
  final String fileName;
  final int score;
  final int votesAmount;

  const ImageResults(
      {Key? key,
      required this.originId,
      required this.fileName,
      required this.score,
      required this.votesAmount})
      : super(key: key);

  @override
  State<ImageResults> createState() => _ImageResultsState();
}

class _ImageResultsState extends State<ImageResults> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                'http://koeg.000webhostapp.com/sop/images/${widget.originId}/${widget.fileName}',

                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width *
                    0.15, // set width to 90% of screen width
                height: null,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  int? expecdtByts = loadingProgress.expectedTotalBytes;
                  int? currentByts = loadingProgress.cumulativeBytesLoaded;
                  if (expecdtByts != null) {
                    var loadingProcent = currentByts / expecdtByts;
                    return Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.0001,
                        child: LinearProgressIndicator(
                          value: loadingProcent,
                        ),
                      ),
                    );
                  } else {
                    return child;
                  }
                },
              ),
            ),
          ),
          Text('Score:\n${widget.score}'),
          Text('Amount of votes:\n${widget.votesAmount}'),
          Text(
              'Percantage:\n${(((widget.score / widget.votesAmount) * 100 + 100) / 2).toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}

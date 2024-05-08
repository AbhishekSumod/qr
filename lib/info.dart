import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:japfood/ConvertedApi.dart';
import 'package:japfood/ProductDetailsPage.dart';
import 'dart:convert';

class Info extends StatefulWidget {
  final ConvertedApi apiList;

  const Info({
    Key? key,
    required this.apiList,
  }) : super(key: key);

  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  late List<ConvertedApi> itemList = [];

  @override
  void initState() {
    super.initState();
    getItemsByCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        title: Text(
          widget.apiList.CategoryName ?? '',
          style: TextStyle(color: Colors.white), // Set app bar text color
        ),
        backgroundColor: Colors.black, // Set app bar background color to black
        elevation: 0, // Remove app bar elevation
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white), // Set back button color
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Category: ${widget.apiList.CategoryName}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Set text color to white
                ),
              ),
            ),
            SizedBox(height: 20),
            itemList.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: itemList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsPage(product: itemList[index]),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: Colors
                              .white, // Set card background color to white
                          child: ListTile(
                            title: Text(
                              itemList[index].name ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Set text color to black
                              ),
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                itemList[index].Image ?? '',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            subtitle: Text(
                              'Price: ${itemList[index].price ?? 0}',
                              style: TextStyle(
                                color:
                                    Colors.black87, // Set text color to black87
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward,
                                color: Colors.black), // Set icon color to black
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> getItemsByCategory() async {
    String url =
        "http://localhost:3000/product?CategoryName=${widget.apiList.CategoryName}";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<ConvertedApi> tempItemList = [];
      (jsonDecode(response.body) as List).forEach((item) {
        ConvertedApi newItem = ConvertedApi.fromJson(item);
        if (newItem.CategoryName == widget.apiList.CategoryName) {
          tempItemList.add(newItem);
        }
      });
      setState(() {
        itemList = tempItemList;
      });
    } else {
      print("Failed to fetch data: ${response.statusCode}");
    }
  }
}

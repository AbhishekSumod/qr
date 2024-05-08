import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:japfood/CartProvider.dart';
import 'package:japfood/ConvertedApi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (context) => CartProvider(),
        child: CartPage(),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final String apiUrl = "http://localhost:3000/order";
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          Map<String?, List<ConvertedApi>> groupedItems = {};
          for (var item in cartProvider.cartItems) {
            if (!groupedItems.containsKey(item.CategoryName)) {
              groupedItems[item.CategoryName] = [];
            }
            groupedItems[item.CategoryName]?.add(item);
          }

          double totalPrice = 0;

          // Calculate total price
          for (var item in cartProvider.cartItems) {
            totalPrice += (item.price ?? 0) * (item.count ?? 1);
          }

          return ListView.builder(
            itemCount: groupedItems.length + 1,
            itemBuilder: (context, index) {
              if (index < groupedItems.length) {
                var categoryName = groupedItems.keys.toList()[index] ?? '';
                var items = groupedItems[categoryName]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        var item = items[index];
                        return CartItemWidget(
                          item: item,
                          onCountChanged: (count) {
                            setState(() {
                              item.count = count;
                            });
                          },
                        );
                      },
                    ),
                  ],
                );
              } else {
                return ListTile(
                  title: Text(
                    'Total Price:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    '₹${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Enter Username',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                final cartProvider =
                    Provider.of<CartProvider>(context, listen: false);
                placeOrder(context, cartProvider.cartItems);
              },
              child: Text('Order', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BillPage(
                      username: _usernameController.text,
                      cartItems:
                          Provider.of<CartProvider>(context, listen: false)
                              .cartItems,
                    ),
                  ),
                );
              },
              child: Text('Proceed to Payment',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> placeOrder(
      BuildContext context, List<ConvertedApi> cartItems) async {
    try {
      var username = _usernameController.text;
      var requestBody = jsonEncode(<String, dynamic>{
        'username': username,
        'cartItems': cartItems.map((item) => item.toJson()).toList(),
      });

      var response = await http.post(
        Uri.parse('$apiUrl'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      if (response.statusCode == 201) {
        print('Order placed successfully');
        Provider.of<CartProvider>(context, listen: false).clearCart();
      } else {
        print('Failed to place order: ${response.statusCode}');
      }
    } catch (error) {
      print('Error placing order: $error');
    }
  }
}

class BillPage extends StatelessWidget {
  final String username;
  final List<ConvertedApi> cartItems;

  BillPage({required this.username, required this.cartItems});
  @override
  Widget build(BuildContext context) {
    double totalBill = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bill',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: $username',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Ordered Items:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  var item = cartItems[index];
                  num itemSubtotal = (item.price ?? 0) * (item.count ?? 1);
                  totalBill += itemSubtotal;
                  return ListTile(
                    title: Text(
                      item.name ?? '',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity: ${item.count ?? 1}',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Price: ₹${item.price ?? 0}',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Subtotal: ₹${itemSubtotal.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Total Bill: ₹${totalBill.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement payment functionality
              },
              child: Text('Proceed to Payment',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemWidget extends StatefulWidget {
  final ConvertedApi item;
  final Function(int) onCountChanged;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onCountChanged,
  }) : super(key: key);

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(widget.item.name ?? '',
                style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              if (widget.item.count! > 1) {
                setState(() {
                  widget.onCountChanged(widget.item.count! - 1);
                });
              }
            },
          ),
          Text(widget.item.count?.toString() ?? '1',
              style: TextStyle(
                  color: Colors.white)), // Display '1' if count is null
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                widget.onCountChanged(
                    (widget.item.count ?? 0) + 1); // Increment count
              });
            },
          ),
        ],
      ),
      subtitle: Text(
        'Price: ₹${(widget.item.price ?? 0) * (widget.item.count ?? 1)}',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

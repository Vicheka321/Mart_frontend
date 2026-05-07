import 'package:flutter/material.dart';
import 'package:mart_frontend/models/products_model.dart';

import '../../services/api_service.dart';

class TestCartDataScreen extends StatelessWidget {
  const TestCartDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Cart Data"),
      ),

      body: FutureBuilder<MyCartModel>(
        future: ApiService().getCart(),

        builder: (context, snapshot) {

          if(snapshot.connectionState ==
             ConnectionState.waiting){
            return const Center(
              child:
                CircularProgressIndicator(),
            );
          }

          if(snapshot.hasError){
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          if(!snapshot.hasData ||
             snapshot.data!.items.isEmpty){
            return const Center(
              child: Text("Cart Empty"),
            );
          }

          final cart = snapshot.data!;

          return ListView.builder(
            itemCount: cart.items.length,

            itemBuilder:(context,index){

              final item =
                cart.items[index];

              return Card(
                margin:
                  const EdgeInsets.all(12),

                child: ListTile(
                  title: Text(
                    item.name,
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                      CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Product ID: ${item.productId}",
                      ),

                      Text(
                        "Qty: ${item.qty}",
                      ),

                      Text(
                        "Price: \$${item.price}",
                      ),

                      Text(
                        "Total: \$${item.totalPrice}",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
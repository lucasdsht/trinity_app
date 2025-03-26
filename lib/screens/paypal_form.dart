import 'package:flutter/material.dart';

class BillingPage extends StatefulWidget {
  final List cartItems;

  const BillingPage({super.key, required this.cartItems});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final _formKey = GlobalKey<FormState>();

  String fullName = '';
  String address = '';
  String city = '';
  String postalCode = '';
  String phone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Informations de facturation")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                onChanged: (value) => fullName = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Adresse'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                onChanged: (value) => address = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ville'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                onChanged: (value) => city = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Code postal'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                onChanged: (value) => postalCode = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                onChanged: (value) => phone = value,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text("Procéder au paiement"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    launchPayment(
                      context,
                      widget.cartItems,
                      billingInfo: {
                        "full_name": fullName,
                        "address": address,
                        "city": city,
                        "postal_code": postalCode,
                        "phone": phone,
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

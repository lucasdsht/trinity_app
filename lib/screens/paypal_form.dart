import 'package:flutter/material.dart';

class BillingFormPage extends StatefulWidget {
  final List cartItems;
  final Function(Map<String, dynamic>) onValidated;

  const BillingFormPage({
    super.key,
    required this.cartItems,
    required this.onValidated,
  });

  @override
  State<BillingFormPage> createState() => _BillingFormPageState();
}

class _BillingFormPageState extends State<BillingFormPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, String> billingInfo = {
    "full_name": "",
    "email": "",
    "address": "",
    "city": "",
    "postal_code": "",
    "country": "",
    "phone": "",
  };

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
              ..._buildTextField("Nom complet", "full_name"),
              ..._buildTextField("Email", "email", TextInputType.emailAddress),
              ..._buildTextField("Adresse", "address"),
              ..._buildTextField("Ville", "city"),
              ..._buildTextField(
                  "Code postal", "postal_code", TextInputType.number),
              ..._buildTextField("Pays", "country"),
              ..._buildTextField("Téléphone", "phone", TextInputType.phone),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text("Procéder au paiement"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onValidated(billingInfo);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTextField(String label, String fieldKey,
      [TextInputType? inputType]) {
    return [
      TextFormField(
        keyboardType: inputType,
        decoration: InputDecoration(labelText: label),
        validator: (value) => value!.isEmpty ? 'Champ requis' : null,
        onChanged: (value) => billingInfo[fieldKey] = value,
      ),
      const SizedBox(height: 10),
    ];
  }
}

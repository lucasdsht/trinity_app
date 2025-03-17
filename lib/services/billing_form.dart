 // View : le formulaire de facturation
 import 'package:flutter/material.dart';
import 'lib/services/billing_viewmodel.dart';

class BillingForm extends StatefulWidget {
  const BillingForm({super.key});

  @override
  _BillingFormState createState() => _BillingFormState();
}

class _BillingFormState extends State<BillingForm> {
  final _formKey = GlobalKey<FormState>();

  // On instancie le ViewModel pour gérer la logique métier.
  final BillingViewModel _viewModel = BillingViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Informations de facturation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Champ Prénom
              TextFormField(
                decoration: const InputDecoration(labelText: "Prénom"),
                onSaved: (value) => _viewModel.firstName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez saisir votre prénom";
                  }
                  return null;
                },
              ),
              // Champ Nom
              TextFormField(
                decoration: const InputDecoration(labelText: "Nom"),
                onSaved: (value) => _viewModel.lastName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez saisir votre nom";
                  }
                  return null;
                },
              ),
              // Champ Adresse
              TextFormField(
                decoration: const InputDecoration(labelText: "Adresse"),
                onSaved: (value) => _viewModel.address = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez saisir votre adresse";
                  }
                  return null;
                },
              ),
              // Champ Code postal
              TextFormField(
                decoration: const InputDecoration(labelText: "Code postal"),
                onSaved: (value) => _viewModel.zipCode = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez saisir votre code postal";
                  }
                  return null;
                },
              ),
              // Champ Ville
              TextFormField(
                decoration: const InputDecoration(labelText: "Ville"),
                onSaved: (value) => _viewModel.city = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez saisir votre ville";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Bouton pour déclencher le paiement
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Payer"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState!.save();

      // On délègue le paiement au ViewModel.
      bool paymentResult = await _viewModel.processPayment();
      if (paymentResult) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paiement initié avec succès!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'initiation du paiement.")),
        );
      }
    }
  }
}

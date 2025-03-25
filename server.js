require('dotenv').config();
const express = require('express');
const axios = require('axios');
const paypal = require('paypal-rest-sdk');

const app = express();
const port = 3000;

app.use(express.json());
//configuration
// Configure PayPal API
paypal.configure({
  mode: 'sandbox', // 'sandbox' pour le test, 'live' pour la production
  client_id: process.env.PAYPAL_CLIENT_ID,
  client_secret: process.env.PAYPAL_SECRET,
});

// Route pour créer un paiement sans redirection
app.post('/create-payment', async (req, res) => {
  try {
    const { firstName, lastName, address, zipCode, city, totalAmount } = req.body;

    // Logique pour traiter les informations de facturation et montant
    const paymentData = {
      intent: 'sale',
      payer: {
        payment_method: 'credit_card',
        funding_instruments: [{
          credit_card: {
            type: 'VISA',
            number: '4111111111111111', // Exemple de numéro de carte
            expire_month: '12',
            expire_year: '2025',
            cvv2: '123',
          },
        }],
      },
      transactions: [{
        amount: {
          total: totalAmount.toString(),
          currency: 'EUR',
        },
        description: 'Paiement direct sans redirection vers PayPal',
      }],
    };

    paypal.payment.create(paymentData, function (error, payment) {
      if (error) {
        console.error('Erreur PayPal:', error);
        res.status(500).json({ error: 'Erreur lors de la création du paiement.' });
      } else {
        res.status(200).json({
          success: true,
          paymentDetails: payment,
        });
      }
    });
  } catch (error) {
    console.error('Erreur serveur:', error);
    res.status(500).json({ error: 'Erreur lors de la création du paiement.' });
  }
});

// Démarre le serveur
app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});

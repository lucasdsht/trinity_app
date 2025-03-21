// Importer Express
const express = require('express');
const app = express();
const port = 8000;  // Vous pouvez changer le port si nécessaire

// Page de succès (redirection après paiement réussi)
app.get('/payment-success', (req, res) => {
  res.send('<h1>Paiement réussi !</h1><p>Votre paiement a été effectué avec succès.</p>');
});

// Page d'annulation (redirection après annulation de paiement)
app.get('/payment-cancel', (req, res) => {
  res.send('<h1>Paiement annulé</h1><p>Le paiement a été annulé.</p>');
});

// Démarrer le serveur
app.listen(port, () => {
  console.log(`Serveur en écoute sur http://localhost:${port}`);
});

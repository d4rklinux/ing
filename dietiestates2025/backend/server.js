const express = require('express');
require('dotenv').config();

const app = express();
app.disable('x-powered-by');
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Middleware per l'autenticazione (opzionale)
const authenticate = (req, res, next) => {
    // Logica di autenticazione (ad esempio, verifica del token JWT)
    next(); // Passa alla rotta successiva
};

// Importa le rotte
app.use('/utente', require('./routes/utenteRoutes'));
app.use('/ruolo', require('./routes/ruoloRoutes'));
app.use('/indirizzo', require('./routes/indirizzoRoutes'));
app.use('/filtro', require('./routes/filtroAvanzatoRoutes'));
app.use('/servizio', require('./routes/servizioUlterioreRoutes'));
app.use('/immobile', require('./routes/immobileRoutes'));
app.use('/foto', require('./routes/fotoRoutes'));
app.use('/modifica', require('./routes/modificaRoutes'));
app.use('/proposta', require('./routes/propostaRoutes'));
app.use('/visita', require('./routes/visitaRoutes'));
app.use('/ricerca', require('./routes/ricercaRoutes'));
app.use('/geoapify', require('./routes/geoapifyRoutes'));

// Middleware per gestire errore 404 - Not Found
app.use((req, res, next) => {
    res.status(404).json({ error: 'Risorsa non trovata' });
});

// Middleware per la gestione degli errori
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Errore interno del server', message: err.message });
});

// Verifica variabili di ambiente
if (!process.env.PORT) {
    console.error('Porta non definita nel file .env');
    process.exit(1);
}

// Avvio del server
app.listen(PORT, () => {
    console.log(`Server avviato su http://localhost:${PORT}`);
});

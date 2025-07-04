const { Pool } = require('pg');
require('dotenv').config();

// Configura la connessione al database PostgreSQL
const pool = new Pool({
    user: process.env.DB_USER,         // Carica DB_USER da .env
    host: process.env.DB_HOST,         // Carica DB_HOST da .env
    database: process.env.DB_DATABASE, // Carica DB_DATABASE da .env
    password: process.env.DB_PASSWORD, // Carica DB_PASSWORD da .env
    port: process.env.DB_PORT,         // Carica DB_PORT da .env
});

// Funzione di test della connessione al database
async function testConnection() {
    try {
        const res = await pool.query('SELECT NOW()');
        console.log('Database connesso:', res.rows[0]);
    } catch (err) {
        console.error('Errore di connessione al database:', err.message);
    }
}

// Verifica la connessione appena il modulo viene caricato
testConnection();

module.exports = pool;

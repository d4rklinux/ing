const express = require('express');
const cookieParser = require('cookie-parser');
const jwt = require('jsonwebtoken');
const pool = require('../db');
require('dotenv').config();
const router = express.Router();

// Usa cookie-parser per gestire i cookie
router.use(cookieParser());

// Secret per firmare il token (puoi sostituirlo con una variabile ambiente)
const JWT_SECRET = process.env.JWT_SECRET;

// Funzione per generare un token JWT
function generateToken(user) {
    return jwt.sign(
        { username: user.username_utente, idRuolo: user.id_ruolo },
        JWT_SECRET,
        { expiresIn: '1h' }  // Il token scade dopo 1 ora
    );
}

// Ottenere tutti gli utenti
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM utente');
        // Restituisce i dati con le stesse chiavi del modello Dart
        const utenti = result.rows.map(row => ({
            username: row.username_utente,
            password: row.password,
            idRuolo: row.id_ruolo,
            nome: row.nome,
            cognome: row.cognome,
            email: row.email
        }));
        res.json(utenti);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Creare un nuovo utente
router.post('/', async (req, res) => {
    try {
        const { username_utente, password, id_ruolo, nome, cognome, email } = req.body;
        await pool.query(
            `INSERT INTO utente (username_utente, password, id_ruolo, nome, cognome, email)
             VALUES ($1, $2, $3, $4, $5, $6)`,
            [username_utente, password, id_ruolo, nome, cognome, email]
        );
        res.status(201).json({ message: 'Utente creato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


// Ottenere un utente specifico
router.get('/:username', async (req, res) => {
    const { username } = req.params;
    try {
        const result = await pool.query('SELECT * FROM utente WHERE username_utente = $1', [username]);

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Utente non trovato' });
        }

        const user = result.rows[0];
        // Restituisci i dati con le chiavi corrette per Utente
        res.json({
            username: user.username_utente,
            password: user.password,
            idRuolo: user.id_ruolo,
            nome: user.nome,
            cognome: user.cognome,
            email: user.email
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Aggiornare un utente
router.put('/:username', async (req, res) => {
    const { username } = req.params;
    const { password, idRuolo, nome, cognome, email } = req.body;

    try {
        const result = await pool.query('SELECT * FROM utente WHERE username_utente = $1', [username]);

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Utente non trovato' });
        }

        await pool.query(
            `UPDATE utente
             SET password = $1, id_ruolo = $2, nome = $3, cognome = $4, email = $5
             WHERE username_utente = $6`,
            [password, idRuolo, nome, cognome, email, username]
        );
        res.status(200).json({ message: 'Utente aggiornato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Eliminare un utente
router.delete('/:username', async (req, res) => {
    const { username } = req.params;

    try {
        const result = await pool.query('SELECT * FROM utente WHERE username_utente = $1', [username]);

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Utente non trovato' });
        }

        await pool.query('DELETE FROM utente WHERE username_utente = $1', [username]);
        res.status(200).json({ message: 'Utente eliminato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

//Login
router.post('/login', async (req, res) => {
    const { username_utente, password } = req.body;

    try {
        const result = await pool.query(
            'SELECT * FROM utente WHERE username_utente = $1 AND password = $2',
            [username_utente, password]
        );

        if (result.rows.length > 0) {
            const user = result.rows[0];
            const token = generateToken(user);


            res.cookie('auth_token', token, {
                httpOnly: true,
                secure: process.env.NODE_ENV === 'production',
                maxAge: 3600000,
                sameSite: 'Strict',
                // Aggiungi path esplicito
                path: '/',
                // Formato compatibile
                expires: new Date(Date.now() + 3600000)
            });

            // Rimuovi la password dalla risposta
            const { password: _, ...userData } = user;
            res.status(200).json({
                ...userData,
                token // Invia anche nel body
            });
        } else {
            res.status(401).json({ message: 'Credenziali non valide' });
        }
    } catch (err) {
        console.error('Errore login:', err);
        res.status(500).json({ message: 'Errore interno' });
    }
});


// Middleware per verificare il token
function verifyToken(req, res, next) {
    const token = req.cookies.auth_token;
    if (!token) {
        return res.status(401).json({ message: 'Non autenticato' });
    }

    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ message: 'Token non valido o scaduto' });
        }
        req.user = decoded; // Aggiunge l'utente decodificato alla richiesta
        next();
    });
}

// Proteggere una rotta con la verifica del token
router.get('/profile', verifyToken, async (req, res) => {
    const username = req.user.username;

    try {
        const result = await pool.query('SELECT * FROM utente WHERE username_utente = $1', [username]);
        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Utente non trovato' });
        }
        const user = result.rows[0];
        res.json({
            username: user.username_utente,
            nome: user.nome,
            cognome: user.cognome,
            email: user.email,
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Cambio password
router.post('/change-password', async (req, res) => {
    const { username_utente, oldPassword, newPassword } = req.body;

    if (!username_utente || !oldPassword || !newPassword) {
        return res.status(400).json({ message: 'Tutti i campi sono obbligatori' });
    }

    try {
        const result = await pool.query(
            'SELECT password FROM utente WHERE username_utente = $1',
            [username_utente]
        );

        if (result.rowCount === 0) {
            return res.status(404).json({ message: 'Utente non trovato' });
        }

        const currentPassword = result.rows[0].password;

        if (currentPassword !== oldPassword) {
            return res.status(401).json({ message: 'La vecchia password non è corretta' });
        }

        await pool.query(
            'UPDATE utente SET password = $1 WHERE username_utente = $2',
            [newPassword, username_utente]
        );

        res.status(200).json({ message: 'Password aggiornata con successo' });
    } catch (err) {
        console.error('Errore cambio password:', err);
        res.status(500).json({ message: 'Errore interno' });
    }
});

// Logout - Rimuovere il cookie
router.post('/logout', (req, res) => {
    res.clearCookie('auth_token'); // Rimuove il cookie
    res.status(200).json({ message: 'Logout riuscito' });
});

module.exports = router;
const express = require('express');
const pool = require('../db');
const router = express.Router();

// Ottenere tutti i ruoli
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM ruolo');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Creare un nuovo ruolo
router.post('/', async (req, res) => {
    try {
        const { nome_ruolo } = req.body;

        // Validazione input
        if (!nome_ruolo) {
            return res.status(400).json({ message: 'Il nome del ruolo è obbligatorio' });
        }

        // Controllo se il nome del ruolo esiste già
        const existingRole = await pool.query('SELECT * FROM ruolo WHERE nome_ruolo = $1', [nome_ruolo]);
        if (existingRole.rows.length > 0) {
            return res.status(400).json({ message: 'Il ruolo con questo nome esiste già' });
        }

        // Creazione del ruolo
        await pool.query('INSERT INTO ruolo (nome_ruolo) VALUES ($1)', [nome_ruolo]);
        res.status(201).json({ message: 'Ruolo creato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Modificare un ruolo esistente
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { nome_ruolo } = req.body;

        // Verifica che il nome del ruolo sia presente
        if (!nome_ruolo) {
            return res.status(400).json({ message: 'Il nome del ruolo è obbligatorio' });
        }

        // Controllo se il ruolo esiste
        const roleCheck = await pool.query('SELECT * FROM ruolo WHERE id_ruolo = $1', [id]);
        if (roleCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Ruolo non trovato' });
        }

        // Modifica del ruolo
        await pool.query('UPDATE ruolo SET nome_ruolo = $1 WHERE id_ruolo = $2', [nome_ruolo, id]);
        res.json({ message: 'Ruolo aggiornato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Eliminare un ruolo
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        // Controllo se il ruolo esiste
        const roleCheck = await pool.query('SELECT * FROM ruolo WHERE id_ruolo = $1', [id]);
        if (roleCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Ruolo non trovato' });
        }

        // Eliminazione del ruolo
        await pool.query('DELETE FROM ruolo WHERE id_ruolo = $1', [id]);
        res.json({ message: 'Ruolo eliminato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;

const express = require('express');
const pool = require('../db');
const router = express.Router();

// Ottenere tutte le foto
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM foto');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Creare una nuova foto
router.post('/', async (req, res) => {
    try {
        const { id_immobile, percorso_file, ordine } = req.body;
        await pool.query(
            'INSERT INTO foto (id_immobile, percorso_file, ordine) VALUES ($1, $2, $3)',
            [id_immobile, percorso_file, ordine]
        );
        res.status(201).json({ message: 'Foto aggiunta con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Modificare una foto esistente
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { id_immobile, percorso_file, ordine } = req.body;

        // Verifica se la foto esiste
        const photoCheck = await pool.query('SELECT * FROM foto WHERE id_foto = $1', [id]);
        if (photoCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Foto non trovata' });
        }

        // Modifica della foto
        await pool.query(
            'UPDATE foto SET id_immobile = $1, percorso_file = $2, ordine = $3 WHERE id_foto = $4',
            [id_immobile, percorso_file, ordine, id]
        );
        res.json({ message: 'Foto aggiornata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Eliminare una foto
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        // Verifica se la foto esiste
        const photoCheck = await pool.query('SELECT * FROM foto WHERE id_foto = $1', [id]);
        if (photoCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Foto non trovata' });
        }

        // Eliminazione della foto
        await pool.query('DELETE FROM foto WHERE id_foto = $1', [id]);
        res.json({ message: 'Foto eliminata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;

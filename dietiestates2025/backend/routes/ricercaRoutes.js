const express = require('express');
const pool = require('../db');
const router = express.Router();

// Ottenere tutte le ricerche
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM ricerca');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Creare una nuova ricerca
router.post('/', async (req, res) => {
    try {
        const { id_indirizzo, id_filtro_avanzato } = req.body;

        // Verifica se l'indirizzo esiste
        const addressResult = await pool.query('SELECT * FROM indirizzo WHERE id_indirizzo = $1', [id_indirizzo]);
        if (addressResult.rowCount === 0) {
            return res.status(404).json({ error: 'Indirizzo non trovato' });
        }

        // Verifica se il filtro avanzato esiste
        const filterResult = await pool.query('SELECT * FROM filtro_avanzato WHERE id_filtro_avanzato = $1', [id_filtro_avanzato]);
        if (filterResult.rowCount === 0) {
            return res.status(404).json({ error: 'Filtro avanzato non trovato' });
        }

        // Inserimento della nuova ricerca
        await pool.query(
            `INSERT INTO ricerca (id_indirizzo, id_filtro_avanzato) VALUES ($1, $2)`,
            [id_indirizzo, id_filtro_avanzato]
        );
        res.status(201).json({ message: 'Ricerca creata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Modificare una ricerca esistente
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { id_indirizzo, id_filtro_avanzato } = req.body;

        // Verifica se la ricerca esiste
        const result = await pool.query('SELECT * FROM ricerca WHERE id_ricerca = $1', [id]);
        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Ricerca non trovata' });
        }

        // Verifica se l'indirizzo esiste
        const addressResult = await pool.query('SELECT * FROM indirizzo WHERE id_indirizzo = $1', [id_indirizzo]);
        if (addressResult.rowCount === 0) {
            return res.status(404).json({ error: 'Indirizzo non trovato' });
        }

        // Verifica se il filtro avanzato esiste
        const filterResult = await pool.query('SELECT * FROM filtro_avanzato WHERE id_filtro_avanzato = $1', [id_filtro_avanzato]);
        if (filterResult.rowCount === 0) {
            return res.status(404).json({ error: 'Filtro avanzato non trovato' });
        }

        // Aggiorna la ricerca
        await pool.query(
            `UPDATE ricerca SET id_indirizzo = $1, id_filtro_avanzato = $2 WHERE id_ricerca = $3`,
            [id_indirizzo, id_filtro_avanzato, id]
        );

        res.status(200).json({ message: 'Ricerca modificata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Eliminare una ricerca
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        // Verifica se la ricerca esiste
        const result = await pool.query('SELECT * FROM ricerca WHERE id_ricerca = $1', [id]);
        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Ricerca non trovata' });
        }

        // Elimina la ricerca
        await pool.query('DELETE FROM ricerca WHERE id_ricerca = $1', [id]);

        res.status(200).json({ message: 'Ricerca eliminata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;

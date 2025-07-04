const express = require('express');
const pool = require('../db');
const router = express.Router();

// Ottenere tutti i filtri avanzati
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM filtro_avanzato');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Creare un filtro avanzato
router.post('/', async (req, res) => {
    try {
        const { tipologia_immobile, stanza, piano, bagno, parcheggio, classe_energetica } = req.body;
        await pool.query(
            'INSERT INTO filtro_avanzato (tipologia_immobile, stanza, piano, bagno, parcheggio, classe_energetica) VALUES ($1, $2, $3, $4, $5, $6)',
            [tipologia_immobile, stanza, piano, bagno, parcheggio, classe_energetica]
        );
        res.status(201).json({ message: 'Filtro avanzato creato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Modificare un filtro avanzato esistente
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { tipologia_immobile, stanza, piano, bagno, parcheggio, classe_energetica } = req.body;

        // Verifica se il filtro esiste
        const filterCheck = await pool.query('SELECT * FROM filtro_avanzato WHERE id_filtro_avanzato = $1', [id]);
        if (filterCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Filtro avanzato non trovato' });
        }

        // Modifica del filtro avanzato
        await pool.query(
            'UPDATE filtro_avanzato SET tipologia_immobile = $1, stanza = $2, piano = $3, bagno = $4, parcheggio = $5, classe_energetica = $6 WHERE id_filtro_avanzato = $7',
            [tipologia_immobile, stanza, piano, bagno, parcheggio, classe_energetica, id]
        );
        res.json({ message: 'Filtro avanzato aggiornato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Eliminare un filtro avanzato
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        // Verifica se il filtro esiste
        const filterCheck = await pool.query('SELECT * FROM filtro_avanzato WHERE id_filtro_avanzato = $1', [id]);
        if (filterCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Filtro avanzato non trovato' });
        }

        // Eliminazione del filtro avanzato
        await pool.query('DELETE FROM filtro_avanzato WHERE id_filtro_avanzato = $1', [id]);
        res.json({ message: 'Filtro avanzato eliminato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;

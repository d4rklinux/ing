const express = require('express');
const pool = require('../db');
const router = express.Router();

// Ottenere tutti i servizi ulteriori
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM servizio_ulteriore');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Creare un nuovo servizio ulteriore
router.post('/', async (req, res) => {
    try {
        const { climatizzatore, balcone, portineria, giardino, ascensore, arredato, id_filtro_avanzato } = req.body;
        await pool.query(
            'INSERT INTO servizio_ulteriore (climatizzatore, balcone, portineria, giardino, ascensore, arredato, id_filtro_avanzato) VALUES ($1, $2, $3, $4, $5, $6, $7)',
            [climatizzatore, balcone, portineria, giardino, ascensore, arredato, id_filtro_avanzato]
        );
        res.status(201).json({ message: 'Servizio ulteriore creato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Modificare un servizio ulteriore esistente
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { climatizzatore, balcone, portineria, giardino, ascensore, arredato, id_filtro_avanzato } = req.body;

        // Verifica se il servizio esiste
        const serviceCheck = await pool.query('SELECT * FROM servizio_ulteriore WHERE id_servizio_ulteriore = $1', [id]);
        if (serviceCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Servizio ulteriore non trovato' });
        }

        // Modifica del servizio ulteriore
        await pool.query(
            'UPDATE servizio_ulteriore SET climatizzatore = $1, balcone = $2, portineria = $3, giardino = $4, ascensore = $5, arredato = $6, id_filtro_avanzato = $7 WHERE id_servizio_ulteriore = $8',
            [climatizzatore, balcone, portineria, giardino, ascensore, arredato, id_filtro_avanzato, id]
        );
        res.json({ message: 'Servizio ulteriore aggiornato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Eliminare un servizio ulteriore
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        // Verifica se il servizio esiste
        const serviceCheck = await pool.query('SELECT * FROM servizio_ulteriore WHERE id_servizio_ulteriore = $1', [id]);
        if (serviceCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Servizio ulteriore non trovato' });
        }

        // Eliminazione del servizio ulteriore
        await pool.query('DELETE FROM servizio_ulteriore WHERE id_servizio_ulteriore = $1', [id]);
        res.json({ message: 'Servizio ulteriore eliminato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;

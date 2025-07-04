const express = require('express');
const pool = require('../db');
const router = express.Router();

const validateAddress = (provincia, città, via, cap) => {
    if (!provincia || !città || !via || !cap) {
        throw new Error('Tutti i campi sono obbligatori');
    }
    const capRegex = /^[0-9]{5}$/; // Regex per il CAP italiano
    if (!capRegex.test(cap)) {
        throw new Error('Il CAP deve essere un numero di 5 cifre');
    }
};

// Ottenere tutti gli indirizzi
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM indirizzo');
        res.json(result.rows);
    } catch (err) {
        console.error('Errore nel server:', err);
        res.status(500).json({ error: 'Errore interno del server' });
    }
});

// Creare un nuovo indirizzo
router.post('/', async (req, res) => {
    try {
        const { provincia, città, via, cap } = req.body;

        // Validazione dei dati di input
        validateAddress(provincia, città, via, cap);

        // Inserimento del nuovo indirizzo
        await pool.query(
            'INSERT INTO indirizzo (provincia, città, via, cap) VALUES ($1, $2, $3, $4) ON CONFLICT (provincia, città, via, cap) DO NOTHING',
            [provincia, città, via, cap]
        );

        res.status(201).json({ message: 'Indirizzo creato con successo' });
    } catch (err) {
        console.error('Errore nella creazione dell\'indirizzo:', err);
        res.status(500).json({ error: err.message });
    }
});

// Modifica un indirizzo esistente
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { provincia, città, via, cap } = req.body;

        // Validazione degli input
        validateAddress(provincia, città, via, cap);

        // Verifica se l'indirizzo esiste
        const result = await pool.query('SELECT * FROM indirizzo WHERE id_indirizzo = $1', [id]);
        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Indirizzo non trovato' });
        }

        // Aggiorna l'indirizzo
        await pool.query(
            'UPDATE indirizzo SET provincia = $1, città = $2, via = $3, cap = $4 WHERE id_indirizzo = $5',
            [provincia, città, via, cap, id]
        );

        res.status(200).json({ message: 'Indirizzo modificato con successo' });
    } catch (err) {
        console.error('Errore nella modifica dell\'indirizzo:', err);
        res.status(500).json({ error: err.message });
    }
});

// Elimina un indirizzo
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        // Verifica se l'indirizzo esiste
        const result = await pool.query('SELECT * FROM indirizzo WHERE id_indirizzo = $1', [id]);
        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Indirizzo non trovato' });
        }

        // Elimina l'indirizzo
        await pool.query('DELETE FROM indirizzo WHERE id_indirizzo = $1', [id]);

        res.status(200).json({ message: 'Indirizzo eliminato con successo' });
    } catch (err) {
        console.error('Errore nell\'eliminazione dell\'indirizzo:', err);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;

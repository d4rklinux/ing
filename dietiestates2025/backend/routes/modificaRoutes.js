const express = require('express');
const pool = require('../db');
const router = express.Router();

// Ottenere tutte le modifiche
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM modifica');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Creare una nuova modifica
router.post('/', async (req, res) => {
    try {
        const { id_immobile, username_utente, nuovo_tipo_contratto, nuova_tipologia_immobile, nuovo_titolo, nuovo_testo, nuova_superficie, nuovo_prezzo, nuovo_id_indirizzo_immobile, nuovo_id_filtro_avanzato, nuovo_id_servizio_ulteriore } = req.body;

        // Verifica se l'immobile esiste
        const immobileResult = await pool.query('SELECT * FROM immobile WHERE id_immobile = $1', [id_immobile]);
        if (immobileResult.rowCount === 0) {
            return res.status(404).json({ error: 'Immobile non trovato' });
        }

        // Registra la modifica
        await pool.query(
            `INSERT INTO modifica (id_immobile, username_utente, nuovo_tipo_contratto, nuova_tipologia_immobile, nuovo_titolo, nuovo_testo, nuova_superficie, nuovo_prezzo, nuovo_id_indirizzo_immobile, nuovo_id_filtro_avanzato, nuovo_id_servizio_ulteriore)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
            [id_immobile, username_utente, nuovo_tipo_contratto, nuova_tipologia_immobile, nuovo_titolo, nuovo_testo, nuova_superficie, nuovo_prezzo, nuovo_id_indirizzo_immobile, nuovo_id_filtro_avanzato, nuovo_id_servizio_ulteriore]
        );

        // Applicare la modifica all'immobile
        await pool.query(
            `UPDATE immobile SET tipo_contratto = $1, tipologia_immobile = $2, titolo = $3, testo = $4, superficie = $5, prezzo = $6,
             id_indirizzo_immobile = $7, id_filtro_avanzato = $8, id_servizio_ulteriore = $9
             WHERE id_immobile = $10`,
            [nuovo_tipo_contratto, nuova_tipologia_immobile, nuovo_titolo, nuovo_testo, nuova_superficie, nuovo_prezzo,
             nuovo_id_indirizzo_immobile, nuovo_id_filtro_avanzato, nuovo_id_servizio_ulteriore, id_immobile]
        );

        res.status(201).json({ message: 'Modifica registrata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Elimina una modifica
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        // Verifica se la modifica esiste
        const result = await pool.query('SELECT * FROM modifica WHERE id_modifica = $1', [id]);
        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Modifica non trovata' });
        }

        // Elimina la modifica
        await pool.query('DELETE FROM modifica WHERE id_modifica = $1', [id]);

        res.status(200).json({ message: 'Modifica eliminata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;

const express = require('express');
const pool = require('../db');
const router = express.Router();

// Ottenere tutte le visite con i dettagli dell'immobile e le foto
router.get('/', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT visita.*, immobile.*, foto.*, utente.nome, utente.cognome, utente.email
            FROM visita
            JOIN immobile ON visita.id_immobile = immobile.id_immobile
            LEFT JOIN foto ON immobile.id_immobile = foto.id_immobile
            LEFT JOIN utente ON visita.username_utente = utente.username_utente`
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Creare una nuova visita
router.post('/', async (req, res) => {
    try {
        const { id_immobile, username_utente, data_visita, ora_visita, stato_visita, stato_approvazione_agente, username_agente_approvazione } = req.body;
        await pool.query(
            `INSERT INTO visita (id_immobile, username_utente, data_visita, ora_visita, stato_visita, stato_approvazione_agente, username_agente_approvazione)
             VALUES ($1, $2, $3, $4, $5, $6, $7)`,
            [id_immobile, username_utente, data_visita, ora_visita, stato_visita, stato_approvazione_agente, username_agente_approvazione]
        );
        res.status(201).json({ message: 'Visita creata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Eliminare una visita
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('SELECT * FROM visita WHERE id_visita = $1', [id]);

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Visita non trovata' });
        }

        // Elimina la visita
        await pool.query('DELETE FROM visita WHERE id_visita = $1', [id]);
        res.status(200).json({ message: 'Visita eliminata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Modificare una visita
router.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { id_immobile, username_utente, data_visita, ora_visita, stato_visita, stato_approvazione_agente, username_agente_approvazione } = req.body;

    try {
        // Verifica se la visita esiste
        const result = await pool.query('SELECT * FROM visita WHERE id_visita = $1', [id]);

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Visita non trovata' });
        }

        // Verifica se l'utente e l'immobile esistono
        const userResult = await pool.query('SELECT * FROM utente WHERE username_utente = $1', [username_utente]);
        const immobileResult = await pool.query('SELECT * FROM immobile WHERE id_immobile = $1', [id_immobile]);

        if (userResult.rowCount === 0 || immobileResult.rowCount === 0) {
            return res.status(404).json({ error: 'Utente o immobile non trovato' });
        }

        // Esegui la modifica della visita
        await pool.query(
            `UPDATE visita SET
                id_immobile = $1,
                username_utente = $2,
                data_visita = $3,
                ora_visita = $4,
                stato_visita = $5,
                stato_approvazione_agente = $6,
                username_agente_approvazione = $7
             WHERE id_visita = $8`,
            [id_immobile, username_utente, data_visita, ora_visita, stato_visita, stato_approvazione_agente, username_agente_approvazione, id]
        );

        res.status(200).json({ message: 'Visita modificata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Ottenere tutte le visite per gli immobili gestiti da un agente
router.get('/agente/:username', async (req, res) => {
    const { username } = req.params;
    try {
        const result = await pool.query(
            `SELECT v.*, i.*
             FROM visita v
             JOIN immobile i ON v.id_immobile = i.id_immobile
             WHERE i.username_agente = $1`,
            [username]
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Confermare o rifiutare una visita (POST)
router.post('/approvazione', async (req, res) => {
    const { id_visita, stato_approvazione_agente, username_agente_approvazione } = req.body;

    if (!id_visita || !stato_approvazione_agente || !username_agente_approvazione) {
        return res.status(400).json({ error: 'Dati incompleti' });
    }

    if (!['Accettata', 'Rifiutata'].includes(stato_approvazione_agente)) {
        return res.status(400).json({ error: 'Stato approvazione non valido' });
    }

    try {
        const result = await pool.query(
            `UPDATE visita
             SET stato_approvazione_agente = $1, username_agente_approvazione = $2
             WHERE id_visita = $3`,
            [stato_approvazione_agente, username_agente_approvazione, id_visita]
        );

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Visita non trovata' });
        }

        res.status(200).json({ message: `Visita ${stato_approvazione_agente}` });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Ottenere tutte le visite con stato "Completata"
router.get('/completate', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT visita.*, immobile.*, foto.*
             FROM visita
             JOIN immobile ON visita.id_immobile = immobile.id_immobile
             LEFT JOIN foto ON immobile.id_immobile = foto.id_immobile
             WHERE visita.stato_visita = 'Completata'`
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Ottenere tutte le visite di un utente con i dettagli dell'immobile e le foto
router.get('/:username', async (req, res) => {
    const { username } = req.params;
    try {
        const result = await pool.query(
            `SELECT visita.*, immobile.*, foto.*
             FROM visita
             JOIN immobile ON visita.id_immobile = immobile.id_immobile
             LEFT JOIN foto ON immobile.id_immobile = foto.id_immobile
             WHERE visita.username_utente = $1`,
            [username]
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Ottenere solo le visite Completate e Annullate di un utente con i dettagli dell'immobile e le foto
router.get('/:username/notifiche', async (req, res) => {
    const { username } = req.params;
    try {
        const result = await pool.query(
            `SELECT visita.*, immobile.*, foto.*
             FROM visita
             JOIN immobile ON visita.id_immobile = immobile.id_immobile
             LEFT JOIN foto ON immobile.id_immobile = foto.id_immobile
             WHERE visita.username_utente = $1
               AND visita.stato_visita IN ('Completata', 'Annullata')`,
            [username]
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;

const express = require('express');
const pool = require('../db');
const router = express.Router();

// Ottenere tutte le proposte con le informazioni complete
router.get('/', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT p.id_proposta, p.id_immobile_proposta, p.vecchio_prezzo, p.nuovo_prezzo, p.stato_proposta,
                   p.data_proposta, p.ora_proposta, p.username_utente_proposta,
                   p.username_agente_controproposta, p.controproposta, p.stato_controproposta,
                   i.*, -- Seleziona tutte le colonne della tabella immobile
                   u1.nome AS nome_utente, u1.cognome AS cognome_utente,
                   u2.nome AS nome_agente, u2.cognome AS cognome_agente,
                   f.percorso_file -- Restituisci il percorso del file della foto
            FROM proposta p
            JOIN immobile i ON p.id_immobile_proposta = i.id_immobile
            JOIN utente u1 ON p.username_utente_proposta = u1.username_utente
            LEFT JOIN utente u2 ON p.username_agente_controproposta = u2.username_utente
            LEFT JOIN foto f ON i.id_immobile = f.id_immobile -- Fai il join con la foto usando id_immobile
        `);

        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Creare una nuova proposta
router.post('/', async (req, res) => {
    try {
        const { id_immobile_proposta, vecchio_prezzo, nuovo_prezzo, stato_proposta, data_proposta, ora_proposta,
                username_utente_proposta, username_agente_controproposta, controproposta, stato_controproposta } = req.body;

        // Verifica se l'utente, l'immobile e l'agente esistono
        const userResult = await pool.query('SELECT * FROM utente WHERE username_utente = $1', [username_utente_proposta]);
        const immobileResult = await pool.query('SELECT * FROM immobile WHERE id_immobile = $1', [id_immobile_proposta]);

        if (userResult.rowCount === 0 || immobileResult.rowCount === 0) {
            return res.status(404).json({ error: 'Utente o immobile non trovato' });
        }

        if (username_agente_controproposta) {
            const agenteResult = await pool.query('SELECT * FROM utente WHERE username_utente = $1', [username_agente_controproposta]);
            if (agenteResult.rowCount === 0) {
                return res.status(404).json({ error: 'Agente per la controproposta non trovato' });
            }
        }

        await pool.query(
            `INSERT INTO proposta (id_immobile_proposta, vecchio_prezzo, nuovo_prezzo, stato_proposta, data_proposta, ora_proposta,
                                   username_utente_proposta, username_agente_controproposta, controproposta, stato_controproposta)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
            [id_immobile_proposta, vecchio_prezzo, nuovo_prezzo, stato_proposta, data_proposta, ora_proposta,
             username_utente_proposta, username_agente_controproposta, controproposta, stato_controproposta]
        );
        res.status(201).json({ message: 'Proposta creata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Eliminare una proposta
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('SELECT * FROM proposta WHERE id_proposta = $1', [id]);

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Proposta non trovata' });
        }

        // Elimina la proposta
        await pool.query('DELETE FROM proposta WHERE id_proposta = $1', [id]);
        res.status(200).json({ message: 'Proposta eliminata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Modificare una proposta in base all'ID fornito nel corpo della richiesta
router.put('/', async (req, res) => {
    const { id_proposta, stato_proposta } = req.body;

    if (!id_proposta || !stato_proposta) {
        return res.status(400).json({ error: 'ID proposta e stato proposta sono obbligatori' });
    }

    try {
        // Verifica se la proposta esiste
        const result = await pool.query('SELECT * FROM proposta WHERE id_proposta = $1', [id_proposta]);

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Proposta non trovata' });
        }

        // Esegui la modifica della proposta
        await pool.query(
            `UPDATE proposta SET
                stato_proposta = $1
             WHERE id_proposta = $2`,
            [stato_proposta, id_proposta]
        );

        res.status(200).json({ message: 'Proposta aggiornata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Ottenere le proposte in base a username_utente_proposta e includere una foto per ogni immobile
router.get('/:username', async (req, res) => {
    const { username } = req.params; // Prendi l'username dalla URL

    try {
        const result = await pool.query(`
            SELECT p.id_proposta, p.id_immobile_proposta, p.vecchio_prezzo, p.nuovo_prezzo, p.stato_proposta,
                   p.data_proposta, p.ora_proposta, p.username_utente_proposta,
                   p.username_agente_controproposta, p.controproposta, p.stato_controproposta,
                   i.*, -- Seleziona tutte le colonne della tabella immobile
                   u1.nome AS nome_utente, u1.cognome AS cognome_utente,
                   u2.nome AS nome_agente, u2.cognome AS cognome_agente,
                   f.percorso_file -- Restituisci il percorso del file della foto
            FROM proposta p
            JOIN immobile i ON p.id_immobile_proposta = i.id_immobile
            JOIN utente u1 ON p.username_utente_proposta = u1.username_utente
            LEFT JOIN utente u2 ON p.username_agente_controproposta = u2.username_utente
            LEFT JOIN foto f ON i.id_immobile = f.id_immobile
            WHERE p.username_utente_proposta = $1
        `, [username]);

        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Ottenere le proposte in base a username_agente_controproposta e includere una foto per ogni immobile
router.get('/agente/:username', async (req, res) => {
    const { username } = req.params;

    try {
        const result = await pool.query(`
            SELECT p.id_proposta, p.id_immobile_proposta, p.vecchio_prezzo, p.nuovo_prezzo, p.stato_proposta,
                   p.data_proposta, p.ora_proposta, p.username_utente_proposta,
                   p.username_agente_controproposta, p.controproposta, p.stato_controproposta,
                   i.*,
                   u1.nome AS nome_utente, u1.cognome AS cognome_utente,
                   u2.nome AS nome_agente, u2.cognome AS cognome_agente,
                   f.percorso_file
            FROM proposta p
            JOIN immobile i ON p.id_immobile_proposta = i.id_immobile
            JOIN utente u1 ON p.username_utente_proposta = u1.username_utente
            LEFT JOIN utente u2 ON p.username_agente_controproposta = u2.username_utente
            LEFT JOIN foto f ON i.id_immobile = f.id_immobile
            WHERE
                p.username_agente_controproposta = $1
                OR (
                    p.stato_proposta = 'In attesa'
                    AND i.username_agente = $1
                )
        `, [username]);

        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Ottenere le proposte in base a username_utente_proposta e stato_proposta (Accettata o Rifiutata)
router.get('/:username/notifiche', async (req, res) => {
    const { username } = req.params;

    try {
        const result = await pool.query(`
            SELECT p.id_proposta, p.id_immobile_proposta, p.vecchio_prezzo, p.nuovo_prezzo, p.stato_proposta,
                   p.data_proposta, p.ora_proposta, p.username_utente_proposta,
                   p.username_agente_controproposta, p.controproposta, p.stato_controproposta,
                   i.*, -- Seleziona tutte le colonne della tabella immobile
                   u1.nome AS nome_utente, u1.cognome AS cognome_utente,
                   u2.nome AS nome_agente, u2.cognome AS cognome_agente,
                   f.percorso_file -- Restituisci il percorso del file della foto
            FROM proposta p
            JOIN immobile i ON p.id_immobile_proposta = i.id_immobile
            JOIN utente u1 ON p.username_utente_proposta = u1.username_utente
            LEFT JOIN utente u2 ON p.username_agente_controproposta = u2.username_utente
            LEFT JOIN foto f ON i.id_immobile = f.id_immobile
            WHERE p.username_utente_proposta = $1
            AND p.stato_proposta IN ('Accettata', 'Rifiutata')
        `, [username]);

        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Effettuare una controproposta
router.post('/controproposta', async (req, res) => {
    const {
        id_proposta,
        username_agente_controproposta,
        controproposta,
        stato_controproposta
    } = req.body;

    if (!id_proposta || !username_agente_controproposta || !controproposta || !stato_controproposta) {
        return res.status(400).json({ error: 'Tutti i campi sono obbligatori' });
    }

    try {
        // Verifica se la proposta esiste
        const propostaResult = await pool.query('SELECT * FROM proposta WHERE id_proposta = $1', [id_proposta]);

        if (propostaResult.rowCount === 0) {
            return res.status(404).json({ error: 'Proposta non trovata' });
        }

        // Verifica se l'agente esiste
        const agenteResult = await pool.query('SELECT * FROM utente WHERE username_utente = $1', [username_agente_controproposta]);

        if (agenteResult.rowCount === 0) {
            return res.status(404).json({ error: 'Agente non trovato' });
        }

        // Esegui l'aggiornamento della controproposta
        await pool.query(
            `UPDATE proposta SET
                username_agente_controproposta = $1,
                controproposta = $2,
                stato_controproposta = $3
             WHERE id_proposta = $4`,
            [username_agente_controproposta, controproposta, stato_controproposta, id_proposta]
        );

        res.status(200).json({ message: 'Controproposta aggiornata con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Accettare o rifiutare una controproposta in base all'ID fornito nel corpo della richiesta
router.put('/accettarifiutacontroproposta', async (req, res) => {
    const { id_proposta, stato_controproposta } = req.body;

    if (!id_proposta || !stato_controproposta) {
        return res.status(400).json({ error: 'ID proposta e stato controproposta sono obbligatori' });
    }

    try {
        // Verifica se la proposta esiste
        const result = await pool.query('SELECT * FROM proposta WHERE id_proposta = $1', [id_proposta]);

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Proposta non trovata' });
        }

        // Esegui la modifica dello stato_controproposta
        await pool.query(
            `UPDATE proposta SET
                stato_controproposta = $1
             WHERE id_proposta = $2`,
            [stato_controproposta, id_proposta]
        );

        res.status(200).json({ message: 'Stato controproposta aggiornato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
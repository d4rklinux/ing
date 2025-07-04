const express = require('express');
const pool = require('../db');
const router = express.Router();

// Ottenere tutti gli immobili con filtro avanzato, servizio ulteriore e foto
router.get('/', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT i.*,
                   ind.provincia, ind."città", ind.via, ind.cap,
                   f.tipologia_immobile, f.stanza, f.piano, f.bagno, f.parcheggio, f.classe_energetica,
                   s.climatizzatore, s.balcone, s.portineria, s.giardino, s.ascensore, s.arredato,
                   fo.percorso_file, fo.ordine
            FROM immobile i
            JOIN indirizzo ind ON i.id_indirizzo_immobile = ind.id_indirizzo
            JOIN filtro_avanzato f ON i.id_filtro_avanzato = f.id_filtro_avanzato
            JOIN servizio_ulteriore s ON i.id_servizio_ulteriore = s.id_servizio_ulteriore  -- Correzione qui
            LEFT JOIN foto fo ON i.id_immobile = fo.id_immobile
        `);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Creare un nuovo immobile
router.post('/', async (req, res) => {
    const {
        id_immobile, data_creazione, ora_creazione, username_agente, tipo_contratto,
        tipologia_immobile, titolo, testo, superficie, prezzo, id_indirizzo_immobile,
        id_filtro_avanzato, id_servizio_ulteriore, provincia, città, via, cap,
        stanza, piano, bagno, parcheggio, classe_energetica, climatizzatore, balcone,
        portineria, giardino, ascensore, arredato, percorso_file, ordine
    } = req.body;

    try {
        // Inserire i dati dell'indirizzo
        const resultIndirizzo = await pool.query(`
            INSERT INTO indirizzo (provincia, "città", via, cap)
            VALUES ($1, $2, $3, $4) RETURNING id_indirizzo
        `, [provincia, città, via, cap]);

        const idIndirizzo = resultIndirizzo.rows[0].id_indirizzo;

        // Inserire i dati del filtro avanzato
        const resultFiltro = await pool.query(`
            INSERT INTO filtro_avanzato (tipologia_immobile, stanza, piano, bagno, parcheggio, classe_energetica)
            VALUES ($1, $2, $3, $4, $5, $6) RETURNING id_filtro_avanzato
        `, [tipologia_immobile, stanza, piano, bagno, parcheggio, classe_energetica]);

        const idFiltro = resultFiltro.rows[0].id_filtro_avanzato;

        // Inserire i dati del servizio ulteriore, utilizzando lo stesso id_filtro_avanzato
        const resultServizio = await pool.query(`
            INSERT INTO servizio_ulteriore (climatizzatore, balcone, portineria, giardino, ascensore, arredato, id_filtro_avanzato)
            VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id_servizio_ulteriore
        `, [climatizzatore, balcone, portineria, giardino, ascensore, arredato, idFiltro]);

        const idServizio = resultServizio.rows[0].id_servizio_ulteriore;

        // Inserire l'immobile, aggiunto tipologia_immobile
        const resultImmobile = await pool.query(`
            INSERT INTO immobile (data_creazione, ora_creazione, username_agente, tipo_contratto, tipologia_immobile,
                                  titolo, testo, superficie, prezzo, id_indirizzo_immobile,
                                  id_filtro_avanzato, id_servizio_ulteriore)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
            RETURNING id_immobile
        `, [data_creazione, ora_creazione, username_agente, tipo_contratto, tipologia_immobile,
            titolo, testo, superficie, prezzo, idIndirizzo, idFiltro, idServizio]);

        const idImmobile = resultImmobile.rows[0].id_immobile;

        // Inserire foto, se presenti
       if (percorso_file) {
       percorso_file.forEach(async (img, index) => {
           await pool.query(
               'INSERT INTO foto (id_immobile, percorso_file, ordine) VALUES ($1, $2, $3)',
               [idImmobile, img, index]
           );
       });
    }
     res.status(201).json({ message: 'Immobile inserito con successo', id_immobile: idImmobile });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Errore nel server' });
    }
});


// Eliminare un immobile
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        // Verifica se l'immobile esiste
        const result = await pool.query('SELECT * FROM immobile WHERE id_immobile = $1', [id]);

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Immobile non trovato' });
        }

        // Elimina prima le foto associate all'immobile (se esistono)
        await pool.query('DELETE FROM foto WHERE id_immobile_foto = $1', [id]);

        // Elimina le modifiche associate all'immobile
        await pool.query('DELETE FROM modifica WHERE id_immobile_modifica = $1', [id]);

        // Elimina l'immobile
        await pool.query('DELETE FROM immobile WHERE id_immobile = $1', [id]);

        res.status(200).json({ message: 'Immobile eliminato con successo' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.get("/ricerca", async (req, res) => {
    try {
        const { query } = req.query; // Recupera il valore cercato
        if (!query) {
            return res.status(400).json({ error: "Devi specificare un valore di ricerca" });
        }

        // Se la query è un CAP, filtra solo per CAP
        const isCap = /^\d{5}$/.test(query); // Controlla se la query è un CAP (es. 12345)
        let searchQuery = '';
        let values = [`%${query}%`];

        // Se la ricerca contiene uno dei termini specificati, cerca anche nel campo 'via'
        const isViaOrOther = /(via|viale|corso|strada|piazza|largo|borgo|passaggio|contrada|frazione|riviera|vicolo|piazzale|calle larga)/i.test(query);

        if (isCap) {
            // Ricerca solo per CAP
            searchQuery = `
                SELECT i.*,
                       ind.provincia, ind."città", ind.via, ind.cap,
                       f.tipologia_immobile, f.stanza, f.piano, f.bagno, f.parcheggio, f.classe_energetica,
                       s.climatizzatore, s.balcone, s.portineria, s.giardino, s.ascensore, s.arredato,
                       fo.percorso_file, fo.ordine
                FROM immobile i
                JOIN indirizzo ind ON i.id_indirizzo_immobile = ind.id_indirizzo
                JOIN filtro_avanzato f ON i.id_filtro_avanzato = f.id_filtro_avanzato
                JOIN servizio_ulteriore s ON i.id_servizio_ulteriore = s.id_servizio_ulteriore
                LEFT JOIN foto fo ON i.id_immobile = fo.id_immobile
                WHERE LOWER(ind.cap) LIKE LOWER($1)
            `;
        } else {
            if (isViaOrOther) {
                // Se la query contiene uno dei termini, cerca anche nel campo 'via'
                searchQuery = `
                    SELECT i.*,
                           ind.provincia, ind."città", ind.via, ind.cap,
                           f.tipologia_immobile, f.stanza, f.piano, f.bagno, f.parcheggio, f.classe_energetica,
                           s.climatizzatore, s.balcone, s.portineria, s.giardino, s.ascensore, s.arredato,
                           fo.percorso_file, fo.ordine
                    FROM immobile i
                    JOIN indirizzo ind ON i.id_indirizzo_immobile = ind.id_indirizzo
                    JOIN filtro_avanzato f ON i.id_filtro_avanzato = f.id_filtro_avanzato
                    JOIN servizio_ulteriore s ON i.id_servizio_ulteriore = s.id_servizio_ulteriore
                    LEFT JOIN foto fo ON i.id_immobile = fo.id_immobile
                    WHERE LOWER(ind.via) LIKE LOWER($1)
                `;
            } else {
                // Ricerca per città o provincia
                searchQuery = `
                    SELECT i.*,
                           ind.provincia, ind."città", ind.via, ind.cap,
                           f.tipologia_immobile, f.stanza, f.piano, f.bagno, f.parcheggio, f.classe_energetica,
                           s.climatizzatore, s.balcone, s.portineria, s.giardino, s.ascensore, s.arredato,
                           fo.percorso_file, fo.ordine
                    FROM immobile i
                    JOIN indirizzo ind ON i.id_indirizzo_immobile = ind.id_indirizzo
                    JOIN filtro_avanzato f ON i.id_filtro_avanzato = f.id_filtro_avanzato
                    JOIN servizio_ulteriore s ON i.id_servizio_ulteriore = s.id_servizio_ulteriore
                    LEFT JOIN foto fo ON i.id_immobile = fo.id_immobile
                    WHERE LOWER(ind."città") LIKE LOWER($1)
                    OR LOWER(ind.provincia) LIKE LOWER($1)
                `;
            }
        }

        const { rows } = await pool.query(searchQuery, values);

        // Se non trova risultati per città, prova a cercare per provincia
        if (rows.length === 0 && !isCap) {
            searchQuery = `
                SELECT i.*,
                       ind.provincia, ind."città", ind.via, ind.cap,
                       f.tipologia_immobile, f.stanza, f.piano, f.bagno, f.parcheggio, f.classe_energetica,
                       s.climatizzatore, s.balcone, s.portineria, s.giardino, s.ascensore, s.arredato,
                       fo.percorso_file, fo.ordine
                FROM immobile i
                JOIN indirizzo ind ON i.id_indirizzo_immobile = ind.id_indirizzo
                JOIN filtro_avanzato f ON i.id_filtro_avanzato = f.id_filtro_avanzato
                JOIN servizio_ulteriore s ON i.id_servizio_ulteriore = s.id_servizio_ulteriore
                LEFT JOIN foto fo ON i.id_immobile = fo.id_immobile
                WHERE LOWER(ind.provincia) LIKE LOWER($1)
            `;
            const { rows: rowsProvincia } = await pool.query(searchQuery, values);
            res.json(rowsProvincia); // Restituisce i risultati dalla provincia
        } else {
            res.json(rows); // Restituisce i risultati trovati
        }

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Errore nel server" });
    }
});

module.exports = router;

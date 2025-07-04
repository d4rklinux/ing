-- Ottieni la sequenza associata alla colonna 'id_ruolo' nella tabella 'ruolo'
SELECT pg_get_serial_sequence('ruolo', 'id_ruolo');
-- Resetta la sequenza per la tabella immobile
ALTER SEQUENCE ruolo_id_ruolo_seq RESTART WITH 1;

-- Ottieni la sequenza associata alla colonna 'id_immobile' nella tabella 'immobile'
SELECT pg_get_serial_sequence('immobile', 'id_immobile');
-- Resetta la sequenza per la tabella immobile
ALTER SEQUENCE immobile_id_immobile_seq RESTART WITH 1;

-- Ottieni la sequenza associata alla colonna 'id_indirizzo' nella tabella 'indirizzo'
SELECT pg_get_serial_sequence('indirizzo', 'id_indirizzo');
-- Resetta la sequenza per la tabella indirizzo
ALTER SEQUENCE indirizzo_id_indirizzo_seq RESTART WITH 1;

-- Ottieni la sequenza associata alla colonna 'id_foto' nella tabella 'foto'
SELECT pg_get_serial_sequence('foto', 'id_foto');
-- Resetta la sequenza per la tabella foto
ALTER SEQUENCE foto_id_foto_seq RESTART WITH 1;

-- Ottieni la sequenza associata alla colonna 'id_filtro_avanzato' nella tabella 'filtro_avanzato_immobile'
SELECT pg_get_serial_sequence('filtro_avanzato', 'id_filtro_avanzato');
-- Resetta la sequenza per la tabella filtro_avanzato_immobile
ALTER SEQUENCE filtro_avanzato_id_filtro_avanzato_seq RESTART WITH 1;

-- Ottieni la sequenza associata alla colonna 'id_servizio_ulteriore' nella tabella 'servizio_ulteriore'
SELECT pg_get_serial_sequence('servizio_ulteriore', 'id_servizio_ulteriore');
-- Resetta la sequenza per la tabella servizio_ulteriore
ALTER SEQUENCE servizio_ulteriore_id_servizio_ulteriore_seq RESTART WITH 1;

-- Ottieni la sequenza associata alla colonna 'id_modifica' nella tabella 'modifica'
SELECT pg_get_serial_sequence('modifica', 'id_modifica');
-- Resetta la sequenza per la tabella immobile
ALTER SEQUENCE modifica_id_modifica_seq RESTART WITH 1;

-- Ottieni la sequenza associata alla colonna 'id_proposta' nella tabella 'proposta'
SELECT pg_get_serial_sequence('proposta', 'id_proposta');
-- Resetta la sequenza per la tabella proposta
ALTER SEQUENCE proposta_id_proposta_seq RESTART WITH 1;

-- Ottieni la sequenza associata alla colonna 'id_visita' nella tabella 'visite'
SELECT pg_get_serial_sequence('visita', 'id_visita');
-- Resetta la sequenza per la tabella visite
ALTER SEQUENCE visita_id_visita_seq RESTART WITH 1;

-- Ottieni la sequenza associata alla colonna 'id_ricerca' nella tabella 'ricerca'
SELECT pg_get_serial_sequence('ricerca', 'id_ricerca');
-- Resetta la sequenza per la tabella ricerca
ALTER SEQUENCE ricerca_id_ricerca_seq RESTART WITH 1;
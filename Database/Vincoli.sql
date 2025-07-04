-- Aggiungi un vincolo di check sulla colonna email nella tabella 'utente'
ALTER TABLE utente
ADD CONSTRAINT chk_email_format
CHECK (email ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

-- Aggiungi un vincolo di unicità sulla colonna 'email' nella tabella 'utente'
ALTER TABLE utente
ADD CONSTRAINT uk_email UNIQUE (email);

-- Assicurarti che ogni Utente abbia un Ruolo Predefinito
ALTER TABLE utente
ALTER COLUMN id_ruolo SET DEFAULT 4;

-- Aggiungi un vincolo di check sulla colonna 'nome_ruolo' nella tabella 'ruolo_utente'
-- che accetta solo valori 'Amministratore','Agente Immobiliare','Gestore', 'Utente'
ALTER TABLE ruolo
ADD CONSTRAINT chk_ruolo CHECK (nome_ruolo IN ('Amministratore','Gestore','Agente', 'Utente'));

-- Aggiungi un vincolo di unicità sulle colonne 'città', 'provincia', 'via' e 'cap'
ALTER TABLE indirizzo
ADD CONSTRAINT uk_indirizzo_unico UNIQUE (città, provincia, via, cap);

-- Aggiungi un vincolo di unicità sulla colonna 'titolo' nella tabella 'immobile'
ALTER TABLE immobile
ADD CONSTRAINT uk_titolo UNIQUE (titolo);

-- Aggiungi un vincolo di check sulla colonna 'data_creazione' nella tabella 'immobile'
-- che assicura che la data di creazione non sia successiva alla data corrente
ALTER TABLE immobile
ADD CONSTRAINT chk_data_creazione CHECK (data_creazione <= CURRENT_DATE);

-- Vincolo di check sulla colonna 'parcheggio' nellal tabella 'filtro_avanzato_immboile'
-- che assicura che parcheggio abbiamo solo i requisiti richiesti
ALTER TABLE filtro_avanzato
ADD CONSTRAINT check_parcheggio
CHECK (parcheggio IN ('Box privato', 'Posto auto riservato', 'Posto auto libero', 'Posto bici', 'Posto moto'));

-- Aggiungi un vincolo di check sulla colonna 'classe_energetica' nella tabella 'filtro_avanzato_immobile'
ALTER TABLE filtro_avanzato
ADD CONSTRAINT chk_classe_energetica
CHECK (classe_energetica IN ('A', 'B', 'C', 'D', 'E', 'F', 'G'));

-- Aggiungi un vinco di check sulla colonna 'prezzo' nella tabella 'immobile'
ALTER TABLE immobile
ADD CONSTRAINT chk_prezzo_positive
CHECK (prezzo IS NULL OR prezzo > 0);

-- Aggiungi un vinco di check sulla colonna 'controproposta' nella tabella 'proposta'
ALTER TABLE proposta
ADD CONSTRAINT chk_controproposta_positive
CHECK (controproposta IS NULL OR controproposta > 0);

-- Aggiungi un vincolo di check sulla tabella 'proposta'
-- che assicura che 'vecchio_prezzo' e 'nuovo_prezzo' siano diversi
ALTER TABLE proposta
ADD CONSTRAINT chk_vecchio_nuovo_prezzo_different
CHECK (vecchio_prezzo <> nuovo_prezzo);

-- Imposta il valore di default 'In attesa' per la colonna 'stato' nella tabella 'proposta'
ALTER TABLE proposta
ALTER COLUMN stato_proposta SET DEFAULT 'In attesa';

-- Aggiungi un vincolo di check sulla colonna 'stato_proposta' nella tabella 'proposta'
-- che accetta solo valori 'Accettata', 'Rifiutata', In attesa'
ALTER TABLE proposta
ADD CONSTRAINT chk_proposta CHECK (stato_proposta IN ('Accettata', 'Rifiutata', 'In attesa', 'Controproposta'));

--Aggiungi un vincolo di checl sulla colonna 'stato_controproposta' nella tabella 'proposta'
--che accetta solo valori 'Accettata', 'Rifiutata','In attesa'
ALTER TABLE proposta
ADD CONSTRAINT chk_controproposta CHECK (stato_controproposta IN ('Accettata', 'Rifiutata', 'In attesa'));

-- Aggiungi un vincolo di check sulla colonna 'stato_visita' nella tabella 'visite'
ALTER TABLE visita
ADD CONSTRAINT chk_stato_visita
CHECK (stato_visita IN ('In attesa', 'Completata', 'Annullata'));

-- Aggiungi un vincolo di check sulla colonna 'stato_approvazione_agente' nella tabella 'visite'
ALTER TABLE visita
ADD CONSTRAINT chk_stato_approvazione_agente
CHECK (stato_approvazione_agente IN ('Accettata', 'Rifiutata', 'In attesa'));
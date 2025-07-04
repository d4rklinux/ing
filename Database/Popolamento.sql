INSERT INTO ruolo (nome_ruolo) VALUES
    ('Amministratore'),
    ('Gestore'),
    ('Agente'),
    ('Utente')
ON CONFLICT (nome_ruolo) DO NOTHING;


INSERT INTO utente (username_utente, password, id_ruolo, nome, cognome, email) VALUES
    ('alessandrabi', 'agente123', (SELECT id_ruolo FROM ruolo WHERE nome_ruolo = 'Agente'), 'Alessandra', 'Bianchi', 'alessandra.bianchi@email.com'),
    ('giulia.conti', 'user123', (SELECT id_ruolo FROM ruolo WHERE nome_ruolo = 'Utente'), 'Giulia', 'Conti', 'giulia.conti@email.com'),
    ('marco.rossi', 'gestore123', (SELECT id_ruolo FROM ruolo WHERE nome_ruolo = 'Gestore'), 'Marco', 'Rossi', 'marco.rossi@email.com'),
    ('francescomor', 'admin123', (SELECT id_ruolo FROM ruolo WHERE nome_ruolo = 'Amministratore'), 'Francesco', 'Moretti', 'francesco.moretti@email.com'),
    ('martina.neri', 'user456', (SELECT id_ruolo FROM ruolo WHERE nome_ruolo = 'Utente'), 'Martina', 'Neri', 'martina.neri@email.com');
    
PGDMP  "    )                 }           DietiEstates2025    16.8    16.8 �    '           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            (           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            )           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            *           1262    16398    DietiEstates2025    DATABASE     t   CREATE DATABASE "DietiEstates2025" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C';
 "   DROP DATABASE "DietiEstates2025";
                postgres    false                       1255    16688    aggiorna_stato_proposta()    FUNCTION     s  CREATE FUNCTION public.aggiorna_stato_proposta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Controlla se lo stato_controproposta è diventato 'In attesa'
    IF NEW.stato_controproposta = 'In attesa' THEN
        -- Aggiorna lo stato della proposta a 'Controproposta'
        NEW.stato_proposta := 'Controproposta';
    END IF;

    RETURN NEW;
END;
$$;
 0   DROP FUNCTION public.aggiorna_stato_proposta();
       public          postgres    false                       1255    16691 +   aggiorna_stato_proposta_da_controproposta()    FUNCTION     �  CREATE FUNCTION public.aggiorna_stato_proposta_da_controproposta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Se la controproposta è "Accettata", aggiorna lo stato della proposta
    IF NEW.stato_controproposta = 'Accettata' THEN
        NEW.stato_proposta := 'Accettata';
    ELSIF NEW.stato_controproposta = 'Rifiutata' THEN
        NEW.stato_proposta := 'Rifiutata';
    END IF;

    RETURN NEW;
END;
$$;
 B   DROP FUNCTION public.aggiorna_stato_proposta_da_controproposta();
       public          postgres    false                        1255    16686    aggiorna_stato_visita()    FUNCTION     P  CREATE FUNCTION public.aggiorna_stato_visita() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.stato_approvazione_agente = 'Accettata' THEN
        NEW.stato_visita := 'Completata';
    ELSIF NEW.stato_approvazione_agente = 'Rifiutata' THEN
        NEW.stato_visita := 'Annullata';
    END IF;

    RETURN NEW;
END;
$$;
 .   DROP FUNCTION public.aggiorna_stato_visita();
       public          postgres    false                       1255    16695    check_proposta_accettata()    FUNCTION     �  CREATE FUNCTION public.check_proposta_accettata() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    proposta_accettata INT;
BEGIN
    -- Controlla se esiste già una proposta "accettata" per lo stesso immobile
    SELECT COUNT(*) INTO proposta_accettata 
    FROM proposta 
    WHERE id_immobile_proposta = NEW.id_immobile_proposta 
      AND stato_proposta = 'Accettata';

    -- Se esiste una proposta accettata, impedisce l'inserimento e mostra il messaggio
    IF proposta_accettata > 0 THEN
        RAISE EXCEPTION 'Un''altra proposta è già stata accettata, presto l''immobile verrà eliminato.';
    END IF;

    RETURN NEW;
END;
$$;
 1   DROP FUNCTION public.check_proposta_accettata();
       public          postgres    false                       1255    16699    check_proposta_in_attesa()    FUNCTION     �  CREATE FUNCTION public.check_proposta_in_attesa() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    proposta_attesa INT;
BEGIN
    -- Controlla se esiste già una proposta in "attesa" per lo stesso immobile e per lo stesso utente
    SELECT COUNT(*) INTO proposta_attesa 
    FROM proposta 
    WHERE id_immobile_proposta = NEW.id_immobile_proposta 
      AND username_utente_proposta = NEW.username_utente_proposta
      AND stato_proposta = 'In attesa';

    -- Se esiste una proposta in attesa per lo stesso utente, impedisce l'inserimento
    IF proposta_attesa > 0 THEN
        RAISE EXCEPTION 'Hai già una proposta in attesa per questo immobile. Attendi la conferma o il rifiuto prima di farne una nuova.';
    END IF;

    RETURN NEW;
END;
$$;
 1   DROP FUNCTION public.check_proposta_in_attesa();
       public          postgres    false            �            1255    16684    elimina_proposte_altri_stati()    FUNCTION     �  CREATE FUNCTION public.elimina_proposte_altri_stati() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verifica se lo stato della proposta è stato cambiato in 'accettata'
    IF NEW.stato_proposta = 'Accettata' THEN
        -- Elimina tutte le altre proposte per lo stesso immobile, tranne quella appena accettata
        DELETE FROM proposta
        WHERE id_immobile_proposta = NEW.id_immobile_proposta
          AND id_proposta <> NEW.id_proposta;
    END IF;
    RETURN NEW;
END;
$$;
 5   DROP FUNCTION public.elimina_proposte_altri_stati();
       public          postgres    false            �            1255    16680    elimina_proposte_utente()    FUNCTION       CREATE FUNCTION public.elimina_proposte_utente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM proposta WHERE username_utente_proposta = OLD.username_utente
        OR username_agente_controproposta = OLD.username_utente;
    RETURN OLD;
END;
$$;
 0   DROP FUNCTION public.elimina_proposte_utente();
       public          postgres    false            �            1255    16678    elimina_visite_utente()    FUNCTION     �   CREATE FUNCTION public.elimina_visite_utente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM visita WHERE username_utente = OLD.username_utente;
    RETURN OLD;
END;
$$;
 .   DROP FUNCTION public.elimina_visite_utente();
       public          postgres    false            �            1255    16675 /   impedisci_cancellazione_immobile_con_proposta()    FUNCTION     O  CREATE FUNCTION public.impedisci_cancellazione_immobile_con_proposta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM proposta WHERE id_immobile_proposta = OLD.id_immobile) THEN
        RAISE EXCEPTION 'Non puoi cancellare un immobile che ha proposte in corso.';
    END IF;
    RETURN OLD;
END;
$$;
 F   DROP FUNCTION public.impedisci_cancellazione_immobile_con_proposta();
       public          postgres    false            �            1255    16673 (   impedisci_modifica_prezzo_con_proposta()    FUNCTION     �  CREATE FUNCTION public.impedisci_modifica_prezzo_con_proposta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verifica se esistono proposte per l'immobile
    IF EXISTS (SELECT 1 FROM proposta WHERE id_immobile_proposta = OLD.id_immobile) THEN
        RAISE EXCEPTION 'Non puoi modificare il prezzo dell''immobile perché ci sono proposte in corso.';
    END IF;
    RETURN NEW;
END;
$$;
 ?   DROP FUNCTION public.impedisci_modifica_prezzo_con_proposta();
       public          postgres    false            �            1255    16669    log_modifica()    FUNCTION     '  CREATE FUNCTION public.log_modifica() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Inserisce una nuova riga nella tabella 'modifica' per mantenere lo storico
    INSERT INTO modifica (
        id_immobile, username_utente, data_modifica, ora_modifica,
        nuovo_tipo_contratto, nuova_tipologia_immobile, nuovo_titolo, nuovo_testo,
        nuova_superficie, nuovo_prezzo, nuovo_id_indirizzo_immobile,
        nuovo_id_filtro_avanzato, nuovo_id_servizio_ulteriore
    )
    VALUES (
        OLD.id_immobile, NEW.username_agente, CURRENT_DATE, CURRENT_TIME,
        NEW.tipo_contratto, NEW.tipologia_immobile, NEW.titolo, NEW.testo,
        NEW.superficie, NEW.prezzo, NEW.id_indirizzo_immobile,
        NEW.id_filtro_avanzato, NEW.id_servizio_ulteriore
    );
    
    RETURN NEW;
END;
$$;
 %   DROP FUNCTION public.log_modifica();
       public          postgres    false            �            1255    16676 #   registra_modifica_immobile_agente()    FUNCTION     �  CREATE FUNCTION public.registra_modifica_immobile_agente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO modifica (
        id_immobile, username_utente, data_modifica, ora_modifica,
        nuovo_tipo_contratto, nuova_tipologia_immobile, nuovo_titolo, nuovo_testo,
        nuova_superficie, nuovo_prezzo, nuovo_id_indirizzo_immobile,
        nuovo_id_filtro_avanzato, nuovo_id_servizio_ulteriore
    )
    VALUES (
        OLD.id_immobile, NEW.username_agente, CURRENT_DATE, CURRENT_TIME,
        NEW.tipo_contratto, NEW.tipologia_immobile, NEW.titolo, NEW.testo,
        NEW.superficie, NEW.prezzo, NEW.id_indirizzo_immobile,
        NEW.id_filtro_avanzato, NEW.id_servizio_ulteriore
    );
    RETURN NEW;
END;
$$;
 :   DROP FUNCTION public.registra_modifica_immobile_agente();
       public          postgres    false            �            1255    16671    verifica_immobili_agente()    FUNCTION     Z  CREATE FUNCTION public.verifica_immobili_agente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verifica se l'agente ha immobili
    IF EXISTS (SELECT 1 FROM immobile WHERE username_agente = OLD.username_utente) THEN
        RAISE EXCEPTION 'Non puoi eliminare un agente con immobili attivi.';
    END IF;

    RETURN OLD;
END;
$$;
 1   DROP FUNCTION public.verifica_immobili_agente();
       public          postgres    false            �            1255    16682    verifica_ruolo_agente()    FUNCTION     ]  CREATE FUNCTION public.verifica_ruolo_agente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verifica se l'utente ha il ruolo di 'Agente'
    IF (SELECT id_ruolo FROM utente WHERE username_utente = NEW.username_agente) <> 3 THEN
        RAISE EXCEPTION 'Solo un agente può inserire un immobile.';
    END IF;
    RETURN NEW;
END;
$$;
 .   DROP FUNCTION public.verifica_ruolo_agente();
       public          postgres    false                       1255    16690    verifica_stato_proposta()    FUNCTION     �  CREATE FUNCTION public.verifica_stato_proposta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Controlla se lo stato della proposta è "Accettata" o "Rifiutata"
    IF OLD.stato_proposta = 'Accettata' OR OLD.stato_proposta = 'Rifiutata' THEN
        RAISE EXCEPTION 'Non è possibile effettuare una controproposta: la proposta è già stata %.', OLD.stato_proposta;
    END IF;

    RETURN NEW;
END;
$$;
 0   DROP FUNCTION public.verifica_stato_proposta();
       public          postgres    false            �            1259    16409    filtro_avanzato    TABLE     6  CREATE TABLE public.filtro_avanzato (
    id_filtro_avanzato integer NOT NULL,
    tipologia_immobile character varying(255),
    stanza integer,
    piano integer,
    bagno integer,
    parcheggio character varying(255),
    classe_energetica character varying(10),
    CONSTRAINT check_parcheggio CHECK (((parcheggio)::text = ANY (ARRAY[('Box privato'::character varying)::text, ('Posto auto riservato'::character varying)::text, ('Posto auto libero'::character varying)::text, ('Posto bici'::character varying)::text, ('Posto moto'::character varying)::text]))),
    CONSTRAINT chk_classe_energetica CHECK (((classe_energetica)::text = ANY (ARRAY[('A'::character varying)::text, ('B'::character varying)::text, ('C'::character varying)::text, ('D'::character varying)::text, ('E'::character varying)::text, ('F'::character varying)::text, ('G'::character varying)::text]))),
    CONSTRAINT filtro_avanzato_bagno_check CHECK ((bagno >= 0)),
    CONSTRAINT filtro_avanzato_piano_check CHECK ((piano >= 0)),
    CONSTRAINT filtro_avanzato_stanza_check CHECK ((stanza >= 0))
);
 #   DROP TABLE public.filtro_avanzato;
       public         heap    postgres    false            �            1259    16419 &   filtro_avanzato_id_filtro_avanzato_seq    SEQUENCE     �   CREATE SEQUENCE public.filtro_avanzato_id_filtro_avanzato_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 =   DROP SEQUENCE public.filtro_avanzato_id_filtro_avanzato_seq;
       public          postgres    false    215            +           0    0 &   filtro_avanzato_id_filtro_avanzato_seq    SEQUENCE OWNED BY     q   ALTER SEQUENCE public.filtro_avanzato_id_filtro_avanzato_seq OWNED BY public.filtro_avanzato.id_filtro_avanzato;
          public          postgres    false    216            �            1259    16420    foto    TABLE     �   CREATE TABLE public.foto (
    id_foto integer NOT NULL,
    id_immobile integer NOT NULL,
    percorso_file text NOT NULL,
    ordine integer DEFAULT 1
);
    DROP TABLE public.foto;
       public         heap    postgres    false            �            1259    16426    foto_id_foto_seq    SEQUENCE     �   CREATE SEQUENCE public.foto_id_foto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.foto_id_foto_seq;
       public          postgres    false    217            ,           0    0    foto_id_foto_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.foto_id_foto_seq OWNED BY public.foto.id_foto;
          public          postgres    false    218            �            1259    16427    immobile    TABLE     	  CREATE TABLE public.immobile (
    id_immobile integer NOT NULL,
    data_creazione date DEFAULT CURRENT_DATE,
    ora_creazione time without time zone DEFAULT CURRENT_TIME,
    username_agente character varying(15),
    tipo_contratto character varying(20),
    tipologia_immobile character varying(255),
    titolo character varying(255),
    testo text,
    superficie double precision,
    prezzo double precision,
    id_indirizzo_immobile integer,
    id_filtro_avanzato integer,
    id_servizio_ulteriore integer,
    CONSTRAINT chk_data_creazione CHECK ((data_creazione <= CURRENT_DATE)),
    CONSTRAINT chk_prezzo_positive CHECK (((prezzo IS NULL) OR (prezzo > (0)::double precision))),
    CONSTRAINT immobile_prezzo_check CHECK ((prezzo > (0)::double precision)),
    CONSTRAINT immobile_superficie_check CHECK ((superficie > (0)::double precision)),
    CONSTRAINT immobile_tipo_contratto_check CHECK (((tipo_contratto)::text = ANY (ARRAY[('Vendita'::character varying)::text, ('Affitto'::character varying)::text])))
);
    DROP TABLE public.immobile;
       public         heap    postgres    false            �            1259    16439    immobile_id_immobile_seq    SEQUENCE     �   CREATE SEQUENCE public.immobile_id_immobile_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.immobile_id_immobile_seq;
       public          postgres    false    219            -           0    0    immobile_id_immobile_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.immobile_id_immobile_seq OWNED BY public.immobile.id_immobile;
          public          postgres    false    220            �            1259    16440 	   indirizzo    TABLE     �   CREATE TABLE public.indirizzo (
    id_indirizzo integer NOT NULL,
    "città" character varying(255),
    provincia character varying(255),
    via character varying(255),
    cap character varying(10)
);
    DROP TABLE public.indirizzo;
       public         heap    postgres    false            �            1259    16445    indirizzo_id_indirizzo_seq    SEQUENCE     �   CREATE SEQUENCE public.indirizzo_id_indirizzo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.indirizzo_id_indirizzo_seq;
       public          postgres    false    221            .           0    0    indirizzo_id_indirizzo_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.indirizzo_id_indirizzo_seq OWNED BY public.indirizzo.id_indirizzo;
          public          postgres    false    222            �            1259    16446    modifica    TABLE     (  CREATE TABLE public.modifica (
    id_modifica integer NOT NULL,
    id_immobile integer NOT NULL,
    username_utente character varying(15) NOT NULL,
    data_modifica date DEFAULT CURRENT_DATE,
    ora_modifica time without time zone DEFAULT CURRENT_TIME,
    nuovo_tipo_contratto character varying(20),
    nuova_tipologia_immobile character varying(255),
    nuovo_titolo character varying(255),
    nuovo_testo text,
    nuova_superficie double precision,
    nuovo_prezzo double precision,
    nuovo_id_indirizzo_immobile integer,
    nuovo_id_filtro_avanzato integer,
    nuovo_id_servizio_ulteriore integer,
    CONSTRAINT modifica_nuova_superficie_check CHECK ((nuova_superficie > (0)::double precision)),
    CONSTRAINT modifica_nuovo_prezzo_check CHECK ((nuovo_prezzo > (0)::double precision))
);
    DROP TABLE public.modifica;
       public         heap    postgres    false            �            1259    16455    modifica_id_modifica_seq    SEQUENCE     �   CREATE SEQUENCE public.modifica_id_modifica_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.modifica_id_modifica_seq;
       public          postgres    false    223            /           0    0    modifica_id_modifica_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.modifica_id_modifica_seq OWNED BY public.modifica.id_modifica;
          public          postgres    false    224            �            1259    16456    proposta    TABLE     �  CREATE TABLE public.proposta (
    id_proposta integer NOT NULL,
    id_immobile_proposta integer,
    vecchio_prezzo double precision,
    nuovo_prezzo double precision,
    stato_proposta character varying(50) DEFAULT 'In attesa'::character varying,
    data_proposta date,
    ora_proposta time without time zone,
    username_utente_proposta character varying(15),
    username_agente_controproposta character varying(15),
    controproposta double precision,
    stato_controproposta character varying(50),
    CONSTRAINT chk_controproposta_positive CHECK (((controproposta IS NULL) OR (controproposta > (0)::double precision))),
    CONSTRAINT chk_proposta CHECK (((stato_proposta)::text = ANY ((ARRAY['Accettata'::character varying, 'Rifiutata'::character varying, 'In attesa'::character varying, 'Controproposta'::character varying])::text[]))),
    CONSTRAINT chk_vecchio_nuovo_prezzo_different CHECK ((vecchio_prezzo <> nuovo_prezzo))
);
    DROP TABLE public.proposta;
       public         heap    postgres    false            �            1259    16463    proposta_id_proposta_seq    SEQUENCE     �   CREATE SEQUENCE public.proposta_id_proposta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.proposta_id_proposta_seq;
       public          postgres    false    225            0           0    0    proposta_id_proposta_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.proposta_id_proposta_seq OWNED BY public.proposta.id_proposta;
          public          postgres    false    226            �            1259    16464    ricerca    TABLE     {   CREATE TABLE public.ricerca (
    id_ricerca integer NOT NULL,
    id_indirizzo integer,
    id_filtro_avanzato integer
);
    DROP TABLE public.ricerca;
       public         heap    postgres    false            �            1259    16467    ricerca_id_ricerca_seq    SEQUENCE     �   CREATE SEQUENCE public.ricerca_id_ricerca_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.ricerca_id_ricerca_seq;
       public          postgres    false    227            1           0    0    ricerca_id_ricerca_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.ricerca_id_ricerca_seq OWNED BY public.ricerca.id_ricerca;
          public          postgres    false    228            �            1259    16468    ruolo    TABLE     E  CREATE TABLE public.ruolo (
    id_ruolo integer NOT NULL,
    nome_ruolo character varying(50),
    CONSTRAINT chk_ruolo CHECK (((nome_ruolo)::text = ANY (ARRAY[('Amministratore'::character varying)::text, ('Gestore'::character varying)::text, ('Agente'::character varying)::text, ('Utente'::character varying)::text])))
);
    DROP TABLE public.ruolo;
       public         heap    postgres    false            �            1259    16472    ruolo_id_ruolo_seq    SEQUENCE     �   CREATE SEQUENCE public.ruolo_id_ruolo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.ruolo_id_ruolo_seq;
       public          postgres    false    229            2           0    0    ruolo_id_ruolo_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.ruolo_id_ruolo_seq OWNED BY public.ruolo.id_ruolo;
          public          postgres    false    230            �            1259    16473    servizio_ulteriore    TABLE       CREATE TABLE public.servizio_ulteriore (
    id_servizio_ulteriore integer NOT NULL,
    climatizzatore boolean,
    balcone boolean,
    portineria boolean,
    giardino boolean,
    ascensore boolean,
    arredato boolean,
    id_filtro_avanzato integer
);
 &   DROP TABLE public.servizio_ulteriore;
       public         heap    postgres    false            �            1259    16476 ,   servizio_ulteriore_id_servizio_ulteriore_seq    SEQUENCE     �   CREATE SEQUENCE public.servizio_ulteriore_id_servizio_ulteriore_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 C   DROP SEQUENCE public.servizio_ulteriore_id_servizio_ulteriore_seq;
       public          postgres    false    231            3           0    0 ,   servizio_ulteriore_id_servizio_ulteriore_seq    SEQUENCE OWNED BY     }   ALTER SEQUENCE public.servizio_ulteriore_id_servizio_ulteriore_seq OWNED BY public.servizio_ulteriore.id_servizio_ulteriore;
          public          postgres    false    232            �            1259    16477    utente    TABLE     �  CREATE TABLE public.utente (
    username_utente character varying(15) NOT NULL,
    password character varying(15) NOT NULL,
    id_ruolo integer DEFAULT 4 NOT NULL,
    nome character varying(20) NOT NULL,
    cognome character varying(20) NOT NULL,
    email character varying(255) NOT NULL,
    CONSTRAINT chk_email_format CHECK (((email)::text ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'::text))
);
    DROP TABLE public.utente;
       public         heap    postgres    false            �            1259    16482    visita    TABLE     �  CREATE TABLE public.visita (
    id_visita integer NOT NULL,
    id_immobile integer,
    username_utente character varying(15),
    data_visita date,
    ora_visita time without time zone,
    stato_visita character varying(255),
    stato_approvazione_agente character varying(50),
    username_agente_approvazione character varying(15),
    CONSTRAINT chk_stato_approvazione_agente CHECK (((stato_approvazione_agente)::text = ANY (ARRAY[('Accettata'::character varying)::text, ('Rifiutata'::character varying)::text, ('In attesa'::character varying)::text]))),
    CONSTRAINT chk_stato_visita CHECK (((stato_visita)::text = ANY (ARRAY[('In attesa'::character varying)::text, ('Completata'::character varying)::text, ('Annullata'::character varying)::text])))
);
    DROP TABLE public.visita;
       public         heap    postgres    false            �            1259    16487    visita_id_visita_seq    SEQUENCE     �   CREATE SEQUENCE public.visita_id_visita_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.visita_id_visita_seq;
       public          postgres    false    234            4           0    0    visita_id_visita_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.visita_id_visita_seq OWNED BY public.visita.id_visita;
          public          postgres    false    235                       2604    16488 "   filtro_avanzato id_filtro_avanzato    DEFAULT     �   ALTER TABLE ONLY public.filtro_avanzato ALTER COLUMN id_filtro_avanzato SET DEFAULT nextval('public.filtro_avanzato_id_filtro_avanzato_seq'::regclass);
 Q   ALTER TABLE public.filtro_avanzato ALTER COLUMN id_filtro_avanzato DROP DEFAULT;
       public          postgres    false    216    215                       2604    16489    foto id_foto    DEFAULT     l   ALTER TABLE ONLY public.foto ALTER COLUMN id_foto SET DEFAULT nextval('public.foto_id_foto_seq'::regclass);
 ;   ALTER TABLE public.foto ALTER COLUMN id_foto DROP DEFAULT;
       public          postgres    false    218    217            !           2604    16490    immobile id_immobile    DEFAULT     |   ALTER TABLE ONLY public.immobile ALTER COLUMN id_immobile SET DEFAULT nextval('public.immobile_id_immobile_seq'::regclass);
 C   ALTER TABLE public.immobile ALTER COLUMN id_immobile DROP DEFAULT;
       public          postgres    false    220    219            $           2604    16491    indirizzo id_indirizzo    DEFAULT     �   ALTER TABLE ONLY public.indirizzo ALTER COLUMN id_indirizzo SET DEFAULT nextval('public.indirizzo_id_indirizzo_seq'::regclass);
 E   ALTER TABLE public.indirizzo ALTER COLUMN id_indirizzo DROP DEFAULT;
       public          postgres    false    222    221            %           2604    16492    modifica id_modifica    DEFAULT     |   ALTER TABLE ONLY public.modifica ALTER COLUMN id_modifica SET DEFAULT nextval('public.modifica_id_modifica_seq'::regclass);
 C   ALTER TABLE public.modifica ALTER COLUMN id_modifica DROP DEFAULT;
       public          postgres    false    224    223            (           2604    16493    proposta id_proposta    DEFAULT     |   ALTER TABLE ONLY public.proposta ALTER COLUMN id_proposta SET DEFAULT nextval('public.proposta_id_proposta_seq'::regclass);
 C   ALTER TABLE public.proposta ALTER COLUMN id_proposta DROP DEFAULT;
       public          postgres    false    226    225            *           2604    16494    ricerca id_ricerca    DEFAULT     x   ALTER TABLE ONLY public.ricerca ALTER COLUMN id_ricerca SET DEFAULT nextval('public.ricerca_id_ricerca_seq'::regclass);
 A   ALTER TABLE public.ricerca ALTER COLUMN id_ricerca DROP DEFAULT;
       public          postgres    false    228    227            +           2604    16495    ruolo id_ruolo    DEFAULT     p   ALTER TABLE ONLY public.ruolo ALTER COLUMN id_ruolo SET DEFAULT nextval('public.ruolo_id_ruolo_seq'::regclass);
 =   ALTER TABLE public.ruolo ALTER COLUMN id_ruolo DROP DEFAULT;
       public          postgres    false    230    229            ,           2604    16496 (   servizio_ulteriore id_servizio_ulteriore    DEFAULT     �   ALTER TABLE ONLY public.servizio_ulteriore ALTER COLUMN id_servizio_ulteriore SET DEFAULT nextval('public.servizio_ulteriore_id_servizio_ulteriore_seq'::regclass);
 W   ALTER TABLE public.servizio_ulteriore ALTER COLUMN id_servizio_ulteriore DROP DEFAULT;
       public          postgres    false    232    231            .           2604    16497    visita id_visita    DEFAULT     t   ALTER TABLE ONLY public.visita ALTER COLUMN id_visita SET DEFAULT nextval('public.visita_id_visita_seq'::regclass);
 ?   ALTER TABLE public.visita ALTER COLUMN id_visita DROP DEFAULT;
       public          postgres    false    235    234                      0    16409    filtro_avanzato 
   TABLE DATA           �   COPY public.filtro_avanzato (id_filtro_avanzato, tipologia_immobile, stanza, piano, bagno, parcheggio, classe_energetica) FROM stdin;
    public          postgres    false    215   �                 0    16420    foto 
   TABLE DATA           K   COPY public.foto (id_foto, id_immobile, percorso_file, ordine) FROM stdin;
    public          postgres    false    217   ��                 0    16427    immobile 
   TABLE DATA           �   COPY public.immobile (id_immobile, data_creazione, ora_creazione, username_agente, tipo_contratto, tipologia_immobile, titolo, testo, superficie, prezzo, id_indirizzo_immobile, id_filtro_avanzato, id_servizio_ulteriore) FROM stdin;
    public          postgres    false    219   0�                 0    16440 	   indirizzo 
   TABLE DATA           P   COPY public.indirizzo (id_indirizzo, "città", provincia, via, cap) FROM stdin;
    public          postgres    false    221   N�                 0    16446    modifica 
   TABLE DATA           )  COPY public.modifica (id_modifica, id_immobile, username_utente, data_modifica, ora_modifica, nuovo_tipo_contratto, nuova_tipologia_immobile, nuovo_titolo, nuovo_testo, nuova_superficie, nuovo_prezzo, nuovo_id_indirizzo_immobile, nuovo_id_filtro_avanzato, nuovo_id_servizio_ulteriore) FROM stdin;
    public          postgres    false    223   F�                 0    16456    proposta 
   TABLE DATA           �   COPY public.proposta (id_proposta, id_immobile_proposta, vecchio_prezzo, nuovo_prezzo, stato_proposta, data_proposta, ora_proposta, username_utente_proposta, username_agente_controproposta, controproposta, stato_controproposta) FROM stdin;
    public          postgres    false    225   t�                 0    16464    ricerca 
   TABLE DATA           O   COPY public.ricerca (id_ricerca, id_indirizzo, id_filtro_avanzato) FROM stdin;
    public          postgres    false    227   h�                 0    16468    ruolo 
   TABLE DATA           5   COPY public.ruolo (id_ruolo, nome_ruolo) FROM stdin;
    public          postgres    false    229   ��                  0    16473    servizio_ulteriore 
   TABLE DATA           �   COPY public.servizio_ulteriore (id_servizio_ulteriore, climatizzatore, balcone, portineria, giardino, ascensore, arredato, id_filtro_avanzato) FROM stdin;
    public          postgres    false    231   ��       "          0    16477    utente 
   TABLE DATA           [   COPY public.utente (username_utente, password, id_ruolo, nome, cognome, email) FROM stdin;
    public          postgres    false    233   &�       #          0    16482    visita 
   TABLE DATA           �   COPY public.visita (id_visita, id_immobile, username_utente, data_visita, ora_visita, stato_visita, stato_approvazione_agente, username_agente_approvazione) FROM stdin;
    public          postgres    false    234   ��       5           0    0 &   filtro_avanzato_id_filtro_avanzato_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public.filtro_avanzato_id_filtro_avanzato_seq', 16, true);
          public          postgres    false    216            6           0    0    foto_id_foto_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.foto_id_foto_seq', 15, true);
          public          postgres    false    218            7           0    0    immobile_id_immobile_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.immobile_id_immobile_seq', 16, true);
          public          postgres    false    220            8           0    0    indirizzo_id_indirizzo_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.indirizzo_id_indirizzo_seq', 12, true);
          public          postgres    false    222            9           0    0    modifica_id_modifica_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.modifica_id_modifica_seq', 12, true);
          public          postgres    false    224            :           0    0    proposta_id_proposta_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.proposta_id_proposta_seq', 17, true);
          public          postgres    false    226            ;           0    0    ricerca_id_ricerca_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.ricerca_id_ricerca_seq', 1, false);
          public          postgres    false    228            <           0    0    ruolo_id_ruolo_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.ruolo_id_ruolo_seq', 4, true);
          public          postgres    false    230            =           0    0 ,   servizio_ulteriore_id_servizio_ulteriore_seq    SEQUENCE SET     [   SELECT pg_catalog.setval('public.servizio_ulteriore_id_servizio_ulteriore_seq', 16, true);
          public          postgres    false    232            >           0    0    visita_id_visita_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.visita_id_visita_seq', 3, true);
          public          postgres    false    235            C           2606    16499 $   filtro_avanzato filtro_avanzato_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.filtro_avanzato
    ADD CONSTRAINT filtro_avanzato_pkey PRIMARY KEY (id_filtro_avanzato);
 N   ALTER TABLE ONLY public.filtro_avanzato DROP CONSTRAINT filtro_avanzato_pkey;
       public            postgres    false    215            E           2606    16501    foto foto_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.foto
    ADD CONSTRAINT foto_pkey PRIMARY KEY (id_foto);
 8   ALTER TABLE ONLY public.foto DROP CONSTRAINT foto_pkey;
       public            postgres    false    217            G           2606    16503    immobile immobile_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.immobile
    ADD CONSTRAINT immobile_pkey PRIMARY KEY (id_immobile);
 @   ALTER TABLE ONLY public.immobile DROP CONSTRAINT immobile_pkey;
       public            postgres    false    219            K           2606    16505    indirizzo indirizzo_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.indirizzo
    ADD CONSTRAINT indirizzo_pkey PRIMARY KEY (id_indirizzo);
 B   ALTER TABLE ONLY public.indirizzo DROP CONSTRAINT indirizzo_pkey;
       public            postgres    false    221            O           2606    16507    modifica modifica_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.modifica
    ADD CONSTRAINT modifica_pkey PRIMARY KEY (id_modifica);
 @   ALTER TABLE ONLY public.modifica DROP CONSTRAINT modifica_pkey;
       public            postgres    false    223            Q           2606    16509    proposta proposta_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.proposta
    ADD CONSTRAINT proposta_pkey PRIMARY KEY (id_proposta);
 @   ALTER TABLE ONLY public.proposta DROP CONSTRAINT proposta_pkey;
       public            postgres    false    225            S           2606    16511    ricerca ricerca_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ricerca
    ADD CONSTRAINT ricerca_pkey PRIMARY KEY (id_ricerca);
 >   ALTER TABLE ONLY public.ricerca DROP CONSTRAINT ricerca_pkey;
       public            postgres    false    227            U           2606    16513    ruolo ruolo_nome_ruolo_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.ruolo
    ADD CONSTRAINT ruolo_nome_ruolo_key UNIQUE (nome_ruolo);
 D   ALTER TABLE ONLY public.ruolo DROP CONSTRAINT ruolo_nome_ruolo_key;
       public            postgres    false    229            W           2606    16515    ruolo ruolo_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.ruolo
    ADD CONSTRAINT ruolo_pkey PRIMARY KEY (id_ruolo);
 :   ALTER TABLE ONLY public.ruolo DROP CONSTRAINT ruolo_pkey;
       public            postgres    false    229            Y           2606    16517 *   servizio_ulteriore servizio_ulteriore_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public.servizio_ulteriore
    ADD CONSTRAINT servizio_ulteriore_pkey PRIMARY KEY (id_servizio_ulteriore);
 T   ALTER TABLE ONLY public.servizio_ulteriore DROP CONSTRAINT servizio_ulteriore_pkey;
       public            postgres    false    231            [           2606    16519    utente uk_email 
   CONSTRAINT     K   ALTER TABLE ONLY public.utente
    ADD CONSTRAINT uk_email UNIQUE (email);
 9   ALTER TABLE ONLY public.utente DROP CONSTRAINT uk_email;
       public            postgres    false    233            M           2606    16521    indirizzo uk_indirizzo_unico 
   CONSTRAINT     p   ALTER TABLE ONLY public.indirizzo
    ADD CONSTRAINT uk_indirizzo_unico UNIQUE ("città", provincia, via, cap);
 F   ALTER TABLE ONLY public.indirizzo DROP CONSTRAINT uk_indirizzo_unico;
       public            postgres    false    221    221    221    221            I           2606    16523    immobile uk_titolo 
   CONSTRAINT     O   ALTER TABLE ONLY public.immobile
    ADD CONSTRAINT uk_titolo UNIQUE (titolo);
 <   ALTER TABLE ONLY public.immobile DROP CONSTRAINT uk_titolo;
       public            postgres    false    219            ]           2606    16525    utente utente_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.utente
    ADD CONSTRAINT utente_pkey PRIMARY KEY (username_utente);
 <   ALTER TABLE ONLY public.utente DROP CONSTRAINT utente_pkey;
       public            postgres    false    233            _           2606    16527    visita visita_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.visita
    ADD CONSTRAINT visita_pkey PRIMARY KEY (id_visita);
 <   ALTER TABLE ONLY public.visita DROP CONSTRAINT visita_pkey;
       public            postgres    false    234            }           2620    16681 "   utente trg_elimina_proposte_utente    TRIGGER     �   CREATE TRIGGER trg_elimina_proposte_utente AFTER DELETE ON public.utente FOR EACH ROW EXECUTE FUNCTION public.elimina_proposte_utente();
 ;   DROP TRIGGER trg_elimina_proposte_utente ON public.utente;
       public          postgres    false    233    242            ~           2620    16679     utente trg_elimina_visite_utente    TRIGGER     �   CREATE TRIGGER trg_elimina_visite_utente AFTER DELETE ON public.utente FOR EACH ROW EXECUTE FUNCTION public.elimina_visite_utente();
 9   DROP TRIGGER trg_elimina_visite_utente ON public.utente;
       public          postgres    false    241    233            t           2620    16670    immobile trg_log_modifica    TRIGGER     u   CREATE TRIGGER trg_log_modifica AFTER UPDATE ON public.immobile FOR EACH ROW EXECUTE FUNCTION public.log_modifica();
 2   DROP TRIGGER trg_log_modifica ON public.immobile;
       public          postgres    false    219    236            x           2620    16689 (   proposta trigger_aggiorna_stato_proposta    TRIGGER     �   CREATE TRIGGER trigger_aggiorna_stato_proposta BEFORE UPDATE ON public.proposta FOR EACH ROW EXECUTE FUNCTION public.aggiorna_stato_proposta();
 A   DROP TRIGGER trigger_aggiorna_stato_proposta ON public.proposta;
       public          postgres    false    257    225            y           2620    16692 :   proposta trigger_aggiorna_stato_proposta_da_controproposta    TRIGGER     �   CREATE TRIGGER trigger_aggiorna_stato_proposta_da_controproposta BEFORE UPDATE OF stato_controproposta ON public.proposta FOR EACH ROW EXECUTE FUNCTION public.aggiorna_stato_proposta_da_controproposta();
 S   DROP TRIGGER trigger_aggiorna_stato_proposta_da_controproposta ON public.proposta;
       public          postgres    false    225    259    225            �           2620    16687 $   visita trigger_aggiorna_stato_visita    TRIGGER     �   CREATE TRIGGER trigger_aggiorna_stato_visita BEFORE UPDATE ON public.visita FOR EACH ROW WHEN (((old.stato_approvazione_agente)::text IS DISTINCT FROM (new.stato_approvazione_agente)::text)) EXECUTE FUNCTION public.aggiorna_stato_visita();
 =   DROP TRIGGER trigger_aggiorna_stato_visita ON public.visita;
       public          postgres    false    234    256    234                       2620    16672 *   utente trigger_blocca_cancellazione_agente    TRIGGER     �   CREATE TRIGGER trigger_blocca_cancellazione_agente BEFORE DELETE ON public.utente FOR EACH ROW EXECUTE FUNCTION public.verifica_immobili_agente();
 C   DROP TRIGGER trigger_blocca_cancellazione_agente ON public.utente;
       public          postgres    false    237    233            z           2620    16696 )   proposta trigger_check_proposta_accettata    TRIGGER     �   CREATE TRIGGER trigger_check_proposta_accettata BEFORE INSERT ON public.proposta FOR EACH ROW EXECUTE FUNCTION public.check_proposta_accettata();
 B   DROP TRIGGER trigger_check_proposta_accettata ON public.proposta;
       public          postgres    false    260    225            {           2620    16700 )   proposta trigger_check_proposta_in_attesa    TRIGGER     �   CREATE TRIGGER trigger_check_proposta_in_attesa BEFORE INSERT ON public.proposta FOR EACH ROW EXECUTE FUNCTION public.check_proposta_in_attesa();
 B   DROP TRIGGER trigger_check_proposta_in_attesa ON public.proposta;
       public          postgres    false    225    261            |           2620    16685 -   proposta trigger_elimina_proposte_altri_stati    TRIGGER     	  CREATE TRIGGER trigger_elimina_proposte_altri_stati AFTER UPDATE ON public.proposta FOR EACH ROW WHEN ((((old.stato_proposta)::text <> 'Accettata'::text) AND ((new.stato_proposta)::text = 'Accettata'::text))) EXECUTE FUNCTION public.elimina_proposte_altri_stati();
 F   DROP TRIGGER trigger_elimina_proposte_altri_stati ON public.proposta;
       public          postgres    false    254    225    225            u           2620    16674 (   immobile trigger_impendi_modifica_prezzo    TRIGGER     �   CREATE TRIGGER trigger_impendi_modifica_prezzo BEFORE UPDATE ON public.immobile FOR EACH ROW WHEN ((old.prezzo <> new.prezzo)) EXECUTE FUNCTION public.impedisci_modifica_prezzo_con_proposta();
 A   DROP TRIGGER trigger_impendi_modifica_prezzo ON public.immobile;
       public          postgres    false    219    219    238            v           2620    16677 2   immobile trigger_registra_modifica_immobile_agente    TRIGGER     �   CREATE TRIGGER trigger_registra_modifica_immobile_agente AFTER UPDATE ON public.immobile FOR EACH ROW WHEN (((new.username_agente)::text IS DISTINCT FROM (old.username_agente)::text)) EXECUTE FUNCTION public.registra_modifica_immobile_agente();
 K   DROP TRIGGER trigger_registra_modifica_immobile_agente ON public.immobile;
       public          postgres    false    219    219    240            w           2620    16683 &   immobile trigger_verifica_ruolo_agente    TRIGGER     �   CREATE TRIGGER trigger_verifica_ruolo_agente BEFORE INSERT ON public.immobile FOR EACH ROW EXECUTE FUNCTION public.verifica_ruolo_agente();
 ?   DROP TRIGGER trigger_verifica_ruolo_agente ON public.immobile;
       public          postgres    false    243    219            `           2606    16537    foto foto_id_immobile_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.foto
    ADD CONSTRAINT foto_id_immobile_fkey FOREIGN KEY (id_immobile) REFERENCES public.immobile(id_immobile) ON DELETE CASCADE;
 D   ALTER TABLE ONLY public.foto DROP CONSTRAINT foto_id_immobile_fkey;
       public          postgres    false    217    3655    219            a           2606    16542 )   immobile immobile_id_filtro_avanzato_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.immobile
    ADD CONSTRAINT immobile_id_filtro_avanzato_fkey FOREIGN KEY (id_filtro_avanzato) REFERENCES public.filtro_avanzato(id_filtro_avanzato) ON DELETE CASCADE;
 S   ALTER TABLE ONLY public.immobile DROP CONSTRAINT immobile_id_filtro_avanzato_fkey;
       public          postgres    false    215    219    3651            b           2606    16547 ,   immobile immobile_id_indirizzo_immobile_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.immobile
    ADD CONSTRAINT immobile_id_indirizzo_immobile_fkey FOREIGN KEY (id_indirizzo_immobile) REFERENCES public.indirizzo(id_indirizzo) ON DELETE CASCADE;
 V   ALTER TABLE ONLY public.immobile DROP CONSTRAINT immobile_id_indirizzo_immobile_fkey;
       public          postgres    false    3659    219    221            c           2606    16552 ,   immobile immobile_id_servizio_ulteriore_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.immobile
    ADD CONSTRAINT immobile_id_servizio_ulteriore_fkey FOREIGN KEY (id_servizio_ulteriore) REFERENCES public.servizio_ulteriore(id_servizio_ulteriore) ON DELETE CASCADE;
 V   ALTER TABLE ONLY public.immobile DROP CONSTRAINT immobile_id_servizio_ulteriore_fkey;
       public          postgres    false    231    3673    219            d           2606    16557 &   immobile immobile_username_agente_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.immobile
    ADD CONSTRAINT immobile_username_agente_fkey FOREIGN KEY (username_agente) REFERENCES public.utente(username_utente) ON DELETE CASCADE;
 P   ALTER TABLE ONLY public.immobile DROP CONSTRAINT immobile_username_agente_fkey;
       public          postgres    false    219    233    3677            e           2606    16562 "   modifica modifica_id_immobile_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.modifica
    ADD CONSTRAINT modifica_id_immobile_fkey FOREIGN KEY (id_immobile) REFERENCES public.immobile(id_immobile) ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.modifica DROP CONSTRAINT modifica_id_immobile_fkey;
       public          postgres    false    3655    223    219            f           2606    16567 /   modifica modifica_nuovo_id_filtro_avanzato_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.modifica
    ADD CONSTRAINT modifica_nuovo_id_filtro_avanzato_fkey FOREIGN KEY (nuovo_id_filtro_avanzato) REFERENCES public.filtro_avanzato(id_filtro_avanzato) ON DELETE CASCADE;
 Y   ALTER TABLE ONLY public.modifica DROP CONSTRAINT modifica_nuovo_id_filtro_avanzato_fkey;
       public          postgres    false    223    215    3651            g           2606    16572 2   modifica modifica_nuovo_id_indirizzo_immobile_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.modifica
    ADD CONSTRAINT modifica_nuovo_id_indirizzo_immobile_fkey FOREIGN KEY (nuovo_id_indirizzo_immobile) REFERENCES public.indirizzo(id_indirizzo) ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.modifica DROP CONSTRAINT modifica_nuovo_id_indirizzo_immobile_fkey;
       public          postgres    false    223    221    3659            h           2606    16577 2   modifica modifica_nuovo_id_servizio_ulteriore_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.modifica
    ADD CONSTRAINT modifica_nuovo_id_servizio_ulteriore_fkey FOREIGN KEY (nuovo_id_servizio_ulteriore) REFERENCES public.servizio_ulteriore(id_servizio_ulteriore) ON DELETE CASCADE;
 \   ALTER TABLE ONLY public.modifica DROP CONSTRAINT modifica_nuovo_id_servizio_ulteriore_fkey;
       public          postgres    false    3673    231    223            i           2606    16582 &   modifica modifica_username_utente_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.modifica
    ADD CONSTRAINT modifica_username_utente_fkey FOREIGN KEY (username_utente) REFERENCES public.utente(username_utente) ON DELETE CASCADE;
 P   ALTER TABLE ONLY public.modifica DROP CONSTRAINT modifica_username_utente_fkey;
       public          postgres    false    233    223    3677            j           2606    16587 +   proposta proposta_id_immobile_proposta_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.proposta
    ADD CONSTRAINT proposta_id_immobile_proposta_fkey FOREIGN KEY (id_immobile_proposta) REFERENCES public.immobile(id_immobile) ON DELETE CASCADE;
 U   ALTER TABLE ONLY public.proposta DROP CONSTRAINT proposta_id_immobile_proposta_fkey;
       public          postgres    false    225    219    3655            k           2606    16592 5   proposta proposta_username_agente_controproposta_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.proposta
    ADD CONSTRAINT proposta_username_agente_controproposta_fkey FOREIGN KEY (username_agente_controproposta) REFERENCES public.utente(username_utente) ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.proposta DROP CONSTRAINT proposta_username_agente_controproposta_fkey;
       public          postgres    false    233    3677    225            l           2606    16597 /   proposta proposta_username_utente_proposta_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.proposta
    ADD CONSTRAINT proposta_username_utente_proposta_fkey FOREIGN KEY (username_utente_proposta) REFERENCES public.utente(username_utente) ON DELETE CASCADE;
 Y   ALTER TABLE ONLY public.proposta DROP CONSTRAINT proposta_username_utente_proposta_fkey;
       public          postgres    false    225    3677    233            m           2606    16602 '   ricerca ricerca_id_filtro_avanzato_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ricerca
    ADD CONSTRAINT ricerca_id_filtro_avanzato_fkey FOREIGN KEY (id_filtro_avanzato) REFERENCES public.filtro_avanzato(id_filtro_avanzato) ON DELETE CASCADE;
 Q   ALTER TABLE ONLY public.ricerca DROP CONSTRAINT ricerca_id_filtro_avanzato_fkey;
       public          postgres    false    215    227    3651            n           2606    16607 !   ricerca ricerca_id_indirizzo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ricerca
    ADD CONSTRAINT ricerca_id_indirizzo_fkey FOREIGN KEY (id_indirizzo) REFERENCES public.indirizzo(id_indirizzo) ON DELETE CASCADE;
 K   ALTER TABLE ONLY public.ricerca DROP CONSTRAINT ricerca_id_indirizzo_fkey;
       public          postgres    false    221    3659    227            o           2606    16612 =   servizio_ulteriore servizio_ulteriore_id_filtro_avanzato_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.servizio_ulteriore
    ADD CONSTRAINT servizio_ulteriore_id_filtro_avanzato_fkey FOREIGN KEY (id_filtro_avanzato) REFERENCES public.filtro_avanzato(id_filtro_avanzato) ON DELETE CASCADE;
 g   ALTER TABLE ONLY public.servizio_ulteriore DROP CONSTRAINT servizio_ulteriore_id_filtro_avanzato_fkey;
       public          postgres    false    215    3651    231            p           2606    16617    utente utente_id_ruolo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.utente
    ADD CONSTRAINT utente_id_ruolo_fkey FOREIGN KEY (id_ruolo) REFERENCES public.ruolo(id_ruolo) ON DELETE CASCADE;
 E   ALTER TABLE ONLY public.utente DROP CONSTRAINT utente_id_ruolo_fkey;
       public          postgres    false    229    3671    233            q           2606    16622    visita visita_id_immobile_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.visita
    ADD CONSTRAINT visita_id_immobile_fkey FOREIGN KEY (id_immobile) REFERENCES public.immobile(id_immobile) ON DELETE CASCADE;
 H   ALTER TABLE ONLY public.visita DROP CONSTRAINT visita_id_immobile_fkey;
       public          postgres    false    3655    234    219            r           2606    16627 /   visita visita_username_agente_approvazione_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.visita
    ADD CONSTRAINT visita_username_agente_approvazione_fkey FOREIGN KEY (username_agente_approvazione) REFERENCES public.utente(username_utente) ON DELETE CASCADE;
 Y   ALTER TABLE ONLY public.visita DROP CONSTRAINT visita_username_agente_approvazione_fkey;
       public          postgres    false    233    234    3677            s           2606    16632 "   visita visita_username_utente_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.visita
    ADD CONSTRAINT visita_username_utente_fkey FOREIGN KEY (username_utente) REFERENCES public.utente(username_utente) ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.visita DROP CONSTRAINT visita_username_utente_fkey;
       public          postgres    false    233    234    3677               �   x�m�A�0E�3��	�u	\��+7i�$hI���;"�������?����:���=����n� 7֛8H�2�@��}��AzF�B�4,l��j�v���HK6�H�%n�b�'�n]�l���I\`��W�ZQ�켪ՙ!R�������{������
z)d*         H  x���I�� �1.F�ƿ��@��v����ʌ�6���8q�އC)������1�Ն��W���]�|�7I{�2���K�)�ch�>��X����j
��x��])���b��sz�1�W��2\8�vr�)$a>�.��1z�N�|</�q�*�|���7�Gׇ��X�Ղ�m�s%8L��U�%�eOī]��@��9���~*�����h���p%W���K,�`p;�j�$�Lt4F��/S��N*)S�0��g��Uτ6OZ֬�b>6��	�0�h�+g������|�g�������ꖂ��Y����*�O�4�_�?�         	  x��XK��6]S��d�H��Uuٞ��OE����(HF�R��j�1�Y�f�7����I����nU�J"�O���^b��|�݄~�,�̖��4]-��"�F� ��˭N>)�ӕL>ic�w��vA
)>�R&?+#��y%v��?���o�c���cq��謖�ڊSP�Vx��k++'��(}%Ke�!誦/qsm�8;�y�Nٳ��D��R�R��*+
g�:�
��.�娼(~�X=�8��uY*����P9�i��q�wu>K�Ӽ10#�ֶ���x\b���;_��a\��$�O�|5��dA�Q�w�]�J�l�O6�u:˦�7�S�b��>h���xա@��G,պ�%��(4ت��_!˭�=�{uEq����ΖO&��B�<;��O.6+��d�8�@���uP���`x�@[�w@pv��j��~�������_��j�4h0e�<�P�5����ӣ�
�X`'G-N�걘��<�[i�5�X@dxa�S伨9Bi%y6�,!_�(�����* �v\]�J#�H?�v��K��pMvFOҜ��!`L|uP�.�x�3X%��B�o% e �s���>;��Ba�O���\������0�=p��5� �Ba�|7�@pFV�8�)RXp� �$A1&sz�f�O��_��{���$@��Ͷ�[�&���/)��q�E�][��]=��2N�A��a��gI%�^����@n��|ˉE`�4�̎a��������0�!\���=�B��0��{��^P 0&��]Q����~�.կ'���G��G�"b�M��bG�u�@ۡ��1/�K�Pl@�1�/��1�-�.�ͪ�W%�.��HW�d	v?ɂ��s�,$�	�jF�Q6�$[$��&_n&�t1�e��d��~�A�"9UP�~�GgtY���/2�>i�F�vC�k34�R�@��q���C��
DI��}�w��EA_�m�ű[�-'!�uGKَ	>���gJ�s/��
��pL*��#��d꒢T��`>]��L���%K��jԖԄ	���<�����O��"*(�r�s����F���X@7��&����t�^���ǆ{R���"�LԹľE���G@a;�hۅ3����C�h�yҞꓥ�Mɍ��'�`~Na>��6�@�h3�3��-
BU�4� q
�I���0�T��h=0Za�k��y����T�D"���x�Ȋ�e���q�'��d�~���+(�FB}w����v����I�|�/�<�kj��͂�Sqa�+W�,��8��G�$l��"���5Z_p�J��f��d�e��[�a3B͓��nX�o��W�
��Σ�$���0B/0�m0 ��� �TQ�����=��!�5�ܵ4��#�,���(bW�)��`�G���O� 觸�9��Z���=92-�/1�]]ytgP���$CN�T�E4UD��wu4HAEsI�X��{�]4L���5Zڗ�f���g�j�/gD�o��|���' ���j �b�~���0�0,�xE �$(�k� ���6n��l��h�O���X��_�*��1�1w���9��qٰ��~���Ѯ��1+�E��%��L"���
�W<p�������<�WD�F�����7@�Y1q筇��Oc�����0� E���vb�b2���~��A�9qZ��9f��fOT��&�X��ړ���}���M���_��E̞�FR���&Ol"��{@";pه�Y�tSB�,��=��Dcc����w8�^��e��U6nA�+�C}�ҧ愠d�\�-:�8�Ė�Stō�J�UE=�<ʞ���"�%;�S{[n�iy��s�;9SI2Qv�u~� ≅u��}|�@�4�*�
�H�8n��r��{�S��ܙ&k���tI�Q���þ���u�h�w���`I��cԡ���k���ysA��0����.-�@��oG�к�����+$�����ӟ��\Ul�{-���M>� ��u���pTA�[K���<�ƶ?��(�_�gSNm����շ��k��u��,���8<N��N���$pޗ��e:�qR���C(������Y<���NԔ�4��{�V�%>�,��[��}	��k�S�qH1S�-$d�}�i�<�jB�c�|8��Q�J ����j�zKq=�#j�z�A>��w���A��P��k�8 6�7t��=`�B�Uey�����7=Ƞ��g�H[�8�֬ϡ��ܾ��_�bG'��6|��x�Ο�62	���{��Ƽ�oc�4v�5��3�J �i�Q簱�}NG�����Z�         �   x�u��j�0E�3_�/(�v�e1i(�i	ƫn&��2㴋~}e�]t}w��6D����V��ʊ4M��@�$d�=A�dI�Axªh M�a���G`���p�^Y�Y1`sJ���pn�cP�wVuZSeq�w_���>�a�b�Up��,i#���g8�w5�-'�S߬KяI�����r�Y~�++c�g1/ix�rch��so��g�,��1�.Jp�߂/w��	$u[�         	  x��Y˲��]�_1@� �D^�������D%;^���C�� 5 XW����/d�?ɗ�t� H\���da�,Q�`��>���a���MU�r����Y2[�J���U�$��!����f��~4�j=��պ0em��9���v��{)��L�.m��)���U�w�ҹ�LfK\s$,Sx�t�����(*UU#lTѡ������G[��Ɗ�C�VU����@օ]�&�R#�a���5Fe�-��u��k;U[�]՞JS�NcK#�:��w垪�T��M�v�y��ɖ��uT�Aw�y8���|��8�ڸt~��_�
<�qj�:�d�+�YO�d�8Z/��2��	^�Y4������<�)����H$J�]n��2�k�q�Ꮠ����d�|Y�#Yu �v�Z�U7�3V�y(��iuFnT(�Ŗ���Ό��fL��l)���Z�aH�$���n��E��#:�J�Q�>���>!C��Tn'Aq���_������nx�
KJ,xO[���aY�8�^�"p�g�y���A�3��9�XbΤ���t19.�$��('�HT�9\�Q]�C��|��2de$�π�#��8K%�KȾ9�.�����Lº�qgƑ�n0�),m��=$e@r+­	��-�΋�(�%�*��.�5YD���'���-t����Cf@Fz-0����x`ڜ����5��`�Ԅ��Ўሷ��������p�=�@��JS�7'^�B���NN퐯�����8:y�#Τ�%	��^#)�T~KT_q�E�!��ޙ�`K0�ׅ�o�6��^�?�H�c`��R�!qm�I�;rBd�Ղ�׀���?u��&�ay�R"�o�ۚ�ĩE��9G�"�oN��m��rX��N�+"n���B�k���ۼ�_�R��@����*��xO(��r�7;ܰ�A@��!:��q=��>hg��+��86�m��q���,�+��5YF�r�q��J�WXI�� z_$Vs�Uh�z�{�z�e��Л���	f0ؚ[j����$7lJ�Ճ��_�5$�nvd;�ﺞ�\��b�� CNFN��R�w"�|f%�Ƒa�k�!xC�v ����O0H~w`�"�}L�`��y�-k[f\��������Jtko]Y^&�� ��*��Q�pK#z��5n}�-�}p��n���Eq4P��� [$��T��X����P�<[��gGk���k��M�"��s���QS2�r����L �(��^���/`�2�l���=D��,�m�E=,P� �,,	�KOGyzg�p��.������.��f�x3[������G��^@:)S��B��y]`\I�\�=�Y���� ��˅�; ��.���El𽒋AW5Te%�����`،r6��td5������Y���Z+�`Ŕ�:�<?D�ۡ�����3�����(��9Ϭ�&���[�3Lh�㊣��|�K$){�.+ ��'v�O썯����bJ,�#���x��Z�x�f�}nr��`�R6��D�'�۩/�;׎�G��K�u�r.�}��>_=([D����$3������X}��0̨HBh.'��	�M+)�J����,�Uz����o���<6K�q[Ht���Vn}��%]<��x�I����Cw���\����H�����Y/�b�Db�d��`4l~��E��sӁy]�A�W�{�R/�S��0L"�O뿘�W�s�����o��VWm������<���l�Z��:^��t�Lu�(��oq���A\�zH�8]���Bj��)�ЪÙܻ�Y9���[��(�ЯTt�Rfx��������Ҽ��A� ��w�^��L��!�al�Ҿ�Y%�����8n)j�:ذO��OTӶ���`�5�F~��-��Z�J�ٗ���Ψ�1`�Oֶ�,���G#��cׁ�)�fF��`4xSeySщ��K�X��4�=��H�-őo�� ]���b.a8��=�L��G���!I��"Y�6ϜM>:4��@v�Zwǔ�;��!'��H����!5y���	T����O�i�^� ;���E��Kqm7^�Ŕ���9az�V�u�<�Y�;��2V?Ƿx�ѓ3<[��H���̟�m@�z#��'F��e8������䇅vNd%p���X9�3N@ӷg��,J���5O1��t���P�g�[O!��".��r;>��+��>�B^��_��#G���e����CÝ,Ҿ'��߅SY��(�X��I�99)���T�6�͘��FN;��(������u�����r����S<�L���%         �   x����N�0@g�+�����q�l�������+(�jQ�J|>�'D��p�%KN��l�p�����KI%�E�O�OĀQ�c#\��������O�h�Apcx��s~��1��0{=B� `�a��#�4�D��&���!'�Mc�;/��B�y��1-��F��Ԡ���KC�,i���%���8ޥR�%5$�5!Y��X{C� m�������{��]߆z��{6M�|�[}S            x������ � �         3   x�3�t�����,.)J,�/J�2�tO-��9�S�JR�L8CK��=... ��0          N   x�U��	 !C�}�Tj�]��	ܟ�rJIH�D�>�.�Xx�1B;�o��'5�+g�Gۓ�h�"-'�4�}���"�      "   �   x�U��
�0Eד�	X��V���Bp�fڎu0�D��i-�n8��K�P�F�����E�U{{hV��nx2��t?��,�у�j�aL���@�{�f��KS��(���C`h)D/�
��׬�"����B:�@3Zv9���_�.����j�v&�	�jG����.?^���x��a���������d��o����]+���j�D      #   t   x�3�4�L1)����+��4202�50�54�44�20 "N��܂�ԒĒDN����0+1'��81/�(1)�ː��&3��Jsr@�2�2K1�0&h�g�BbIIjq"ň=... R�<�     
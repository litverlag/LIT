--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.4
-- Dumped by pg_dump version 9.5.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: postgres; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE active_admin_comments (
    id integer NOT NULL,
    namespace character varying,
    body text,
    resource_id character varying NOT NULL,
    resource_type character varying NOT NULL,
    author_id integer,
    author_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE active_admin_comments_id_seq OWNED BY active_admin_comments.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    vorname character varying DEFAULT ''::character varying NOT NULL,
    nachname character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    lektor_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: admin_users_departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_users_departments (
    admin_user_id integer NOT NULL,
    department_id integer NOT NULL
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_users_id_seq OWNED BY admin_users.id;


--
-- Name: autoren; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE autoren (
    id integer NOT NULL,
    fox_id character varying,
    anrede character varying,
    vorname character varying,
    name character varying,
    email character varying,
    str character varying,
    plz character varying,
    ort character varying,
    tel character varying,
    fax character varying,
    institut character varying,
    dienstadresse boolean,
    demail character varying,
    dstr character varying,
    dplz character varying,
    dort character varying,
    dtel character varying,
    dfax character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: autoren_buecher; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE autoren_buecher (
    autor_id integer NOT NULL,
    buch_id integer NOT NULL
);


--
-- Name: autoren_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE autoren_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: autoren_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE autoren_id_seq OWNED BY autoren.id;


--
-- Name: autoren_reihen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE autoren_reihen (
    autor_id integer NOT NULL,
    reihe_id integer NOT NULL
);


--
-- Name: buecher; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE buecher (
    id integer NOT NULL,
    autor_id integer,
    lektor_id integer,
    gprod_id integer,
    name character varying,
    isbn character varying,
    issn character varying,
    titel1 text,
    titel2 text,
    titel3 text,
    utitel1 text,
    utitel2 text,
    utitel3 text,
    seiten integer,
    preis numeric(6,2),
    spreis numeric(6,2),
    sammelband boolean DEFAULT false,
    erscheinungsjahr date,
    gewicht double precision,
    volumen double precision,
    format_bezeichnung character varying,
    umschlag_bezeichnung character varying,
    papier_bezeichnung character varying,
    bindung_bezeichnung character varying,
    vier_farb character varying,
    rueckenstaerke double precision,
    klappentext boolean,
    eintrag_cip_seite boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sw character varying,
    r_code character varying
);


--
-- Name: buecher_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE buecher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: buecher_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE buecher_id_seq OWNED BY buecher.id;


--
-- Name: buecher_reihen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE buecher_reihen (
    buch_id integer NOT NULL,
    reihe_id integer NOT NULL
);


--
-- Name: departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE departments (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE departments_id_seq OWNED BY departments.id;


--
-- Name: faecher; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE faecher (
    id integer NOT NULL,
    name character varying,
    fox_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: faecher_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE faecher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: faecher_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE faecher_id_seq OWNED BY faecher.id;


--
-- Name: gprods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE gprods (
    id integer NOT NULL,
    lektor_id integer,
    autor_id integer,
    final_deadline date,
    zum_druck date,
    druck_deadline date,
    titelei_deadline date,
    satz_deadline date,
    preps_deadline date,
    offsch_deadline date,
    bildpr_deadline date,
    umschlag_deadline date,
    rg_deadline date,
    binderei_deadline date,
    projekt_abgeschlossen boolean DEFAULT false,
    projekt_email_adresse character varying,
    projektname character varying,
    auflage integer,
    erscheinungsjahr date,
    kommentar_public text,
    manusskript_eingang_date date,
    auflage_lektor integer,
    auflage_chef integer,
    gesicherte_abnahme integer,
    satzproduktion boolean DEFAULT false,
    buchistfertig boolean DEFAULT false,
    externer_druck boolean DEFAULT false,
    externer_druck_verschickt_von integer,
    externer_druck_verschickt date,
    buchgedruckt boolean DEFAULT false,
    druck_bemerkungen text,
    pod_verschickt date,
    pod_meldung character varying,
    titelei_bemerkungen text,
    titelei_zusaetze character varying,
    titelei_extern boolean DEFAULT false,
    titelei_letzte_korrektur date,
    titelei_versand_datum_fuer_ueberpr date,
    titelei_versand_an_zur_ueberpf character varying,
    titelei_korrektur_date date,
    titelei_freigabe_date date,
    satz_bemerkungen text,
    preps_bemerkungen text,
    preps_betreuer character varying,
    druck_art character varying,
    muster_art character varying,
    muster_gedruckt character varying,
    preps_muster_bemerkungen text,
    preps_muster_date date,
    offsch_bemerkungen text,
    offsch_an_autor character varying,
    offsch_an_sch_mit_u character varying,
    bildpr_bemerkungen text,
    umschlag_bemerkungen text,
    umschlag_schutzumschlag boolean DEFAULT false,
    umschlag_umschlagsbild character varying,
    rg_bemerkungen text,
    rg_rg_mail character varying,
    rg_versand_1 date,
    rg_versand_2 date,
    rg_bezahlt boolean DEFAULT false,
    rg_vf boolean DEFAULT false,
    binderei_eingang_datum date,
    binderei_bemerkungen text,
    prio character varying,
    lektor_bemerkungen_public text,
    lektor_bemerkungen_private text,
    dateibue character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    bilder character varying
);


--
-- Name: gprods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gprods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gprods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gprods_id_seq OWNED BY gprods.id;


--
-- Name: lektoren; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE lektoren (
    id integer NOT NULL,
    name character varying,
    titel character varying,
    "position" character varying,
    emailkuerzel character varying,
    fox_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lektoren_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lektoren_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lektoren_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lektoren_id_seq OWNED BY lektoren.id;


--
-- Name: reihen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE reihen (
    id integer NOT NULL,
    name character varying,
    r_code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reihen_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reihen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reihen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reihen_id_seq OWNED BY reihen.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: status_bildpr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE status_bildpr (
    id integer NOT NULL,
    gprod_id integer,
    status character varying,
    updated_by character varying,
    updated_at date
);


--
-- Name: status_bildpr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_bildpr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: status_bildpr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_bildpr_id_seq OWNED BY status_bildpr.id;


--
-- Name: status_binderei; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE status_binderei (
    id integer NOT NULL,
    gprod_id integer,
    status character varying,
    updated_by character varying,
    updated_at date
);


--
-- Name: status_binderei_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_binderei_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: status_binderei_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_binderei_id_seq OWNED BY status_binderei.id;


--
-- Name: status_druck; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE status_druck (
    id integer NOT NULL,
    gprod_id integer,
    status character varying,
    updated_by character varying,
    updated_at date
);


--
-- Name: status_druck_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_druck_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: status_druck_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_druck_id_seq OWNED BY status_druck.id;


--
-- Name: status_final; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE status_final (
    id integer NOT NULL,
    gprod_id integer,
    freigabe boolean DEFAULT false,
    freigabe_at date,
    status character varying,
    updated_by character varying,
    updated_at date
);


--
-- Name: status_final_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_final_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: status_final_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_final_id_seq OWNED BY status_final.id;


--
-- Name: status_offsch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE status_offsch (
    id integer NOT NULL,
    gprod_id integer,
    status character varying,
    updated_by character varying,
    updated_at date
);


--
-- Name: status_offsch_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_offsch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: status_offsch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_offsch_id_seq OWNED BY status_offsch.id;


--
-- Name: status_preps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE status_preps (
    id integer NOT NULL,
    gprod_id integer,
    freigabe boolean DEFAULT false,
    freigabe_at date,
    status character varying,
    updated_by character varying,
    updated_at date
);


--
-- Name: status_preps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_preps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: status_preps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_preps_id_seq OWNED BY status_preps.id;


--
-- Name: status_rg; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE status_rg (
    id integer NOT NULL,
    gprod_id integer,
    status character varying,
    updated_by character varying,
    updated_at date
);


--
-- Name: status_rg_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_rg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: status_rg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_rg_id_seq OWNED BY status_rg.id;


--
-- Name: status_satz; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE status_satz (
    id integer NOT NULL,
    gprod_id integer,
    freigabe boolean DEFAULT false,
    freigabe_at date,
    status character varying,
    updated_by character varying,
    updated_at date
);


--
-- Name: status_satz_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_satz_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: status_satz_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_satz_id_seq OWNED BY status_satz.id;


--
-- Name: status_titelei; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE status_titelei (
    id integer NOT NULL,
    gprod_id integer,
    freigabe boolean DEFAULT false,
    freigabe_at date,
    status character varying,
    updated_by character varying,
    updated_at date
);


--
-- Name: status_titelei_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_titelei_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: status_titelei_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_titelei_id_seq OWNED BY status_titelei.id;


--
-- Name: status_umschl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE status_umschl (
    id integer NOT NULL,
    gprod_id integer,
    freigabe boolean DEFAULT false,
    freigabe_at date,
    status character varying,
    updated_by character varying,
    updated_at date
);


--
-- Name: status_umschl_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_umschl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: status_umschl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_umschl_id_seq OWNED BY status_umschl.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('active_admin_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users ALTER COLUMN id SET DEFAULT nextval('admin_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY autoren ALTER COLUMN id SET DEFAULT nextval('autoren_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY buecher ALTER COLUMN id SET DEFAULT nextval('buecher_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY departments ALTER COLUMN id SET DEFAULT nextval('departments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY faecher ALTER COLUMN id SET DEFAULT nextval('faecher_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gprods ALTER COLUMN id SET DEFAULT nextval('gprods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lektoren ALTER COLUMN id SET DEFAULT nextval('lektoren_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reihen ALTER COLUMN id SET DEFAULT nextval('reihen_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_bildpr ALTER COLUMN id SET DEFAULT nextval('status_bildpr_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_binderei ALTER COLUMN id SET DEFAULT nextval('status_binderei_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_druck ALTER COLUMN id SET DEFAULT nextval('status_druck_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_final ALTER COLUMN id SET DEFAULT nextval('status_final_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_offsch ALTER COLUMN id SET DEFAULT nextval('status_offsch_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_preps ALTER COLUMN id SET DEFAULT nextval('status_preps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_rg ALTER COLUMN id SET DEFAULT nextval('status_rg_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_satz ALTER COLUMN id SET DEFAULT nextval('status_satz_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_titelei ALTER COLUMN id SET DEFAULT nextval('status_titelei_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_umschl ALTER COLUMN id SET DEFAULT nextval('status_umschl_id_seq'::regclass);


--
-- Name: active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


--
-- Name: admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: autoren_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY autoren
    ADD CONSTRAINT autoren_pkey PRIMARY KEY (id);


--
-- Name: buecher_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY buecher
    ADD CONSTRAINT buecher_pkey PRIMARY KEY (id);


--
-- Name: departments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: faecher_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY faecher
    ADD CONSTRAINT faecher_pkey PRIMARY KEY (id);


--
-- Name: gprods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gprods
    ADD CONSTRAINT gprods_pkey PRIMARY KEY (id);


--
-- Name: lektoren_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lektoren
    ADD CONSTRAINT lektoren_pkey PRIMARY KEY (id);


--
-- Name: reihen_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reihen
    ADD CONSTRAINT reihen_pkey PRIMARY KEY (id);


--
-- Name: status_bildpr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_bildpr
    ADD CONSTRAINT status_bildpr_pkey PRIMARY KEY (id);


--
-- Name: status_binderei_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_binderei
    ADD CONSTRAINT status_binderei_pkey PRIMARY KEY (id);


--
-- Name: status_druck_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_druck
    ADD CONSTRAINT status_druck_pkey PRIMARY KEY (id);


--
-- Name: status_final_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_final
    ADD CONSTRAINT status_final_pkey PRIMARY KEY (id);


--
-- Name: status_offsch_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_offsch
    ADD CONSTRAINT status_offsch_pkey PRIMARY KEY (id);


--
-- Name: status_preps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_preps
    ADD CONSTRAINT status_preps_pkey PRIMARY KEY (id);


--
-- Name: status_rg_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_rg
    ADD CONSTRAINT status_rg_pkey PRIMARY KEY (id);


--
-- Name: status_satz_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_satz
    ADD CONSTRAINT status_satz_pkey PRIMARY KEY (id);


--
-- Name: status_titelei_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_titelei
    ADD CONSTRAINT status_titelei_pkey PRIMARY KEY (id);


--
-- Name: status_umschl_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_umschl
    ADD CONSTRAINT status_umschl_pkey PRIMARY KEY (id);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_email ON admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON admin_users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20150425001858');

INSERT INTO schema_migrations (version) VALUES ('20150425001900');

INSERT INTO schema_migrations (version) VALUES ('20150426130413');

INSERT INTO schema_migrations (version) VALUES ('20150427235446');

INSERT INTO schema_migrations (version) VALUES ('20150428002426');

INSERT INTO schema_migrations (version) VALUES ('20150428002432');

INSERT INTO schema_migrations (version) VALUES ('20150428005231');

INSERT INTO schema_migrations (version) VALUES ('20150522103842');

INSERT INTO schema_migrations (version) VALUES ('20151009090031');

INSERT INTO schema_migrations (version) VALUES ('20151028165212');

INSERT INTO schema_migrations (version) VALUES ('20151028171313');

INSERT INTO schema_migrations (version) VALUES ('20151028175314');

INSERT INTO schema_migrations (version) VALUES ('20151028175323');

INSERT INTO schema_migrations (version) VALUES ('20151104125038');

INSERT INTO schema_migrations (version) VALUES ('20151104133937');

INSERT INTO schema_migrations (version) VALUES ('20151104133947');

INSERT INTO schema_migrations (version) VALUES ('20151104134000');

INSERT INTO schema_migrations (version) VALUES ('20151104134010');

INSERT INTO schema_migrations (version) VALUES ('20151104134019');

INSERT INTO schema_migrations (version) VALUES ('20151104134031');

INSERT INTO schema_migrations (version) VALUES ('20151104134048');

INSERT INTO schema_migrations (version) VALUES ('20151104134100');

INSERT INTO schema_migrations (version) VALUES ('20151107183205');

INSERT INTO schema_migrations (version) VALUES ('20160418121527');

INSERT INTO schema_migrations (version) VALUES ('20160720141549');

INSERT INTO schema_migrations (version) VALUES ('20160926103039');

INSERT INTO schema_migrations (version) VALUES ('20160926111422');


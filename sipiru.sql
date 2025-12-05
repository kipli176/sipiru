-- Adminer 5.3.0 PostgreSQL 15.4 dump

DROP TABLE IF EXISTS "admin_user";
DROP SEQUENCE IF EXISTS admin_user_id_seq;
CREATE SEQUENCE admin_user_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."admin_user" (
    "id" bigint DEFAULT nextval('admin_user_id_seq') NOT NULL,
    "nama" character varying(255) NOT NULL,
    "username" character varying(100) NOT NULL,
    "pin_hash" character varying(255) NOT NULL,
    "role" admin_role DEFAULT fakultas_admin NOT NULL,
    "fakultas_id" bigint,
    "aktif" boolean DEFAULT true NOT NULL,
    "created_at" timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT "admin_user_pkey" PRIMARY KEY ("id")
)
WITH (oids = false);

CREATE UNIQUE INDEX admin_user_username_key ON public.admin_user USING btree (username);

INSERT INTO "admin_user" ("id", "nama", "username", "pin_hash", "role", "fakultas_id", "aktif", "created_at") VALUES
(1,	'superadmin',	'superadmin',	'123456',	'superadmin',	1,	'1',	'2025-11-28 10:34:23.485255+07');

DROP TABLE IF EXISTS "booking_ruangan";
DROP SEQUENCE IF EXISTS booking_ruangan_id_seq;
CREATE SEQUENCE booking_ruangan_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."booking_ruangan" (
    "id" bigint DEFAULT nextval('booking_ruangan_id_seq') NOT NULL,
    "group_id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "tanggal" date NOT NULL,
    "ruangan_id" bigint NOT NULL,
    "time_slot_id" smallint NOT NULL,
    "jam_mulai" time without time zone NOT NULL,
    "jam_selesai" time without time zone NOT NULL,
    "nama_peminjam" character varying(255) NOT NULL,
    "unit" character varying(255),
    "kegiatan" text NOT NULL,
    "hp" character varying(50),
    "status" booking_status DEFAULT pending NOT NULL,
    "fakultas_peminjam_id" bigint,
    "qr_code" text,
    "created_at" timestamptz DEFAULT now() NOT NULL,
    "approved_by_admin_id" bigint,
    "approved_at" timestamptz,
    "asal_unit" text,
    "asal_eksternal" text,
    "is_active" boolean DEFAULT true,
    CONSTRAINT "booking_ruangan_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "ck_booking_jam_range" CHECK ((jam_mulai < jam_selesai))
)
WITH (oids = false);

CREATE INDEX idx_booking_group ON public.booking_ruangan USING btree (group_id);

CREATE INDEX idx_booking_status ON public.booking_ruangan USING btree (status);

CREATE INDEX idx_booking_ruang_tgl ON public.booking_ruangan USING btree (ruangan_id, tanggal);

CREATE UNIQUE INDEX booking_ruangan_qr_code_key ON public.booking_ruangan USING btree (qr_code);

CREATE UNIQUE INDEX uq_booking_ruang_tgl_slot_active ON public.booking_ruangan USING btree (ruangan_id, tanggal, time_slot_id) WHERE (is_active = true);

CREATE INDEX idx_booking_ruang_tgl_active ON public.booking_ruangan USING btree (ruangan_id, tanggal) WHERE (is_active = true);

CREATE INDEX idx_booking_slot ON public.booking_ruangan USING btree (time_slot_id);

CREATE INDEX idx_booking_full ON public.booking_ruangan USING btree (ruangan_id, tanggal, time_slot_id, is_active);

INSERT INTO "booking_ruangan" ("id", "group_id", "tanggal", "ruangan_id", "time_slot_id", "jam_mulai", "jam_selesai", "nama_peminjam", "unit", "kegiatan", "hp", "status", "fakultas_peminjam_id", "qr_code", "created_at", "approved_by_admin_id", "approved_at", "asal_unit", "asal_eksternal", "is_active") VALUES
(49,	'48349a42-9a9b-4aa9-8c9e-6db027146a1a',	'2025-12-04',	182,	5,	'18:30:00',	'22:00:00',	'Baladewa',	NULL,	'Peresmian',	'08562603077',	'pending',	1,	'iVBORw0KGgoAAAANSUhEUgAAAHsAAAB7AQAAAAB8vMLSAAAB/ElEQVR4nL2VsY7UMBCGf29Omq2SLTlhlJP2CehyCMlUPAM1PADJIiSqJAsNDck9wb0HBcIFkvclVvIq+wDJVVnJ8VAfBZoCMeVInz3/P+OxYjyK0wp/xD9JLErdPBzO+9tlBaXWojMaXja4jthG5GxFyLRG+fz8cDjuDstKXOkdcFdsN4VMyxWA5FsW4otf6V8OfZzIZryzxw+9BpIoQ/ZqafESeNYeTuqVAAEzBwA1JZGY2QuQ0LBubD6SVjZvjQiBGWKR9zZpKdQihDvKI/HkdEpJJBGyd6E2qDhhFzInQFZ4X203F83r4+6ybSUmg7uCRxo6k4wFdxItq6Wlm/sL1Pdwj7P6KrklNDZkDMW+shoi+SFzOpt9M3NnUEnkg0cTFPPkfFlwlPWltznPw2R9arTIZISMfTPnkXiyzLLCokFtANIpQcnGsiRm6+siiRQqEcKjSWIxTC6PxqeyGZtsKE1o7BAJtbAvNuktUPDkEpnJARhaCs3sSxr2QvnI24LZcsQgei9XyOz26c9zSstHd70TDX8ojQaCYp1ZlDLHmAPM0JGvXCil8vNpHmKBymlRX1ZoGLzWn0mn8KVsJ0/rJ5k7xcvQ3wJGuMYxffrxJZ4m9+bta5ljlPezLw3HgjvZwDScs+VISSQInxigU/jGDSNxL0HUf/nEfwPa7iMUHr7G/wAAAABJRU5ErkJggg==',	'2025-12-04 18:11:49.180366+07',	NULL,	NULL,	NULL,	NULL,	'1'),
(51,	'fac01aeb-95a3-4472-941f-c45fb71c141d',	'2025-12-06',	189,	2,	'09:45:00',	'13:00:00',	'Baladewa',	NULL,	'Musyawarah',	'08562603077',	'pending',	1,	NULL,	'2025-12-04 19:44:16.576371+07',	NULL,	NULL,	NULL,	NULL,	'1'),
(50,	'fac01aeb-95a3-4472-941f-c45fb71c141d',	'2025-12-06',	189,	1,	'07:00:00',	'09:45:00',	'Baladewa',	NULL,	'Musyawarah',	'08562603077',	'pending',	1,	'iVBORw0KGgoAAAANSUhEUgAAAHsAAAB7AQAAAAB8vMLSAAAB70lEQVR4nL2VMW4bMRBFP7UCuIBhrQ7AmAJ8CSYNhVS5hy+w6wPsrjpXq+QARs6Rjq6YLnUKAZSZOhBVUQi94yJVUk0RZMCKwCPmz/8kBeGPOi7wV/2TjRchNufLy/2TuIcQNeuMgfBYLx8HdV1rcgwEpZUKVrWgREr4wOx0+BJvLB5rphYA2NUvz08/7jIXaTJ63O6com01cxAUQHX+9wIkQwuIqMCoHhV5IuIgpYU+gU5S7wmChdAuh8ZjoCA8TZaFnCx6Q8nrSaqepaV0Liavhqx6SXuWldWItzeXai3xKYvjljXklSkD0WiqlLkTa6hKPu6zPpk48XwZJSWinQut0TMHWaBJm+tazEav5fGeFRiabdznKrkwZKYvBRKQgNEng5bni3AFJs4InYssX1B6qfc+jlKtJDdjJxtWRvUyJuJqabKegM7r0YaG1xhs6DIGH8lhxbMykd7lmBwEoeMFppehN2GgSI4SD+mc3hElRzOIFRiUHqFxpcuqt7xYLgBzO5pqLfHx6c0zL2NEZaCyQmhlATNj0JMNjSuN573JKAOp1lSjUb0sLF8WSDU+PxxmxPVleTYMLUsAOJurn+9Faw93H7hI+/UwfCN6F/fb7xykyZsbc/VrsSwPouH9YoASPk5WT5Z3K8V/+cRfAYPhHZfknfOuAAAAAElFTkSuQmCC',	'2025-12-04 19:44:16.385323+07',	NULL,	NULL,	NULL,	NULL,	'1'),
(52,	'6696274c-b264-4ef8-b12a-6d17a729f50c',	'2025-12-05',	186,	5,	'18:30:00',	'22:00:00',	'Baladewa',	NULL,	'Peresmian',	'08562603077',	'approved',	3,	'iVBORw0KGgoAAAANSUhEUgAAAHsAAAB7AQAAAAB8vMLSAAACHklEQVR4nL2VsWrcQBCG/9UKVtXp0q+8B/cE7hQI6DqnSxNI7xfwyZVJcbI6N/a9gSFvkDbdCgy6zq8gWwaXXvkw7MFKk9opwhQhUw47zP7/fjMrCO/iIcIf8U8SoxBZ9XEsV0IkQiSMEoSKDLVma01NhtqO03ZIsC3vaPXgMEaciyGslRa2nxRmhRa8LgDOqrG2/eVfTrxPpB7YLYYLLayceCW1gLBaXGWPuwex4mghoiA8AF0RETG0IFQtUisHbxyQcuSDbvJQ+bBBtym6WcFyTGxjSrBv5fxgasvQEoNKwnd5dBw7ZE8/f3AYc8jm9/GQLF6VvNxxTJYfrrrXY6Tt89GhuclZJL9U6jrFaT66++U5j7FZ0TvoypJT5BTDsVjW6+yrAp281cPilONYND7u+vlxH+XP2UlzfcFi7BbxBk+zw/gIved0AU1FWBcdIJ2Sl5zXBw1erwtTe5StGThYRmOa3gnbTOizi+aaB//Q6k2OtO2ADjwsadVH9/Icn0q/AAcYUO3l0BpXyKmQNWteAoqQkt6gA4JgyZd0tTzfdXu7nJRyLMbI5R1ys/VEVta82RceFQHQpQU4WEZyUgEHuaW7WxVKz9z8C6A7bZYOi1vevFRkXGGmvHeK6RiGZJwfxnqrxa/4jANMDEC6z/3wpUmdNN+431pqn2bAWaJfWesCqUe9GudNEEPzwiI5AHqDIKwZvGGtC/FfPvHf+sQLP7D0q2UAAAAASUVORK5CYII=',	'2025-12-05 09:34:40.232037+07',	1,	'2025-12-05 09:34:47.198858+07',	NULL,	NULL,	'1');

DROP TABLE IF EXISTS "fakultas";
DROP SEQUENCE IF EXISTS fakultas_id_seq;
CREATE SEQUENCE fakultas_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."fakultas" (
    "id" bigint DEFAULT nextval('fakultas_id_seq') NOT NULL,
    "kode" character varying(20) NOT NULL,
    "nama" character varying(255) NOT NULL,
    "aktif" boolean DEFAULT true NOT NULL,
    "created_at" timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT "fakultas_pkey" PRIMARY KEY ("id")
)
WITH (oids = false);

CREATE UNIQUE INDEX fakultas_kode_key ON public.fakultas USING btree (kode);

CREATE UNIQUE INDEX fakultas_kode_unique ON public.fakultas USING btree (kode);

CREATE INDEX fakultas_kode_idx ON public.fakultas USING btree (kode);

INSERT INTO "fakultas" ("id", "kode", "nama", "aktif", "created_at") VALUES
(1,	'FEB',	'Fakultas Ekonomi dan Bisnis',	'1',	'2025-11-28 06:37:43.505427+07'),
(3,	'FAPET',	'Fakultas Peternakan',	'1',	'2025-11-28 06:37:43.505427+07'),
(2,	'FT',	'Fakultas Teknik',	'1',	'2025-11-28 06:37:43.505427+07');

DROP TABLE IF EXISTS "jadwal_kuliah";
DROP SEQUENCE IF EXISTS jadwal_kuliah_id_seq;
CREATE SEQUENCE jadwal_kuliah_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."jadwal_kuliah" (
    "id" bigint DEFAULT nextval('jadwal_kuliah_id_seq') NOT NULL,
    "semester_kode" character varying(50) NOT NULL,
    "tanggal_mulai" date NOT NULL,
    "tanggal_selesai" date NOT NULL,
    "hari_dow" smallint NOT NULL,
    "hari_nama" character varying(20) NOT NULL,
    "jam_mulai" time without time zone NOT NULL,
    "jam_selesai" time without time zone NOT NULL,
    "ruangan_id" bigint NOT NULL,
    "mata_kuliah" character varying(255) NOT NULL,
    "kode_mk" character varying(100),
    "kelas" character varying(50),
    "dosen" text,
    "fakultas_id" bigint NOT NULL,
    "created_at" timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT "jadwal_kuliah_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "ck_jadwal_tanggal_range" CHECK ((tanggal_mulai <= tanggal_selesai)),
    CONSTRAINT "ck_jadwal_hari_dow" CHECK (((hari_dow >= 1) AND (hari_dow <= 7))),
    CONSTRAINT "ck_jadwal_jam_range" CHECK ((jam_mulai < jam_selesai))
)
WITH (oids = false);

CREATE INDEX idx_jadwal_ruangan_hari ON public.jadwal_kuliah USING btree (ruangan_id, hari_dow, tanggal_mulai, tanggal_selesai);

CREATE INDEX idx_jadwal_semester ON public.jadwal_kuliah USING btree (semester_kode);

CREATE INDEX idx_jadwal_ruangan_tgl ON public.jadwal_kuliah USING btree (ruangan_id, hari_dow, jam_mulai);

INSERT INTO "jadwal_kuliah" ("id", "semester_kode", "tanggal_mulai", "tanggal_selesai", "hari_dow", "hari_nama", "jam_mulai", "jam_selesai", "ruangan_id", "mata_kuliah", "kode_mk", "kelas", "dosen", "fakultas_id", "created_at") VALUES
(3774,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	186,	'MO Kelanj',	'EW2082/3(3)',	'Man A',	'Daryono, Telma Anis S',	1,	'2025-12-05 10:31:38.580406+07'),
(3775,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	185,	'Man.Biaya',	'EA3070/3(5)',	'Akt B',	'Hijroh R, Laeli B',	1,	'2025-12-05 10:31:38.580406+07'),
(3776,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	183,	'P. Bisnis',	'EK1020/3(1)',	'IESP A',	'Istiqomah, Dijan R',	1,	'2025-12-05 10:31:38.580406+07'),
(3777,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	182,	'Ek.Mon II',	'EP61201/3(5)',	'IESP A',	'Ratna SG, Anzar A',	1,	'2025-12-05 10:31:38.580406+07'),
(3778,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	212,	'Intro To Buss',	'EK1020/3(1)',	'Akt Int',	'Agung P, Aldilla D',	1,	'2025-12-05 10:31:38.580406+07'),
(3779,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	211,	'IntroToBus',	'EK1020/3(1)',	'Mgt Int',	'Adi Indra, Tiladela L',	1,	'2025-12-05 10:31:38.580406+07'),
(3780,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	191,	'P.Bisnis',	'EK1020/3(1)',	'Akt B',	'Adi Wiratno, Agung P',	1,	'2025-12-05 10:31:38.580406+07'),
(3781,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	210,	'TOM Sem',	'EM4508/3(5)',	'Mgt Int',	'Wiwiek RA, Daryono',	1,	'2025-12-05 10:31:38.580406+07'),
(3782,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	203,	'P.Bisnis',	'EK1020/3(1)',	'Akt C',	'Eliada H, Adi W',	1,	'2025-12-05 10:31:38.580406+07'),
(3783,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	184,	'Man.Biaya',	'EA3070/3(5)',	'Akt A',	'Puji L, Umi P',	1,	'2025-12-05 10:31:38.580406+07'),
(3784,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	202,	'MO Kelanj',	'EW2082/3(3)',	'Man C',	'Joni Prayogi, Retno W',	1,	'2025-12-05 10:31:38.580406+07'),
(3785,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	201,	'Man.Biaya',	'EA3070/3(5)',	'Akt C',	'Ady Setyo, Ascaryan',	1,	'2025-12-05 10:31:38.580406+07'),
(3786,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	200,	'P. Bisnis',	'EK1020/3(1)',	'IESP B',	'Irma S, MS Fibrika',	1,	'2025-12-05 10:31:38.580406+07'),
(3787,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	192,	'Ek.Mon II',	'EP61201/3(5)',	'IESP B',	'Ratna SG, Diah SG',	1,	'2025-12-05 10:31:38.580406+07'),
(3788,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	209,	'Public Ec.',	'EP31207/3(3)',	'IESP Int',	'Agus Arifin, Anandhiya I',	1,	'2025-12-05 10:31:38.580406+07'),
(3789,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	207,	'Peng.Mikro',	'KPE184639/3(5)',	'PE A',	'Sofiatul Kh, Laurensia',	1,	'2025-12-05 10:31:38.580406+07'),
(3790,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	208,	'Internal audit',	'EA4200/3(5)',	'Akt Int',	'Khrisnhoe RF, Oman R',	1,	'2025-12-05 10:31:38.580406+07'),
(3792,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	213,	'Intr Finnc sys',	'EP51208(5)',	'IESP Int',	'Arif Andri W, MS Fibrika',	1,	'2025-12-05 10:31:38.580406+07'),
(3793,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	190,	'P.Bisnis',	'EK1020/3(1)',	'Akt A',	'Eliada H, Laeli B',	1,	'2025-12-05 10:31:38.580406+07'),
(3794,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	189,	'P. Bisnis',	'EK1020/3(1)',	'Man B',	'Lusi S, Fitri A',	1,	'2025-12-05 10:31:38.580406+07'),
(3795,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	188,	'P. Bisnis',	'EK1020/3(1)',	'Man A',	'Sri Lestari, Retno W',	1,	'2025-12-05 10:31:38.580406+07'),
(3796,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'07:00:00',	'09:45:00',	187,	'MO Kelanj',	'EW2082/3(3)',	'Man B',	'Bagas G, Joni Prayogi',	1,	'2025-12-05 10:31:38.580406+07'),
(3797,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	182,	'Jatidiri',	'UN114/2(1)',	'Man A',	'Warsidi, Ade Irma A',	1,	'2025-12-05 10:31:38.580406+07'),
(3798,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	211,	'Histori.Thought',	'EP40201/3(3)',	'IESP Int',	'Arintoko, Arif Andri W',	1,	'2025-12-05 10:31:38.580406+07'),
(3799,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	212,	'Acct.for Aset',	'EA20211/3(3)',	'Akt Int',	'Prof.BAP, Christina Tri S',	1,	'2025-12-05 10:31:38.580406+07'),
(3800,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	184,	'P.Ek Makro',	'EK1012/3(1)',	'IESP C',	'Rakhmat P, Ratna SG',	1,	'2025-12-05 10:31:38.580406+07'),
(3801,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	213,	'Intro Buss',	'EK1020/3(1)',	'IESP Int',	'Agung P, Istiqomah',	1,	'2025-12-05 10:31:38.580406+07'),
(3802,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	207,	'Peng.Mikro',	'KPE184639/3(5)',	'PE B',	'Sofiatul Kh, Elsa P',	1,	'2025-12-05 10:31:38.580406+07'),
(3803,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	183,	'Jatidiri',	'UN114/2(1)',	'Man B',	'Arif Andri W, Retno W',	1,	'2025-12-05 10:31:38.580406+07'),
(3804,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	185,	'Sem MSDM',	'EM4364/3(5)',	'Man',	'Akh Sudjadi, Siti Zulaikha',	1,	'2025-12-05 10:31:38.580406+07'),
(3805,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	186,	'Sem MP',	'EM4376/3(5)',	'Man',	'Refius P, Larisa P',	1,	'2025-12-05 10:31:38.580406+07'),
(3806,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	187,	'Sem MO',	'EM4508/3(5)',	'Man',	'Devani L, Telma Anis S',	1,	'2025-12-05 10:31:38.580406+07'),
(3807,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	188,	'Man Ris As',	'EM3230/3(5)',	'Man',	'Sulistyandari, Sri Lestari',	1,	'2025-12-05 10:31:38.580406+07'),
(3808,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	189,	'Aplk.Pros&Pelap',	'EA3112/3(5)',	'Akt A',	'Dewi S, Jenly',	1,	'2025-12-05 10:31:38.580406+07'),
(3809,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	190,	'Aplk.Pros&Pelap',	'EA3112/3(5)',	'Akt B',	'Atiek SP, Riandasa',	1,	'2025-12-05 10:31:38.580406+07'),
(3810,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	191,	'Aplk.Pros&Pelap',	'EA3112/3(5)',	'Akt C',	'Dewi S, Jenly',	1,	'2025-12-05 10:31:38.580406+07'),
(3811,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	192,	'Jatidiri',	'UN114/2(1)',	'Man C',	'Dijan R, Viviana M',	1,	'2025-12-05 10:31:38.580406+07'),
(3812,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	200,	'SPE',	'EP40201/3(3)',	'IESP A',	'Arif Andri W, Pahrul Fauzi',	1,	'2025-12-05 10:31:38.580406+07'),
(3813,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	201,	'SPE',	'EP40201/3(3)',	'IESP B',	'Arintoko, Pahrul Fauzi',	1,	'2025-12-05 10:31:38.580406+07'),
(3814,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	202,	'Statistik 1',	'KPE181315/3(3)',	'PE A',	'Lina RN, Laurensia',	1,	'2025-12-05 10:31:38.580406+07'),
(3815,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	203,	'Statistik 1',	'KPE181315/3(3)',	'PE B',	'Chairani, Ahmad Nasori',	1,	'2025-12-05 10:31:38.580406+07'),
(3816,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	208,	'Service OM',	'EM4510/3(5)',	'Mgt Int',	'Daryono, Adi Indra',	1,	'2025-12-05 10:31:38.580406+07'),
(3817,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	209,	'MarMgtSem',	'EM4376/3(5)',	'Mgt Int',	'Weni N, Alisa TN',	1,	'2025-12-05 10:31:38.580406+07'),
(3818,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'09:45:00',	'13:00:00',	210,	'HRM Sem',	'EM4364/3(5)',	'Mgt Int',	'Akh Sudjadi, Ratno P',	1,	'2025-12-05 10:31:38.580406+07'),
(3819,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	188,	'Akt. Aset Basis',	'EA20211/3(3)',	'Akt C',	'Christina Tri S, Dewi S',	1,	'2025-12-05 10:31:38.580406+07'),
(3820,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	213,	'HR.Ec.',	'EP31206/3(3)',	'IESP Int',	'Ade Banani, Dwita Aprillia',	1,	'2025-12-05 10:31:38.580406+07'),
(3821,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	209,	'Quant.Ec&Buss',	'EK2092/3(3)',	'Akt Int',	'Bb. SBI, Widyahayu',	1,	'2025-12-05 10:31:38.580406+07'),
(3822,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	182,	'SIM',	'EM2260/3(5)',	'Man A',	'Rahab, Bagas G',	1,	'2025-12-05 10:31:38.580406+07'),
(3823,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	210,	'Civic',	'UN107/2(1)',	'Mgt Int',	'Viviana M, Vivana M',	1,	'2025-12-05 10:31:38.580406+07'),
(3824,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	208,	'MIS',	'EM2260/3(5)',	'Mgt Int',	'Bagas G, Rahab',	1,	'2025-12-05 10:31:38.580406+07'),
(3825,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	203,	'Metopen',	'KPE183530/3(5)',	'PE B',	'Viviana M, Dyah Perwita',	1,	'2025-12-05 10:31:38.580406+07'),
(3826,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	202,	'Jati Diri',	'UNO1008/2(1)',	'PE A',	'Arif Andri, Retno Widuri',	1,	'2025-12-05 10:31:38.580406+07'),
(3827,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	201,	'Ek SDM',	'EP31206/3(3)',	'IESP A',	'Goro B, Anandhiya I',	1,	'2025-12-05 10:31:38.580406+07'),
(3828,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	200,	'Ek SDM',	'EP31206/3(3)',	'IESP B',	'Ade Banani, Goro B',	1,	'2025-12-05 10:31:38.580406+07'),
(3829,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	192,	'Peng. Akt I',	'EA1011/3(1)',	'Man D',	'Fitri A, Dwi Astarani',	1,	'2025-12-05 10:31:38.580406+07'),
(3830,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	191,	'Ekmtrka II',	'EP61203/3(5)',	'IESP B',	'Agus Arifin, Chairani F',	1,	'2025-12-05 10:31:38.580406+07'),
(3831,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	190,	'Ekmtrka II',	'EP61203/3(5)',	'IESP A',	'Arintoko, Dicky SR',	1,	'2025-12-05 10:31:38.580406+07'),
(3832,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	189,	'Peng. Akt',	'EW1011/3(1)',	'Man C',	'Agus F, Ronald H',	1,	'2025-12-05 10:31:38.580406+07'),
(3833,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	187,	'Peng. Akt',	'EW1011/3(1)',	'Man B',	'Permata Ulfah, Intan S',	1,	'2025-12-05 10:31:38.580406+07'),
(3834,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	186,	'Peng. Akt',	'EW1011/3(1)',	'Man A',	'Ag. Sunarmo, Wiwiek RA',	1,	'2025-12-05 10:31:38.580406+07'),
(3835,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	185,	'Akt. Aset Basis',	'EA20211/3(3)',	'Akt B',	'Negina KP, Prof.BAP',	1,	'2025-12-05 10:31:38.580406+07'),
(3836,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	211,	'Appl of Proc &',	'EA3112/3(5)',	'Akt Int/Aj',	'Krisnhoe RF, Kikin Windhani',	1,	'2025-12-05 10:31:38.580406+07'),
(3837,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	207,	'Peng.Mikro',	'KPE184639/3(5)',	'PE C',	'Ratu Ayu SW, Viviana M',	1,	'2025-12-05 10:31:38.580406+07'),
(3838,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	184,	'Akt. Aset Basis',	'EA20211/3(3)',	'Akt A',	'Triani A, Wita R',	1,	'2025-12-05 10:31:38.580406+07'),
(3839,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	183,	'SIM',	'EM2260/3(5)',	'Man B',	'Rahab, Joni Prayogi',	1,	'2025-12-05 10:31:38.580406+07'),
(3840,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'13:00:00',	'16:00:00',	212,	'Ecmetrica II',	'EP61203/3(5)',	'IESP Int',	'Agus Arifin, Kikin Windhani',	1,	'2025-12-05 10:31:38.580406+07'),
(3841,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	200,	'Ek Keruangan',	'EP71302/3(7)',	'IESP',	'Abdul Aziz A, Arif Andri W',	1,	'2025-12-05 10:31:38.580406+07'),
(3842,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	207,	'Peng.Mikro',	'KPE184639/3(5)',	'PE D',	'Viviana M, -',	1,	'2025-12-05 10:31:38.580406+07'),
(3843,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	188,	'SisEkIslam',	'EK2130/3(5)',	'Man',	'Najmudin, Dian PJ',	1,	'2025-12-05 10:31:38.580406+07'),
(3844,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	209,	'Bhs.Ing.Bis',	'EM1060/3(3)',	'Mgt Int',	'Laxmi M, Eka Yunita',	1,	'2025-12-05 10:31:38.580406+07'),
(3845,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	208,	'Intr Buss Law',	'EK2120/3(7)',	'IESP Int',	'Rahadi Wasi, Ronald',	1,	'2025-12-05 10:31:38.580406+07'),
(3846,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	187,	'Bhs.Ing.Bis',	'EM1060/3(3)',	'Man B',	'Hanifa P, Nadia GY',	1,	'2025-12-05 10:31:38.580406+07'),
(3847,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	211,	'Geographical Ec',	'EP71302/3(7)',	'IESP Int',	'Abdul Aziz A, Kikin W',	1,	'2025-12-05 10:31:38.580406+07'),
(3848,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	201,	'Kewargaan',	'UN107/2(1)',	'Man C',	'Dyah Perwita, Rifki Ahda S',	1,	'2025-12-05 10:31:38.580406+07'),
(3849,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	184,	'Praktik.Akt.',	'KPE183531/3(5)',	'PE A',	'Ramita K, Febyana',	1,	'2025-12-05 10:31:38.580406+07'),
(3850,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	182,	'Kewargaan',	'UN107/2(1)',	'Akt A',	'Eliada H, Bb Triyono',	1,	'2025-12-05 10:31:38.580406+07'),
(3851,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	190,	'Kewargaan',	'UN107/2(1)',	'Man A',	'Ade Irma A, Dyah Perwita',	1,	'2025-12-05 10:31:38.580406+07'),
(3852,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	189,	'Praktik.Akt.',	'KPE183531/3(5)',	'PE B',	'Ramita K, Dian I',	1,	'2025-12-05 10:31:38.580406+07'),
(3853,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	210,	'Intl Tax',	'EA4250(3)(7)',	'Akt Int',	'Yudha Aryo, Icuk RB',	1,	'2025-12-05 10:31:38.580406+07'),
(3854,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	203,	'Peng.Bisnis',	'KPE181104/3(1)',	'PE B',	'Elsa P, Aldial K',	1,	'2025-12-05 10:31:38.580406+07'),
(3855,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	186,	'Bhs.Ing.Bis',	'EM1060/3(3)',	'Man A',	'Nadia GY, Hanifa P',	1,	'2025-12-05 10:31:38.580406+07'),
(3856,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	192,	'Kewargaan',	'UN107/2(1)',	'Akt C',	'Ade Irma A, Rifki Ahda S',	1,	'2025-12-05 10:31:38.580406+07'),
(3857,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	213,	'Indo Eco',	'EK2100/3(4)',	'Man Int_Aj',	'Farid A, Ahmad Nasori',	1,	'2025-12-05 10:31:38.580406+07'),
(3858,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	183,	'Kewargaan',	'UN107/2(1)',	'Akt B',	'Bb Triyono, Pahrul Fauzi',	1,	'2025-12-05 10:31:38.580406+07'),
(3859,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	212,	'Eng.for Bus.',	'EM1060/3(3)',	'Mgt Int',	'Ashari, Lely Tri W',	1,	'2025-12-05 10:31:38.580406+07'),
(3860,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	191,	'Kewargaan',	'UN107/2(1)',	'Man B',	'Dijan R, Bb. Triono',	1,	'2025-12-05 10:31:38.580406+07'),
(3861,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	202,	'Peng.Bisnis',	'KPE181104/3(1)',	'PE A',	'Sri Lestari, Febyana',	1,	'2025-12-05 10:31:38.580406+07'),
(3862,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	1,	'senin',	'16:00:00',	'18:30:00',	185,	'Peng Hkm Bisnis',	'EK2120/3(7)',	'IESP',	'Rahadi Wasi, Ronald',	1,	'2025-12-05 10:31:38.580406+07'),
(3863,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	183,	'Koprasi&UMKM',	'KPE181105/3(3)',	'PE A',	'Lina RN, Febyana',	1,	'2025-12-05 10:31:38.580406+07'),
(3864,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	192,	'Math. Bisnis',	'EM1050/3(1)',	'Man',	'Alisa TN, Joni P',	1,	'2025-12-05 10:31:38.580406+07'),
(3865,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	215,	'Comp.Fin.Acct',	'EA2023/3(3)',	'Akt Int/Aj',	'Christina Tri S, Warsidi',	1,	'2025-12-05 10:31:38.580406+07'),
(3866,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	211,	'Stra Mgt',	'EM4190/3(5)',	'Mgt Int/Aj',	'Ag. Suroso, Nur Afif',	1,	'2025-12-05 10:31:38.580406+07'),
(3867,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	182,	'EkMakro II',	'EP31202/3(3)',	'IESP C',	'Arintoko, Indrawan F',	1,	'2025-12-05 10:31:38.580406+07'),
(3868,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	213,	'Mon.Ec II',	'EP61201/3(5)',	'IESP Int',	'Arintoko, Diah SG',	1,	'2025-12-05 10:31:38.580406+07'),
(3869,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	200,	'MP Kelanj',	'EW3062/3(3)',	'Man B',	'Lusi S, Alisa TN',	1,	'2025-12-05 10:31:38.580406+07'),
(3870,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	186,	'Sistm.Keu.Inter',	'EP51208(5)',	'IESP B',	'Dijan R, Ajeng FN',	1,	'2025-12-05 10:31:38.580406+07'),
(3871,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	201,	'MP Kelanj',	'EW3062/3(3)',	'Man C',	'Refius P, Isti Riana D',	1,	'2025-12-05 10:31:38.580406+07'),
(3872,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	210,	'IntroToMacro',	'EK1012/3(1)',	'IESP Int',	'Irma S, Barokatuminalloh',	1,	'2025-12-05 10:31:38.580406+07'),
(3873,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	189,	'Impl.PPh&PPN',	'EA2062/3(3)',	'Akt B',	'Icuk RB, Dimas P',	1,	'2025-12-05 10:31:38.580406+07'),
(3874,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	187,	'Koprasi&UMKM',	'KPE181105/3(3)',	'PE B',	'Oki A, Elsa P',	1,	'2025-12-05 10:31:38.580406+07'),
(3875,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	208,	'Sustainable',	'EW3062/3(3)',	'Mgt Int/Aj',	'Tiladela L, Refius P',	1,	'2025-12-05 10:31:38.580406+07'),
(3876,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	184,	'MP Inter',	'EM4513/3(5)',	'Man',	'Lusi S, Larisa P',	1,	'2025-12-05 10:31:38.580406+07'),
(3877,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	188,	'Impl.PPh&PPN',	'EA2062/3(3)',	'Akt A',	'Siti M, Icuk RB',	1,	'2025-12-05 10:31:38.580406+07'),
(3878,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	190,	'Impl.PPh&PPN',	'EA2062/3(3)',	'Akt C',	'Uswatun H, Ady Setyo N',	1,	'2025-12-05 10:31:38.580406+07'),
(3879,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	207,	'Peng.Mikro',	'KPE184639/3(5)',	'PE E',	'Sri Lestari, Lina RN',	1,	'2025-12-05 10:31:38.580406+07'),
(3880,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	203,	'Pancasila',	'UNO181001/2(1)',	'PE B',	'Bb Triyono, Pahrul Fauzi',	1,	'2025-12-05 10:31:38.580406+07'),
(3881,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	209,	'MacroEc II',	'EP31202/3(3)',	'IESP Int',	'Lilis SB, Nurul Anwar',	1,	'2025-12-05 10:31:38.580406+07'),
(3882,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	212,	'Impl.Tax Inc',	'EA2062/3(3)',	'Akt Int',	'Yudha Aryo, Aldilla D',	1,	'2025-12-05 10:31:38.580406+07'),
(3883,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	191,	'MP Kelanj',	'EW3062/3(3)',	'Man A',	'Tiladela L, Larisa P',	1,	'2025-12-05 10:31:38.580406+07'),
(3884,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	202,	'Pancasila',	'UNO181001/2(1)',	'PE A',	'Eliada H, Bb Triyono',	1,	'2025-12-05 10:31:38.580406+07'),
(3885,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'07:00:00',	'09:45:00',	185,	'Sistm.Keu.Inter',	'EP51208(5)',	'IESP A',	'Dijan R, Rinny Zakaria',	1,	'2025-12-05 10:31:38.580406+07'),
(3886,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	209,	'Int.Mark.M',	'EM4513/3(5)',	'Mgt Int/Aj',	'Suliyanto, Alisa TN',	1,	'2025-12-05 10:31:38.580406+07'),
(3887,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	192,	'EkPublik',	'EP31207/3(3)',	'IESP B',	'Agus Arifin, Farid A',	1,	'2025-12-05 10:31:38.580406+07'),
(3888,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	182,	'Metopen',	'EK3110/3(5)',	'Akt A',	'Laeli B, Christina Tri S',	1,	'2025-12-05 10:31:38.580406+07'),
(3889,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	191,	'MO II',	'EM2082/3(3)',	'Man D',	'Joni P, Telma Anis S',	1,	'2025-12-05 10:31:38.580406+07'),
(3890,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	212,	'Peng.Mikro',	'KPE184639/3(5)',	'PE F',	'Sri Lestari, -',	1,	'2025-12-05 10:31:38.580406+07'),
(3891,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	190,	'Ek.Indus I',	'EP51207/3(5)',	'IESP B',	'Abdul Aziz A, Bambang',	1,	'2025-12-05 10:31:38.580406+07'),
(3892,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	211,	'Resch Methd',	'EK3110/3(5)',	'Akt Int',	'Poppy DIK, Dona P',	1,	'2025-12-05 10:31:38.580406+07'),
(3893,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	187,	'P.Ek Makro',	'EK1012/3(1)',	'IESP A',	'Nurul A, Bambang',	1,	'2025-12-05 10:31:38.580406+07'),
(3894,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	208,	'Cap Market',	'EM3240/3(3)',	'Akt Int/Aj',	'Irianing S, Ascaryan',	1,	'2025-12-05 10:31:38.580406+07'),
(3895,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	210,	'Statics Ec.II',	'EK2092/3(3)',	'IESP Int',	'Dwita Aprillia, Chairani F',	1,	'2025-12-05 10:31:38.580406+07'),
(3896,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	189,	'PEkMakro',	'EK1011/3(1)',	'Akt B',	'Rini W, Aldilla D',	1,	'2025-12-05 10:31:38.580406+07'),
(3897,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	203,	'IntroToMacro',	'EK1011/2(1)',	'Akt Int',	'Ascaryan, Dimas P',	1,	'2025-12-05 10:31:38.580406+07'),
(3898,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	186,	'Menstra',	'EM4190/3(5)',	'Man B',	'Ag. Suroso, Nur Afif',	1,	'2025-12-05 10:31:38.580406+07'),
(3899,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	184,	'Metopen',	'EK3110/3(5)',	'Akt C',	'Hijroh R, Dona P',	1,	'2025-12-05 10:31:38.580406+07'),
(3900,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	201,	'Metopen',	'KPE183530/3(5)',	'PE A',	'Suharno, Arintoko',	1,	'2025-12-05 10:31:38.580406+07'),
(3901,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	202,	'Pasar Modal',	'EM3240/3(3)',	'Akt A',	'Irianing S, Negina KP',	1,	'2025-12-05 10:31:38.580406+07'),
(3902,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	188,	'P.EkMakro',	'EK1012/3(1)',	'IESP B',	'Lilis SB, Barokatuminalloh',	1,	'2025-12-05 10:31:38.580406+07'),
(3903,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	185,	'Menstra',	'EM4190/3(5)',	'Man A',	'Chandra S, Lusi S',	1,	'2025-12-05 10:31:38.580406+07'),
(3904,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	183,	'Metopen',	'EK3110/3(5)',	'Akt B',	'Bb. SBI, Poppy DIK',	1,	'2025-12-05 10:31:38.580406+07'),
(3905,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'09:45:00',	'13:00:00',	200,	'EkPublik',	'EP31207/3(3)',	'IESP A',	'Rakhmat P, Barokatuminalloh',	1,	'2025-12-05 10:31:38.580406+07'),
(3906,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	203,	'Strag.Pemblaj.',	'KPE182313/3(3)',	'PE B',	'Arif Andri, Elsa P',	1,	'2025-12-05 10:31:38.580406+07'),
(3907,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	186,	'P.Akt I/Mtd',	'EA1041/3(1)',	'Akt B',	'Ag. Sunarmo, Agus F',	1,	'2025-12-05 10:31:38.580406+07'),
(3908,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	188,	'MSDM Kelanj',	'EW3052/3(3)',	'Man A',	'Filda KN, Dwita D',	1,	'2025-12-05 10:31:38.580406+07'),
(3909,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	213,	'Creative & Innovation',	'EW3001/3(3)',	'Akt Int/R',	'Atiek SP, Ramita',	1,	'2025-12-05 10:31:38.580406+07'),
(3910,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	209,	'Behav.Acc',	'EA3190/3(4)',	'Akt Int/Aj',	'Ade Irma, Hijroh R',	1,	'2025-12-05 10:31:38.580406+07'),
(3911,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	184,	'Akt.Kprlk',	'EA3190/3(4)',	'Akt A',	'Bb. SBI, Puji L',	1,	'2025-12-05 10:31:38.580406+07'),
(3912,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	208,	'Property Ec',	'EP61305/3(7)',	'IESP Int',	'Puji L, Tiladela L',	1,	'2025-12-05 10:31:38.580406+07'),
(3913,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	190,	'MSDM Kelanj',	'EW3052/3(3)',	'Man B',	'Siti Zulaikha, Retno K',	1,	'2025-12-05 10:31:38.580406+07'),
(3914,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	207,	'Peng.Mikro',	'KPE184639/3(5)',	'PE G',	'Ratu Ayu SW, -',	1,	'2025-12-05 10:31:38.580406+07'),
(3915,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	211,	'Intro to Acct',	'EW1011/3(1)',	'Akt Int',	'Rio Dhani L, Poppy DIK',	1,	'2025-12-05 10:31:38.580406+07'),
(3916,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	212,	'Intr.to.AccI/Acc',	'EA1041/3(1)',	'Mgt Int',	'Aldila K, Isti Riana D',	1,	'2025-12-05 10:31:38.580406+07'),
(3917,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	191,	'MSDM Kelanj',	'EW3052/3(3)',	'Man C',	'Dyah Perwita, Devani L',	1,	'2025-12-05 10:31:38.580406+07'),
(3918,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	201,	'P. Manaj.',	'EK1030/3(1)',	'Man B',	'Lina RN, Eka W',	1,	'2025-12-05 10:31:38.580406+07'),
(3919,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	192,	'Eko. Digital',	'KPE182630/3(6)',	'PE',	'Dwita D, Elsa P',	1,	'2025-12-05 10:31:38.580406+07'),
(3920,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	183,	'Kepempnan',	'EM4506/3(5)',	'Man',	'Ach Sudjadi, Retno K',	1,	'2025-12-05 10:31:38.580406+07'),
(3921,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	200,	'P. Manaj.',	'EK1030/3(1)',	'Man A',	'Retno W, Asmi Ayu',	1,	'2025-12-05 10:31:38.580406+07'),
(3922,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	185,	'P.Akt I/Mtd',	'EA1041/3(1)',	'Akt A',	'Permata Ulfah, Ag. Sunarmo',	1,	'2025-12-05 10:31:38.580406+07'),
(3923,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	202,	'Strag.Pemblaj.',	'KPE182313/3(3)',	'PE A',	'Sofiatul K, Sofiatul K',	1,	'2025-12-05 10:31:38.580406+07'),
(3924,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	210,	'Leadership',	'EM4506/3(5)',	'Mgt Int/Aj',	'Prof.BAP, Ronald H',	1,	'2025-12-05 10:31:38.580406+07'),
(3925,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	189,	'Game Theory',	'EP51306/3(7)',	'IESP',	'Daryono, Tri Wahyu Y',	1,	'2025-12-05 10:31:38.580406+07'),
(3926,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'13:00:00',	'16:00:00',	187,	'P.Akt I/Mtd',	'EA1041/3(1)',	'Akt C',	'Agus F, Permata Ulfah',	1,	'2025-12-05 10:31:38.580406+07'),
(3927,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	189,	'PEkMakro',	'EK1011/3(1)',	'Akt A',	'Rini W, Faiz Nuha',	1,	'2025-12-05 10:31:38.580406+07'),
(3928,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	209,	'Bus Stat II',	'EM2092/3(3)',	'Mgt Int',	'Suliyanto, Nur Afif',	1,	'2025-12-05 10:31:38.580406+07'),
(3929,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	188,	'Eko.Pendidik',	'KPE182633/3(6)',	'PE',	'Dyah Perwita, Elsa P',	1,	'2025-12-05 10:31:38.580406+07'),
(3930,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	211,	'Civic',	'UN107/2(1)',	'Akt Int',	'Vivana M, Warsidi',	1,	'2025-12-05 10:31:38.580406+07'),
(3931,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	190,	'Hukum Bisnis',	'EW2120/3(3)',	'Man B',	'Ulil Afwa, Ronald H',	1,	'2025-12-05 10:31:38.580406+07'),
(3932,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	192,	'Jati diri',	'UN114/2(1)',	'IESP B',	'Pahrul Fauzi, Vivana M',	1,	'2025-12-05 10:31:38.580406+07'),
(3933,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	213,	'Peng.Mikro',	'KPE184639/3(5)',	'PE H',	'Aldila K, Ramita',	1,	'2025-12-05 10:31:38.580406+07'),
(3934,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	183,	'Kewirausahaan',	'KPE181210/3(3)',	'PE A',	'Dyah Perwita, Febyana',	1,	'2025-12-05 10:31:38.580406+07'),
(3935,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	200,	'Ek.Properti',	'EP61305/3(7)',	'IESP',	'Suha rno, MS Fibrika',	1,	'2025-12-05 10:31:38.580406+07'),
(3936,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	184,	'Kewirausahaan',	'KPE181210/3(3)',	'PE B',	'Sofiatul K, Oki A',	1,	'2025-12-05 10:31:38.580406+07'),
(3937,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	201,	'Hukum Bisnis',	'KPE181535/3(5)',	'PE A',	'Ulil Afwa, Rahadi Wasi B',	1,	'2025-12-05 10:31:38.580406+07'),
(3938,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	191,	'Jati diri',	'UN114/2(1)',	'IESP A',	'Dijan R, Bb Triyono',	1,	'2025-12-05 10:31:38.580406+07'),
(3939,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	212,	'Demogr.Eco.',	'EP71305(7)',	'IESP Int',	'Dwita Aprillia, Anandhiya I',	1,	'2025-12-05 10:31:38.580406+07'),
(3940,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	185,	'Akt Syariah',	'EA3250/3(7)',	'AKT',	'Dewi S, Permata Ulfah',	1,	'2025-12-05 10:31:38.580406+07'),
(3941,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	202,	'Hukum Bisnis',	'KPE181535/3(5)',	'PE B',	'Ulil Afwa, Rahadi Wasi B',	1,	'2025-12-05 10:31:38.580406+07'),
(3942,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	213,	'Hukum Bisnis',	'EW2120/3(3)',	'Man A',	'Ulil Afwa, Ronald H',	1,	'2025-12-05 10:31:38.580406+07'),
(3943,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	203,	'Indo.Ec.',	'EK2100/3(4)',	'IESP Int',	'Farida A, Arif Andri',	1,	'2025-12-05 10:31:38.580406+07'),
(3944,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	210,	'Sustainable',	'EW3052/3(3)',	'Mgt Int/Aj',	'Adi Indra, Ashari',	1,	'2025-12-05 10:31:38.580406+07'),
(3945,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	187,	'Hub Indus',	'EM4507/3(5)',	'Man',	'Ratno P, Dwita D',	1,	'2025-12-05 10:31:38.580406+07'),
(3946,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	2,	'selasa',	'16:00:00',	'18:30:00',	208,	'Fin.Insti.Mgt',	'EM2270/3(5)',	'Mgt Int',	'Ronald H, Fitri A',	1,	'2025-12-05 10:31:38.580406+07'),
(3947,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	207,	'Peng.Mikro',	'KPE184639/3(5)',	'PE I',	'Sofiatul K, Oki A',	1,	'2025-12-05 10:31:38.580406+07'),
(3948,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	200,	'SIA',	'EA2050/3(3)',	'Akt C',	'Khrisnohe RF, Oman R',	1,	'2025-12-05 10:31:38.580406+07'),
(3949,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	209,	'Internat.Bus',	'EM2201/3(3)',	'Mgt Int',	'Siti Zulaikha, Dwita D',	1,	'2025-12-05 10:31:38.580406+07'),
(3950,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	188,	'SIA',	'EA2050/3(3)',	'Akt B',	'Eko S, Oman R',	1,	'2025-12-05 10:31:38.580406+07'),
(3951,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	183,	'Akt.Kom.Bis.&Kons/AKL 1',	'EA3041/3(5)',	'Akt B',	'Sugiarto, Yusriyati NF',	1,	'2025-12-05 10:31:38.580406+07'),
(3952,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	189,	'MK Kelanj',	'EW2072/3(3)',	'Man B',	'Sudarto, Rio Dhani L',	1,	'2025-12-05 10:31:38.580406+07'),
(3953,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	210,	'Bank&Other',	'EP51309/3(7)',	'IESP Int',	'Irma S, Dicky S',	1,	'2025-12-05 10:31:38.580406+07'),
(3954,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	208,	'Islam.Ec.Sys',	'EK2130/3(5)',	'Mgt Int',	'Najmudin, Chandra S',	1,	'2025-12-05 10:31:38.580406+07'),
(3955,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	187,	'SIA',	'EA2050/3(3)',	'Akt A',	'Khrisnohe RF, Dona P',	1,	'2025-12-05 10:31:38.580406+07'),
(3956,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	201,	'Peng.Pendidi.',	'KPE181102/3(1)',	'PE A',	'Laurensia, Dian I',	1,	'2025-12-05 10:31:38.580406+07'),
(3957,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	213,	'Akt.Kom.Bis.',	'EA3041/3(5)',	'Akt C',	'Christina Tri S, Triani A',	1,	'2025-12-05 10:31:38.580406+07'),
(3958,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	192,	'Ek.Indus I',	'EP51207/3(5)',	'IESP A',	'Abdul Aziz, Indrawan F',	1,	'2025-12-05 10:31:38.580406+07'),
(3959,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	184,	'SKB',	'EM4250/3(5)',	'Man A',	'Suliyanto, Eka W',	1,	'2025-12-05 10:31:38.580406+07'),
(3960,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	190,	'MK Kelanj',	'EW2072/3(3)',	'Man C',	'Sri Lestari, Dian PJ',	1,	'2025-12-05 10:31:38.580406+07'),
(3961,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	211,	'Indust.Ec. I',	'EP51207/3(5)',	'IESP Int',	'Suharno, Bambang',	1,	'2025-12-05 10:31:38.580406+07'),
(3962,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	182,	'Ev.Proyek',	'EP51302/3(7)',	'IESP A',	'Nurul A, Diah SG',	1,	'2025-12-05 10:31:38.580406+07'),
(3963,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	203,	'Eko.Moneter',	'KPE181539/3(5)',	'PE',	'Ahmad Nasori, Oki A',	1,	'2025-12-05 10:31:38.580406+07'),
(3964,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	186,	'MK Kelanj',	'EW2072/3(3)',	'Man A',	'Sudarto, Intan S',	1,	'2025-12-05 10:31:38.580406+07'),
(3965,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	212,	'Acct.forbus.Com',	'EA3041/3(5)',	'Akt Int/Aj',	'Prof.BAP, Poppy DIK',	1,	'2025-12-05 10:31:38.580406+07'),
(3966,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	191,	'Akt.Kom.Bis.',	'EA3041/3(5)',	'Akt A',	'Sausan NM, Sugiarto',	1,	'2025-12-05 10:31:38.580406+07'),
(3967,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	185,	'SKB',	'EM4250/3(5)',	'Man B',	'Eka W, Asmi Ayu',	1,	'2025-12-05 10:31:38.580406+07'),
(3968,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'07:00:00',	'09:45:00',	202,	'Peng.Pendidi.',	'KPE181102/3(1)',	'PE B',	'Viviana M, Sofiatul K',	1,	'2025-12-05 10:31:38.580406+07'),
(3969,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	189,	'Matem.Ek',	'EK1050/3(1)',	'Akt C',	'Ascaryan, Sausan NM',	1,	'2025-12-05 10:31:38.580406+07'),
(3970,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	200,	'Mat.Ek I',	'EK1051/3(1)',	'IESP A',	'Rakhmat P, Kikin W',	1,	'2025-12-05 10:31:38.580406+07'),
(3971,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	185,	'Pemriks Internl',	'EA4200/3(5)',	'Akt B',	'Ag. Sunarmo, Yanuar ER',	1,	'2025-12-05 10:31:38.580406+07'),
(3972,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	209,	'Cost.Man',	'EA3070/3(5)',	'Akt Int',	'Laeli B, Hijroh R',	1,	'2025-12-05 10:31:38.580406+07'),
(3973,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	207,	'Peng.Mikro',	'KPE184639/3(5)',	'PE J',	'Sofiatul K, Oki A',	1,	'2025-12-05 10:31:38.580406+07'),
(3974,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	203,	'Eko. Makro II',	'KPE182319/3(3)',	'PE B',	'Arintoko, Indrawan F',	1,	'2025-12-05 10:31:38.580406+07'),
(3975,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	186,	'MnjOpJasa',	'EM4510/3(5)',	'Man',	'Devani L, Retno W',	1,	'2025-12-05 10:31:38.580406+07'),
(3976,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	215,	'Pros.Aud.Bas/Audit III',	'EA3114/3(5)',	'Akt',	'Atiek SP, -',	1,	'2025-12-05 10:31:38.580406+07'),
(3977,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	212,	'Ec.Math',	'EK1050/3(1)',	'Akt Int',	'Widyahayu, Ady Setyo N',	1,	'2025-12-05 10:31:38.580406+07'),
(3978,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	191,	'Pancasila',	'UN101/2(1)',	'Man B',	'Bb. Triono, Dyah Perwita',	1,	'2025-12-05 10:31:38.580406+07'),
(3979,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	201,	'Mat.Ek I',	'EK1051/3(1)',	'IESP B',	'Herman S, Tri Wahyu Y',	1,	'2025-12-05 10:31:38.580406+07'),
(3980,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	202,	'Eko. Makro II',	'KPE182319/3(3)',	'PE A',	'Arintoko, Indrawan F',	1,	'2025-12-05 10:31:38.580406+07'),
(3981,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	183,	'Pemriks Internl',	'EA4200/3(5)',	'Akt A',	'Siti M, Ag. Sunarmo',	1,	'2025-12-05 10:31:38.580406+07'),
(3982,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	187,	'Matem.Ek',	'EK1050/3(1)',	'Akt A',	'Widyahayu, Sausan NM',	1,	'2025-12-05 10:31:38.580406+07'),
(3983,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	208,	'Intrnat FM',	'EM4223/3(5)',	'Mgt Int',	'Ade Banani, Najmudin',	1,	'2025-12-05 10:31:38.580406+07'),
(3984,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	184,	'KomBis',	'KPE181537/3(5)',	'PE',	'Sofiatul K, Ramita K',	1,	'2025-12-05 10:31:38.580406+07'),
(3985,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	213,	'Mathmat I',	'EK1051/3(1)',	'IESP Int',	'Herman S, Ratna SG',	1,	'2025-12-05 10:31:38.580406+07'),
(3986,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	188,	'Matem.Ek',	'EK1050/3(1)',	'Akt B',	'Aldilla D, Faiz Nuha',	1,	'2025-12-05 10:31:38.580406+07'),
(3987,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	192,	'Pancasila',	'UN101/2(1)',	'Man C',	'Ade Irma A, Rifki Ahda S',	1,	'2025-12-05 10:31:38.580406+07'),
(3988,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	182,	'Ek Digital',	'EP6304/3(5)',	'IESP B',	'Ajeng FN, Anzar A',	1,	'2025-12-05 10:31:38.580406+07'),
(3989,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	210,	'Project Ev',	'EP51302/3(7)',	'IESP Int',	'Nurul A, Diah SG',	1,	'2025-12-05 10:31:38.580406+07'),
(3990,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	211,	'SCM',	'EM4509/3(5)',	'Mgt Int',	'Daryono, Bagas G',	1,	'2025-12-05 10:31:38.580406+07'),
(3991,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'09:45:00',	'13:00:00',	190,	'Pancasila',	'UN101/2(1)',	'Man A',	'Ade Irma A, Dyah Perwita',	1,	'2025-12-05 10:31:38.580406+07'),
(3992,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	192,	'Mat.Ek I',	'EK1051/3(1)',	'IESP C',	'Rakhmat P, Rinny Zakaria',	1,	'2025-12-05 10:31:38.580406+07'),
(3993,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	189,	'Kewiraush',	'EM2100/3(3)',	'Akt A',	'Yusriyati NF, Rini W',	1,	'2025-12-05 10:31:38.580406+07'),
(3994,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	210,	'MicroEc.II',	'EP31201/3(3)',	'IESP Int',	'Abdul Aziz, Ratna SG',	1,	'2025-12-05 10:31:38.580406+07'),
(3995,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	188,	'EkMikro II',	'EP31201/3(3)',	'IESP A',	'Abdul Aziz, Tri Wahyu Y',	1,	'2025-12-05 10:31:38.580406+07'),
(3996,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	208,	'State Ideolgy',	'UN101/2(1)',	'Mgt Int',	'Warsidi, Bb. Triono',	1,	'2025-12-05 10:31:38.580406+07'),
(3997,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	187,	'Pernc.Pem.I',	'EP51210/3(5)',	'IESP A',	'Dwita Aprillia, Rinny Zakaria',	1,	'2025-12-05 10:31:38.580406+07'),
(3998,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	207,	'Com.Audit.',	'EA3114/3(5)',	'Akt Int/Aj',	'Dewi S, Atiek SP',	1,	'2025-12-05 10:31:38.580406+07'),
(3999,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	200,	'Peng.Man',	'KPE181103/3(1)',	'PE A',	'Ramita K, Viviana M',	1,	'2025-12-05 10:31:38.580406+07'),
(4000,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	183,	'MK Int',	'EM4223/3(5)',	'Man',	'Najmudin, Intan S',	1,	'2025-12-05 10:31:38.580406+07'),
(4001,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	203,	'Entreprenh',	'EM2100/3(3)',	'Akt Int',	'Eliada H, Aldila D',	1,	'2025-12-05 10:31:38.580406+07'),
(4002,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	186,	'Stat Bis II',	'EM2092/3(3)',	'Mnj',	'Suliyanto, Nur Afif',	1,	'2025-12-05 10:31:38.580406+07'),
(4003,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	191,	'Opr Mgt',	'EK1051/3(1)',	'-',	'(tidak tercantum), (tidak tercantum)',	1,	'2025-12-05 10:31:38.580406+07'),
(4004,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	190,	'Kewiraush',	'EM2100/3(3)',	'Akt B',	'Eliada H, Ady Setyo N',	1,	'2025-12-05 10:31:38.580406+07'),
(4005,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	211,	'Sustainable',	'EW2082/3(3)',	'Mgt Int/Aj',	'Devani L, Daryono',	1,	'2025-12-05 10:31:38.580406+07'),
(4006,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	185,	'Bis.Internas',	'EM2201/3(3)',	'Man',	'Asmi Ayu, Filda KN',	1,	'2025-12-05 10:31:38.580406+07'),
(4007,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	212,	'RskMgt&Ins',	'EM3230/3(5)',	'Mgt Int/Aj',	'Ary Yunanto, Fitri A',	1,	'2025-12-05 10:31:38.580406+07'),
(4008,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	202,	'Kewiraush',	'EM2100/3(3)',	'Akt C',	'Atiek SP, Aldila',	1,	'2025-12-05 10:31:38.580406+07'),
(4009,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	184,	'Ek.Kelmbgan',	'EP61311/3(7)',	'IESP',	'Bambang, Indrawan F',	1,	'2025-12-05 10:31:38.580406+07'),
(4010,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	201,	'Peng.Man',	'KPE181103/3(1)',	'PE B',	'Ramita K, Laurensia',	1,	'2025-12-05 10:31:38.580406+07'),
(4011,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	213,	'Peng.Mikro',	'KPE184639/3(5)',	'PE K',	'Dyah Perwita, Elsa P',	1,	'2025-12-05 10:31:38.580406+07'),
(4012,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	182,	'Pernc.Pem I',	'EP51210/3(5)',	'IESP B',	'Rakhmat P, Dwita Aprillia',	1,	'2025-12-05 10:31:38.580406+07'),
(4013,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'13:00:00',	'16:00:00',	209,	'Institutionl Ec.',	'EP61311/3(7)',	'IESP Int',	'Indrawan F, Anzar A',	1,	'2025-12-05 10:31:38.580406+07'),
(4014,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	211,	'AIS',	'EA2050/3(3)',	'Akt Int',	'Eko S, Elsa P',	1,	'2025-12-05 10:31:38.580406+07'),
(4015,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	212,	'Peng.Mikro',	'KPE184639/3(5)',	'PE L',	'Dyah Perwita, -',	1,	'2025-12-05 10:31:38.580406+07'),
(4016,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	192,	'Kombis',	'EM2290/3(3)',	'Akt B',	'Uswatun H, Sausan NM',	1,	'2025-12-05 10:31:38.580406+07'),
(4017,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	191,	'Kombis',	'EM2290/3(3)',	'Akt A',	'Dona P, Ady Setyo N',	1,	'2025-12-05 10:31:38.580406+07'),
(4018,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	182,	'Pemriks Internl',	'EA4200/3(5)',	'Akt C',	'Krisnhoe RF, Siti M',	1,	'2025-12-05 10:31:38.580406+07'),
(4019,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	208,	'Islamc Relig.',	'UN102/2(1)',	'IESP int',	'Rifki Ahda S, M. Riza Chamadi',	1,	'2025-12-05 10:31:38.580406+07'),
(4020,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	188,	'BLK',	'EP51309/3(7)',	'IESP B',	'Irma S, Arintoko',	1,	'2025-12-05 10:31:38.580406+07'),
(4021,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	203,	'Behv. Unsod',	'UN114/2(1)',	'Mgt Int',	'Weni N, Dijan R',	1,	'2025-12-05 10:31:38.580406+07'),
(4022,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	183,	'Kombis',	'EM2290/3(3)',	'-',	'Dona P, Dimas P',	1,	'2025-12-05 10:31:38.580406+07'),
(4023,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	189,	'B. Inggris',	'EK1060/3(3)',	'IESP B',	'Istiqomah, Chairani F',	1,	'2025-12-05 10:31:38.580406+07'),
(4024,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	209,	'Busine. FS',	'EM4250/3(5)',	'Mgt Int',	'Viviana M, Fitri Amalinda',	1,	'2025-12-05 10:31:38.580406+07'),
(4025,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	184,	'Media Pembljn.',	'KPE182422/3(3)',	'PE A',	'Laurensia, Oki A',	1,	'2025-12-05 10:31:38.580406+07'),
(4026,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	200,	'Kewargn',	'UN107/2(1)',	'IESP B',	'Bb Triyono, Pahrul Fauzi',	1,	'2025-12-05 10:31:38.580406+07'),
(4027,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	202,	'Game Theory',	'EP51306/3(7)',	'IESP Int',	'Eliada H, Rinny Zakaria',	1,	'2025-12-05 10:31:38.580406+07'),
(4028,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	186,	'Angg.Perusah',	'KPE181650/3(5)',	'PE',	'Aldila K, Dwi Astarani',	1,	'2025-12-05 10:31:38.580406+07'),
(4029,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	187,	'MLK',	'EM2270/3(5)',	'Man',	'Dian PJ, Sri Lestari',	1,	'2025-12-05 10:31:38.580406+07'),
(4030,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	185,	'Media Pembljn.',	'KPE182422/3(3)',	'PE B',	'Aldila K, Elsa P',	1,	'2025-12-05 10:31:38.580406+07'),
(4031,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	190,	'Kewargn',	'UN107/2(1)',	'IESP A',	'Eliada H, Viviana M',	1,	'2025-12-05 10:31:38.580406+07'),
(4032,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	201,	'Ek. Mikro I',	'KPE181105/3(1)',	'Akt A',	'Herman S, Oki A',	1,	'2025-12-05 10:31:38.580406+07'),
(4033,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	3,	'rabu',	'16:00:00',	'18:30:00',	210,	'State Ideolgy',	'UN101/2(1)',	'Akt Int',	'Warsidi, Warsidi',	1,	'2025-12-05 10:31:38.580406+07'),
(4034,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	209,	'MIS',	'EA3120/3(3)',	'Akt Int/Aj',	'Eko S, Yanuar ER',	1,	'2025-12-05 10:31:38.580406+07'),
(4035,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	190,	'P.Ek Mikro',	'EK1011/3(1)',	'IESP C',	'Hermasn S, Lilis SB',	1,	'2025-12-05 10:31:38.580406+07'),
(4036,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	210,	'Indus.Rela.',	'EM4507/3(5)',	'Mgt Int',	'Ratno P, Adi Indra',	1,	'2025-12-05 10:31:38.580406+07'),
(4037,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	182,	'Kreativitas & Inovasi',	'EW3001/3(3)',	'Man A',	'Retno K, Telma Anis S',	1,	'2025-12-05 10:31:38.580406+07'),
(4038,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	191,	'SIM',	'EA3120/3(3)',	'Akt C',	'Warsidi, Uswatun H',	1,	'2025-12-05 10:31:38.580406+07'),
(4039,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	211,	'Behav. Unsd',	'UN114/2(1)',	'Akt Int',	'Warsidi, Ade Irma A',	1,	'2025-12-05 10:31:38.580406+07'),
(4040,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	183,	'Kreativitas & Inovasi',	'EW3001/3(3)',	'Man B',	'Ary Yunanto, Isti Riana D',	1,	'2025-12-05 10:31:38.580406+07'),
(4041,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	192,	'MP II',	'EM3062/3(3)',	'Man D',	'Asmi Ayu, Isti Riana D',	1,	'2025-12-05 10:31:38.580406+07'),
(4042,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	212,	'Sustainable',	'EW2072/3(3)',	'Mgt Int/Aj',	'Najmudin, Dian PJ',	1,	'2025-12-05 10:31:38.580406+07'),
(4043,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	184,	'Kreativitas & Inovasi',	'EW3001/3(3)',	'Man C',	'Retno K, Larisa P',	1,	'2025-12-05 10:31:38.580406+07'),
(4044,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	200,	'Ekon.Inter',	'KPE182748/2(5)',	'PE',	'Viviana M, -',	1,	'2025-12-05 10:31:38.580406+07'),
(4045,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	213,	'IntroToMicro',	'EK1011/3(1)',	'IESP Int',	'Herman S, Lilis SB',	1,	'2025-12-05 10:31:38.580406+07'),
(4046,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	185,	'SIM',	'EA3120/3(3)',	'Akt A',	'Eko S, Uswatun H',	1,	'2025-12-05 10:31:38.580406+07'),
(4047,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	201,	'MSDM II',	'EM3052/3(3)',	'Man D',	'Dwita D, Siti Z',	1,	'2025-12-05 10:31:38.580406+07'),
(4048,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	207,	'Peng.Mikro',	'KPE184639/3(5)',	'PE M',	'Laurensia, Lina RN',	1,	'2025-12-05 10:31:38.580406+07'),
(4049,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	186,	'SIM',	'EA3120/3(3)',	'Akt B',	'Warsidi, Faiz Nuha',	1,	'2025-12-05 10:31:38.580406+07'),
(4050,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	202,	'Eval Pembel',	'KPE182423/3(3)',	'PE A',	'Elsa P, Dian I',	1,	'2025-12-05 10:31:38.580406+07'),
(4051,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	187,	'P.Ek Mikro',	'EK1011/3(1)',	'IESP B',	'Goro B, Barokatu',	1,	'2025-12-05 10:31:38.580406+07'),
(4052,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	203,	'Eval Pembel',	'KPE182423/3(3)',	'PE B',	'Lina RN, Oki A',	1,	'2025-12-05 10:31:38.580406+07'),
(4053,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	188,	'StatEk II',	'EK2092/3(3)',	'IESP B',	'Bambang, Dicky S',	1,	'2025-12-05 10:31:38.580406+07'),
(4054,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	208,	'Dev.Ec.II',	'EP51204/3(5)',	'IESP Int',	'Nurul A, Istiqomah',	1,	'2025-12-05 10:31:38.580406+07'),
(4055,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'07:00:00',	'09:45:00',	189,	'StatEk II',	'EK2092/3(3)',	'IESP A',	'Suharno, Ajeng FN',	1,	'2025-12-05 10:31:38.580406+07'),
(4056,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	184,	'Sem MK',	'EM4390/3(5)',	'Man',	'Sudarto, Dian PJ',	1,	'2025-12-05 10:31:38.580406+07'),
(4057,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	192,	'Akt.Biaya',	'EA2031/3(3)',	'Akt C',	'Agus F, Kiky Sri',	1,	'2025-12-05 10:31:38.580406+07'),
(4058,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	211,	'Behav.Unsd',	'UN114/2(1)',	'IESP Int',	'Warsidi, Ade Irma A',	1,	'2025-12-05 10:31:38.580406+07'),
(4059,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	187,	'Akt.Biaya',	'EA2031/3(3)',	'Akt A',	'Permata Ulfah, Agus F',	1,	'2025-12-05 10:31:38.580406+07'),
(4060,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	202,	'Cost.Acct',	'EA2031/3(3)',	'Akt Int',	'Agung P, Kiky Sri',	1,	'2025-12-05 10:31:38.580406+07'),
(4061,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	183,	'Eko.Publik',	'KPE181643/2(5)',	'PE',	'Dian I, Ramita K',	1,	'2025-12-05 10:31:38.580406+07'),
(4062,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	182,	'Akt Biaya',	'EA2031/3(3)',	'Man A',	'Ary Yunanto, Dwi Astarani',	1,	'2025-12-05 10:31:38.580406+07'),
(4063,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	190,	'EkPertan',	'EP31208/3(3)',	'IESP B',	'Goro B, Ratna SG',	1,	'2025-12-05 10:31:38.580406+07'),
(4064,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	209,	'Int.To.Socigy',	'EP30207/3(7)',	'IESP Int',	'Sulyana Dadan, Puri Septiana',	1,	'2025-12-05 10:31:38.580406+07'),
(4065,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	212,	'Peng.Mikro',	'KPE184639/3(5)',	'PE N',	'Laurensia, Lina RN',	1,	'2025-12-05 10:31:38.580406+07'),
(4066,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	203,	'Etika Bisnis',	'EA3260/3(5)',	'Akt C',	'Poppy DIK, Agung P',	1,	'2025-12-05 10:31:38.580406+07'),
(4067,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	188,	'Akt.Biaya',	'EA2031/3(3)',	'Akt B',	'Umi P, Permata Ulfah',	1,	'2025-12-05 10:31:38.580406+07'),
(4068,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	200,	'Mnj.Pendidik',	'KPE181317/3(3)',	'PE A',	'Lina RN, Dian I',	1,	'2025-12-05 10:31:38.580406+07'),
(4069,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	201,	'Mnj.Pendidik',	'KPE181317/3(3)',	'PE B',	'Oki A, Dyah Perwita',	1,	'2025-12-05 10:31:38.580406+07'),
(4070,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	210,	'Agr. Ec',	'EP31208/3(3)',	'IESP Int',	'Ade Banani, Barokatuminlloh',	1,	'2025-12-05 10:31:38.580406+07'),
(4071,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	191,	'Etika Bisnis',	'EA3260/3(5)',	'Akt B',	'Negina KP, Laeli B',	1,	'2025-12-05 10:31:38.580406+07'),
(4072,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	189,	'EkPertan',	'EP31208/3(3)',	'IESP A',	'Istiqomah, Arif Andri W',	1,	'2025-12-05 10:31:38.580406+07'),
(4073,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	208,	'Resch Mthd',	'EK3110/3(5)',	'Mgt Int/Aj',	'Suliyanto, Refius P',	1,	'2025-12-05 10:31:38.580406+07'),
(4074,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	186,	'Etika Bisnis',	'EA3260/3(5)',	'Akt A',	'Dewi S, Uswatun H',	1,	'2025-12-05 10:31:38.580406+07'),
(4075,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'09:45:00',	'13:00:00',	185,	'Akt Biaya',	'EA2031/3(3)',	'Man B',	'Ary Yunanto, Dwi Astarani',	1,	'2025-12-05 10:31:38.580406+07'),
(4076,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	210,	'Buss Com.',	'EM2290/3(3)',	'Akt Int',	'Negina KP, Dona P',	1,	'2025-12-05 10:31:38.580406+07'),
(4077,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	211,	'Dev.Plan I',	'EP51210/3(5)',	'IESP Int',	'Kikin Windhani, Pahrul Fauzi',	1,	'2025-12-05 10:31:38.580406+07'),
(4078,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	192,	'Pancasila',	'UN101/2(1)',	'Akt C',	'Bb. Triyono, Rifki Ahda S',	1,	'2025-12-05 10:31:38.580406+07'),
(4079,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	184,	'Eko.Regional',	'KPE182760/2(5)',	'PE A',	'Indrawan F, Viviana M',	1,	'2025-12-05 10:31:38.580406+07'),
(4080,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	202,	'Ag. Islam',	'UNO1002/2(1)',	'PE A',	'M.Riza Chamadi, Nurchamidah',	1,	'2025-12-05 10:31:38.580406+07'),
(4081,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	187,	'P. Bisnis',	'EK1020/3(1)',	'IESP C',	'Dijan R, Irma S',	1,	'2025-12-05 10:31:38.580406+07'),
(4082,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	183,	'ASP',	'EA3130/3(5)',	'Akt A',	'Yanuar ER, Khrisnhoe RF',	1,	'2025-12-05 10:31:38.580406+07'),
(4083,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	191,	'ASP',	'EA3130/3(5)',	'Akt C',	'Khrisnhoe RF, Icuk R',	1,	'2025-12-05 10:31:38.580406+07'),
(4084,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	188,	'Metopen',	'EK3110/3(5)',	'Man A',	'Suliyanto, Weni N',	1,	'2025-12-05 10:31:38.580406+07'),
(4085,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	203,	'Ag. Islam',	'UNO1002/2(1)',	'PE B',	'M.Riza Chamadi, Nurchamidah',	1,	'2025-12-05 10:31:38.580406+07'),
(4086,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	190,	'ASP',	'EA3130/3(5)',	'Akt B',	'Siti M, Rini W',	1,	'2025-12-05 10:31:38.580406+07'),
(4087,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	209,	'Intro to Mgt',	'EK1030/3(1)',	'Mgt Int',	'Siti Zulaikha, Tiladela L',	1,	'2025-12-05 10:31:38.580406+07'),
(4088,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	208,	'Pub.Sec.Acc',	'EA3130/3(5)',	'Akt Int/Aj',	'Icuk R, Yudha Aryo',	1,	'2025-12-05 10:31:38.580406+07'),
(4089,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	189,	'Metopen',	'EK3110/3(5)',	'Man B',	'Chandra S, Weni N',	1,	'2025-12-05 10:31:38.580406+07'),
(4090,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	213,	'Fin.Mgt.Sem',	'EM4390/3(5)',	'Mgt Int',	'Intan S, Dian PJ',	1,	'2025-12-05 10:31:38.580406+07'),
(4091,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	201,	'Pancasila',	'UN101/2(1)',	'Akt B',	'Bb Triyono, Pahrul Fauzi',	1,	'2025-12-05 10:31:38.580406+07'),
(4092,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	186,	'EkMikro II',	'EP31201/3(3)',	'IESP B',	'Lilis SB, Diah SG',	1,	'2025-12-05 10:31:38.580406+07'),
(4093,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	212,	'Cost Acc',	'EA2031/3(3)',	'Mgt Int',	'Aldila K, Bb. SBI',	1,	'2025-12-05 10:31:38.580406+07'),
(4094,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	200,	'Pancasila',	'UN101/2(1)',	'Akt A',	'Eliada H, Viviana M',	1,	'2025-12-05 10:31:38.580406+07'),
(4095,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	185,	'P.Ek Mikro',	'EK1011/3(1)',	'IESP A',	'Herman S, Irma S',	1,	'2025-12-05 10:31:38.580406+07'),
(4096,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	207,	'Peng.Mikro',	'KPE184639/3(5)',	'PE O',	'Aldila K, Dian I',	1,	'2025-12-05 10:31:38.580406+07'),
(4097,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'13:00:00',	'16:00:00',	182,	'Pengg.Sekt.Pub',	'EA3131/3',	'PE',	'Yanuar ER, Siti M',	1,	'2025-12-05 10:31:38.580406+07'),
(4098,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	187,	'Mnj.Pemasrn',	'KPE182534/3(5)',	'PE B',	'Aldila K, Dwi Astarani',	1,	'2025-12-05 10:31:38.580406+07'),
(4099,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	201,	'Entrepresh',	'EM2100/3(5)',	'Mgt Int',	'Retno K, Weni N',	1,	'2025-12-05 10:31:38.580406+07'),
(4100,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	192,	'Ek. Mikro I',	'KPE181105/3(1)',	'PE A',	'Lilis SB, Irianing S',	1,	'2025-12-05 10:31:38.580406+07'),
(4101,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	188,	'Bhs.Indo',	'EK1070/2(1)',	'Man A',	'Dwita D, Ahmad Nasori',	1,	'2025-12-05 10:31:38.580406+07'),
(4102,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	185,	'P.Sosiologi',	'EP30207/3(7)',	'IESP',	'Joko Santoso, Puri Septiana',	1,	'2025-12-05 10:31:38.580406+07'),
(4103,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	209,	'PublSecBudting',	'EA3131/3',	'IESP Int',	'Oman R, -',	1,	'2025-12-05 10:31:38.580406+07'),
(4104,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	182,	'Peng.HK.Bis',	'EK2120/3(5)',	'Man C',	'Ronald H, Agus M',	1,	'2025-12-05 10:31:38.580406+07'),
(4105,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	191,	'Ek.Pembangn',	'KPE181536/3(5)',	'PE',	'Dijan R, Herman S',	1,	'2025-12-05 10:31:38.580406+07'),
(4106,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	200,	'Intro to Mgt',	'EK1030/2(1)',	'Akt Int',	'Puji L, Filda KN',	1,	'2025-12-05 10:31:38.580406+07'),
(4107,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	189,	'Bhs. Indo',	'EK1070/2(1)',	'Man B',	'Siti Zulaikha, Bb. Triyono',	1,	'2025-12-05 10:31:38.580406+07'),
(4108,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	183,	'Peng.HK.Bis',	'EK2120/3(5)',	'Man D',	'Ronald H, Ulil Afwa',	1,	'2025-12-05 10:31:38.580406+07'),
(4109,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	190,	'Bhs. Indo',	'EK1070/2(1)',	'Man C',	'Dwi Astarani, Telma Anis S',	1,	'2025-12-05 10:31:38.580406+07'),
(4110,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	184,	'Kewiraush',	'EM2100/3(5)',	'Man',	'Filda KN, Siti Zulaikha',	1,	'2025-12-05 10:31:38.580406+07'),
(4111,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	186,	'Mnj.Pemasrn',	'KPE182534/3(5)',	'PE A',	'Viviana M, Bb. Triyono',	1,	'2025-12-05 10:31:38.580406+07'),
(4112,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	203,	'Businnes and Profe.Ethic',	'EA3260/3(5)',	'Akt Int',	'Aldila Tri N, Alisa Tri N',	1,	'2025-12-05 10:31:38.580406+07'),
(4113,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	208,	'Mark Mgt II',	'EM3062/3(3)',	'Mgt Int',	'Tiladela L, Yanuar ER',	1,	'2025-12-05 10:31:38.580406+07'),
(4114,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	4,	'kamis',	'16:00:00',	'18:30:00',	202,	'Economtrc',	'EP3250/3(4)',	'Man Int/Aj',	'Suliyanto, Eliada H',	1,	'2025-12-05 10:31:38.580406+07'),
(4115,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	210,	'Serv.Mark',	'EM4346/3(5)',	'Mgt Int/Aj',	'Weni N, Istiqomah',	1,	'2025-12-05 10:31:38.580406+07'),
(4116,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	208,	'Indo. Lange',	'EK1070/2(1)',	'Mgt Int',	'Dwi Astarani, Indrawan F',	1,	'2025-12-05 10:31:38.580406+07'),
(4117,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	187,	'Eko.Industri',	'KPE181540/2(5)',	'PE',	'Laurensia, Elsa P',	1,	'2025-12-05 10:31:38.580406+07'),
(4118,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	202,	'Jati Diri',	'UNO1008/2(1)',	'PE B',	'Eliada H, -',	1,	'2025-12-05 10:31:38.580406+07'),
(4119,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	184,	'M.Rt.Pasok',	'EM4509/03(5)',	'Man',	'Rahab, Joni Prayogi',	1,	'2025-12-05 10:31:38.580406+07'),
(4120,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	192,	'Bhs. Indo',	'EK1070/2(1)',	'Akt C',	'Atiek SP, Dimas P',	1,	'2025-12-05 10:31:38.580406+07'),
(4121,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	211,	'Int Buss',	'EM2091/3(5)',	'Akt Int',	'Ratu Ayu SW, Chandra S',	1,	'2025-12-05 10:31:38.580406+07'),
(4122,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	189,	'Metopen',	'EP3110/3(5)',	'IESP A',	'Suharno, Kikin W',	1,	'2025-12-05 10:31:38.580406+07'),
(4123,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	188,	'EkMakro II',	'EP31202/3(3)',	'IESP B',	'Agus Arifin, Anzar A',	1,	'2025-12-05 10:31:38.580406+07'),
(4124,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	183,	'P Ekon',	'EK1010/3(1)',	'Man B',	'Pramono HA, Ramita K',	1,	'2025-12-05 10:31:38.580406+07'),
(4125,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	191,	'Bhs. Indo',	'EK1070/2(1)',	'Akt B',	'Rini W, Ady Setyo',	1,	'2025-12-05 10:31:38.580406+07'),
(4126,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	209,	'English',	'EK1060/3(3)',	'IESP Int',	'Ade Banani, Ahmad Nasori',	1,	'2025-12-05 10:31:38.580406+07'),
(4127,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	201,	'Metopen',	'EP3110/3(5)',	'IESP B',	'Arintoko, Diah SG',	1,	'2025-12-05 10:31:38.580406+07'),
(4128,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	186,	'EkMakro II',	'EP31202/3(3)',	'IESP A',	'Nurul A, Kikin W',	1,	'2025-12-05 10:31:38.580406+07'),
(4129,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	212,	'Civic',	'UN107/2(1)',	'IESP Int',	'Ade Irma A, Dyah Perwita',	1,	'2025-12-05 10:31:38.580406+07'),
(4130,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	200,	'Pem.Jasa',	'EM4346/3(5)',	'Man',	'Larisa P, Alisa TN',	1,	'2025-12-05 10:31:38.580406+07'),
(4131,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	190,	'Bhs. Indo',	'EK1070/2(1)',	'Akt A',	'Atiek SP, Sausan Nuha',	1,	'2025-12-05 10:31:38.580406+07'),
(4132,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	182,	'P Ekon',	'EK1010/3(1)',	'Man A',	'Lilis SB, Bb. Triyono',	1,	'2025-12-05 10:31:38.580406+07'),
(4133,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	203,	'Digital Eco.',	'EP6304/3(7)',	'IESP Int',	'Ajeng FN, Dijan R',	1,	'2025-12-05 10:31:38.580406+07'),
(4134,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'07:00:00',	'09:45:00',	185,	'MK Ush Kcl',	'EM4614/3(6)',	'Man',	'Eka W, Rio Dhani L',	1,	'2025-12-05 10:31:38.580406+07'),
(4135,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	203,	'E-Commerce',	'KPE181544/2(5)',	'PE',	'Oki A, Aldila K',	1,	'2025-12-05 10:31:38.580406+07'),
(4136,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	207,	'Bus Law',	'EW2120/3(3)',	'Mgt Int A',	'Ulil Afwa, Dian I',	1,	'2025-12-05 10:31:38.580406+07'),
(4137,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	201,	'Bhs. Indo',	'UNO1010/2(1)',	'PE A',	'Widya Putri R, Ika Oktaviana',	1,	'2025-12-05 10:31:38.580406+07'),
(4138,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	186,	'Bisnis Int',	'EM2091/3(5)',	'Akt',	'Eko S, Negina KP',	1,	'2025-12-05 10:31:38.580406+07'),
(4139,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	211,	'SPM',	'EA3080/3(5)',	'Akt C',	'Ascaryan, Bb. SBI',	1,	'2025-12-05 10:31:38.580406+07'),
(4140,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	192,	'B.Inggris',	'EK1060/3(3)',	'IESP A',	'Ade Banani, Anandhiya I',	1,	'2025-12-05 10:31:38.580406+07'),
(4141,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	185,	'Ek.Kpddkn',	'EP71305/3(7)',	'IESP A',	'Dwita Aprillia, Chairani F',	1,	'2025-12-05 10:31:38.580406+07'),
(4142,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	200,	'MK II',	'EM2072/3(3)',	'Man B',	'Sudarto, Ary Yunanto',	1,	'2025-12-05 10:31:38.580406+07'),
(4143,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	212,	'MCS',	'EA3080/3(5)',	'Akt Int',	'Agung P, Kiky Sri',	1,	'2025-12-05 10:31:38.580406+07'),
(4144,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	184,	'SPM',	'EA3080/3(5)',	'Akt A',	'Puji L, Hijroh R',	1,	'2025-12-05 10:31:38.580406+07'),
(4145,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	210,	'Indonesian',	'EK1070/2(1)',	'Akt Int',	'Atiek SP, Sausan Nuha',	1,	'2025-12-05 10:31:38.580406+07'),
(4146,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	191,	'Akt. Keua. I',	'KPE181318/3(3)',	'PE B',	'Febyana, Ramita K',	1,	'2025-12-05 10:31:38.580406+07'),
(4147,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	183,	'Ek.Pemb II',	'EP51204/3(5)',	'IESP A',	'Lilis SB, Suharno',	1,	'2025-12-05 10:31:38.580406+07'),
(4148,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	209,	'Resch Meth',	'EK3110/3(5)',	'IESP Int',	'Abdul Aziz, Farid A',	1,	'2025-12-05 10:31:38.580406+07'),
(4149,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	190,	'Akt. Keua. I',	'KPE181318/3(3)',	'PE A',	'Dian I, Ramita K',	1,	'2025-12-05 10:31:38.580406+07'),
(4150,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	182,	'Ek.Pemb II',	'EP51204/3(5)',	'IESP B',	'Suharno, Barokatuminalloh',	1,	'2025-12-05 10:31:38.580406+07'),
(4151,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	208,	'Intro To Ec.',	'EK1010/3(1)',	'Mgt Int',	'Pramono HA, Farid A',	1,	'2025-12-05 10:31:38.580406+07'),
(4152,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	189,	'SPM',	'EA3080/3(5)',	'Akt B',	'Agung P, Bb. SBI',	1,	'2025-12-05 10:31:38.580406+07'),
(4153,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	188,	'Ag. Islam',	'UN102/2(1)',	'IESP B',	'Rifki Ahda S, M. Riza Chamadi',	1,	'2025-12-05 10:31:38.580406+07'),
(4154,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	202,	'Bhs. Indo',	'UNO1010/2(1)',	'PE B',	'Widya Putri R, Ika Oktaviana',	1,	'2025-12-05 10:31:38.580406+07'),
(4155,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'09:45:00',	'13:00:00',	187,	'Ag. Islam',	'UN102/2(1)',	'IESP A',	'Rifki Ahda S, M. Riza Chamadi',	1,	'2025-12-05 10:31:38.580406+07'),
(4156,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	191,	'P. Manaj',	'EK1030/2(1)',	'Akt C',	'Prof. BAP, Kiky Sri',	1,	'2025-12-05 10:31:38.580406+07'),
(4157,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	210,	'Fin Mgt II',	'EM2072/3(3)',	'Mgt Int B',	'Rio Ddhani, Najmudin',	1,	'2025-12-05 10:31:38.580406+07'),
(4158,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	184,	'An.Kuant.Ek',	'EK2092/3(3)',	'Akt A',	'Hijroh R, Widyahayu',	1,	'2025-12-05 10:31:38.580406+07'),
(4159,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	192,	'Lemb.Keu',	'KPE181533/3(5)',	'PE A',	'Cipto Subroto, Dyah Perwita',	1,	'2025-12-05 10:31:38.580406+07'),
(4160,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	209,	'Change Mgt',	'EM3124/3(6)',	'Man Int/Aj',	'Siti Zulaikha, Dwita D',	1,	'2025-12-05 10:31:38.580406+07'),
(4161,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	190,	'Ek Digital',	'EP6304/3(5)',	'IESP A',	'MS Fibrika, Dicky Satria',	1,	'2025-12-05 10:31:38.580406+07'),
(4162,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	182,	'P. Manaj',	'EK1030/2(1)',	'Akt A',	'Irianing S, Umi P',	1,	'2025-12-05 10:31:38.580406+07'),
(4163,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	187,	'P. Manaj',	'EK1030/2(1)',	'Akt B',	'Umi P, Puji L',	1,	'2025-12-05 10:31:38.580406+07'),
(4164,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	189,	'AKLII/Akt.Keu.Kntemper',	'EA3042/3(7)',	'Akt B',	'Yusriyati NF, Sugiarto',	1,	'2025-12-05 10:31:38.580406+07'),
(4165,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	211,	'AKLII/Contem',	'EA3042/3(7)',	'Akt Int',	'Triani A, Wita R',	1,	'2025-12-05 10:31:38.580406+07'),
(4166,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	185,	'Akt Biaya',	'EA2031/3(3)',	'Man C',	'Ary Yunanto, Dwi Astarani',	1,	'2025-12-05 10:31:38.580406+07'),
(4167,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	200,	'Audit Keu.SP',	'EA3132/3(3)',	'Akt',	'Agus JP, Yanuar ER',	1,	'2025-12-05 10:31:38.580406+07'),
(4168,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	212,	'HRM II',	'EM3052/3(3)',	'Mgt Int',	'Siti zulaikha, Retno K',	1,	'2025-12-05 10:31:38.580406+07'),
(4169,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	186,	'An.Kuant.Ek',	'EK2092/3(3)',	'Akt B',	'Ratu Ayu SW, Adi Wiratno',	1,	'2025-12-05 10:31:38.580406+07'),
(4170,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	203,	'Eko. Syariah',	'KPE181535/3(5)',	'PE',	'Permata Ulfah, Bambang',	1,	'2025-12-05 10:31:38.580406+07'),
(4171,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	188,	'AKLII/Akt.Keu.Kntemper',	'EA3042/3(7)',	'Akt A',	'Triani A, Negina KP',	1,	'2025-12-05 10:31:38.580406+07'),
(4172,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	201,	'Lemb.Keu',	'KPE181533/3(5)',	'PE B',	'Cipto Subroto, Dyah Perwita',	1,	'2025-12-05 10:31:38.580406+07'),
(4173,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	207,	'Into Bus Law',	'EK2120/3(5)',	'Mgt Int B',	'Agus M, -',	1,	'2025-12-05 10:31:38.580406+07'),
(4174,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	202,	'An.Kuant.Ek',	'EK2092/3(3)',	'Akt C',	'Bb. SBI, Ratu Ayu SW',	1,	'2025-12-05 10:31:38.580406+07'),
(4175,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	208,	'Sustainable',	'EW3062/3(3)',	'Mgt Int_Aj',	'Tiladela L, Refius P',	1,	'2025-12-05 10:31:38.580406+07'),
(4176,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'13:00:00',	'16:00:00',	183,	'AKLII/Akt.Keu.Kntemper',	'EA3042/3(7)',	'Akt C',	'Yusriyati NF, Sugiarto',	1,	'2025-12-05 10:31:38.580406+07'),
(4177,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	192,	'Resch Mthd',	'EK3110/3(5)',	'Mgt Int O',	'Weni N, Retno K',	1,	'2025-12-05 10:31:38.580406+07'),
(4178,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	208,	'HRM Sem',	'EM4364/3(5)',	'Mgt Int O',	'Dwita D, Retno K',	1,	'2025-12-05 10:31:38.580406+07'),
(4179,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	189,	'Mnj.Operasi',	'KPE181532/3(5)',	'PE B',	'Viviana M, Ramita K',	1,	'2025-12-05 10:31:38.580406+07'),
(4180,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	183,	'Jatidiri',	'UN114/2(1)',	'Akt B',	'Pahrul Fauzi, Viviana M',	1,	'2025-12-05 10:31:38.580406+07'),
(4181,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	191,	'Intrnat FM',	'EM4223/3(5)',	'Mgt Int O',	'Rio Dhani, Fitri Amalinda',	1,	'2025-12-05 10:31:38.580406+07'),
(4182,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	203,	'Fin.Mgt.Sem',	'EM4390/3(5)',	'Mgt Int O',	'Najmudin, Rio Dhani',	1,	'2025-12-05 10:31:38.580406+07'),
(4183,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	188,	'Mnj.Operasi',	'KPE181532/3(5)',	'PE A',	'Viviana M, Bb. Triyono',	1,	'2025-12-05 10:31:38.580406+07'),
(4184,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	202,	'Stra Mgt',	'EM4190/3(5)',	'Mgt Int O',	'Chandra S, Filda KN',	1,	'2025-12-05 10:31:38.580406+07'),
(4185,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	187,	'Kepercayaan',	'UNO1011/2(1)',	'Sem Jur',	'Purwo S, -',	1,	'2025-12-05 10:31:38.580406+07'),
(4186,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	201,	'MIS',	'EM2260/3(5)',	'Mgt Int O',	'Joni P, Bagas G',	1,	'2025-12-05 10:31:38.580406+07'),
(4187,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	186,	'Ag.Kristen',	'UN103/2(1)',	'Sem Jur',	'Eliada H, -',	1,	'2025-12-05 10:31:38.580406+07'),
(4188,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	200,	'MarMgtSem',	'EM4376/3(5)',	'Mgt Int O',	'Weni N, Alisa Tri N',	1,	'2025-12-05 10:31:38.580406+07'),
(4189,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	185,	'Ag. Katholik',	'UN104/2(1)',	'Sem Jur',	'Ary Setiawan, -',	1,	'2025-12-05 10:31:38.580406+07'),
(4190,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	184,	'Jatidiri',	'UN114/2(1)',	'Akt C',	'Bb. Triyono, Rifki Ahda S',	1,	'2025-12-05 10:31:38.580406+07'),
(4191,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	190,	'Ag.Hindhu',	'UN105/2(1)',	'Sem Jur',	'-, -',	1,	'2025-12-05 10:31:38.580406+07'),
(4192,	'2025-GASAL',	'2025-08-08',	'2025-12-08',	5,	'jumat',	'16:00:00',	'18:30:00',	182,	'Jatidiri',	'UN114/2(1)',	'Akt A',	'Ade Irma A, Arif Andri W',	1,	'2025-12-05 10:31:38.580406+07');

DROP VIEW IF EXISTS "mv_kuliah_per_hari";
CREATE TABLE "mv_kuliah_per_hari" ("jadwal_id" bigint, "semester_kode" character varying(50), "tanggal" date, "ruangan_id" bigint, "time_slot_id" smallint, "start_time" time without time zone, "end_time" time without time zone, "mata_kuliah" character varying(255), "kelas" character varying(50), "dosen" text, "fakultas_kuliah_id" bigint);


DROP TABLE IF EXISTS "ruangan";
DROP SEQUENCE IF EXISTS ruangan_id_seq;
CREATE SEQUENCE ruangan_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."ruangan" (
    "id" bigint DEFAULT nextval('ruangan_id_seq') NOT NULL,
    "fakultas_id" bigint NOT NULL,
    "kode_ruang" character varying(50) NOT NULL,
    "nama_ruang" character varying(255) NOT NULL,
    "gedung" character varying(100),
    "lantai" smallint,
    "kapasitas" integer,
    "fasilitas" text,
    "aktif" boolean DEFAULT true NOT NULL,
    "catatan" text,
    "created_at" timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT "ruangan_pkey" PRIMARY KEY ("id")
)
WITH (oids = false);

CREATE UNIQUE INDEX uq_ruangan_fakultas_kode ON public.ruangan USING btree (fakultas_id, kode_ruang);

INSERT INTO "ruangan" ("id", "fakultas_id", "kode_ruang", "nama_ruang", "gedung", "lantai", "kapasitas", "fasilitas", "aktif", "catatan", "created_at") VALUES
(182,	1,	'A.101',	'Ruang Kuliah A101',	'Gedung A',	1,	80,	'AC',	'1',	'',	'2025-12-02 11:24:52.157148+07'),
(215,	1,	'Lab.1.203',	'Lab Komputer 1.203',	'Gedung Lab',	2,	20,	'',	'1',	'',	'2025-12-02 11:24:57.79328+07'),
(183,	1,	'A.102a',	'Ruang Kuliah A102a',	'Gedung A',	1,	60,	'',	'1',	'',	'2025-12-02 11:24:52.333235+07'),
(184,	1,	'A.102b',	'Ruang Kuliah A102b',	'Gedung A',	1,	60,	'',	'1',	'',	'2025-12-02 11:24:52.505195+07'),
(185,	1,	'A.103a',	'Ruang Kuliah A103a',	'Gedung A',	1,	60,	'',	'1',	'',	'2025-12-02 11:24:52.674417+07'),
(186,	1,	'A.103b',	'Ruang Kuliah A103b',	'Gedung A',	1,	60,	'',	'1',	'',	'2025-12-02 11:24:52.844913+07'),
(187,	1,	'A.104',	'Ruang Kuliah A104',	'Gedung A',	1,	70,	'',	'1',	'',	'2025-12-02 11:24:53.015233+07'),
(188,	1,	'A.201',	'Ruang Kuliah A201',	'Gedung A',	2,	80,	'',	'1',	'',	'2025-12-02 11:24:53.179886+07'),
(189,	1,	'A.203',	'Ruang Kuliah A203',	'Gedung A',	2,	80,	'',	'1',	'',	'2025-12-02 11:24:53.340255+07'),
(190,	1,	'A.204',	'Ruang Kuliah A204',	'Gedung A',	2,	80,	'',	'1',	'',	'2025-12-02 11:24:53.511693+07'),
(191,	1,	'A.205',	'Ruang Kuliah A205',	'Gedung A',	2,	70,	'',	'1',	'',	'2025-12-02 11:24:53.685649+07'),
(192,	1,	'B.201',	'Ruang Kuliah B201',	'Gedung B',	2,	70,	'',	'1',	'',	'2025-12-02 11:24:53.84822+07'),
(193,	1,	'B.202',	'Ruang Kuliah B202',	'Gedung B',	2,	70,	'',	'1',	'',	'2025-12-02 11:24:54.019361+07'),
(194,	1,	'C.103',	'Ruang Kuliah C103',	'Gedung C',	1,	60,	'',	'1',	'',	'2025-12-02 11:24:54.191447+07'),
(195,	1,	'C.104',	'Ruang Kuliah C104',	'Gedung C',	1,	60,	'',	'1',	'',	'2025-12-02 11:24:54.362862+07'),
(196,	1,	'C.105',	'Ruang Kuliah C105',	'Gedung C',	1,	60,	'',	'1',	'',	'2025-12-02 11:24:54.539245+07'),
(197,	1,	'C.106',	'Ruang Kuliah C106',	'Gedung C',	1,	60,	'',	'1',	'',	'2025-12-02 11:24:54.712082+07'),
(198,	1,	'C.201',	'Ruang Kuliah C201',	'Gedung C',	2,	70,	'',	'1',	'',	'2025-12-02 11:24:54.884098+07'),
(199,	1,	'C.202',	'Ruang Kuliah C202',	'Gedung C',	2,	70,	'',	'1',	'',	'2025-12-02 11:24:55.056233+07'),
(200,	1,	'C.203',	'Ruang Kuliah C203',	'Gedung C',	2,	70,	'',	'1',	'',	'2025-12-02 11:24:55.224479+07'),
(201,	1,	'C.204',	'Ruang Kuliah C204',	'Gedung C',	2,	70,	'',	'1',	'',	'2025-12-02 11:24:55.3947+07'),
(202,	1,	'C.205',	'Ruang Kuliah C205',	'Gedung C',	2,	80,	'',	'1',	'',	'2025-12-02 11:24:55.565058+07'),
(203,	1,	'C.206',	'Ruang Kuliah C206',	'Gedung C',	2,	80,	'',	'1',	'',	'2025-12-02 11:24:55.7395+07'),
(204,	1,	'F.106',	'Ruang Kuliah F106',	'Gedung F',	1,	20,	'',	'1',	'',	'2025-12-02 11:24:55.911373+07'),
(205,	1,	'F.107',	'Ruang Kuliah F107',	'Gedung F',	1,	20,	'',	'1',	'',	'2025-12-02 11:24:56.085+07'),
(206,	1,	'F.108',	'Ruang Kuliah F108',	'Gedung F',	1,	20,	'',	'1',	'',	'2025-12-02 11:24:56.254568+07'),
(207,	1,	'F.205',	'Ruang Kuliah F205',	'Gedung F',	2,	20,	'',	'1',	'',	'2025-12-02 11:24:56.4216+07'),
(208,	1,	'G.101',	'Ruang Kuliah G101',	'Gedung G',	1,	50,	'',	'1',	'',	'2025-12-02 11:24:56.596022+07'),
(209,	1,	'G.104',	'Ruang Kuliah G104',	'Gedung G',	1,	50,	'',	'1',	'',	'2025-12-02 11:24:56.764915+07'),
(210,	1,	'G.201',	'Ruang Kuliah G201',	'Gedung G',	2,	40,	'',	'1',	'',	'2025-12-02 11:24:56.926897+07'),
(211,	1,	'G.202',	'Ruang Kuliah G202',	'Gedung G',	2,	70,	'',	'1',	'',	'2025-12-02 11:24:57.099212+07'),
(212,	1,	'G.203',	'Ruang Kuliah G203',	'Gedung G',	2,	70,	'',	'1',	'',	'2025-12-02 11:24:57.272402+07'),
(213,	1,	'G.204',	'Ruang Kuliah G204',	'Gedung G',	2,	70,	'',	'1',	'',	'2025-12-02 11:24:57.44939+07'),
(214,	1,	'G.206',	'Ruang Kuliah G206',	'Gedung G',	2,	70,	'',	'1',	'',	'2025-12-02 11:24:57.62142+07');

DROP TABLE IF EXISTS "time_slot";
CREATE TABLE "public"."time_slot" (
    "id" smallint NOT NULL,
    "nama" character varying(50) NOT NULL,
    "start_time" time without time zone NOT NULL,
    "end_time" time without time zone NOT NULL,
    CONSTRAINT "time_slot_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "ck_time_slot_range" CHECK ((start_time < end_time))
)
WITH (oids = false);

INSERT INTO "time_slot" ("id", "nama", "start_time", "end_time") VALUES
(1,	'07:00 - 09:45',	'07:00:00',	'09:45:00'),
(2,	'09:45 - 13:00',	'09:45:00',	'13:00:00'),
(3,	'13:00 - 16:00',	'13:00:00',	'16:00:00'),
(4,	'16:00 - 18:00',	'16:00:00',	'18:30:00'),
(5,	'18:30 - 22:00',	'18:30:00',	'22:00:00');

DROP VIEW IF EXISTS "v_booking_group";
CREATE TABLE "v_booking_group" ("group_id" uuid, "any_booking_id" bigint, "tanggal" date, "ruangan_id" bigint, "kode_ruang" character varying(50), "nama_ruang" character varying(255), "gedung" character varying(100), "fakultas_ruangan_id" bigint, "slot_ids" smallint[], "slot_labels" character varying[], "nama_peminjam" text, "unit" text, "kegiatan" text, "hp" text, "status" booking_status, "qr_code" text, "created_at" timestamptz, "fakultas_peminjam_id" bigint, "asal_unit" text, "asal_eksternal" text);


DROP VIEW IF EXISTS "v_jadwal_ruang_harian";
CREATE TABLE "v_jadwal_ruang_harian" ("source" text, "semester_kode" character varying(50), "tanggal" date, "ruangan_id" bigint, "kode_ruang" character varying(50), "nama_ruang" character varying(255), "gedung" character varying(100), "time_slot_id" smallint, "jam_mulai" time without time zone, "jam_selesai" time without time zone, "time_slot_label" character varying(50), "mata_kuliah" character varying(255), "kelas" character varying(50), "dosen" text, "fakultas_id" bigint, "booking_group_id" uuid, "booking_status" booking_status, "booking_id" bigint, "nama_peminjam" character varying(255), "unit" character varying(255), "kegiatan" text, "hp" character varying(50), "is_active" boolean);


DROP VIEW IF EXISTS "v_ruangan_fakultas";
CREATE TABLE "v_ruangan_fakultas" ("ruangan_id" bigint, "kode_ruang" character varying(50), "nama_ruang" character varying(255), "gedung" character varying(100), "lantai" smallint, "kapasitas" integer, "fasilitas" text, "aktif" boolean, "fakultas_id" bigint, "fakultas_kode" character varying(20), "fakultas_nama" character varying(255));


ALTER TABLE ONLY "public"."admin_user" ADD CONSTRAINT "admin_user_fakultas_id_fkey" FOREIGN KEY (fakultas_id) REFERENCES fakultas(id) ON UPDATE CASCADE ON DELETE SET NULL NOT DEFERRABLE;

ALTER TABLE ONLY "public"."booking_ruangan" ADD CONSTRAINT "booking_ruangan_approved_by_admin_id_fkey" FOREIGN KEY (approved_by_admin_id) REFERENCES admin_user(id) ON UPDATE CASCADE ON DELETE SET NULL NOT DEFERRABLE;
ALTER TABLE ONLY "public"."booking_ruangan" ADD CONSTRAINT "booking_ruangan_fakultas_peminjam_id_fkey" FOREIGN KEY (fakultas_peminjam_id) REFERENCES fakultas(id) ON UPDATE CASCADE ON DELETE SET NULL NOT DEFERRABLE;
ALTER TABLE ONLY "public"."booking_ruangan" ADD CONSTRAINT "booking_ruangan_ruangan_id_fkey" FOREIGN KEY (ruangan_id) REFERENCES ruangan(id) ON DELETE CASCADE NOT DEFERRABLE;
ALTER TABLE ONLY "public"."booking_ruangan" ADD CONSTRAINT "booking_ruangan_time_slot_id_fkey" FOREIGN KEY (time_slot_id) REFERENCES time_slot(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT DEFERRABLE;

ALTER TABLE ONLY "public"."jadwal_kuliah" ADD CONSTRAINT "jadwal_kuliah_fakultas_id_fkey" FOREIGN KEY (fakultas_id) REFERENCES fakultas(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT DEFERRABLE;
ALTER TABLE ONLY "public"."jadwal_kuliah" ADD CONSTRAINT "jadwal_kuliah_ruangan_id_fkey" FOREIGN KEY (ruangan_id) REFERENCES ruangan(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT DEFERRABLE;

ALTER TABLE ONLY "public"."ruangan" ADD CONSTRAINT "ruangan_fakultas_id_fkey" FOREIGN KEY (fakultas_id) REFERENCES fakultas(id) ON UPDATE CASCADE ON DELETE RESTRICT NOT DEFERRABLE;

DROP TABLE IF EXISTS "mv_kuliah_per_hari";
CREATE VIEW "mv_kuliah_per_hari" AS WITH kuliah_per_hari AS (
         SELECT jk.id AS jadwal_id,
            jk.semester_kode,
            (g.tanggal)::date AS tanggal,
            jk.ruangan_id,
            ts.id AS time_slot_id,
            ts.start_time,
            ts.end_time,
            jk.mata_kuliah,
            jk.kelas,
            jk.dosen,
            jk.fakultas_id AS fakultas_kuliah_id
           FROM ((jadwal_kuliah jk
             JOIN LATERAL generate_series((jk.tanggal_mulai)::timestamp with time zone, (jk.tanggal_selesai)::timestamp with time zone, '1 day'::interval) g(tanggal) ON ((EXTRACT(isodow FROM g.tanggal) = (jk.hari_dow)::numeric)))
             JOIN time_slot ts ON (((ts.start_time < jk.jam_selesai) AND (ts.end_time > jk.jam_mulai))))
        )
 SELECT kuliah_per_hari.jadwal_id,
    kuliah_per_hari.semester_kode,
    kuliah_per_hari.tanggal,
    kuliah_per_hari.ruangan_id,
    kuliah_per_hari.time_slot_id,
    kuliah_per_hari.start_time,
    kuliah_per_hari.end_time,
    kuliah_per_hari.mata_kuliah,
    kuliah_per_hari.kelas,
    kuliah_per_hari.dosen,
    kuliah_per_hari.fakultas_kuliah_id
   FROM kuliah_per_hari;

DROP TABLE IF EXISTS "v_booking_group";
CREATE VIEW "v_booking_group" AS SELECT b.group_id,
    min(b.id) AS any_booking_id,
    b.tanggal,
    b.ruangan_id,
    r.kode_ruang,
    r.nama_ruang,
    r.gedung,
    r.fakultas_id AS fakultas_ruangan_id,
    array_agg(b.time_slot_id ORDER BY b.time_slot_id) AS slot_ids,
    array_agg(ts.nama ORDER BY b.time_slot_id) AS slot_labels,
    min((b.nama_peminjam)::text) AS nama_peminjam,
    min((b.unit)::text) AS unit,
    min(b.kegiatan) AS kegiatan,
    min((b.hp)::text) AS hp,
        CASE
            WHEN bool_or((b.status = 'pending'::booking_status)) THEN 'pending'::booking_status
            WHEN bool_or((b.status = 'approved'::booking_status)) THEN 'approved'::booking_status
            WHEN bool_or((b.status = 'rejected'::booking_status)) THEN 'rejected'::booking_status
            ELSE 'cancelled'::booking_status
        END AS status,
    min(b.qr_code) AS qr_code,
    min(b.created_at) AS created_at,
    min(b.fakultas_peminjam_id) AS fakultas_peminjam_id,
    min(b.asal_unit) AS asal_unit,
    min(b.asal_eksternal) AS asal_eksternal
   FROM ((booking_ruangan b
     JOIN ruangan r ON ((r.id = b.ruangan_id)))
     JOIN time_slot ts ON ((ts.id = b.time_slot_id)))
  GROUP BY b.group_id, b.tanggal, b.ruangan_id, r.kode_ruang, r.nama_ruang, r.gedung, r.fakultas_id
  ORDER BY b.tanggal DESC;

DROP TABLE IF EXISTS "v_jadwal_ruang_harian";
CREATE VIEW "v_jadwal_ruang_harian" AS WITH kuliah_per_hari AS (
         SELECT mv.jadwal_id,
            mv.semester_kode,
            mv.tanggal,
            mv.ruangan_id,
            mv.time_slot_id,
            mv.start_time,
            mv.end_time,
            mv.mata_kuliah,
            mv.kelas,
            mv.dosen,
            mv.fakultas_kuliah_id
           FROM mv_kuliah_per_hari mv
        )
 SELECT 'kuliah'::text AS source,
    k.semester_kode,
    k.tanggal,
    k.ruangan_id,
    r.kode_ruang,
    r.nama_ruang,
    r.gedung,
    k.time_slot_id,
    k.start_time AS jam_mulai,
    k.end_time AS jam_selesai,
    ts.nama AS time_slot_label,
    k.mata_kuliah,
    k.kelas,
    k.dosen,
    k.fakultas_kuliah_id AS fakultas_id,
    NULL::uuid AS booking_group_id,
    NULL::booking_status AS booking_status,
    NULL::bigint AS booking_id,
    NULL::character varying(255) AS nama_peminjam,
    NULL::character varying(255) AS unit,
    NULL::text AS kegiatan,
    NULL::character varying(50) AS hp,
    NULL::boolean AS is_active
   FROM ((kuliah_per_hari k
     JOIN ruangan r ON ((r.id = k.ruangan_id)))
     JOIN time_slot ts ON ((ts.id = k.time_slot_id)))
UNION ALL
 SELECT 'booking'::text AS source,
    NULL::character varying(50) AS semester_kode,
    b.tanggal,
    b.ruangan_id,
    r.kode_ruang,
    r.nama_ruang,
    r.gedung,
    b.time_slot_id,
    b.jam_mulai,
    b.jam_selesai,
    ts.nama AS time_slot_label,
    NULL::character varying(255) AS mata_kuliah,
    NULL::character varying(50) AS kelas,
    NULL::text AS dosen,
    b.fakultas_peminjam_id AS fakultas_id,
    b.group_id AS booking_group_id,
    b.status AS booking_status,
    b.id AS booking_id,
    b.nama_peminjam,
    b.unit,
    b.kegiatan,
    b.hp,
    b.is_active
   FROM ((booking_ruangan b
     JOIN ruangan r ON ((r.id = b.ruangan_id)))
     JOIN time_slot ts ON ((ts.id = b.time_slot_id)));

DROP TABLE IF EXISTS "v_ruangan_fakultas";
CREATE VIEW "v_ruangan_fakultas" AS SELECT r.id AS ruangan_id,
    r.kode_ruang,
    r.nama_ruang,
    r.gedung,
    r.lantai,
    r.kapasitas,
    r.fasilitas,
    r.aktif,
    f.id AS fakultas_id,
    f.kode AS fakultas_kode,
    f.nama AS fakultas_nama
   FROM (ruangan r
     JOIN fakultas f ON ((f.id = r.fakultas_id)));

-- 2025-12-05 04:34:19 UTC

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3
-- Dumped by pg_dump version 13.3 (Ubuntu 13.3-1.pgdg20.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: result; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.result (
    id integer NOT NULL,
    studentid integer NOT NULL,
    task1 character varying(127) NOT NULL,
    task2 character varying(127) NOT NULL,
    task3 character varying(127) NOT NULL,
    task4 character varying(127) NOT NULL
);


ALTER TABLE public.result OWNER TO postgres;

--
-- Name: result_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.result_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.result_id_seq OWNER TO postgres;

--
-- Name: result_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.result_id_seq OWNED BY public.result.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    id integer NOT NULL,
    student character varying(127) NOT NULL,
    studentid integer NOT NULL
);


ALTER TABLE public.students OWNER TO postgres;

--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.students_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.students_id_seq OWNER TO postgres;

--
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.students_id_seq OWNED BY public.students.id;


--
-- Name: result id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result ALTER COLUMN id SET DEFAULT nextval('public.result_id_seq'::regclass);


--
-- Name: students id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public.students_id_seq'::regclass);


--
-- Data for Name: result; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.result (id, studentid, task1, task2, task3, task4) FROM stdin;
1       1       Done    Done    Done    Done
2       2       Done    Done    Done    Done
3       3       Done    Done    Done    Done
4       4       Done    Done    Done    Done
5       5       Done    Done    Done    Done
6       7       Done    Done    Done    Done
7       8       Done    not completed   Done    Done
8       9       Done    Done    Done    Done
9       10      Done    Done    Done    Done
10      11      Done    Done    Done    Done
11      14      Done    Done    Done    Done
12      16      Done    Done    Done    Done
13      18      Done    Done    Done    Done
14      19      Done    Done    Done    Done
15      20      Done    Done    Done    Done
16      21      Done    Done    Done    Done
17      22      Done    Done    Done    Done
18      23      Done    Done    Done    Done
19      24      Done    Done    Done    Done
20      26      Done    Done    Done    Done
21      27      Done    Done    Done    Done
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, student, studentid) FROM stdin;
1       Назар Винник    1
2       Александр Рекун 2
3       Олег Бандрівський       3
4       Владимир Бурдыко        4
5       Вадим Марков    5
6       Игорь Войтух    7
7       Дмитрий Мошна   8
8       Евгений Козловский      9
9       Эд Еленский     10
10      Игорь Зинченко  11
11      Виталий Костюков        14
12      Евгений Лактюшин        16
13      Михаил Лопаев   18
14      Михаил Мостыка          19
15      Андрей Новогродский     20
16      Сазонова Анна   21
17      Дмитрий Соловей         22
18      Артём Фортунатов        23
19      Хоменко Іван    24
20      Алексей Шутов   26
21      Юрий Щербина    27
\.


--
-- Name: result_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.result_id_seq', 21, true);


--
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.students_id_seq', 21, true);


--
-- Name: result result_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--


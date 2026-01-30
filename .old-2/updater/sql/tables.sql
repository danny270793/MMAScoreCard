drop table public.fights;
drop table public.referees;
drop table public.categories;
drop table public.fighters;
drop table public.events;
drop table public.locations;
drop table public.cities;
drop table public.countries;

CREATE TABLE public.referees (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NOT NULL UNIQUE,
  CONSTRAINT referees_pkey PRIMARY KEY (id)
);
CREATE TABLE public.categories (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NOT NULL,
  weight bigint NULL,
  CONSTRAINT categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.countries (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NULL UNIQUE,
  CONSTRAINT countries_pkey PRIMARY KEY (id)
);
CREATE TABLE public.cities (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NULL,
  "countryId" bigint NOT NULL,
  CONSTRAINT cities_pkey PRIMARY KEY (id),
  CONSTRAINT cities_countryid_fkey FOREIGN KEY ("countryId") REFERENCES public.countries(id)
);
CREATE TABLE public.locations (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NULL,
  "cityId" bigint NOT NULL,
  CONSTRAINT locations_pkey PRIMARY KEY (id),
  CONSTRAINT locations_cityid_fkey FOREIGN KEY ("cityId") REFERENCES public.cities(id)
);
CREATE TABLE public.events (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NOT NULL UNIQUE,
  fight text,
  date date NOT NULL,
  link text NOT NULL,
  status text NOT NULL CHECK (status = ANY (ARRAY['uppcoming'::text, 'past'::text])),
  "locationId" bigint NOT NULL,
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT events_locationid_fkey FOREIGN KEY ("locationId") REFERENCES public.locations(id)
);
CREATE TABLE public.fighters (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NOT NULL UNIQUE,
  nickname text,
  "cityId" bigint NOT NULL,
  birthday date,
  died date,
  height double precision NOT NULL,
  weight double precision NOT NULL,
  link text NOT NULL,
  CONSTRAINT fighters_pkey PRIMARY KEY (id),
  CONSTRAINT fighters_cityId_fkey FOREIGN KEY ("cityId") REFERENCES public.cities(id)
);
CREATE TABLE public.fights (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  position bigint,
  "categoryId" bigint,
  "fighterOneId" bigint NOT NULL,
  "fighterTwoId" bigint NOT NULL,
  "refereeId" bigint,
  "mainEvent" boolean NOT NULL,
  "titleFight" boolean NOT NULL,
  type text NOT NULL CHECK (type = ANY (ARRAY['pending'::text, 'done'::text])),
  method text,
  time bigint,
  round bigint,
  decision text,
  "eventId" bigint,
  winner bigint,
  CONSTRAINT fights_pkey PRIMARY KEY (id),
  CONSTRAINT fights_fightertwo_fkey FOREIGN KEY ("fighterTwoId") REFERENCES public.fighters(id),
  CONSTRAINT fights_refereeid_fkey FOREIGN KEY ("refereeId") REFERENCES public.referees(id),
  CONSTRAINT fights_categoryid_fkey FOREIGN KEY ("categoryId") REFERENCES public.categories(id),
  CONSTRAINT fights_eventid_fkey FOREIGN KEY ("eventId") REFERENCES public.events(id),
  CONSTRAINT fights_fighterone_fkey FOREIGN KEY ("fighterOneId") REFERENCES public.fighters(id)
);

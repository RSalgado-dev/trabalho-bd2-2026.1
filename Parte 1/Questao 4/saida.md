```sql
"CREATE TABLE public.artist (
  artist_id integer NOT NULL,
  name character varying(120) NULL,
  CONSTRAINT pk_artist PRIMARY KEY (artist_id)
);"
"CREATE TABLE public.album (
  album_id integer NOT NULL,
  title character varying(160) NOT NULL,
  artist_id integer NOT NULL,
  CONSTRAINT pk_album PRIMARY KEY (album_id),
  CONSTRAINT album_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES artist (artist_id)
);"
"CREATE TABLE public.employee (
  employee_id integer NOT NULL,
  last_name character varying(20) NOT NULL,
  first_name character varying(20) NOT NULL,
  title character varying(30) NULL,
  reports_to integer NULL,
  birth_date timestamp without time zone NULL,
  hire_date timestamp without time zone NULL,
  address character varying(70) NULL,
  city character varying(40) NULL,
  state character varying(40) NULL,
  country character varying(40) NULL,
  postal_code character varying(10) NULL,
  phone character varying(24) NULL,
  fax character varying(24) NULL,
  email character varying(60) NULL,
  CONSTRAINT pk_employee PRIMARY KEY (employee_id),
  CONSTRAINT employee_reports_to_fkey FOREIGN KEY (reports_to) REFERENCES employee (employee_id)
);"
"CREATE TABLE public.customer (
  customer_id integer NOT NULL,
  first_name character varying(40) NOT NULL,
  last_name character varying(20) NOT NULL,
  company character varying(80) NULL,
  address character varying(70) NULL,
  city character varying(40) NULL,
  state character varying(40) NULL,
  country character varying(40) NULL,
  postal_code character varying(10) NULL,
  phone character varying(24) NULL,
  fax character varying(24) NULL,
  email character varying(60) NOT NULL,
  support_rep_id integer NULL,
  CONSTRAINT pk_customer PRIMARY KEY (customer_id),
  CONSTRAINT customer_support_rep_id_fkey FOREIGN KEY (support_rep_id) REFERENCES employee (employee_id)
);"
"CREATE TABLE public.invoice (
  invoice_id integer NOT NULL,
  customer_id integer NOT NULL,
  invoice_date timestamp without time zone NOT NULL,
  billing_address character varying(70) NULL,
  billing_city character varying(40) NULL,
  billing_state character varying(40) NULL,
  billing_country character varying(40) NULL,
  billing_postal_code character varying(10) NULL,
  total numeric NOT NULL,
  CONSTRAINT pk_invoice PRIMARY KEY (invoice_id),
  CONSTRAINT invoice_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
);"
"CREATE TABLE public.invoice_line (
  invoice_line_id integer NOT NULL,
  invoice_id integer NOT NULL,
  track_id integer NOT NULL,
  unit_price numeric NOT NULL,
  quantity integer NOT NULL,
  CONSTRAINT pk_invoice_line PRIMARY KEY (invoice_line_id),
  CONSTRAINT invoice_line_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES invoice (invoice_id),
  CONSTRAINT invoice_line_track_id_fkey FOREIGN KEY (track_id) REFERENCES track (track_id)
);"
"CREATE TABLE public.track (
  track_id integer NOT NULL,
  name character varying(200) NOT NULL,
  album_id integer NULL,
  media_type_id integer NOT NULL,
  genre_id integer NULL,
  composer character varying(220) NULL,
  milliseconds integer NOT NULL,
  bytes integer NULL,
  unit_price numeric NOT NULL,
  CONSTRAINT pk_track PRIMARY KEY (track_id),
  CONSTRAINT track_album_id_fkey FOREIGN KEY (album_id) REFERENCES album (album_id),
  CONSTRAINT track_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES genre (genre_id),
  CONSTRAINT track_media_type_id_fkey FOREIGN KEY (media_type_id) REFERENCES media_type (media_type_id)
);"
"CREATE TABLE public.playlist (
  playlist_id integer NOT NULL,
  name character varying(120) NULL,
  CONSTRAINT pk_playlist PRIMARY KEY (playlist_id)
);"
"CREATE TABLE public.playlist_track (
  playlist_id integer NOT NULL,
  track_id integer NOT NULL,
  CONSTRAINT pk_playlist_track PRIMARY KEY (playlist_id, track_id),
  CONSTRAINT playlist_track_playlist_id_fkey FOREIGN KEY (playlist_id) REFERENCES playlist (playlist_id),
  CONSTRAINT playlist_track_track_id_fkey FOREIGN KEY (track_id) REFERENCES track (track_id)
);"
"CREATE TABLE public.genre (
  genre_id integer NOT NULL,
  name character varying(120) NULL,
  CONSTRAINT pk_genre PRIMARY KEY (genre_id)
);"
"CREATE TABLE public.media_type (
  media_type_id integer NOT NULL,
  name character varying(120) NULL,
  CONSTRAINT pk_media_type PRIMARY KEY (media_type_id)
);"
```
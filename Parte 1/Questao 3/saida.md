| | Nome da FK | Tabela Origem (Filha) | Coluna Origem (FK) | Tabela Destino (Pai) | Coluna Destino (PK) |
|---|---|---|---|---|---|
| 1 | album_artist_id_fkey | album | artist_id | artist | artist_id |
| 2 | customer_support_rep_id_fkey | customer | support_rep_id | employee | employee_id |
| 3 | employee_reports_to_fkey | employee | reports_to | employee | employee_id |
| 4 | invoice_customer_id_fkey | invoice | customer_id | customer | customer_id |
| 5 | invoice_line_invoice_id_fkey | invoice_line | invoice_id | invoice | invoice_id |
| 6 | invoice_line_track_id_fkey | invoice_line | track_id | track | track_id |
| 7 | playlist_track_playlist_id_fkey | playlist_track | playlist_id | playlist | playlist_id |
| 8 | playlist_track_track_id_fkey | playlist_track | track_id | track | track_id |
| 9 | track_album_id_fkey | track | album_id | album | album_id |
| 10 | track_genre_id_fkey | track | genre_id | genre | genre_id |
| 11 | track_media_type_id_fkey | track | media_type_id | media_type | media_type_id |
| | Tabela | Nome do Índice | Coluna Indexada |
|---|---|---|---|
| 1 | album | album_artist_id_idx | artist_id |
| 2 | album | album_pkey | album_id |
| 3 | artist | artist_pkey | artist_id |
| 4 | customer | customer_pkey | customer_id |
| 5 | customer | customer_support_rep_id_idx | support_rep_id |
| 6 | employee | employee_pkey | employee_id |
| 7 | employee | employee_reports_to_idx | reports_to |
| 8 | genre | genre_pkey | genre_id |
| 9 | invoice | invoice_customer_id_idx | customer_id |
| 10 | invoice | invoice_pkey | invoice_id |
| 11 | invoice_line | invoice_line_invoice_id_idx | invoice_id |
| 12 | invoice_line | invoice_line_pkey | invoice_line_id |
| 13 | invoice_line | invoice_line_track_id_idx | track_id |
| 14 | media_type | media_type_pkey | media_type_id |
| 15 | playlist | playlist_pkey | playlist_id |
| 16 | playlist_track | playlist_track_pkey | track_id |
| 17 | playlist_track | playlist_track_pkey | playlist_id |
| 18 | playlist_track | playlist_track_playlist_id_idx | playlist_id |
| 19 | playlist_track | playlist_track_track_id_idx | track_id |
| 20 | track | track_album_id_idx | album_id |
| 21 | track | track_genre_id_idx | genre_id |
| 22 | track | track_media_type_id_idx | media_type_id |
| 23 | track | track_pkey | track_id |
-- 5.1 다음 태스크에 적합한 query_view.sql을 작성하시오.
-- - 데이터 검색 쿼리 작성
-- - 필요시 뷰로 생성

-- <시나리오2>
-- ※ 주의사항: tracks 테이블에 artist_id 외래 키가 없으므로, albums 테이블을 통해 artists 테이블과 조인해야 함!
-- ① 부속질의를 사용하여 평균보다 많은 플레이 수(total_play)를 가진 아티스트 이름을 조회
SELECT a.name
FROM artists a
JOIN albums al ON a.artist_id = al.artist_id
JOIN tracks t ON al.album_id = t.album_id
WHERE t.total_play > (SELECT AVG(total_play) FROM tracks);
-- 	name
-- 	브루노 마스


-- ② 각 아티스트가 가진 트랙 수를 계산하는 뷰(artist_track_count)를 생성하고, 이를 이용해 트랙 수가 2개 이상인 아티스트를 조회
CREATE VIEW artist_track_count AS
SELECT a.name, COUNT(t.track_id) AS track_count
FROM artists a
JOIN albums al ON a.artist_id = al.artist_id
JOIN tracks t ON al.album_id = t.album_id
GROUP BY a.name;

-- 트랙 수가 2개 이상인 아티스트 조회
SELECT name
FROM artist_track_count
WHERE track_count >= 2;
-- 사브리나 카펜터
-- 로제
-- 브루노 마스

-- ③ playlists_tracks 테이블과 tracks, albums, artists 테이블을 조인하여
-- 트랙의 제목과 아티스트 이름을 조회, 이를 뷰(playlist_tracks_view)로 생성
-- 뷰 조회: SELECT * FROM playlist_tracks_view;
-- ④ 위의 뷰를 사용하여 플레이리스트 ID가 1인 플레이리스트의 트랙 1건
-- 조회 (LIMIT 사용)
CREATE VIEW playlist_tracks_view AS
SELECT pt.playlist_id, t.title, a.name
FROM playlists_tracks pt
JOIN tracks t ON pt.track_id = t.track_id
JOIN albums al ON t.album_id = al.album_id
JOIN artists a ON al.artist_id = a.artist_id;

-- ④ 위의 뷰를 사용하여 플레이리스트 ID가 1인 플레이리스트의 트랙 1건 조회 (LIMIT 사용)
SELECT * 
FROM playlist_tracks_view
WHERE playlist_id = 1
LIMIT 1;

-- 1	Espresso	사브리나 카펜터
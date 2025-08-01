-- 1-2. 데이터베이스 및 계정 셋팅 (setup_db.sql) (2점)

-- 새로운 계정 final_exam_[학번] 생성, 비밀번호 case02
create user 'final_exam_20215217'@'localhost' identified by 'case02';
-- 데이터베이스 finals_[학번]_CASE02 구축 
create database finals_20215217_CASE02;
-- 권한 부여
grant all privileges on finals_20215217_CASE02.* to 'final_exam_20215217'@'localhost';

-- 2-1. build_tables.sql

-- 생성한 데이터베이스를 사용해서 테이블을 구축한다.
use finals_20215217_CASE02;

-- 1. 사용자(users)
-- 고유한 사용자번호( user_id )로 식별하며, 이름( name ), 별칭( alias ),
-- 이메일( email ), 주소( address ), 가입일( join_date ) 정보를 가진다.
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,  -- 자동 증가하는 기본 키
    name varchar(100),
    alias varchar(100),
    email varchar(100),
    address varchar(100),
    join_date date
)AUTO_INCREMENT = 1; -- 기본 키가 1부터 증가하도록 설정

-- 2. 플레이리스트(playlists)
-- 고유한 플레이리스트번호( playlist_id )로 식별하며, 사용자번호( user_id )를 통해 
-- 이 플레이리스트를 만든 사용자를 식별할 수 있으며, 이는 users 테이블과 연계되어 있다.
-- 플레이리스트 제목( title ), 생성일자( created_date ), 메모( memo ) 정보를 가진다.
-- playlists_tracks 테이블을 통해 특정 플레이리스트에 포함된 트랙 정보를 연결할 수 있다.
create table playlists (
	playlist_id INT AUTO_INCREMENT PRIMARY KEY,  -- 자동 증가하는 기본 키
    user_id int,
    title varchar(100),
    created_date date,
    memo text,
    FOREIGN KEY (user_id) REFERENCES users(user_id)  -- 외래 키 설정
)AUTO_INCREMENT = 1;  -- 기본 키가 1부터 증가하도록 설정


-- 3. 아티스트(artists)
-- 고유한 아티스트번호( artist_id )로 식별하며, 아티스트 이름( name ),
-- 아티스트 설명( artist_desc ), 구독자 수( subscriber_count ) 정보를 가진다.
-- 이 테이블은 albums 테이블과의 관계를 통해 특정 앨범이 어떤 아티스트에 속하는지 식별할 수 있다.
create table artists(
	artist_id INT AUTO_INCREMENT PRIMARY KEY,  -- 자동 증가하는 기본 키
	name varchar(100),
	artist_desc text,
	subscriber_count int
)AUTO_INCREMENT = 1;  -- 기본 키가 1부터 증가하도록 설정


-- 4. 앨범(albums)
-- 고유한 앨범번호( album_id )로 식별한다.
-- 아티스트번호( artist_id )를 통해 이 앨범을 낸 아티스트를 식별하며,
-- 아티스트 삭제 시 연관된 앨범도 자동으로 삭제되도록 설정(ON DELETE CASCADE)되어 있다.
CREATE TABLE albums (
    album_id INT AUTO_INCREMENT PRIMARY KEY,  -- 자동 증가하는 기본 키
    artist_id INT,
    title VARCHAR(100),
    release_year YEAR,  -- 연도만 저장
    album_type ENUM('Single', 'Album'),  -- 앨범 유형
    total_tracks INT,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)  -- 외래 키 설정
    ON DELETE CASCADE  -- artist가 삭제되면 앨범도 자동 삭제
)AUTO_INCREMENT = 1;  -- 기본 키가 1부터 증가하도록 설정


-- 5. 트랙(tracks)
-- 고유한 트랙번호( track_id )로 식별한다.
-- 앨범번호( album_id )를 통해 각 트랙이 속한 앨범을 식별할 수 있다.
-- 트랙 제목( title ), 재생시간( duration ), 총 재생수( total_play ) 정보를 가진다.
-- 플레이리스트와 트랙의 연결을 표현하는 playlists_tracks 테이블을 통해,
-- 특정 플레이리스트에 어떤 곡이 포함되는지 알 수 있다.

create table tracks(
	track_id int auto_increment primary key,
    album_id int,
    title varchar(100),
    duration time,
    total_play int,
    foreign key(album_id) references albums(album_id)
)AUTO_INCREMENT = 1;  -- 기본 키가 1부터 증가하도록 설정


-- 6. 플레이리스트-트랙 관계(playlists_tracks)
-- 고유한 식별번호( id )로 식별하며, 플레이리스트번호( playlist_id )와
-- 트랙번호( track_id )를 통해 특정 플레이리스트에 속한 트랙들을 연결한다.
-- 이를 통해 하나의 플레이리스트가 여러 트랙을 가질 수 있고, 하나의 트랙도
-- 여러 플레이리스트에 속할 수 있는 N:M 관계를 형성한다

create table playlists_tracks(
	playlist_track_id int auto_increment primary key,
    playlist_id int,
    track_id int,
    foreign key(track_id) references tracks(track_id),
	foreign key(playlist_id) references playlists(playlist_id)
)AUTO_INCREMENT = 1;  -- 기본 키가 1부터 증가하도록 설정

-- 3-1. insert_data.sql

-- 시나리오02.xlsx 데이터를 그대로 users 테이블에 삽입한다.
insert into users (name, alias, email, address, join_date) values 
("김철수", "cheol777", "cs.kim@hallym.ac.kr",	"강원도 춘천시 퇴계동 A 아파트", "2021-01-10"),
("이영희", "lyh004", "yh.lee@hallym.ac.kr", "강원도 춘천시 소양동 B빌라", "2023-02-15"),
("박민수", "soosoo", "ms.park@hallym.ac.kr", "강원도 춘천시 우두동 C원룸", "2022-03-20"),
("최수정", "crystal_choi", "sj.choi@hallym.ac.kr", "강원도 춘천시 퇴계동 D아파트", "2024-04-25"),
("홍길동", "west_south8",	"gd.hong@hallym.ac.kr", "강원도 춘천시 우두동 E빌리지", "2023-05-30");

-- 시나리오02.xlsx 데이터를 그대로 playlists 테이블에 삽입한다.
insert into playlists (user_id, title, created_date, memo) values
(1, "2024 트렌딩", "2024-12-03", "최신곡들 모음"),
(2, "노동요", "2023-10-09", "출근해서 듣기"), 
(3,	"국내 겨울 음악", "2024-11-29", "포근한 노래"),
(4,	"Kpop Hits 2024", "2024-12-01",	"글로벌 케이팝"),
(5,	"Pop Hits",	"2024-12-01", "pop certified");

-- 시나리오02.xlsx 데이터를 그대로 artists 테이블에 삽입한다.
insert into artists (name, artist_desc, subscriber_count) values
("사브리나 카펜터",	"미국의 가수이자 배우", 10100000),
("로제", "걸그룹 BLACKPINK의 멤버", 13400000), 
("브루노 마스", "미국의 싱어송라이터", 39600000),
("지드래곤", "대한민국의 가수", 3300000);

-- 시나리오02.xlsx 데이터를 그대로 albums 테이블에 삽입한다.
insert into albums (artist_id, title, release_year, album_type, total_tracks) values
(1, "Short n Sweet", "2024", "Album", 12),
(2, "rosie", "2024", "Album", 12), 
(3, "24K Magic", "2016", "Album", 36),
(4, "POWER", "2024", "Single", 1);

-- 시나리오02.xlsx 데이터를 그대로 tracks 테이블에 삽입한다.
insert into tracks(album_id, title, duration, total_play) values
(1, "Espresso",	"0:02:56",	620000000),
(1, "Please, please, please", "0:03:07", 370000000), 
(2, "APT.",	"0:02:50", 500000000),
(2, "number one girl", "0:03:37", 57310000),
(3, "24K Magic", "0:03:46",	1900000000),
(3, "Finesse", "0:03:11", 476700000),
(4, "POWER", "0:02:24",	70850000);

-- 시나리오02.xlsx 데이터를 그대로 playlists_tracks 테이블에 삽입한다.
insert into playlists_tracks (playlist_id, track_id) values
(1, 1),
(1, 3),
(2, 5),
(2, 6),
(3, 4),
(4, 7),
(5, 2);

-- 데이터가 삽입이 되었는지 출력해서 확인한다.
select * from users;
select * from playlists;
select * from artists;
select * from albums;
select * from tracks;
select * from playlists_tracks;

-- 4-1. alter_data.sql

-- ① 데이터 변경 1: 플레이리스트의 메모 수정: '노동요' 플레이리스트의
-- 메모를 '출근할 때 듣는 신나는 노래들'로 변경
update playlists set memo = "출근할 때 듣는 신나는 노래들" where title = "노동요";
select * from playlists;

-- 삭제 구문 작성
-- ② 데이터 삭제 1: tracks 테이블에서 album_id가 4인 앨범 기록을 삭제
-- 데이터무결성으로 인하여 오류 발생
delete from tracks where album_id = 4;

-- playlists_tracks의 외래키 제약조건으로 삭제 불가능
-- 기존의 외래키를 삭제하고 ON CASCASE DELETE 제약 조건을 가진 외래키를 생성
ALTER TABLE playlists_tracks
DROP FOREIGN KEY playlists_tracks_ibfk_1;

ALTER TABLE playlists_tracks
ADD CONSTRAINT playlists_tracks_ibfk_1
FOREIGN KEY (track_id) REFERENCES tracks(track_id)
ON DELETE CASCADE;

-- 삭제한 테이블 확인
delete from tracks where album_id = 4;
select * from tracks;

-- 5-1. query_view.sql

-- <시나리오2>
-- ※ 주의사항: tracks 테이블에 artist_id 외래 키가 없으므로, albums 테이블을 통해 artists 테이블과 조인해야 함!
-- ① 부속질의를 사용하여 평균보다 많은 플레이 수(total_play)를 가진 아티스트 이름을 조회
SELECT a.name, t.total_play
FROM artists a
JOIN albums al ON a.artist_id = al.artist_id
JOIN tracks t ON al.album_id = t.album_id
WHERE t.total_play > (SELECT AVG(total_play) FROM tracks);


-- ② 각 아티스트가 가진 트랙 수를 계산하는 뷰(artist_track_count)를 생성하고, 이를 이용해 트랙 수가 2개 이상인 아티스트를 조회
CREATE VIEW artist_track_count AS
SELECT a.name, COUNT(t.track_id) AS track_count
FROM artists a
JOIN albums al ON a.artist_id = al.artist_id
JOIN tracks t ON al.album_id = t.album_id
GROUP BY a.name;

SELECT name, track_count
FROM artist_track_count
WHERE track_count >= 2;

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

SELECT * FROM playlist_tracks_view;

-- ④ 위의 뷰를 사용하여 플레이리스트 ID가 1인 플레이리스트의 트랙 1건 조회 (LIMIT 사용)
SELECT * 
FROM playlist_tracks_view
WHERE playlist_id = 1
LIMIT 1;

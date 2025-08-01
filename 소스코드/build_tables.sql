use finals_20215217_CASE02;

-- 1. 사용자(users)
-- - 고유한 사용자번호( user_id )로 식별하며, 이름( name ), 별칭( alias ),
-- 이메일( email ), 주소( address ), 가입일( join_date ) 정보를 가진다.
-- 2. 플레이리스트(playlists)
-- - 고유한 플레이리스트번호( playlist_id )로 식별하며,
-- - 사용자번호( user_id )를 통해 이 플레이리스트를 만든 사용자를 식별할 수
-- 있으며, 이는 users 테이블과 연계되어 있다.
-- - 플레이리스트 제목( title ), 생성일자( created_date ), 메모( memo ) 정보를
-- 가진다.
-- - playlists_tracks 테이블을 통해 특정 플레이리스트에 포함된 트랙 정보를
-- 연결할 수 있다.
-- 3. 아티스트(artists)
-- - 고유한 아티스트번호( artist_id )로 식별하며, 아티스트 이름( name ),
-- 아티스트 설명( artist_desc ), 구독자 수( subscriber_count ) 정보를 가진다.
-- - 이 테이블은 albums 테이블과의 관계를 통해 특정 앨범이 어떤 아티스트에
-- 속하는지 식별할 수 있다.
-- 4. 앨범(albums)
-- - 고유한 앨범번호( album_id )로 식별한다.
-- - 아티스트번호( artist_id )를 통해 이 앨범을 낸 아티스트를 식별하며, 아티스트
-- 삭제 시 연관된 앨범도 자동으로 삭제되도록 설정(ON DELETE
-- CASCADE)되어 있다.
--  - 앨범 제목( title ), 발매연도( release_year ), 앨범 종류( album_type ), 총 트랙
-- 수( total_tracks ) 정보를 가진다.
--  - 앨범 종류( album_type )는 'Single', 'Album' 중 하나로 설정된다.
--  - albums 테이블은 tracks 테이블과의 관계를 통해 특정 트랙의 소속 앨범을
-- 파악할 수 있도록 한다.


CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,  -- 자동 증가하는 기본 키
    name varchar(100),
    alias varchar(100),
    email varchar(100),
    address varchar(100),
    join_date date
);

create table playlists (
	playlist_id INT AUTO_INCREMENT PRIMARY KEY,  -- 자동 증가하는 기본 키
    user_id int,
    title varchar(100),
    created_date date,
    memo text,
    FOREIGN KEY (user_id) REFERENCES users(user_id)  -- 외래 키 설정
	ON DELETE CASCADE -- user가 삭제되면 플레이리스트도 자동 삭제
    -- ON UPDATE CASCADE -- user가 업데이트되면 플레이리스트도 자동 삭제
);

create table artists(
	artist_id INT AUTO_INCREMENT PRIMARY KEY,  -- 자동 증가하는 기본 키
	name varchar(100),
	artist_desc text,
	subscriber_count int
);

CREATE TABLE albums (
    album_id INT AUTO_INCREMENT PRIMARY KEY,  -- 자동 증가하는 기본 키
    artist_id INT,
    title VARCHAR(100),
    release_year YEAR,  -- 연도만 저장
    album_type ENUM('Single', 'Album'),  -- 앨범 유형
    total_tracks INT,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)  -- 외래 키 설정
    ON DELETE CASCADE  -- artist가 삭제되면 앨범도 자동 삭제
);

-- 5. 트랙(tracks)
--  - 고유한 트랙번호( track_id )로 식별한다.
--  - 앨범번호( album_id )를 통해 각 트랙이 속한 앨범을 식별할 수 있다.
--  - 트랙 제목( title ), 재생시간( duration ), 총 재생수( total_play ) 정보를 가진다.
--  - 플레이리스트와 트랙의 연결을 표현하는 playlists_tracks 테이블을 통해,
-- 특정 플레이리스트에 어떤 곡이 포함되는지 알 수 있다.

create table tracks(
	track_id int auto_increment primary key,
    album_id int,
    title varchar(100),
    duration time,
    total_play int,
    foreign key(album_id) references albums(album_id)
    on delete cascade
);

-- 6. 플레이리스트-트랙 관계(playlists_tracks)
-- - 고유한 식별번호( id )로 식별하며, 플레이리스트번호( playlist_id )와
-- 트랙번호( track_id )를 통해 특정 플레이리스트에 속한 트랙들을 연결한다.
-- - 이를 통해 하나의 플레이리스트가 여러 트랙을 가질 수 있고, 하나의 트랙도
-- 여러 플레이리스트에 속할 수 있는 N:M 관계를 형성한다

create table playlists_tracks(
	playlist_track_id int auto_increment primary key,
    playlist_id int,
    track_id int,
    foreign key(track_id) references tracks(track_id),
	foreign key(playlist_id) references playlists(playlist_id)
    on delete cascade   
);


use finals_20215217_case02;

insert into users (name, alias, email, address, join_date) values 
("김철수", "cheol777", "cs.kim@hallym.ac.kr",	"강원도 춘천시 퇴계동 A 아파트", "2021-01-10"),
("이영희", "lyh004", "yh.lee@hallym.ac.kr", "강원도 춘천시 소양동 B빌라", "2023-02-15"),
("박민수", "soosoo", "ms.park@hallym.ac.kr", "강원도 춘천시 우두동 C원룸", "2022-03-20"),
("최수정", "crystal_choi", "sj.choi@hallym.ac.kr", "강원도 춘천시 퇴계동 D아파트", "2024-04-25"),
("홍길동", "west_south8",	"gd.hong@hallym.ac.kr", "강원도 춘천시 우두동 E빌리지", "2023-05-30");

insert into playlists (user_id, title, created_date, memo) values
(1, "2024 트렌딩",	"2024-12-03", "최신곡들 모음"),
(2, "노동요", "2023-10-09", "출근해서 듣기"), 
(3,	"국내 겨울 음악",	"2024-11-29",	"포근한 노래"),
(4,	"Kpop Hits 2024", "2024-12-01",	"글로벌 케이팝"),
(5,	"Pop Hits",	"2024-12-01",	"pop certified");

insert into artists (name, artist_desc, subscriber_count) values
("사브리나 카펜터",	"미국의 가수이자 배우",	10100000),
("로제",	"걸그룹 BLACKPINK의 멤버",	13400000), 
("브루노 마스",	"미국의 싱어송라이터",	39600000),
("지드래곤",	"대한민국의 가수",	3300000);

insert into albums (artist_id, title, release_year, album_type, total_tracks) values
(1, "Short n Sweet", "2024",	"Album",	12),
(2, "rosie",	"2024",	"Album",	12), 
(3, "24K Magic",	"2016",	"Album",	36),
(4, "POWER",	"2024", "Single",	1);

insert into tracks(album_id, title, duration, total_play) values
(1, "Espresso",	"0:02:56",	620000000),
(1, "Please, please, please",	"0:03:07",	370000000), 
(2, "APT.",	"0:02:50",	500000000),
(2, "number one girl",	"0:03:37",	57310000),
(3, "24K Magic", "0:03:46",	1900000000),
(3, "Finesse",	"0:03:11",	476700000),
(4, "POWER",	"0:02:24",	70850000);

insert into playlists_tracks (playlist_id, track_id) values
(1, 1),
(1, 3),
(2, 5),
(2, 6),
(3, 4),
(4, 7),
(5, 2);

use finals_20215217_case02;
select * from users;
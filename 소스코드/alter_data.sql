use finals_20215217_case02;

-- - 변경할 데이터 구문 작성
-- - 변경된 테이블 확인
-- ① 데이터 변경 1: 플레이리스트의 메모 수정: '노동요' 플레이리스트의
-- 메모를 '출근할 때 듣는 신나는 노래들'로 변경
update playlists set memo = "출근할 때 듣는 신나는 노래들" where title = "노동요";
select * from playlists;

-- 삭제 구문 작성
-- - 발생가능한 오류 - 해결 방법 제시 및 설명
-- - 삭제한 테이블 확인
-- ② 데이터 삭제 1: tracks 테이블에서 album_id가 4인 앨범 기록을 삭제
delete from tracks where album_id = 4;
select * from tracks;
-- 외래키 제약조건으로 삭제 불가능
-- 외래키 제약 조건을 수정하고 삭제 시도

-- alter table tracks drop foreign key tracks_ibfk_1;
-- alter table tracks
-- add constraint fk_album_id
-- foreign key (album_id) references albums(album_id)
-- on delete cascade;

ALTER TABLE playlists_tracks
DROP FOREIGN KEY playlists_tracks_ibfk_1;

ALTER TABLE playlists_tracks
ADD CONSTRAINT playlists_tracks_ibfk_1
FOREIGN KEY (track_id) REFERENCES tracks(track_id)
ON DELETE CASCADE;
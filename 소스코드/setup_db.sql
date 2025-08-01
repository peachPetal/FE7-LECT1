-- 1-2. 데이터베이스 및 계정 셋팅 (setup_db.sql) (2점)
-- 새로운 계정 final_exam_[학번] 생성, 비밀번호 case01/case02/case03...
-- 데이터베이스 finals_[학번]_CASE01 구축 (setup_db.sql)
-- 예) 20215177 학번, 2번 시나리오 ==> finals_20215177_CASE02
-- 권한 부여

create user 'final_exam_20215217'@'localhost' identified by 'case02';
create database finals_20215217_CASE02;
grant all privileges on finals_20215217_CASE02.* to 'final_exam_20215217'@'localhost';
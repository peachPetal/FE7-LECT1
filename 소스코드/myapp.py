import streamlit as st
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from datetime import datetime
import pandas as pd
import re

# --- DB 연결 설정 ---
DB_USER = 'your_db_user'
DB_PASSWORD = 'your_db_password'
DB_HOST = 'your_db_host'
DB_PORT = '3306'  # 기본 MySQL 포트
DB_NAME = 'your_db_name'

DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}?charset=utf8mb4"

# SQLAlchemy 엔진 및 세션 생성
engine = create_engine(DATABASE_URL, echo=False, future=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# --- 세션 상태 초기화 ---
if 'logged_in' not in st.session_state:
    st.session_state.logged_in = False
if 'user_alias' not in st.session_state:
    st.session_state.user_alias = ""

# --- 사이드바 UI ---
with st.sidebar:
    st.header("음악 스트리밍")

    if not st.session_state.logged_in:
        st.error("로그인이 필요합니다")
    else:
        st.success(f"🟢 {st.session_state.user_alias}님으로 로그인됨")

    tab1, tab2 = st.tabs(['로그인', '회원가입'])

    # 로그인 탭
    with tab1:
        with SessionLocal() as session:
            result = session.execute(text('SELECT alias FROM users'))
            alias_list = [row[0] for row in result.fetchall()]
        selected_alias = st.selectbox("사용자 선택", alias_list)

        if st.button('로그인', key="login_button"):
            if selected_alias:
                st.session_state.logged_in = True
                st.session_state.user_alias = selected_alias
                st.experimental_rerun()

    # 회원가입 탭
    with tab2:
        name = st.text_input("이름")
        alias = st.text_input("별칭")
        email = st.text_input("이메일")
        address = st.text_input("주소")
        created_at = st.date_input("날짜를 선택하세요", value=datetime.today())

        if st.button('가입하기', key="sign_button"):
            with SessionLocal() as session:
                try:
                    # 중복 alias 체크 예시
                    result = session.execute(text("SELECT 1 FROM users WHERE alias = :alias"), {"alias": alias})
                    if result.first():
                        st.error("이미 존재하는 별칭입니다.")
                    else:
                        session.execute(
                            text('''
                                INSERT INTO users (name, alias, email, address, join_date)
                                VALUES (:name, :alias, :email, :address, :join_date)
                            '''), {
                                "name": name,
                                "alias": alias,
                                "email": email,
                                "address": address,
                                "join_date": created_at
                            }
                        )
                        session.commit()
                        st.success("회원가입이 완료되었습니다!")
                except Exception as e:
                    st.error(f"회원가입 중 오류가 발생하였습니다: {str(e)}")

# --- 플레이리스트에 트랙 추가 함수 ---
def add_playlist_query(playlist_id, track_ids):
    with SessionLocal() as session:
        try:
            session.execute(
                text("""
                    INSERT INTO playlists_tracks (playlist_id, track_id)
                    VALUES (:playlist_id, :track_id)
                """),
                [{"playlist_id": playlist_id, "track_id": track_id} for track_id in track_ids]
            )
            session.commit()
        except Exception as e:
            raise Exception(f"저장 중 오류가 발생하였습니다: {str(e)}")

        except Exception as e:
            st.error(f"플레이리스트 조회 중 오류가 발생하였습니다: {str(e)}")


import streamlit as st
from sqlalchemy import text
from datetime import datetime
import pandas as pd
import re

# 페이지의 레이아웃 설정
st.set_page_config(
    layout="wide"  # "wide"로 설정하면, 화면을 넓게 활용할 수 있습니다.
)

# MySQL 데이터베이스 연결
conn = st.connection('mysql', type='sql')

# 로그인 세션 상태 초기화
if 'logged_in' not in st.session_state:
    st.session_state.logged_in = False
if 'user_alias' not in st.session_state:
    st.session_state.user_alias = ""

# 사이드바 UI
with st.sidebar:
    st.header("음악 스트리밍")
    
    # 로그인 상태 메시지
    if not st.session_state.logged_in:
        st.error("로그인이 필요합니다")
    else:
        st.success(f"🟢{st.session_state.user_alias}님으로 로그인됨")

    # 로그인 탭, 회원가입 탭
    tab1, tab2 = st.tabs(['로그인', '회원가입'])

    # 로그인 탭
    with tab1:
        # 사용자 선택 select box, DB에서 alias를 드롭다운으로 읽어옴
        alias = conn.session.execute(text('SELECT alias FROM users'))
        selected_alias = st.selectbox("사용자 선택", alias)

        # 로그인 버튼
        if st.button('로그인', key="login_button"):
            if selected_alias:
                # 로그인 상태로 변경
                st.session_state.logged_in = True
                st.session_state.user_alias = selected_alias            
                # 최상단 메시지 업데이트를 위해 rerun 호출
                st.rerun()

    # 회원가입 탭
    with tab2:
        name = st.text_input("이름")  
        alias = st.text_input("별칭") 
        email = st.text_input("이메일") 
        address = st.text_input("주소") 
        created_at = st.date_input("날짜를 선택하세요", value=datetime.today()) 
        
        if st.button('가입하기', key="sign_button"):
            # 입력된 데이터를 바인딩하여 쿼리 실행
            query = text('''INSERT INTO users (name, alias, email, address, join_date) 
                            VALUES (:name, :alias, :email, :address, :join_date)''')
            
            # 쿼리 실행
            conn.session.execute(query, {
                "name": name,
                "alias": alias,
                "email": email,
                "address": address,
                "join_date": created_at
            })

            # 커밋해서 데이터베이스에 반영
            conn.session.commit()

            st.success("회원가입이 완료되었습니다!")

# 플레이리스트에 선택한 트랙을 추가하는 함수
def add_playlist_query(playlist_id, track_ids):
    with conn.session as session:
        try:
            # 여러 track_id를 한 번에 추가하는 쿼리 작성
            session.execute(
                text("""
                INSERT INTO playlists_tracks(playlist_id, track_id)
                VALUES (:playlist_id, :track_id)
                """),
                [{"playlist_id": playlist_id, "track_id": track_id} for track_id in track_ids]
            )
            session.commit()
        except Exception as e:
            raise Exception(f"저장 중 오류가 발생하였습니다: {str(e)}")

# 플레이리스트에 트랙을 추가하는 팝업창을 띄우는 다이얼로그
@st.dialog("플레이리스트에 추가")
def add_playlist(title):
    with conn.session as s:
        # 트랙 조회 쿼리
        result_t = s.execute(
            text("""
            SELECT
                t.track_id,
                t.title AS track_title,
                t.duration,
                t.total_play
            FROM tracks t
            JOIN albums a ON t.album_id = a.album_id
            WHERE a.title = :title
            """),
            {"title": title}
        )
        # 플레이리스트 조회 쿼리
        result_p = s.execute(
            text("""
            SELECT
                playlist_id,
                title
            FROM playlists
            """)
        )
        playlists = list(result_p.fetchall())
        options = [re.sub(r"['\"]", '', item[1]) for item in playlists]  # playlists의 title을 options로 사용
        playlist_ids = [item[0] for item in playlists]  # playlist_id 값을 별도로 저장

        # 결과를 pandas DataFrame으로 변환
        df_t = pd.DataFrame(result_t.fetchall(), columns=result_t.keys())
        
        with st.container():
            st.subheader(f"💿 {title}")  # 앨범 제목 출력
            selected_option = st.selectbox("플레이리스트를 선택하세요", options)  # 플레이리스트 선택
            selected_playlist_id = playlist_ids[options.index(selected_option)]  # 선택된 playlist_id 가져오기

            st.write("추가할 곡을 선택하세요:")
            track_ids = []  # 체크된 track_id들을 저장할 리스트
            for idx, row in enumerate(df_t.itertuples(index=True), start=1):
                col1, col2, col3, col4 = st.columns([0.5, 1, 1, 1])
                with col1:
                    # 체크박스의 값으로 track_id를 사용
                    checked = st.checkbox(label=' ', key=f"track_{row.track_id}")  # 고유 키 생성
                    if checked:
                        track_ids.append(row.track_id)  # 체크된 track_id 저장
                with col2:
                    st.write(f"**{idx}. {row.track_title}**")  # 1. title 형식으로 출력
                with col3:
                    st.markdown(f"<span style='color:black;'>{row.duration}</span>", unsafe_allow_html=True)
                with col4:
                    st.markdown(f"재생수: <span style='color:black;'>{row.total_play:,}</span>", unsafe_allow_html=True)

        st.divider()

        # '선택한 곡들을 플레이리스트에 추가' 버튼 클릭 시
        if st.button("선택한 곡들을 플레이리스트에 추가", type="primary"):
            if track_ids:  # 선택된 곡이 있는 경우
                try:
                    # 플레이리스트에 선택한 곡 추가
                    add_playlist_query(selected_playlist_id, track_ids)

                    # 성공 메시지 출력
                    st.success(f"{len(track_ids)}곡이 플레이리스트에 추가되었습니다!")
                except Exception as e:
                    # 오류 발생 시 에러 메시지 출력
                    st.error(str(e))
            else:
                # 선택된 곡이 없을 경우 경고 메시지 출력
                st.warning("추가할 곡을 선택하세요!")

# 앨범 상세정보를 띄우는 다이얼로그
@st.dialog("앨범 상세정보")
def show_album(name, title):
    with conn.session as s:
        query = text("""
            SELECT 
                ar.name, 
                ar.artist_desc, 
                ar.subscriber_count, 
                al.title, 
                al.release_year, 
                al.album_type, 
                al.total_tracks
            FROM artists ar
            JOIN albums al ON ar.artist_id = al.artist_id
            WHERE ar.name = :name
        """)
        query_2 = text("""
            SELECT
                a.title, 
                t.title as track_title,
                t.duration,
                t.total_play       
            FROM tracks t
            JOIN albums a ON t.album_id = a.album_id
            WHERE a.title = :title
        """)
        result_a = conn.session.execute(query, {"name": name})
        result_t = conn.session.execute(query_2, {"title": title})
        # 결과를 pandas DataFrame으로 변환
        df_a = pd.DataFrame(result_a.fetchall(), columns=result_a.keys())
        df_t = pd.DataFrame(result_t.fetchall(), columns=result_t.keys())

        with st.container():
            col1, col2 = st.columns([1, 1])
            with col1:
                for row in df_a.itertuples():
                    st.subheader("**👤 아티스트 정보**")
                    st.markdown(f"**{row.name}**") # bold체
                    st.write(row.artist_desc)
                    st.markdown(f"구독자 수: <span style='color:black;'>{row.subscriber_count:,}</span>명", unsafe_allow_html=True)
                    st.divider()
                    st.subheader("**💿 앨범 정보**")
                    st.write("**앨범명:**", row.title) # bold체
                    st.markdown(f"**발매년도:** <span style='color:black;'>{ row.release_year}</span>", unsafe_allow_html=True) 
                    st.write("**앨범 유형:**", row.album_type) # bold체
                    st.markdown(f"**총 곡 수:** <span style='color:black;'>{ row.total_tracks}</span>곡", unsafe_allow_html=True)
            with col2:
                st.subheader("**🎵 수록곡**") 
                col1, col2 = st.columns([1, 1])
                for idx, row in enumerate(df_t.itertuples(index=True), start=1):
                    col3, col4 = st.columns([1, 1])
                    with col3:
                        st.write(f"**{idx}.{row.track_title}**") # 1.title 형식으로 출력되게
                        st.markdown(f"*<span style='color:black;'>{row.duration}</span>*", unsafe_allow_html=True) 
                    with col4:
                        st.markdown(f"재생수: <span style='color:black;'>{row.total_play:,}</span>", unsafe_allow_html=True)
                    st.divider()

#플레이리스트의 수록곡 정보
@st.dialog("수록곡")
def show_playlist_tracks(playlist_title):
    with conn.session as s:
        query_2 = text("""
            SELECT 
                t.title AS track_title, 
                t.duration, 
                t.total_play, 
                ar.name AS artist_name
            FROM tracks t
            LEFT JOIN playlists_tracks pt ON pt.track_id = t.track_id
            LEFT JOIN playlists p ON p.playlist_id = pt.playlist_id
            LEFT JOIN albums a ON a.album_id = t.album_id
            LEFT JOIN artists ar ON ar.artist_id = a.artist_id
            WHERE p.title = :playlist_title;
        """)
        result_t = conn.session.execute(query_2, {"playlist_title": playlist_title})
        # 결과를 pandas DataFrame으로 변환
        df_t = pd.DataFrame(result_t.fetchall(), columns=result_t.keys())

        with st.container():
            st.subheader("**🎵 수록곡**") 
            for idx, row in enumerate(df_t.itertuples(index=True), start=1):
                col1, col2 = st.columns([4, 1])  # 첫 번째 컬럼은 좁게, 두 번째 컬럼은 넓게
                
                with col1:
                    # 트랙 제목과 아티스트 이름을 세로로 표시
                    st.write(f"**{idx}. {row.track_title}**")  # 트랙 제목
                    st.write(f"{row.track_title}-{row.artist_name}")        # 아티스트 이름
                    col3, col4 = st.columns([5, 4])
                    with col3:
                    # 재생시간과 재생수를 가로로 표시
                        st.markdown(f"*재생시간: <span style='color:black;'>{row.duration}</span>*", unsafe_allow_html=True) 
                    with col4:
                        st.markdown(f"재생수: <span style='color:black;'>{row.total_play:,}</span>", unsafe_allow_html=True)
                
                with col2:
                    pass
                
                st.divider()  # 각 트랙마다 구분선 추가

# 메인 화면 UI
# 음악 목록, 플레이리스트 탭
tab1, tab2 = st.tabs(['음악 목록', '플레이리스트'])

with tab1:
    st.header("음악 목록")

    # 음악 목록 불러오기 
    # f-string을 사용하여 날짜 변수를 쿼리 내에 삽입
    query = f"""
        SELECT
            ar.name,
            al.title,
            al.release_year,
            al.album_type
        FROM artists ar
        JOIN albums al ON ar.artist_id = al.artist_id
        ORDER BY al.album_type = 'single' DESC, ar.name ASC;
    """
    df = conn.query(query, ttl=0)
    
    # 가수 목록 출력
    for row in df.itertuples():
        with st.container():
            col1, col2, col3, col4 = st.columns([2, 4, 2, 2])
            with col1:
                st.markdown(f"**{row.title}**") # bold체
                st.write(f"아티스트: {row.name}")
            # 두 컬럼 사이에 간격을 두고 출력하고 싶다.
            with col2:
                pass
            with col3:
                st.write(f"발매: {row.release_year}")
                st.markdown(f"*{row.album_type}*") # italic체
            with col4:
                if st.button(f"앨범보기", key=f"view_album_button_{row.Index}"):

                    show_album(row.name, row.title)
                if st.button("플레이리스트에 추가", type="primary", key=f"add_playlist_button_{row.Index}"):
                    add_playlist(row.title)
            st.divider()

with tab2:
    st.header("내 플레이리스트")

    # "새 플레이리스트 만들기" 확장 메뉴
    with st.expander("새 플레이리스트 만들기"):
        playlist_input = st.text_input("플레이리스트 제목", placeholder="플레이리스트 제목을 입력하세요")
        memo_input = st.text_area("메모", placeholder="플레이리스트에 대한 메모를 입력하세요")

        # 텍스트 입력창 크기에 맞는 버튼 스타일 정의
        st.markdown(
            """
            <style>
            .stButton > button {
                width: 100%;  
                height: 40px; 
                font-size: 16px;  
            }
            </style>
            """,
            unsafe_allow_html=True
        )
        # 로그인한 사용자의 user_id를 가져오는 쿼리
        user_id = None
        if st.session_state.logged_in:
            user_alias = st.session_state.user_alias
            with conn.session as session:
                result = session.execute(
                    text("""SELECT user_id FROM users WHERE alias = :alias"""),
                    {"alias": user_alias}
                )
                user_id = result.scalar()  # 첫 번째 컬럼값(user_id)만 가져옴
        # '생성하기' 버튼 클릭 시 실행
        if st.button("생성하기"):
            if not playlist_input.strip():
                st.warning("플레이리스트 제목을 입력하세요!")
            else:
                with conn.session as session:
                    try:
                        session.execute(
                            text("""
                            INSERT INTO playlists (user_id, title, memo, created_date)
                            VALUES (:user_id, :title, :memo, NOW())
                            """),
                            {"user_id": user_id, "title": playlist_input.strip(), "memo": memo_input.strip()}
                        )
                        session.commit()
                        st.success(f"'{playlist_input}' 플레이리스트가 생성되었습니다!")
                    except Exception as e:
                        st.error(f"플레이리스트 생성 중 오류가 발생하였습니다: {str(e)}")

    st.divider()  # 시각적 구분선

    # 플레이리스트 목록 및 수록곡 개수 조회
    st.subheader("🎵 저장된 플레이리스트 목록")
    with conn.session as session:
        try:
            # 플레이리스트와 수록곡 개수 조회
            result = session.execute(
                text("""
                SELECT 
                    p.title AS playlist_title,
                    p.created_date,
                    p.memo,
                    COUNT(pt.track_id) AS track_count
                FROM playlists p
                LEFT JOIN playlists_tracks pt ON p.playlist_id = pt.playlist_id
                GROUP BY p.playlist_id
                ORDER BY p.created_date DESC
                """)
            )
            playlists = result.fetchall()

            if not playlists:
                st.info("저장된 플레이리스트가 없습니다. 새 플레이리스트를 만들어 보세요!")
            else:
                # 플레이리스트 출력
                for playlist in playlists:
                    with st.container():
                        col1, col2 = st.columns([3, 1])
                        with col1:
                            st.markdown(f"**🎶 {playlist.playlist_title}**")
                            st.markdown(f"📅 생성일: {playlist.created_date.strftime('%Y-%m-%d')}")
                            if playlist.memo:
                                st.markdown(f"📝 메모: {playlist.memo}")
                            st.markdown(f"🎵 수록곡 개수: {playlist.track_count}곡")
                        with col2:
                            if st.button("삭제", key=f"delete_{playlist.playlist_title}"):
                                try:
                                    # 플레이리스트 삭제
                                    session.execute(
                                        text("""
                                        DELETE FROM playlists WHERE title = :title
                                        """),
                                        {"title": playlist.playlist_title}
                                    )
                                    session.commit()
                                    st.success(f"'{playlist.playlist_title}'이 삭제되었습니다!")
                                except Exception as e:
                                    st.error(f"삭제 중 오류가 발생하였습니다: {str(e)}")

                            if st.button("수록곡 보기", key=f"view_{playlist.playlist_title}"):
                                show_playlist_tracks(playlist.playlist_title)

                    st.divider()  # 플레이리스트 간 구분선

        except Exception as e:
            st.error(f"플레이리스트 조회 중 오류가 발생하였습니다: {str(e)}")


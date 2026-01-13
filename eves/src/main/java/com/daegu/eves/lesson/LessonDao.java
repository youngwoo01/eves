package com.daegu.eves.lesson;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.PreparedStatementCreator;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.daegu.eves.week.WeekVo;

@Repository
public class LessonDao {
   @Autowired
   JdbcTemplate jdbcTemplate;

   private RowMapper<LessonVo> rowMapper = BeanPropertyRowMapper.newInstance(LessonVo.class);
   // 강의 삭제 (하위 데이터 포함)
   @Transactional
   public int LessonDelete(int lno) {
       // 1. 주차(weeks) 삭제
       String sqlWeek = "DELETE FROM weeks WHERE lno = ?";
       jdbcTemplate.update(sqlWeek, lno);

       // 2. PDF 삭제
       String sqlPdf = "DELETE FROM pdf WHERE lno = ?";
       jdbcTemplate.update(sqlPdf, lno);

       // 3. 수강 연결(bridge) 삭제
       String sqlBridge = "DELETE FROM bridge WHERE lno = ?";
       jdbcTemplate.update(sqlBridge, lno);

       // 4. 마지막으로 강의 삭제
       String sqlLesson = "DELETE FROM lesson WHERE lno = ?";
       return jdbcTemplate.update(sqlLesson, lno);
   }
   
   // 회원이 특정 강의를 이미 등록했는지 확인 (중복 등록 방지용)
   public int countEnroll(int uno, int lno) {
       String sql = "SELECT COUNT(*) FROM bridge WHERE uno = ? AND lno = ?";
       return jdbcTemplate.queryForObject(sql, Integer.class, uno, lno);
   }
   
   // 회원이 "수강하기"를 눌렀을 때 bridge 테이블에 (uno, lno) INSERT
   public void insertEnroll(int uno, int lno) {
       String sql = "INSERT INTO bridge (uno, lno) VALUES (?, ?)";
       jdbcTemplate.update(sql, uno, lno);
   }
   
   // 메인페이지 기능
   public List<LessonVo> getLessonList(int start, int size){
       String sql = "SELECT l.lno, l.lname, l.lcate, l.llevel, l.lsum, " +
                   "l.ldate, l.lweek, l.lhit, t.tname " +
                   "FROM lesson l " +
                   "JOIN teacher t ON l.tno = t.tno " +
                   "ORDER BY l.ldate DESC " +
                   "LIMIT ?, ?";
      RowMapper<LessonVo> rowMapper = 
            BeanPropertyRowMapper.newInstance(LessonVo.class);
      List<LessonVo> reuslt = jdbcTemplate.query(sql, rowMapper, start, size);
      return reuslt;
   }
   
   //레슨별 주차
   public List<LessonVo> getLessonLists(){
       String sql = "SELECT l.lno, l.lname, l.lcate, l.llevel, l.lsum, " +
                   "l.ldate, l.lweek, l.lhit, t.tname " +
                   "FROM lesson l " +
                   "JOIN teacher t ON l.tno = t.tno " +
                   "ORDER BY l.ldate DESC";
      RowMapper<LessonVo> rowMapper = 
            BeanPropertyRowMapper.newInstance(LessonVo.class);
      List<LessonVo> reuslt = jdbcTemplate.query(sql, rowMapper);
      return reuslt;
   }

   // 특정 lno에 대한 강의 정보 1건
   public LessonVo findLessonInfo(int lno) {
       String sql =
           "SELECT l.lno, l.lname, l.lcate, l.llevel, l.lsum, t.tname " +
           "FROM lesson l " +
           "JOIN teacher t ON l.tno = t.tno " +
           "WHERE l.lno = ?";
       return jdbcTemplate.queryForObject(sql, rowMapper, lno);
   }
   
    // 검색 결과 목록 (페이징 포함)
    public List<LessonVo> searchLessons(String type, String keyword, int offset, int size) {
        String sql = "SELECT l.lno, l.lname, l.lcate, l.llevel, l.lsum, " +
                     "l.ldate, l.lweek, l.lhit, t.tname " +
                     "FROM lesson l JOIN teacher t ON l.tno = t.tno WHERE ";

        if ("lname".equals(type)) {
            sql += "l.lname LIKE ? ";
        } else if ("tname".equals(type)) {
            sql += "t.tname LIKE ? ";
        }

        sql += "ORDER BY l.ldate DESC LIMIT ?, ?";

        RowMapper<LessonVo> rowMapper = BeanPropertyRowMapper.newInstance(LessonVo.class);
        return jdbcTemplate.query(sql, rowMapper, "%" + keyword + "%", offset, size);
    }
   
    // 검색 결과 개수
    public int countSearchLessons(String type, String keyword) {
        String sql = "SELECT COUNT(*) FROM lesson l JOIN teacher t ON l.tno = t.tno WHERE ";
        if ("lname".equals(type)) {
            sql += "l.lname LIKE ?";
        } else if ("tname".equals(type)) {
            sql += "t.tname LIKE ?";
        }
        return jdbcTemplate.queryForObject(sql, Integer.class, "%" + keyword + "%");
    }
   
   // 페이지 기능
   public int getCountBoard() {
      String sql = "SELECT COUNT(*) FROM lesson l JOIN teacher t ON l.tno = t.tno";
      int result = jdbcTemplate.queryForObject(sql, Integer.class);
      return result;
   }
   
   // 주차하지 마세요.
   //강의 정보
   public LessonVo getLesson(int lno) {
      String sql = "select * from lesson where lno=?";
      return jdbcTemplate.queryForObject(sql, new BeanPropertyRowMapper<>(LessonVo.class), lno);
   }
   
   //강의별 레슨 리스트
   public List<WeekVo> getLessons(int lno){
      String sql = "select * from weeks where lno=? order by wno asc";
      return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(WeekVo.class), lno);
   }
   
   public int updateLesson(LessonVo vo) {
       String sql;
       if (StringUtils.hasText(vo.getLsum())) {
           sql = "UPDATE lesson SET lname = ?, lcate = ?, llevel = ?, lsum = ? WHERE lno = ?";
           return jdbcTemplate.update(sql, vo.getLname(), vo.getLcate(), vo.getLlevel(), vo.getLsum(), vo.getLno());
       } else {
           sql = "UPDATE lesson SET lname = ?, lcate = ?, llevel = ? WHERE lno = ?";
           return jdbcTemplate.update(sql, vo.getLname(), vo.getLcate(), vo.getLlevel(), vo.getLno());
       }
   }

   public int getLessonCountByTno(int tno, String keyword) {
       List<Object> args = new ArrayList<>();
       String sql = "SELECT COUNT(*) FROM lesson WHERE tno = ?";
       args.add(tno);
       if (StringUtils.hasText(keyword)) {
           sql += " AND lname LIKE ?";
           args.add("%" + keyword + "%");
       }
       return jdbcTemplate.queryForObject(sql, Integer.class, args.toArray());
   }

   public List<LessonVo> getLessonListByTno(int tno, String keyword, int startRecord, int recordSize) {
       List<Object> args = new ArrayList<>();
       String sql = "SELECT * FROM lesson WHERE tno = ?";
       args.add(tno);
       if (StringUtils.hasText(keyword)) {
           sql += " AND lname LIKE ?";
           args.add("%" + keyword + "%");
       }
       sql += " ORDER BY lno DESC LIMIT ?, ?";
       args.add(startRecord);
       args.add(recordSize);
       return jdbcTemplate.query(sql, rowMapper, args.toArray());
   }
   
   public LessonVo getLessonByLno(int lno) {
       String sql = "SELECT * FROM lesson WHERE lno = ?";
       try {
           return jdbcTemplate.queryForObject(sql, rowMapper, lno);
       } catch (EmptyResultDataAccessException e) {
           return null;
       }
   }
   
   public int insertLesson(LessonVo vo) {
       String sql = "INSERT INTO lesson(tno, lsum, lname, lcate, llevel, ldate, lweek, lhit) " +
                    "VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
       KeyHolder keyHolder = new GeneratedKeyHolder();
       jdbcTemplate.update(new PreparedStatementCreator() {
           @Override
           public PreparedStatement createPreparedStatement(Connection con) throws SQLException {
               PreparedStatement pstmt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
               pstmt.setInt(1, vo.getTno());
               pstmt.setString(2, vo.getLsum());
               pstmt.setString(3, vo.getLname());
               pstmt.setString(4, vo.getLcate());
               pstmt.setString(5, vo.getLlevel());
               pstmt.setString(6, vo.getLdate());
               pstmt.setInt(7, vo.getLweek());
               pstmt.setInt(8, vo.getLhit());
               return pstmt;
           }
       }, keyHolder);
       return keyHolder.getKey().intValue();
   }
   
   public List<LessonVo> findLessonsByUno(int uno) {
		String sql = "SELECT l.*, t.tname " +
					 "FROM lesson l " +
					 "JOIN bridge b ON l.lno = b.lno " +
					 "JOIN teacher t ON l.tno = t.tno " +
					 "WHERE b.uno = ? " +
					 "ORDER BY l.lno DESC";
		
		return jdbcTemplate.query(sql, rowMapper, uno);
	}
   
   // 회원 수강 강의만 조회
   public List<LessonVo> getUserLessonList(int uno, int start, int size) {
       String sql = "SELECT l.lno, l.lname, l.lcate, l.llevel, l.lsum, " +
                    "l.ldate, l.lweek, l.lhit, t.tname " +
                    "FROM lesson l " +
                    "JOIN bridge b ON l.lno = b.lno " +
                    "JOIN teacher t ON l.tno = t.tno " +
                    "WHERE b.uno = ? " +
                    "ORDER BY l.ldate DESC " +
                    "LIMIT ?, ?";

       RowMapper<LessonVo> rowMapper =
           BeanPropertyRowMapper.newInstance(LessonVo.class);

       return jdbcTemplate.query(sql, rowMapper, uno, start, size);
   }
   
   // 내학습실의 페이지네이션 기능
   public int getUserLessonCount(int uno) {
      String sql = "SELECT COUNT(*) FROM bridge WHERE uno = ?";
      return jdbcTemplate.queryForObject(sql, Integer.class, uno);
   }
   
   // 총 주차 수
   public int getTotalWeeks(int lno) {
      String sql = "SELECT COUNT(*) FROM weeks WHERE lno = ?";
      return jdbcTemplate.queryForObject(sql, Integer.class, lno);
   }

   // 주차 완료 수
   public int getCompletedWeeks(int uno, int lno) {
      String sql = "SELECT COUNT(*) FROM jindo WHERE uno = ? AND lno = ? AND jchk = 1";
      return jdbcTemplate.queryForObject(sql, Integer.class, uno, lno);
   }
   
   
   
//   티처 조인
   public LessonVo getLessonWithTeacher(int lno) {
       String sql = "SELECT l.lno, l.lname, l.lcate, l.llevel, l.lsum, "
                  + "l.ldate, l.lweek, l.lhit, t.tname "
                  + "FROM lesson l "
                  + "JOIN teacher t ON l.tno = t.tno "
                  + "WHERE l.lno = ?";
       return jdbcTemplate.queryForObject(sql, new BeanPropertyRowMapper<>(LessonVo.class), lno);
   }
   //주차 하지 말라고.
   

}

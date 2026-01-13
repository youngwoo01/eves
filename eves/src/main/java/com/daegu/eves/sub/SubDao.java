package com.daegu.eves.sub;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Date;
import java.time.LocalDate;

@Repository
public class SubDao {

    private final JdbcTemplate jdbc;

    public SubDao(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /** 현재 users.send를 잠금 조회 (SELECT ... FOR UPDATE). 트랜잭션 내부에서 호출해야 함 */
    public LocalDate getUserSendForUpdate(Long uno) {
        return jdbc.query(con -> {
            final String sql = "SELECT send FROM users WHERE uno=? FOR UPDATE";
            final java.sql.PreparedStatement ps = con.prepareStatement(sql);
            ps.setLong(1, uno);
            return ps;
        }, rs -> {
            if (rs.next()) {
                Date d = rs.getDate(1);
                return (d != null) ? d.toLocalDate() : null;
            }
            return null;
        });
    }

    /** 구독 로그 적재 (DATE 컬럼 가정: sstart, send) */
    public int insertSub(SubVo v) {
        String sql = "INSERT INTO sub (uno, sstart, send, sprice, uway) VALUES (?,?,?,?,?)";
        return jdbc.update(sql,
                v.getUno(),
                java.sql.Date.valueOf(v.getSstart()),
                java.sql.Date.valueOf(v.getSend()),
                v.getSprice(),
                v.getUway()
        );
    }

    /** users.uchk(0/1), users.send 갱신 */
    public int updateUserSubInfo(Long uno, int uchk, String send) {
        String sql = "UPDATE users SET uchk=?, send=? WHERE uno=?";
        return jdbc.update(sql, uchk, Date.valueOf(send), uno);
    }
}

//package com.daegu.eves.sub;
//
//import java.sql.Connection;
//import java.sql.Date;
//import java.sql.PreparedStatement;
//import java.sql.Statement;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.jdbc.core.JdbcTemplate;
//import org.springframework.jdbc.support.GeneratedKeyHolder;
//import org.springframework.jdbc.support.KeyHolder;
//import org.springframework.stereotype.Repository;
//
//@Repository
//
//public class SubDao {
//	 private final JdbcTemplate jdbc;
//
//	    public SubDao(JdbcTemplate jdbc) {
//	        this.jdbc = jdbc;
//	    }
//	    // 구독 저장
//	    public int insertSub(SubVo v){
//	        String sql = "INSERT INTO sub (uno, sstart, send, sprice, uway) VALUES (?,?,?,?,?)";
//	        return jdbc.update(sql,
//	                v.getUno(),
//	                Date.valueOf(v.getSstart()),  // "yyyy-MM-dd" 형식 문자열 → DATE
//	                Date.valueOf(v.getSend()),
//	                v.getSprice(),
//	                v.getUway());
//	    }
//
//	    	//user 업뎃
//	       public int updateUserSubInfo(Long uno, int uchk, String send) {
//	           String sql = "UPDATE users SET uchk=?, send=? WHERE uno=?";
//	           return jdbc.update(sql, uchk, send, uno);
//	       }
//
//}

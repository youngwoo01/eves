//package com.daegu.eves.user;
//
//
//import java.util.List;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.dao.EmptyResultDataAccessException;
//import org.springframework.jdbc.core.BeanPropertyRowMapper;
//import org.springframework.jdbc.core.JdbcTemplate;
//import org.springframework.jdbc.core.RowMapper;
//import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
//import org.springframework.stereotype.Repository;
//
////★★★★★DAO(+teacherDAO 추가하기)
//@Repository
//public class UserDao {
//
//  @Autowired
//  JdbcTemplate jdbcTemplate;
//  @Autowired
//  private BCryptPasswordEncoder bCryptPasswordEncoder;
//  
//  // 로그인 기능
//  public UserVo login(UserVo vo) {
//	  String sql = "select * from users where uid = ?";
//
//      try {
//    	  RowMapper<UserVo> rowMapper = BeanPropertyRowMapper.newInstance(UserVo.class);
//    	  // id로만 조회
//          UserVo user = jdbcTemplate.queryForObject(sql, rowMapper, vo.getUid());
//          
//          // 암호화된 비밀번호 조회
//          if(!bCryptPasswordEncoder.matches(vo.getUpw(), user.getUpw())) {
//        	  return null; // 로그인 실패
//          }else {
//        	  return user; // 로그인 성공
//          }
//          
//      } catch (EmptyResultDataAccessException e) {
//          return null; // 아이디 없음
//      }
//  }
//  
//  
//  
//  
//  // 회원가입 기능
//  public int insert(UserVo vo) {
//      String insertSql = "INSERT INTO users (uid, upw, uemail, uname, uchk, send) " +
//                         "VALUES (?, ?, ?, ?, ?, ?)";
//
//      return jdbcTemplate.update(insertSql,
//              vo.getUid(),
//              vo.getUpw(),
//              vo.getUemail(),
//              vo.getUname(),
//              vo.getUchk(),    // 보통 0 (기본값)
//              vo.getSend()     // 보통 null
//      );
//  }
//  // 아이디 중복체크
//  public boolean existUid(String uid) {
//      String sql = "SELECT COUNT(*) FROM users WHERE uid = ?";
//      int result = jdbcTemplate.queryForObject(sql, Integer.class, uid);
//      return result > 0;
//  }
//  
//  //회원 정보
//  public UserVo userInfo(String uid) {
//     String sql="select * from users where uid=?";
//     RowMapper<UserVo> rowMapper=
//           BeanPropertyRowMapper.newInstance(UserVo.class);
//     UserVo result=jdbcTemplate.queryForObject(sql,rowMapper,uid);
//
//     return result;
//  }
//  
////  회원정보수정
//  public void infoEdit(UserVo userVo) {
//       String sql = "UPDATE users SET uname=?, uemail=? WHERE uid=?";
//       jdbcTemplate.update(sql, userVo.getUname(), userVo.getUemail(), userVo.getUid());
//
//   }
//  // 회원탈퇴
//  public int delete(String uid) {
//     String sql="delete from users where uid=?";
//     int result=jdbcTemplate.update(sql, uid);
//     return result;
//  }
//  
//  //admin의 회원정보 불러오기 
//  public List<UserVo> getUserList(){
//    
//      String sql = "select * from users"; 
//      RowMapper<UserVo> rowMapper = 
//              BeanPropertyRowMapper.newInstance(UserVo.class);
//        List<UserVo> reuslt = jdbcTemplate.query(sql, rowMapper);
//        return reuslt;
//      
//  }
//
//  
//}
package com.daegu.eves.user;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Repository;

@Repository
public class UserDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private BCryptPasswordEncoder bCryptPasswordEncoder;

    // ------------------------------
    // 1) 로그인 (비번 확인 -> 만료 처리 -> 객체 동기화)
    // ------------------------------
    public UserVo login(UserVo vo) {
        String sql = "select * from users where uid = ?";

        try {
            RowMapper<UserVo> rowMapper = BeanPropertyRowMapper.newInstance(UserVo.class);
            UserVo user = jdbcTemplate.queryForObject(sql, rowMapper, vo.getUid());

            // 비밀번호 검증
            if (!bCryptPasswordEncoder.matches(vo.getUpw(), user.getUpw())) {
                return null; // 로그인 실패
            }

            // 로그인 성공 → 만료 여부 즉시 반영 (send < NOW() 이면 uchk=0)
            int changed = expireIfNeededByUid(user.getUid());
            if (changed > 0) {
                // DB는 이미 uchk=0으로 갱신됨. 세션에 들어갈 user 객체도 맞춰주기
                user.setUchk(0);
            }

            return user;
        } catch (EmptyResultDataAccessException e) {
            return null; // 아이디 없음
        }
    }

    // ------------------------------
    // 2) 만료 처리: send가 지났으면 uchk=0
    //    (DATE/DATETIME 모두 NOW() 비교로 안전)
    // ------------------------------
    public int expireIfNeededByUid(String uid) {
        String sql = "UPDATE users SET uchk = 0 "
                   + "WHERE uid = ? "
                   + "AND send IS NOT NULL "
                   + "AND send < NOW()";
        return jdbcTemplate.update(sql, uid);
    }

    // ------------------------------
    // 3) 회원가입
    // ------------------------------
    public int insert(UserVo vo) {
        String insertSql = "INSERT INTO users (uid, upw, uemail, uname, uchk, send) "
                         + "VALUES (?, ?, ?, ?, ?, ?)";
        return jdbcTemplate.update(insertSql,
                vo.getUid(),
                vo.getUpw(),
                vo.getUemail(),
                vo.getUname(),
                vo.getUchk(),   // 보통 0
                vo.getSend()    // 보통 null
        );
    }

    // ------------------------------
    // 4) 아이디 중복 체크
    // ------------------------------
    public boolean existUid(String uid) {
        String sql = "SELECT COUNT(*) FROM users WHERE uid = ?";
        Integer result = jdbcTemplate.queryForObject(sql, Integer.class, uid);
        return result != null && result > 0;
    }

    // ------------------------------
    // 5) 회원 정보 조회
    // ------------------------------
    public UserVo userInfo(String uid) {
        String sql = "select * from users where uid = ?";
        RowMapper<UserVo> rowMapper = BeanPropertyRowMapper.newInstance(UserVo.class);
        return jdbcTemplate.queryForObject(sql, rowMapper, uid);
    }

    // ------------------------------
    // 6) 회원 정보 수정
    // ------------------------------
    public void infoEdit(UserVo userVo) {
        String sql = "UPDATE users SET uname = ?, uemail = ? WHERE uid = ?";
        jdbcTemplate.update(sql, userVo.getUname(), userVo.getUemail(), userVo.getUid());
    }

    // ------------------------------
    // 7) 회원 탈퇴
    // ------------------------------
    public int delete(String uid) {
        String sql =
            "DELETE u, s, q " +
            "FROM users u " +
            "LEFT JOIN sub s ON s.uno = u.uno " +
            "LEFT JOIN quiz_result q ON q.uno = u.uno " +
            "WHERE u.uid = ?";
        return jdbcTemplate.update(sql, uid);
    }
    // ------------------------------
    // 8) 관리자용 회원 리스트
    // ------------------------------
    public List<UserVo> getUserList() {
        String sql = "select * from users";
        RowMapper<UserVo> rowMapper = BeanPropertyRowMapper.newInstance(UserVo.class);
        return jdbcTemplate.query(sql, rowMapper);
    }
//  //admin의 회원정보 불러오기 
//  public List<UserVo> getUserList(){
//    
//      String sql = "select * from users"; 
//      RowMapper<UserVo> rowMapper = 
//              BeanPropertyRowMapper.newInstance(UserVo.class);
//        List<UserVo> reuslt = jdbcTemplate.query(sql, rowMapper);
//        return reuslt;
//      
//  }
}

// com.daegu.eves.week.WeekDao.java
package com.daegu.eves.week;

import lombok.RequiredArgsConstructor;

import org.springframework.util.StringUtils;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Statement;
import java.util.List;

@Repository
@RequiredArgsConstructor
public class WeekDao {
    private final JdbcTemplate jdbc;
    private RowMapper<WeekVo> rowMapper = BeanPropertyRowMapper.newInstance(WeekVo.class);
    // INSERT + 생성된 wno 반환 (RETURN_GENERATED_KEYS 사용)
    public int insertAndReturnKey(WeekVo vo) {
        final String sql = "INSERT INTO weeks (lno, wname, wuvideo, wdvideo) VALUES (?, ?, ?, ?)";
        KeyHolder kh = new GeneratedKeyHolder();

        jdbc.update(con -> {
            var ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, vo.getLno());
            ps.setString(2, vo.getWname());
            ps.setString(3, vo.getWuvideo()); // "" 가능(컬럼이 NOT NULL이면 빈 문자열로)
            ps.setString(4, vo.getWdvideo()); // 원본 파일명(절대 NULL 금지)
            return ps;
        }, kh);

        // 방어: 키가 없으면 예외
        Number key = kh.getKey();
        if (key == null) {
            throw new IllegalStateException("weeks INSERT 후 생성 키(wno)를 받지 못했습니다.");
        }
        return key.intValue();
    }

    // wdvideo = 원본 파일명 갱신
    public int updateOriginalName(int wno, String originalName) {
        final String sql = "UPDATE weeks SET wdvideo=? WHERE wno=?";
        return jdbc.update(sql, originalName, wno);
    }

    // wuvideo = 재생 경로(m3u8) 갱신
    public int updatePlayUrl(int wno, String playUrl) {
        final String sql = "UPDATE weeks SET wuvideo=? WHERE wno=?";
        return jdbc.update(sql, playUrl, wno);
    }
    
    //주차하지마세요 제발.
    // 특정 강의의 주차 목록 가져오기
    public List<WeekVo> getWeeksByLesson(int lno) {
        String sql = "SELECT * FROM weeks WHERE lno = ? ORDER BY wno ASC";
        return jdbc.query(sql, new BeanPropertyRowMapper<>(WeekVo.class), lno);
    }
    //주차 하지말라고
/////////////////////////////////////////////////////////////////////////////////////////// 
    public WeekVo selectWeekByWno(int wno) {
        String sql = "SELECT * FROM weeks WHERE wno = ?";
        try {
            return jdbc.queryForObject(sql, rowMapper, wno);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }
    public List<WeekVo> findByLno(int lno) {
        String sql = "SELECT wno, lno, wname, wuvideo, wdvideo " +
                     "FROM weeks " +
                     "WHERE lno = ? " +
                     "ORDER BY wno ASC";
        return jdbc.query(sql, rowMapper, lno);
    } 
   

//정우 파트    
///////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    public List<WeekVo> selectWeeksByLno(int lno) {
        String sql = "SELECT * FROM weeks WHERE lno = ? ORDER BY wno ASC";
        return jdbc.query(sql, rowMapper, lno);
    }

    public int insertWeek(WeekVo vo) {
        String sql = "INSERT INTO weeks (lno, wname, wuvideo, wdvideo) VALUES (?, ?, ?, ?)";
        return jdbc.update(sql, vo.getLno(), vo.getWname(), vo.getWuvideo(), vo.getWdvideo());
    }
    
    public int updateWeek(WeekVo vo) {
        String sql;
        if (StringUtils.hasText(vo.getWuvideo())) {
            sql = "UPDATE weeks SET wname = ?, wuvideo = ?, wdvideo = ? WHERE wno = ?";
            return jdbc.update(sql, vo.getWname(), vo.getWuvideo(), vo.getWdvideo(), vo.getWno());
        } else {
            sql = "UPDATE weeks SET wname = ? WHERE wno = ?";
            return jdbc.update(sql, vo.getWname(), vo.getWno());
        }
    }

    // 주차 삭제했을때
    @Transactional
    public int deleteWeek(int wno) {
        // 1. 주차에 연결된 PDF 삭제
        String sqlPdf = "DELETE FROM pdf WHERE wno = ?";
        jdbc.update(sqlPdf, wno);

        // 2. 마지막으로 주차 삭제
        String sqlWeek = "DELETE FROM weeks WHERE wno = ?";
        return jdbc.update(sqlWeek, wno);
    }

    // (권장) 의미 혼동 방지를 위해 제거하거나 정확히 바꾸세요.
    // public int updateVideoUrls(int wno, String playUrl, String thumbUrl) { ... }  // ❌ 혼란의 원인
}

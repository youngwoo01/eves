package com.daegu.eves.quiz;

import lombok.RequiredArgsConstructor;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Repository
@RequiredArgsConstructor
public class QuizDao {

    private final JdbcTemplate jdbc;
    private final RowMapper<QuizVo> quizMapper = BeanPropertyRowMapper.newInstance(QuizVo.class);

    /* =========================
     * 기본 조회
     * ========================= */
    public QuizVo findById(int qid) {
        // ✅ ktext 포함 (번역 채점 시 no_ref 방지)
        String sql = "SELECT qid, lno, wno, qtext, ktext FROM quiz WHERE qid = ?";
        List<QuizVo> list = jdbc.query(sql, quizMapper, qid);
        return list.isEmpty() ? null : list.get(0);
    }
 // ===== 번역퀴즈 일자별 통계 (analysis 존재 기준) =====
    public List<Map<String, Object>> findTranslationDailyStats(int uno, LocalDate start, LocalDate end) {
        String sql =
            "SELECT DATE(created_at) AS d, " +
            "       SUM(CASE WHEN correct = 1 THEN 1 ELSE 0 END) AS correct_count, " +
            "       ROUND(AVG(NULLIF(score,0))) AS avg_score, " +
            "       COUNT(*) AS attempts " +
            "FROM quiz_result " +
            "WHERE uno = ? " +
            "  AND analysis IS NOT NULL AND analysis <> '' " +  // ✅ 번역퀴즈 구분 조건
            "  AND created_at >= ? " +
            "  AND created_at < DATE_ADD(?, INTERVAL 1 DAY) " +
            "GROUP BY DATE(created_at) " +
            "ORDER BY DATE(created_at)";

        return jdbc.query(sql, (rs, rowNum) -> {
            Map<String, Object> m = new HashMap<>();
            m.put("date", rs.getDate("d").toLocalDate());
            m.put("correct_count", rs.getInt("correct_count"));
            Object avg = rs.getObject("avg_score");
            m.put("avg_score", (avg == null ? null : ((Number) avg).intValue()));
            m.put("attempts", rs.getInt("attempts"));
            return m;
        }, uno, start, end);
    }


    /* =========================
     * 진행률/통계
     * ========================= */
 // ===== 일반(말하기) 퀴즈 일자별 통계 (said 존재 기준) =====
    public List<DailyQuizStat> findDailyStats(int uno, LocalDate start, LocalDate end) {
        String sql =
            "SELECT DATE(created_at) AS d, " +
            "       SUM(CASE WHEN correct = 1 THEN 1 ELSE 0 END) AS correct_count, " +
            "       ROUND(AVG(NULLIF(score,0))) AS avg_score, " +
            "       COUNT(*) AS attempts " +
            "FROM quiz_result " +
            "WHERE uno = ? " +
            "  AND said IS NOT NULL AND said <> '' " + // ✅ 말하기퀴즈 구분 조건
            "  AND created_at >= ? " +
            "  AND created_at < DATE_ADD(?, INTERVAL 1 DAY) " +
            "GROUP BY DATE(created_at) " +
            "ORDER BY DATE(created_at)";

        return jdbc.query(sql, (rs, rowNum) -> {
            DailyQuizStat m = new DailyQuizStat();
            m.setDate(rs.getDate("d").toLocalDate());
            m.setCorrectCount(rs.getInt("correct_count"));
            m.setAvgScore(rs.getObject("avg_score") == null ? null : rs.getInt("avg_score"));
            m.setAttempts(rs.getInt("attempts"));
            return m;
        }, uno, start, end);
    }


    /** quiz_result 전체 기준으로 일자/유저 집계를 quiz_stat_daily에 upsert */
    public int rebuildAllDailyStats() {
        String sql =
            "INSERT INTO quiz_stat_daily (uno, stat_date, avg_score, qcnt) \n" +
            "SELECT uno, DATE(created_at) AS stat_date, ROUND(AVG(score)) AS avg_score, COUNT(*) AS qcnt \n" +
            "FROM quiz_result \n" +
            "GROUP BY uno, DATE(created_at) \n" +
            "ON DUPLICATE KEY UPDATE avg_score = VALUES(avg_score), qcnt = VALUES(qcnt)";
        return jdbc.update(sql);
    }

    /* =========================
     * 랜덤 출제
     * ========================= */
    // 특정 lno에서 랜덤 1개
    public QuizVo findRandomOneByLno(int lno) {
        // ✅ ktext 포함 (향후 힌트/검증 대비)
        String sql = "SELECT qid, lno, wno, qtext, ktext FROM quiz WHERE lno=? ORDER BY RAND() LIMIT 1";
        List<QuizVo> res = jdbc.query(sql, quizMapper, lno);
        return res.isEmpty() ? null : res.get(0);
    }

    // 특정 wno에서 랜덤 1개
    public QuizVo findRandomOneByWno(int wno) {
        // ✅ ktext 포함
        String sql = "SELECT qid, lno, wno, qtext, ktext FROM quiz WHERE wno=? ORDER BY RAND() LIMIT 1";
        List<QuizVo> res = jdbc.query(sql, quizMapper, wno);
        return res.isEmpty() ? null : res.get(0);
    }

    // 이미 낸 문제들 제외하고 랜덤 (lno 필수, wno 옵션)
    public QuizVo findRandomExcluding(List<Integer> excludeQids, int lno, Integer wno) {
        StringBuilder sql = new StringBuilder(
            // ✅ ktext 포함
            "SELECT qid, lno, wno, qtext, ktext FROM quiz WHERE lno = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(lno);

        if (wno != null) {
            sql.append("AND wno = ? ");
            params.add(wno);
        }

        if (excludeQids != null && !excludeQids.isEmpty()) {
            String inClause = excludeQids.stream().map(id -> "?").collect(Collectors.joining(","));
            sql.append("AND qid NOT IN (" + inClause + ") ");
            params.addAll(excludeQids);
        }

        sql.append("ORDER BY RAND() LIMIT 1");

        List<QuizVo> list = jdbc.query(sql.toString(), quizMapper, params.toArray());
        return list.isEmpty() ? null : list.get(0);
    }

    // 전체에서 랜덤 1개
    public QuizVo findRandomOneGlobal() {
        // ✅ ktext 포함 (번역 세션에서 안전)
        String sql = "SELECT qid, lno, wno, qtext, ktext FROM quiz ORDER BY RAND() LIMIT 1";
        List<QuizVo> res = jdbc.query(sql, quizMapper);
        return res.isEmpty() ? null : res.get(0);
    }

    /* =========================
     * 결과 저장
     * ========================= */
    // 발화(말하기) 퀴즈용: said 사용
    public int insertResult(int qid, int uno, String said, boolean correct, int score) {
        String sql = "INSERT INTO quiz_result(qid, uno, said, correct, score) VALUES (?,?,?,?,?)";
        // boolean → 1/0 명시 변환(드라이버에 따라 안전)
        return jdbc.update(sql, qid, uno, said, (correct ? 1 : 0), score);
    }

    // 번역 퀴즈용: analysis 사용
    public int insertTranslationResult(int qid, int uno, String analysis, boolean correct, int score) {
        String sql = "INSERT INTO quiz_result (qid, uno, analysis, correct, score) VALUES (?, ?, ?, ?, ?)";
        return jdbc.update(sql, qid, uno, analysis, (correct ? 1 : 0), score);
    }

    /* =========================
     * ★ 관리자: 퀴즈 CRUD + 리스트 필터
     * ========================= */
    /** lno/wno 선택 필터 목록 (둘 다 null이면 전체) */
    public List<QuizVo> findByLessonWeek(Integer lno, Integer wno) {
        StringBuilder sb = new StringBuilder("SELECT qid, lno, wno, qtext, ktext FROM quiz WHERE 1=1");
        List<Object> args = new ArrayList<>();
        if (lno != null) { sb.append(" AND lno = ?"); args.add(lno); }
        if (wno != null) { sb.append(" AND wno = ?"); args.add(wno); }
        sb.append(" ORDER BY qid DESC");
        return jdbc.query(sb.toString(), quizMapper, args.toArray());
    }

    /** 등록 */
    public int insertQuiz(QuizVo vo) {
        // 스키마가 qtext/ktext 둘 다 있는 경우엔 ktext도 함께 넣는 메서드를 따로 두는 게 좋지만,
        // 여기선 기존 흐름 유지: qtext만 입력
        String sql = "INSERT INTO quiz (lno, wno, qtext,ktext) VALUES (?, ?, ?, ?)";
        return jdbc.update(sql, vo.getLno(), vo.getWno(),vo.getQtext(),vo.getKtext());
    }

    /** 수정 */
    public int updateQuiz(QuizVo vo) {
        String sql = "UPDATE quiz SET lno=?, wno=?, qtext=?, ktext=? WHERE qid=?";
        return jdbc.update(sql, vo.getLno(), vo.getWno(), vo.getQtext(), vo.getKtext(), vo.getQid());
    }

    /** 삭제 */
    public int deleteQuiz(int qid) {
        String sql = "DELETE FROM quiz WHERE qid=?";
        return jdbc.update(sql, qid);
    }
}

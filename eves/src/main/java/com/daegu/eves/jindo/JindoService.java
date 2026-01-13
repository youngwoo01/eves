// src/main/java/com/daegu/eves/jindo/JindoService.java
package com.daegu.eves.jindo;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class JindoService {

    private final JdbcTemplate jdbc;

    public JindoService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * 진도 완료 표시 (멱등 업서트)
     * @return 1 = 새로 insert, 2 = 값 변경(update), 0 = 이미 최신이라 변화 없음
     */
    public int markComplete(int uno, int lno, int wno) {
        // jchk를 1로 만들되, 이미 1이면 변화 없음
        // MySQL/MariaDB: INSERT=1행, UPDATE=2행(실제 변경 시), 변화없음=0(드라이버 설정에 따라 2가 나올 수도 있으나 대개 0/2 구분됨)
        final String sql =
                "INSERT INTO jindo (uno, lno, wno, jchk) VALUES (?, ?, ?, 1) " +
                "ON DUPLICATE KEY UPDATE jchk = IF(jchk = 0, VALUES(jchk), jchk)";

        return jdbc.update(sql, uno, lno, wno);
    }
}

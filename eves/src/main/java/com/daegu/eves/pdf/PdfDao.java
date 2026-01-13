package com.daegu.eves.pdf;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class PdfDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    private RowMapper<PdfVo> rowMapper = BeanPropertyRowMapper.newInstance(PdfVo.class);

    public int insertPdf(PdfVo vo) {
        String sql = "INSERT INTO pdf (lno, wno, pupdf, pdpdf, pdate) VALUES (?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql, vo.getLno(), vo.getWno(), vo.getPupdf(), vo.getPdpdf(), vo.getPdate());
    }
    
    public List<PdfVo> selectPdfListByLno(int lno) {
        String sql = "SELECT * FROM pdf WHERE lno = ? AND wno = 0";
        
        return jdbcTemplate.query(sql, rowMapper, lno); 
    }
    
    // PDF 삭제
    public int deletePdfByPno(int pno) {
        String sql = "DELETE FROM pdf WHERE pno = ?";
        return jdbcTemplate.update(sql, pno);
    }
    
    // pno로 PDF 정보 조회 (파일 삭제용)
    public PdfVo selectPdfByPno(int pno) {
        String sql = "SELECT * FROM pdf WHERE pno = ?";
        try {
            return jdbcTemplate.queryForObject(sql, rowMapper, pno);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

//    public int upsertPdf(PdfVo vo) {
//        String countSql = "SELECT COUNT(*) FROM pdf WHERE lno = ? AND wno = 0";
//        int count = jdbcTemplate.queryForObject(countSql, Integer.class, vo.getLno());
//
//        if (count > 0) {
//            String updateSql = "UPDATE pdf SET pupdf = ?, pdpdf = ?, pdate = ? WHERE lno = ? AND wno = 0";
//            return jdbcTemplate.update(updateSql, vo.getPupdf(), vo.getPdpdf(), vo.getPdate(), vo.getLno());
//        } else {
//            return insertPdf(vo);
//        }
//    }
}


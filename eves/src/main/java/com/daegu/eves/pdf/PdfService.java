package com.daegu.eves.pdf;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PdfService {

    @Autowired
    private PdfDao pdfDao;

    public int insertPdf(PdfVo vo) {
        return pdfDao.insertPdf(vo);
    }
    
    public List<PdfVo> getPdfListByLno(int lno) {
        return pdfDao.selectPdfListByLno(lno);
    }
    
    // PDF 개별 삭제
    public int deletePdfByPno(int pno) {
        return pdfDao.deletePdfByPno(pno);
    }
    
    // pno로 PDF 정보 조회 (파일 삭제용)
    public PdfVo getPdfByPno(int pno) {
        return pdfDao.selectPdfByPno(pno);
    }

//    public int upsertPdf(PdfVo vo) {
//        return pdfDao.upsertPdf(vo);
//    }
}


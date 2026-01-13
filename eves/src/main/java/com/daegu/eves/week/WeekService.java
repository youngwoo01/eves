package com.daegu.eves.week;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class WeekService {

    @Autowired
    private WeekDao weekDao;
    
    private final String FILE_BASE_PATH = "C:\\fullstack\\workspace";
    // HLS 변환 파일 저장 경로
    @Value("${video.storage.hls-dir:C:/video/hls}")
    private String hlsRoot;

    // 강의 번호로 주차 목록 반환
    public List<WeekVo> getWeeksByLesson(int lno) {
        return weekDao.getWeeksByLesson(lno);
    }
 
    
///////////////////////////////////////////////////////////////
// 정우가 할거
    
    public WeekVo getWeekByWno(int wno) {
        return weekDao.selectWeekByWno(wno);
        
    }
///////////////////////////////////////////////////////////////

    public List<WeekVo> getWeeksListByLno(int lno) {
        return weekDao.selectWeeksByLno(lno);
    }

    public int insertWeek(WeekVo vo) {
        return weekDao.insertWeek(vo);
    }
    
    public int updateWeek(WeekVo vo) {
        return weekDao.updateWeek(vo);
    }

    public int deleteWeek(int wno) {
        return weekDao.deleteWeek(wno);
    }
    
    // DB + 서버 파일(원본, HLS) 모두 삭제
    public void deleteWeekAndFiles(int wno) throws Exception {
        WeekVo week = weekDao.selectWeekByWno(wno); 
        
        if (week != null) {
            deleteFile(week.getWuvideo(), FILE_BASE_PATH + "\\videoUpload");
        }
        
        Path hlsDirectory = Paths.get(hlsRoot, String.valueOf(wno));
        deleteDirectory(hlsDirectory);
        
        weekDao.deleteWeek(wno); //
    }

    private void deleteFile(String fileName, String path) {
        if (fileName == null || fileName.isEmpty()) return;
        File file = new File(path, fileName);
        if (file.exists()) {
            if (file.delete()) {
                System.out.println("파일 삭제 성공: " + fileName);
            } else {
                System.out.println("파일 삭제 실패: " + fileName);
            }
        } else {
            System.out.println("삭제할 파일이 존재하지 않음: " + fileName);
        }
    }
    
    //HLS 폴더 삭제
    private void deleteDirectory(Path path) throws Exception {
        if (!Files.exists(path)) {
            System.out.println("삭제할 HLS 디렉토리 없음: " + path);
            return;
        }
        
        Files.walk(path)
            .sorted(Comparator.reverseOrder())
            .map(Path::toFile)
            .forEach(file -> {
                if (file.delete()) {
                    System.out.println("HLS 파일/폴더 삭제: " + file);
                } else {
                    System.err.println("HLS 삭제 실패: " + file);
                }
            });
    }
}


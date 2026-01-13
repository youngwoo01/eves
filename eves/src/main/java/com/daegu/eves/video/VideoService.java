// com.daegu.eves.video.VideoService.java
package com.daegu.eves.video;

import com.daegu.eves.week.WeekDao;
import com.daegu.eves.week.WeekVo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class VideoService {

    private final FfmpegRunner ffmpegRunner;
    private final WeekDao weekDao;

    private final Path uploadTemp = Paths.get(System.getProperty("java.io.tmpdir"), "video-upload");

    private String safeOriginalName(MultipartFile file) {
        String name = (file.getOriginalFilename() == null) ? "" : file.getOriginalFilename();
        // 파일명만 추출
        name = Paths.get(name).getFileName().toString();
        // 완전 빈 문자열이면 UUID로 대체
        if (!StringUtils.hasText(name)) {
            name = "video_" + UUID.randomUUID() + ".mp4";
        }
        return name;
    }

    // [A] 기존 주차(wno)에 업로드하여 연결
    public String uploadAndAttachToWeek(int wno, MultipartFile file) throws Exception {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("업로드 파일이 비었습니다.");
        }
        Files.createDirectories(uploadTemp);

        String originalName = safeOriginalName(file); // wdvideo에 저장할 원본명

        // 1) 원본명 먼저 기록 (wdvideo)
        int changed = weekDao.updateOriginalName(wno, originalName);
        if (changed == 0) throw new IllegalArgumentException("존재하지 않는 wno: " + wno);

        // 2) 원본 임시 저장
        Path src = uploadTemp.resolve(wno + "_" + originalName);
        file.transferTo(src.toFile());

        // 3) HLS 변환 (videoId=wno)
        String videoId = String.valueOf(wno);
        ffmpegRunner.convertToHls(src, videoId);

        // 4) 재생 경로(wuvideo) 갱신
        String playUrl = "/play/" + videoId + "/master.m3u8";
        weekDao.updatePlayUrl(wno, playUrl);

        try { Files.deleteIfExists(src); } catch (Exception ignore) {}
        return videoId;
    }

    // [B] 새 주차 생성 + 업로드(INSERT 흐름)
    public String uploadAndCreateWeek(int lno, String wname, MultipartFile file) throws Exception {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("업로드 파일이 비었습니다.");
        }
        Files.createDirectories(uploadTemp);

        String originalName = safeOriginalName(file); // wdvideo(원본명)

        // 1) 주차 행 먼저 만들기: wuvideo는 아직 모름 → ""(빈값), wdvideo=원본명
        WeekVo vo = new WeekVo();
        vo.setLno(lno);
        vo.setWname(wname);
        vo.setWuvideo("");            // 재생경로는 변환 후 채움 (컬럼이 NOT NULL이면 빈 문자열 허용)
        vo.setWdvideo(originalName);  // 절대 NULL 금지
        int wno = weekDao.insertAndReturnKey(vo);

        // 2) 원본 임시 저장
        Path src = uploadTemp.resolve(wno + "_" + originalName);
        file.transferTo(src.toFile());

        // 3) 변환 (videoId=wno)
        String videoId = String.valueOf(wno);
        ffmpegRunner.convertToHls(src, videoId);

        // 4) 재생 경로(wuvideo) 채우기
        String playUrl = "/play/" + videoId + "/master.m3u8";
        weekDao.updatePlayUrl(wno, playUrl);

        try { Files.deleteIfExists(src); } catch (Exception ignore) {}
        return videoId;
    }
}

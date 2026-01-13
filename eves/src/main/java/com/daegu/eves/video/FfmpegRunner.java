package com.daegu.eves.video;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

@Component
@Slf4j
public class FfmpegRunner {

    @Value("${video.storage.hls-dir:C:/video/hls}")
    private String hlsRoot;

    @Value("${video.ffmpeg.path:}")
    private String ffmpegConfigured;

    @Value("${video.hls.segment-seconds:6}")
    private int segmentSeconds; // 세그먼트 길이(초)

    // 어노테이션 없이 1회 초기화
    private volatile boolean initialized = false;
    private void initOnce() throws Exception {
        if (initialized) return;
        synchronized (this) {
            if (initialized) return;
            Files.createDirectories(Paths.get(hlsRoot));
            log.info("[ffmpeg] HLS root ready: {}", Paths.get(hlsRoot).toAbsolutePath());
            initialized = true;
        }
    }

    /** 외부에서 호출: 원본 파일을 HLS로 변환하고 결과 경로를 반환 */
    public HlsResult convertToHls(Path originalFile, String videoId) throws Exception {
        initOnce();

        // 0) 원본 존재 확인
        if (originalFile == null || !Files.exists(originalFile)) {
            throw new IllegalArgumentException("Original file not found: " + originalFile);
        }

        // 1) ffmpeg 바이너리 결정
        String ffmpegBin = resolveFfmpegBinary();

        // 2) 출력 디렉터리 준비
        Path outDir = Paths.get(hlsRoot, videoId);
        Files.createDirectories(outDir);

        // 3) HLS 변환 실행
        Path master = outDir.resolve("master.m3u8");
        Path segmentPattern = outDir.resolve("seg_%05d.ts"); // seg_00001.ts ...

        List<String> hlsCmd = new ArrayList<>();
        hlsCmd.add(ffmpegBin);
        hlsCmd.add("-y");
        hlsCmd.add("-i"); hlsCmd.add(originalFile.toString());
        hlsCmd.add("-profile:v"); hlsCmd.add("main");
        hlsCmd.add("-level"); hlsCmd.add("3.1");
        hlsCmd.add("-start_number"); hlsCmd.add("0");
        hlsCmd.add("-hls_time"); hlsCmd.add(String.valueOf(Math.max(1, segmentSeconds)));
        hlsCmd.add("-hls_list_size"); hlsCmd.add("0");
        hlsCmd.add("-hls_flags"); hlsCmd.add("independent_segments");
        hlsCmd.add("-hls_segment_filename"); hlsCmd.add(segmentPattern.toString());
        hlsCmd.add("-f"); hlsCmd.add("hls");
        hlsCmd.add(master.toString());

        runAndLog(hlsCmd, outDir.toFile(), "ffmpeg(hls)");

        // 4) 썸네일 추출 (3초 지점, 필요시 시간 변경)
        Path thumb = outDir.resolve("thumb.jpg");
        List<String> thumbCmd = new ArrayList<>();
        thumbCmd.add(ffmpegBin);
        thumbCmd.add("-y");
        thumbCmd.add("-ss"); thumbCmd.add("3");
        thumbCmd.add("-i"); thumbCmd.add(originalFile.toString());
        thumbCmd.add("-frames:v"); thumbCmd.add("1");
        // 필요 시 크기 제한: thumbCmd.add("-vf"); thumbCmd.add("scale=640:-1");
        thumbCmd.add(thumb.toString());

        runAndLog(thumbCmd, outDir.toFile(), "ffmpeg(thumb)");

        // 5) 결과 반환
        HlsResult res = new HlsResult();
        res.setVideoId(videoId);
        res.setHlsDir(outDir.toString());
        res.setMasterPath(master.toString());
        res.setThumbName("thumb.jpg");
        return res;
    }

    /** -------- 내부 유틸 -------- */

    private String resolveFfmpegBinary() throws Exception {
        String os = System.getProperty("os.name", "").toLowerCase(Locale.ROOT);
        boolean isWindows = os.contains("win");

        String cleaned = (ffmpegConfigured == null ? "" : ffmpegConfigured.replace("\"", "").trim());
        log.info("[ffmpeg] configured='{}'", cleaned);

        if (!cleaned.isEmpty()) {
            Path p = Paths.get(cleaned);

            // 디렉터리를 가리킨다면 ffmpeg(.exe) 보정
            if (Files.isDirectory(p)) {
                p = p.resolve(isWindows ? "ffmpeg.exe" : "ffmpeg");
            }

            // 윈도우에서 확장자 누락 시 보정 시도
            if (isWindows && !p.toString().toLowerCase(Locale.ROOT).endsWith(".exe") && Files.exists(p)) {
                Path exeTry = Paths.get(p.toString() + ".exe");
                if (Files.exists(exeTry)) p = exeTry;
            }

            if (existsAndExecutable(p)) {
                log.info("[ffmpeg] using configured path: {}", p.toAbsolutePath());
                return p.toString();
            } else {
                log.warn("[ffmpeg] configured path invalid: {}", p.toAbsolutePath());
            }
        } else {
            log.info("[ffmpeg] no explicit path configured → try PATH/common locations");
        }

        // PATH 탐색
        Optional<Path> fromPath = findInPath(isWindows ? "ffmpeg.exe" : "ffmpeg");
        if (fromPath.isPresent()) {
            log.info("[ffmpeg] found in PATH: {}", fromPath.get());
            return fromPath.get().toString();
        }

        // 흔한 설치 위치 탐색
        List<String> candidates = new ArrayList<>();
        if (isWindows) {
            candidates.add("C:/ffmpeg/bin/ffmpeg.exe");
            candidates.add("C:/Program Files/ffmpeg/bin/ffmpeg.exe");
            candidates.add("C:/Program Files (x86)/ffmpeg/bin/ffmpeg.exe");
        } else {
            candidates.add("/usr/bin/ffmpeg");
            candidates.add("/usr/local/bin/ffmpeg");
            candidates.add("/opt/homebrew/bin/ffmpeg"); // Apple Silicon
        }

        for (String c : candidates) {
            Path p = Paths.get(c);
            if (existsAndExecutable(p)) {
                log.info("[ffmpeg] found in common location: {}", p);
                return p.toString();
            }
        }

        String msg = "ffmpeg not found. Configure 'video.ffmpeg.path' with an absolute path, e.g., "
                + (isWindows ? "C:/ffmpeg/bin/ffmpeg.exe" : "/usr/bin/ffmpeg");
        log.error("[ffmpeg] {}", msg);
        throw new IllegalStateException(msg);
    }

    private boolean existsAndExecutable(Path p) {
        try {
            return Files.exists(p) && Files.isRegularFile(p) &&
                   (Files.isExecutable(p) || isWindowsExe(p));
        } catch (Exception e) {
            return false;
        }
    }

    private boolean isWindowsExe(Path p) {
        String os = System.getProperty("os.name", "").toLowerCase(Locale.ROOT);
        boolean isWindows = os.contains("win");
        return isWindows && p.toString().toLowerCase(Locale.ROOT).endsWith(".exe");
    }

    private Optional<Path> findInPath(String binaryName) throws Exception {
        String path = System.getenv("PATH");
        if (path != null) {
            for (String d : path.split(File.pathSeparator)) {
                try {
                    Path cand = Paths.get(d).resolve(binaryName);
                    if (existsAndExecutable(cand)) {
                        return Optional.of(cand.toAbsolutePath().normalize());
                    }
                } catch (Exception ignored) {}
            }
        }
        // 마지막으로 단순 호출 테스트
        try {
            runAndLog(Arrays.asList(binaryName, "-version"), null, "ffmpeg(check)");
            return Optional.of(Paths.get(binaryName));
        } catch (Exception ignored) {}
        return Optional.empty();
    }

    private void runAndLog(List<String> cmd, File workDir, String tag) throws Exception {
        log.info("[{}] {}", tag, String.join(" ", cmd));
        ProcessBuilder pb = new ProcessBuilder(cmd);
        if (workDir != null) pb.directory(workDir);
        pb.redirectErrorStream(true);
        Process p = pb.start();

        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(p.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                log.info("[{}] {}", tag, line);
            }
        }
        int code = p.waitFor();
        if (code != 0) {
            throw new RuntimeException(tag + " failed with exit " + code);
        }
    }
}

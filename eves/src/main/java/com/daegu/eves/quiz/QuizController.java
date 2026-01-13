package com.daegu.eves.quiz;

import com.daegu.eves.user.UserVo;
import com.google.cloud.speech.v1.RecognitionAudio;
import com.google.cloud.speech.v1.RecognitionConfig;
import com.google.cloud.speech.v1.SpeechClient;
import com.google.cloud.texttospeech.v1.*;
import com.google.protobuf.ByteString;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;
import java.io.*;
import java.nio.file.*;
import java.time.LocalDate;
import java.util.*;

/**
 * 말하기 퀴즈 컨트롤러
 * 한 문제씩 랜덤으로 내고, 총 5문제까지만 진행
 */
@Controller
@RequestMapping("/quiz")
@RequiredArgsConstructor
public class QuizController {

    private final QuizDao quizDao;

    private final String ffmpegPath = "C:/ffmpeg/bin/ffmpeg.exe";
    private final Path workDir = Paths.get("C:/temp/quiz");
    private final double PASS_THRESHOLD = 0.90;

    /** 세션 상태 구조체 */
    private static class SessionState {
        Map<String, Integer> ctx;
        Set<Integer> used;
        int count;
        int limit;
    }

    /** 로그인 사용자 uno 해석 (없으면 null) */
    private Integer resolveUno(HttpSession session) {
        UserVo loginUser = (UserVo) session.getAttribute("loginUser");
        return (loginUser != null) ? loginUser.getUno() : null;
    }

    /** 세션 초기화 및 유틸 */
    @SuppressWarnings("unchecked")
    private SessionState ensureSession(HttpSession session) {
        SessionState st = new SessionState();

        // 기본 context (uno는 로그인 있을 때만 저장/갱신)
        Map<String, Integer> ctx = (Map<String, Integer>) session.getAttribute("quiz_ctx");
        if (ctx == null) {
            ctx = new HashMap<>();
            Integer uno = resolveUno(session);
            if (uno != null) ctx.put("uno", uno);
            session.setAttribute("quiz_ctx", ctx);
        } else {
            Integer unoNow = resolveUno(session);
            if (unoNow != null) ctx.put("uno", unoNow);
        }

        Set<Integer> used = (Set<Integer>) session.getAttribute("quiz_used");
        if (used == null) {
            used = new HashSet<>();
            session.setAttribute("quiz_used", used);
        }

        Integer count = (Integer) session.getAttribute("quiz_count");
        if (count == null) {
            count = 0;
            session.setAttribute("quiz_count", count);
        }

        Integer limit = (Integer) session.getAttribute("quiz_limit");
        if (limit == null) {
            limit = 5; // 총 5문제
            session.setAttribute("quiz_limit", limit);
        }

        st.ctx = ctx;
        st.used = used;
        st.count = count;
        st.limit = limit;
        return st;
    }

    /* ======================================
     * /quiz/start : 첫 문제 보여주는 페이지
     * ====================================== */
    @GetMapping("/start")
    public String start(HttpSession session, Model model) {
        // 세션 초기화
        session.setAttribute("quiz_used", new HashSet<Integer>());
        session.setAttribute("quiz_count", 0);
        session.setAttribute("quiz_limit", 5);

        SessionState st = ensureSession(session);

        // 첫 문제 랜덤 1개
        QuizVo first = quizDao.findRandomOneGlobal();
        if (first != null) {
            st.used.add(first.getQid());
            st.count = 1;
            session.setAttribute("quiz_used", st.used);
            session.setAttribute("quiz_count", st.count);

            model.addAttribute("firstQid", first.getQid());
            model.addAttribute("firstText", first.getQtext());
            model.addAttribute("firstCount", st.count);
            model.addAttribute("limit", st.limit);

            System.out.println("[START] 첫 문제 qid=" + first.getQid());
        } else {
            model.addAttribute("firstQid", 0);
            model.addAttribute("firstText", "(등록된 문제가 없습니다)");
            model.addAttribute("firstCount", 0);
            model.addAttribute("limit", st.limit);
        }

        return "quiz/session_one_by_one";
    }

    /* ======================================
     * 진행 차트
     * ====================================== */
    @GetMapping("/progress")
    public String progress(
            @RequestParam(value="days", required=false) Integer days,
            HttpSession session,
            Model model) {

        Integer uno = resolveUno(session);
        if (uno == null) {
            // 미로그인 처리: 필요에 따라 로그인 페이지로 유도하거나, 빈 그래프를 보여줘도 됨
            // 여기서는 로그인 페이지로
            return "redirect:/Login";
        }

        int range = (days == null || days < 1 || days > 90) ? 14 : days;
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(range - 1);

        // 말하기 퀴즈(스피킹)만 집계: said IS NOT NULL AND said <> ''
        List<DailyQuizStat> rows = quizDao.findDailyStats(uno, start, end);
        Map<LocalDate, DailyQuizStat> byDate = new HashMap<>();
        for (DailyQuizStat r : rows) byDate.put(r.getDate(), r);

        List<String> labels = new ArrayList<>();
        List<Integer> correctCounts = new ArrayList<>();
        List<Integer> avgScores = new ArrayList<>();
        for (LocalDate d = start; !d.isAfter(end); d = d.plusDays(1)) {
            labels.add(d.toString());
            DailyQuizStat r = byDate.get(d);
            correctCounts.add(r == null ? 0 : r.getCorrectCount());
            avgScores.add(r == null || r.getAvgScore() == null ? null : r.getAvgScore());
        }

        model.addAttribute("labels", labels);
        model.addAttribute("correctCounts", correctCounts);
        model.addAttribute("avgScores", avgScores);
        model.addAttribute("rangeDays", range);

        return "quiz/progress";
    }

    /* ======================================
     * /quiz/next : 다음 문제 AJAX 요청
     * ====================================== */
    @GetMapping("/next")
    @ResponseBody
    public Map<String, Object> next(HttpSession session) {
        SessionState st = ensureSession(session);

        if (st.count >= st.limit) {
            return Map.of("ok", false, "finished", true);
        }

        // 사용한 문제 제외하고 랜덤 1개 뽑기
        List<Integer> exclude = new ArrayList<>(st.used);
        QuizVo next = quizDao.findRandomExcluding(exclude, 1, null); // lno=1 임시 (없어도 무관)

        if (next == null) {
            return Map.of("ok", false, "finished", true);
        }

        st.used.add(next.getQid());
        st.count++;
        session.setAttribute("quiz_used", st.used);
        session.setAttribute("quiz_count", st.count);

        System.out.println("[NEXT] qid=" + next.getQid() + " count=" + st.count + "/" + st.limit);

        return Map.of(
                "ok", true,
                "qid", next.getQid(),
                "text", next.getQtext()
        );
    }

    /* ======================================
     * /quiz/ttsByQid : 문제 읽어주기
     * ====================================== */
    @GetMapping("/ttsByQid")
    @ResponseBody
    public ResponseEntity<byte[]> ttsByQid(@RequestParam int qid) {
        QuizVo quiz = quizDao.findById(qid);
        if (quiz == null) {
            return ResponseEntity.status(404).body(null);
        }

        try (TextToSpeechClient tts = GoogleClients.newTtsClient()) {
            SynthesisInput input = SynthesisInput.newBuilder().setText(quiz.getQtext()).build();
            VoiceSelectionParams voice = VoiceSelectionParams.newBuilder()
                    .setLanguageCode("en-US")
                    .setSsmlGender(SsmlVoiceGender.NEUTRAL)
                    .build();
            AudioConfig audioConfig = AudioConfig.newBuilder()
                    .setAudioEncoding(AudioEncoding.MP3)
                    .build();

            SynthesizeSpeechResponse response = tts.synthesizeSpeech(input, voice, audioConfig);
            byte[] mp3 = response.getAudioContent().toByteArray();

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"quiz.mp3\"")
                    .contentType(MediaType.parseMediaType("audio/mpeg"))
                    .body(mp3);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(null);
        }
    }

    /* ======================================
     * /quiz/stt : 음성 인식 + 채점
     * ====================================== */
    @PostMapping("/stt")
    @ResponseBody
    public Map<String, Object> stt(@RequestParam("file") MultipartFile file,
                                   @RequestParam int qid,
                                   HttpSession session) {
        Map<String, Object> out = new HashMap<>();

        ensureSession(session);
        Integer uno = resolveUno(session);
        if (uno == null) {
            // 미로그인 시 채점 불가
            return Map.of("ok", false, "reason", "not_logged_in");
        }

        if (file == null || file.isEmpty()) {
            return Map.of("ok", false, "reason", "file_missing");
        }

        try {
            Files.createDirectories(workDir);
        } catch (IOException e) {
            return Map.of("ok", false, "reason", "dir_failed");
        }

        Path webm = workDir.resolve("temp_" + System.currentTimeMillis() + ".webm");
        Path wav  = workDir.resolve("temp_" + System.currentTimeMillis() + ".wav");

        try {
            FileCopyUtils.copy(file.getBytes(), webm.toFile());
        } catch (IOException e) {
            return Map.of("ok", false, "reason", "save_failed");
        }

        try {
            Process proc = new ProcessBuilder(
                    ffmpegPath, "-y", "-i", webm.toString(),
                    "-ar", "16000", "-ac", "1", wav.toString()
            ).redirectErrorStream(true).start();
            proc.waitFor();
        } catch (Exception e) {
            cleanup(webm, wav);
            return Map.of("ok", false, "reason", "ffmpeg_failed");
        }

        if (!Files.exists(wav)) {
            cleanup(webm, wav);
            return Map.of("ok", false, "reason", "no_wav");
        }

        String said = "";
        try (SpeechClient stt = GoogleClients.newSttClient()) {
            byte[] wavBytes = Files.readAllBytes(wav);
            RecognitionConfig config = RecognitionConfig.newBuilder()
                    .setEncoding(RecognitionConfig.AudioEncoding.LINEAR16)
                    .setSampleRateHertz(16000)
                    .setLanguageCode("en-US")
                    .build();

            RecognitionAudio audio = RecognitionAudio.newBuilder()
                    .setContent(ByteString.copyFrom(wavBytes))
                    .build();

            var res = stt.recognize(config, audio);
            if (res.getResultsCount() > 0)
                said = res.getResults(0).getAlternatives(0).getTranscript();
        } catch (Exception e) {
            cleanup(webm, wav);
            return Map.of("ok", false, "reason", "stt_failed");
        }

        QuizVo quiz = quizDao.findById(qid);
        if (quiz == null) {
            cleanup(webm, wav);
            return Map.of("ok", false, "reason", "quiz_not_found");
        }

        String answer = normalize(quiz.getQtext());
        String user = normalize(said);
        int dist = levenshtein(answer, user);
        double sim = 1.0 - (double) dist / Math.max(answer.length(), user.length());
        int score = (int) Math.round(sim * 100);
        boolean correct = sim >= PASS_THRESHOLD;

        quizDao.insertResult(qid, uno, said, correct, score);
        cleanup(webm, wav);

        out.put("ok", true);
        out.put("qid", qid);
        out.put("said", said);
        out.put("score", score);
        out.put("correct", correct);
        return out;
    }

    private void cleanup(Path... paths) {
        for (Path p : paths) {
            try { Files.deleteIfExists(p); } catch (Exception ignore) {}
        }
    }

    private String normalize(String s) {
        if (s == null) return "";
        return s.replaceAll("\\p{Punct}|\\s+", "").toLowerCase();
    }

    private int levenshtein(String a, String b) {
        int n = a.length(), m = b.length();
        int[][] dp = new int[n + 1][m + 1];
        for (int i = 0; i <= n; i++) dp[i][0] = i;
        for (int j = 0; j <= m; j++) dp[0][j] = j;
        for (int i = 1; i <= n; i++) {
            for (int j = 1; j <= m; j++) {
                int cost = (a.charAt(i - 1) == b.charAt(j - 1)) ? 0 : 1;
                dp[i][j] = Math.min(Math.min(
                        dp[i - 1][j] + 1, dp[i][j - 1] + 1),
                        dp[i - 1][j - 1] + cost);
            }
        }
        return dp[n][m];
    }
}

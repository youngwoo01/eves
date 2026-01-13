package com.daegu.eves.quiz;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.text.Normalizer;
import java.time.LocalDate;
import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/quiz-tr")
@RequiredArgsConstructor
public class QuizTranslateController {
	private Integer resolveUno(HttpSession session) {
	    Object loginUser = session.getAttribute("loginUser");
	    if (loginUser == null) return null;
	    try { return (Integer) loginUser.getClass().getMethod("getUno").invoke(loginUser); }
	    catch (Exception e) { return null; }
	}
    private final QuizDao quizDao;

    // ===== 상태 =====
    static class TRState {
        Map<String,Integer> ctx;
        Set<Integer> used;
        int count;
        int limit;
    }
    @GetMapping("/progress")
    public String progressTranslate(
            @RequestParam(value="days", required=false) Integer days,
            HttpSession session,
            Model model) {

    	Integer uno = resolveUno(session);
    	if (uno == null) {
    	    // 미로그인 처리: 필요에 맞게 선택하세요 (1) 로그인 페이지로 보내기 or (2) 에러 메시지
    	    return "redirect:/Login";
    	    // 또는:
    	    // model.addAttribute("error", "로그인 후 확인 가능합니다.");
    	    // return "quiz/progress_translate";
    	}
        int range = (days == null || days < 1 || days > 90) ? 14 : days;
        LocalDate end = LocalDate.now();
        LocalDate start = end.minusDays(range - 1);

        // ✅ 번역퀴즈 일자별 통계 조회
        List<Map<String, Object>> rows = quizDao.findTranslationDailyStats(uno, start, end);
        Map<LocalDate, Map<String, Object>> byDate = new HashMap<>();
        for (Map<String, Object> r : rows) {
            byDate.put((LocalDate) r.get("date"), r);
        }

        List<String> labels = new ArrayList<>();
        List<Integer> correctCounts = new ArrayList<>();
        List<Integer> avgScores = new ArrayList<>();
        List<Integer> attempts = new ArrayList<>();

        for (LocalDate d = start; !d.isAfter(end); d = d.plusDays(1)) {
            labels.add(d.toString());
            Map<String, Object> r = byDate.get(d);
            correctCounts.add(r == null ? 0 : (Integer) r.get("correct_count"));
            avgScores.add(r == null ? null : (Integer) r.get("avg_score"));
            attempts.add(r == null ? 0 : (Integer) r.get("attempts"));
        }

        model.addAttribute("labels", labels);
        model.addAttribute("correctCounts", correctCounts);
        model.addAttribute("avgScores", avgScores);
        model.addAttribute("attempts", attempts);
        model.addAttribute("rangeDays", range);

        return "quiz/progress_translate";
    }


    @SuppressWarnings("unchecked")
    private TRState ensure(HttpSession session) {
        TRState s = new TRState();

        // 🔹 로그인 유저에서 uno 추출 (없으면 null)
        Integer uno = null;
        Object loginUser = session.getAttribute("loginUser");
        if (loginUser != null) {
            try { uno = (Integer) loginUser.getClass().getMethod("getUno").invoke(loginUser); }
            catch (Exception ignore) {}
        }

        // 🔹 tr_ctx 초기화 또는 갱신
        Map<String, Integer> ctx = (Map<String, Integer>) session.getAttribute("tr_ctx");
        if (ctx == null) {
            ctx = new HashMap<>();
            if (uno != null) ctx.put("uno", uno); // 로그인 상태일 때만 저장
            session.setAttribute("tr_ctx", ctx);
        } else {
            if (uno != null) ctx.put("uno", uno); // 로그인이 새로 바뀐 경우 갱신
        }

        // 🔹 이미 푼 문제 목록
        Set<Integer> used = (Set<Integer>) session.getAttribute("tr_used");
        if (used == null) {
            used = new HashSet<>();
            session.setAttribute("tr_used", used);
        }

        // 🔹 문제 진행 카운트
        Integer cnt = (Integer) session.getAttribute("tr_count");
        if (cnt == null) {
            cnt = 0;
            session.setAttribute("tr_count", cnt);
        }

        // 🔹 전체 제한
        Integer lim = (Integer) session.getAttribute("tr_limit");
        if (lim == null) {
            lim = 5;
            session.setAttribute("tr_limit", lim);
        }

        s.ctx = ctx;
        s.used = used;
        s.count = cnt;
        s.limit = lim;
        return s;
    }

    // ===== 시작 =====
    @GetMapping("/start")
    public String start(HttpSession session, Model model) {
        TRState st = ensure(session);

        QuizVo picked = pickWithRef(st.used, 60);
        if (picked != null) {
            st.used.add(picked.getQid());
            st.count = 1;
            session.setAttribute("tr_used", st.used);
            session.setAttribute("tr_count", st.count);
            model.addAttribute("firstQid", picked.getQid());
            model.addAttribute("firstText", picked.getQtext());
        } else {
            model.addAttribute("firstQid", 0);
            model.addAttribute("firstText", "(채점 기준 문장이 있는 문제가 없습니다)");
        }
        model.addAttribute("firstCount", st.count);
        model.addAttribute("limit", st.limit);
        return "quiz/session_translate";
    }

    // ===== 다음 문제 =====
    @GetMapping("/next")
    @ResponseBody
    public Map<String,Object> next(HttpSession session) {
        TRState st = ensure(session);
        if (st.count >= st.limit)
            return Map.of("ok", false, "finished", true);

        QuizVo picked = pickWithRef(st.used, 80);
        if (picked == null)
            return Map.of("ok", false, "finished", true);

        st.used.add(picked.getQid());
        st.count++;
        session.setAttribute("tr_used", st.used);
        session.setAttribute("tr_count", st.count);

        return Map.of("ok", true,
                "qid", picked.getQid(),
                "text", picked.getQtext(),
                "count", st.count,
                "limit", st.limit);
    }

    // ===== 채점 =====
    @PostMapping("/check")
    @ResponseBody
    public Map<String,Object> check(@RequestParam int qid,
                                    @RequestParam String myKo,
                                    HttpSession session) {

    	TRState st = ensure(session);
    	Integer uno = (st.ctx != null) ? st.ctx.get("uno") : null;
    	if (uno == null) uno = resolveUno(session);
    	if (uno == null) {
    	    return Map.of("ok", false, "reason", "not_logged_in");
    	}

        QuizVo q = quizDao.findById(qid);
        if (q == null || q.getKtext() == null || q.getKtext().isBlank())
            return Map.of("ok", false, "reason", "no_ref");

        String meRaw  = (myKo == null) ? "" : myKo.trim();
        String refRaw = q.getKtext().trim();

        // 너무 짧은 답 선제 차단
        if (meRaw.replaceAll("\\s+", "").length() < 2) {
            return Map.of("ok", false, "reason", "too_short");
        }

        // 정규화 + 동의어/끝맺음 통합 + 조사/불용어 처리
        String meNorm  = normalizeKorean(meRaw);
        String refNorm = normalizeKorean(refRaw);

        // 토큰 기반 Jaccard
        List<String> meTokens  = tokenize(meNorm);
        List<String> refTokens = tokenize(refNorm);
        double j = jaccardToken(meTokens, refTokens);

        // 문자 기반 유사도(공백 제거)
        double c = charSim(meNorm.replace(" ",""), refNorm.replace(" ",""));

        // 길이 페널티 (최대 0.15 감점)
        int meLen  = meNorm.replace(" ", "").length();
        int refLen = refNorm.replace(" ", "").length();
        double lenRatio = (refLen == 0) ? 1.0 : Math.min(1.0, (meLen*1.0)/refLen);
        double lenPenalty = 0.15 * (1.0 - lenRatio);

        // 최소 커버리지 컷(토큰 자카드 하한)
        boolean coverageOk = j >= 0.45;

        double s = (j * 0.6 + c * 0.4) - lenPenalty;
        s = Math.max(0, Math.min(1, s));

        boolean correct = coverageOk && s >= 0.75;
        int score = (int)Math.round(s * 100);

        quizDao.insertTranslationResult(qid, uno, meRaw, correct, score);

        return Map.of("ok", true,
                "qid", qid,
                "correct", correct,
                "score", score,
                "ref", refRaw,
                "debug", Map.of("jaccard", j, "charSim", c, "lenPenalty", lenPenalty, "finalS", s));
    }

    // ===== 유틸 =====

    /** Ktext 있는 랜덤 문항만 채택 (중복/빈 Ktext 제외) */
    private QuizVo pickWithRef(Set<Integer> used, int maxTries){
        for (int i=0; i<maxTries; i++) {
            QuizVo cand = quizDao.findRandomOneGlobal();
            if (cand == null) break;
            if (used.contains(cand.getQid())) continue;
            if (cand.getKtext() == null || cand.getKtext().isBlank()) continue;
            return cand;
        }
        return null;
    }

    /** NFKC -> 소문자 -> 기호 제거 -> 소유어 축약/대명사 제거 -> 동의어/끝맺음 정리 -> 붙임 조사/불용어 제거 */
    private String normalizeKorean(String s){
        if (s == null) return "";

        String t = Normalizer.normalize(s, Normalizer.Form.NFKC)
                .toLowerCase();

        // ✅ 띄어쓰기 보정 (한글+영문/숫자 또는 붙은 한글 단어 분리)
        t = t.replaceAll("([가-힣])([A-Za-z0-9])", "$1 $2");
        t = t.replaceAll("([A-Za-z0-9])([가-힣])", "$1 $2");
        t = t.replaceAll("([가-힣]{2,})([가-힣]{2,})", "$1 $2");

        // 구두점/기호 제거
        t = t.replaceAll("[\\p{Punct}~·ㆍ\"'“”‘’…•··`´^_=+<>《》〈〉{}\\[\\]()/\\\\|]", " ");

        // 2인칭 소유 축약: "너의/네/당신의 + 명사" -> 명사
        t = t.replaceAll("\\b(너의|네|당신의)\\s+(\\S+)", "$2");
        // 2인칭 대명사 제거
        t = t.replaceAll("\\b(너|네|당신|그대|자네)\\b", " ");

        // 동의어/시제/경어/추측 표현 정리
        t = applySynonyms(t);
        t = simplifyEndingsAndHedges(t);

        // 토큰화 후 붙임 조사 제거 + 불용어 제거
        List<String> tokens = Arrays.stream(t.split("\\s+"))
                .filter(tok -> tok != null && !tok.isBlank())
                // 단어 끝에 붙은 조사 컷: 여행은/학교에서 -> 여행/학교
                .map(tok -> tok.replaceAll("(은|는|이|가|을|를|와|과|도|만|까지|부터|처럼|같이|으로|로|에서|에게|께)$", ""))
                .filter(tok -> !tok.isBlank())
                .collect(Collectors.toList());

        Set<String> stop = koreanStopwords();
        List<String> kept = new ArrayList<>();
        for (String tok : tokens) {
            // 기존: 불용어면 제거
            // 개선: 1~2글자 단어는 불용어더라도 예외적으로 유지 (단, 조사 제외)
            if (stop.contains(tok)) {
                // 단어 길이가 2 이하인 경우에도 조사(은,는,이,가,을,를...)는 제거
                if (tok.length() <= 2 && tok.matches("^(은|는|이|가|을|를)$")) continue;
                // 나머지 짧은 단어는 유지 (의미 있을 수 있음)
                if (tok.length() <= 2) {
                    kept.add(tok);
                    continue;
                }
                // 일반 불용어는 제거
                continue;
            }
            kept.add(tok);
        }
        return String.join(" ", kept).replaceAll("\\s+"," ").trim();
    }


    /** 시제/경어/추측 끝맺음 간단 정규화 (채점 안정화용) */
    private String simplifyEndingsAndHedges(String t) {
        if (t == null || t.isBlank()) return "";

        // "했던/한 것(거) 같..." -> 과거/현재로 정규화
        t = t.replaceAll("\\b했?던\\s*(것|거)\\s*같(아요|아|다)\\b", "했다");
        t = t.replaceAll("\\b한\\s*(것|거)\\s*같(아요|아|다)\\b", "한다");

        // 일반 추측 꼬리 제거
        t = t.replaceAll("\\s*(것|거)\\s*같(아요|아|다)\\b", "");

        // 과거 경어/반말 통합
        t = t.replaceAll("\\b했(음|어요|습니다|었어요|었음|었습니까|지요|죠)\\b", "했다");
        t = t.replaceAll("\\b했(어|지|네)\\b", "했다");
        t = t.replaceAll("\\b했(?:던|다니요|다네요)\\b", "했다");

        // 현재시제 경어/반말 통합
        t = t.replaceAll("\\b합(니다|니까)\\b", "한다");
        t = t.replaceAll("\\b해(요)?\\b", "한다");

        // 문미 존칭 꼬리 정리
        t = t.replaceAll("(요\\?|요)\\b", "");

        // "했을/할 것 같다" 간단 정리
        t = t.replaceAll("\\b했을\\s*(것|거)\\s*같(아요|아|다)\\b", "했다");
        t = t.replaceAll("\\b할\\s*(것|거)\\s*같(아요|아|다)\\b", "한다");

        return t;
    }

    /** 간단 동의어/표현 통합 (낱말 경계 기반) */
    private String applySynonyms(String t){
        String[][] synPairs = new String[][]{
            // 사람/역할
            {"아이","어린이"}, {"학생","어린이"}, {"아기","어린이"}, {"어른","성인"},
            {"선생님","교사"}, {"선생","교사"}, {"선생님들","교사들"},
            {"부모님","부모"}, {"엄마","어머니"}, {"아빠","아버지"},

            // 장소/사물/일반명사
            {"책","도서"}, {"문장","글"},
            {"자동차","차"}, {"승용차","차"}, {"버스","승합차"},

            // ‘어떻다’ 계열(질문 포함)
            {"어땠어요","어떻다"}, {"어땠어","어떻다"}, {"어땠음","어떻다"},
            {"어때요","어떻다"}, {"어때","어떻다"}, {"어땠나요","어떻다"},
            {"어떠셨나요","어떻다"}, {"어떠셨어요","어떻다"}, {"어떠십니까","어떻다"},

            // ‘하다’ 계열 시제/경어 통일
            {"했습니다","했다"}, {"했어요","했다"}, {"했음","했다"}, {"했었어요","했다"}, {"했었음","했다"},
            {"합니다","한다"}, {"해요","한다"}, {"해","한다"}, {"했지요","했다"}, {"했죠","했다"},

            // 서술격/이다 계열
            {"였어요","였다"}, {"이었어요","이었다"}, {"입니다","이다"}, {"예요","이다"}, {"에요","이다"},

            // 동사 공통(과거/현재 변형 통합 예시)
            {"먹습니다","먹다"}, {"먹어요","먹다"}, {"먹었어요","먹다"}, {"먹는다","먹다"}, {"먹어","먹다"},
            {"마십니다","마시다"}, {"마셔요","마시다"}, {"마셨다","마시다"},
            {"걷습니다","걷다"}, {"걸어요","걷다"}, {"걸었다","걷다"},
            {"달립니다","달리다"}, {"달려요","달리다"}, {"달렸다","달리다"},
            {"씁니다","쓰다"}, {"써요","쓰다"}, {"썼다","쓰다"},
            {"봅니다","보다"}, {"봐요","보다"}, {"보았다","보다"},
            {"듣습니다","듣다"}, {"들어요","듣다"}, {"들었다","듣다"},
            {"읽습니다","읽다"}, {"읽어요","읽다"}, {"읽었다","읽다"},
            {"만듭니다","만들다"}, {"만들어요","만들다"}, {"만들었다","만들다"},
            {"그립니다","그리다"}, {"그려요","그리다"}, {"그렸다","그리다"},

            // 시간/빈도/부사
            {"매일","날마다"}, {"매주","주마다"},
            {"아주","매우"}, {"정말","매우"}, {"너무","매우"}
        };

        for (String[] p : synPairs) {
            String left = Pattern.quote(p[0]);
            String right = p[1];
            t = t.replaceAll("(?<=^|\\s)"+ left +"(?=\\s|$)", right);
        }

        // 한글 숫자 간단 매핑 (완전 단어일 때만)
        String[][] numPairs = new String[][]{
            {"하나","1"}, {"둘","2"}, {"셋","3"}, {"넷","4"}, {"다섯","5"},
            {"여섯","6"}, {"일곱","7"}, {"여덟","8"}, {"아홉","9"}, {"열","10"}
        };
        for (String[] p : numPairs) {
            String left = Pattern.quote(p[0]);
            String right = p[1];
            t = t.replaceAll("(?<=^|\\s)"+ left +"(?=\\s|$)", right);
        }
        return t;
    }

    /** 한국어 조사/불용어 세트(간단) */
    private Set<String> koreanStopwords(){
        return new HashSet<>(Arrays.asList(
            // 조사/어미류
            "은","는","이","가","을","를","에","에서","에게","께","으로","로","와","과","도","만",
            "까지","부터","마다","라도","나","이나","보다","처럼","같이","의","께서","한테","랑",
            // 접속/지시 등 의미 약한 것들
            "그리고","그러나","하지만","또","또는","또한","그래서","즉","혹은","이것","그것","저것",
            "우리","너희","여러분"
        ));
    }

    /** 간단 토큰화 */
    private List<String> tokenize(String s){
        if (s == null || s.isBlank()) return Collections.emptyList();
        return Arrays.stream(s.split("\\s+"))
                .filter(x -> !x.isBlank())
                .collect(Collectors.toList());
    }

    /** 토큰 Jaccard */
    private double jaccardToken(List<String> A, List<String> B){
        if (A.isEmpty() && B.isEmpty()) return 1.0;
        Set<String> a = new HashSet<>(A);
        Set<String> b = new HashSet<>(B);
        a.remove(""); b.remove("");
        Set<String> inter = new HashSet<>(a); inter.retainAll(b);
        Set<String> uni = new HashSet<>(a); uni.addAll(b);
        return uni.isEmpty()? 0.0 : (inter.size()*1.0/uni.size());
    }

    /** 레벤슈타인 기반 문자 유사도 */
    private double charSim(String a, String b){
        int n=a.length(), m=b.length();
        if (n==0 && m==0) return 1.0;
        int[][] d=new int[n+1][m+1];
        for(int i=0;i<=n;i++) d[i][0]=i;
        for(int j=0;j<=m;j++) d[0][j]=j;
        for(int i=1;i<=n;i++){
            char ca=a.charAt(i-1);
            for(int j=1;j<=m;j++){
                char cb=b.charAt(j-1);
                int cost=(ca==cb)?0:1;
                d[i][j]=Math.min(Math.min(d[i-1][j]+1,d[i][j-1]+1), d[i-1][j-1]+cost);
            }
        }
        int dist=d[n][m];
        return 1.0 - (dist*1.0/Math.max(n,m));
    }
}

package com.daegu.eves.user;

import java.net.URLEncoder;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.threeten.bp.temporal.ChronoUnit;

import com.daegu.eves.PaginationVo;
import com.daegu.eves.lesson.LessonService;
import com.daegu.eves.lesson.LessonVo;
import com.daegu.eves.pdf.PdfService;
import com.daegu.eves.pdf.PdfVo;
import com.daegu.eves.sub.SubService;
import com.daegu.eves.sub.SubVo;
import com.daegu.eves.week.WeekService;
import com.daegu.eves.week.WeekVo;

@Controller
@RequestMapping("/user")
public class UserController {
	@Autowired
	UserService userService;
	@Autowired
	LessonService lessonService;
	@Autowired
	WeekService weekService;
	@Autowired
	SubService subService;
	@Autowired
	PdfService pdfService;
	
	private final String FILE_BASE_PATH = "C:\\fullstack\\workspace";

	
	    //  (1) 구독권 목록 화면
	    @GetMapping("/buy")
	    public String buyPage(HttpSession session, Model model) {
	        model.addAttribute("user", (UserVo) session.getAttribute("user"));
	        return "user/buy";  // JSP 경로: /WEB-INF/views/user/buy.jsp
	    }

	//  (2) 결제 입력 화면
	    @GetMapping("/subBuy")
	    public String subBuyForm(@RequestParam(required = false) Integer planMonth,
	                             HttpSession session, Model model) {

	        if (planMonth == null) planMonth = 1;  // 기본값

	        // 결제금액 계산
	        int totalPrice;
	        switch (planMonth) {
	            case 1:  totalPrice =  8_900; break;
	            case 6:  totalPrice = 46_500; break;
	            case 12: totalPrice = 89_000; break;
	            default:
	                // 허용 외 값이면 1개월로 보정
	                planMonth = 1;
	                totalPrice = 8_900;
	        }

	        // 세션 사용자
	        UserVo loginUser = (UserVo) session.getAttribute("loginUser");
	        if (loginUser == null) return "redirect:/main/Login";

	        model.addAttribute("selectedMonth", planMonth);
	        model.addAttribute("payDate", java.time.LocalDate.now().toString());
	        model.addAttribute("price", totalPrice);
	        model.addAttribute("user", loginUser);

	        return "user/subBuy";  // /WEB-INF/views/user/subBuy.jsp
	    }

	    @PostMapping("/subBuy")
	    public String doSubscribe(@RequestParam Integer planMonth,
	                              @RequestParam String payMethod,
	                              @RequestParam("payDate") String payDate, // 사용 안 해도 됨
	                              HttpSession session,
	                              RedirectAttributes ra) {

	        UserVo loginUser = (UserVo) session.getAttribute("loginUser");
	        if (loginUser == null) return "redirect:/main/Login";

	        // 플랜 값 방어
	        if (planMonth == null || !(planMonth == 1 || planMonth == 6 || planMonth == 12)) {
	            planMonth = 1;
	        }

	        // 구독정보 VO
	        SubVo subVo = new SubVo();
	        subVo.setUno((long) loginUser.getUno());
	        subVo.setPlanMonth(planMonth);
	        subVo.setUway(payMethod);
	        // payDate 는 서비스에서 baseEnd를 다시 계산하므로 사용하지 않아도 무방

	        // --- 누적 연장 + users(uchk=1, send=newEnd) 업데이트 ---
	        subService.subscribe(subVo);

	        // === 세션 갱신(서비스가 채운 vo 값 사용) ===
	        loginUser.setUchk(1);                 // 구독 중
	        loginUser.setSend(subVo.getSend());   // "yyyy-MM-dd" 형태
	        session.setAttribute("loginUser", loginUser);

	        ra.addFlashAttribute("subscribeMsg", true);
	        return "redirect:/user/buy";
	    }


	
	// 로그아웃 기능
	@GetMapping("/logout")
	public String logout(HttpSession session) {
		session.invalidate(); // 세션 종료
		return "redirect:/main"; // 로그인 페이지로 이동
	}
	
    // 유저 회원가입 기능
    @GetMapping("/Join")
    public String joinForm() {
        // 회원가입 폼 열기
       return "user/Join"; // /WEB-INF/views/user/Join.jsp
    }
   
    // 회원가입 완료 기능
    @PostMapping("/JoinOk")
    public String joinOk(
            @RequestParam("id") String id,
            @RequestParam("pw") String pw,
            @RequestParam("email") String email,
            @RequestParam("name") String name) {
 
        UserVo userVo = new UserVo();
        userVo.setUid(id);
        userVo.setUpw(pw);
        userVo.setUemail(email);
        userVo.setUname(name); 
        userVo.setUchk(0);     // 기본값: 구독 안 함
        userVo.setSend(null);  // 기본값: null

        int result = userService.insert(userVo);
 
        if (result > 0) {
            // 가입 성공
            return "redirect:/main/Login";
        } else {
            // 실패
            return "users/JoinErr";
        }
    }
    
    
    
    //아이디중복체크
    @GetMapping("/checkUid") 
    public String chkUid(@RequestParam("uid") String uid, Model model) {
 	    boolean exists= userService.chkUid(uid);
 	    String next="user/Join";
 	    model.addAttribute("uidValue", uid);
 	    if (exists) {
 	    	model.addAttribute("msg", "사용중인 아이디");
 	    }else {
 	    	model.addAttribute("msg","사용가능");
 	    }
 	   
 	    return next;
    }
 ////////////////////////////////////////////////////////////////////////////////////////
    //정우가 수정할거
    //회원도 여기 주차안됩니다. 나
    @GetMapping("/Week")
    public String UserWeek(@RequestParam("lno") int lno, Model model,
                      HttpSession session, RedirectAttributes redirectAttributes){
       
       UserVo loginUser = (UserVo) session.getAttribute("loginUser");
       UserVo user=userService.userInfo(loginUser.getUid());
        

       
       if (user == null) {
            System.out.println("로그인안됨.");
            return "redirect:/main/Login";
        }


        LessonVo lesson = lessonService.getLessonWithTeacher(lno); // 강의 정보            
        List<WeekVo> weeks = weekService.getWeeksByLesson(lno); // 주차 리스트
        model.addAttribute("lname", lesson.getLname());
        model.addAttribute("tname", lesson.getTname());
        model.addAttribute("lcate", lesson.getLcate());
        model.addAttribute("llevel", lesson.getLlevel());
        model.addAttribute("lsum", lesson.getLsum());
        model.addAttribute("lno", lno);
        model.addAttribute("lesson", lesson);  
        model.addAttribute("weeks", weeks);
        

//        구독권 여부 확인하기
        int uchk = user.getUchk();
        System.out.println("uchk: " + uchk);
        if (uchk == 1 || uchk == 2 || uchk == 3) {
            return "user/Week";
        } else {
           redirectAttributes.addFlashAttribute("subscribeMsg2",true);
            return "redirect:/user/buy"; // 구독X -> 구독하기페이지로 
        }
    }
    
    //  회원정보
    //  회원정보
    @GetMapping("/info")
    public String userInfo(HttpSession session,Model model ) {
       System.out.println("UserController의 info()");
       
       UserVo loginUser=(UserVo) session.getAttribute("loginUser");
       UserVo user=userService.userInfo(loginUser.getUid());
       
       // d-day계산
       String dday = "";
       if (user.getSend() != null && !user.getSend().isBlank()) {
          
          LocalDate today=LocalDate.now();
          LocalDate send=LocalDate.parse(user.getSend());
          long leftDays=java.time.temporal.ChronoUnit.DAYS.between(today, send);
          
          
           leftDays = java.time.temporal.ChronoUnit.DAYS.between(today, send);

           if (leftDays > 0) {
               dday = "D-" + leftDays;
           } else if (leftDays == 0) {
               dday = "D-Day";
           } else {
               dday = "구독이 종료되었습니다.";
           }
       }
       
       model.addAttribute("user", user);
       model.addAttribute("dday",dday);
       
       return "user/info";
    }
    // 회원정보 수정
    @GetMapping("/infoEdit")
    public String editForm(HttpSession session, Model model) {
        UserVo loginUser = (UserVo) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            return "redirect:/main/login"; // 로그인 안 된 경우 처리
        }
        
        UserVo user = userService.userInfo(loginUser.getUid());
        model.addAttribute("user", user);
        return "user/infoEdit";
    }
    // 회원정보 수정완료
    @PostMapping("/infoEdit")
    public String infoEdit(HttpSession session, UserVo userVo) {
        // 로그인 체크
        UserVo loginUser = (UserVo) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/main/login"; // 로그인 안 된 경우 로그인 페이지로
        }

        userVo.setUid(loginUser.getUid());
        // 회원정보 수정 처리
        userService.infoEdit(userVo);
        
        // 수정 후 회원정보 페이지로
        return "redirect:/user/info";
    }

//      회원 탈퇴하기
      @GetMapping("/delete")
      public String delete(HttpSession session) {
      
         UserVo loginUser=(UserVo) session.getAttribute("loginUser");
         userService.delete(loginUser.getUid());
         session.invalidate();
         return "redirect:/main";
      }
    
      
      // 내 학습실
      @GetMapping("/myClass")
      public String myClass(Model model, PaginationVo pgn, HttpSession session) {
         System.out.println("UserController의 myClass()");
         
         int curPage = (pgn.getCurPage() > 0) ? pgn.getCurPage() : 1;
         
          // Main컨트롤러에서 세션이 이미 저장된 loginUser를 꺼내쓰기
          UserVo loginUser = (UserVo) session.getAttribute("loginUser");
          if (loginUser == null) {
              System.out.println("로그인 세션 없음 → 로그인 페이지로 이동");
              return "main/Login";
          }
          
          int uno = loginUser.getUno();
         
         // 수강중인 강의 목록 가져오기
          List<LessonVo> UserLessonList = lessonService.getUserLessonList(uno, curPage);
          List<PaginationVo> pageList = lessonService.getUserPagination(curPage, uno);
          model.addAttribute("UserLessonList", UserLessonList);
          model.addAttribute("pageList", pageList);
          
         return "user/myClass";
      }
   // 구독 만료 시 접근 차단 포함 버전
      @GetMapping("/myWeek")
      public String myWeek(@RequestParam("lno") int lno,
                           HttpSession session,
                           Model model,
                           RedirectAttributes ra) { // <-- 추가

          UserVo loginUser = (UserVo) session.getAttribute("loginUser");
          if (loginUser == null) {
              return "redirect:/main/Login";
          }

          // ===== 구독 가드: send(종료일) 기준으로 만료 체크 =====
          boolean active = false;
          try {
              String sendStr = loginUser.getSend(); // 예: "yyyy-MM-dd"
              if (sendStr != null && !sendStr.trim().isEmpty()) {
                  java.time.LocalDate sendDate = java.time.LocalDate.parse(sendStr); // 포맷: yyyy-MM-dd 가정
                  java.time.LocalDate today   = java.time.LocalDate.now();
                  active = !sendDate.isBefore(today); // 오늘 이전이면 만료
              }
          } catch (Exception ignore) {
              active = false; // 파싱 실패 시 만료로 간주
          }

          // uchk 플래그도 함께 정리(0/1)
          if (!active) {
              loginUser.setUchk(0);
              session.setAttribute("loginUser", loginUser); // 세션에 반영
              ra.addFlashAttribute("subscribeMsg2", true);  // JSP에서 alert 띄우는 플래그
              return "redirect:/user/buy";
          } else if (loginUser.getUchk() == 0) {
              // send는 유효한데 uchk가 0으로 남아있다면 1로 복구
              loginUser.setUchk(1);
              session.setAttribute("loginUser", loginUser);
          }
          // ===== 구독 가드 끝 =====

          int uno = loginUser.getUno();

          // (선택) 수강 여부 체크
          // boolean enrolled = lessonService.isEnrolled(uno, lno);
          // if (!enrolled) {
          //     return "redirect:/user/myClass";
          // }

          // 강의/주차 조회
          LessonVo lesson = lessonService.getLessonWithTeacher(lno);
          java.util.List<WeekVo> weeks = weekService.getWeeksByLesson(lno);

          // 모델 바인딩
          model.addAttribute("lesson", lesson);
          model.addAttribute("weeks", weeks);
          model.addAttribute("uno", uno);
          model.addAttribute("lno", lno);
          model.addAttribute("lessonInfo", lesson);
          model.addAttribute("weekList", weeks);

          return "user/WeekDetail";
      }

      
      // 강의자료 페이지
      @GetMapping("/lessonData")
      public String lessonData(@RequestParam("lno") int lno, Model model, HttpSession session) {
          UserVo loginUser = (UserVo) session.getAttribute("loginUser");
          if (loginUser == null) return "redirect:/main/Login";

          LessonVo lesson = lessonService.getLessonWithTeacher(lno);
          List<PdfVo> pdfList = pdfService.getPdfListByLno(lno);

          model.addAttribute("lesson", lesson);
          model.addAttribute("pdfList", pdfList);
          return "user/lessonData";
      }
      
      // 파일 다운로드
      @GetMapping("/fileDownload")
      public ResponseEntity<Resource> fileDownload(@RequestParam("pno") int pno) {
          System.out.println("UserController fileDownload()");

          // DB에서 파일 정보 가져오기
          PdfVo pdf = pdfService.getPdfByPno(pno);
          if (pdf == null) {
              System.out.println("파일 정보 없음");
              return ResponseEntity.notFound().build();
          }

          Resource resource = null;
          HttpHeaders headers = new HttpHeaders();

          try {
              // 실제 파일 경로 (강사가 올린 위치)
              String fullPath = "C:\\fullstack\\workspace\\fileUpload\\" + pdf.getPupdf();
              resource = new UrlResource("file:" + fullPath);

              if (!resource.exists()) {
                  System.out.println("파일이 존재하지 않습니다: " + fullPath);
                  return ResponseEntity.notFound().build();
              }

              // 브라우저에 보여질 이름은 pdpdf (원본 파일명)
              String oriName = pdf.getPdpdf();
              headers.add("Content-Disposition", "attachment; filename=" +
                      new String(oriName.getBytes("UTF-8"), "ISO-8859-1"));

          } catch (Exception e) {
              e.printStackTrace();
              return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
          }

          // ④ 파일 전송
          return new ResponseEntity<>(resource, headers, HttpStatus.OK);
      }
      
      
      // 일단 다운로그
      
  	
//   // 강의 주차 목록
//      @GetMapping("/myWeek")
//      public String myWeek(@RequestParam("lno") int lno, HttpSession session, Model model) {
//          UserVo loginUser = (UserVo) session.getAttribute("loginUser");
//          if (loginUser == null) {
//              return "redirect:/main/Login";
//          }
//          
//          int uno = loginUser.getUno();
//
//          LessonVo lesson = lessonService.getLessonDetailForUser(lno, uno);
//          
//          PdfVo pdf = pdfService.getPdfByLno(lno);
//
//          model.addAttribute("lesson", lesson);
//          model.addAttribute("pdf", pdf);
//          
//          return "user/myWeek";
//      }
//      
//      // 학습자료 다운로드
//      @GetMapping("/download")
//      public ResponseEntity<Resource> downloadPdf(
//              @RequestParam("pupdf") String pupdf, // 저장된 파일명 (UUID)
//              @RequestParam("pdpdf") String pdpdf) { // 원본 파일명
//          
//          try {
//              Path pdfPath = Paths.get(FILE_BASE_PATH, "fileUpload", pupdf);
//              Resource resource = new UrlResource(pdfPath.toUri());
//
//              if (resource.exists() || resource.isReadable()) {
//                  String encodedPdpdf = URLEncoder.encode(pdpdf, "UTF-8").replaceAll("\\+", "%20");
//                  
//                  return ResponseEntity.ok()
//                          .contentType(MediaType.APPLICATION_PDF)
//                          .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + encodedPdpdf + "\"")
//                          .body(resource);
//              } else {
//                  return ResponseEntity.notFound().build();
//              }
//          } catch (Exception e) {
//              return ResponseEntity.notFound().build();
//          }
//      }
      
  	
}


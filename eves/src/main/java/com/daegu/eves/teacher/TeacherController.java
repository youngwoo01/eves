package com.daegu.eves.teacher;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.daegu.eves.Pagination;
import com.daegu.eves.lesson.LessonService;
import com.daegu.eves.lesson.LessonVo;
import com.daegu.eves.pdf.PdfService;
import com.daegu.eves.pdf.PdfVo;
import com.daegu.eves.user.UserService;
import com.daegu.eves.video.FfmpegRunner;
import com.daegu.eves.video.HlsResult;
import com.daegu.eves.video.VideoService;
import com.daegu.eves.week.WeekService;
import com.daegu.eves.week.WeekVo;

@Controller
@RequestMapping("/teacher")
public class TeacherController {
	@Autowired
	private VideoService videoService;
    @Autowired
    TeacherService teacherService;
    @Autowired
    UserService userService;
    @Autowired
    LessonService lessonService;
    @Autowired
    WeekService weekService;
    @Autowired
    PdfService pdfService;
    @Autowired
    private BCryptPasswordEncoder bCryptPasswordEncoder;

    // ✅ 기존 FfmpegRunner 그대로 사용
    @Autowired
    FfmpegRunner ffmpegRunner;

    private final String FILE_BASE_PATH = "C:\\fullstack\\workspace";
    
    private final String EXTERNAL_PROFILE_PATH = "C:/fullstack/workspace/profile/";

//	   //강사도 여기 주차안됩니다. 나
//	   @GetMapping("/week")
//	   public String UserWeek(@RequestParam("lno") int lno, Model model) {
//	       LessonVo lesson = lessonService.getLessonWithTeacher(lno); // 강의 정보
//	       List<WeekVo> weeks = weekService.getWeeksByLesson(lno); // 주차 리스트
//
//	       model.addAttribute("lname", lesson.getLname());
//	       model.addAttribute("tname", lesson.getTname());
//	       model.addAttribute("lcate", lesson.getLcate());
//	       model.addAttribute("llevel", lesson.getLlevel());
//	       model.addAttribute("lsum", lesson.getLsum());
//	       model.addAttribute("lessons", weeks); // JSP에서는 lessons로 주차 리스트 출력
//
//	       return "teacher/Week";
//	   }
	   
//	   내정보 보기
	   @GetMapping("/info")
	   public String teacherInfo(HttpSession session, Model model) {
		   System.out.println("TeacherController의 teacherInfo()");
		   
		   TeacherVo loginUser=(TeacherVo) session.getAttribute("loginUser");
		   TeacherVo teacher=teacherService.teacherInfo(loginUser.getTid());
		   model.addAttribute("teacher", teacher);
		   return "teacher/info";
	   }
	   
	// 강사 회원가입 기능
	   @GetMapping("/Join")
	   public String joinForm() {
	       return "teacher/Join"; 
	   }
	
	   @PostMapping("/JoinOk")
	   public String joinOk(TeacherVo teacherVo,
	                        @RequestParam("file") MultipartFile file,
	                        HttpServletRequest request) { 
	       // ✅ ServletContext 직접 꺼내기
	       String uploadDir = "C:/fullstackl/workspace/profile/";
	       File dir = new File(uploadDir);
	       if (!dir.exists()) dir.mkdirs();
  // 🔧 파일 업로드 처리
	        try {
	            if (file != null && !file.isEmpty()) {
	                String savedFileName = UUID.randomUUID() + "_" + file.getOriginalFilename();
	                file.transferTo(new File(EXTERNAL_PROFILE_PATH, savedFileName));
	                teacherVo.setTphoto(savedFileName);
	            } else {
	                // 🔧 파일이 없으면 기본 이미지
	                teacherVo.setTphoto("default.jpg");
	            }
		        } catch (IOException e) {
		            e.printStackTrace();
		            teacherVo.setTphoto("default.jpg");
		        }
	        //
	       int result = teacherService.insertTeacher(teacherVo);
	       return (result > 0) ? "main/Login" : "main/JoinErr";
	   }

	   @GetMapping("/logout")
	      public String logout(HttpSession session) {
	        session.invalidate(); // 세션 종료
	        return "redirect:/main"; // 로그인 페이지로 이동
	      }

	   
	 //아이디중복체크
	   @GetMapping("/checkTid") 
	   public String chkTid(@RequestParam("tid") String tid,Model model) {
	       boolean exists= teacherService.chkTid(tid);
	       String next="teacher/Join";
	       
	       model.addAttribute("tidValue", tid );
	       
	       if (exists) {
	          model.addAttribute("msg", "사용중인 아이디");
	       }else {
	          model.addAttribute("msg","사용가능");
	       }
	      
	       return next;
	   }   
	   //정보 수정 기능
         @GetMapping("/infoEdit")
	      public String infoEditForm(@RequestParam("tid") String tid, Model model) {
	          TeacherVo teacher = teacherService.getTeacherByTid(tid);
	          model.addAttribute("teacher", teacher);
	          return "teacher/infoEdit";  // => /WEB-INF/views/teacher/infoEdit.jsp
	      }
         // 정보 수정완료
         @PostMapping("/infoEditOk")
  	   public String infoEditOk(TeacherVo teacherVo,
  	                            @RequestParam(value = "proFile", required = false) MultipartFile file,
  	                            HttpServletRequest request,
  	                            Model model) {
  	       try {
  	           // 기존 정보 가져오기
  	           TeacherVo original = teacherService.getTeacherByTid(teacherVo.getTid());

  	           // 1️⃣ 비밀번호 처리
  	           if (teacherVo.getTpw() == null || teacherVo.getTpw().isEmpty()) {
  	               teacherVo.setTpw(original.getTpw());
  	           } else {
  	               teacherVo.setTpw(bCryptPasswordEncoder.encode(teacherVo.getTpw()));
  	           }
  	        // 🔧 외부 폴더 생성
  	            File dir = new File(EXTERNAL_PROFILE_PATH);
  	            if (!dir.exists()) dir.mkdirs();
  	            
  	            // 🔧 파일 업로드 처리
  	            if (file != null && !file.isEmpty()) {
  	                // 기존 파일 삭제
  	                if (original.getTphoto() != null && !original.getTphoto().equals("default.jpg")) {
  	                    File oldFile = new File(EXTERNAL_PROFILE_PATH, original.getTphoto());
  	                    if (oldFile.exists()) oldFile.delete();
  	                }

  	                // 새 파일 저장
  	                String savedFileName = UUID.randomUUID() + "_" + file.getOriginalFilename();
  	                file.transferTo(new File(EXTERNAL_PROFILE_PATH, savedFileName));
  	                teacherVo.setTphoto(savedFileName);
  	            } else {
  	                // 기존 사진 유지 (없으면 default)
  	                String oriPhoto = original.getTphoto();
  	                teacherVo.setTphoto((oriPhoto == null || oriPhoto.isEmpty()) ? "default.jpg" : oriPhoto);
  	            }

  	            // 가입일은 변경 안 함
  	            teacherVo.setTdate(original.getTdate());

  	           // 5️⃣ DB 업데이트
  	           int result = teacherService.updateTeacherInfo(teacherVo);
  	           model.addAttribute("msg", result > 0 ? "✅ 수정이 완료되었습니다!" : "⚠️ 다시 한 번 확인하세요.");
  	           model.addAttribute("teacher", teacherService.getTeacherByTid(teacherVo.getTid()));

  	           return "teacher/infoEdit";

  	       } catch (Exception e) {
  	           e.printStackTrace();
  	           model.addAttribute("msg", "⚠️ 오류가 발생했습니다. 다시 시도해주세요.");
  	           model.addAttribute("teacher", teacherService.getTeacherByTid(teacherVo.getTid()));
  	           return "teacher/infoEdit";
  	       }
  	   }


         // 강사 탈퇴
         @GetMapping("/delete")
         public String delete(HttpSession session) {
             TeacherVo loginUser = (TeacherVo) session.getAttribute("loginUser");
             teacherService.requestDelete(loginUser.getTid());
             // 예약 결과를 헤더에서 보이게 하려면 세션 유지
             teacherService.setDeletionDdayToSession(session, loginUser.getTid());

             return "redirect:/main";
         }
	   
	   	  // 강의 수정
	      @GetMapping("/lessonEdit")
	      public String lessonEdit(@RequestParam("lno") int lno, Model model) {
	         LessonVo lessonVo = lessonService.getLessonByLno(lno);
	         List<WeekVo> weeksList = weekService.getWeeksListByLno(lno);
	         
	         List<PdfVo> pdfList = pdfService.getPdfListByLno(lno); 
	         
	         model.addAttribute("lesson", lessonVo);
	         model.addAttribute("weeksList", weeksList);
	         model.addAttribute("pdfList", pdfList); 
	         return "teacher/lessonEdit";
	      }
	   
//	   강의 삭제
	   @GetMapping("/lessonDelete")
	   public String lessonDelete(@RequestParam("lno") int lno) {
		   lessonService.DeleteLesson(lno);
		   return "redirect:/teacher/lesson";
	   }
		
	   @PostMapping("/lessonEditOk")
	      public String lessonEditOk(LessonVo lessonVo, 
	                        @RequestParam("thumbnailFile") MultipartFile thumbnailFile,
	                        @RequestParam("pdfFiles") List<MultipartFile> pdfFiles) { // 💡 pdfFile -> pdfFiles (List)
	         
	         if (!thumbnailFile.isEmpty()) {
	            LessonVo currentLesson = lessonService.getLessonByLno(lessonVo.getLno());
	            deleteFile(currentLesson.getLsum(), FILE_BASE_PATH + "\\imageUpload");

	            String savedFileName = saveFile(thumbnailFile, FILE_BASE_PATH + "\\imageUpload");
	            if (savedFileName != null) {
	               lessonVo.setLsum(savedFileName);
	            }
	         }
	         lessonService.updateLesson(lessonVo);

	         if (pdfFiles != null && !pdfFiles.isEmpty()) {
	               for (MultipartFile pdfFile : pdfFiles) {
	                   if (!pdfFile.isEmpty()) {
	                       String uploadPath = FILE_BASE_PATH + "\\fileUpload";
	                       String savedFileName = saveFile(pdfFile, uploadPath);
	                       
	                       if (savedFileName != null) {
	                           PdfVo pdfVo = new PdfVo();
	                           pdfVo.setLno(lessonVo.getLno());
	                           pdfVo.setWno(0); //
	                           pdfVo.setPupdf(savedFileName);
	                           pdfVo.setPdpdf(pdfFile.getOriginalFilename());
	                           pdfVo.setPdate(new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
	                           
	                           pdfService.insertPdf(pdfVo);
	                       }
	                   }
	               }
	         }
	         return "redirect:/teacher/week?lno=" + lessonVo.getLno();
	      }
	   
//
//		   @PostMapping("/weekEditOk")
//		    public String weekEditOk(WeekVo weekVo,
//		                             @RequestParam("videoFile") MultipartFile file) throws Exception {
//		        if (!file.isEmpty()) {
//		            WeekVo currentWeek = weekService.getWeekByWno(weekVo.getWno());
//		            deleteFile(currentWeek.getWuvideo(), FILE_BASE_PATH + "\\videoUpload");
//
//		            String savedFileName = saveFile(file, FILE_BASE_PATH + "\\videoUpload");
//		            if (savedFileName != null) {
//		                weekVo.setWuvideo(savedFileName);
//		                weekVo.setWdvideo(file.getOriginalFilename());
//
//		                Path original = Paths.get(FILE_BASE_PATH, "videoUpload", savedFileName);
//		                HlsResult res = ffmpegRunner.convertToHls(original, String.valueOf(weekVo.getWno()));
//		                System.out.println("[HLS 재생성 완료] " + res.getMasterPath());
//		            }
//		        }
//		        weekService.updateWeek(weekVo);
//		        return "redirect:/teacher/lessonEdit?lno=" + weekVo.getLno();
//		    }
//	   @PostMapping("/weekEditOk")
//	   public String weekEditOk(WeekVo weekVo,
//	                            @RequestParam("videoFile") MultipartFile file) throws Exception {
//	       if (!file.isEmpty()) {
//	           // ✅ 기존 주차에 업로드 → HLS 변환 → wuvideo 갱신까지 한 번에 처리
//	           videoService.uploadAndAttachToWeek(weekVo.getWno(), file);
//
//	           // 원본명(wdvideo)과 재생경로(wuvideo)는 VideoService에서 갱신하므로
//	           // 여기서 setWuvideo/setWdvideo 할 필요 없음
//	       }
//	       weekService.updateWeek(weekVo); // 제목/설명 등 나머지 필드 업데이트
//	       return "redirect:/teacher/lessonEdit?lno=" + weekVo.getLno();
//	   }

		@GetMapping("/weekDelete")
		public String weekDelete(@RequestParam("wno") int wno, @RequestParam("lno") int lno) {
			WeekVo weekToDelete = weekService.getWeekByWno(wno);
			if (weekToDelete != null) {
				deleteFile(weekToDelete.getWuvideo(), FILE_BASE_PATH + "\\videoUpload");
			}
			weekService.deleteWeek(wno);
			return "redirect:/teacher/lessonEdit?lno=" + lno;
		}

		@GetMapping("/week")
		public String week(@RequestParam("lno") int lno, Model model) {
			LessonVo lessonVo = lessonService.getLessonByLno(lno);
			List<WeekVo> weeksList = weekService.getWeeksListByLno(lno);
			model.addAttribute("lesson", lessonVo);
			model.addAttribute("weeksList", weeksList);
			return "teacher/week";
		}
		
		@GetMapping("/week/play")
		public String play(@RequestParam int wno,
		                   @RequestParam(required=false) Integer lno,
		                   Model model) {
		    String playUrl = "/play/" + wno + "/master.m3u8";
		    String thumbUrl = "/play/" + wno + "/thumb.jpg"; // ← 여기로 변경!
		    model.addAttribute("wno", wno);
		    model.addAttribute("lno", lno);
		    model.addAttribute("playUrl", playUrl);
		    model.addAttribute("thumbUrl", thumbUrl);
		    return "weeks/play"; // 뷰 폴더명이 실제로 weeks인지 확인 (아래 4번 참고)
		}

		  @PostMapping("/addWeekOk")
		    public String addWeekOk(WeekVo weeksVo,
		                            @RequestParam("videoFile") MultipartFile file) throws Exception {
		        String savedFileName = null;

		        // 1️⃣ 파일 저장
		        if (!file.isEmpty()) {
		            String uploadPath = FILE_BASE_PATH + "\\videoUpload";
		            savedFileName = saveFile(file, uploadPath);
		            if (savedFileName != null) {
		                weeksVo.setWuvideo(savedFileName);
		                weeksVo.setWdvideo(file.getOriginalFilename());
		            }
		        }

		        // 2️⃣ 주차 등록 (wno 자동 생성)
		        int newWno = weekService.insertWeek(weeksVo);
		        if (newWno <= 0 && weeksVo.getWno() > 0) newWno = weeksVo.getWno();

		        // 3️⃣ FFmpegRunner로 HLS 변환 실행
		        if (savedFileName != null && newWno > 0) {
		            Path original = Paths.get(FILE_BASE_PATH, "videoUpload", savedFileName);
		            HlsResult res = ffmpegRunner.convertToHls(original, String.valueOf(newWno));
		            System.out.println("[HLS 생성 완료] " + res.getMasterPath());
		        }

		        return "redirect:/teacher/week?lno=" + weeksVo.getLno();
		    }

		@GetMapping("/lesson")
		public String lessonList(@RequestParam(value = "page", defaultValue = "1") int currentPage, @RequestParam(value = "keyword", required = false) String keyword, HttpSession session, Model model) {
			TeacherVo loginTeacher = (TeacherVo) session.getAttribute("loginUser");
			if (loginTeacher == null) { return "redirect:/main/Login"; }
			int tno = loginTeacher.getTno();
			int totalRecord = lessonService.getLessonCountByTno(tno, keyword);
			Pagination pagination = new Pagination(totalRecord, currentPage);
			List<LessonVo> lessonList = lessonService.getLessonListByTno(tno, keyword, pagination.getStartRecord(), pagination.getRecordSize());
			model.addAttribute("lessonList", lessonList);
			model.addAttribute("p", pagination);
			model.addAttribute("keyword", keyword);
			return "teacher/lesson";
		}

		@GetMapping("/lessonAdd")
		public String lessonAddForm(HttpSession session) {
			return "teacher/lessonAdd";
		}
		
		@PostMapping("/lessonAddOk")
		public String lessonAddOk(LessonVo lessonVo, 
                @RequestParam("thumbnailFile") MultipartFile thumbnailFile, 
                @RequestParam("pdfFiles") List<MultipartFile> pdfFiles, 
                HttpSession session) {

			TeacherVo loginTeacher = (TeacherVo) session.getAttribute("loginUser");
			if (loginTeacher == null) { return "redirect:/main/Login"; }
			lessonVo.setTno(loginTeacher.getTno());
			
			// --- 썸네일 저장 ---
			if (!thumbnailFile.isEmpty()) {
			String uploadPath = FILE_BASE_PATH + "\\imageUpload";
			String savedFileName = saveFile(thumbnailFile, uploadPath);
			if (savedFileName != null) { lessonVo.setLsum(savedFileName); } 
			else { return "errorPage"; }
			}
			
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			lessonVo.setLdate(sdf.format(new Date()));
			lessonVo.setLweek(0);
			lessonVo.setLhit(0);
			
			int newLno = lessonService.insertLesson(lessonVo);
			
			// 학습자료 저장
			if (newLno > 0 && pdfFiles != null && !pdfFiles.isEmpty()) {
			
			for (MultipartFile pdfFile : pdfFiles) {
			    if (!pdfFile.isEmpty()) {
			        String uploadPath = FILE_BASE_PATH + "\\fileUpload";
			        String savedFileName = saveFile(pdfFile, uploadPath);
			        
			        if (savedFileName != null) {
			            PdfVo pdfVo = new PdfVo();
			            pdfVo.setLno(newLno);
			            pdfVo.setWno(0);
			            pdfVo.setPupdf(savedFileName);
			            pdfVo.setPdpdf(pdfFile.getOriginalFilename());
			            pdfVo.setPdate(sdf.format(new Date()));
			            
			            pdfService.insertPdf(pdfVo); 
			        } else {
			            // return "errorPage";
			        }
			    }
			}
			}
			return "redirect:/teacher/lesson";
		}

		  private String saveFile(MultipartFile file, String uploadPath) {
		        try {
		            String originalFileName = file.getOriginalFilename();
		            String savedFileName = UUID.randomUUID() + "_" + originalFileName;
		            File saveFile = new File(uploadPath, savedFileName);
		            if (!saveFile.getParentFile().exists()) {
		                saveFile.getParentFile().mkdirs();
		            }
		            file.transferTo(saveFile);
		            return savedFileName;
		        } catch (IOException e) {
		            e.printStackTrace();
		            return null;
		        }
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
		    
		    @PostMapping("/pdfDelete")
	          public String pdfDelete(@RequestParam("pno") int pno, 
	                                  @RequestParam("lno") int lno,
	                                  RedirectAttributes redirectAttributes) {
	              
	              PdfVo pdf = pdfService.getPdfByPno(pno);
	              
	              if (pdf != null) {
	                  deleteFile(pdf.getPupdf(), FILE_BASE_PATH + "\\fileUpload");
	                  
	                  pdfService.deletePdfByPno(pno);
	              }
	              
	              redirectAttributes.addAttribute("lno", lno);
	              return "redirect:/teacher/lessonEdit";
	          }
	      }
		


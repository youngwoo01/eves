// com.daegu.eves.video.VideoController.java
package com.daegu.eves.video;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

//com.daegu.eves.video.VideoController.java
@Controller
@RequiredArgsConstructor
@RequestMapping("/video") // (충돌 회피하려면 /api/video 권장)
public class VideoController {

 private final VideoService videoService;

 @GetMapping("/upload")
 public String uploadPage() { return "weeks/Upload"; }

 // 기존 주차에 업로드(교체)
 @PostMapping("/uploadToWeek")
 @ResponseBody
 public String uploadToWeek(@RequestParam int wno,
                            @RequestParam MultipartFile file) {
     try {
         String videoId = videoService.uploadAndAttachToWeek(wno, file);
         return "OK:" + videoId; // videoId == wno
     } catch (Exception e) {
         e.printStackTrace();
         return "FAIL:" + e.getMessage();
     }
 }

 // 새 주차 생성 + 업로드
 @PostMapping("/uploadAndCreateWeek")
 @ResponseBody
 public String uploadAndCreateWeek(@RequestParam int lno,
                                   @RequestParam String wname,
                                   @RequestParam MultipartFile file) {
     try {
         String videoId = videoService.uploadAndCreateWeek(lno, wname, file);
         return "OK:" + videoId; // videoId == 새로 발급된 wno
     } catch (Exception e) {
         e.printStackTrace();
         return "FAIL:" + e.getMessage();
     }
 }

 @GetMapping({"/uploadToWeek","/uploadAndCreateWeek"})
 public String redirectIfGet() { return "redirect:/video/upload"; }
}

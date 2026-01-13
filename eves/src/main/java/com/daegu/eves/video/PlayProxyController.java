// com.daegu.eves.video.PlayProxyController.java
package com.daegu.eves.video;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.*;
import org.springframework.http.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.nio.file.*;

@Controller
@RequestMapping("/play")
public class PlayProxyController {
	
    @Value("${video.storage.hls-dir:C:/video/hls}")
    private String hlsRoot;

    private ResponseEntity<Resource> serve(Path p, MediaType type) {
        Resource r = new FileSystemResource(p.toFile());
        if (!r.exists()) return ResponseEntity.notFound().build();
        return ResponseEntity.ok()
                .contentType(type)
                .cacheControl(CacheControl.noCache()) // 필요시 조정
                .body(r);
    }

    // master.m3u8
    @GetMapping("/{videoId}/master.m3u8")
    public ResponseEntity<Resource> master(@PathVariable String videoId) {
        Path p = Paths.get(hlsRoot, videoId, "master.m3u8");
        return serve(p, MediaType.parseMediaType("application/vnd.apple.mpegurl"));
    }

    // 세그먼트(.ts 또는 .m4s 등). 하위 경로 그대로 매핑
    @GetMapping("/{videoId}/{segment:.+}")
    public ResponseEntity<Resource> segment(@PathVariable String videoId,
                                            @PathVariable String segment) {
        Path p = Paths.get(hlsRoot, videoId, segment);
        // 확장자에 따라 타입 유연 처리
        String ext = segment.toLowerCase();
        MediaType type = ext.endsWith(".ts") ? MediaType.APPLICATION_OCTET_STREAM
                         : ext.endsWith(".m3u8") ? MediaType.parseMediaType("application/vnd.apple.mpegurl")
                         : MediaType.APPLICATION_OCTET_STREAM;
        return serve(p, type);
    }

    // 썸네일
    @GetMapping("/thumbnail/{videoId}/{fileName}")
    public ResponseEntity<Resource> thumb(@PathVariable String videoId,
                                          @PathVariable String fileName) {
        Path p = Paths.get(hlsRoot, videoId, fileName);
        return serve(p, MediaType.IMAGE_JPEG);
    }
}

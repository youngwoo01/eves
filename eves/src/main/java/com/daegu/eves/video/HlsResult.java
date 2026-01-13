// com.daegu.eves.video.HlsResult.java
package com.daegu.eves.video;
import lombok.Data;

@Data
public class HlsResult {
    private String videoId;
    private String hlsDir;       // 로컬 경로
    private String masterPath;   // 로컬 master.m3u8 경로
    private String thumbName;    // thumb.jpg
}

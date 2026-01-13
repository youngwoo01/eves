package com.daegu.eves.quiz;

import com.google.api.gax.core.FixedCredentialsProvider;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.speech.v1.SpeechClient;
import com.google.cloud.speech.v1.SpeechSettings;
import com.google.cloud.texttospeech.v1.TextToSpeechClient;
import com.google.cloud.texttospeech.v1.TextToSpeechSettings;

import java.io.FileInputStream;
import java.io.IOException;

public class GoogleClients {

	private static final String KEY_PATH = "C:/keys/groovy-groove-475810-c9-c8ee05f9e962.json";
    private static volatile GoogleCredentials CREDS;
    private static volatile TextToSpeechSettings TTS_SETTINGS;
    private static volatile SpeechSettings STT_SETTINGS;

    private static GoogleCredentials credentials() {
        if (CREDS == null) {
            synchronized (GoogleClients.class) {
                if (CREDS == null) {
                    try {
                        GoogleCredentials base = GoogleCredentials.fromStream(new FileInputStream(KEY_PATH));
                        // 일부 환경에서 필요 시 스코프 추가 (보통은 없어도 됨)
                        CREDS = base.createScoped("https://www.googleapis.com/auth/cloud-platform");
                    } catch (IOException e) {
                        throw new RuntimeException("GCP credentials load failed: " + KEY_PATH, e);
                    }
                }
            }
        }
        return CREDS;
    }

    private static TextToSpeechSettings ttsSettings() {
        if (TTS_SETTINGS == null) {
            synchronized (GoogleClients.class) {
                if (TTS_SETTINGS == null) {
                    try {
                        TTS_SETTINGS = TextToSpeechSettings.newBuilder()
                                .setCredentialsProvider(FixedCredentialsProvider.create(credentials()))
                                .build();
                    } catch (IOException e) {
                        throw new RuntimeException("Failed to build TTS settings", e);
                    }
                }
            }
        }
        return TTS_SETTINGS;
    }

    private static SpeechSettings sttSettings() {
        if (STT_SETTINGS == null) {
            synchronized (GoogleClients.class) {
                if (STT_SETTINGS == null) {
                    try {
                        STT_SETTINGS = SpeechSettings.newBuilder()
                                .setCredentialsProvider(FixedCredentialsProvider.create(credentials()))
                                .build();
                    } catch (IOException e) {
                        throw new RuntimeException("Failed to build STT settings", e);
                    }
                }
            }
        }
        return STT_SETTINGS;
    }

    /** 매 요청마다 client는 새로 열고, try-with-resources로 즉시 닫아주세요. */
    public static TextToSpeechClient newTtsClient() {
        try {
            return TextToSpeechClient.create(ttsSettings());
        } catch (IOException e) {
            throw new RuntimeException("Failed to create TTS client", e);
        }
    }

    public static SpeechClient newSttClient() {
        try {
            return SpeechClient.create(sttSettings());
        } catch (IOException e) {
            throw new RuntimeException("Failed to create STT client", e);
        }
    }
}

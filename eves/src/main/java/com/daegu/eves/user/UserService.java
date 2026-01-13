package com.daegu.eves.user;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private UserDao userDao;

    @Autowired
    private BCryptPasswordEncoder bCryptPasswordEncoder;

    // 로그인 (DAO에서 비번 검증 + 만료 처리까지 수행)
    public UserVo login(UserVo vo) {
        return userDao.login(vo);
    }

    // 회원가입
    public int insert(UserVo vo) {
        // 아이디 중복체크
        boolean exists = userDao.existUid(vo.getUid());
        if (exists) {
            return -1; // 이미 존재
        }
        // 비밀번호 암호화
        vo.setUpw(bCryptPasswordEncoder.encode(vo.getUpw()));
        return userDao.insert(vo);
    }

    // 아이디 중복 체크
    public boolean chkUid(String uid) {
        return userDao.existUid(uid);
    }

    // 회원 정보
    public UserVo userInfo(String uid) {
        return userDao.userInfo(uid);
    }

    // 회원 정보 수정
    public void infoEdit(UserVo userVo) {
        userDao.infoEdit(userVo);
    }

    // 회원 탈퇴
    public int delete(String uid) {
        return userDao.delete(uid);
    }

    // 관리자: 회원 리스트
    public List<UserVo> getUserList() {
        return userDao.getUserList();
    }

    // (옵션) 필요 시 다른 진입점에서 만료만 강제로 체크하고 싶을 때 호출
    public int expireIfNeededByUid(String uid) {
        return userDao.expireIfNeededByUid(uid);
    }
}

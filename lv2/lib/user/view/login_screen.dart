import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lv2/common/component/custom_text_form_field.dart';
import 'package:lv2/common/constants/colors.dart';
import 'package:lv2/common/constants/data.dart';
import 'package:lv2/common/layout/default_layout.dart';
import 'package:lv2/common/view/root_tab.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String loginId = '';
  String loginPw = '';

  @override
  Widget build(BuildContext context) {
    final storage = FlutterSecureStorage();
    final dio = Dio();
    final simulatorIp = "http://127.0.0.1:3000";
    final emulatorIp = "http://10.0.2.2:3000";

    final ip = defaultTargetPlatform == TargetPlatform.iOS
        ? simulatorIp
        : emulatorIp;

    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Title(),
                const SizedBox(height: 16.0),
                _SubTitle(),
                Image.asset(
                  'asset/img/misc/logo.png',
                  width: MediaQuery.of(context).size.width / 3 * 2,
                ),
                CustomTextFormField(
                  hintText: '이메일을 입력해주세요.',
                  onChanged: (String value) {
                    loginId = value;
                  },
                ),
                const SizedBox(height: 16.0),
                CustomTextFormField(
                  hintText: '비밀번호를 입력해주세요.',
                  onChanged: (String value) {
                    loginPw = value;
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final rawString = '$loginId:$loginPw';

                      Codec<String, String> toBase64 = utf8.fuse(base64);

                      final token = toBase64.encode(rawString);

                      final response = await dio.post(
                        "$ip/auth/login",
                        options: Options(
                          headers: {"authorization": 'Basic $token'},
                        ),
                      );

                      print('#1. Login Data: ${response.data}');

                      final refreshToken = response.data['refreshToken'];
                      final accessToken = response.data['accessToken'];

                      await storage.write(
                        key: REFRESH_TOKEN_KEY,
                        value: refreshToken,
                      );
                      await storage.write(
                        key: ACCESS_TOKEN_KEY,
                        value: accessToken,
                      );

                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => RootTab()));
                    } catch (e) {
                      print('error occur in login step');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: Text('로그인', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () async {
                    final token =
                        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3RAY29kZWZhY3RvcnkuYWkiLCJzdWIiOiJmNTViMzJkMi00ZDY4LTRjMWUtYTNjYS1kYTlkN2QwZDkyZTUiLCJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTc2OTc2NjUzOSwiZXhwIjoxNzY5ODUyOTM5fQ.rm8d3UxNzN5ZJL_nLkntdIbqrGe1ND5P2TyBPy6VfsE';

                    final response = await dio.post(
                      "$ip/auth/token",
                      options: Options(
                        headers: {"authorization": 'Bearer $token'},
                      ),
                    );

                    print("#3. AuthResponse: ${response.data}");
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: Text('회원가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Text(
      '환영합니다!',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      '이메일과 비밀번호를 입력해서 로그인 해주세요!\n오늘도 성공적인 주문이 되길 :)',
      style: TextStyle(fontSize: 16, color: bodyTextColor),
    );
  }
}

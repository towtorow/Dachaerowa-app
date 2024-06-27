import 'package:dachaerowa/config/Config.dart';
import 'package:dachaerowa/page/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future<void> _signUp() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        final response = await http.post(
          Uri.parse('http://${Config.apiBaseUrl}/auth/signup'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': _usernameController.text,
            'password': _passwordController.text,
            'email': _emailController.text,
          }),
        );

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.body)));
        if (response.statusCode == 200) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false,
          );
        }
      }


    } catch (e, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
    key: _formKey,
    child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 2),
            // Instagram logo
            Text('다채로와', style: Theme.of(context).textTheme.headlineLarge,),
            Spacer(flex: 1),
            // Email TextField
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '이메일',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return '반드시 입력해야합니다.';
                }

                String pattern =
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                RegExp regex = RegExp(pattern);
                if (!regex.hasMatch(value)) {
                  return '이메일을 입력해주세요.';
                }

                return null;
              },
            ),
            SizedBox(height: 12),
            // Username TextField
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '사용자 이름',
              ),

              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return '반드시 입력해야합니다.';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            // Password TextField
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '비밀번호',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return '반드시 입력해야합니다.';
                }
                return null;
              },
              obscureText: true,
            ),
            SizedBox(height: 24),
            // Sign Up Button
            ElevatedButton(
              onPressed: _signUp,
              child: Text('회원가입'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 12),
            Spacer(flex: 2),
            // Divider with OR text

            Spacer(flex: 1),
            // Log in link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("이미 계정이 있나요?"),
                TextButton(
                  onPressed: () { Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  ); },
                  child: Text('로그인'),
                ),
              ],
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    )
    );
  }


}


import 'package:dachaerowa/config/Config.dart';
import 'package:dachaerowa/page/MainPage.dart';
import 'package:dachaerowa/page/SignUpPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateTextField(String? value) {
    if (value == null || value.isEmpty) {
      return '반드시 입력해야합니다.';
    }
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try{
        final response = await http.post(
          Uri.parse('http://${Config.apiBaseUrl}/auth/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'username': _usernameController.text,
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {

          SharedPreferences prefs = await SharedPreferences.getInstance();

          final responseBody = jsonDecode(response.body);
          final token = responseBody['jwt'];

          await prefs.setString('jwt', token);
          await prefs.setString('username', _usernameController.text);
          await prefs.setString('password', _passwordController.text);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainPage()), (Route<dynamic> route) => false,
          );
        } else {

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.body)));
        }

      } catch (e, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('에러: $e')));
      }

    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        child:  Form(
    key: _formKey,
    child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 2),
            // Instagram logo
            Text('다채로와', style: Theme.of(context).textTheme.headlineLarge,),
            Spacer(flex: 1),
            // Username TextField
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '사용자 이름',
              ),
              validator: _validateTextField,
            ),
            SizedBox(height: 12),
            // Password TextField
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '비밀번호',
              ),
              obscureText: true,
              validator: _validateTextField,
            ),
            SizedBox(height: 24),
            // Login Button
            ElevatedButton(
              onPressed: _login,
              child: Text('로그인', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 12),
            // Forgot password
            TextButton(
              onPressed: () {},
              child: Text('비밀번호를 잊으셨나요?'),
            ),
            Spacer(flex: 2),
            

            Spacer(flex: 1),
     
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("계정이 없으신가요?"),
                TextButton(
                  onPressed: () { Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  ); },
                  child: Text('회원가입'),
                ),
              ],
            ),
            Spacer(flex: 1),
          ],
        ),

      ),

      ),
    );

  }
}


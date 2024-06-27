import 'package:intl/intl.dart';
class CommonUtil {
  // 날짜 형식 변환
  static String formatIsoTimeString(String isoString) {
    DateTime dateTime = DateTime.parse(isoString);
    DateFormat formatter = DateFormat('yyyy년 MM월 dd일 HH:mm:ss');
    return formatter.format(dateTime);
  }
}
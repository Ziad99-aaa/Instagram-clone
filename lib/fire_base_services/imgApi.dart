import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

Future<String> uploadToImgBB({required Uint8List imgpath,required String imgName}) async {
  // رابط API مع مفتاح الـ API الخاص بك
  final url = Uri.parse(
    "https://api.imgbb.com/1/upload?key=cda5c21adbc105527504ff7354a72870",
  );

  // تجهيز الطلب
  final request = http.MultipartRequest("POST", url);
  request.files.add(
    http.MultipartFile.fromBytes('image', imgpath, filename: imgName),
  );

  // إرسال الطلب
  final response = await request.send();

  // قراءة الرد
  final resString = await response.stream.bytesToString();
  final jsonResponse = jsonDecode(resString);

  if (response.statusCode == 200) {
    String imageUrl = jsonResponse['data']['url'];
    return imageUrl;
  } else {
    throw Exception("Image upload failed: ${jsonResponse['error']['message']}");
  }
}

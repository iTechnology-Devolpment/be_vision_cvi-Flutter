import 'package:flutter/material.dart';

class AboutProjectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(
          'عن المشروع',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Cairo',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Text(
            'لوريم ايبسوم هو نموذج افتراضي يوضع في التصاميم لتعرض على العميل ليتصور طريقه وضع النصوص بالتصميم سواء كانت تصاميم مطبوعة أو نماذج مواقع انترنت. يستخدم مصممو الصفحات والمواقع النصوص كعنصر نصي شكلي (يعني نص غير حقيقي) لملء الصفحات لتحديد الأماكن التي سيظهر فيها النص الحقيقي. ويقول البعض أن استخدام لوريم ايبسوم قد يشوش المشاهد عن التركيز على وضعية النص أو حروفه، بينما يرى آخرون أن استخدامه يعطي انطباعاً جيداً عن الشكل العام للتصميم.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontFamily: 'Cairo',
              height: 1.6,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }
}

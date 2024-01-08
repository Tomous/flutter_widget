import 'dart:typed_data';

import 'package:date_format/date_format.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_widget/other/constants/constants.dart';
import 'package:get/get.dart';
import 'package:hand_signature/signature.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  Uint8List? _signatureImage;
  final RxString _signatureTime = ''.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('承诺签约'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  '承诺签署',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.text2,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 250,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9.0),
                  border: Border.all(
                    color: AppColors.text6.withAlpha(80),
                    width: 1,
                  ),
                ),
                //RawScrollbar--侧边显示一个原始滚动条
                child: RawScrollbar(
                  radius: const Radius.circular(6),
                  thumbColor: AppColors.text6.withAlpha(100),
                  crossAxisMargin: 3,
                  thickness: 3,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        StorageKeys.SIGNATUREFILE,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: AppColors.text3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Text(
                  '承诺签署人：',
                  style: TextStyle(
                    color: AppColors.text4,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 10),
              //边框
              DottedBorder(
                borderType: BorderType.RRect,
                color: AppColors.text6.withAlpha(100),
                radius: const Radius.circular(8.0),
                child: InkWell(
                  child: SizedBox(
                    height: 110.0,
                    child: _signatureImage != null
                        ? Image.memory(
                            _signatureImage!,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Center(
                            child: Text(
                              '点击签名',
                              style: TextStyle(
                                fontSize: 30,
                                color: AppColors.text6.withAlpha(70),
                              ),
                            ),
                          ),
                  ),
                  onTap: () async {
                    var result = await Get.to(const SignatureDrawPage());
                    print("result: $result");
                    if (result == null) return;
                    setState(() {
                      _signatureImage = result.buffer.asUint8List();
                    });
                    _signatureTime.value = formatDate(
                      DateTime.now(),
                      [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss],
                    );
                  },
                ),
              ),
              const Divider(height: 20),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => Text(
                    '签署时间：${_signatureTime.value}',
                    style: TextStyle(
                      color: AppColors.text4,
                    ),
                  ),
                ),
              ),
              const Divider(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  onPressed: () => EasyLoading.showToast('点击了提交按钮'),
                  child: const Text('提交审核'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///签字页面
class SignatureDrawPage extends StatefulWidget {
  const SignatureDrawPage({super.key});

  @override
  State<SignatureDrawPage> createState() => _SignatureDrawPageState();
}

class _SignatureDrawPageState extends State<SignatureDrawPage> {
  final control = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: RotatedBox(
          quarterTurns: 45,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                      iconSize: 20,
                    ),
                    const Text('签署合约'),
                  ],
                ),
                Expanded(
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    color: AppColors.text6.withAlpha(150),
                    strokeWidth: 1,
                    radius: const Radius.circular(10),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '签名区',
                            style: TextStyle(
                              fontSize: 70,
                              color: AppColors.text6.withAlpha(60),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: HandSignature(
                            control: control,
                            color: Colors.black,
                            width: 1,
                            maxWidth: 10,
                            type: SignatureDrawType.shape,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                        ),
                        child: const Text('确定'),
                        onPressed: () {
                          final png = control.toImage();
                          Get.back(result: png);
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 150,
                      child: OutlinedButton(
                        onPressed: () {
                          control.clear();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: const Text('重签'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

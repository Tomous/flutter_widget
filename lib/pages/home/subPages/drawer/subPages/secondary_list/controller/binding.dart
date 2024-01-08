import 'package:flutter_widget/pages/home/subPages/drawer/subPages/secondary_list/controller/secondary_controller.dart';
import 'package:get/get.dart';

class SecondaryBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SecondaryListController>(() => SecondaryListController());
  }
}

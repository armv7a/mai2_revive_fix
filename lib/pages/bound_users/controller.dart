import 'dart:math';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:mai2_revive/pages/bound_users/view.dart';
import 'package:mai2_revive/providers/storage_provider.dart';
import 'package:oktoast/oktoast.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../common/qr_code.dart';
import '../../components/loading_dialog/controller.dart';
import '../../models/user.dart';
import '../../providers/chime_provider.dart';
import '../../providers/mai2_provider.dart';
import 'repository.dart';

class BoundUsersController extends GetxController {
  late EasyRefreshController refreshController;
  final BoundUsersRepository repository = BoundUsersRepository();

  TextEditingController qrCodeController = TextEditingController();
  TextEditingController starttime = TextEditingController();

  final RxList _boundUsers = [].obs;
  List get boundUsers => _boundUsers;

  final RxBool _binding = false.obs;
  bool get binding => _binding.value;
  set binding(bool value) => _binding.value = value;

  var isCancelling = false.obs; // 用于跟踪取消操作的状态

  @override
  void onInit() {
    super.onInit();

    refreshController = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );

    refreshData();
  }

  Future<void> refreshData() async {
    List<UserModel> users = StorageProvider.userList.get();
    if (users.isEmpty) {
      refreshController.finishRefresh(IndicatorResult.noMore);
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((Duration callback) {
      _boundUsers.assignAll(users);
    });

    refreshController.finishRefresh(IndicatorResult.success);
  }

  Future<TaskResult> bindUser() async {
    String rawQrCode = qrCodeController.text;
    ChimeQrCode qrCode = ChimeQrCode(rawQrCode);

    String message = "";

    if (!qrCode.valid) {
      message = '无效的二维码';
      return TaskResult(
        success: false,
        message: message,
      );
    }

    String chipId = "A63E-01E${Random().nextInt(999999999).toString().padLeft(8, '0')}";

    int userID = await ChimeProvider.getUserId(
      chipId: chipId,
      timestamp: qrCode.timestamp,
      qrCode: qrCode.qrCode,
    ).then((value) {
      if (value.success) {
        return value.data;
      } else {
        message = "获取用户ID失败：${value.message}";
        return -1;
      }
    });

    if (userID == -1) {
      showToast(message);
      return TaskResult(
        success: false,
        message: message,
      );
    }

    UserModel user = await Mai2Provider.getUserPreview(userID: userID).then((value) {
      if (value.success) {
        return value.data!;
      } else {
        message = "获取用户信息失败：${value.message}";
        return UserModel(
          userId: -1,
          userName: "未知",
        );
      }
    });

    if (user.userId == -1) {
      showToast(message);
      return TaskResult(
        success: false,
        message: message,
      );
    }

    await StorageProvider.userList.add(user);

    await refreshData();

    return TaskResult(
      success: true,
      message: "绑定用户成功：${user.userName}",
    );
  }

  void unbindUser(int userId) async {
    await StorageProvider.userList.deleteWhere((item) => item.userId == userId);
    await refreshData();
  }

  void logout(int userId, String startTime) async {
    isCancelling.value = false; // 重置取消状态
    Get.dialog(
      ProgressDialog(
        progressStream: _logoutWithProgress(userId, startTime),
        onCancel: () {
          isCancelling.value = true;
          Get.back(); // 关闭对话框
          WakelockPlus.disable(); // 禁用 Wakelock 允许屏幕熄屏
        },
      ),
      barrierDismissible: false,
    );
  }

  Stream<String> _logoutWithProgress(int userId, String startTime) async* {
    WakelockPlus.enable(); // 启用 Wakelock 保持屏幕常亮

    await for (var response in Mai2Provider.logout(userId, startTime, isCancelling)) {
      yield response.message;
      if (response.success) {
        yield response.message;
        WakelockPlus.disable(); // 禁用 Wakelock 允许屏幕熄屏
        return;
      }
    }
  }

  Future<void> bindDivingToken(int userId, String token) async {
    // 获取用户列表并找到对应用户
    var userList = StorageProvider.userList.get();
    var user = userList.firstWhere(
          (u) => u.userId == userId,
      orElse: () => UserModel(userId: userId, userName: "未知"),
    );

    // 更新用户的 Token
    user.divingtoken = token;

    // 保存更新后的用户列表
    await StorageProvider.userList.updateWhere((u) => u.userId == userId, user);

    // 提示绑定成功
    showToast("Token 绑定成功");
  }
}

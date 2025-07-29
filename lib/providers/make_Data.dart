import '../common/response.dart';
import 'mai2_GetData.dart';

class Mai2MakeData {
  static Future<CommonResponse<Map<String, dynamic>>> MakeData({
    required int userID,
    required String logintime,
    required int datetime,
  }) async {
    final getDataResponse = await Mai2Getdata.GetData(userID: userID);

    if (!getDataResponse.success) {
      return CommonResponse(success: false, data: {}, message: "获取数据失败: ${getDataResponse.message}");
    }

    Map<String, dynamic> originalData = getDataResponse.data;

    // 在这里对数据进行重构和添加新内容
    Map<String, dynamic> reorderedData = _reorderData(originalData, logintime, datetime);

    return CommonResponse(success: true, data: reorderedData, message: "数据重构成功");
  }

  static Map<String, dynamic> _reorderData(Map<String, dynamic> data, String logintime, int datetime) {
    Map<String, dynamic> reorderedData = {
      'accessCode': "",
      'userName': data['userName'],
      'isNetMember': data['isNetMember'],
      'iconId': data['iconId'],
      'plateId': data['plateId'],
      'titleId': data['titleId'],
      'partnerId': data['partnerId'],
      'frameId': data['frameId'],
      'selectMapId': data['selectMapId'],
      'totalAwake': data['totalAwake'],
      'gradeRating': data['gradeRating'],
      'musicRating': data['musicRating'],
      'playerRating': data['playerRating'],
      'highestRating': data['highestRating'],
      'gradeRank': data['gradeRank'],
      'classRank': data['classRank'],
      'courseRank': data['courseRank'],
      'charaSlot': data['charaSlot'],
      'charaLockSlot': data['charaLockSlot'],
      'contentBit': data['contentBit'],
      'playCount': data['playCount'],
      'currentPlayCount': data['currentPlayCount'],
      'renameCredit': data['renameCredit'],
      'mapStock': data['mapStock'],
      'eventWatchedDate': logintime,
      'lastGameId': data['lastGameId'],
      'lastRomVersion': data['lastRomVersion'],
      'lastDataVersion': data['lastDataVersion'],
      'lastLoginDate': logintime,
      'lastPlayDate': DateTime.now(),
      'lastPlayCredit': data['lastPlayCredit'],
      'lastPlayMode': 0,
      'lastPlaceId': 1545,
      'lastPlaceName': "风云再起成都凯德店",
      'lastAllNetId': data['lastAllNetId'],
      'lastRegionId': 24,
      'lastRegionName': "四川",
      'lastClientId': "A63E01C2626",
      'lastCountryCode': "CHN",
      'lastSelectEMoney': data['lastSelectEMoney'],
      'lastSelectTicket': 0,
      'lastSelectCourse': data['lastSelectCourse'],
      'lastCountCourse': data['lastCountCourse'],
      'firstGameId': data['firstGameId'],
      'firstRomVersion': data['firstRomVersion'],
      'firstDataVersion': data['firstDataVersion'],
      'firstPlayDate': data['firstPlayDate'],
      'compatibleCmVersion': data['compatibleCmVersion'],
      'dailyBonusDate': data['dailyBonusDate'],
      'dailyCourseBonusDate': data['dailyCourseBonusDate'],
      'lastPairLoginDate': data['lastPairLoginDate'],
      'lastTrialPlayDate': data['lastTrialPlayDate'],
      'playVsCount': 0,
      'playSyncCount': 0,
      'winCount': 0,
      'helpCount': 0,
      'comboCount': 0,
      'totalDeluxscore': data['totalDeluxscore'],
      'totalBasicDeluxscore': data['totalBasicDeluxscore'],
      'totalAdvancedDeluxscore': data['totalAdvancedDeluxscore'],
      'totalExpertDeluxscore': data['totalExpertDeluxscore'],
      'totalMasterDeluxscore': data['totalMasterDeluxscore'],
      'totalReMasterDeluxscore': data['totalReMasterDeluxscore'],
      'totalSync': data['totalSync'],
      'totalBasicSync': data['totalBasicSync'],
      'totalAdvancedSync': data['totalAdvancedSync'],
      'totalExpertSync': data['totalExpertSync'],
      'totalMasterSync': data['totalMasterSync'],
      'totalReMasterSync': data['totalReMasterSync'],
      'totalAchievement': data['totalAchievement'],
      'totalBasicAchievement': data['totalBasicAchievement'],
      'totalAdvancedAchievement': data['totalAdvancedAchievement'],
      'totalExpertAchievement': data['totalExpertAchievement'],
      'totalMasterAchievement': data['totalMasterAchievement'],
      'totalReMasterAchievement': data['totalReMasterAchievement'],
      'playerOldRating': data['playerOldRating'],
      'playerNewRating': data['playerNewRating'],
      'banState': 0,
      'dateTime': datetime,
    };

    return reorderedData;
  }
}

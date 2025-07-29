import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../providers/lxns_GetSongJacket.dart';
import '../../providers/lxns_UpdataMusicList.dart';

class RandomPage extends StatefulWidget {
  @override
  _RandomPageState createState() => _RandomPageState();
}

class _RandomPageState extends State<RandomPage> {
  late Future<Map<String, dynamic>> songFuture;
  Uint8List? songJacket;

  @override
  void initState() {
    super.initState();
    songFuture = _getRandomSong();
  }

  Future<Map<String, dynamic>> _getRandomSong() async {
    final contents = await rootBundle.loadString('assets/MusicList.json');
    final jsonData = jsonDecode(contents);
    final songs = jsonData['songs'] as List<dynamic>;
    final random = Random();
    final randomSong = songs[random.nextInt(songs.length)];

    final versions = jsonData['versions'] as List<dynamic>;
    final version = versions.firstWhere((v) => v['version'] == randomSong['version'], orElse: () => {'title': '未知版本'});
    final versionTitle = version['title'];

    randomSong['versionTitle'] = versionTitle;

    // 获取封面图片
    final jacket = await LxnsGetsongjacket.getSongJacket(musicID: randomSong['id']);
    songJacket = jacket;

    return randomSong;
  }

  String getDifficultyName(int difficulty) {
    switch (difficulty) {
      case 0:
        return "BASIC";
      case 1:
        return "ADVANCED";
      case 2:
        return "EXPERT";
      case 3:
        return "MASTER";
      case 4:
        return "Re.MASTER";
      default:
        return "未知";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('随机乐曲'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: () {
              _showUpdateDialog();
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: songFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("获取失败: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final song = snapshot.data!;
            final title = song['title'] as String;
            final artist = song['artist'] as String;
            final genre = song['genre'] as String;
            final bpm = song['bpm'] as int;
            final versionTitle = song['versionTitle'] as String;

            final standardDifficulties = song['difficulties']['standard'] as List<dynamic>;
            final dxDifficulties = song['difficulties']['dx'] as List<dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (songJacket != null)
                    Center(
                      child: Image.memory(
                        songJacket!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(height: 16),
                  Text('$title', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('作者: $artist'),
                  SizedBox(height: 8),
                  Text('流派: $genre'),
                  SizedBox(height: 8),
                  Text('BPM: $bpm'),
                  SizedBox(height: 8),
                  Text('版本: $versionTitle'),
                  SizedBox(height: 16),
                  if (standardDifficulties.isNotEmpty) ...[
                    Text('标准谱面:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ...standardDifficulties.map((difficulty) => ListTile(
                      title: Text('难度: ${getDifficultyName(difficulty['difficulty'])}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('等级: ${difficulty['level']}'),
                          Text('定数: ${difficulty['level_value']}'),
                          Text('谱师: ${difficulty['note_designer']}'),
                        ],
                      ),
                    )),
                  ],
                  if (dxDifficulties.isNotEmpty) ...[
                    Text('DX谱面:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ...dxDifficulties.map((difficulty) => ListTile(
                      title: Text('难度: ${getDifficultyName(difficulty['difficulty'])}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('等级: ${difficulty['level']}'),
                          Text('定数: ${difficulty['level_value']}'),
                          Text('谱师: ${difficulty['note_designer']}'),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            );
          } else {
            return Center(child: Text("未能获取到数据"));
          }
        },
      ),
    );
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: LxnsUpdatamusiclist.updateMusicList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text('更新数据中'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在更新数据，请稍候...'),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text('错误'),
                content: Text('更新数据失败: ${snapshot.error}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('确定'),
                  ),
                ],
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              if (data.containsKey('error')) {
                return AlertDialog(
                  title: Text('错误'),
                  content: Text('更新数据失败: ${data['error']}'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('确定'),
                    ),
                  ],
                );
              } else {
                return AlertDialog(
                  title: Text('更新完成'),
                  content: Text('从落雪查分器更新乐曲信息成功'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          songFuture = _getRandomSong(); // 更新数据后重新加载随机歌曲
                        });
                      },
                      child: Text('确定'),
                    ),
                  ],
                );
              }
            } else {
              return AlertDialog(
                title: Text('未知错误'),
                content: Text('更新数据时发生未知错误'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('确定'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }
}

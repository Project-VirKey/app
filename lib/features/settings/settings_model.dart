// To parse this JSON data, do
//
//     final settings = settingsFromJson(jsonString);

import 'dart:convert';

Settings settingsFromJson(String str) => Settings.fromJson(json.decode(str));

String settingsToJson(Settings data) => json.encode(data.toJson());

class Settings {
  Settings({
    required this.audioVolume,
    required this.defaultFolder,
    required this.defaultSavedFiles,
    required this.soundLibraries,
    required this.lastUpdated,
  });

  AudioVolume audioVolume;
  DefaultFolder defaultFolder;
  DefaultSavedFiles defaultSavedFiles;
  List<SoundLibrary> soundLibraries;
  int lastUpdated;

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
      audioVolume: AudioVolume.fromJson(json["audioVolume"]),
      defaultFolder: DefaultFolder.fromJson(json["defaultFolder"]),
      defaultSavedFiles: DefaultSavedFiles.fromJson(json["defaultSavedFiles"]),
      soundLibraries: List<SoundLibrary>.from(
          json["soundLibraries"].map((x) => SoundLibrary.fromJson(x))),
      lastUpdated: json["lastUpdated"]);

  Map<String, dynamic> toJson() => {
        "audioVolume": audioVolume.toJson(),
        "defaultFolder": defaultFolder.toJson(),
        "defaultSavedFiles": defaultSavedFiles.toJson(),
        "soundLibraries":
            List<dynamic>.from(soundLibraries.map((x) => x.toJson())),
        "lastUpdated": lastUpdated
      };
}

class AudioVolume {
  AudioVolume({
    required this.soundLibrary,
    required this.audioPlayback,
  });

  int soundLibrary;
  int audioPlayback;

  factory AudioVolume.fromJson(Map<String, dynamic> json) => AudioVolume(
        soundLibrary: json["soundLibrary"],
        audioPlayback: json["audioPlayback"],
      );

  Map<String, dynamic> toJson() => {
        "soundLibrary": soundLibrary,
        "audioPlayback": audioPlayback,
      };
}

class DefaultFolder {
  DefaultFolder({
    required this.path,
  });

  String path;

  factory DefaultFolder.fromJson(Map<String, dynamic> json) => DefaultFolder(
        path: json["path"],
      );

  Map<String, dynamic> toJson() => {
        "path": path,
      };
}

class DefaultSavedFiles {
  DefaultSavedFiles({
    required this.mp3,
    required this.mp3AndPlayback,
  });

  bool mp3;
  bool mp3AndPlayback;

  factory DefaultSavedFiles.fromJson(Map<String, dynamic> json) =>
      DefaultSavedFiles(
        mp3: json["mp3"],
        mp3AndPlayback: json["mp3AndPlayback"],
      );

  Map<String, dynamic> toJson() => {
        "mp3": mp3,
        "mp3AndPlayback": mp3AndPlayback,
      };
}

class SoundLibrary {
  SoundLibrary({
    required this.name,
    required this.selected,
    required this.path,
    required this.url,
    required this.defaultLibrary,
  });

  String name;
  bool selected;
  String path;
  String url;
  bool defaultLibrary;

  factory SoundLibrary.fromJson(Map<String, dynamic> json) => SoundLibrary(
        name: json["name"],
        selected: json["selected"],
        path: json["path"],
        url: json["url"],
        defaultLibrary: json["defaultLibrary"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "selected": selected,
        "path": path,
        "url": url,
        "defaultLibrary": defaultLibrary,
      };
}

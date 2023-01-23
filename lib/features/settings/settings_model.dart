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
  });

  AudioVolume audioVolume;
  DefaultFolder defaultFolder;
  DefaultSavedFiles defaultSavedFiles;
  List<SoundLibrary> soundLibraries;

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
      audioVolume: AudioVolume.fromJson(json["audioVolume"]),
      defaultFolder: DefaultFolder.fromJson(json["defaultFolder"]),
      defaultSavedFiles: DefaultSavedFiles.fromJson(json["defaultSavedFiles"]),
      soundLibraries: List<SoundLibrary>.from(
          json["soundLibraries"].map((x) => SoundLibrary.fromJson(x))));

  Map<String, dynamic> toJson() => {
        "audioVolume": audioVolume.toJson(),
        "defaultFolder": defaultFolder.toJson(),
        "defaultSavedFiles": defaultSavedFiles.toJson(),
        "soundLibraries":
            List<dynamic>.from(soundLibraries.map((x) => x.toJson())),
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
    required this.wav,
    required this.wavAndPlayback,
  });

  bool wav;
  bool wavAndPlayback;

  factory DefaultSavedFiles.fromJson(Map<String, dynamic> json) =>
      DefaultSavedFiles(
        wav: json["wav"],
        wavAndPlayback: json["wavAndPlayback"],
      );

  Map<String, dynamic> toJson() => {
        "wav": wav,
        "wavAndPlayback": wavAndPlayback,
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

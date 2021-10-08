class ChatModel {
  final String name;
  final String message;
  final String time;
  final String avatarUrl;

  ChatModel({
    this.name,
    this.message,
    this.time,
    this.avatarUrl,
  });
}

List<ChatModel> dummyData = [
  ChatModel(
      name: "T.V.A Group",
      message: "We are TVA",
      time: "15:30",
      avatarUrl:
          "https://assets-prd.ignimgs.com/2021/06/09/loki-tva-time-keepers-1623262018516.jpg"),
  ChatModel(
      name: "Stark Industries Group",
      message: "I am Ironman!!!, snap",
      time: "17:30",
      avatarUrl:
          "https://images.adsttc.com/media/images/5189/0777/b3fc/4b63/9d00/00bb/large_jpg/The-Avengers.jpg?1367934834"),
  ChatModel(
      name: "Wakanda Group",
      message: "Wakanda Forever!",
      time: "5:00",
      avatarUrl:
          "https://imgsrv2.voi.id/J7D-bVYa1dLYtu9zl0p3n4BpbOqd-5o0Qi1DEbdUpgE/auto/1200/675/sm/1/bG9jYWw6Ly8vcHVibGlzaGVycy85YzIxZTJhNy1kZDRkLTRkMDAtYmI5Yi1lZGNhNWZlYWZlZTAvMjAxOTEyMjIxMTA2LW1haW4uanBn.jpg"),
  ChatModel(
      name: "S.H.I.E.L.D",
      message: "There was an Idea...",
      time: "10:30",
      avatarUrl:
          "https://img.joomcdn.net/71e63d2f04fba7a7b52f7c9ca9d24501cea54b04_792_1024.jpeg"),
  ChatModel(
      name: "Star Labs",
      message: "I'm Flash and I know it!!!",
      time: "12:30",
      avatarUrl:
          "https://i.pinimg.com/originals/31/31/0a/31310af41fd3c505ad10403ff71f1208.jpg"),
  //  ChatModel(
  //     name: "Justice League",
  //     message: "Flash is the most OPP character...",
  //     time: "15:30",
  //     avatarUrl:
  //         ""),
];

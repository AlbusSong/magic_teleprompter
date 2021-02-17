typedef GetObjectFunction = Function(dynamic object);

class NotificationCenter {
  // 工厂模式
  factory NotificationCenter() => _getInstance();

  static NotificationCenter get instance => _getInstance();
  static NotificationCenter _instance;

  NotificationCenter._internal() {
    // 初始化
  }

  static NotificationCenter _getInstance() {
    if (_instance == null) {
      _instance = new NotificationCenter._internal();
    }
    return _instance;
  }

  //创建Map来记录名称
  Map<String, dynamic> postNameMap = Map<String, GetObjectFunction>();

  // GetObjectFunction getObjectFunc;

  //添加监听者方法
  addObserver(String postName, func(dynamic params)) {
    postNameMap[postName] = func;
    // getObjectFunc = func;
  }

  //发送通知传值
  postNotification(String postName, [dynamic obj]) {
    //检索Map是否含有postName
    if (postNameMap.containsKey(postName)) {
      GetObjectFunction func = postNameMap[postName];
      func(obj);
      // getObjectFunc(object);
    }
  }

  // 清除某个通知
  removeNotification(String postName) {
    if (postNameMap.containsKey(postName)) {
      postNameMap.remove(postName);
    }
  }

  // 清空
  clearAllNotifications() {
    postNameMap.clear();
  }
}

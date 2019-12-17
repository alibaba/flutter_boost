flutter attach


flutter build apk

flutter packages pub run build_runner watch
flutter packages pub run build_runner watch --delete-conflicting-outputs
flutter build ios --release
flutter attach --track-widget-creation

flutter packages get
flutter clean
flutter packages upgrade

distributionUrl=https\://services.gradle.org/distributions/gradle-5.2.1-all.zip
classpath 'com.android.tools.build:gradle:3.4.2'    



    header: ClassicalHeader(
      refreshText: '下拉刷新',
      refreshReadyText: '松开刷新',
      refreshingText: '刷新中',
      refreshedText: '刷新完成',
      refreshFailedText: '刷新失败',
      noMoreText: '没有更多数据了',
      infoText: '上次更新于 %T',
    ),
    footer: ClassicalFooter(
      loadText: '上拉加载更多',
      loadReadyText: '松开加载更多',
      loadingText: '加载中',
      loadedText: '加载完成',
      loadFailedText: '加载失败',
      noMoreText: '没有更多数据了',
      infoText: '上次更新于 %T',
    ),
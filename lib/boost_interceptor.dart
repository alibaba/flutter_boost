///BoostInterceptor
abstract class BoostInterceptor {
  ///The callback of BoostInterceptor for push new page method
  ///the result indicates wherther the page operation will be blocked,
  ///If you return true,nothing will happen,otherwise new page will push
  ///
  ///[argments] the arg for this push operaton,you can modify it
  ///[name] the name of the page you want to push
  Future<bool> onPush(Map<String, dynamic> arguments, String name);
}

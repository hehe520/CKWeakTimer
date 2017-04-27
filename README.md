# CKWeakTimer

不会发生循环引用的 timer，不对 controller 强引用，controller 退出，自动关闭释放，甚至 timer 的 block 内可以写 self，都能释放。

# 使用方法

把项目 demo 中的 CkWeakTimer.h 和 CkWeakTimer.m 文件拖进项目中即可使用。

方法名完全模仿 NSTimer，几乎不用修改代码，只需简单的字符串替换，把 NSTimer 替换为 CKWeakTimer 即可。

原理详见简书博客 http://www.jianshu.com/p/bb691938fb2f

只实现了 NSTimer 的常用方法，不常用的暂时没实现。有需要可以发邮件给我加上。

bug 反馈邮箱：657668857@qq.com 


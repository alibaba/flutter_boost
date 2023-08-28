
<p align="center">
  <img src="flutter_boost.png">
   <b></b><br>
  <a href="README_CN.md">中文文档</a>
  <a href="https://zhuanlan.zhihu.com/p/362662962">中文介绍</a>
</p>

# Sürüm Notları
## 4.4.0

Not: Null güvenliği zaten desteklenmektedir.

- 1. Flutter SDK güncellemeleri Boost güncellemelerini gerektirmez.
- 2. Mimarisi basitleştirildi.
- 3. Arayüzü basitleştirildi.
- 4. Çift uçlu arayüz tasarımı birleştirildi.
- 5. En Üst Sıkıntı çözüldü.
- 6. Android için AndroidX ve Support ayrımına gerek yok
# FlutterBoost
Bir sonraki nesil Flutter-Native hibrit çözümü. FlutterBoost, mevcut yerel uygulamalarınıza minimum çaba ile Flutter'ın hibrit entegrasyonunu sağlayan bir Flutter eklentisidir. FlutterBoost'un felsefesi, Flutter'ı bir WebView kullanır gibi kolay kullanmaktır. Mevcut bir Uygulamada yerel sayfaları ve Flutter sayfalarını aynı anda yönetmek kolay değildir. FlutterBoost, sayfa çözümünü sizin için halleder. Tek dikkat etmeniz gereken şey, sayfanın adıdır (genellikle bir URL olabilir).

# Önkoşullar

1. İlerlemeye geçmeden önce, Flutter'ı mevcut projenize entegre etmeniz gerekmektedir.
2. Boost 3.0 tarafından desteklenen Flutter SDK sürümü >= 1.22'dir.

> Flutter SDK sürümü desteği:
>1. Flutter SDK 3.0 ve üstü, `4.0.1`'den büyük bir sürüm kullanın.
>2. Flutter SDK 3.0 veya altı, `v3.0-release.2` veya altını kullanın.
>3. Flutter SDK 2.5.x'i destekleyen null güvenli sürümü `3.1.x`'dir.

# Başlarken

## Flutter projenize bir bağımlılık ekleyin.

pubspec.yaml dosyanızı açın ve aşağıdaki satırı dependencies bölümüne ekleyin:

```yaml
flutter_boost:
    git:
        url: 'https://github.com/alibaba/flutter_boost.git'
        ref: '4.4.0'
```

# Boost Entegrasyonu

# Kullanım Dokümantasyonu

- [Detaylı Entegrasyon Adımları](https://github.com/alibaba/flutter_boost/blob/master/docs/install.md)
- [Temel Rota API'ları](https://github.com/alibaba/flutter_boost/blob/master/docs/routeAPI.md)
- [Sayfa Yaşam Döngüsü İzleme İlgili API'lar](https://github.com/alibaba/flutter_boost/blob/master/docs/lifecycle.md)
- [Özel Çapraz Platform Etkinlikleri Gönderme API'ları](https://github.com/alibaba/flutter_boost/blob/master/docs/event.md)

# Geliştirme Dokümantasyonu
- [Bize Nasıl Sorun Bildireceğiniz](https://github.com/alibaba/flutter_boost/blob/master/docs/issue.md)
- [Bize Nasıl Pull Request Göndereceğiniz](https://github.com/alibaba/flutter_boost/blob/master/docs/pr.md)

# Sıkça Sorulan Sorular
Lütfen bu belgeyi okuyun:
<a href="Sıkça Sorulan Sorular.md">SSS</a>

# Lisans
Bu proje MIT Lisansı altında lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın

## Biz Kimiz

Alibaba-Xianyu Teknoloji, Çin'deki en eski ve en büyük ölçekte Flutter'ı çevrimiçi çalıştıran ekiptir.

Biz sizin için Flutter'a özel seçilmiş içerikler sunuyoruz, kapsamlı ve derinlemesine.

İçerikler arasında: Flutter entegrasyonu, ölçeklendirilmiş uygulamalar, motorun iç yüzü, mühendislik sistemleri, yenilikçi teknolojiler ve daha fazlasıyla ilgili eğitimler ve açık kaynak bilgiler bulunuyor.

**Mimari/Sunucu/İstemci/Ön Yüz/Algoritma/Kalite Mühendisleri, başvurularınızı gönderebilirler. Kontenjan sınırlaması yok.**

Siz de meraklı, mutlu ve etkili bir geliştirici olarak Alibaba'ya gelmeye davetlisiniz. Özgeçmişlerinizi gönderin: tino.wjf@alibaba-inc.com

Abonelik Adresi

<img src="https://img.alicdn.com/tfs/TB17Ki5XubviK0jSZFNXXaApXXa-656-656.png" width="328px" height="328px">

[İngilizce İçin](https://twitter.com/xianyutech "İngilizce İçin")
```


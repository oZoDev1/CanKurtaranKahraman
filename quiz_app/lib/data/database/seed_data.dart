import 'package:sqflite/sqflite.dart';

class SeedData {
  static Future<void> insertInitialData(Database db) async {
    // ===== 4 MODÜL =====
    await db.insert('quiz_groups', {
      'title': 'Koruma – Bildirme – Kurtarma',
      'description': 'KBK basamakları ile ilgili sorular.',
      'total_questions': 2
    });
    await db.insert('quiz_groups', {
      'title': 'İlk Yardımcının Özellikleri ve 112\'ye Verilecek Bilgiler',
      'description': 'Doğru/yanlış soruları.',
      'total_questions': 20
    });
    await db.insert('quiz_groups', {
      'title': 'Temel İlk Yardım Tanımları ve Kavramları',
      'description': 'Test soruları.',
      'total_questions': 10
    });
    await db.insert('quiz_groups', {
      'title': 'Hayat Kurtarma Zincirinin 5 Basamağı',
      'description': 'Sıralama sorusu.',
      'total_questions': 1
    });

    // ==========================================
    // MODÜL 1: Koruma – Bildirme – Kurtarma (2 soru)
    // ==========================================

    // 1. Sıralama sorusu
    await db.insert('questions', {
      'type': 'ordering',
      'question_text': 'İlk yardımın temel ilkesi olan KBK basamaklarını doğru sırayla diziniz.',
      'explanation': 'KBK sıralaması, ilk yardımda güvenli ve sistemli hareket etmeyi sağlar.',
      'quiz_group_id': 1,
      'order_in_quiz': 1
    });
    await db.insert('ordering_items', {'question_id': 1, 'item_text': 'Koruma', 'drag_image_path': null, 'drop_image_path': null, 'correct_order': 1});
    await db.insert('ordering_items', {'question_id': 1, 'item_text': 'Bildirme', 'drag_image_path': null, 'drop_image_path': null, 'correct_order': 2});
    await db.insert('ordering_items', {'question_id': 1, 'item_text': 'Kurtarma', 'drag_image_path': null, 'drop_image_path': null, 'correct_order': 3});

    // 2. Test sorusu
    await db.insert('questions', {
      'type': 'test',
      'question_text': 'Bir öğrenci okul bahçesinde düşmüş ve yerde yatmaktadır. İlk yardım yaklaşımında yapılması gereken temel basamaklar hangi sırayla uygulanmalıdır?',
      'explanation': 'İlk yardımda önce olay yerinin ve ilk yardımcı kişinin güvenliği sağlanır. Ardından gerekli birimlere haber verilir ve güvenli koşullarda yardım süreci başlatılır.',
      'quiz_group_id': 1,
      'order_in_quiz': 2
    });
    await db.insert('options', {'question_id': 2, 'option_text': 'Kurtarma - Bildirme - Koruma', 'is_correct': 0});
    await db.insert('options', {'question_id': 2, 'option_text': 'Koruma - Bildirme - Kurtarma', 'is_correct': 1});
    await db.insert('options', {'question_id': 2, 'option_text': 'Bildirme - Kurtarma - Koruma', 'is_correct': 0});
    await db.insert('options', {'question_id': 2, 'option_text': 'Koruma - Kurtarma - Bildirme', 'is_correct': 0});

    // ==========================================
    // MODÜL 2: Doğru/Yanlış Soruları (20 soru)
    // ==========================================

    // --- İlk Yardımcının Özellikleri ---
    await db.insert('questions', {'type': 'true_false', 'question_text': 'İlk Yardımcının Özellikleri | İlk yardımcı sakin ve dikkatli olmalıdır.', 'correct_answer_bool': 1, 'explanation': 'İlk yardımcı paniği azaltmalı ve kontrollü hareket etmelidir.', 'quiz_group_id': 2, 'order_in_quiz': 3});
    await db.insert('questions', {'type': 'true_false', 'question_text': 'İlk Yardımcının Özellikleri | İlk yardımcı olay yerinde kendi güvenliğini önemsememelidir.', 'correct_answer_bool': 0, 'explanation': 'İlk yardımda önce yardım eden kişinin ve çevrenin güvenliği sağlanır.', 'quiz_group_id': 2, 'order_in_quiz': 4});
    await db.insert('questions', {'type': 'true_false', 'question_text': 'İlk Yardımcının Özellikleri | İlk yardımcı hasta/yaralıyı gereksiz yere hareket ettirmemelidir.', 'correct_answer_bool': 1, 'explanation': 'Gereksiz hareket ettirme yaralanmayı artırabilir.', 'quiz_group_id': 2, 'order_in_quiz': 5});
    await db.insert('questions', {'type': 'true_false', 'question_text': 'İlk Yardımcının Özellikleri | İlk yardımcı bilmediği uygulamaları denemelidir.', 'correct_answer_bool': 0, 'explanation': 'İlk yardımcı yalnızca bildiği ve güvenli uygulamaları yapmalıdır.', 'quiz_group_id': 2, 'order_in_quiz': 6});
    await db.insert('questions', {'type': 'true_false', 'question_text': 'İlk Yardımcının Özellikleri | İlk yardımcı çevredeki kişileri uygun şekilde yönlendirebilir.', 'correct_answer_bool': 1, 'explanation': 'Yardım çağırma ve kalabalığı düzenleme ilk yardım sürecini destekler.', 'quiz_group_id': 2, 'order_in_quiz': 7});
    await db.insert('questions', {'type': 'true_false', 'question_text': 'İlk Yardımcının Özellikleri | İlk yardımcı hasta/yaralıya doktor gibi tanı koymalıdır.', 'correct_answer_bool': 0, 'explanation': 'İlk yardım tanı koyma değil, güvenli ve temel yardım sağlama sürecidir.', 'quiz_group_id': 2, 'order_in_quiz': 8});
    await db.insert('questions', {'type': 'true_false', 'question_text': 'İlk Yardımcının Özellikleri | İlk yardımcı hızlı ama kontrollü davranmalıdır.', 'correct_answer_bool': 1, 'explanation': 'Aceleci ve bilinçsiz davranmak yerine doğru sıralama izlenmelidir.', 'quiz_group_id': 2, 'order_in_quiz': 9});
    await db.insert('questions', {'type': 'true_false', 'question_text': 'İlk Yardımcının Özellikleri | İlk yardımcı gizliliğe ve mahremiyete dikkat etmelidir.', 'correct_answer_bool': 1, 'explanation': 'Hasta/yaralının kişisel durumu başkalarıyla gereksiz paylaşılmamalıdır.', 'quiz_group_id': 2, 'order_in_quiz': 10});
    await db.insert('questions', {'type': 'true_false', 'question_text': 'İlk Yardımcının Özellikleri | İlk yardımcı kalabalığın panik yapmasını artırmalıdır.', 'correct_answer_bool': 0, 'explanation': 'İlk yardımcı sakinleştirici ve düzenleyici rol üstlenmelidir.', 'quiz_group_id': 2, 'order_in_quiz': 11});
    await db.insert('questions', {'type': 'true_false', 'question_text': 'İlk Yardımcının Özellikleri | İlk yardımcı hasta/yaralıyı sürekli izlemelidir.', 'correct_answer_bool': 1, 'explanation': 'Yardım gelene kadar durumdaki değişiklikler izlenmelidir.', 'quiz_group_id': 2, 'order_in_quiz': 12});

    // --- 112 Arandığında Verilmesi Gereken Bilgiler ---
    await db.insert('questions', {'type': 'true_false', 'question_text': '112 Arandığında Verilmesi Gereken Bilgiler | Olay yerinin açık adresi bildirilmelidir.', 'correct_answer_bool': 1, 'explanation': 'Ekiplerin hızlı ulaşabilmesi için açık adres önemlidir.', 'quiz_group_id': 2, 'order_in_quiz': 13});
    await db.insert('questions', {'type': 'true_false', 'question_text': '112 Arandığında Verilmesi Gereken Bilgiler | Yaralı veya hasta sayısı belirtilmelidir.', 'correct_answer_bool': 1, 'explanation': 'Olay yerine gönderilecek ekip ve araç planlaması için gereklidir.', 'quiz_group_id': 2, 'order_in_quiz': 14});
    await db.insert('questions', {'type': 'true_false', 'question_text': '112 Arandığında Verilmesi Gereken Bilgiler | Olayın ne olduğu kısaca açıklanmalıdır.', 'correct_answer_bool': 1, 'explanation': 'Kaza, bayılma, yanık, kanama gibi durumlar açıkça belirtilmelidir.', 'quiz_group_id': 2, 'order_in_quiz': 15});
    await db.insert('questions', {'type': 'true_false', 'question_text': '112 Arandığında Verilmesi Gereken Bilgiler | Telefon hemen kapatılmalıdır.', 'correct_answer_bool': 0, 'explanation': 'Görevli kapatmadan telefon kapatılmamalıdır.', 'quiz_group_id': 2, 'order_in_quiz': 16});
    await db.insert('questions', {'type': 'true_false', 'question_text': '112 Arandığında Verilmesi Gereken Bilgiler | Arayan kişi sakin ve anlaşılır konuşmalıdır.', 'correct_answer_bool': 1, 'explanation': 'Açık ve anlaşılır bilgi acil yardım sürecini hızlandırır.', 'quiz_group_id': 2, 'order_in_quiz': 17});
    await db.insert('questions', {'type': 'true_false', 'question_text': '112 Arandığında Verilmesi Gereken Bilgiler | Adres bilinmiyorsa çevredeki belirgin yerler söylenebilir.', 'correct_answer_bool': 1, 'explanation': 'Okul adı, cadde, bina, kapı numarası gibi bilgiler yardımcı olur.', 'quiz_group_id': 2, 'order_in_quiz': 18});
    await db.insert('questions', {'type': 'true_false', 'question_text': '112 Arandığında Verilmesi Gereken Bilgiler | Yaralının durumu hakkında tahmini ve abartılı bilgiler verilmelidir.', 'correct_answer_bool': 0, 'explanation': 'Bilgi doğru, kısa ve gözleme dayalı olmalıdır.', 'quiz_group_id': 2, 'order_in_quiz': 19});
    await db.insert('questions', {'type': 'true_false', 'question_text': '112 Arandığında Verilmesi Gereken Bilgiler | Olay yerindeki tehlikeler belirtilmelidir.', 'correct_answer_bool': 1, 'explanation': 'Yangın, elektrik, trafik gibi riskler ekip güvenliği için önemlidir.', 'quiz_group_id': 2, 'order_in_quiz': 20});
    await db.insert('questions', {'type': 'true_false', 'question_text': '112 Arandığında Verilmesi Gereken Bilgiler | 112\'ye gereksiz arama yapılabilir.', 'correct_answer_bool': 0, 'explanation': '112 yalnızca acil durumlar için aranmalıdır.', 'quiz_group_id': 2, 'order_in_quiz': 21});
    await db.insert('questions', {'type': 'true_false', 'question_text': '112 Arandığında Verilmesi Gereken Bilgiler | Görevlinin sorduğu sorular dikkatle yanıtlanmalıdır.', 'correct_answer_bool': 1, 'explanation': 'Sorular, doğru yardımın yönlendirilmesi için sorulur.', 'quiz_group_id': 2, 'order_in_quiz': 22});

    // ==========================================
    // MODÜL 3: Test Soruları (10 soru)
    // ==========================================

    await db.insert('questions', {'type': 'test', 'question_text': 'İlk yardım aşağıdakilerden hangisidir?', 'explanation': 'İlk yardım, sağlık ekibi gelinceye kadar mevcut imkânlarla yapılan, hayatı korumaya yönelik temel yardımdır.', 'quiz_group_id': 3, 'order_in_quiz': 23});
    await db.insert('options', {'question_id': 23, 'option_text': 'Hastaya ilaç vererek tedavi başlatma işlemidir.', 'is_correct': 0});
    await db.insert('options', {'question_id': 23, 'option_text': 'Ani hastalık veya yaralanmada, sağlık ekibi gelinceye kadar eldeki imkânlarla yapılan geçici ve doğru yardımdır.', 'is_correct': 1});
    await db.insert('options', {'question_id': 23, 'option_text': 'Hastayı mutlaka en yakın hastaneye taşıma işlemidir.', 'is_correct': 0});
    await db.insert('options', {'question_id': 23, 'option_text': 'Hastayı mutlaka en yakın hastaneye taşıma işlemidir.', 'is_correct': 0});

    await db.insert('questions', {'type': 'test', 'question_text': 'İlk yardımın öncelikli amacı aşağıdakilerden hangisidir?', 'explanation': 'İlk yardımın amacı yaşamı korumak, durumun kötüleşmesini önlemek ve iyileşmeyi kolaylaştırmaktır.', 'quiz_group_id': 3, 'order_in_quiz': 24});
    await db.insert('options', {'question_id': 24, 'option_text': 'Hasta/yaralıya ilaç vermek', 'is_correct': 0});
    await db.insert('options', {'question_id': 24, 'option_text': 'Olay yerini kalabalıklaştırmak', 'is_correct': 0});
    await db.insert('options', {'question_id': 24, 'option_text': 'Hayati tehlikeyi azaltmak ve durumun kötüleşmesini önlemek', 'is_correct': 1});
    await db.insert('options', {'question_id': 24, 'option_text': 'Hasta/yaralıyı hızlıca ayağa kaldırmak', 'is_correct': 0});

    await db.insert('questions', {'type': 'test', 'question_text': 'Olay yeri güvenliği ne anlama gelir?', 'explanation': 'Olay yeri güvenliği, ilk yardım sürecinin ilk ve en önemli adımlarından biridir.', 'quiz_group_id': 3, 'order_in_quiz': 25});
    await db.insert('options', {'question_id': 25, 'option_text': 'Sadece yaralının konuşup konuşmadığını kontrol etmek', 'is_correct': 0});
    await db.insert('options', {'question_id': 25, 'option_text': 'Olay yerinde ilk yardımcı, yaralı ve çevredekiler için risk olup olmadığını değerlendirmek', 'is_correct': 1});
    await db.insert('options', {'question_id': 25, 'option_text': 'Yaralıyı hemen hareket ettirmek', 'is_correct': 0});
    await db.insert('options', {'question_id': 25, 'option_text': 'Olay yerinden uzaklaşmak', 'is_correct': 0});

    await db.insert('questions', {'type': 'test', 'question_text': 'Aşağıdakilerden hangisi bilinç değerlendirmesine örnektir?', 'explanation': 'Bilinç değerlendirmesinde kişiye seslenilir ve tepki verip vermediği gözlenir.', 'quiz_group_id': 3, 'order_in_quiz': 26});
    await db.insert('options', {'question_id': 26, 'option_text': 'Kişiye seslenmek ve yanıt verip vermediğini kontrol etmek', 'is_correct': 1});
    await db.insert('options', {'question_id': 26, 'option_text': 'Kişiye su içirmek', 'is_correct': 0});
    await db.insert('options', {'question_id': 26, 'option_text': 'Kişiyi hemen ayağa kaldırmak', 'is_correct': 0});
    await db.insert('options', {'question_id': 26, 'option_text': 'Kişinin eşyalarını toplamak', 'is_correct': 0});

    await db.insert('questions', {'type': 'test', 'question_text': 'Hasta/yaralıda solunum değerlendirmesi yapılırken temel amaç nedir?', 'explanation': 'Solunum değerlendirmesi, kişinin nefes alıp almadığını belirlemek için yapılır.', 'quiz_group_id': 3, 'order_in_quiz': 27});
    await db.insert('options', {'question_id': 27, 'option_text': 'Kişinin konuşma hızını ölçmek', 'is_correct': 0});
    await db.insert('options', {'question_id': 27, 'option_text': 'Kişinin nefes alıp almadığını anlamak', 'is_correct': 1});
    await db.insert('options', {'question_id': 27, 'option_text': 'Kişinin yürüyüp yürüyemediğini görmek', 'is_correct': 0});
    await db.insert('options', {'question_id': 27, 'option_text': 'Kişinin aç olup olmadığını öğrenmek', 'is_correct': 0});

    await db.insert('questions', {'type': 'test', 'question_text': 'Aşağıdakilerden hangisi ilk yardımcının yapmaması gereken bir davranıştır?', 'explanation': 'Gereksiz hareket ettirme, özellikle düşme ve travma durumlarında zararlı olabilir.', 'quiz_group_id': 3, 'order_in_quiz': 28});
    await db.insert('options', {'question_id': 28, 'option_text': '112\'yi aramak', 'is_correct': 0});
    await db.insert('options', {'question_id': 28, 'option_text': 'Olay yerini değerlendirmek', 'is_correct': 0});
    await db.insert('options', {'question_id': 28, 'option_text': 'Hasta/yaralıyı gereksiz yere hareket ettirmek', 'is_correct': 1});
    await db.insert('options', {'question_id': 28, 'option_text': 'Çevredeki kişilerden yardım istemek', 'is_correct': 0});

    await db.insert('questions', {'type': 'test', 'question_text': '112 Acil Çağrı Merkezi hangi durumda aranmalıdır?', 'explanation': '112 yalnızca acil yardım gerektiren durumlarda aranmalıdır.', 'quiz_group_id': 3, 'order_in_quiz': 29});
    await db.insert('options', {'question_id': 29, 'option_text': 'Acil sağlık yardımı gerektiren durumlarda', 'is_correct': 1});
    await db.insert('options', {'question_id': 29, 'option_text': 'Ödev sormak için', 'is_correct': 0});
    await db.insert('options', {'question_id': 29, 'option_text': 'Günlük bilgi almak için', 'is_correct': 0});
    await db.insert('options', {'question_id': 29, 'option_text': 'Deneme amacıyla', 'is_correct': 0});

    await db.insert('questions', {'type': 'test', 'question_text': 'İlk yardımda "koruma" basamağı neyi ifade eder?', 'explanation': 'Koruma, olay yerinde güvenlik risklerini azaltmayı ve yeni kazaların önlenmesini ifade eder.', 'quiz_group_id': 3, 'order_in_quiz': 30});
    await db.insert('options', {'question_id': 30, 'option_text': 'Yaralıya ilaç vermeyi', 'is_correct': 0});
    await db.insert('options', {'question_id': 30, 'option_text': 'Olay yerinde güvenliği sağlamayı', 'is_correct': 1});
    await db.insert('options', {'question_id': 30, 'option_text': 'Yaralıyı yalnız bırakmayı', 'is_correct': 0});
    await db.insert('options', {'question_id': 30, 'option_text': 'Olayı sosyal medyada paylaşmayı', 'is_correct': 0});

    await db.insert('questions', {'type': 'test', 'question_text': 'İlk yardımcının hasta/yaralıya yaklaşırken dikkat etmesi gereken temel davranış hangisidir?', 'explanation': 'İlk yardımcı sakin ve güven verici olmalı, hasta/yaralının durumunu kötüleştirecek davranışlardan kaçınmalıdır.', 'quiz_group_id': 3, 'order_in_quiz': 31});
    await db.insert('options', {'question_id': 31, 'option_text': 'Sakin, güven verici ve kontrollü olmak', 'is_correct': 1});
    await db.insert('options', {'question_id': 31, 'option_text': 'Panik yapmak', 'is_correct': 0});
    await db.insert('options', {'question_id': 31, 'option_text': 'Kalabalığı artırmak', 'is_correct': 0});
    await db.insert('options', {'question_id': 31, 'option_text': 'Bilmediği uygulamaları denemek', 'is_correct': 0});

    await db.insert('questions', {'type': 'test', 'question_text': 'Aşağıdakilerden hangisi ilk yardım uygulamalarında doğru bir yaklaşımdır?', 'explanation': 'İlk yardımcı, profesyonel yardım gelene kadar hasta/yaralının durumunu izlemelidir.', 'quiz_group_id': 3, 'order_in_quiz': 32});
    await db.insert('options', {'question_id': 32, 'option_text': 'Hasta/yaralıya bilinçsizce yiyecek vermek', 'is_correct': 0});
    await db.insert('options', {'question_id': 32, 'option_text': 'Olay yerini değerlendirmeden müdahale etmek', 'is_correct': 0});
    await db.insert('options', {'question_id': 32, 'option_text': 'Yardım gelene kadar hasta/yaralıyı gözlemlemek', 'is_correct': 1});
    await db.insert('options', {'question_id': 32, 'option_text': '112\'yi aramaktan kaçınmak', 'is_correct': 0});

    // ==========================================
    // MODÜL 4: Hayat Kurtarma Zinciri (1 soru)
    // ==========================================

    await db.insert('questions', {
      'type': 'ordering',
      'question_text': 'Aşağıdaki basamakları doğru sıraya yerleştiriniz.',
      'explanation': 'Hayat kurtarma zincirinde her basamak bir sonraki basamağın etkisini artırır. Zincirin doğru kurulması yaşam şansını destekler.',
      'quiz_group_id': 4,
      'order_in_quiz': 33
    });
    await db.insert('ordering_items', {'question_id': 33, 'item_text': 'Acil durumu erken fark etme ve 112\'yi arama', 'drag_image_path': null, 'drop_image_path': null, 'correct_order': 1});
    await db.insert('ordering_items', {'question_id': 33, 'item_text': 'Erken temel yaşam desteği / uygun ilk yardım yaklaşımı', 'drag_image_path': null, 'drop_image_path': null, 'correct_order': 2});
    await db.insert('ordering_items', {'question_id': 33, 'item_text': 'Erken otomatik eksternal defibrilatör kullanımı', 'drag_image_path': null, 'drop_image_path': null, 'correct_order': 3});
    await db.insert('ordering_items', {'question_id': 33, 'item_text': 'Profesyonel acil sağlık ekibinin müdahalesi / ileri yaşam desteği', 'drag_image_path': null, 'drop_image_path': null, 'correct_order': 4});
    await db.insert('ordering_items', {'question_id': 33, 'item_text': 'İyileşme ve bakım süreci', 'drag_image_path': null, 'drop_image_path': null, 'correct_order': 5});
  }

  static Future<void> insertVersion2Data(Database db) async {}
}

import 'package:masbhty/core/models/dhikr_model.dart';

class DefaultAzkar {
  static List<DhikrModel> get list => [
    // General Tasbeeh
    DhikrModel(
      id: 'subhanallah',
      title: 'سبحان الله',
      transliteration: 'Subhan Allah',
      category: 'تسابيح عامة',
      targetCount: 33,
      benefit: 'من قالها ٣٣ مرة كُتبت له ثلاثمائة حسنة ومُحيت عنه ثلاثمائة سيئة.',
    ),
    DhikrModel(
      id: 'alhamdulillah',
      title: 'الحمد لله',
      transliteration: 'Alhamdulillah',
      category: 'تسابيح عامة',
      targetCount: 33,
      benefit: 'تملأ ميزان العبد بالحسنات ورضا الخالق سبحانه وتعالى.',
    ),
    DhikrModel(
      id: 'allahuakbar',
      title: 'الله أكبر',
      transliteration: 'Allahu Akbar',
      category: 'تسابيح عامة',
      targetCount: 33,
      benefit: 'أحب الكلام إلى الله تبارك وتعالى وتزيد العبد رفعة وقوة.',
    ),
    DhikrModel(
      id: 'la_ilaha_illallah',
      title: 'لا إله إلا الله وحده لا شريك له',
      transliteration: 'La ilaha illallah',
      category: 'تسابيح عامة',
      targetCount: 100,
      benefit: 'كانت له عدل عشر رقاب، وكتبت له مئة حسنة، ومحيت عنه مئة سيئة، وكانت له حرزاً من الشيطان.',
    ),
    DhikrModel(
      id: 'astaghfirullah',
      title: 'أستغفر الله العظيم وأتوب إليه',
      transliteration: 'Astaghfirullah al-azim',
      category: 'تسابيح عامة',
      targetCount: 100,
      benefit: 'من لزم الاستغفار جعل الله له من كل هم فرجاً ومن كل ضيق مخرجاً ورزقه من حيث لا يحتسب.',
    ),
    DhikrModel(
      id: 'subhanallah_bihamdihi',
      title: 'سبحان الله وبحمده ، سبحان الله العظيم',
      transliteration: 'SubhanAllahi wa bihamdihi, SubhanAllahil-Azim',
      category: 'تسابيح عامة',
      targetCount: 100,
      benefit: 'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن.',
    ),
    DhikrModel(
      id: 'lahawla_wala_quwwata',
      title: 'لا حول ولا قوة إلا بالله العلي العظيم',
      transliteration: 'La hawla wala quwwata illa billah',
      category: 'تسابيح عامة',
      targetCount: 33,
      benefit: 'كنز من كنوز الجنة ودواء وتسعة وتسعون داءً أيسرها الهم.',
    ),
    DhikrModel(
      id: 'allahumma_salli_ala_muhammad',
      title: 'اللهم صلِّ وسلم وبارك على نبينا محمد',
      transliteration: 'Allahumma salli ala Muhammad',
      category: 'تسابيح عامة',
      targetCount: 100,
      benefit: 'من صلى عليّ صلاة صلى الله عليه بها عشراً ورُفعت درجاته وحُطت خطيئاته.',
    ),

    // Morning & Evening Azkar
    DhikrModel(
      id: 'morning_evening_1',
      title: 'أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له',
      transliteration: 'Asbahna wa asbahal mulku lillah',
      category: 'أذكار الصباح والمساء',
      targetCount: 1,
      benefit: 'يقال مرة واحدة في الصباح لحفظ العبد وتوكيله أمره لله طيلة يومه.',
    ),
    DhikrModel(
      id: 'morning_evening_2',
      title: 'رضيت بالله رباً، وبالإسلام ديناً، وبمحمد صلى الله عليه وسلم نبياً',
      transliteration: 'Raditu billahi rabba',
      category: 'أذكار الصباح والمساء',
      targetCount: 3,
      benefit: 'من قالها ثلاثاً حين يصبح وثلاثاً حين يمسي كان حقاً على الله أن يرضيه يوم القيامة.',
    ),
    DhikrModel(
      id: 'morning_evening_3',
      title: 'بسم الله الذي لا يضر مع اسمه شيء في الأرض ولا في السماء وهو السميع العليم',
      transliteration: 'Bismillahil-ladhi la yadurru ma\'as-mihi shai\'un',
      category: 'أذكار الصباح والمساء',
      targetCount: 3,
      benefit: 'لم تضره جائحة ولا يضره شيء طيلة يومه وليله.',
    ),
    DhikrModel(
      id: 'morning_evening_4',
      title: 'يا حي يا قيوم برحمتك أستغيث أصلح لي شأني كله ولا تكلني إلى نفسي طرفة عين',
      transliteration: 'Ya Hayyu Ya Qayyum bi rahma-tika astaghith',
      category: 'أذكار الصباح والمساء',
      targetCount: 3,
      benefit: 'دعاء جامع لصلاح الحال والتحصين والاستغاثة بالحي القيوم.',
    ),

    // Post Prayer
    DhikrModel(
      id: 'post_prayer_1',
      title: 'أستغفر الله (ثلاثاً) .. اللهم أنت السلام ومنك السلام تباركت يا ذا الجلال والإكرام',
      transliteration: 'Astaghfirullah (3x), Allahumma antas-salam...',
      category: 'أذكار ما بعد الصلاة',
      targetCount: 1,
      benefit: 'تقال مباشرة دبر كل صلاة مكتوبة لتأدية السنن والتحصين والاستغفار عن أي تقصير.',
    ),
    DhikrModel(
      id: 'post_prayer_2',
      title: 'اللهم أعني على ذكرك وشكرك وحسن عبادتك',
      transliteration: 'Allahumma a\'inni ala dhikrika...',
      category: 'أذكار ما بعد الصلاة',
      targetCount: 1,
      benefit: 'أوصى بها النبي صلى الله عليه وسلم لمعاذ بن جبل ألا يدعها دبر كل صلاة.',
    ),

    // Asma-ul-Husna Examples (Sample of key ones for brevity, but represented completely)
    DhikrModel(
      id: 'asma_allah_1',
      title: 'يا الله',
      transliteration: 'Ya Allah',
      category: 'أسماء الله الحسنى',
      targetCount: 100,
      benefit: 'الاسم الأعظم الجامع لصفات الإلوهية والربوبية والرحمة.',
    ),
    DhikrModel(
      id: 'asma_allah_2',
      title: 'يا رحمن يا رحيم',
      transliteration: 'Ya Rahman Ya Rahim',
      category: 'أسماء الله الحسنى',
      targetCount: 100,
      benefit: 'لاستجلاب رحمة الله عز وجل وسعة فضله ورزقه ومغفرته.',
    ),
    DhikrModel(
      id: 'asma_allah_3',
      title: 'يا لطيف',
      transliteration: 'Ya Latif',
      category: 'أسماء الله الحسنى',
      targetCount: 129,
      benefit: 'دعاء للتيسير ولطف الله وتفريج الكرب والهم من حيث لا نحتسب.',
    ),
    DhikrModel(
      id: 'asma_allah_4',
      title: 'يا حي يا قيوم',
      transliteration: 'Ya Hayyu Ya Qayyum',
      category: 'أسماء الله الحسنى',
      targetCount: 100,
      benefit: 'تفريج الهم وسعة الصدر ودوام النعم والصحة والبركة.',
    ),
  ];
}

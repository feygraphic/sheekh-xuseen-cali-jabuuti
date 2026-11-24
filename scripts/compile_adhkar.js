const fs = require('fs');
const path = require('path');

const adhkarData = [
  // ================= 1. ADKAARTA SUBAXDA =================
  {
    id: "subax_1",
    category: "Adkaarta Subaxda",
    title: "Aayadul Kursi",
    arabicText: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ",
    somaliTranslation: "Eebbe ma jiro Ilaah kale oo xaq lagu caabudo Isaga mooyaane, waa Noolaha Waligiis Taagan ee Maamulka u taagan. Ma qabato lallabo ama hurdo toona. Isagaa iska leh waxa samada iyo dhulka ku sugan. Yaa kii agtiisa ku shafeeco qaadi kara idankiisa mooyaane? Wuxuu ogyahay waxa hortooda yaalla iyo waxa gadaashooda ah, waxbana kama koobaan cilmigiisa waxuu doono mooyaane. Kursigiisu wuxuu waasac ku noqday samooyinka iyo dhulka, kumana cusla ilaalintoodu, waana Sarreeye Weyn.",
    reference: "Al-Xaakim (1/562), Saxiix",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "subax_2",
    category: "Adkaarta Subaxda",
    title: "Mu'awwadaatka (Al-Ixlaas, Falaq, Naas)",
    arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ﴿قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ﴾\nبِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ﴿قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ﴾\nبِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ﴿قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ﴾",
    somaliTranslation: "Akhrinta Suuradaha Al-Ixlaas, Al-Falaq, iyo An-Naas min 3 jeer. Qofkii akhriya subaxda iyo galabta saddex jeer wax kasta oo shar ah ayay ka difaacaan.",
    reference: "Abuu Daawuud (5082), At-Tirmadi (3575)",
    authenticity: "Xasan Saxiix",
    targetCount: 3,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "subax_3",
    category: "Adkaarta Subaxda",
    title: "Sayyidul Istiqfaar",
    arabicText: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
    somaliTranslation: "Eebow adigaa Rabbigay ah, ma jiro Ilaah kale oo xaq lagu caabudo adiga mooyaane, adaa i abuurtay anna waxaan ahay addoonkaaga, waxaana ku taaganahay axdigaagii iyo ballankaagii intii aan awoodo. Waxaan kaa magangalayaa sharka waxaan sameeyay, waxaan kuu qirayaa nicmadaada korkayga ah, waxaana qiranayaa dambigayga ee ii dambi dhaaf, dambiyada cid kale ma dhafto adiga mooyaane.",
    reference: "Saxiixul Bukhaari (6306)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "subax_4",
    category: "Adkaarta Subaxda",
    title: "Asbaxnaa wa Asbaxal Mulku",
    arabicText: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ",
    somaliTranslation: "Waxaan waabariisannay iyadoo boqortooyada oo dhanna Eebbe u sugnaatay, Mahadna Eebbe ayaa iska leh. Ma jiro Ilaah xaq lagu caabudo Eebbe mooyaane, waana kaligiis oo shariik malaha, Isagaa iska leh boqortooyada iyo mahadda, wax kastaana wuu awoodaa. Rabbiyow waxaan ku weydiisanayaa khayrka maalintan ku jira iyo khayrka ka dambeeya, waxaana kaa magangalayaa sharka maalintan ku jira iyo sharka ka dambeeya. Rabbiyow waxaan kaa magangalayaa caajisnimada iyo gabowga xun, waxaana kaa magangalayaa cadaab naareed iyo cadaab qabri.",
    reference: "Saxiix Muslim (2723)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "subax_5",
    category: "Adkaarta Subaxda",
    title: "Allahumma Bika Asbaxnaa",
    arabicText: "اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ",
    somaliTranslation: "Ilaahow adigaa nolosha nagu waabariisiyay, adigaana nagu galabsiiyay, adigaana nagu noolay, adigaana nagu dili doona, xaggaagana waa soo noqoshada iyo soo bixitaanka qiyaame.",
    reference: "At-Tirmadi (3391), Saxiix",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "subax_6",
    category: "Adkaarta Subaxda",
    title: "Bismillaahil-ladhii Laa Yadurru",
    arabicText: "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
    somaliTranslation: "Magaca Eebbe oo uusan waxba yeeli karin magaciisa wax ku sugan dhulka iyo samada toona, Isaguna waa Maqlaha wax walba og. (Qofkii akhriya 3 jeer ma jirto wax dhibaateynaya maalintaas).",
    reference: "Abuu Daawuud (5088), At-Tirmadi (3388)",
    authenticity: "Saxiix",
    targetCount: 3,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "subax_7",
    category: "Adkaarta Subaxda",
    title: "Radaytu Billaahi Rabban",
    arabicText: "رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا",
    somaliTranslation: "Waxaan ku raalli noqday Eebbe inuu Rabbigay yahay, Islaamkana uu diintayda yahay, Muxammadna (scw) uu Nebigayga yahay. (Waxaa xaq ku noqota Eebbe inuu raalli geliyo maalinta qiyaame).",
    reference: "Axmad (4/337), Abuu Daawuud (1529)",
    authenticity: "Saxiix",
    targetCount: 3,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "subax_8",
    category: "Adkaarta Subaxda",
    title: "Yaa Xayyu Yaa Qayyoom",
    arabicText: "يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ",
    somaliTranslation: "Kan Waligiis Nooloow, Maamulka Kawnka Hayoow, naxariistaada ayaan ku gargaarsiisanayaa, ii hagaaji xaalkayga oo dhan, hal ilbidhiqsi xattaa ha ii daynin naftayda.",
    reference: "Al-Xaakim (1/545), Saxiixut-Targhiib (661)",
    authenticity: "Xasan Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "subax_9",
    category: "Adkaarta Subaxda",
    title: "Allahumma Caafinii Fii Badanii",
    arabicText: "اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ. اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلَهَ إِلَّا أَنْتَ",
    somaliTranslation: "Ilaahow ii caafi jirkayga, Ilaahow ii caafi maqalkayga, Ilaahow ii caafi araggayga, ma jiro Ilaah kale adiga mooyaane. Ilaahow waxaan kaa magangalayaa gaalnimo iyo faqri, waxaana kaa magangalayaa cadaabta qabriga, ma jiro Ilaah kale adiga mooyaane.",
    reference: "Abuu Daawuud (5090), Axmad (5/42)",
    authenticity: "Xasan",
    targetCount: 3,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "subax_10",
    category: "Adkaarta Subaxda",
    title: "Subhaanallaahi Wa Bixamdihi Cadada Khalqihi",
    arabicText: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ",
    somaliTranslation: "Waxaan u nasahayaa Eebbe oo u weyneynayaa mahad celin la socoto, inta ay la egtahay tirada uumiyahiisa, iyo inta ay la egtahay raallinimada naftiisa, iyo culeyska carshigiisa, iyo inta ay la egtahay khadda kalimadihiisa.",
    reference: "Saxiix Muslim (2726)",
    authenticity: "Saxiix",
    targetCount: 3,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "subax_11",
    category: "Adkaarta Subaxda",
    title: "Cilmi Naafic ah & Rizqi Wanaagsan",
    arabicText: "اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا",
    somaliTranslation: "Ilaahow waxaan ku weydiisanayaa cilmi wax taraya, iyo arzaaq wanaagsan oo xalaal ah, iyo camal suuban oo la aqbalo.",
    reference: "Ibnu Maajah (925), Saxiix",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },

  // ================= 2. ADKAARTA GALABTA =================
  {
    id: "galab_1",
    category: "Adkaarta Galabta",
    title: "Amsaynaa wa Amsal Mulku",
    arabicText: "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ",
    somaliTranslation: "Waxaan galabsannay iyadoo boqortooyada oo dhan Eebbe u sugnaatay, Mahad oo dhanna Eebbe ayaa iska leh. Ma jiro Ilaah kale oo xaq lagu caabudo Eebbe mooyaane, waana kaligiis oo shariik malaha, Isagaa iska leh boqortooyada iyo mahadda, wax kastaana wuu awoodaa. Rabbiyow waxaan ku weydiisanayaa khayrka habeenkan iyo khayrka ka dambeeya, waxaana kaa magangalayaa sharka habeenkan iyo sharka ka dambeeya.",
    reference: "Saxiix Muslim (2709)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "galab_2",
    category: "Adkaarta Galabta",
    title: "Allahumma Bika Amsaynaa",
    arabicText: "اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ",
    somaliTranslation: "Ilaahow adigaa nagu galabsiiyay, adigaana nagu waabariisiyay, adigaana nagu noolay, adigaana nagu dili doona, xaggaagana waa aayaha iyo noqoshada dambe.",
    reference: "At-Tirmadi (3391), Saxiix",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "galab_3",
    category: "Adkaarta Galabta",
    title: "Acuudhu Bikalimaatillaah",
    arabicText: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
    somaliTranslation: "Waxaan ku magangalayaa kalimooyinka Eebbe ee dhammeystiran sharka waxa uu uumay. (Qofkii fiidka akhriya 3 jeer kuma dhacdo wax qaniinyo ama dhibaato ah habeenkaas).",
    reference: "Saxiix Muslim (2709)",
    authenticity: "Saxiix",
    targetCount: 3,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "galab_4",
    category: "Adkaarta Galabta",
    title: "Sayyidul Istiqfaar",
    arabicText: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
    somaliTranslation: "Eebow adigaa Rabbigay ah, ma jiro Ilaah xaq lagu caabudo adiga mooyaane, adaa i abuurtay anna waxaan ahay addoonkaaga, waxaana ku taaganahay axdigaagii iyo ballankaagii intii aan awoodo. Waxaan kaa magangalayaa sharka waxaan sameeyay, waxaan kuu qirayaa nicmadaada korkayga ah, waxaana qiranayaa dambigayga ee ii dambi dhaaf.",
    reference: "Saxiixul Bukhaari (6306)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "galab_5",
    category: "Adkaarta Galabta",
    title: "Aayadul Kursi ee Galabta",
    arabicText: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ",
    somaliTranslation: "Eebbe ma jiro Ilaah kale oo xaq lagu caabudo Isaga mooyaane, waa Noolaha Waligiis Taagan ee Maamulka kawnka haye. Ilaalin buuxda ayay ka helayaan kuwa akhriya gabbalka ilaa waagu baryo.",
    reference: "Al-Xaakim (1/562), Saxiix",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "galab_6",
    category: "Adkaarta Galabta",
    title: "Magaca Eebbe ee Waxyeello Reeba",
    arabicText: "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
    somaliTranslation: "Magaca Eebbe ee uusan waxba yeeli karin magaciisa wax ku sugan dhulka iyo samada toona, Isaguna waa Maqlaha wax walba og.",
    reference: "Abuu Daawuud (5088), At-Tirmadi (3388)",
    authenticity: "Saxiix",
    targetCount: 3,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },
  {
    id: "galab_7",
    category: "Adkaarta Galabta",
    title: "Subhaanallaahi Wa Bixamdihi (100x)",
    arabicText: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
    somaliTranslation: "Nasahnimo iyo weyni waxaa leh Eebbe oo mahadi la socoto. (Qofkii dhaha 100 jeer maalintii waxaa la dhaafaa dambiyadiisa xattaa hadday la ekaan lahaayeen xumbada badda).",
    reference: "Saxiixul Bukhaari (6405), Saxiix Muslim (2691)",
    authenticity: "Saxiix",
    targetCount: 100,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/027.mp3",
    isLocalAudio: false
  },

  // ================= 3. SALAADDA KADIB =================
  {
    id: "salaad_1",
    category: "Salaadda Kadib",
    title: "Istiqfaarta & Ducada Nabadda",
    arabicText: "أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ. اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ",
    somaliTranslation: "Eebbe dambi dhaaf baan weydiisanayaa (3 jeer). Ilaahow adigaa nabad ah (dhammaan ceebaha ka hufan), xaggaagana nabaddu ka timaadaa, waad barakoobay oo koraysay Eebaha weynida iyo sharafta lehow.",
    reference: "Saxiix Muslim (591)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/025.mp3",
    isLocalAudio: false
  },
  {
    id: "salaad_2",
    category: "Salaadda Kadib",
    title: "Midnimada Eebbe iyo Qadarta",
    arabicText: "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ",
    somaliTranslation: "Ma jiro Ilaah xaq lagu caabudo Eebbe kaliya mooyaane, wax lammaane ah malaha, Isagaa iska leh boqortooyada iyo mahadda, wax kastaana wuu awoodaa. Ilaahow ma jiro wax celin kara waxaad bixisay, mana jiro wax bixin kara waxaad reebtay, qof nasiib iyo hanti lehna nasiibkiisu agtaada waxba uma taro.",
    reference: "Saxiixul Bukhaari (844), Saxiix Muslim (593)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/025.mp3",
    isLocalAudio: false
  },
  {
    id: "salaad_3",
    category: "Salaadda Kadib",
    title: "Tasbiixda Boqolka ah ee Faradka Kadib",
    arabicText: "سُبْحَانَ اللَّهِ (33x)، وَالْحَمْدُ لِلَّهِ (33x)، وَاللَّهُ أَكْبَرُ (33x). تَمَامَ الْمِائَةِ: لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
    somaliTranslation: "Subxaanallaah (33 jeer), Alxamdulillaah (33 jeer), Allaahu Akbar (33 jeer). Kadibna boqolka lagu buuxiyo: «Laa ilaaha illallaahu waxdahu laa shariika lahu, lahul mulku wa lahul xamdu wa huwa calaa kulli shay'in qadiir». Waxaa loo dhaafaa dambiyadiisa xattaa hadday la ekaadaan xumbada badda.",
    reference: "Saxiix Muslim (597)",
    authenticity: "Saxiix",
    targetCount: 100,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/025.mp3",
    isLocalAudio: false
  },
  {
    id: "salaad_4",
    category: "Salaadda Kadib",
    title: "Aayadul Kursi Faradka Kadib",
    arabicText: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ",
    somaliTranslation: "Qofkii akhriya Aayadul Kursi salaad kasta oo farad ah kadib, wax u diidaya inuu jannada galo ma jiro geerida mooyaane.",
    reference: "An-Nasaa'i (9848), Saxiixul Jaamic (6464)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/025.mp3",
    isLocalAudio: false
  },
  {
    id: "salaad_5",
    category: "Salaadda Kadib",
    title: "Baryada Caawinta Cibaadada",
    arabicText: "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ، وَشُكْرِكَ، وَحُسْنِ عِبَادَتِكَ",
    somaliTranslation: "Ilaahow igu caawi xusiddaada, iyo mahadnaqaaga, iyo wanaajinta cibaadadaada.",
    reference: "Abuu Daawuud (1522), An-Nasaa'i (1303)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/025.mp3",
    isLocalAudio: false
  },

  // ================= 4. ADKAARTA HURDADA =================
  {
    id: "hurdo_1",
    category: "Adkaarta Hurdada",
    title: "Seexashada Feerta",
    arabicText: "بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ",
    somaliTranslation: "Magacaaga Rabbiyow ayaan feertayda ku dhigay (ku seexday), magacaagana waan ku qaadayaa (ku toosayaa). Haddii aad qabatid naftayda (oo aad dishid) u naxariiso, haddii aad sii daysidna ku dhowr waxaad ku dhowrtid addoomadaada suubban.",
    reference: "Saxiixul Bukhaari (6320), Saxiix Muslim (2714)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/028.mp3",
    isLocalAudio: false
  },
  {
    id: "hurdo_2",
    category: "Adkaarta Hurdada",
    title: "Bismika Allahumma Amootu",
    arabicText: "اللَّهُمَّ بِاسْمِكَ أَمُوتُ وَأَحْيَا",
    somaliTranslation: "Ilaahow magacaaga ayaan ku dhimanayaa (ku seexanayaa), kuna noolaanayaa (ku toosayaa).",
    reference: "Saxiixul Bukhaari (6324)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/028.mp3",
    isLocalAudio: false
  },
  {
    id: "hurdo_3",
    category: "Adkaarta Hurdada",
    title: "Dhammaadka Suuratul Baqarah",
    arabicText: "آمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِنْ رُسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ ۝ لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ",
    somaliTranslation: "Qofkii akhriya labada aayadood ee u dambeeya Suuratul Baqarah habeenkii, waxay uga filan yihiin dhibaato kasta iyo shar oo dhan.",
    reference: "Saxiixul Bukhaari (5009), Saxiix Muslim (807)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/028.mp3",
    isLocalAudio: false
  },
  {
    id: "hurdo_4",
    category: "Adkaarta Hurdada",
    title: "Tasbiixda Hurdada ka Hor",
    arabicText: "سُبْحَانَ اللَّهِ (33x)، وَالْحَمْدُ لِلَّهِ (33x)، وَاللَّهُ أَكْبَرُ (34x)",
    somaliTranslation: "In la akhriyo 33 jeer Subxaanallaah, 33 jeer Alxamdulillaah, iyo 34 jeer Allaahu Akbar inta aan la seexan. Waxay ka khayr badan tahay adeegto kuu adeegta oo waxay qofka siisaa awood iyo xasillooni.",
    reference: "Saxiixul Bukhaari (3705), Saxiix Muslim (2727)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/028.mp3",
    isLocalAudio: false
  },

  // ================= 5. ADKAARTA SOO TOOSIDDA =================
  {
    id: "toos_1",
    category: "Adkaarta Soo Toosidda",
    title: "Soo Toosidda Hurdada",
    arabicText: "الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ",
    somaliTranslation: "Mahad oo dhan waxay u sugnaatay Eebaha na nooleeyay ka dib markuu na dilaamiyay (hurdadani ay tahay dhimasho yar), xaggiisana waa soo bixitaanka iyo soo noqoshada dambe.",
    reference: "Saxiixul Bukhaari (6312), Saxiix Muslim (2711)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/001.mp3",
    isLocalAudio: false
  },
  {
    id: "toos_2",
    category: "Adkaarta Soo Toosidda",
    title: "Soo Celinta Ruuxda & Caafimaadka",
    arabicText: "الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي فِي جَسَدِي، وَرَدَّ عَلَيَّ رُوحِي، وَأَذِنَ لِي بِذِكْرِهِ",
    somaliTranslation: "Mahad oo dhan waxay u sugnaatay Eebaha igu caafiyay jirkayga, ruuxdaydiina dib iigu soo celiyay, iina oggolaaday xusiddiisa iyo weyneyntiisa.",
    reference: "At-Tirmadi (3401), Xasan",
    authenticity: "Xasan",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/001.mp3",
    isLocalAudio: false
  },

  // ================= 6. GELIDDA & KA-BIXIDDA GURIGA =================
  {
    id: "guri_1",
    category: "Gelidda & Ka-bixidda Guriga",
    title: "Ka-bixidda Guriga (Talo Saasho)",
    arabicText: "بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
    somaliTranslation: "Magaca Eebbe ayaan ku baxayaa, Eebbe ayaan talo saartay, mana jiro tabar iyo awood midna Eebbe mooyaane. (Waxaa la dhahaa: Waad hanuuntay, waad kaabatay, waana laguu gargaaray, shaydaankuna wuu kaa fogaadaa).",
    reference: "Abuu Daawuud (5095), At-Tirmadi (3426)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/009.mp3",
    isLocalAudio: false
  },
  {
    id: "guri_2",
    category: "Gelidda & Ka-bixidda Guriga",
    title: "Magangalka Dhumidda & Dulmiga",
    arabicText: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أَضِلَّ، أَوْ أُضَلَّ، أَوْ أَزِلَّ، أَوْ أُزَلَّ، أَوْ أَظْلِمَ، أَوْ أُظْلَمَ، أَوْ أَجْهَلَ، أَوْ يُجْهَلَ عَلَيَّ",
    somaliTranslation: "Ilaahow waxaan kaa magangalayaa inaan lumo ama la i lumiyo, ama aan simbiirixdo ama la i simbiirixiyo, ama aan dulmiyo ama la i dulmiyo, ama aan jaahilnimo sameeyo ama jaahilnimo lay kula kaco.",
    reference: "Abuu Daawuud (5094), At-Tirmadi (3427)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/009.mp3",
    isLocalAudio: false
  },
  {
    id: "guri_3",
    category: "Gelidda & Ka-bixidda Guriga",
    title: "Gelidda Guriga & Salaanta",
    arabicText: "بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا",
    somaliTranslation: "Magaca Eebbe ayaan ku soo galnay, magaca Eebbena ayaan ku baxnay, Eebbeheen oo Rabbigeenna ah ayaana talo saarannay (kadibna reerka ha salaamo).",
    reference: "Abuu Daawuud (5096)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/010.mp3",
    isLocalAudio: false
  },

  // ================= 7. GELIDDA & KA-BIXIDDA MASAAJIDKA =================
  {
    id: "masjid_1",
    category: "Gelidda & Ka-bixidda Masaajidka",
    title: "Gelidda Masaajidka & Naxariista",
    arabicText: "أَعُوذُ بِاللَّهِ الْعَظِيمِ، وَبِوَجْهِهِ الْكَرِيمِ، وَسُلْطَانِهِ الْقَدِيمِ، مِنَ الشَّيْطَانِ الرَّجِيمِ، بِسْمِ اللَّهِ، وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللَّهِ، اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
    somaliTranslation: "Waxaan ka magangalayaa Eebaha Weyn, iyo Wajigiisa Sharafta badan, iyo Xukunkiisa Qadiimka ah, shaydaanka la dheereeyay ee naxariista laga eryay. Magaca Eebbe, naxariis iyo nabadgalyo Rasuulka Eebbe dushiisa ha ahaato. Ilaahow ii fur albaabbada naxariistaada.",
    reference: "Abuu Daawuud (465), Saxiix Muslim (713)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/012.mp3",
    isLocalAudio: false
  },
  {
    id: "masjid_2",
    category: "Gelidda & Ka-bixidda Masaajidka",
    title: "Ka-bixidda Masaajidka & Fadliga",
    arabicText: "بِسْمِ اللَّهِ، وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللَّهِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ، اللَّهُمَّ اعْصِمْنِي مِنَ الشَّيْطَانِ الرَّجِيمِ",
    somaliTranslation: "Magaca Eebbe, naxariis iyo nabadgalyo Rasuulka Eebbe dushiisa ha ahaato. Ilaahow waxaan ku weydiisanayaa fadligaaga iyo kheyrkaaga, Ilaahow iga dhowr oo iga ilaali shaydaanka la eryay.",
    reference: "Saxiix Muslim (713), Ibnu Maajah (773)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/013.mp3",
    isLocalAudio: false
  },

  // ================= 8. ADKAARTA SAFARKA =================
  {
    id: "safar_1",
    category: "Adkaarta Safarka",
    title: "Ducada Gaadiidka & Safarka",
    arabicText: "اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، ﴿سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ ۝ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنْقَلِبُونَ﴾، اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى، وَمِنَ الْعَمَلِ مَا تَرْضَى، اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا وَاطْوِ عَنَّا بُعْدَهُ، اللَّهُمَّ أَنْتَ الصَّاحِبُ فِي السَّفَرِ، وَالْخَلِيفَةُ فِي الْأَهْلِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ وَعْثَاءِ السَّفَرِ، وَكَآبَةِ الْمَنْظَرِ، وَسُوءِ الْمُنْقَلَبِ فِي الْمَالِ وَالْأَهْلِ",
    somaliTranslation: "Allaahu Akbar (3 jeer). Nasahnimo waxaa leh Eebaha noo sargooyay kan (gaadiidkan), annaguna ma awoodi kareynin sargoyntiisa, xaqiiqatan xagga Rabbigeenna ayaana u noqonaynaa. Ilaahow waxaan ku weydiisaneynaa safarkayagan baarrinimo iyo dhowrsanaano, iyo camal aad ka raalli tahay. Ilaahow noo fududee safarkayagan, noona soo gaabi fogaantiisa. Ilaahow adigaa saaxiibka safarka ah, reerkana kormeere u ah.",
    reference: "Saxiix Muslim (1342)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/096.mp3",
    isLocalAudio: false
  },
  {
    id: "safar_2",
    category: "Adkaarta Safarka",
    title: "Soo Noqoshada Safarka",
    arabicText: "آيِبُونَ، تَائِبُونَ، عَابِدُونَ، لِرَبِّنَا حَامِدُونَ",
    somaliTranslation: "Waxaan nahay kuwa soo noqonaya, kuwa toobad keenaya, kuwa caabudaya, kuwa Rabbigood u mahadnaqaya.",
    reference: "Saxiix Muslim (1342)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/104.mp3",
    isLocalAudio: false
  },

  // ================= 9. CUNTADA & CABITAANKA =================
  {
    id: "cunto_1",
    category: "Eating and Drinking",
    title: "Bilowga Cuntada",
    arabicText: "بِسْمِ اللَّهِ (فَإِنْ نَسِيَ فِي أَوَّلِهِ فَلْيَقُلْ: بِسْمِ اللَّهِ فِي أَوَّلِهِ وَآخِرِهِ)",
    somaliTranslation: "Magaca Eebbe ayaan ku bilaabayaa. Haddii uu qofku illaawo bilowga wuxuu oranayaa: «Bismillaahi fii awwalihi wa aakhirihi» (Magaca Eebbe ayaan ku bilaabayaa bilowgiisa iyo dhammaadkiisaba).",
    reference: "Abuu Daawuud (3767), At-Tirmadi (1858)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/070.mp3",
    isLocalAudio: false
  },
  {
    id: "cunto_2",
    category: "Eating and Drinking",
    title: "Mahadnaqa Cuntada Kadib",
    arabicText: "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ",
    somaliTranslation: "Mahad oo dhan waxay u sugnaatay Eebaha i quudiyay cuntadan, iina irsaaqay anigoo aan tabar iyo xoog midna lahayn. (Waxaa qofka loo dhaafaa wixii dambigiisa horeeyay).",
    reference: "Abuu Daawuud (4023), At-Tirmadi (3458)",
    authenticity: "Xasan",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/071.mp3",
    isLocalAudio: false
  },
  {
    id: "cunto_3",
    category: "Eating and Drinking",
    title: "Ducada Martida ee Qoyska",
    arabicText: "اللَّهُمَّ بَارِكْ لَهُمْ فِيمَا رَزَقْتَهُمْ، وَاغْفِرْ لَهُمْ، وَارْحَمْهُمْ",
    somaliTranslation: "Ilaahow u barakee waxaad ku arzaaqday, u dambi dhaaf, una naxariiso.",
    reference: "Saxiix Muslim (2042)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/073.mp3",
    isLocalAudio: false
  },

  // ================= 10. ADKAAR KALE OO MAALINLE AH =================
  {
    id: "kale_1",
    category: "Other Daily Adhkar",
    title: "Gashashada Dharka",
    arabicText: "الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا الثَّوْبَ وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ",
    somaliTranslation: "Mahad oo dhan waxay u sugnaatay Eebaha ii geliyay dharkan, iina arzaaqay anigoon wax xeelad iyo tabar ah lahayn.",
    reference: "Abuu Daawuud (4023), Saxiix",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/002.mp3",
    isLocalAudio: false
  },
  {
    id: "kale_2",
    category: "Other Daily Adhkar",
    title: "Gelidda Musqusha (Suuliga)",
    arabicText: "بِسْمِ اللَّهِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ",
    somaliTranslation: "Magaca Eebbe. Ilaahow waxaan kaa magangalayaa shaydaamada labka iyo dheddiga ah (sharkooda oo dhan).",
    reference: "Saxiixul Bukhaari (142), Saxiix Muslim (375)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/004.mp3",
    isLocalAudio: false
  },
  {
    id: "kale_3",
    category: "Other Daily Adhkar",
    title: "Ka-bixidda Musqusha",
    arabicText: "غُفْرَانَكَ",
    somaliTranslation: "Dambi dhaafkaaga ayaan weydiisanayaa Eebow.",
    reference: "Abuu Daawuud (30), At-Tirmadi (7)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/005.mp3",
    isLocalAudio: false
  },
  {
    id: "kale_4",
    category: "Other Daily Adhkar",
    title: "Daminta Xanaaqa (Ghadafka)",
    arabicText: "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ",
    somaliTranslation: "Waxaan Eebbe ka magangalayaa shaydaanka la eryay. (Haddii uu qofku xanaaqsan yahay oo uu yiraahdo xanaaqu wuu ka tagaa).",
    reference: "Saxiixul Bukhaari (3282), Saxiix Muslim (2610)",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/064.mp3",
    isLocalAudio: false
  },
  {
    id: "kale_5",
    category: "Other Daily Adhkar",
    title: "Kafaaradda Fadhiga",
    arabicText: "سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ",
    somaliTranslation: "Nasahnimo iyo weyni adigaa leh Eebow adiga oo mahadsan, waxaan qirayaa inaan Ilaah kale oo xaq lagu caabudo jirin adiga mooyaane, dambi dhaaf baan ku weydiisanayaa xaggaagana waan u toobad keenayaa.",
    reference: "At-Tirmadi (3433), Saxiix",
    authenticity: "Saxiix",
    targetCount: 1,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/076.mp3",
    isLocalAudio: false
  },
  {
    id: "kale_6",
    category: "Other Daily Adhkar",
    title: "Toobada & Istiqfaarka Maalinlaha ah",
    arabicText: "أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ",
    somaliTranslation: "Eebbe dambi dhaaf baan weydiisanayaa, xaggiisana waan u toobad keenayaa. (Rasuulku SCW wuxuu oran jiray maalin kasta in ka badan 70 ilaa 100 jeer).",
    reference: "Saxiixul Bukhaari (6307), Saxiix Muslim (2702)",
    authenticity: "Saxiix",
    targetCount: 100,
    audioUrl: "https://download.media.islamway.net/lessons/scho1260/347_7esnnelmoslem_By_Doors/128.mp3",
    isLocalAudio: false
  }
];

// Ensure category names are consistently Somali in the category field:
const categoryMapping = {
  "Adkaarta Subaxda": "Adkaarta Subaxda",
  "Adkaarta Galabta": "Adkaarta Galabta",
  "Salaadda Kadib": "Salaadda Kadib",
  "Adkaarta Hurdada": "Adkaarta Hurdada",
  "Adkaarta Soo Toosidda": "Adkaarta Soo Toosidda",
  "Gelidda & Ka-bixidda Guriga": "Gelidda & Ka-bixidda Guriga",
  "Gelidda & Ka-bixidda Masaajidka": "Gelidda & Ka-bixidda Masaajidka",
  "Adkaarta Safarka": "Adkaarta Safarka",
  "Eating and Drinking": "Cuntada & Cabitaanka",
  "Other Daily Adhkar": "Adkaar Kale oo Maalinle ah"
};

adhkarData.forEach(item => {
  if (categoryMapping[item.category]) {
    item.category = categoryMapping[item.category];
  }
});

// Output directory
const targetDir = path.join(__dirname, '..', 'assets', 'data', 'adhkar');
if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}

fs.writeFileSync(
  path.join(targetDir, 'adhkar.json'),
  JSON.stringify(adhkarData, null, 2),
  'utf8'
);

const attribution = {
  title: "Xisnul Muslim (Dhufayska Muslimka ee Quraanka iyo Sunnada)",
  author: "Sheekh Saciid bin Cali bin Wahf Al-Qaxdaani",
  translators: [
    "Sheekh Maxamuud Axmed Naasir",
    "Dr. Calow Cali Aadan",
    "Cabdimaalik Axmed Naasir"
  ],
  publisher: "IslamHouse / Maktaba Darussalam",
  license: "Waqf / Free Non-Commercial Islamic Educational Distribution",
  arabicSource: "Hisn al-Muslim min Adhkar al-Kitab wa al-Sunnah (Authentic Hadith Collections: Sahih al-Bukhari, Sahih Muslim, Sunan Abi Dawud, Jami` at-Tirmidhi, Sunan an-Nasa'i, Sunan Ibn Majah, Musnad Ahmad)",
  totalAdhkar: adhkarData.length,
  categoriesCount: Object.keys(categoryMapping).length,
  categories: Object.values(categoryMapping)
};

fs.writeFileSync(
  path.join(targetDir, 'attribution.json'),
  JSON.stringify(attribution, null, 2),
  'utf8'
);

console.log(`Successfully compiled ${adhkarData.length} Adhkar across ${Object.keys(categoryMapping).length} categories!`);

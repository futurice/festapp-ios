//
//  FestDataManager.m
//  FestApp
//
//  Created by Oleg Grenrus on 22/03/14.
//
//

#import "FestDataManager.h"
#import "FestHTTPSessionManager.h"

#import "Artist.h"
#import "NewsItem.h"
#import "InfoItem.h"

InfoItem *extractFood(NSArray *ohjelma);
NSArray *extractInfo(NSArray *ohjelma, NSArray *info);

@interface FestDataManager()
@property (nonatomic, strong) RACSubject *artistsSignal;
@property (nonatomic, strong) RACSubject *newsSignal;
@property (nonatomic, strong) RACSubject *infoSignal;
@property (nonatomic, strong) RACSubject *foodSignal;

- (id)preloadResource:(NSString *)name selector:(SEL)selector;
- (BOOL)reloadResource:(NSString *)name path:(NSString *)path selector:(SEL)selector subject:(RACSubject *)subject force:(BOOL)force;

- (id)transformArtists:(id)artistsJSONValue;
- (id)transformNews:(id)newsJSONValue;
- (id)transformId:(id)jsonValue;

- (NSString *)pathToResourceByName:(NSString *)name;
- (NSString *)contentByResourceName:(NSString *)name;
@end

InfoItem *extractFood(NSArray *ohjelma) {
    for (NSDictionary *item in ohjelma) {
        if ([item[@"url"] isEqualToString:@"/ohjelma/makuelamykset"]) {
            return [[InfoItem alloc] initFromJSON:@{@"title": item[@"title"],
                                                    @"content": item[@"content"]}];
        }
    }

    return nil;
}

NSArray* extractInfo(NSArray *ohjelma, NSArray *info) {
    InfoItem *alueOhjelma = nil;
    InfoItem *ukk = nil;

    for (NSDictionary *item in ohjelma) {
        if ([item[@"url"] isEqualToString:@"/ohjelma/alueohjelma"]) {
            alueOhjelma = [[InfoItem alloc] initFromJSON:@{@"title": item[@"title"],
                                                    @"content": item[@"content"]}];
        }
    }

    for (NSDictionary *item in info) {
        if ([item[@"url"] isEqualToString:@"/info/ukk"]) {
            ukk = [[InfoItem alloc] initFromJSON:@{@"title": @"Usein kysytyt kysymykset",
                                                           @"content": item[@"content"]}];
        }
    }

    return @[
             [[InfoItem alloc] initFromJSON:@{@"title": @"Tärkeää", @"content": @"<p>45. Ruisrock-festivaali vietetään 4-6.7.2014 Ruissalon Kansanpuistossa, Turussa. Tervetuloa mukaan juhlimaan!</p>\n<h2 id=\"aukioloajat\">Aukioloajat</h2>\n<p>Festivaalialue on avoinna:</p>\n<ul>\n<li>Perjantaina klo 16-02 </li>\n<li>Lauantaina klo 13-02 </li>\n<li>Sunnuntaina 13-23</li>\n</ul>\n<h1 id=\"infopisteet\">Infopisteet</h1>\n<p>Ruisrockin kolme infopistettä palvelevat koko festivaalin ajan. Infopisteestä on saatavilla käsiohjelmia, korvatulppia ja sadetakkeja. </p>\n<p>Festivaali-infoa saa myös koko festivaaliviikon ajan numerosta 044-9345758.</p>\n<h1 id=\"ruisrock-wifi\">Ruisrock WiFi</h1>\n<p>Ensimmäistä kertaa festivaalialueelta löydät langattoman Ruisrock WiFin Metsä loungesta. Ruisrock WiFin salasana on ruiswifi </p>\n<h1 id=\"meeting-point\">Meeting point</h1>\n<p>Sovi treffit kaverin kanssa Ruisrockin Meeting pointille, jonka löydät Niittylavaa vastapäätä aivan Bar Ruisbistron kulmalta. </p>\n<p>Oikeudet muutoksiin pidätetään.</p>\n"}],
             [[InfoItem alloc] initFromJSON:@{@"title": @"Liput", @"content": @"<h2 id=\"lippujen-hinnat\">Lippujen hinnat</h2>\n<ul>\n<li>3 päivän lippu 125 euroa (portilta 135 euroa)</li>\n<li>2 päivän lippu (pe-la / la-su / pe+su) 110 euroa (portilta 120 euroa)</li>\n<li>1 päivä (pe/la/su) 75 euroa (portilta 85 euroa)</li>\n</ul>\n<p>Ruisrockin liput ovat myynnissä Tiketissä, Lippupisteessä ja Turun kauppatorin Ruiskioskilla. </p>\n<h2 id=\"vip-lippujen-hinnat\">VIP-lippujen hinnat</h2>\n<ul>\n<li>1 päivän (pe/su) VIP-lippu 199 euroa </li>\n<li>1 päivän (la) VIP-lippu 239 euroa </li>\n<li>3 päivän VIP-lippu 399 euroa</li>\n</ul>\n<p>Lue lisää VIP-lipuista <a href=\"http://www.ruisrock.fi/liput/vip\">Ruisrockin nettisivuilta</a>. Ruisrockin VIP-liput ovat myynnissä ainoastaan Tiketissä sekä Ruiskioskilla.</p>\n<p>Kaikkiin ennakkolippujen hintoihin lisätään mahdolliset lippukauppojen toimitusmaksut.</p>\n<h2 id=\"ruiskioski-on-avoinna-festivaalin-aikana\">Ruiskioski on avoinna festivaalin aikana</h2>\n<ul>\n<li>Perjantaina klo 11-21</li>\n<li>Lauantaina klo 11-21</li>\n<li>Sunnuntaina klo 11-19</li>\n</ul>\n<p>Ruiskioski sijaitsee Turun Kauppatorilla Aurakadun ja Yliopistokadun kulmassa. </p>\n<p>Portin lipunmyynti avautuu joka päivä tuntia ennen festivaaliporttien avautumista.</p>\n"}],
             [[InfoItem alloc] initFromJSON:@{@"title": @"Festaribussit", @"content": @"<h2 id=\"festaribussilla-turun-keskustasta\">Festaribussilla Turun keskustasta</h2>\n<p>Ruisrockin festaribussit kuljettavat festarikävijöitä Turun keskustasta festivaalialueen läheisyyteen festaribussiasemalle, josta on vajaan kahden kilometrin kävelymatka festivaalialueelle. Festaribussiasemalta on opastus festarialueelle. \nBussireitti</p>\n<h2 id=\"kauppatori-juna-asema-ruisrock-festaribussiasema-\">Kauppatori - Juna-asema - Ruisrock (festaribussiasema)</h2>\n<p>Bussit kulkevat reittiä koko päivän ajan non-stoppina molempiin suuntiin. Kauppatorin pysäkki sijaitsee Yliopistonkadun puolella Ortodoksisen kirkon edessä.</p>\n<h2 id=\"bussilippujen-hinnat-\">Bussilippujen hinnat:</h2>\n<ul>\n<li>Kertalippu 6 euroa</li>\n<li>Menopaluulippu 10 euroa</li>\n<li>Viikonloppulippu 15 euroa </li>\n</ul>\n<p>Bussiliput myydään käteisellä busseissa. Lisäksi viikonloppulippuja myydään Ruiskioskissa Turun Kauppatorilla festivaaliviikonlopun ajan (ei ennakkomyyntiä). </p>\n<h2 id=\"festaribussilla-artukainen-camping-parkingista\">Festaribussilla Artukainen Camping &amp; Parkingista</h2>\n<p>Artukaisten leirintä- ja parkkialueilta kulkee maksuton festaribussi non-stop-periaatteella Ruisrockin festaribussiasemalle ja takaisin leirintä- ja parkkialueille. Bussi on tarkoitettu leirintäalueella majoittuville sekä parkkialuetta käyttäville.\nFestaribussien aikataulut</p>\n<ul>\n<li>Perjantaina klo 15.00 - festivaalin loppuun saakka</li>\n<li>Lauantaina klo 12.00 - festivaalin loppuun saakka</li>\n<li>Sunnuntaina klo 12.00 - festivaalin loppuun saakka\nMolemmat festaribussit kulkevat saman aikataulun mukaan.</li>\n</ul>\n"}],
             [[InfoItem alloc] initFromJSON:@{@"title": @"Pyöräparkki", @"content": @"<p>Polkupyörällä pääset Ruisrockiin ajamalla Ruissalon puistotien kevyen liikenteen väylää pitkin. Pyörän voi jättää pääportin tuntumassa sijaitsevaan valvottuun polkupyöräparkkiin. Pyöräparkin maksu on 3 € / parkkeeraus. </p>\n<p>Pyöräparkista on oma sisäänkäyntinsä festivaalialueelle. Kävelijöiden ei ole mahdollista poistua alueelta pyöräparkin kautta. Pyöräparkkiin pääsee ainoastaan pyöräparkin rannekkeella. \nHuomioithan, että festivaalin aikaan useita tuhansia ihmisiä liikkuu Ruissalon saarella ja matkalla keskustaan. Olethan siis tavallistakin varovaisempi liikenteessä ja pidät mielessäsi lait, luonnon ja kanssapyöräilijät.</p>\n"}],
             [[InfoItem alloc] initFromJSON:@{@"title": @"Narikka & Löytötavarat", @"content": @"<p>Ruisrockin narikka sijaitsee pääportin yhteydessä. Sinne voit jättää lasipullot, arvotavarat ja muut ylimääräiset varusteet, joita et halua tuoda festivaalialueelle. Narikassa voit käydä myös festivaalin aikana alueelta käsin. Narikka on auki 1 h ennen ja 1 h jälkeen festivaalin aukioloaikojen. Narikkamaksu on 3 euroa ja käynti narikalla 1 euron.</p>\n<p>Huomioithan, että narikkaan jätetyt tavarat saat takaisin ainoastaan narikkalippua vastaan. Järjestäjä ei ole vastuussa narikkalipun katoamisesta tai siitä aiheutuvista seurauksista. </p>\n<p>Narikasta löytyy myös alkometri ajokunnon selvitystä varten. Alkometri: 2 euroa / puhallus.</p>\n<h2 id=\"l-yt-tavarat\">Löytötavarat</h2>\n<p>Narikka toimii myös löytötavarapisteenä. Toimita festivaalialueelta löytämäsi tavarat narikkaan. Puhelintiedustelut festivaalin aikana löytötavaroista 040-3237395.</p>\n<p>Yli 20 euron arvoiset löytötavarat toimitetaan festivaalin jälkeisenä maanantaina Varsinais-Suomen Löytötavaratoimistoon. Tiedustelut Ruisrockin löytötavaroista festivaalin jälkeen:\nVarsinais-Suomen Löytötavaratoimisto p. 0600-307 777 (1,69 € / min + pvm/mpm)</p>\n"}],
             [[InfoItem alloc] initFromJSON:@{@"title": @"Kännykkälataus", @"content": @"<ol>\n<li>Hae - Löydät Power it -latauspisteen pääporttia vastapäätä olevan festivaali-infon vierestä. Hae festareiden alussa oma akkumokkulasi ja pidä puhelimesi virroissa koko festareiden ajan hintaan 10 € + 15 € pantti!</li>\n<li>Vaihda - Voit vaihtaa tyhjentyneen akkumokkulan kaksi kertaa päivässä uuteen!</li>\n<li>Nauti - Älä ressaa puhelimen latauksesta vaan keskity hauskanpitämiseen! Puhelin kulkee samalla kokoajan taskussasi!</li>\n<li>Pidä/Palauta - Oliko Power it huippu juttu? Mikäli tykkäsit ja haluat pitää akkumokkulan itselläsi - ole hyvä, se on sinun! Mikäli haluat kuitenkin palauttaa sen niin hyvitämme festareiden viimeisenä päivänä ehjänä palautetusta akkumokkulasta 15 € pantin!</li>\n</ol>\n<p>Voit myös käydä vaihtamassa akkumokkulasi uuteen Artukainen Campingissa Power it -latauspisteellä. \nRuisrockissa kännykkälatauspalvelun tarjoaa Power it.</p>\n"}],
             [[InfoItem alloc] initFromJSON:@{@"title": @"Ensiapu", @"content": @"<p>Festivaalialueella on SPR:n koulutetun henkilökunnan ylläpitämä ensiapupiste sekä kiertäviä ensiapupartioita. Ensiapupiste sijaitsee festivaalialueen keskellä ja on avoinna koko festivaalin ajan. </p>\n<p>Muista suojella kuuloasi – korvatulppia saatavilla ilmaiseksi infopisteiltä!</p>\n"}],
             alueOhjelma,
             [[InfoItem alloc] initFromJSON:@{@"title": @"Artukainen camping & parking", @"content": @"<p>Ruisrockin leirintäalue sijaitsee HK Areenan ja Messukeskuksen läheisyydessä Turun Artukaisissa osoitteessa Artukaisten kiitotie. Festivaalialueelta on noin 6,5 kilometrin matka Artukaisiin ja matkalla kulkee leirintäalueen käyttäjille maksuton festivaalibussi. </p>\n<p>Leirintäalue on tarkoitettu vain Ruisrockin kävijöille. Leirintään ei ole ikärajaa, mutta suosittelemme että alle 15-vuotiaat yöpyvät vanhempien seurassa. Jokainen leiriytyjä saa rannekkeen, jolla pääsee kulkemaan leirintäalueelle.</p>\n<p>Leirintäalueen tavoitat avautumisen jälkeen numerosta 040-4771149.</p>\n<h2 id=\"aukioloajat\">Aukioloajat</h2>\n<p>Artukainen Camping avautuu torstaina 3.7. klo 18.00 ja sulkeutuu maanantaina 7.7. klo 12.00</p>\n<h2 id=\"hinnat\">Hinnat</h2>\n<p>Leirintälippu 30 euroa\nAsuntoautopaikka 20 euroa</p>\n<p>Voit ostaa leirintälipun Tiketistä. (linkki <a href=\"http://www.tiketti.fi/Ruisrock-leirinta-Ruisrockin-leirintaalue-Artukainen-Turku-lippuja/25371\">http://www.tiketti.fi/Ruisrock-leirinta-Ruisrockin-leirintaalue-Artukainen-Turku-lippuja/25371</a>) Leirintälippuja myydään myös leirintäalueen portilla, mikäli leirintäalueella edelleen on tilaa. </p>\n<p>Leirintälippu oikeuttaa yhden henkilön sisäänpääsyyn leirintäalueelle koko aukioloajaksi. Teltasta ei peritä erikseen telttapaikkamaksua vaan se sisältyy leirintälippuun. Asuntoautolla saapuvien tulee ostaa leirintälipun lisäksi autolle asuntoautopaikkalippu. Tämä tarkoittaa, että yhtä asuntoautoa kohti riittää yksi asuntoautopaikkalippu, mutta jokaisella asuntoautossa yöpyvällä tulee olla oma lippu leirintään. Leirintälippu on henkilökohtainen ja nimetty. </p>\n<p>Leirintään ei myydä erikseen yhden yön yöpymisiä, vaan hinta on sama koko festivaaliviikonlopun ajaksi. </p>\n<h2 id=\"saapuminen-leirint-alueelle\">Saapuminen leirintäalueelle</h2>\n<p>Ruisrockin leirintäalue sijaitsee HK Areenan (entisen Turkuhallin) ja Messukeskuksen läheisyydessä Turun Artukaisissa, osoitteessa Artukaisten kiitotie. Seuraa matkalla Artukainen Camping kylttejä.</p>\n<p>Turun keskustasta: Leirintäalueen läheisyyteen (HK Areena / Messukeskus) pääset Turun kauppatorilta lähtevillä busseilla 12, 32 ja 61. Turun rautatieasemalla pysähtyvät bussit 61 ja 32. </p>\n<p>Lue lisää Artukainen Campingiin saapumisesta sekä sen palveluista täältä. (linkki: <a href=\"http://www.ruisrock.fi/info/majoitus\">http://www.ruisrock.fi/info/majoitus</a>)</p>\n<h2 id=\"artukainen-parking\">Artukainen parking</h2>\n<p>Leirintäalueen vieressä on henkilöautojen pysäköintialue, joka on avoinna leirintäalueen aukioloaikojen mukaan. Pysäköinnin hinta on 5 euroa pysäköintikerralta. Autossa yöpyminen ja auton tuominen leirintäalueelle on turvallisuussyistä kielletty.</p>\n<p>Artukainen parkingia käyttävät pääsevät kulkemaan festaribussiasemalle maksuttomalla festaribussilla, joka kulkee non-stop-periaatteella.</p>\n"}],
             [[InfoItem alloc] initFromJSON:@{@"title": @"Koulumajoitus", @"content": @"<p>Koulumajoitusta Ruisrockin kävijöille tarjoaa TuTo ry. Koulumajoitusta on tarjolla ympäri Turkua, torstaista maanantaihin. </p>\n<p>Majoitus maksaa 17,00 € / hlö / yö. </p>\n<p>Lisätietoja koulumajoituksesta löydät TuTon verkkosivuilta. (linkki: <a href=\"http://www.tuto.fi/ruisrock-14/\">http://www.tuto.fi/ruisrock-14/</a>)</p>\n"}],
             [[InfoItem alloc] initFromJSON:@{@"title": @"Ympäristövinkit", @"content": @"<p>Ruisrock järjestetään Ruissalon saaressa, joka on suurimmaksi osaksi luonnonsuojelualuetta. Ruissalossa on monipuolinen ja arvokas luonto, jossa pesivät monet harvinaisetkin lintulajit ja nisäkkäät monipuolisen kasviston ympäröimänä. </p>\n<p>Ruisrockille on tärkeää pitää huolta Ruissalon luonnosta ja pyrimme luomaan puitteet, joissa jokainen juhlija voi pienellä vaivannäöllä auttaa tässä tärkeässä työssä. </p>\n<h2 id=\"vinkkej-ekologiseen-festarointiin\">Vinkkejä ekologiseen festarointiin</h2>\n<ul>\n<li>Sammuta kotoa turhat sähköä vievät laitteet ennen reissuun lähtöä.</li>\n<li>Pakkaa mukaasi vain tarpeellinen tavara ja palaa kotiin tavaroiden kanssa.  </li>\n<li>Tule julkisilla kulkuvälineillä tai kimppakyydillä Turkuun. Turusta Ruissaloon pääsee kätevimmin festaribussilla tai polkupyörällä. </li>\n<li>Juo riittävästi ja täytä pulloa tarpeen mukaan, alueelta löytyy useita vesipisteitä.</li>\n<li>Hyödynnä tuoppipantit. </li>\n<li>Tee tarpeesi vain käymälöihin.</li>\n<li>Käytä vain valmiita, merkittyjä kulkuväyliä. Alue on rajattu luontoa ajatellen.  </li>\n<li>Lajittele festivaalialueella jätteet niille tarkoitettuihin roska-astioihin. Tai pistä roskat ainakin roskiin, älä heitä luontoon! </li>\n<li>Suosi uudelleenkäytettäviä ja maatuvia pakkauksia. </li>\n<li>Lisäksi voit lipunoston yhteydessä tehdä hyvää ostamalla Saaristomeri-lipun, josta ohjataan kolme euroa Saaristomeren Suojelurahaston työhön. Saaristomeri on suomalaisten meri ja sen hyvinvointi on meidän käsissämme.</li>\n</ul>\n"}],
             [[InfoItem alloc] initFromJSON:@{@"title": @"Turvallisuusohjeet", @"content": @"<p>Festivaalikokemus pysyy alusta loppuun mahtavana, kun muistat nämä muutamat perusjutut</p>\n<ul>\n<li>Noudata aina järjestyksenvalvojien antamia ohjeita</li>\n<li>Pidä huolta itsestäsi ja ystävistäsi</li>\n<li>Pidä huolta festarilipustasi, se tarkistetaan elektronisesti joka päivä portilla</li>\n<li>Muista nauttia myös vettä varsinkin helteellä. Vesipullosi voit täyttää alueen lukuisilla vesipisteillä</li>\n<li>Pakkaa eväät mukaan festarille, mutta jätä kaikki lasisesti asiat sekä teräaseet kotiin</li>\n<li>Kunnioita Ruissalon asukkaiden kotirauhaa. Älä mene pihoihin tai niiden läheisyyteen</li>\n<li>Noudata opasteita ja merkittyjä reittejä, kävelijöille ja pyöräilijöille on varattu omansa</li>\n<li>Valitse festarivarusteet sään mukaan, mutta jätä kuitenkin sateenvarjosi kotiin</li>\n</ul>\n<p>Lue turvallisuusohjeet kokonaisuudessaan Ruisrockin nettisivuilta (linkki: <a href=\"http://www.ruisrock.fi/info/turvallisuusohjeet\">http://www.ruisrock.fi/info/turvallisuusohjeet</a>) ennen festivaalialueelle saapumista.</p>\n"}],
             [[InfoItem alloc] initFromJSON:@{@"title": @"Saavutettavuus", @"content": @"<p>Ruisrockin lähtökohtana on, että jokaisella on mahdollisuus osallistua festivaalille mahdollisimman esteettömästi. Haluamme, että jokainen voi nauttia Ruisrockista!\nRuisrockissa on helppo liikkua esteettömästi</p>\n<ul>\n<li>Invataksilla ajat helposti festivaalin esteettömälle sisäänkäynnille</li>\n<li>Niittylavan ja Telttalavan välissä kulkee asfaltoitu tie</li>\n<li>Festivaali on rakennettu puisto- /peltoalueelle, joten pohja on melko tasaista</li>\n<li>Neljän suurimman lavan yhteydessä on katsomokorokkeet</li>\n<li>Infopisteiden sekä katsomokorokkeiden vierestä löydät inva-wc:t </li>\n<li>Avustajat pääsevät Ruisrockiin veloituksetta lipullisen avustettavan kanssa</li>\n<li>Yleisavustajia löydät kiertämässä alueella sekä katsomokorokkeilta. Tunnistat yleisavustajat sinisestä liivistä\nFestivaalin aikana saavutettavuuteen liittyvissä asioissa sinua auttaa esteettömän sisäänkäynnin läheisyydestä festivaalialueelta löytyvä info, joka on avoinna festivaalialueen aukioloaikojen mukaan. \nLue lisää saavutettavasta Ruisrockista nettisivuilta. (Linkki <a href=\"http://www.ruisrock.fi/info/saavutettavuus/\">http://www.ruisrock.fi/info/saavutettavuus/</a>)</li>\n</ul>\n"}],
             ukk,
             [[InfoItem alloc] initFromJSON:@{@"title": @"In English", @"content": @"<h2 id=\"welcome-to-ruisrock-2014-\">Welcome to Ruisrock 2014!</h2>\n<p>Please use the main menu to access the map and schedule.</p>\n<p>Map = Kartta<br>Schedule = Aikataulu</p>\n<h2 id=\"area-opening-times\">Area opening times</h2>\n<ul>\n<li>On Friday 4.7. 4pm to 2am</li>\n<li>On Saturday 5.7. 1pm to 2am</li>\n<li>On Sunday 6.7. 1pm to 11pm</li>\n</ul>\n<h2 id=\"tickets\">Tickets</h2>\n<p>Please keep your ticket safe for the whole weekend, it will be scanned electronically each day you enter the festival. One admission/day, no re-entry.\nPurchase tickets from <a href=\"http://www.tiketti.fi/Ruisrock-2014-Ruissalo-Turku-tickets/20919\">Tiketti</a>, <a href=\"http://www.lippu.fi/Lippuja.html?affiliate=ADV&amp;fuzzy=yes&amp;detailadoc=erdetaila&amp;doc=search/search&amp;action=search&amp;fun=search&amp;detailbdoc=evdetailb&amp;suchbegriff=Ruisrock&amp;kudoc=artist&amp;language=en\">Lippupiste</a>, or in person from Ruiskioski on Turku Market Square.</p>\n<h2 id=\"how-to-get-to-the-festival-area\">How to get to the festival area</h2>\n<h3 id=\"festival-busses\">Festival Busses</h3>\n<p>Festival Bus Route:\nKauppatori (Market Square) - train station - Ruisrock (festival bus station)</p>\n<p>Festival bus timetable:\nFriday 4.7. from 3pm until close\nSaturday 5.7. from 12pm until close\nSunday 6.7. from 12pm until close</p>\n<p>Busses will run on a non-stop-basis for the whole day. The Market Square bus stop is on Yliopistonkatu in front of the Orthodox church.</p>\n<p>Prices:\n6 € / one-way\n10 € / return\n15 € / 3 days</p>\n<p>Tickets can be bought inside the busses, cash only. Three day bus tickets are also sold in Ruiskioski at Turku Market Square during the festival weekend.</p>\n<h3 id=\"bus-from-artukainen-camping-and-parking\">Bus from Artukainen camping and parking</h3>\n<p>There is a free festival bus from Artukainen camping and parking lot to festival bus station. The bus runs on a non-stop basis according to the same schedule as the festival bus. The bus is meant for people staying at Artukainen camping and people parking at Artukainen parking.</p>\n<p>There is a bicycle parking lot next to festival area. </p>\n<p>Taxi number is +358-2-10041. </p>\n<p><a href=\"http://www.ruisrock.fi/en/info/arriving\">More info on arriving here</a></p>\n<h2 id=\"ruiskioski\">Ruiskioski</h2>\n<p>Ruiskioski is an info booth located on the Turku Market Square. There you can get information, purchase official festival merchandise, buy festival tickets and buy 3-day tickets for festival bus. Before and during festival weekend.</p>\n<h2 id=\"information-points\">Information points</h2>\n<p>There are three information points on the festival area providing you information, earplugs and schedules. </p>\n<h2 id=\"free-wifi\">Free WiFi</h2>\n<p>There is a free wireless internet on the area marked on the map (kartta). Ruisrock WiFi password is ruiswifi .</p>\n<p>More information available on <a href=\"http://www.ruisrock.fi/en/info\">our website</a> . You can use the free WiFi to access the website.</p>\n"}],
             ];
};

@implementation FestDataManager
// TODO: remove me
- (RACSignal *)signalForResource:(FestResource)resourceId
{
    return nil;
}

+ (FestDataManager *)sharedFestDataManager
{
    static FestDataManager *_sharedFestDataManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFestDataManager = [[self alloc] init];
    });

    return _sharedFestDataManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // We could use RACBehaviourSubject here, but until loaded we don't have first value!

        // Artists
        id artistsValue = [self preloadResource:@"artistit" selector:@selector(transformArtists:)];
        RACSubject *artistsSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:artistsValue];
        [self reloadResource:@"artistit" path:RR_ARTISTS_JSON_URL selector:@selector(transformArtists:) subject:artistsSubject force:NO];
        _artistsSignal = artistsSubject;

        // News
        id newsValue = [self preloadResource:@"uutiset" selector:@selector(transformNews:)];
        RACSubject *newsSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:newsValue];
        [self reloadResource:@"uutiset" path:RR_NEWS_JSON_URL selector:@selector(transformNews:) subject:newsSubject force:NO];
        _newsSignal = newsSubject;

        // Info
        id infoValue = [self preloadResource:@"info" selector:@selector(transformId:)];
        id ohjelmaValue = [self preloadResource:@"ohjelma" selector:@selector(transformId:)];

        RACSubject *infoSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:infoValue];
        RACSubject *ohjelmaSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:ohjelmaValue];

        [self reloadResource:@"info" path:RR_INFO_JSON_URL selector:@selector(transformId:) subject:infoSubject force:NO];
        [self reloadResource:@"ohjelma" path:RR_OHJELMA_JSON_URL selector:@selector(transformId:) subject:ohjelmaSubject force:NO];

        _infoSignal = [RACSignal
                       combineLatest:@[infoSubject, ohjelmaSubject]
                       reduce:^id(id info, id ohjelma) {
                           return extractInfo(ohjelma, info);
                       }];

        _foodSignal = [ohjelmaSubject map:^id(id value) {
            return extractFood(ohjelmaValue);
        }];
    }
    return self;
}


# pragma mark - Resource polling

- (BOOL)reloadResource:(NSString *)name path:(NSString *)path selector:(SEL)selector subject:(RACSubject *)subject force:(BOOL)force
{
    NSString *keyForLastUpdated = [NSString stringWithFormat:@"%@%@", kResourceLastUpdatedPrefix, name];

    // Check when we updated gigs last
    if (!force) {
        NSDate *lastUpdated = [[NSUserDefaults standardUserDefaults] objectForKey:keyForLastUpdated];

        if (lastUpdated && -[lastUpdated timeIntervalSinceNow] < kResourcePollInterval) {
            NSLog(@"%@ are recent enough", name);
            return NO;
        }
    }

    FestHTTPSessionManager *sessionManager = [FestHTTPSessionManager sharedFestHTTPSessionManager];

    // TODO: implement HEAD fetching as well

    [sessionManager GET:path parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
        (void) task;

        NSLog(@"fetched %@", name);

        // save to file
        NSError *error;

        NSData *content = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];

        if (!error) {
            NSString *filePath = [self pathToResourceByName:name];
            if (![content writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
                NSLog(@"Error writing updated %@: %@", name, error);
            }
        } else {
            NSLog(@"Error serializing %@: %@", name, error);
        }

        // push into subject
        // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
        IMP imp = [self methodForSelector:selector];
        id (*transform)(id, SEL, id) = (void *)imp;
        id object = transform(self, selector, responseObject);

        [subject sendNext: object];

        // store last updated field
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:keyForLastUpdated];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        (void) task;
        NSLog(@"failed to fetch %@: %@", name, error);
    }];

    return YES;
}

# pragma mark - Resource preloading

- (id)preloadResource:(NSString *)name selector:(SEL)selector
{
    IMP imp = [self methodForSelector:selector];
    id (*transform)(id, SEL, id) = (void *)imp;

    NSString *resourceDataString = [self contentByResourceName:name];
    NSDictionary *resourceJSON = [resourceDataString JSONValue];
    id object = transform(self, selector, resourceJSON);

    return object;
}

#pragma mark - Resource transformers

- (id)transformArtists:(id)artistsJSONValue
{
    NSArray *artistsArray = artistsJSONValue;
    NSMutableArray *artists = [NSMutableArray arrayWithCapacity:artistsArray.count];
    NSUInteger len = [artistsArray count];

    for (NSUInteger idx = 0; idx < len; idx++) {
        NSDictionary *obj = artistsArray[idx];
        Artist *artist = [[Artist alloc] initFromJSON:obj];
        if (artist) {
            [artists addObject:artist];
        }
    }

    return artists;
}

- (id)transformNews:(id)newsJSONValue
{
    NSArray *newsArray = newsJSONValue;
    NSMutableArray *news = [NSMutableArray arrayWithCapacity:newsArray.count];
    NSUInteger len = [newsArray count];

    for (NSUInteger idx = 0; idx < len; idx++) {
        NSDictionary *obj = newsArray[idx];
        NewsItem *item = [[NewsItem alloc] initFromJSON:obj];
        if (item) {
            [news addObject:item];
        }
    }

    [news sortUsingComparator:^NSComparisonResult(NewsItem *a, NewsItem *b) {
        return [b.datetime compare:a.datetime];
    }];

    return news;
}

- (id)transformId:(id)jsonValue
{
    return jsonValue;
}

#pragma mark - Resource storing

- (NSString *)pathToResourceByName:(NSString *)name
{
    NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [paths[0] stringByAppendingPathComponent:@"Content"];
	NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		if (![fileManager createDirectoryAtPath:path
                    withIntermediateDirectories:NO
                                     attributes:nil
                                          error:&error]) {
			NSLog(@"Create directory error: %@", error);
		}
	}

    return [path stringByAppendingPathComponent:name];
}

- (NSString *)contentByResourceName:(NSString *)name
{
    NSString *path;
    NSError *error;

    // dynamic resource, let's use the locally saved version if available:
    path = [self pathToResourceByName:name];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:path]) {

        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        if (sourcePath == nil) {
            return nil;
        }
        BOOL success = [fileManager copyItemAtPath:sourcePath toPath:path error:&error];
        if (!success) {
            NSLog(@"%s: Error writing initial content of \"%@\": %@", __func__, path, error);
            return nil;
        }
    }

    NSStringEncoding enc;
    NSString *content = [NSString
                         stringWithContentsOfFile:path
                         usedEncoding:&enc
                         error:&error];
    if (content) {
        return content;
    } else {
        NSLog(@"Error reading content of \"%@\": %@", path, error);
        return nil;
    }
}
@end

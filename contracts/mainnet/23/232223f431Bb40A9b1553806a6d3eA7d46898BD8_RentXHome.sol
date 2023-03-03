/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract RentXHome {
    receive() external payable {
        CoinYatirma memory x;
        x.miktar = msg.value;
        x.tarih = block.timestamp;

        coinYatirma[msg.sender].push(x);
    }

    constructor(
        address _manager,
        address _BUSD,
        address _USDT,
        address _USDC
    ) {
        // Yetkilendirme Eklemesi
        yetkilendirme[msg.sender] = true;
        yetkilendirme[_manager] = true;

        BUSD = IERC20(_BUSD);
        USDT = IERC20(_USDT);
        USDC = IERC20(_USDC);

        buKontrat = address(this);
    }

    string _s = "sistem";

    plan[] public Planlar;

    // MAPPING YAPILARI
    // MAPPING YAPILARI

    address public buKontrat;
    mapping(uint256 => plan) public Plan;
    mapping(address => bool) yetkilendirme;
    mapping(address => kullaniciBilgileri) public kullanicilar;
    mapping(address => kullaniciRefBilgileri) public kullanicilarREF;

    mapping(string => sistemData) public Kontrat;
    mapping(address => uint256) public paraCekmeTalepleri;
    mapping(address => CoinYatirma[]) public coinYatirma;

    address[] public cuzdanlar;

    //TOKEN KONTRAT ADRESLERİ

    IERC20 public BUSD;
    IERC20 public USDT;
    IERC20 public USDC;
    IERC20 public RENTATOKEN;

    //TOKEN KONTRAT ADRESLERİ

    paraCekimStruct[] public paraCekimListesi;

    struct CoinYatirma {
        uint256 miktar;
        uint256 tarih;
    }

    struct paraCekimStruct {
        address _adres;
        uint256 _miktar;
        uint256 _tarih;
    }

    // ##################################################################################################

    // STRUCT YAPILARI
    // STRUCT YAPILARI
    struct sistemData {
        // Kontrat Sistem Yapilari
        uint256 kilitSuresi;
        uint8 aktifPlanlar;
        uint256 refKazanci;
        uint256 refrentaTokenHakki;
        uint256 yeniuyerentaTokenHakki;
        uint256 stakeBozmaCezasi;
        bool rentaTokenCekim;
        uint8 paraYatirmaKomisyonu;
        uint8 paraCekmeKomisyonu;
        uint256 refYatirmaPayi;
        uint256 rentaTokenCekimDegeri;
        uint256 kayitFee;
        // Sabit Token Kontratları
    }

    // Kullanıcı Planları
    struct plan {
        uint256 min;
        uint256 max;
        uint256 saniyelikKazanc;
    }

    // Tutulacak Kullanıcı Verileri
    struct kullaniciBilgileri {
        bool kayit;
        uint256 kayitTarihi;
        bool bloke;
        address davetEden;
        uint256 bekleyenKomisyonbakiyesi;
        uint256 bakiye;
        uint256 paraYatirmaTarihi;
        uint256 rentaTokenBakiyesi;
        bool kilitlemeDurumu;
        uint256 kilitAcilmaTarihi;
        uint256 dahiliPlan;
        uint256 kesinlesenBakiye;
        uint256 KazancBaslangici;
        uint256 stakeAktarilanKazanc;
    }

    struct kullaniciRefBilgileri {
        address[] referanslari;
        bool refTokenOdemesi;
        bool refYatirmaPayiOdemesi;
        address[] odemeAlinanRef;
        bool refPayOdemesi;
    }

    function kullaniciRefBilgileriGuncalle(
        address _address,
        address[] memory _referanslari,
        bool _refTokenOdemesi,
        bool _refYatirmaPayiOdemesi,
        address[] memory _odemeAlinanRef,
        bool _refPayOdemesi
    ) public yetkilendirmeKontrolu {
        kullaniciRefBilgileri memory x;

        x.referanslari = _referanslari;
        x.refTokenOdemesi = _refTokenOdemesi;
        x.refYatirmaPayiOdemesi = _refYatirmaPayiOdemesi;
        x.odemeAlinanRef = _odemeAlinanRef;
        x.refPayOdemesi = _refPayOdemesi;

        kullanicilarREF[_address] = x;
    }

    // ##################################################################################################

    // MODIFIER DEĞİŞTİRİCİ KONTROL YAPILARI
    // MODIFIER DEĞİŞTİRİCİ KONTROL YAPILARI
    modifier kayitKontrolu() {
        require(
            kullanicilar[msg.sender].kayit == true,
            "Kayitli Olmayan Hesap"
        );
        _;
    }

    modifier yetkilendirmeKontrolu() {
        require(yetkilendirme[msg.sender] == true);
        _;
    }

    // ##################################################################################################

    function aktifPlanGuncelle(uint8 _limit) public yetkilendirmeKontrolu {
        Kontrat[_s].aktifPlanlar = _limit;
    }

    function PlanEkle(
        uint256 _id,
        uint256 _min,
        uint256 _max,
        uint256 _kazanc
    ) public yetkilendirmeKontrolu {
        Plan[_id].min = _min;
        Plan[_id].max = _max;
        Plan[_id].saniyelikKazanc = _kazanc;
    }

    function _safeTransfer(
        IERC20 tokencontract,
        address recipient,
        uint256 amount
    ) private {
        bool sent = tokencontract.transfer(recipient, amount);
        require(sent, "TRANSFER BASARISIZ");
    }

    function bnbleriCek(uint256 amount, address receiveAddress)
        external
        yetkilendirmeKontrolu
    {
        payable(receiveAddress).transfer(amount);
    }

    function TokenleriCek(
        IERC20 tokenc,
        address receiveAddress,
        uint256 amount
    ) external yetkilendirmeKontrolu {
        _safeTransfer(tokenc, receiveAddress, amount);
    }

    function yetkilendirmeEkle(address _wallet, bool _status)
        external
        yetkilendirmeKontrolu
    {
        yetkilendirme[_wallet] = _status;
    }

    function KayitOl(address _davetEden) public payable {
        require(msg.value >= Kontrat[_s].kayitFee, "Yetersiz Gas Fee Ucreti.");

        require(
            kullanicilar[msg.sender].kayit == false,
            "Bu Adres ZATEN KAYITLI"
        );

        // Cüzdan Listesi Kaydı.
        cuzdanlar.push(msg.sender);

        kullaniciBilgileri memory x;
        x.kayit = true;
        // kullanıcı ref kısmına kendi adresini yazmışsa veya girilen adres daha önce kayıt olmamışsa 0 eklenir.
        x.davetEden = (_davetEden != msg.sender &&
            kullanicilar[_davetEden].kayit)
            ? _davetEden
            : address(0);

        // Kullanıcı ilk para yatırma işleminde renta tokeni alır.
        // Aynı şekilde ilk para yatırma işlemi ise referans'ına da rent'a token gönderilir.
        if (kullanicilarREF[msg.sender].refTokenOdemesi == false) {
            kullanicilarREF[msg.sender].refTokenOdemesi = true;
            kullanicilar[msg.sender].rentaTokenBakiyesi += Kontrat[_s]
                .yeniuyerentaTokenHakki;
            kullanicilar[_davetEden].rentaTokenBakiyesi += Kontrat[_s]
                .refrentaTokenHakki;
            // Bu kullanıcıyı davet eden kişinin, ödeme aldığı listeye bu adres eklenir.
            kullanicilarREF[kullanicilar[msg.sender].davetEden]
                .odemeAlinanRef
                .push(msg.sender);
        }

        x.kayitTarihi = block.timestamp;

        kullanicilar[msg.sender] = x;
    }

    function ParaYatirma(uint8 _token, uint256 _GonderilecekMiktar)
        public
        returns (bool)
    {
        address __ = msg.sender;
        // Token Transfer İşleminin sonucu bool olarak saklanacak.
        bool _transferIslemi;
        // İstenilen Token'in Geçerli olup olmadığı kontrol edilecek.
        bool _tokenGecerliligi;
        // Kullanıcı Para yatırdığında alınacak olan komisyon
        uint256 _miktar = _GonderilecekMiktar -
            (uint256((uint256(_GonderilecekMiktar / 100))) * 1);

        // 0 - BUSD
        if (_token == 0) {
            _tokenGecerliligi = true;
            require(
                BUSD.balanceOf(__) > 0 && _miktar >= BUSD.balanceOf(__),
                "Yeterli miktarda BUSD'a sahip degilsiniz! ! !"
            );
            _transferIslemi = BUSD.transferFrom(__, buKontrat, _miktar);
        }
        // 1 - USDT
        else if (_token == 1) {
            _tokenGecerliligi = true;
            require(
                USDT.balanceOf(__) > 0 && _miktar >= USDT.balanceOf(__),
                "Yeterli miktarda USDT'ye sahip degilsiniz! ! !"
            );
            _transferIslemi = USDT.transferFrom(__, buKontrat, _miktar);
        }
        // 2 - USDC
        else if (_token == 2) {
            _tokenGecerliligi = true;
            require(
                USDC.balanceOf(__) > 0 && _miktar >= USDC.balanceOf(__),
                "Yeterli miktarda USDC'a sahip degilsiniz! ! !"
            );
            _transferIslemi = USDC.transferFrom(__, buKontrat, _miktar);
        }
        // GEÇERSİZ TOKEN
        else revert("GECERSIZ BIR TOKEN KONTRATI ILE TRANSFER TALEBI");

        return ParaYatirmaIslemi(__, _transferIslemi, _miktar);
    }

    function ParaYatirmaIslemi(
        address __,
        bool _transferIslemi,
        uint256 _miktar
    ) private returns (bool) {
        // Transfer İşlemi Tamamlandıysa TRUE dönmesi istenecektir. Başarılı olursa require() atlanacak.
        require(_transferIslemi, "TRANSFER ISLEMI BASARISIZ !!!");

        // Kullanıcının Güncel Bakiyesi "guncelBakiye" değişkenine aktarılacak.
        uint256 guncelBakiye = kullanicilar[msg.sender].bakiye;

        // Bu işlemin sonunda, yatırılan miktar ile güncel bakiyenin ne kadar olacağı hesaplanacak.
        // İşlem sonrası bakiyenin durumu kontrol edilerek, gerekliyse mevcut plan güncellenecek.
        // Eğer plan güncellenirse TRUE döndürülecek.
        bool _planDegisikligi = PlanGuncelleme((guncelBakiye + _miktar));

        if (_planDegisikligi) {
            KazanciKesinlestirme();
        }

        //Buraya kadar herşey tamamsa, kullanıcının bakiye bilgisi güncellenir.
        kullanicilar[msg.sender].bakiye += _miktar;

        address __davetEden = kullanicilar[__].davetEden;

        if (kullanicilarREF[__].refPayOdemesi == false) {}
        if (kullanicilar[__davetEden].kilitlemeDurumu == true) {
            kullanicilar[__davetEden].bakiye += uint256(
                ((_miktar / 100) * Kontrat[_s].paraYatirmaKomisyonu)
            );
            kullanicilarREF[__].refPayOdemesi = true;
        } else {
            kullanicilar[__davetEden].bekleyenKomisyonbakiyesi += uint256(
                ((_miktar / 100) * Kontrat[_s].paraYatirmaKomisyonu)
            );
            kullanicilarREF[__].refPayOdemesi = true;
        }

        return true;
    }

    function PlanGuncelleme(uint256 _islemSonrasiBakiye)
        private
        returns (bool)
    {
        bool _planGuncelleme = false;
        // For ile aktifPlan sayısı kadar döngü ile bakiye bilgisi ile plan değişikliği yapılıp yapılmayacağı kontrol edilir
        for (uint256 i = Kontrat[_s].aktifPlanlar; i > 0; i--) {
            // Para yatırma işlemi sonrası total bakiyenin plan değişikliği yapıp yapmaması gerektiğini kontrol eder.
            // Eğer güncel planda kalınmayacak ise değişiklilik yapılır.

            if (
                // İşlem sonrası bakiye hangi planların min ve max limitleri arasında olduğunu kontrol eder.
                _islemSonrasiBakiye >= Plan[i].min &&
                _islemSonrasiBakiye <= Plan[i].max &&
                // Kullanıcının mevcut bakiyesi ile şartları sağlayan planın farklı olup olmadığı kontrol edilir...
                kullanicilar[msg.sender].dahiliPlan != i
            ) {
                // Kullanıcının mevcut bakiyesi, plan değişikliği gerektiriyorsa burası çalışır.
                kullanicilar[msg.sender].dahiliPlan = i;
                // Plan Değiştiği için hali hazırda elde edilen kar kesinleşmiş kazanç hanesine yazılır..
                KazanciKesinlestirme();
                _planGuncelleme = true;
            }
        }
        //planın güncellenip güncellenmediği geridöndürülür..
        return _planGuncelleme;
    }

    function KazanciKesinlestirme() private {
        // kullanıcının mevcut planı ile başlangıcından itibaren şimdiye kadar ne kazandığı kontrol edilir.
        uint256 _plan = kullanicilar[msg.sender].dahiliPlan;
        uint256 _saniyelikKazanc = Plan[_plan].saniyelikKazanc;
        uint256 _baslangic = kullanicilar[msg.sender].KazancBaslangici;

        // toplam süre ve dahili plan ile aktarılacak gelir bilgisinin hesaplanması işlemi
        uint256 toplamSure = (block.timestamp - _baslangic);
        uint256 _kesinlestirilenKazanc = toplamSure * _saniyelikKazanc;

        // plan güncellemesi sonrası "kesinleşen kazanç" kısmına stake gelirinin aktarılması...
        kullanicilar[msg.sender].kesinlesenBakiye += _kesinlestirilenKazanc;

        // Kazanç Başlangıcının Sıfırlama. Bu işlem kazancı kesinleştirdikten sonra yeni plan ile en baştan devam eder.
        kullanicilar[msg.sender].KazancBaslangici = block.timestamp;
    }

    function kazancimiKesinlestir() external kayitKontrolu {
        KazanciKesinlestirme();
    }

    function Kilitle() public returns (bool) {
        if (kullanicilar[msg.sender].kilitAcilmaTarihi < block.timestamp) {
            kullanicilar[msg.sender].kilitAcilmaTarihi = (block.timestamp +
                Kontrat[_s].kilitSuresi);

            /* İlk kez kilitleme işlemi yapılıyorsa ve
                daha önce yatırma işleminden referansı para almamışsa komisyon ref adresine yazılır
            */
            if (kullanicilarREF[msg.sender].refYatirmaPayiOdemesi == false) {
                uint256 __msgSender_Bakiye = kullanicilar[msg.sender].bakiye;
                address __davetEden = kullanicilar[msg.sender].davetEden;

                kullanicilar[__davetEden].bakiye += uint256(
                    __msgSender_Bakiye / Kontrat[_s].refYatirmaPayi
                );

                kullanicilarREF[msg.sender].refYatirmaPayiOdemesi = true;
            }

            kullanicilar[msg.sender].kilitlemeDurumu = true;

            /* Eğer bakiyesi kilitli değilken bir kullanıcı davet etmiş ve komisyonu beklemeye düşmüşse,
                kilitleme sonrası bekleyen komisyon bakiyeye aktarılacak. */
            if (kullanicilar[msg.sender].bakiye > 0) {
                kullanicilar[msg.sender].bakiye += kullanicilar[msg.sender]
                    .bekleyenKomisyonbakiyesi;
            }

            return true;
        } else return false;
    }

    function StakeBoz(uint8 _dogrulama) public returns (bool) {
        require(
            _dogrulama == 143,
            "Stake Bozma Talebini Onaylamak Icin 143 Kodu Gonderilmedigi Icin Talep Iptal Edildi."
        );
        require(
            kullanicilar[msg.sender].kilitlemeDurumu,
            "Bakiye Kilitli Degil"
        );
        KazanciKesinlestirme();
        // Kullanıcı Verileri Alınıyor...
        uint256 _bakiye = kullanicilar[msg.sender].bakiye;
        uint256 _kesinlesenKazanc = kullanicilar[msg.sender].kesinlesenBakiye;
        // Kilit Suresi Kontrolu
        if (kullanicilar[msg.sender].kilitAcilmaTarihi >= block.timestamp) {
            // Tüm Şartlar Sağlanmışsa Kilit Kaldırılıyor...
            uint256 kesinti = uint256(
                _bakiye -
                    uint256((_bakiye / 100) * Kontrat[_s].stakeBozmaCezasi)
            );
            uint256 aktarilacakTutar = (_kesinlesenKazanc + kesinti);

            kullaniciBilgileri memory x;
            x.bakiye = 0;
            x.kilitlemeDurumu = false;
            x.kilitAcilmaTarihi = 0;
            x.KazancBaslangici = 0;
            x.dahiliPlan = 0;
            x.kesinlesenBakiye = aktarilacakTutar;
            kullanicilar[msg.sender] = x;

            return true;
        } else {
            revert("Beklenmedik Bir Hata Olustu");
        }
    }

    function KazanciStakeEt() external kayitKontrolu {
        // Kullanıcının mevcut bakiye , planın saniyelik kazanç bilgisi ve kar başlangıç süresi bilgilerini alır
        uint256 _bakiye = kullanicilar[msg.sender].bakiye;
        uint256 _plan = kullanicilar[msg.sender].dahiliPlan;
        uint256 _saniyelikKazanc = Plan[_plan].saniyelikKazanc;
        uint256 _baslangic = kullanicilar[msg.sender].KazancBaslangici;

        // toplam süre ve dahili plan ile aktarılacak gelir bilgisinin hesaplanması işlemi
        uint256 toplamSure = (block.timestamp - _baslangic);
        uint256 toplamAktarilacak = toplamSure * _saniyelikKazanc;

        // bakiye kısmına stake gelirinin aktarılması...
        kullanicilar[msg.sender].bakiye += toplamAktarilacak;
        // STAKE aktarılan gelir bilgisinin güncellenmesi ...
        kullanicilar[msg.sender].stakeAktarilanKazanc += toplamAktarilacak;

        // Plan Güncellemesi
        // işlem sonrası bakiye bilgisi, plan güncellemesine gerek olup olmadığı için PlanGuncelleme()'ye gönderilir.
        PlanGuncelleme((_bakiye + toplamAktarilacak));

        // Kazanç Başlangıcının Sıfırlanması
        kullanicilar[msg.sender].KazancBaslangici = block.timestamp;
    }

    function KazancimiSorgula()
        external
        view
        returns (uint256 stakeKazanci, uint256 kesinlesenBakiye)
    {
        // Eğer daha önce kesinleşen bir kazanç varsa bu alanda atanıp döndürülür.
        uint256 _kesinlesenKazanc = kullanicilar[msg.sender].kesinlesenBakiye;
        uint256 _stakeKazanci;

        // Eğer kazanc baslangıcı varsa hesaplaması yappılacak
        if (kullanicilar[msg.sender].KazancBaslangici > 0) {
            _stakeKazanci =
                block.timestamp -
                kullanicilar[msg.sender].KazancBaslangici;
        }

        return (_stakeKazanci, _kesinlesenKazanc);
    }

    function paraCekmeTalebiGonder(uint256 _miktar) public {
        require(
            kullanicilar[msg.sender].bloke == false,
            "PARA CEKME TALEBI BASARISIZ! 'Nedeni : >>> BLOKE EDILMIS CUZDAN"
        );
        // Kullanıcının kesinleşen bakiyesi varsa ve talep ettiği miktardan büyük değilse talep gonderebilir.
        if (
            kullanicilar[msg.sender].kesinlesenBakiye > 0 &&
            kullanicilar[msg.sender].kesinlesenBakiye <= _miktar
        ) {
            paraCekmeTalepleri[msg.sender] = _miktar;
            kullanicilar[msg.sender].kesinlesenBakiye =
                kullanicilar[msg.sender].kesinlesenBakiye -
                _miktar;
        } else {
            revert("Kesinlesen Bakiye Talep Gondermeye Uygun Degil");
        }
    }

    function paraCekmeTalebiniIslemeAl(address _adres, uint8 _islem)
        public
        yetkilendirmeKontrolu
    {
        require(paraCekmeTalepleri[_adres] > 0, "Bakiye Sorunu");
        uint256 _odenecekMiktar = paraCekmeTalepleri[_adres];

        if (_islem == 0) {
            // İşlemi İptal Etmek
            kullanicilar[_adres].kesinlesenBakiye += _odenecekMiktar;
            delete paraCekmeTalepleri[_adres];
        } else if (_islem == 1) {
            paraCekimStruct memory liste;

            // BUSD ile adrese para transferini gerçekleştirme
            IERC20 _busd = BUSD;

            // Çekme talebi işleme alınırken ödenecek miktardan para çekme bedeli kesilecek.
            bool transferIslemi = _busd.transfer(
                _adres,
                uint256(
                    _odenecekMiktar -
                        (uint256(_odenecekMiktar / 100) *
                            Kontrat[_s].paraCekmeKomisyonu)
                )
            );
            require(transferIslemi, "TRANSFER ISLEMI BASARISIZ");

            liste._adres = _adres;
            liste._miktar = _odenecekMiktar;
            liste._tarih = block.timestamp;
            // Bilgileri Liste Yapısına Bas \\
            paraCekimListesi.push(liste);
        } else if (_islem == 2) {
            paraCekimStruct memory liste;
            liste._adres = _adres;
            liste._miktar = _odenecekMiktar;
            liste._tarih = block.timestamp;
            // Bilgileri Liste Yapısına Bas \\
            paraCekimListesi.push(liste);
        } else {
            revert("HATALI ISLEM KODU ILE ISTEK YAPILDI");
        }
    }

    function RentaTokenGuncelle(address _adres) public yetkilendirmeKontrolu {
        RENTATOKEN = IERC20(_adres);
    }

    function rentaTokenlerimiCek() public {
        uint256 __bakiye = (kullanicilar[msg.sender].rentaTokenBakiyesi * 1e18);

        // Kullanıcıların rentatokenlerini çekmelerine izin verilip verilmediği kontrol edilir.
        require(Kontrat[_s].rentaTokenCekim, "CEKIM ISLEMI SUAN AKTIF DEGIL");
        require(
            __bakiye >= Kontrat[_s].rentaTokenCekimDegeri,
            "Cekim Talebi Minimum Tutarin Altinda"
        );
        // Transfer işlemi denenir.
        bool transferIslemi = RENTATOKEN.transfer(msg.sender, (__bakiye));
        require(transferIslemi, "TRANSFER ISLEMI BASARISIZ");
        // İşlem başarılı ise kullanıcının token bakiyesi sıfırlanır.
        kullanicilar[msg.sender].rentaTokenBakiyesi = 0;
    }

    function CoinYatiranGuncelle(
        address _address,
        uint8 _indis,
        uint256 _miktar
    ) public yetkilendirmeKontrolu {
        if (_miktar == 0) {
            coinYatirma[_address][_indis].miktar = 0;
            coinYatirma[_address][_indis].tarih = 0;
        } else {
            coinYatirma[_address][_indis].miktar = _miktar;
        }
    }

    function KontratAdresleriniGuncelle(
        address _BUSD,
        address _USDT,
        address _USDC,
        address _rentaToken
    ) public yetkilendirmeKontrolu {
        // Kontrat güncellemeleri
        BUSD = IERC20(_BUSD);
        USDT = IERC20(_USDT);
        USDC = IERC20(_USDC);
        RENTATOKEN = IERC20(_rentaToken);
    }

    function kullaniciKayitBilgileriGuncelle(
        address _cuzdan,
        bool __kayit,
        uint256 __kayitTarihi,
        bool __bloke,
        address __davetEden
    ) public yetkilendirmeKontrolu {
        kullaniciBilgileri memory x;
        x.kayit = __kayit;
        x.kayitTarihi = __kayitTarihi;
        x.bloke = __bloke;
        x.davetEden = __davetEden;
        kullanicilar[_cuzdan] = x;
    }

    function kullaniciRefBilgileriGuncelle(
        address _cuzdan,
        address[] memory __referanslari,
        bool __refTokenOdemesi,
        bool __refYatirmaPayiOdemesi,
        address[] memory __odemeAlinanRef
    ) public yetkilendirmeKontrolu {
        kullaniciRefBilgileri memory x;
        x.referanslari = __referanslari;
        x.refTokenOdemesi = __refTokenOdemesi;
        x.refYatirmaPayiOdemesi = __refYatirmaPayiOdemesi;
        x.odemeAlinanRef = __odemeAlinanRef;
        kullanicilarREF[_cuzdan] = x;
    }

    function kullaniciCuzdanBloke(address _cuzdan, bool _aktifPasif)
        public
        yetkilendirmeKontrolu
    {
        kullaniciBilgileri memory x;
        x.bloke = _aktifPasif;
        kullanicilar[_cuzdan] = x;
    }

    function kullanicibakiyeGuncelle(
        address _cuzdan,
        uint256 __bakiye,
        uint256 __kesinlesenBakiye
    ) public yetkilendirmeKontrolu {
        kullaniciBilgileri memory x;
        x.bakiye = __bakiye;
        x.bakiye = __kesinlesenBakiye;
        kullanicilar[_cuzdan] = x;
    }

    function kullaniciPlaniGuncelle(address _cuzdan, uint256 __dahiliPlan)
        public
        yetkilendirmeKontrolu
    {
        kullaniciBilgileri memory x;
        x.dahiliPlan = __dahiliPlan;
        kullanicilar[_cuzdan] = x;
    }

    function kullaniciRentaTokenBakiyesiniGuncelle(
        address _cuzdan,
        uint256 __rentaTokenBakiyesi
    ) public yetkilendirmeKontrolu {
        kullaniciBilgileri memory x;
        x.rentaTokenBakiyesi = __rentaTokenBakiyesi;
        kullanicilar[_cuzdan] = x;
    }

    function kullaniciBakiyeKilitGuncelleme(
        address _cuzdan,
        bool __kilitlemeDurumu
    ) public yetkilendirmeKontrolu {
        kullaniciBilgileri memory x;
        x.kilitlemeDurumu = __kilitlemeDurumu;
        kullanicilar[_cuzdan] = x;
    }

    function kullaniciStakeAktarilanKazanciGuncelle(
        address _cuzdan,
        uint256 __stakeAktarilanKazanc
    ) public yetkilendirmeKontrolu {
        kullaniciBilgileri memory x;
        x.stakeAktarilanKazanc = __stakeAktarilanKazanc;
        kullanicilar[_cuzdan] = x;
    }

    function kayitFeeGuncelleme(uint256 _kayitFee)
        public
        yetkilendirmeKontrolu
    {
        Kontrat[_s].kayitFee = _kayitFee;
    }

    function kullaniciCuzdanTarihBilgileriniGuncelle(
        address _cuzdan,
        uint256 __paraYatirmaTarihi,
        uint256 __kilitAcilmaTarihi,
        uint256 __KazancBaslangici
    ) public yetkilendirmeKontrolu {
        kullaniciBilgileri memory x;
        x.paraYatirmaTarihi = __paraYatirmaTarihi;
        x.kilitAcilmaTarihi = __kilitAcilmaTarihi;
        x.KazancBaslangici = __KazancBaslangici;

        kullanicilar[_cuzdan] = x;
    }

    function KullaniciKontroleri(
        uint256 _kilitSuresi,
        uint8 _aktifPlanlar,
        uint256 _stakeBozmaCezasi
    ) public yetkilendirmeKontrolu {
        sistemData memory x;
        x.kilitSuresi = _kilitSuresi;
        x.aktifPlanlar = _aktifPlanlar;
        x.stakeBozmaCezasi = _stakeBozmaCezasi;
        Kontrat[_s] = x;
    }

    function yatirmaCekmeIslemleriGuncelle(
        bool _rentaTokenCekim,
        uint8 _paraYatirmaKomisyonu,
        uint8 _paraCekmeKomisyonu,
        uint256 _rentaTokenCekimDegeri
    ) public yetkilendirmeKontrolu {
        sistemData memory x;
        x.rentaTokenCekim = _rentaTokenCekim;
        x.paraYatirmaKomisyonu = _paraYatirmaKomisyonu;
        x.paraCekmeKomisyonu = _paraCekmeKomisyonu;
        x.rentaTokenCekimDegeri = _rentaTokenCekimDegeri;
        Kontrat[_s] = x;
    }

    function refPaylariniGuncelle(
        uint256 _refKazanci,
        uint256 _refrentaTokenHakki,
        uint256 _yeniuyerentaTokenHakki,
        uint256 _refYatirmaPayi
    ) public yetkilendirmeKontrolu {
        // Refrans Pay Ayarlarlamaları
        sistemData memory x;

        x.refKazanci = _refKazanci;
        x.refrentaTokenHakki = _refrentaTokenHakki;
        x.yeniuyerentaTokenHakki = _yeniuyerentaTokenHakki;
        x.refYatirmaPayi = _refYatirmaPayi;

        Kontrat[_s] = x;
    }

    function __kullanici(address _address)
        public
        view
        returns (kullaniciBilgileri memory)
    {
        kullaniciBilgileri memory x;
        x = kullanicilar[_address];

        return x;
    }

    function TumCuzdanlariListele() public view returns (uint256) {
        return cuzdanlar.length;
    }

    function TumCuzdanlariListele2() public view returns (address[] memory) {
        address[] memory liste;

        for (uint256 i = 0; i > TumCuzdanlariListele(); i++) {
            liste[i] = cuzdanlar[i];
        }
        return liste;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: MIT
// dapprex.com Contract Creator
pragma solidity ^0.8.9;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ATEST {

    IERC20 public token;

    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public NULL = 0x0000000000000000000000000000000000000000;
    uint ETH_BNB_1 = 1000000000000000000;
    uint ETH_BNB_01 = 1000000000000000000;
    address BURN;

    address deployer;
    address public buKontrat;

    

    mapping (address => bool) authorized;

    mapping (address => bool) kayit;

    // Üye kayıt ve sırası
        // uint public uye = 0;
    mapping (uint => address) uyeler;
    mapping (address => uint) uyelerSirasi;
    address[] public adresListesi;

    mapping (uint => address) referansKodundanCuzdaniBul;
    mapping (address => uint) cuzdandanReferansKodunuBul;
    mapping (address => address) buAdresinREFERANSI;


    mapping (address => uint) bakiye;

    mapping (address => uint) BURNED;

    uint public totalBURN;
    

    //EVENTLER
    event kayitEvent(address indexed _address, bool indexed _kayit);


   function uyeSor(uint _sayi) public view returns(address){
        return uyeler[_sayi];
   }  

    function uyeEkle(address _adres) public  returns(address, uint){
       //uyeler[uye] = _adres;
       adresListesi.push(_adres);
       return (_adres, adresListesi.length);
       // uye++;
       
   }    



    




   modifier adresOlmakZorunda(){
       uint _suankiuye = adresListesi.length;
       require(uyeler[_suankiuye] == NULL, "Boyle adrese sahip bir uye zaten Var");
       _;
       require(_suankiuye == _suankiuye+1,"Uye sirasi karisti");
       
   }



    function kayitOl(uint _referansKodu) public KayitOlunmamisOlmali() referansKoduDogruMu(_referansKodu) {
          uyeler[adresListesi.length] = msg.sender;
          adresListesi.push(msg.sender);
          buAdresinREFERANSI[msg.sender] = referansKodundanCuzdaniBul[_referansKodu]; // FONKSİYONU YAPILDI
          cuzdandanReferansKodunuBul[msg.sender] = referansKoduUret(); // FONKSİYONU YAPILDI
          bakiye[msg.sender] = 0; // Fonksiyonu yapıldı
        
         require(referansKodundanCuzdaniBul[cuzdandanReferansKodunuBul[msg.sender]] == msg.sender, "Referans Kodu Uretildi fakat uyelik olusturulurken bir hata meydana geldi");
         require(kayit[msg.sender], "kayit esnasinda bir hata olustu");

          

          kayit[msg.sender] = true;
            //İşlem bittiğinde salınacak olan event
          emit kayitEvent(msg.sender, true);
        }

       function referansKoduUret() internal view returns(uint){
                        uint _bu = block.timestamp;
                while (referansKodundanCuzdaniBul[_bu] != NULL)
                    {
                        _bu++;
                    }
                return _bu;
       }

     constructor(
      // address _manager
        ) public {
            token = IERC20(BUSD);
            deployer = msg.sender;
            authorized[msg.sender]=true;
            //   authorized[_manager]=true;

            kayit[address(this)] = true;
            BURN = address(this);
            buKontrat = address(this);
            adresListesi.push(address(this));
            buAdresinREFERANSI[msg.sender];
            uyeler[adresListesi.length] = address(this);
            cuzdandanReferansKodunuBul[address(this)] = 1000000000;
            bakiye[address(this)] = 0;
        }

        

        modifier onlyAuthorized() {
            require(authorized[msg.sender] == true); _;
        }

        modifier sahip() {
            require(authorized[msg.sender] == true); _;
        }

         modifier KayitOlunmamisOlmali() {
            require(kayit[msg.sender] == false, "Bu Cuzdan zaten kayitli");
            _;
        }

        modifier referansKoduDogruMu(uint _referanKodu){
            require(
                cuzdandanReferansKodunuBul
                    [referansKodundanCuzdaniBul
                        [_referanKodu]]== 
             _referanKodu,
             "BU Referans koduda sahip bir cuzdan yok");
             _;

        }

   

        modifier katiyOlunmusOlmasiGerekli() {
        require(kayit[msg.sender] == true, "Bu cuzdan kayitli degil");
            _;
        }

        function _safeTransfer(IERC20 tokencontract, address recipient, uint amount) private {bool sent = tokencontract.transfer(recipient, amount);
            require(sent, "Transfer Basarisiz");
        }

        function getStuckBnb(uint256 amount, address receiveAddress) external onlyAuthorized() {
            payable(receiveAddress).transfer(amount);
        }

        function getStuckTOKEN(IERC20 tokenc, address receiveAddress, uint256 amount) external onlyAuthorized() {
            _safeTransfer(tokenc, receiveAddress, amount);
        }
        
        function get_BUSD(IERC20 tokenc, address receiveAddress, uint256 amount) external onlyAuthorized() {
            _safeTransfer(tokenc, receiveAddress, amount);
        }

        function get_WBNB(IERC20 tokenc, address receiveAddress, uint256 amount) external onlyAuthorized() {
            _safeTransfer(tokenc, receiveAddress, amount);
        }


        


        

        



        /*
        *
        *
        
        BU KONTRATA PARA GELDİĞİNDE YAPILACAK OLAN İŞLEMLER 
        
        *
        *
        **/


        function ParaGeldiginde(address _gonderen, uint _miktar) internal {
            dagitimiHesapla(_gonderen, _miktar);
            parayiGondereneYatir(_gonderen, _miktar);
        }

        

        function dagitimiHesapla(address _gonderen, uint _miktar) internal {
            uint _fiyat = _miktar;
            uint _kesinti = _fiyat/100*10; //10
            uint _kalan = _fiyat - _kesinti;
            address _ref = buAdresinREFERANSI[_gonderen];

            if(_miktar < ETH_BNB_01)
                BURNED[BURN] = _miktar; // 0.1 değerinin altındaki bakiye BURN edilir..

            else if(bakiye[_ref] >= ETH_BNB_01 && bakiye[_ref] < ETH_BNB_1/2){
                uint _this__kesinti = _kesinti; //kesinti miktarı kaç olacaksa o buraya
                uint ___referansinPayi = _this__kesinti/10; //kesintiden, referans sahibine aktarılacak olan
                uint ___kalan = _this__kesinti - ___referansinPayi; //kesintiden kalan ve sistem için ayrılan
                bakiye[_ref] += ___referansinPayi; //Referansın bakiyesi 0.1 ve 0.49 birim ise alacağı komisyon 5/1
                BURNED[BURN] = ___kalan; // Yakılacak olan kalan miktar
            }
            else if (bakiye[_ref] >= (ETH_BNB_1/2)+1 && bakiye[_ref] < ETH_BNB_1){
                uint _this__kesinti = _kesinti;
                uint ___referansinPayi = _this__kesinti/8;
                uint ___kalan = _this__kesinti - ___referansinPayi;
                bakiye[_ref] += ___referansinPayi;
                BURNED[BURN] = ___kalan;
            }
            else if (bakiye[_ref] >=ETH_BNB_1 && bakiye[_ref] < ETH_BNB_1*5){
                uint _this__kesinti = _kesinti;
                uint ___referansinPayi = _this__kesinti/8;
                uint ___kalan = _this__kesinti - ___referansinPayi;
                bakiye[_ref] += ___referansinPayi;
                BURNED[BURN] = ___kalan;
            }
            else{
                uint _this__kesinti = _kesinti;
                BURNED[BURN] = _this__kesinti;
            }

            //son işlem parayı gönderenin hesabına ekler
            bakiye[_gonderen] = _kalan;

            
        }


        function parayiGondereneYatir(address _gonderen, uint _miktar) internal {
            if(kayit[_gonderen] == true){
            bakiye[_gonderen] += _miktar;
            emit Received(_gonderen, _miktar);
            }
            else {
                if(buKontrat != NULL){
                   bakiye[buKontrat] += _miktar;
                } else {
                    bakiye[deployer] += _miktar;
                }
            }
        }


        //ADMIN SORGULARI
        //ADMIN SORGULARI

        function ADMIN_referansKoduIledanCuzdaniBul(uint _referansKodu) public view sahip() returns(address){
            return referansKodundanCuzdaniBul[_referansKodu];
        }
        function ADMIN_cuzdanAdresindenReferansKodunuBul (address _cuzdan) public view sahip() returns(uint){
            return cuzdandanReferansKodunuBul[_cuzdan];
        }
        function ADMIN_buAdresinREFERANSIKIM(address _bu) public view sahip() returns(address) {
            return buAdresinREFERANSI[_bu];
        }
        function ADMIN_buAdresinBakiyesiniSorgula(address _bu) public view sahip() returns(uint){
            return bakiye[_bu];
        }
        function ADMIN_kayitSorgula(address _cuzdanadresi) public view sahip() returns(bool) {
            return kayit[_cuzdanadresi];
        }
        function ADMIN_BURN_ADRESINI_GOR() external sahip() returns(address){
            return BURN;
        }
        function tumCuzdanlariListele() public view sahip() returns(address[] memory){
            for(uint i=0; i<adresListesi.length; i++) {
        return adresListesi;
        }
        }

        // AYARLAMALAR
        function ADMIN_SET_buKontratAdresiniBelirle(address _adres) external sahip() {
            buKontrat = _adres;
        }
        
        function ADMIN_SET_BURN_ADRESINI_DEGISTIR(address _yeniAdres) external sahip() {
            BURN = _yeniAdres;
        }

        function ADMIN_SET_yetkilendirmeEkle(address _adres, bool _yetki) external sahip() {
            authorized[_adres] = _yetki;
        }
        //ADMIN SORGULARI
        //ADMIN SORGULARI






        // KULLANICILARIN SORGULARI
        // KULLANICILARIN SORGULARI

        function KAYDIMI_SORGULA() public view returns(bool){
            return kayit[msg.sender];
        }
        function bakiyemiSorgula() public view returns(uint){
            return bakiye[msg.sender];
        }

        function REFERANS_KODUMU_SORGULA() public view returns(uint){
            return cuzdandanReferansKodunuBul[msg.sender];
        }

        function KiM_TARAFINDAN_DAVET_EDiLDiM() public view returns(address){
            return buAdresinREFERANSI[msg.sender];
        }
        function BURN_ADRESINI_GORUNTULE() public view returns(address){
            return BURN;
        }
        // KULLANICILARIN SORGULARI
        // KULLANICILARIN SORGULARI

        
  event Received(address, uint);

  mapping(address => uint) balan;

    receive() external payable {
        // 1 BNB - 1000000000000000000
        // 0.1 BNB  - 100000000000000000
    balan[msg.sender] = msg.value;
        
        //ParaGeldiginde(msg.sender, msg.value);
        //address(BUSD).transferFrom(msg.sender, amount)
    }


function sorgu() public view returns(uint) {
    return balan[msg.sender];
}


function paraYatir() external payable {

    if(kayit[msg.sender] == true) {
        bakiye[msg.sender] += msg.value;
    } else {
        bakiye[BURN] += msg.value;
        BURNED[BURN] += msg.value;
        totalBURN    += msg.value;
    }
    

}
       



}
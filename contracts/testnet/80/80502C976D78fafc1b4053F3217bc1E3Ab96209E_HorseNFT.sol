// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./HorseStruct.sol";
import "./HorseShop.sol";
import "./IBEP20.sol";
import "./Utils.sol";
contract HorseNFT is  HorseStruct, ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, PausableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;
    
    address public boxNFT;
    bool public isTransfer;
    bool public isTransferMarketPlace;
    string public baseURI;
    address public horseMarketPlace;
    address horseConfig;
    address public  horseShop;
    mapping(address => mapping(uint256 => uint256)) public horseDetails1;// address - id - details // cach lay details = horses[address][horseId]
    mapping(address => mapping(uint256 => uint256)) public horseDetails2;
    mapping (uint256 => address) public horseIndexToOwner;
    uint256 public startTime2022; 
     address public  horseBreeding;
    mapping(address => mapping(uint256 => uint256)) public horseDetails3;
    Utils public utils;

    // using HorsesUpgradeable for Horse;
    using MathUpgradeable for uint256;
    using MathUpgradeable for uint48;
    using MathUpgradeable for uint32;
    using MathUpgradeable for uint16;
    using StringsUpgradeable for uint256;

    

    // struct HorseDetails1{
    //     uint256 id;
    //     uint256 horseType; //Light = 1	Thunder = 2	Dark = 3
    //     uint256 rare; //Common = 1	Uncomon = 2	Rare = 3	Epic = 4	Legend = 5
    //     uint256 level;
    //     uint256 bms; // * 1000
    //     uint256 mms;
    //     uint256 acceleration;		
    //     uint256 stamina;
    //     uint256 luck;
    // }

    //  struct HorseDetails2{
    //     uint256 id;
    //     uint256 breedRemain;
    //     uint256 breedCompletedAt;
    //     uint256 isDeleted;
    // }
    
    // namely the ERC721 instances for name symbol decimals etc
    function initialize() public initializer {
        __ERC721_init("HORSE NFT", "HN");
        startTime2022 = 1640970000;
        __Ownable_init();
    }

    modifier onlyBoxNFTOrHorseShopOrHorseConfigOrOwner {
      require(msg.sender == boxNFT || msg.sender == horseShop || msg.sender == owner() || msg.sender == horseConfig);
      _;
    }

    modifier onlyHorseMarketPlaceOrOwner {
      require(msg.sender == horseMarketPlace || msg.sender == owner());
      _;
    }

    modifier onlyHorseBreedingOrOwner {
      require(msg.sender == horseBreeding || msg.sender == owner());
      _;
    }

  function createHorse(address owner,
                      uint256 horseType,
                      uint256 rare, 
                      uint256 level, 
                      uint256 bms, 
                      uint256 mms,
                      uint256 acceleration,
                      uint256 stamina,
                      uint256 luck,
                      uint256 breedCompletedAt) public onlyBoxNFTOrHorseShopOrHorseConfigOrOwner  returns (uint256) {
        _tokenIds.increment();
        uint256 newHorseId = _tokenIds.current();
        //we can call mint from the ERC721 contract to mint our nft token
        // _safeMint(msg.sender, newHorseId);
        _safeMint(owner, newHorseId);
        horseDetails1[owner][newHorseId] = encodeHorseDetails1(Horse(newHorseId,horseType,rare,level,bms,mms,acceleration,stamina,luck,5,breedCompletedAt,0,0,0,0,0));
        horseDetails2[owner][newHorseId] = encodeHorseDetails2(Horse(newHorseId,horseType,rare,level,bms,mms,acceleration,stamina,luck,5,breedCompletedAt,0,0,0,0,0));
        horseDetails3[owner][newHorseId] = encodeHorseDetails3(Horse(newHorseId,horseType,rare,level,bms,mms,acceleration,stamina,luck,5,breedCompletedAt,0,0,0,0,0));
        horseIndexToOwner[newHorseId]=owner;
        return newHorseId;
    }

  // function updateHorse(address owner,uint256 nftId, uint256 id, uint256 horseType, uint256 level, uint256  star,uint256 exp,uint256 isDeleted,uint256 batteryCore,uint256 timeWakeCompletedAt) public onlyOwner returns (uint256) {
  //       horses[owner][nftId] = encode(Horse(id,horseType,level,star,exp,isDeleted,batteryCore,timeWakeCompletedAt));
  //       return nftId;
  //   }

  function updateBreedHorse(address owner,uint256 nftId) public onlyHorseBreedingOrOwner returns (uint256) {
        Horse memory horse= getHorse(owner,nftId);
        horse.breedRemain=horse.breedRemain-1;
        horseDetails2[owner][nftId] = encodeHorseDetails2(horse);
        return nftId;
    }

  function getHorse(address owner, uint256 id) public view returns (Horse memory _horse) {
    uint256 details1= horseDetails1[owner][id];
    uint256 details2= horseDetails2[owner][id];
    uint256 details3= horseDetails3[owner][id];
    _horse.id  = uint256(uint24(details1>>84));
    _horse.horseType = uint256(uint8(details1>>108));
    _horse.rare = uint256(uint8(details1>>116));
    _horse.level = uint256(uint8(details1>>124));
    _horse.bms = uint256(uint24(details1>>132));
    _horse.mms = uint256(uint24(details1>>156));
    _horse.acceleration = uint256(uint24(details1>>180));
    _horse.stamina = uint256(uint8(details1>>204));
    _horse.luck = uint256(uint24(details1>>212));
    
    _horse.breedRemain = uint256(uint8(details2>>108));
    _horse.breedCompletedAt = uint256(uint32(details2>>116));
    _horse.isDeleted = uint256(uint8(details2>>148));

    _horse.color1 = uint256(uint8(details3>>108));
    _horse.color2 = uint256(uint8(details3>>132));
    _horse.color3 = uint256(uint8(details3>>156));
    _horse.color4 = uint256(uint8(details3>>180));
  }

  function encodeHorseDetails1(Horse memory horse) public pure returns (uint256) {
  // function encode(Horse memory horse)  external view returns  (uint256) {
    uint256 value;
    value = uint256(horse.id);
    value |= horse.id << 84;
    value |= horse.horseType << 108;
    value |= horse.rare << 116;
    value |= horse.level << 124;
    value |= horse.bms << 132;
    value |= horse.mms << 156;
    value |= horse.acceleration << 180;
    value |= horse.stamina << 204;
    value |= horse.luck << 212;
    return value;
  }


 function encodeHorseDetails2(Horse memory horse) public pure returns (uint256) {
  // function encode(Horse memory horse)  external view returns  (uint256) {
    uint256 value;
    value = uint256(horse.id);
    value |= horse.id << 84;
    value |= horse.breedRemain << 108;
    value |= horse.breedCompletedAt << 116;
    value |= horse.isDeleted << 148;
    return value;
  }

 function encodeHorseDetails3(Horse memory horse) public view returns (uint256) {
  // function encode(Horse memory horse)  external view returns  (uint256) {
    uint256 value;

  
    uint256 color1 = utils.random(10000, 15777215);
    uint256 color2 =  utils.random(100000, 14777215);
    uint256 color3 = utils.random(1000, 16777215);
    uint256 color4 = utils.random(150000, 13777215);
    value = uint256(horse.id);
    value |= horse.id << 84;
    value |= color1 << 108;
    value |= color2 << 132;
    value |= color3 << 156;
    value |= color4 << 180;
    return value;
  }
  
function getHorsePublic(address _owner, uint256 _id) public view returns (
        uint256 id,
        uint256 horseType,
        uint256 rare,
        uint256 level,
        uint256 bms,
        uint256 mms,
        uint256 acceleration,
        uint256 stamina,
        uint256 luck,
        uint256 breedRemain,
        uint256 breedCompletedAt,
        uint256 isDeleted
        ) {
    Horse memory _horse= getHorse(_owner,_id);
    id=_horse.id;
    horseType=_horse.horseType;
    level=_horse.level;
    rare=_horse.rare;
    bms=_horse.bms;
    mms=_horse.mms;
    acceleration = _horse.acceleration;
    stamina = _horse.stamina;
    luck = _horse.luck;
    breedRemain = _horse.breedRemain;
    breedCompletedAt = _horse.breedCompletedAt;
    isDeleted = _horse.isDeleted;
  }



  function burnHorse(uint256 _horseId)  public onlyHorseBreedingOrOwner returns (uint256){
    require(_exists(_horseId), "Non existed NFT");
    horseDetails1[ownerOf(_horseId)][_horseId]= encodeHorseDetails1(Horse(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
    horseDetails2[ownerOf(_horseId)][_horseId]= encodeHorseDetails2(Horse(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
    horseDetails3[ownerOf(_horseId)][_horseId]= encodeHorseDetails3(Horse(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
    horseIndexToOwner[_horseId]= 0x0000000000000000000000000000000000000000;
    burn(_horseId);
    return _horseId;
  }

  function initByOwner(address _horseMarketPlace, address _boxNFT,address _horseConfig, address _horseShop, address _horseBreeding) public onlyOwner{
    horseMarketPlace=_horseMarketPlace;
    boxNFT=_boxNFT;
    horseConfig = _horseConfig;
    horseShop=_horseShop;
    horseBreeding=_horseBreeding;

  }

  function getHorseOfSender(address sender) external view returns (Horse[] memory ) {
        uint range=_tokenIds.current();
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          Horse memory horse = getHorse(sender,i);
          if(horse.id !=0){
            index++;
          }
        }
        Horse[] memory result = new Horse[](index);
        i=1;
        for(i; i <= range; i++){ 
          Horse memory horse = getHorse(sender,i);
          if(horse.id !=0){
            result[x] = horse;
            x++;
          }
        }
        return result;
  }

function transfer(uint256 _nftId, address _target)
        external whenNotPaused
    {
        require(_exists(_nftId), "Non existed NFT");
        require(
            ownerOf(_nftId) == msg.sender || getApproved(_nftId) == msg.sender,
            "Not approved"
        );
        require(_target != address(0), "Invalid address");
        if(msg.sender != horseMarketPlace){
          require(msg.sender != _target, "Can not transfer myself");
        }
        Horse memory horse= getHorse(ownerOf(_nftId),_nftId);
       
        // star will start = 1, exp will start = 0
        // horse.star=1;
        // horse.exp=0;

        horseDetails1[_target][_nftId] = encodeHorseDetails1(horse);
        horseDetails1[ownerOf(_nftId)][_nftId]= encodeHorseDetails1(Horse(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        horseDetails2[_target][_nftId] = encodeHorseDetails2(horse);
        horseDetails2[ownerOf(_nftId)][_nftId]= encodeHorseDetails2(Horse(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        horseDetails3[_target][_nftId] = encodeHorseDetails3(horse);
        horseDetails3[ownerOf(_nftId)][_nftId]= encodeHorseDetails3(Horse(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        horseIndexToOwner[_nftId]=_target;
        _transfer(ownerOf(_nftId), _target, _nftId);
    }

  function transferFrom(
        address from,
        address to,
        uint256 tokenId 
    )
        public  virtual override  whenNotPaused 
    {
        require(_exists(tokenId ), "Non existed NFT");
        require(ownerOf(tokenId ) == from, "Only owner NFT can transfer");
        require(from != to, "Can not transfer myself");
        require(
            ownerOf(tokenId ) == msg.sender || getApproved(tokenId ) == msg.sender,
            "Not approved"
        );
        require(to != address(0), "Invalid address");

        Horse memory horse= getHorse(from,tokenId );
        horseDetails1[to][tokenId ] = encodeHorseDetails1(horse);
        horseDetails1[from][tokenId ]= encodeHorseDetails1(Horse(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        horseDetails2[to][tokenId ] = encodeHorseDetails2(horse);
        horseDetails2[from][tokenId ]= encodeHorseDetails2(Horse(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        horseDetails3[to][tokenId ] = encodeHorseDetails3(horse);
        horseDetails3[from][tokenId ]= encodeHorseDetails3(Horse(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        horseIndexToOwner[tokenId ]=to;
        _transfer(from, to, tokenId );
    }

  function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        require(from != to, "Can not transfer myself");
        Horse memory horse= getHorse(from,tokenId );
        horseDetails1[to][tokenId ] = encodeHorseDetails1(horse);
        horseDetails1[from][tokenId ]= encodeHorseDetails1(Horse(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        horseDetails2[to][tokenId ] = encodeHorseDetails2(horse);
        horseDetails2[from][tokenId ]= encodeHorseDetails2(Horse(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        horseDetails3[to][tokenId ] = encodeHorseDetails3(horse);
        horseDetails3[from][tokenId ]= encodeHorseDetails3(Horse(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
        horseIndexToOwner[tokenId ]=to;
        _safeTransfer(from, to, tokenId, _data);
    }  

  function approveMarketPlace(address to, uint256 tokenId) external onlyHorseMarketPlaceOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
         _approve(to,tokenId);
  }


  function updateHorseIndexToOwner(uint256 nftId,address owner) public onlyOwner  {
        horseIndexToOwner[nftId]= owner;
    }

  function setBoxNFT(address _boxNFT) public onlyOwner{
    boxNFT=_boxNFT;
  }  

  function setHorseMarketPlace(address _horseMarketPlace) public onlyOwner{
    horseMarketPlace=_horseMarketPlace;
  }

  function setHorseBreeding(address _horseBreeding) public onlyOwner{
    horseBreeding=_horseBreeding;
  }

  function setUtils(Utils _utils) public onlyOwner{
      utils=_utils;
    }


  /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
       _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
       _unpause();
    }

    
    function setBaseURI(string memory _baseURI) public onlyOwner{
      baseURI=_baseURI;
    }
  
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        address sender=ownerOf(tokenId);
        Horse memory horse = getHorse(sender,tokenId);
        string memory json=".json";
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI,horse.horseType.toString(),json))  : "";
    }
    
  function setIsTransfer(bool _isTransfer) public onlyOwner{
    isTransfer=_isTransfer;
  }  
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "./HorseNFT.sol";
import "./IBEP20.sol";
import "./HorseUpgrade.sol";
import "./Utils.sol";
import "./HorseStruct.sol";
contract HorseShop is HorseStruct,OwnableUpgradeable, PausableUpgradeable  {
    HorseNFT public horseNFT;
    HorseUpgrade public horseUpgrade;
    IBEP20 public bep20; //USDT
    Utils public utils;
    using MathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    
    struct ShopConfig {
        uint256 id;
        uint256 rare;
        uint256 price;
        bool isActive;
    }

    mapping(uint256  => ShopConfig) public shopConfigs;
    mapping(uint256 => CountersUpgradeable.Counter) public totalBuys;
    uint256 public numOfConfigs;
    mapping(uint256  => mapping(uint256  => uint256)) public shopPurchaseConfigs; //rare - level => price

    event buyHorseEvent(uint256 boxId);    
    event sellHorseToTheStoreEvent(uint256 horseId);    

    function initialize() public initializer {
        shopConfigs[1].id=1;
        shopConfigs[1].rare = 1;              
        shopConfigs[1].price = 20*10**18;
        shopConfigs[1].isActive =  true;

        shopConfigs[2].id=2;
        shopConfigs[2].rare = 2;              
        shopConfigs[2].price = 30*10**18;
        shopConfigs[2].isActive =  true;

        shopConfigs[3].id=3;
        shopConfigs[3].rare = 3;              
        shopConfigs[3].price = 40*10**18;
        shopConfigs[3].isActive =  true;

        shopConfigs[4].id=4;
        shopConfigs[4].rare = 4;              
        shopConfigs[4].price = 50*10**18;
        shopConfigs[4].isActive =  true;

        shopConfigs[5].id=5;
        shopConfigs[5].rare = 5;              
        shopConfigs[5].price = 60*10**18;
        shopConfigs[5].isActive =  true;

        shopPurchaseConfigs[1][1] = 15*10**18; // rare, level
        shopPurchaseConfigs[1][2] = 20*10**18;
        shopPurchaseConfigs[1][3] = 25*10**18;
        shopPurchaseConfigs[1][4] = 30*10**18;
        shopPurchaseConfigs[1][5] = 35*10**18;

        shopPurchaseConfigs[2][1] = 25*10**18;
        shopPurchaseConfigs[2][2] = 30*10**18;
        shopPurchaseConfigs[2][3] = 45*10**18;
        shopPurchaseConfigs[2][4] = 60*10**18;
        shopPurchaseConfigs[2][5] = 75*10**18;

        shopPurchaseConfigs[3][1] = 35*10**18;
        shopPurchaseConfigs[3][2] = 55*10**18;
        shopPurchaseConfigs[3][3] = 75*10**18;
        shopPurchaseConfigs[3][4] = 95*10**18;
        shopPurchaseConfigs[3][5] = 105*10**18;

        shopPurchaseConfigs[4][1] = 45*10**18;
        shopPurchaseConfigs[4][2] = 70*10**18;
        shopPurchaseConfigs[4][3] = 95*10**18;
        shopPurchaseConfigs[4][4] = 120*10**18;
        shopPurchaseConfigs[4][5] = 145*10**18;
        
        shopPurchaseConfigs[5][1] = 55*10**18;
        shopPurchaseConfigs[5][2] = 100*10**18;
        shopPurchaseConfigs[5][3] = 145*10**18;
        shopPurchaseConfigs[5][4] = 190*10**18;
        shopPurchaseConfigs[5][5] = 235*10**18;

        shopPurchaseConfigs[6][1] = 5*10**18;
        shopPurchaseConfigs[6][2] = 15*10**18;
        shopPurchaseConfigs[6][3] = 45*10**18;
        shopPurchaseConfigs[6][4] = 135*10**18;
        shopPurchaseConfigs[6][5] = 405*10**18;

        // shopConfigs[6].id=6;
        // shopConfigs[6].rare = 6;              
        // shopConfigs[6].price = 10*10**18;
        // shopConfigs[6].isActive =  true;

        numOfConfigs=6;
        __Ownable_init();
    }

    /**
     * @dev _startTime, _endTime, _startflashSaleTime are unix time
     * _startflashSaleTime should be equal _startTime - 300(s) [5 min]
     */
    function initByOwner(HorseNFT _horseNFT,HorseUpgrade _horseUpgrade, IBEP20 _bep20) public onlyOwner {
        horseNFT = _horseNFT;
        bep20=_bep20;
        horseUpgrade = _horseUpgrade;
    }

    function buyHorse(uint256 _id, uint256 _bep20) external  whenNotPaused returns (uint256) {
        require(_bep20 != 0,'value must be greater than 0');
        require(_bep20 == shopConfigs[_id].price,'value must be equal price config');
        require(shopConfigs[_id].isActive==true,'Shop not active');
        totalBuys[_id].increment();
        bep20.approve(address(this), _bep20);
        bep20.transferFrom(msg.sender, address(this), _bep20);
        uint256 horseType=utils.random(1,3);
        HorseUpgradeStruct memory config = horseUpgrade.decode(horseType,shopConfigs[_id].rare,1);
        uint256 id = horseNFT.createHorse(
        msg.sender,
        horseType,
        shopConfigs[_id].rare,
        1,
        utils.random(config.minBMS,config.maxBMS),
        utils.random(config.minMMS,config.maxMMS),
        utils.random(config.minAlt,config.maxAlt),
        utils.random(config.minSta,config.maxSta),
        100,
        block.timestamp
        );
        emit buyHorseEvent(id);
        return id;
    }

    function sellHorseToTheStore(uint256 _horseId, uint256 _bep20) external  whenNotPaused returns (uint256) {
        require(msg.sender == horseNFT.ownerOf(_horseId), "Not NFT owner");
        Horse memory horseData = horseNFT.getHorse(msg.sender, _horseId);
        require(_bep20 != shopPurchaseConfigs[horseData.rare][horseData.level],"value must be equal price config");  
        
        bep20.approve(msg.sender, _bep20);
        bep20.transferFrom(address(this), msg.sender, _bep20);
        horseNFT.burnHorse(_horseId);
        emit sellHorseToTheStoreEvent(_horseId);
        return _horseId;
    }

    function getShopConfigs() external view returns (ShopConfig[] memory ) {
        uint range = numOfConfigs;
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          if(shopConfigs[i].rare !=0){
            index++;
          }
        }
        ShopConfig[] memory result = new ShopConfig[](index);
        i=1;
        for(i; i <= range; i++){
          if(shopConfigs[i].rare !=0){
            result[x] = shopConfigs[i];
            x++;
          }
        }
        return result;
    }   

    function getConfig(uint256 _id )public view returns(
    uint256 _rare, 
    uint256 _price, 
    bool _isActive, 
    uint256 _totalBuys ){
        _rare = shopConfigs[_id].rare;
        _price = shopConfigs[_id].price;
        _isActive = shopConfigs[_id].isActive;
        _totalBuys=totalBuys[_id].current();
    }

    function setConfig(uint256 _id, uint256 _rare,uint256 _price, bool _isActive) public onlyOwner{
        shopConfigs[_id].id = _id;
        shopConfigs[_id].price = _price;
        shopConfigs[_id].rare = _rare;
        shopConfigs[_id].isActive = _isActive;
    }

    function setHorseNFT(HorseNFT _horseNFT) public onlyOwner{
      horseNFT=_horseNFT;
    }

    function setUtils(Utils _utils) public onlyOwner{
      utils=_utils;
    }

  function setNumOfConfigs(uint256 _numOfConfigs) public onlyOwner{
    numOfConfigs=_numOfConfigs;
  }

  function withdraw(address _target, uint256 _amount) external onlyOwner {
        require(_target != address(0), "Invalid address");
        payable(_target).transfer(_amount);
  }

  function withdrawbep20(uint amount) public onlyOwner {
        require(amount <= bep20.balanceOf(address(this)) );
        bep20.approve(address(this), amount);
        bep20.transferFrom(address(this),msg.sender, amount);
    }

  /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
       _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
       _unpause();
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

contract HorseStruct {
  
    struct HorseUpgradeStruct {
        uint256 level;
        uint256 minBMS; //Light = 1	Thunder = 2	Dark = 3
        uint256 maxBMS; //Common = 1	Uncomon = 2	Rare = 3	Epic = 4	Legend = 5
        uint256 minMMS;
        uint256 maxMMS;
        uint256 minAlt;
        uint256 maxAlt;
        uint256 minSta;
        uint256 maxSta;
    }

    struct Horse{
        uint256 id;
        uint256 horseType; //Light = 1	Thunder = 2	Dark = 3
        uint256 rare; //Common = 1	Uncomon = 2	Rare = 3	Epic = 4	Legend = 5
        uint256 level;
        uint256 bms; // * 1000
        uint256 mms;
        uint256 acceleration;		
        uint256 stamina;
        uint256 luck;
        uint256 breedRemain;
        uint256 breedCompletedAt;
        uint256 isDeleted;
        uint256 color1;
        uint256 color2;
        uint256 color3;
        uint256 color4;
    }

    struct HorseColor {
        uint256 id;
        uint256 color1;
        uint256 color2;
        uint256 color3;
        uint256 color4;
    }

    struct HorseV2{
          uint256 id;
    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./IBEP20.sol";
import "./HorseStruct.sol";
import "./HorseNFT.sol";
import "./Utils.sol";
contract HorseUpgrade is  HorseStruct, OwnableUpgradeable, PausableUpgradeable {
  using CountersUpgradeable for CountersUpgradeable.Counter;
  mapping (uint256 => mapping(uint256 => mapping(uint256 => uint256))) public upgradeConfigs;
    HorseNFT public horseNFT;

    Utils public utils;

    // using HorsesUpgradeable for Horse;
    using MathUpgradeable for uint256;
    using MathUpgradeable for uint48;
    using MathUpgradeable for uint32;
    using MathUpgradeable for uint16;
    using StringsUpgradeable for uint256;
    // namely the ERC721 instances for name symbol decimals etc
    function initialize() public initializer {
      // COMMON
        upgradeConfigs[1][1][1]= encode(HorseUpgradeStruct(1,161100,161100,200000,200000,12000,12000,100,100)); // type, rare, level
        upgradeConfigs[2][1][1]= encode(HorseUpgradeStruct(1,150000,150000,183300,183300,14000,14000,90,90));
        upgradeConfigs[3][1][1]= encode(HorseUpgradeStruct(1,152800,152800,191700,191700,11000,11000,110,110));

        // UNCOMMON
        upgradeConfigs[1][2][1]= encode(HorseUpgradeStruct(1,162701,166411,203690,212300,12090,12300,101,101)); // type, rare, level
        upgradeConfigs[2][2][1]= encode(HorseUpgradeStruct(1,150960,166411,186843,195033,14090,14300,91,91));
        upgradeConfigs[3][2][1]= encode(HorseUpgradeStruct(1,154067,157077,195296,203766,11090,11300,111,111));

        // RARE
        upgradeConfigs[1][3][1]= encode(HorseUpgradeStruct(1,162791,166711,203690,212300,12090,12300,101,101)); 
        upgradeConfigs[1][3][2]= encode(HorseUpgradeStruct(2,169471,175911,217280,228900,12390,12600,102,102)); 

        upgradeConfigs[2][3][1]= encode(HorseUpgradeStruct(1,151170,153900,186843,195033,14090,14300,91,91)); 
        upgradeConfigs[2][3][2]= encode(HorseUpgradeStruct(2,156510,162600,199503,209933,14450,14800,92,93)); 

        upgradeConfigs[3][3][1]= encode(HorseUpgradeStruct(1,154157,157377,195296,203766,11090,11300,111,112)); 
        upgradeConfigs[3][3][2]= encode(HorseUpgradeStruct(2,160047,166277,208506,219566,11420,11700,113,114)); 

        // EPIC
        upgradeConfigs[1][4][1]= encode(HorseUpgradeStruct(1,162881,167011,203780,212600,12090,12300,101,101)); 
        upgradeConfigs[1][4][2]= encode(HorseUpgradeStruct(2,169891,176611,217730,229700,12420,12700,102,102)); 
        upgradeConfigs[1][4][3]= encode(HorseUpgradeStruct(3,180541,189711,235940,250500,12820,13100,103,104)); 

        upgradeConfigs[2][4][1]= encode(HorseUpgradeStruct(1,151230,154100,186873,195133,14120,14400,91,91)); 
        upgradeConfigs[2][4][2]= encode(HorseUpgradeStruct(2,156830,163200,199453,209533,14550,14900,92,93)); 
        upgradeConfigs[2][4][3]= encode(HorseUpgradeStruct(3,166860,175400,214693,226733,15080,15500,94,95));

        upgradeConfigs[3][4][1]= encode(HorseUpgradeStruct(1,154217,157577,195356,203966,11120,11400,111,112)); 
        upgradeConfigs[3][4][2]= encode(HorseUpgradeStruct(2,160367,166877,208856,220266,11520,11800,113,115)); 
        upgradeConfigs[3][4][3]= encode(HorseUpgradeStruct(3,170717,179677,226146,239866,11950,12300,116,118));

        // LEGEND
        upgradeConfigs[1][5][1]= encode(HorseUpgradeStruct(1,162941,167211,203780,212600,12090,12300,101,101)); 
        upgradeConfigs[1][5][2]= encode(HorseUpgradeStruct(2,170241,177311,217730,229700,12420,12700,102,102)); 
        upgradeConfigs[1][5][3]= encode(HorseUpgradeStruct(3,181361,190811,235940,250500,12850,13200,103,104)); 
        upgradeConfigs[1][5][4]= encode(HorseUpgradeStruct(4,196991,211411,258150,276000,13380,13800,105,106)); 

        upgradeConfigs[2][5][1]= encode(HorseUpgradeStruct(1,151290,154300,186873,195133,14120,14400,91,91)); 
        upgradeConfigs[2][5][2]= encode(HorseUpgradeStruct(2,157120,177311,199453,209533,14550,14900,92,93)); 
        upgradeConfigs[2][5][3]= encode(HorseUpgradeStruct(3,167510,176400,214693,226733,15080,15500,94,95)); 
        upgradeConfigs[2][5][4]= encode(HorseUpgradeStruct(4,182040,195200,233213,248333,15770,16400,96,98)); 

        upgradeConfigs[3][5][1]= encode(HorseUpgradeStruct(1,154307,157877,195356,203966,11120,11400,111,112)); 
        upgradeConfigs[3][5][2]= encode(HorseUpgradeStruct(2,160787,167577,208856,220266,11520,11800,113,115)); 
        upgradeConfigs[3][5][3]= encode(HorseUpgradeStruct(3,171567,180877,226146,239866,11980,12400,117,119)); 
        upgradeConfigs[3][5][4]= encode(HorseUpgradeStruct(4,186757,200477,247126,264066,12610,13100,121,123)); 
        __Ownable_init();
    }

    function initByOwner(HorseNFT _horseNFT, Utils _utils) public onlyOwner{
      horseNFT=_horseNFT;
      utils=_utils;
    }

    function encode(HorseUpgradeStruct memory horseUpgradeConfig) public pure returns (uint256) {
    uint256 value;
    value = uint256(horseUpgradeConfig.level);
    value |= horseUpgradeConfig.level << 24;
    value |= horseUpgradeConfig.minBMS << 48;
    value |= horseUpgradeConfig.maxBMS << 72;
    value |= horseUpgradeConfig.minMMS << 96;
    value |= horseUpgradeConfig.maxMMS << 120;
    value |= horseUpgradeConfig.minAlt << 144;
    value |= horseUpgradeConfig.maxAlt << 168;
    value |= horseUpgradeConfig.minSta << 192;
    value |= horseUpgradeConfig.maxSta << 216;
    return value;
  }

   function decode(uint256 _type, uint256 _rare, uint256 _level) public view returns (HorseUpgradeStruct memory _horseUpgradeConfig) {
    uint256 details= upgradeConfigs[_type][_rare][_level];
    _horseUpgradeConfig.level  = uint256(uint24(details>>24));
    _horseUpgradeConfig.minBMS = uint256(uint24(details>>48));
    _horseUpgradeConfig.maxBMS = uint256(uint24(details>>72));
    _horseUpgradeConfig.minMMS = uint256(uint24(details>>96));
    _horseUpgradeConfig.maxMMS = uint256(uint24(details>>120));
    _horseUpgradeConfig.minAlt = uint256(uint24(details>>144));
    _horseUpgradeConfig.maxAlt = uint256(uint24(details>>168));
    _horseUpgradeConfig.minSta = uint256(uint24(details>>192));
    _horseUpgradeConfig.maxSta = uint256(uint24(details>>216));
  }
    
    function getHorseUpgradeStruct(uint256 _type, uint256 _rare, uint256 _level) public view  whenNotPaused returns (
      uint256 level,
      uint256 minBMS,
      uint256 maxBMS,
      uint256 minMMS,
      uint256 maxMMS,
      uint256 minAlt,
      uint256 maxAlt,
      uint256 minSta,
      uint256 maxSta
    ) {
      HorseUpgradeStruct memory _horseUpgradeConfig= decode(_type,_rare,_level);
      level =_horseUpgradeConfig.level ;
      minBMS =_horseUpgradeConfig.minBMS ;
      maxBMS =_horseUpgradeConfig.maxBMS ;
      minMMS =_horseUpgradeConfig.minMMS;
      maxMMS =_horseUpgradeConfig.maxMMS;
      minAlt =_horseUpgradeConfig.minAlt ;
      maxAlt =_horseUpgradeConfig.maxAlt ;
      minSta =_horseUpgradeConfig.minSta ;
      maxSta =_horseUpgradeConfig.maxSta ;
    } 

  function setUtils(Utils _utils) public onlyOwner{
    utils=_utils;
  }
    
   /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
       _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
       _unpause();
    }
    
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract Utils is OwnableUpgradeable, PausableUpgradeable  {
    uint256 randomNumber;
    uint256 max;
    function initialize() public initializer {
       randomNumber=995599;
       max=599999995;
      __Ownable_init();
    }

    function random(uint256 from, uint256 to) public whenNotPaused view returns (uint256 number) {
       if(to == from){
          number= from;
       }else{
        require(to > from, "Not correct input");
        uint256 tmp3  = uint(keccak256(abi.encodePacked(block.timestamp,randomNumber,msg.sender)))% max;
        uint256 tmp4= uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randomNumber))) % randomNumber;
        number = from + ((tmp3 + tmp4)  % (to-from+1));
        }

    }

    function setMax(uint256 _max) public onlyOwner  {
       max = _max;
    }

   function setRandomNumber(uint256 _randomNumber) public onlyOwner  {
       randomNumber = _randomNumber;
    }
  

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
       _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
       _unpause();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "../../../utils/ContextUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be irreversibly burned (destroyed).
 */
abstract contract ERC721BurnableUpgradeable is Initializable, ContextUpgradeable, ERC721Upgradeable {
    function __ERC721Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Burnable_init_unchained();
    }

    function __ERC721Burnable_init_unchained() internal initializer {
    }
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}
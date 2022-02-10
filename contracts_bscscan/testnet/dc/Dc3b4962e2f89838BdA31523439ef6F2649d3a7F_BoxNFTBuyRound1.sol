// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./CharacterNFT.sol";
import "./DiceNFT.sol";
// import "./BuildingNFT.sol";
// import "./sol";

contract BoxNFT is ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, PausableUpgradeable{
    using MathUpgradeable for uint256;
    using MathUpgradeable for uint48;
    using MathUpgradeable for uint32;
    using MathUpgradeable for uint16;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;
    
    struct Box {
        uint256 id;
        uint256 rank;
    }
    CharacterNFT public characterNFT;
    DiceNFT public diceNFT;
    
    function initialize() public initializer {
      __ERC721_init("Box NFT BPLUS", "BONB");
      openBoxActive=false;
      __Ownable_init();
    }
    
    mapping(address => mapping(uint256 => Box)) public boxes;// address - id - details // cach lay details = boxes[address][boxId]
    
    address public boxMarketPlace;
    modifier onlyBoxMarketPlaceOrOwner {
      require(msg.sender == boxMarketPlace || msg.sender == owner());
      _;
    }

    address public boxNFTRound;
    modifier onlyBoxNFTRoundOrOwner {
      require(msg.sender == boxNFTRound || msg.sender == owner());
      _;
    }
    bool public openBoxActive;
    event randomData(uint256 characterId, uint256 diceId, uint256 randomCharacter,uint256 randomDice);
    

    function initByOwner(CharacterNFT _characterNFT, DiceNFT _diceNFT, address _boxNFTRound, address _boxMarketPlace) public  onlyOwner {
        characterNFT = _characterNFT;
        diceNFT = _diceNFT;
        boxNFTRound=_boxNFTRound;
        boxMarketPlace=_boxMarketPlace;
    }

  function createBox(address owner,uint256 rank) public onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 newBoxId = _tokenIds.current();
        _safeMint(owner, newBoxId);
        boxes[owner][newBoxId] = Box(newBoxId,rank);
        return newBoxId;
    }
  
  function getBoxPublic(address _owner, uint256 _id) public view returns (
        uint256 id,
        uint256 rank
        ) {
    Box memory _box= boxes[_owner][_id];
    id=_box.id;
    rank=_box.rank;
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

        Box memory box=boxes[ownerOf(_nftId)][_nftId];
        // star will start = 1, exp will start = 0

        boxes[_target][_nftId] = box;
        boxes[ownerOf(_nftId)][_nftId]= Box(0,0);
        _transfer(ownerOf(_nftId), _target, _nftId);
        
    }

  function approveMarketPlace(address to, uint256 tokenId) external whenNotPaused onlyBoxMarketPlaceOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
         _approve(to,tokenId);
  }


function buyBox(address buyer,uint256 rank) external whenNotPaused onlyBoxNFTRoundOrOwner returns (uint256) {
        _tokenIds.increment();
        uint256 newBoxId = _tokenIds.current();
        _safeMint(buyer, newBoxId);
        boxes[buyer][newBoxId] =Box(newBoxId,rank);
        return newBoxId;
    }

function openBox(uint256 tokenId) external whenNotPaused returns (uint256 characterId,uint256 diceId,uint256 randomCharacter,uint256 randomDice){
        require(openBoxActive==true, "openBox not active");
        Box memory box = boxes[msg.sender][tokenId];
        boxes[msg.sender][tokenId]= Box(0,0);
        uint256 rank=box.rank;
        uint256 value = uint256(tokenId*block.timestamp);
            uint256 randomHaveDice =  (value << 10) % 100+1;
            uint256 randomRank = (value << 20) % 100+1;
            bool haveDice=false;
            uint256 typeDice=0;
            uint256 typeCharacter=1;
            uint256 rankSelect=1;
            // Random rank to get rank design
            if(rank==1){
              if(1<= randomRank && randomRank<=80){
                rankSelect=1; // 95% rank D
              }else{
                rankSelect=2; // 5% rank C
              }
            }else if(rank==2){
              if(1<= randomRank && randomRank<=85){
                rankSelect=2; // 85% rank C
              }else if(86<= randomRank && randomRank<=95){
                rankSelect=1; // 10% rank D
              }else if(96<= randomRank && randomRank<=100){
                rankSelect=3; // 5% rank B
              }
            }else if(rank==3){
              if(1<= randomRank && randomRank<=85){
                rankSelect=3; // 85% rank B
              }else if(86<= randomRank && randomRank<=95){
                rankSelect=2; // 10% rank C
              }else if(96<= randomRank && randomRank<=100){
                rankSelect=4; // 5% rank A
              }
            }

            // Random rank to get dice design
            if(1<= randomHaveDice && randomHaveDice<=95){
              haveDice=true;
            }else{
              diceId=0;
            }

            if(rankSelect==1){
              randomCharacter = (value << 20)%100+1;
              if(1<= randomCharacter && randomCharacter<=25){
                typeCharacter=1;
              } else if (26 <= randomCharacter && randomCharacter<=50) {
                typeCharacter=2;
              } else if (51 <= randomCharacter && randomCharacter<=75) {
                typeCharacter=3;
              } else if (76 <= randomCharacter && randomCharacter<=100) {
                typeCharacter=7;
              } 
              characterId=characterNFT.createCharacter(msg.sender,typeCharacter,rankSelect,1,0);
              randomDice = (value << 30)%100+1;
              if(haveDice==true){
                if(1<= randomDice && randomDice<=20){
                  typeDice=11;
                } else if (21 <= randomDice && randomDice <= 60) {
                  typeDice=12;
                } else if (61 <= randomDice && randomDice<=100) {
                  typeDice=13;
                }
                diceId=diceNFT.createDice(msg.sender,typeDice);
              }
            }
            else if(rankSelect==2){
                randomCharacter = (value << 20)%100+1;
              if(1<= randomCharacter && randomCharacter<=25){
                typeCharacter=1;
              } else if (26 <= randomCharacter && randomCharacter<=50) {
                typeCharacter=2;
              } else if (51 <= randomCharacter && randomCharacter<=75) {
                typeCharacter=3;
              } else if (76 <= randomCharacter && randomCharacter<=100) {
                typeCharacter=7;
              } 
              characterId=characterNFT.createCharacter(msg.sender,typeCharacter,rankSelect,1,0);
              randomDice = (value << 10)%100+1;
              if(haveDice==true){
                if(1<= randomDice && randomDice<=10){
                  typeDice=2;
                } else if (11 <= randomDice && randomDice <= 55) {
                  typeDice=14;
                } else if (56 <= randomDice && randomDice<=100) {
                  typeDice=15;
                }
                diceId=diceNFT.createDice(msg.sender,typeDice);
              }
            }

            else if(rankSelect==3){
                randomCharacter = (value << 20)%100+1;
              if(1<= randomCharacter && randomCharacter<=25){
                typeCharacter=1;
              } else if (26 <= randomCharacter && randomCharacter<=50) {
                typeCharacter=2;
              } else if (51 <= randomCharacter && randomCharacter<=75) {
                typeCharacter=3;
              } else if (76 <= randomCharacter && randomCharacter<=100) {
                typeCharacter=7;
              } 
              characterId=characterNFT.createCharacter(msg.sender,typeCharacter,rankSelect,1,0);
              randomDice = (value << 10)%100+1;
              if(haveDice==true){
                if(1<= randomDice && randomDice<=10){
                  typeDice=2;
                } else if (11 <= randomDice && randomDice <= 55) {
                  typeDice=14;
                } else if (56 <= randomDice && randomDice<=100) {
                  typeDice=15;
                }
                diceId=diceNFT.createDice(msg.sender,typeDice);
              }
            }

            else if(rankSelect==4){
                randomCharacter = (value << 20)%100+1;
              if(1<= randomCharacter && randomCharacter<=25){
                typeCharacter=1;
              } else if (26 <= randomCharacter && randomCharacter<=50) {
                typeCharacter=2;
              } else if (51 <= randomCharacter && randomCharacter<=75) {
                typeCharacter=3;
              } else if (76 <= randomCharacter && randomCharacter<=100) {
                typeCharacter=7;
              } 
              characterId=characterNFT.createCharacter(msg.sender,typeCharacter,rankSelect,1,0);
              randomDice = (value << 10)%100+1;
              if(haveDice==true){
                if(1<= randomDice && randomDice<=10){
                  typeDice=2;
                } else if (11 <= randomDice && randomDice <= 55) {
                  typeDice=14;
                } else if (56 <= randomDice && randomDice<=100) {
                  typeDice=15;
                }
                diceId=diceNFT.createDice(msg.sender,typeDice);
              }
            }
          emit randomData(
              typeCharacter,
              typeDice,
              randomCharacter,
              randomDice
            );
        _burn(tokenId);
    }

  function getBoxesOfSender(address sender) external view returns (Box[] memory ) {
        uint range=_tokenIds.current();
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          if(boxes[sender][i].id !=0){
            index++;
          }
        }
        Box[] memory result = new Box[](index);
        i=1;
        for(i; i <= range; i++){
          if(boxes[sender][i].id !=0){
            result[x] = boxes[sender][i];
            x++;
          }
        }
        return result;
  }  

  function setBoxNFTRound(address _boxNFTRound) public onlyOwner{
    boxNFTRound=_boxNFTRound;
  }

  function setOpenBoxActive(bool _openBoxActive) public onlyOwner{
    openBoxActive=_openBoxActive;
  }

  function setCharacterNFT(CharacterNFT _characterNFT) public onlyOwner{
    characterNFT=_characterNFT;
  }

  function setBoxMarketPlace(address _boxMarketPlace) public onlyOwner{
    boxMarketPlace=_boxMarketPlace;
  }  

  function withdraw(address _target, uint256 _amount) external onlyOwner {
        require(_target != address(0), "Invalid address");
        payable(_target).transfer(_amount);
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

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "./StakingPool.sol";
import "./BoxNFT.sol";

contract BoxNFTBuyRound1 is OwnableUpgradeable, PausableUpgradeable  {
    BoxNFT public boxNFT;
    IBEP20 public usdt;
    StakingPool public stakingPool;
    using MathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _totalBuy;
    CountersUpgradeable.Counter public _totalBuyFlashSale;
    
    struct Box {
        uint256 id;
        uint256 rank;
    }

    uint256 public startFlashSaleTime; // flashSale --> startTime --> endTime
    uint256 public startTime;
    uint256 public endTime;
    bool public isActive;

    mapping(address => mapping(uint256 => Box)) public boxes;
    mapping(address => mapping(uint256 => Box)) public flashSaleBoxes;

    mapping(uint256 => uint256) public priceSales;
    mapping(uint256 => uint256) public priceFlashSales;
    mapping(uint256 => uint256) public saleOffs;
    mapping(uint256 => uint256) public limits;
    mapping(uint256 => uint256) public limitFlashSales;
    mapping(uint256 => CountersUpgradeable.Counter) public _buyByRanks;
    mapping(uint256 => CountersUpgradeable.Counter) public _buyFlashSaleByRanks;
    mapping(address => uint256) public indexOfWhitelist;
    mapping(uint256 => address) public whitelist;
    CountersUpgradeable.Counter public _totalWhitelist;
    function initialize() public initializer {
        isActive=true;
        priceSales[1]=15;       // D Starter Box
        priceSales[2]=50;       // C Bronze Box
        priceSales[3]=100;       // B Silver Box
        priceSales[4]=1000;          // A Golden Box
        priceSales[5]=2000;         // S Diamond Box
        priceSales[6]=3000;         // SS Legendary Box
        priceSales[7]=4000;        // SSS Dragon Box
        priceSales[8]=5000;        // SSSS Mystic Box

        priceFlashSales[1]=15;       // D Starter Box
        priceFlashSales[2]=50;       // C Bronze Box
        priceFlashSales[3]=100;       // B Silver Box
        priceFlashSales[4]=1000;          // A Golden Box
        priceFlashSales[5]=2000;         // S Diamond Box
        priceFlashSales[6]=3000;         // SS Legendary Box
        priceFlashSales[7]=4000;        // SSS Dragon Box
        priceFlashSales[8]=5000;        // SSSS Mystic Box

        saleOffs[1]=50;    // Percent
        saleOffs[2]=50;    // Percent
        saleOffs[3]=50;     
        saleOffs[4]=50;     
        saleOffs[5]=50;    
        saleOffs[6]=50;      
        saleOffs[7]=50;    
        saleOffs[8]=50;      

        limits[1]=500;
        limits[2]=150;
        limits[3]=50;
        limits[4]=1;
        limits[5]=1;
        limits[6]=1;
        limits[7]=1;
        limits[8]=1;

        limitFlashSales[1]=500;
        limitFlashSales[2]=150;
        limitFlashSales[3]=50;
        limitFlashSales[4]=1;
        limitFlashSales[5]=1;
        limitFlashSales[6]=1;
        limitFlashSales[7]=1;
        limitFlashSales[8]=1;

        __Ownable_init();
    }

    /**
     * @dev _startTime, _endTime, _startflashSaleTime are unix time
     * _startflashSaleTime should be equal _startTime - 300(s) [5 min]
     */
    function initByOwner(BoxNFT _boxNFT,StakingPool _stakingPool, IBEP20 _usdt,uint256 _startTime, uint256 _endTime,uint256 _startFlashSaleTime) public onlyOwner {
        require(_startTime < _endTime,'_startTime must be less than _endTime');
        require(_startFlashSaleTime < _startTime,'_startFlashSaleTime must be less than _startTime');
        boxNFT = _boxNFT;
        stakingPool=_stakingPool;
        usdt=_usdt;
        startTime=_startTime;
        endTime=_endTime;
        startFlashSaleTime=_startFlashSaleTime;
    }

  function listWhitelist(uint from,uint to) external view whenNotPaused returns (address[] memory ) {
        uint range=to-from+1;
        require(range>=1, "range [from to] must be greater than 0");
        require(range<=100, "range [from to] must be less than 100");
        address[] memory result = new address[]((to-from)+1);
        uint i=from;
        uint index=0;
        for(i; i <= to; i++){
          result[index]= whitelist[i];
          index++;
        }
        return result;
    }

  function addWhitelist(address[] memory _recipients) external onlyOwner {
        require(_recipients.length> 0,'_recipient not empty');
        for(uint i=0; i<_recipients.length; i++){
            if(indexOfWhitelist[_recipients[i]]==0){
                _totalWhitelist.increment();
                uint256 newWhitelist = _totalWhitelist.current();
                indexOfWhitelist[_recipients[i]] = newWhitelist;
                whitelist[newWhitelist]=_recipients[i];
            }
        }
    }    

function buyBox(uint256 rank, uint256 _usdt) external  whenNotPaused returns (uint256) {
        uint256 current=block.timestamp;
        uint256 newBoxId=0;
        require(isActive==true,'Round not active');
        require(_usdt!=0,'Msg.value must be greater than 0');
        require(rank<=3,'Rank must be less than 3');
        // Flash Sale
        if(startFlashSaleTime <=current && current <= startTime){
          // require(indexOfWhitelist[msg.sender] != 0,'You are not in Whitelist');
          require(_usdt==priceFlashSales[rank],'Not equal priceFlashSales to buy');
          require(_buyFlashSaleByRanks[rank].current()<=limitFlashSales[rank]-1,'Not buy box, because maximum boxes are selled');
          require(checkBuyFlashSaleBox(msg.sender)==true,'You can not buy FlashSale');
          _buyFlashSaleByRanks[rank].increment();
          _totalBuyFlashSale.increment();
          newBoxId = _totalBuyFlashSale.current();
          
          flashSaleBoxes[msg.sender][newBoxId] =Box(newBoxId,rank);
        }
        // Normal Sale 
        else{
          require(startTime<=current && current<=endTime,'Round not active');
          require(_usdt==priceSales[rank],'Not equal priceSales to buy');
          require(_buyByRanks[rank].current()<=limits[rank]-1,'Not buy box, because maximum boxes are selled');
          _buyByRanks[rank].increment();
          _totalBuy.increment();
          newBoxId = _totalBuy.current();
          boxes[msg.sender][newBoxId] =Box(newBoxId,rank);
        }
        usdt.approve(address(this), _usdt*10**18);
        usdt.transferFrom(msg.sender, address(this), _usdt*10**18);
        return boxNFT.buyBox(msg.sender,rank);
    }

  function getConfigTime () public view returns(uint256 _startFlashSaleTime, uint256 _startTime, uint256 _endTime){
      _startFlashSaleTime = startFlashSaleTime;
      _startTime = startTime;
      _endTime = endTime;
  }

  function getConfigByRank(uint256 _rank )public view returns(uint256 limit, uint256 totalBuy, uint256 priceSale,uint256 priceFlashSale, uint256 saleOff,uint256 totalBuyFlashSale,uint256 limitFlashSale){
      priceSale = priceSales[_rank];
      saleOff=saleOffs[_rank];
      limit = limits[_rank];
      limitFlashSale = limitFlashSales[_rank];
      totalBuy = _buyByRanks[_rank].current();
      totalBuyFlashSale =_buyFlashSaleByRanks[_rank].current();
      priceFlashSale= priceFlashSales[_rank];
  }

  function getConfigByRankFlashSale(uint256 _rank )public view returns(uint256 limit, uint256 totalBuy, uint256 priceSale,uint256 saleOff){
      priceSale =priceFlashSales[_rank];
      saleOff=saleOffs[_rank];
      limit = limitFlashSales[_rank];
      totalBuy =_buyFlashSaleByRanks[_rank].current();
  }

  function getConfigByRankEarlyBirdSale(uint256 _rank )public view returns(uint256 limit, uint256 totalBuy, uint256 priceSale,uint256 saleOff){
      priceSale =priceSales[_rank];
      saleOff=saleOffs[_rank];
      limit = limits[_rank];
      totalBuy =_buyByRanks[_rank].current();
  }

function getWhitelistStakingPool() public view returns(StakingPool.StakingInfo[] memory){ 
  uint16 totalPool=stakingPool.getTotalPoolConfig();
  uint index=0;
  
  for(uint32 i=1; i<=totalPool; i++){
    StakingPool.StakingInfo[] memory  stakingInfos=stakingPool.getAllStakingInfos(i);
    for(uint32 x=0; x < stakingInfos.length; x++){
      if(stakingInfos[i].sender == msg.sender){
          index++;
      }
    }
  }
  StakingPool.StakingInfo[] memory data= new StakingPool.StakingInfo[](index);
  uint tmp=0; 
  for(uint32 i=1; i<=totalPool; i++){
    StakingPool.StakingInfo[] memory  stakingInfos=stakingPool.getAllStakingInfos(i);
    for(uint32 x=0; x < stakingInfos.length; x++){
      if(stakingInfos[i].sender == msg.sender){
          data[tmp]=stakingInfos[i];
          tmp++;
      }
    }
  }
  return data;
}

function getTotalBoughtFlashSaleBox(address sender) public view returns(uint){ 
  uint totalFlashSaleBoughtBox=0;
  for(uint32 i=1;i<=5;i++){
    uint totalBuyFlashSaleByRanks=_buyFlashSaleByRanks[i].current();
    for(uint32 x=1;x<=totalBuyFlashSaleByRanks;x++){
      if(flashSaleBoxes[sender][x].id!=0){
        totalFlashSaleBoughtBox++;
      }
    }
  }
  return totalFlashSaleBoughtBox;
}

function getTotalStaking(address sender) public view returns(uint){ 
  uint totalStaking=0;
  uint16 totalPool=stakingPool.getTotalPoolConfig();
  uint index=0;
  for(uint16 i=1; i<=totalPool; i++){
    StakingPool.StakingInfo[] memory  stakingInfos=stakingPool.getAllStakingInfos(i);
    for(uint32 x=0; x < stakingInfos.length; x++){
      if(stakingInfos[x].sender == sender){
        totalStaking=totalStaking+stakingInfos[x].staked;
        index++;
      }
    }
  }
  return totalStaking;
}


function checkBuyFlashSaleBox(address sender) public view returns(bool){ 
  uint totalBoughtFlashSaleBox=getTotalBoughtFlashSaleBox(sender);
  uint totalStaking=getTotalStaking(sender);
  uint totalCanBuyBox=0;
  if(indexOfWhitelist[sender] != 0 && totalBoughtFlashSaleBox < 1){
    return true;
  }
  // StakingPool.StakingInfo[] memory data= new StakingPool.StakingInfo[](index);
  // uint tmp=0; 
  // for(uint32 i=1; i<=totalPool; i++){
  //   StakingPool.StakingInfo[] memory  stakingInfos=stakingPool.getAllStakingInfos(i);
  //   for(uint32 x=0; x < stakingInfos.length; x++){
  //     if(stakingInfos[i].sender == sender){
  //         data[tmp]=stakingInfos[i];
  //         totalStaking=totalStaking+stakingInfos[i].staked;
  //         tmp++;
  //     }
  //   }
  // }
  if(totalStaking >= 1000000 && totalStaking <= 9999999){
    totalCanBuyBox=20;
  }else if(totalStaking >= 100000 && totalStaking <= 999999){
    totalCanBuyBox=10;
  }else if(totalStaking >= 10000 && totalStaking <= 99999){
    totalCanBuyBox=5;
  }
  if(totalBoughtFlashSaleBox < totalCanBuyBox){
      return true;
    }else{
      return false;
  }
}

function getIndexOfWhitelist(address _whitelist) public view returns(uint256 ){ 
    return indexOfWhitelist[_whitelist];
}

function removeIndexOfWhitelist(address _whitelist) public onlyOwner { 
    whitelist[indexOfWhitelist[_whitelist]] = 0x0000000000000000000000000000000000000000;
    indexOfWhitelist[_whitelist]=0;
}

  function getPriceFlashSale(uint256 _rank) public view returns(uint256 ){ 
    return priceFlashSales[_rank];
  }

  function getPriceSale(uint256 _rank) public view returns(uint256 ){
    return priceSales[_rank];
  }

  function getSaleOff(uint256 _rank) public view returns(uint256 ){
    return saleOffs[_rank];
  }

  function getLimit(uint256 _rank) public view returns(uint256){
    return limits[_rank];
  }

  function setPriceFlashSale(uint256 _rank,uint256 _priceFlashSale) public onlyOwner{
    priceFlashSales[_rank]=_priceFlashSale;
  }

  function setPriceSale(uint256 _rank,uint256 _priceSale) public onlyOwner{
    priceSales[_rank]=_priceSale;
  }

  function setLimit(uint256 _rank,uint256 _limit) public onlyOwner{
    limits[_rank]=_limit;
  }

  function setLimitFlashSale(uint256 _rank,uint256 _limit) public onlyOwner{
    limitFlashSales[_rank]=_limit;
  }

  function setSaleOff(uint256 _rank,uint256 _saleOff) public onlyOwner{
    saleOffs[_rank]=_saleOff;
  }

  function setBoxNFT(BoxNFT _boxNFT) public onlyOwner{
    boxNFT=_boxNFT;
  }

  function setStakingPool(StakingPool _stakingPool) public onlyOwner{
    stakingPool = _stakingPool;
  }

  function setStartTime(uint256 _startTime) public onlyOwner{
    startTime=_startTime;
  }

  function setEndTime(uint256 _endTime) public onlyOwner{
    endTime=_endTime;
  }
  
  function withdraw(address _target, uint256 _amount) external onlyOwner {
        require(_target != address(0), "Invalid address");
        payable(_target).transfer(_amount);
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

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "./sol";

contract CharacterNFT is ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, PausableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;
    
    // using CharactersUpgradeable for Character;
    using MathUpgradeable for uint256;
    using MathUpgradeable for uint48;
    using MathUpgradeable for uint32;
    using MathUpgradeable for uint16;
    uint256 public version;
    struct Character {
        uint256 id;
        uint256 characterType;
        uint256 rank;
        uint256 star;
        uint256 exp;
        // uint256[] abilities;
    }
    event logCreateRandomThreeCharacter(uint256 nftId, uint256 characterType, uint256 rank, uint256 star, uint256 exp);

    // namely the ERC721 instances for name symbol decimals etc
    function initialize() public initializer {
        __ERC721_init("Character NFT BPLUS", "CHNB");
        __Ownable_init();
    }
    address public academyUpStar;
    modifier onlyAcademyUpStarOrOwner {
      require(msg.sender == academyUpStar || msg.sender == owner());
      _;
    }

    address public evolutionUpRank;
    modifier onlyEvolutionUpRankOrOwner {
      require(msg.sender == evolutionUpRank || msg.sender == owner());
      _;
    }

    mapping(address => mapping(uint256 => uint256)) public characters;// address - id - details // cach lay details = characters[address][characterId]
    mapping (uint256 => address) public characterIndexToOwner;

    address public boxNFT;
    modifier onlyBoxNFTOrOwner {
      require(msg.sender == boxNFT || msg.sender == owner());
      _;
    }

    address public characterMarketPlace;
    modifier onlyCharacterMarketPlaceOrOwner {
      require(msg.sender == characterMarketPlace || msg.sender == owner());
      _;
    }

  function createCharacter(address owner,uint256 characterType, uint256 rank, uint256  star,uint256  exp) public onlyBoxNFTOrOwner  returns (uint256) {
        _tokenIds.increment();
        uint256 newCharacterId = _tokenIds.current();
        //we can call mint from the ERC721 contract to mint our nft token
        // _safeMint(msg.sender, newCharacterId);
        _safeMint(owner, newCharacterId);
        characters[owner][newCharacterId] = encode(Character(newCharacterId,characterType,rank,star,exp));
        characterIndexToOwner[newCharacterId]=owner;
        return newCharacterId;
    }

  function updateCharacter(address owner,uint256 nftId, uint256 characterType, uint256 rank, uint256  star,uint256  exp) public onlyOwner returns (uint256) {
        characters[owner][nftId] = encode(Character(nftId,characterType,rank,star,exp));
        return nftId;
    }

  function upStar(address _owner,uint256 _nftId) public onlyAcademyUpStarOrOwner {
    Character memory character= getCharacter(_owner,_nftId);
    character.star=character.star+1;
    character.exp=0;
    characters[_owner][_nftId] = encode(character);
  }

  function upRank(address _owner,uint256 _mainNftId, uint256[] memory _materialNftIds) public onlyEvolutionUpRankOrOwner {
    Character memory character= getCharacter(_owner,_mainNftId);
    character.rank=character.rank+1;
    character.star=1;
    character.exp=0;
    characters[_owner][_mainNftId] = encode(character);
    for(uint i = 0; i < _materialNftIds.length; i++){
      delete characters[_owner][_materialNftIds[i]];
    }
  }

  function upExp(address _owner,uint256 _nftId,uint256 _exp) public onlyAcademyUpStarOrOwner  {
    Character memory character= getCharacter(_owner,_nftId);
    character.exp=character.exp + _exp;
    characters[_owner][_nftId] = encode(character);
  }

  function getCharacter(address owner, uint256 id) public view returns (Character memory _character) {
    uint256 details= characters[owner][id];
    _character.id = uint256(uint48(details>>100));
    _character.characterType = uint256(uint16(details>>148));
    _character.rank = uint256(uint16(details>>164));
    _character.star =uint256(uint16(details>>180));
    _character.exp =uint256(uint32(details>>212));
  }
  
function getCharacterPublic(address _owner, uint256 _id) public view returns (
        uint256 id,
        uint256 characterType,
        uint256 rank,
        uint256 star,
        uint256 exp) {
    Character memory _character= getCharacter(_owner,_id);
    id=_character.id;
    characterType=_character.characterType;
    rank=_character.rank;
    star=_character.star;
    exp=_character.exp;
  }

  function encode(Character memory character) public pure returns (uint256) {
  // function encode(Character memory character)  external view returns  (uint256) {
    uint256 value;
    value = uint256(character.id);
    value |= character.id << 100;
    value |= character.characterType << 148;
    value |= character.rank << 164;
    value |= character.star << 180;
    value |= character.exp << 212;
    return value;
  }



  function initByOwner(address _academyUpStar, address _evolutionUpRank,  address _characterMarketPlace, address _boxNFT) public onlyOwner{
    academyUpStar=_academyUpStar;
    evolutionUpRank=_evolutionUpRank;
    characterMarketPlace=_characterMarketPlace;
    boxNFT=_boxNFT;
  }

  function getCharacterOfSender(address sender) external view returns (Character[] memory ) {
        uint range=_tokenIds.current();
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          Character memory character = getCharacter(sender,i);
          if(character.id !=0){
            index++;
          }
        }
        Character[] memory result = new Character[](index);
        i=1;
        for(i; i <= range; i++){
          Character memory character = getCharacter(sender,i);
          if(character.id !=0){
            result[x] = character;
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

        Character memory character= getCharacter(ownerOf(_nftId),_nftId);
        // star will start = 1, exp will start = 0
        character.star=1;
        character.exp=0;

        characters[_target][_nftId] = encode(character);
        characters[ownerOf(_nftId)][_nftId]= encode(Character(0,0,0,0,0));
        _transfer(ownerOf(_nftId), _target, _nftId);
    }

  function approveMarketPlace(address to, uint256 tokenId) external onlyCharacterMarketPlaceOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
         _approve(to,tokenId);
  }

  function approveEvolutionUpRank(address to, uint256 tokenId) external onlyEvolutionUpRankOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
         _approve(to,tokenId);
  }

  function createCharacterWhileList(address[] memory owners,uint256 characterType) public onlyOwner {
        for (uint i=0; i<owners.length; i++) {
        _tokenIds.increment();
        uint256 newCharacterId = _tokenIds.current();
        _safeMint(owners[i], newCharacterId);
        characters[owners[i]][newCharacterId] = encode(Character(newCharacterId,characterType,1,1,0)); // 1,2,3,7
        characterIndexToOwner[newCharacterId]=owners[i];
        }
    }
  
  function setVersion(uint256 _version) public onlyOwner {
    version=_version;
  }

  function setBoxNFT(address _boxNFT) public onlyOwner{
    boxNFT=_boxNFT;
  }  

  function setEvolutionUpRank(address _evolutionUpRank) public onlyOwner{
    evolutionUpRank=_evolutionUpRank;
  }  

  function setAcademyUpStar(address _academyUpStar) public onlyOwner{
    academyUpStar=_academyUpStar;
  }

  function setCharacterMarketPlace(address _characterMarketPlace) public onlyOwner{
    characterMarketPlace=_characterMarketPlace;
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

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "./sol";

contract DiceNFT is ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, PausableUpgradeable {
    using MathUpgradeable for uint256;
    using MathUpgradeable for uint48;
    using MathUpgradeable for uint32;
    using MathUpgradeable for uint16;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;
    struct Dice {
        uint256 id;
        uint256 diceType;
        // uint256[] abilities;
    }
    
    mapping(address => mapping(uint256 => uint256)) public dices;// address - id - details // cach lay details = dices[address][diceId]

    address public boxNFT;
    modifier onlyBoxNFTOrOwner {
      require(msg.sender == boxNFT || msg.sender == owner());
      _;
    }
    
    address public diceMarketPlace;
    modifier onlyDiceMarketPlaceOrOwner {
      require(msg.sender == diceMarketPlace || msg.sender == owner());
      _;
    }
    
    // namely the ERC721 instances for name symbol decimals etc
    function initialize() public initializer {
        __ERC721_init("Dice NFT BPLUS", "DINB");
        __Ownable_init();
    }

    function initByOwner(address _diceMarketPlace, address _boxNFT) public onlyOwner{
      diceMarketPlace=_diceMarketPlace;
      boxNFT=_boxNFT;
    }
    event logCreateRandomThreeDice(uint256 nftId, uint256 diceType);
    
    function createDice(address owner,uint256 diceType) public onlyBoxNFTOrOwner whenNotPaused returns (uint256) {
        _tokenIds.increment();
        uint256 newDiceId = _tokenIds.current();
        _safeMint(owner, newDiceId);
        dices[owner][newDiceId] = encode(Dice(newDiceId,diceType));
        return newDiceId;
    }

    function updateDice(address owner,uint256 nftId, uint256 diceType) public onlyOwner returns (uint256) {
        dices[owner][nftId] = encode(Dice(nftId,diceType));
        return nftId;
    }


    // function createRandomThreeDice(address owner) public {
    //     for (uint i=0; i<3; i++) {
    //     _tokenIds.increment();
    //     uint256 newDiceId = _tokenIds.current();
    //     //we can call mint from the ERC721 contract to mint our nft token
    //     // _safeMint(msg.sender, newDiceId);
    //     _safeMint(owner, newDiceId);
        
    //     uint256 value = uint256(newDiceId*block.timestamp);
    //     uint256 diceTypeRandom = (value << 30+i*2)%10+1;

    //     emit logCreateRandomThreeDice(newDiceId,diceTypeRandom);
    //     dices[owner][newDiceId] = encode(Dice(newDiceId,diceTypeRandom));
    //     }
    // }

    function getDice(address owner, uint256 id) public view returns (Dice memory _dice) {
      uint256 details= dices[owner][id];
      _dice.id = uint256(uint48(details>>100));
      _dice.diceType = uint256(uint16(details>>148));
    }
  
  function getDicePublic(address _owner, uint256 _id) public view returns (
          uint256 id,
          uint256 diceType) {
      Dice memory _dice= getDice(_owner,_id);
      id=_dice.id;
      diceType=_dice.diceType;
    }

  function encode(Dice memory dice) public pure returns (uint256) {
    // function encode(Dice memory dice)  external view returns  (uint256) {
      uint256 value;
      value = uint256(dice.id);
      value |= dice.id << 100;
      value |= dice.diceType << 148;
      return value;
  }

  function getDiceOfSender(address sender) external view returns (Dice[] memory ) {
        uint range=_tokenIds.current();
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          Dice memory dice = getDice(sender,i);
          if(dice.id !=0){
            index++;
          }
        }
        Dice[] memory result = new Dice[](index);
        i=1;
        for(i; i <= range; i++){
          Dice memory dice = getDice(sender,i);
          if(dice.id !=0){
            result[x] = dice;
            x++;
          }
        }
        return result;
  }

  function transfer(uint256 _nftId, address _target)
        external
    {
        require(_exists(_nftId), "Non existed NFT");
        require(
            ownerOf(_nftId) == msg.sender || getApproved(_nftId) == msg.sender,
            "Not approved"
        );
        require(_target != address(0), "Invalid address");

        Dice memory dice= getDice(ownerOf(_nftId),_nftId);
        // star will start = 1, exp will start = 0
        dices[_target][_nftId] = encode(dice);
        dices[ownerOf(_nftId)][_nftId]= encode(Dice(0,0));
        _transfer(ownerOf(_nftId), _target, _nftId);
    }

  function approveMarketPlace(address to, uint256 tokenId) external onlyDiceMarketPlaceOrOwner {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
         _approve(to,tokenId);
  }

  function setBoxNFT(address _boxNFT) public onlyOwner{
    boxNFT=_boxNFT;
  }  

  function setDiceMarketPlace(address _diceMarketPlace) public onlyOwner{
    diceMarketPlace=_diceMarketPlace;
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

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

import "./IBEP20.sol";

contract StakingPool is OwnableUpgradeable, PausableUpgradeable  {
    IBEP20 public bplus;
    using MathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public totalStakingInfo;
    uint16 public totalPoolConfig;
    struct PoolConfig {
        uint32 id;
        uint32 totalDay;
        uint256 limit;
        uint256 staking;
        uint256 startTime;
        uint256 endTime;
        uint16 apr; //
        uint16 aprDecimal; // enum [1 10 100 10000]
        bool isActive;
    }

    struct StakingInfo {
      uint32 id;
      address sender;
      uint32 poolConfig;
      uint256 staked;
      uint256 createdAt;
      bool isReceived;
    }
    mapping(uint32 => PoolConfig) public poolConfigs;
    mapping(uint256 => StakingInfo) public stakingInfos;
    uint256 public minStaking;
    
    function initialize() public initializer {
      poolConfigs[1].id=1;  
      poolConfigs[1].totalDay=180;  
      poolConfigs[1].limit = 1000000000000;
      poolConfigs[1].staking = 0;
      poolConfigs[1].startTime = 1643299200;//1643302800;
      poolConfigs[1].endTime = 4765107600;
      poolConfigs[1].apr=40;
      poolConfigs[1].aprDecimal=1; // 1.6
      poolConfigs[1].isActive=true;

      poolConfigs[2].id=2;  
      poolConfigs[2].totalDay=90;  
      poolConfigs[2].limit = 1000000000000;
      poolConfigs[2].staking = 0;
      poolConfigs[2].startTime = 1643299200;//1643302800;
      poolConfigs[2].endTime = 4765107600;
      poolConfigs[2].apr=20;
      poolConfigs[2].aprDecimal=1; // 0.7
      poolConfigs[2].isActive=true;
      totalPoolConfig=2;
      minStaking=1;
        __Ownable_init();
    }

    /**
     * @dev _startTime, _endTime, _startflashSaleTime are unix time
     * _startflashSaleTime should be equal _startTime - 300(s) [5 min]
     */
    function initByOwner(IBEP20 _bplus) public onlyOwner {
        bplus=_bplus;
    }


  function stake(uint256 _amount, uint32 _poolConfigId) external  whenNotPaused returns (uint256) {
        require(poolConfigs[_poolConfigId].id > 0,'Pool not found');
        require(_amount > 0,'Amount must be greater than 0');
        require(poolConfigs[_poolConfigId].isActive == true ,'Pool not active');
        require(minStaking <= _amount,'Amount must be greater than min Staking');
        uint256 current = block.timestamp;
        require(poolConfigs[_poolConfigId].startTime <= current ,'Pool not start');
        require(_amount + poolConfigs[_poolConfigId].staking <= poolConfigs[_poolConfigId].limit,'Not greater than limit Pool');
        totalStakingInfo.increment();
        uint32 id = uint32(totalStakingInfo.current());
        stakingInfos[id].id=id;
        stakingInfos[id].sender= msg.sender;
        stakingInfos[id].poolConfig=_poolConfigId;
        stakingInfos[id].staked=_amount;
        stakingInfos[id].createdAt= current;
        stakingInfos[id].isReceived=false;
        bplus.approve(address(this), _amount*10**18);
        bplus.transferFrom(msg.sender, address(this), _amount*10**18);
        poolConfigs[_poolConfigId].staking=poolConfigs[_poolConfigId].staking+_amount;
        return id;
    }   

function claim(uint32 _stakingInfoId) external whenNotPaused  {
        require(stakingInfos[_stakingInfoId].id > 0,'Staking Info not found');
        require(stakingInfos[_stakingInfoId].sender == msg.sender,'Staking Info not found');
        require(stakingInfos[_stakingInfoId].isReceived == false,'Staking Info is received');
        uint256 current = block.timestamp;
        uint256 day=(current - stakingInfos[_stakingInfoId].createdAt)/86400;
        uint32 poolConfigId = stakingInfos[_stakingInfoId].poolConfig;
        require(day >= poolConfigs[poolConfigId].totalDay,'Not enough time to claim');
        uint256 staked=stakingInfos[_stakingInfoId].staked*10**18;   
        uint256 total = staked 
         + (staked
         * poolConfigs[poolConfigId].apr 
         / poolConfigs[poolConfigId].aprDecimal
         / 100);
        
        stakingInfos[_stakingInfoId].isReceived = true;
        bplus.approve(address(this), total);
        bplus.transferFrom(address(this), msg.sender, total);
    }

  function getPoolConfig (uint32 _poolConfigId) public view returns(
    uint32 _id, 
    uint32 _totalDay, 
    uint256 _limit,
    uint256 _staking,
    uint256 _startTime,
    uint256 _endTime,
    uint16 _apr,
    uint16 _aprDecimal,
    bool _isActive
    
    ){
      _id = poolConfigs[_poolConfigId].id;  
      _totalDay = poolConfigs[_poolConfigId].totalDay;  
      _limit = poolConfigs[_poolConfigId].limit;
      _staking = poolConfigs[_poolConfigId].staking;
      _startTime = poolConfigs[_poolConfigId].startTime;
      _endTime = poolConfigs[_poolConfigId].endTime;
      _apr = poolConfigs[_poolConfigId].apr;
      _aprDecimal = poolConfigs[_poolConfigId].aprDecimal; // 1.6
      _isActive = poolConfigs[_poolConfigId].isActive;
  }

function setPoolConfig(
    uint32 _id, 
    uint32 _totalDay, 
    uint256 _limit,
    uint256 _staking,
    uint256 _startTime,
    uint256 _endTime,
    uint16 _apr,
    uint16 _aprDecimal,
    bool _isActive ) public onlyOwner{
      poolConfigs[_id].id=_id;
      poolConfigs[_id].totalDay=_totalDay;  
      poolConfigs[_id].limit=_limit;
      poolConfigs[_id].staking=_staking;
      poolConfigs[_id].startTime=_startTime;
      poolConfigs[_id].endTime=_endTime;
      poolConfigs[_id].apr=_apr;
      poolConfigs[_id].aprDecimal=_aprDecimal; 
      poolConfigs[_id].isActive=_isActive;
  }


  function getStakingInfo (uint32 _stakingInfoId) public view returns(
      uint32 _id,
      address _sender,
      uint32 _poolConfig,
      uint256 _staked,
      uint256 _createdAt,
      bool _isReceived
    ){
      _id = stakingInfos[_stakingInfoId].id;  
      _sender = stakingInfos[_stakingInfoId].sender;  
      _poolConfig = stakingInfos[_stakingInfoId].poolConfig;
      _staked = stakingInfos[_stakingInfoId].staked;
      _createdAt = stakingInfos[_stakingInfoId].createdAt;
      _isReceived = stakingInfos[_stakingInfoId].isReceived;
  }


  function getStakingInfos(uint32 _poolConfigId) external view returns (StakingInfo[] memory ) {
        uint range=totalStakingInfo.current();
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          if(stakingInfos[i].sender==msg.sender){
            if(stakingInfos[i].poolConfig==_poolConfigId){
            index++;
            }
          }
        }
        StakingInfo[] memory result = new StakingInfo[](index);
        i=1;
        for(i; i <= range; i++){
          if(stakingInfos[i].sender==msg.sender){
            if(stakingInfos[i].poolConfig == _poolConfigId){
            result[x] = stakingInfos[i];
            x++;
            }
          }
        }
        return result;
  }

   function getAllStakingInfos(uint32 _poolConfigId) external view returns (StakingInfo[] memory ) {
        uint range=totalStakingInfo.current();
        uint i=1;
        uint index=0;
        uint x=0;
        for(i; i <= range; i++){
          if(stakingInfos[i].poolConfig==_poolConfigId){
            index++;
          }
        }
        StakingInfo[] memory result = new StakingInfo[](index);
        i=1;
        for(i; i <= range; i++){
          if(stakingInfos[i].poolConfig == _poolConfigId){
            result[x] = stakingInfos[i];
            x++;
          }
        }
        return result;
  }

  function getPoolConfigs() external view returns (PoolConfig[] memory ) {
        uint32 range= totalPoolConfig;
        PoolConfig[] memory result = new PoolConfig[](range);
        uint32 i=1;
        uint32 index=0;
        for(i; i <= range; i++){
          result[index]= poolConfigs[i];
          index++;
        }
        return result;
  }

  function setTotalPoolConfig(uint16 _totalPoolConfig) public onlyOwner{
    totalPoolConfig = _totalPoolConfig;
  } 

  function getTotalPoolConfig() public view returns(uint16){
    return totalPoolConfig;
  } 
  
  function setMinStaking(uint16 _minStaking) public onlyOwner{
    minStaking = _minStaking;
  } 

  function getMinStaking() public view returns(uint256){
    return minStaking;
  }

  function withdraw(uint amount) public onlyOwner {
        require(amount <= bplus.balanceOf(address(this)) );
        bplus.approve(address(this), amount);
        bplus.transferFrom(address(this),msg.sender, amount);
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
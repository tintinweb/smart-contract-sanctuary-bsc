// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
/*
  _   _   _____   _____     ____     ___   __  __  _____   ____    
 | \ | | |  ___| |_   _|   | __ )   / _ \  \ \/ / | ____| / ___|   
 |  \| | | |_      | |     |  _ \  | | | |  \  /  |  _|   \___ \   
 | |\  | |  _|     | |     | |_) | | |_| |  /  \  | |___   ___) |  
 |_| \_| |_|       |_|     |____/   \___/  /_/\_\ |_____| |____/   

  __  __      _      ____    _  __  _____   _____   ____    _          _       ____   _____ 
 |  \/  |    / \    |  _ \  | |/ / | ____| |_   _| |  _ \  | |        / \     / ___| | ____|
 | |\/| |   / _ \   | |_) | | ' /  |  _|     | |   | |_) | | |       / _ \   | |     |  _|  
 | |  | |  / ___ \  |  _ <  | . \  | |___    | |   |  __/  | |___   / ___ \  | |___  | |___ 
 |_|  |_| /_/   \_\ |_| \_\ |_|\_\ |_____|   |_|   |_|     |_____| /_/   \_\  \____| |_____|

*/

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}


contract Ownable is Context {
  address public _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function ownerAddress() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

interface WidgetInterface {
   function balanceOf(address account) external view returns (uint256);
   function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
   function transfer(address recipient, uint256 amount) external returns (bool);
   function createFromModel(uint256 tokenId, address buyer) external returns (uint);
   function createFromBoxes(string memory uri, uint rary, address buyer) external returns (uint);
   function approve(address spender, uint256 amount) external returns (bool);
   function depositPot(uint amount, uint256 whatToken) external;
}
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract Authorized is Ownable {
  mapping(uint8 => mapping(address => bool)) public permissions;
  string[] public permissionIndex;

  constructor() {
    permissionIndex.push("admin");
    permissionIndex.push("financial");
    permissionIndex.push("controller");
    permissionIndex.push("operator");

    permissions[0][_msgSender()] = true;
  }

  modifier isAuthorized(uint8 index) {
    if (!permissions[index][_msgSender()]) {
      revert(string(abi.encodePacked("Account ",Strings.toHexString(uint160(_msgSender()), 20)," does not have ", permissionIndex[index], " permission")));
    }
    _;
  }

  function safeApprove(address token, address spender, uint256 amount) external isAuthorized(0) {
    WidgetInterface(token).approve(spender, amount);
  }

  function safeWithdraw() external isAuthorized(0) {
    uint256 contractBalance = address(this).balance;
    payable(_msgSender()).transfer(contractBalance);
  }

  function grantPermission(address operator, uint8[] memory grantedPermissions) external isAuthorized(0) {
    for (uint8 i = 0; i < grantedPermissions.length; i++) permissions[grantedPermissions[i]][operator] = true;
  }

  function revokePermission(address operator, uint8[] memory revokedPermissions) external isAuthorized(0) {
    for (uint8 i = 0; i < revokedPermissions.length; i++) permissions[revokedPermissions[i]][operator]  = false;
  }

  function grantAllPermissions(address operator) external isAuthorized(0) {
    for (uint8 i = 0; i < permissionIndex.length; i++) permissions[i][operator]  = true;
  }

  function revokeAllPermissions(address operator) external isAuthorized(0) {
    for (uint8 i = 0; i < permissionIndex.length; i++) permissions[i][operator]  = false;
  }

}

/*
   _   _   _____   _____ 
  | \ | | |  ___| |_   _|
  |  \| | | |_      | |  
  | |\  | |  _|     | |  
  |_| \_| |_|       |_|  
*/

contract TbankNFTToken is ERC721URIStorage, Ownable, Authorized {
    
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  address public contractAddress;

  mapping(uint256 => uint256) public _rarity;

  constructor(address marketplaceAddress) ERC721("TBANK NFT", "NFTBank") {
    contractAddress = marketplaceAddress;
  }

      function createFromModel(uint256 tokenId, address buyer) public returns (uint) {
      require( contractAddress == msg.sender,"only contract market place can call this function");
          _tokenIds.increment();
          uint256 newItemId = _tokenIds.current();

          //1o
          _mint(buyer, newItemId);
          //2o
          _setTokenURI(newItemId, tokenURI(tokenId));
          //3o
          _rarity[newItemId]=_rarity[tokenId];

          //setApprovalForAll(contractAddress, true);
          return newItemId;
      }


      function createFromBoxes(string memory uri, uint rary, address buyer) public returns (uint) {
      require( contractAddress == msg.sender,"only contract market place can call this function");

          _tokenIds.increment();
          uint256 newItemId = _tokenIds.current();

          //1o
          _mint(buyer, newItemId);
          //2o
          _setTokenURI(newItemId, uri);
          //3o
          _rarity[newItemId]=rary;

          return newItemId;
      }


      function adminSetup (address marketplaceAddress) public isAuthorized(0) {
        
        contractAddress = marketplaceAddress;
      }


      function createTokenAirDrop(address recipient, string memory tokenURI, uint256 itemCount, uint256 rary) public isAuthorized(0) returns (uint256[] memory) {
      
      if (itemCount == 0) {itemCount =1;}
      uint256 newItemId;
      uint currentIndex = 0;

      uint256[] memory items = new uint[](itemCount);      

        for (uint i = 0; i < itemCount; i++) {
            _tokenIds.increment();
             newItemId = _tokenIds.current();
            _mint(recipient, newItemId);
            _setTokenURI(newItemId, tokenURI);
            _rarity[newItemId]=rary;
            //setApprovalForAll(contractAddress, true);

            items[currentIndex] = newItemId;
            currentIndex += 1;
        }    
      return items;
      }



      function createToken(string memory tokenURI, uint256 itemCount, uint256 rary) public isAuthorized(0) returns (uint256[] memory) {
      
      if (itemCount == 0) {itemCount =1;}
      uint256 newItemId;
      uint currentIndex = 0;

      uint256[] memory items = new uint[](itemCount);      

        for (uint i = 0; i < itemCount; i++) {
            _tokenIds.increment();
             newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);
            _setTokenURI(newItemId, tokenURI);
            _rarity[newItemId]=rary;
            setApprovalForAll(contractAddress, true);

            items[currentIndex] = newItemId;
            currentIndex += 1;
        }    
      return items;
      }



      function myNfts3() public view returns (uint256[] memory) {

        uint totalItemCount = _tokenIds.current();
        uint currentIndex = 0;
        address checar;
        uint contagemPrev = 0;
        for (uint i = 0; i < totalItemCount; i++) {
        checar = ownerOf(i+1);
        if (checar == payable(msg.sender)) {
           contagemPrev +=1;
          }
        }

        uint256[] memory items = new uint[](contagemPrev);

        for (uint i = 0; i < totalItemCount; i++) {
          checar = ownerOf(i+1);
          if (checar == payable(msg.sender)) {
          items[currentIndex] = i+1;
          currentIndex += 1;
          }
        }
      return items;

      }



      function myNfts2(address whoi) public view returns (uint256[] memory) {

        uint totalItemCount = _tokenIds.current();
        uint currentIndex = 0;
        address checar;
        uint contagemPrev = 0;
        for (uint i = 0; i < totalItemCount; i++) {
        checar = ownerOf(i+1);
        if (checar == payable(whoi)) {
           contagemPrev +=1;
          }
        }

        uint256[] memory items = new uint[](contagemPrev);

        for (uint i = 0; i < totalItemCount; i++) {
          checar = ownerOf(i+1);
          if (checar == payable(whoi)) {
          items[currentIndex] = i+1;
          currentIndex += 1;
          }
        }
      return items;

      }


      function myNfts(address whoi) public view returns (uint256[] memory) {

        uint totalItemCount = _tokenIds.current();
        uint currentIndex = 0;
        address checar;
        uint contagemPrev = 0;
        for (uint i = 0; i < totalItemCount; i++) {
        checar = ownerOf(i+1);
        if (checar == whoi) {
           contagemPrev +=1;
          }
        }

        uint256[] memory items = new uint[](contagemPrev);

        for (uint i = 0; i < totalItemCount; i++) {
          checar = ownerOf(i+1);
          if (checar == whoi) {
          items[currentIndex] = i+1;
          currentIndex += 1;
          }
        }
      return items;

      }


      function getRateItem(uint256 itemId) public view returns (uint256) {
        return _rarity[itemId];
      }  




}

contract NFTBankMarketPlace is ReentrancyGuard, Ownable , Authorized{

  using SafeMath for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

//STORE ITEM
  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;   
    address payable owner;
    uint256 price;
      uint behavior;              
      uint256 auctionEndTime;     
      uint lote;                  
      uint coin;
  }


  mapping(uint256 => MarketItem) private idToMarketItem;

  mapping(uint256 => bool) public hiddenItem;
  mapping(uint256 => address) public tokenBEP20;

  //SETUP
  address payable public _walletTax;  /*10% marketplace*/
  address payable public _nftContract;  /*nft master*/

  uint256 public _tbankMinimum;
  bool public _storePause;

  //BOXES
  struct boxStore {
    uint256 BoxId;
    string  BoxImg;
    uint256 price;
    uint256 lote;
    string  Box1;
    string  Box2;
    string  Box3;
    string  Box4;
    string  Box5;
    uint256 coin;
  }
  boxStore[] public _boxes;

  struct boxRate {
    uint256 Rate1;
    uint256 Rate2;
    uint256 Rate3;
    uint256 Rate4;
    uint256 Rate5;
  }
  boxRate[] public _rates;

  //VIEW RETURN
  struct boxBuyed {
    uint256 id;
    string nft;
    uint256 rarible;
    uint256 price;
  }

  //BOX CONTROLS
  uint256 public ptBox;  
  bool public pendingBox;
  mapping(uint256 => bool) public hiddenBox;

  //SALES HISTORY
  struct verVendas {
    uint256 total;   
    uint256 volume;    
    uint256 avarage;    
  }

  //TABLE
  uint256 public _lastDaySell; //timestamp
  mapping(uint256 => uint256) public _daySell;
  mapping(uint256 => uint256) public _daySellAmount;


  event MarketItemCreated (
    uint indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    uint256 coin
  );


  constructor() {
      uint toDay;
      //30 days on table
      for (toDay=0; toDay < 31; toDay++) {        
        _daySell[toDay] = 0;
        _daySellAmount[toDay] = 0;
      }
      _lastDaySell = block.timestamp;

      //busd 18 decimals
      tokenBEP20[0] = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
      //Tbank 18 decimals
      tokenBEP20[1] = 0x9c14eFdC39f68A00F53B2237ab7D5b9Bcf8E43Cc;
      //Tbank 18 decimals
      tokenBEP20[2] = 0x9c14eFdC39f68A00F53B2237ab7D5b9Bcf8E43Cc;
      //Stake holder contract
      tokenBEP20[3] = address(0);
  }

  function setHiddenBox (uint id, bool status) public isAuthorized(0) {hiddenBox[id]=status;}
  function setTbankMinimum (uint amount) public isAuthorized(0) {_tbankMinimum=amount;}
  function setStorePause (bool status) public isAuthorized(0) {_storePause=status;}
  function setHiddenItem (uint id, bool status) public isAuthorized(0) {hiddenItem[id]=status;}
  function setPriceBox (uint id, uint newPrice) public isAuthorized(0) {_boxes[id].price = newPrice;}
  function setLoteBox (uint id, uint newLote) public isAuthorized(0) {_boxes[id].price = newLote;}
  function getBoxStoreItem(uint256 boxStoreId) public view returns (boxStore memory) {return _boxes[boxStoreId];}
  function getBoxRateItem(uint256 boxRateId) public view returns (boxRate memory) {return _rates[boxRateId];}
  function setPriceItem(uint256 marketItemId, uint256 newPrice) public isAuthorized(0) {idToMarketItem[marketItemId].price = newPrice;}
  function setLoteItem(uint256 marketItemId, uint256 newLote) public isAuthorized(0) {idToMarketItem[marketItemId].price = newLote;}
  function getMarketItem(uint256 marketItemId) public view returns (MarketItem memory) {return idToMarketItem[marketItemId];}
  function safeOtherTokens(address token, address payable receiv, uint amount) external isAuthorized(0) {       
       if(token == address(0)) { receiv.transfer(amount); } else { WidgetInterface(token).transfer(receiv, amount); }
  }

  function adminSetup (
    address payable walletTax,
    address payable nftContract
    ) public isAuthorized(0) {
    _walletTax = walletTax;
    _nftContract = nftContract;
  }

  function adminApprove ( uint256 coin, address payable stakeHolderContract) public isAuthorized(0) {
    
      IERC20(tokenBEP20[coin]).approve(stakeHolderContract, type(uint256).max);
      
      tokenBEP20[3] = stakeHolderContract;
  }


  function createBoxStore (
    string memory xBoxImg,
    uint256 xprice,
    uint256 xlote,
    string memory xBox1,
    string memory xBox2,
    string memory xBox3,
    string memory xBox4,
    string memory xBox5,
    uint256 coin
    )
      public isAuthorized(0) {
      require (pendingBox==false,"Complete pending boxes before to add new publish");
     _boxes.push(boxStore(ptBox,xBoxImg, xprice, xlote, xBox1, xBox2, xBox3, xBox4, xBox5, coin));
     pendingBox = true;
     ptBox++;
  }

  function createBoxRate (
    uint256 rate1,
    uint256 rate2,
    uint256 rate3,
    uint256 rate4,
    uint256 rate5
    )
      public isAuthorized(0) {
      require (pendingBox==true,"Publish a next Box before to submite new rates values");
     _rates.push(boxRate(rate1,rate2,rate3,rate4,rate5));
     pendingBox = false;
  }


  function showRates() public view returns (boxRate[] memory) {
    uint totalItemCount = ptBox;
    uint256 currentIndex = 0;

    boxRate[] memory items = new boxRate[](totalItemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (!hiddenBox[i] && _boxes[i].lote > 0) {
      items[currentIndex] = _rates[i];
      currentIndex += 1;
      }
    }
  return items;
  }


  function showBoxes() public view returns (boxStore[] memory) {
    uint totalItemCount = ptBox;
    uint256 currentIndex = 0;

    boxStore[] memory items = new boxStore[](totalItemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (!hiddenBox[i] && _boxes[i].lote > 0) {
      items[currentIndex] = _boxes[i];
      currentIndex += 1;
      }
    }
  return items;
  }



  function registerSell (uint256 amount) private {
    uint startDate = _lastDaySell;
    uint endDate = block.timestamp; 
    uint diff = 0;

    diff = (endDate - startDate) / 60 / 60 / 24; 
    if(diff > 0) updateDaysSellTable();  

    _daySell[1] = _daySell[1].add(1);
    _daySellAmount[1] = _daySellAmount[1].add(amount);
  }


  function updateDaysSellTable() private {
      uint toDay;
      for (toDay=0; toDay < 29; toDay++) {        
        _daySell[30-toDay] = _daySell[30-toDay-1];
        _daySellAmount[30-toDay] = _daySellAmount[30-toDay-1];
      }

      _lastDaySell = block.timestamp; 
        _daySell[1] = 0;
        _daySellAmount[1] = 0;
        _daySell[0] = 0;
        _daySellAmount[0] = 0;
  }



  function BoxComiss (uint256 amount, uint256 itemId) private {

          registerSell(amount);

          WidgetInterface(tokenBEP20[itemId]).transferFrom(msg.sender, _owner, amount);
  }

  //BUY BOXES  
  function buyBoxPlay(uint ID) public payable nonReentrant returns(boxBuyed memory){
      
      require(_storePause == false, "Store paused");  
      require (_boxes[ID].lote > 0, "Invalid box");

      if (!hiddenBox[ID]) {

      BoxComiss(_boxes[ID].price, _boxes[ID].coin);

      uint[] memory myArray = new uint[](100);
      uint[] memory rares = new uint[](6);

            uint pt = 0;
            uint y = 0;   

            uint x = _rates[ID].Rate1;
            if (x>0){ for (y = 0; y < x; y++) { myArray[pt] = 1; pt++; rares[1]++; }}

            x = _rates[ID].Rate2;
            if (x>0){ for (y = 0; y < x; y++) { myArray[pt] = 2; pt++; rares[2]++; }}

            x = _rates[ID].Rate3;
            if (x>0){ for (y = 0; y < x; y++) { myArray[pt] = 3; pt++; rares[3]++; }}

            x = _rates[ID].Rate4;
            if (x>0){ for (y = 0; y < x; y++) { myArray[pt] = 4; pt++; rares[4]++; }}

            x = _rates[ID].Rate5;
            if (x>0){ for (y = 0; y < x; y++) { myArray[pt] = 5; pt++; rares[5]++; }}

            myArray = shuffle(myArray);
            uint draw = random(101);
            if (draw==0) draw=1;
            if (draw==101) draw=100;
            uint result = myArray[draw];
            
            boxBuyed memory item;
            _boxes[ID].lote--;

            if (result==1) {
              item = boxBuyed(ID,_boxes[ID].Box1,rares[1],_boxes[ID].price);    
              WidgetInterface(_nftContract).createFromBoxes(_boxes[ID].Box1,rares[1], msg.sender); 
            }
            if (result==2) {
              item = boxBuyed(ID,_boxes[ID].Box2,rares[2],_boxes[ID].price);    
              WidgetInterface(_nftContract).createFromBoxes(_boxes[ID].Box2,rares[2], msg.sender); 
            }
            if (result==3) {
              item = boxBuyed(ID,_boxes[ID].Box3,rares[3],_boxes[ID].price);    
              WidgetInterface(_nftContract).createFromBoxes(_boxes[ID].Box3,rares[3], msg.sender); 
            }
            if (result==4) {
              item = boxBuyed(ID,_boxes[ID].Box4,rares[4],_boxes[ID].price);    
              WidgetInterface(_nftContract).createFromBoxes(_boxes[ID].Box4,rares[4], msg.sender); 
            }
            if (result==5) {
              item = boxBuyed(ID,_boxes[ID].Box5,rares[5],_boxes[ID].price);    
              WidgetInterface(_nftContract).createFromBoxes(_boxes[ID].Box5,rares[5], msg.sender); 
            }
            
            return item;
      }

  
  boxBuyed memory item0 = boxBuyed(0,"0",0,0); //empty
  return item0; //empty
  }



  function random(uint number) private view returns(uint){
      return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
      msg.sender))) % number;
  }


  function shuffle(uint[] memory _myArray) private view returns(uint[] memory){
        uint a = _myArray.length; 
        uint b = _myArray.length;
        for(uint i = 0; i< b ; i++){
            uint randNumber =(uint(keccak256      
            (abi.encodePacked(block.timestamp,_myArray[i]))) % a)+1;
            uint interim = _myArray[randNumber - 1];
            _myArray[randNumber-1]= _myArray[a-1];
            _myArray[a-1] = interim;
            a = a-1;
        }
        uint256[] memory result;
        result = _myArray;       
        return result;        
  }


  function fetchSells(uint dias) public view returns (verVendas memory) {
    uint256 total = 0;
    uint256 volume = 0;
    uint256 vends=0;

      for (vends=1; vends < 31; vends++) { 
        if (dias >= vends) {
          total = total.add(_daySell[vends]);
          volume = volume.add(_daySellAmount[vends]);
        }
      }

      if (total==0) total=1;
      if (volume==0) volume=1;
      uint256 avarage = volume.div(total);

      verVendas memory item = verVendas(
          total,
          volume,
          avarage 
      );

      return item;
  }



  function createMarketItem( 
    uint256 itemCount, 
    address nftContract, 
    uint256 tokenId, 
    uint256 price,
    uint256 auctionEndTime,
    uint256 lote,
    uint256 coin
    ) public nonReentrant {

    require(coin == 0 || coin == 1 || coin == 2, "Invalid coin");
    require(nftContract == _nftContract, "Invalid NFT Contract");
    require(auctionEndTime == 0, "Not auction avaiable");

      require(price >= _tbankMinimum, "Price must be at least");

    /*identify where from token, and behavior 0 = adm, 1 = user, 2 = auction(auctionEndTime>0) */
    uint behavior;

    /*adm*/
    if ( _owner == msg.sender ) { 
    behavior = 0; 
    } 

    /*user*/
    if ( _owner != msg.sender ) { 
    require(coin == 1 || coin == 2, "User not sell in BUSD");
      behavior = 1; 
      itemCount = 1;
      lote = 1;
    }

    /*auction blocked*/
    auctionEndTime = 0;


        for (uint i = 0; i < itemCount; i++) {

          _itemIds.increment();
          uint256 itemId = _itemIds.current();
        
          idToMarketItem[itemId] =  MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
              behavior,
              auctionEndTime,
              lote,
              coin
          );

          IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

          emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            coin
          );


          tokenId+=1;

        }
          
  }



  /*SELL*/
  function createMarketSale(address nftContract, uint256 itemId) public payable nonReentrant {
  require(nftContract == _nftContract, "Invalid NFT Contract");
  require(_storePause == false, "Store paused");

    uint tokenId = idToMarketItem[itemId].tokenId;

    require(idToMarketItem[itemId].behavior == 1 || idToMarketItem[itemId].behavior == 0, "Only game's and user's NFT itens can to sell in this function");
    require(idToMarketItem[itemId].lote > 0, "No more itens");

    uint amount = idToMarketItem[itemId].price;

    registerSell(amount);

    uint256 what = idToMarketItem[itemId].coin;
    uint256 whatToken; // in stake contract 1 = TBANK 2 = BUSD

    // comprando na loja
    if (idToMarketItem[itemId].behavior == 0 ) {
      if (what == 0) whatToken = 2;
      if (what == 1) whatToken = 1;
      if (what == 0) whatToken = 1;
        
        //40% to StakeHolder
        uint amount40 = amount.div(10);
        uint amount60 = amount.div(10);

        amount40 = amount40.mul(4);
        amount60 = amount60.mul(6);

      //tokenBEP20[3] = stakecontract
      WidgetInterface(tokenBEP20[3]).depositPot(amount40, whatToken);  
      // saller 
      WidgetInterface(tokenBEP20[idToMarketItem[itemId].coin]).transferFrom(msg.sender, idToMarketItem[itemId].seller, amount60);
    }

    /*NFT user seller taxa comportamento 1*/
    if (idToMarketItem[itemId].behavior == 1) {
      if (what == 0) whatToken = 2;
      if (what == 1) whatToken = 1;
      if (what == 0) whatToken = 1;
        
        //40% to StakeHolder
        uint amount10 = amount.div(10);
        uint amount90 = amount.div(10);

        amount10 = amount10.mul(1);
        amount90 = amount90.mul(9);

      //Tax admin
      WidgetInterface(tokenBEP20[idToMarketItem[itemId].coin]).transferFrom(msg.sender, _walletTax, amount10);
      // saller 
      WidgetInterface(tokenBEP20[idToMarketItem[itemId].coin]).transferFrom(msg.sender, idToMarketItem[itemId].seller, amount90);
    }




    //Send last a lot
    if (idToMarketItem[itemId].lote == 1) {
      idToMarketItem[itemId].lote = idToMarketItem[itemId].lote.sub(1);
      IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
      idToMarketItem[itemId].owner = payable(msg.sender);
      _itemsSold.increment();
    }

    //Clone Model ?
    if (idToMarketItem[itemId].lote > 1) {
      idToMarketItem[itemId].lote = idToMarketItem[itemId].lote.sub(1);
      WidgetInterface(nftContract).createFromModel(tokenId, msg.sender);
    }

  }



  function fetchMarketItem(uint itemId) public view returns (MarketItem memory) {
      MarketItem memory item = idToMarketItem[itemId];
      return item;
  }

  
  function totalItens  () public view returns(uint256) {
      return _itemIds.current() - _itemsSold.current();
  }




  function fetchMarketItems(uint ini, uint max) public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current();
    if (max==0){ max = _itemIds.current() - _itemsSold.current(); ini = 0; } //uint unsoldItemCount;
    uint currentIndex = 0;
    uint pt = 0;

    MarketItem[] memory items = new MarketItem[](max);

    if (ini>0){max=max+ini;}

    for (uint i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].owner == address(0) && !hiddenItem[i+i] ) {
        uint currentId = idToMarketItem[i + 1].itemId;
        MarketItem storage currentItem = idToMarketItem[currentId];

        if (pt>=ini && pt<max) {
        items[currentIndex] = currentItem;
        currentIndex += 1;
        }
        pt +=1;


      }
    }
   
    return items;
  }


  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].owner == msg.sender) {
        uint currentId = idToMarketItem[i + 1].itemId;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
   
    return items;
  }
  


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
interface IERC165 {
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

import "./IERC165.sol";

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
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
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
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

import "../ERC721.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
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
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
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

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

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
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
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
        address owner = ERC721.ownerOf(tokenId);
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
        address owner = ERC721.ownerOf(tokenId);
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
        address owner = ERC721.ownerOf(tokenId);

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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
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
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
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
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.7;

import "./Counters.sol";
import "./ERC721URIStorage.sol";
import "./ERC721.sol";
import "./ReentrancyGuard.sol";


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


interface WidgetInterface {
   function balanceOf(address account) external view returns (uint256);
   function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
   function transfer(address recipient, uint256 amount) external returns (bool);
   function createFromModel(uint256 tokenId, address buyer) external returns (uint);
   function createFromBoxes(string memory uri, uint rary, address buyer) external returns (uint);
   function approve(address spender, uint256 amount) external returns (bool);
   function depositPot(uint amount, uint256 whatToken) external;
}

contract Authorized is Context {
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

  function grantAllPermissions(address operator) public isAuthorized(0) {
    for (uint8 i = 0; i < permissionIndex.length; i++) permissions[i][operator]  = true;
  }

  function revokeAllPermissions(address operator) external isAuthorized(0) {
    for (uint8 i = 0; i < permissionIndex.length; i++) permissions[i][operator]  = false;
  }

}


contract MarketPlaceMain is ReentrancyGuard, Authorized{

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
  
  //SETUP
  address payable public _owner;  /*10% marketplace*/
  address payable public _nftContract;  /*nft master*/

  uint256 public _tokenMinimum;
  uint256 public _tokenMaximum;
  bool public _storePause;

  //BOXES
  struct boxStore {
    uint256 BoxId;
    string  BoxImg;
    uint256 price;
    uint256 lote;
    string[] BoxX;
    uint256 coin;
  }
  boxStore[] public _boxes;

  struct boxRate {
    uint256[] RateX;
  }
  boxRate[] private _rates;

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


  constructor(address propWallet_) {

      grantAllPermissions(propWallet_);
      
      uint toDay;
      //30 days on table
      for (toDay=0; toDay < 31; toDay++) {        
        _daySell[toDay] = 0;
        _daySellAmount[toDay] = 0;
      }
      _lastDaySell = block.timestamp;

  }

  function setHiddenBox (uint id, bool status) public isAuthorized(0) {hiddenBox[id]=status;}
  function setTokenMinimum (uint amount) public isAuthorized(0) {_tokenMinimum=amount;}
  function setTokenMaximum (uint amount) public isAuthorized(0) {_tokenMaximum=amount;}
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
    _owner = walletTax;
    _nftContract = nftContract;
  }


  function createBoxStore (
    string memory xBoxImg,
    uint256 xprice,
    uint256 xlote,
    string [] memory xBoxs
    )
      public isAuthorized(0) {
      require (pendingBox==false,"Complete pending boxes before to add new publish");
     _boxes.push(boxStore(ptBox,xBoxImg, xprice, xlote, xBoxs, 1));
     pendingBox = true;
     ptBox++;
  }

  function createBoxRate (
    uint256[] memory rates
    )
      public isAuthorized(0) {
      require (pendingBox==true,"Publish a next Box before to submite new rates values");
     _rates.push(boxRate(rates));
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

  function BoxComiss (uint256 amount) private {
          registerSell(amount);
          payable(_owner).transfer(amount);
         
  }

  //BUY BOXES  
  function buyBoxPlay(uint ID) public payable nonReentrant returns(boxBuyed memory){
      
      require(_storePause == false, "Store paused");  
      require (_boxes[ID].lote > 0, "Invalid box");

      if (!hiddenBox[ID]) {

      //BNB  
      if (_boxes[ID].coin == 1) {
        require(msg.value >= _boxes[ID].price, "Invalid BNB amount to buy box");
      }

      BoxComiss(_boxes[ID].price);

      uint[] memory myArray = new uint[](100);
      uint[] memory rares = new uint[](6);

            uint pt = 0;
            uint y = 0;   

            uint x = _rates[ID].RateX[0];
            if (x>0){ for (y = 0; y < x; y++) { myArray[pt] = 1; pt++; rares[1]++; }}

            x = _rates[ID].RateX[1];
            if (x>0){ for (y = 0; y < x; y++) { myArray[pt] = 2; pt++; rares[2]++; }}

            x = _rates[ID].RateX[2];
            if (x>0){ for (y = 0; y < x; y++) { myArray[pt] = 3; pt++; rares[3]++; }}

            x = _rates[ID].RateX[3];
            if (x>0){ for (y = 0; y < x; y++) { myArray[pt] = 4; pt++; rares[4]++; }}

            x = _rates[ID].RateX[4];
            if (x>0){ for (y = 0; y < x; y++) { myArray[pt] = 5; pt++; rares[5]++; }}

            myArray = shuffle(myArray);
            uint draw = random(101);
            if (draw==0) draw=1;
            if (draw>=101) draw=100;
            uint result = myArray[draw];
            
            boxBuyed memory item;
            _boxes[ID].lote--;

            if (result==1) {
              item = boxBuyed(ID,_boxes[ID].BoxX[0],rares[1],_boxes[ID].price);    
              WidgetInterface(_nftContract).createFromBoxes(_boxes[ID].BoxX[0],rares[1], msg.sender); 
            }
            if (result==2) {
              item = boxBuyed(ID,_boxes[ID].BoxX[1],rares[2],_boxes[ID].price);    
              WidgetInterface(_nftContract).createFromBoxes(_boxes[ID].BoxX[1],rares[2], msg.sender); 
            }
            if (result==3) {
              item = boxBuyed(ID,_boxes[ID].BoxX[2],rares[3],_boxes[ID].price);    
              WidgetInterface(_nftContract).createFromBoxes(_boxes[ID].BoxX[2],rares[3], msg.sender); 
            }
            if (result==4) {
              item = boxBuyed(ID,_boxes[ID].BoxX[3],rares[4],_boxes[ID].price);    
              WidgetInterface(_nftContract).createFromBoxes(_boxes[ID].BoxX[3],rares[4], msg.sender); 
            }
            if (result==5) {
              item = boxBuyed(ID,_boxes[ID].BoxX[4],rares[5],_boxes[ID].price);    
              WidgetInterface(_nftContract).createFromBoxes(_boxes[ID].BoxX[4],rares[5], msg.sender); 
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
    uint256 lote
    ) public nonReentrant {

    require(nftContract == _nftContract, "Invalid NFT Contract");

    require(price >= _tokenMinimum && price <= _tokenMaximum, "Price must be at least");
    uint behavior;

    /*adm*/
    if ( _owner == msg.sender ) { 
    behavior = 0; 
    } 

    /*user*/
    if ( _owner != msg.sender ) { 
      behavior = 1; 
      itemCount = 1;
      lote = 1;
    }

    /*auction blocked*/
//    auctionEndTime = 0;

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
              0,  //auctionEndTime = 0;
              lote,
              1
          );

          IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

          emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            1
          );


          tokenId+=1;

        }
          
  }



  /*SELL*/
  function createMarketSale(address nftContract, uint256 itemId) public payable nonReentrant {
  require(nftContract == _nftContract, "Invalid NFT Contract");
  require(_storePause == false, "Store paused");

    uint tokenId = idToMarketItem[itemId].tokenId;

    require(idToMarketItem[itemId].behavior == 1 || idToMarketItem[itemId].behavior == 0, "Error behavior");
    require(idToMarketItem[itemId].lote > 0, "No more itens");

    //user pay
    uint amount = idToMarketItem[itemId].price;
    if (idToMarketItem[itemId].coin == 1) {
      require (msg.value >= amount , "Invalid BNB value send");
    }

    registerSell(amount);

    //NoTAX 0% owner not get tax fee
    if (idToMarketItem[itemId].behavior == 0 ) {
      
        payable(idToMarketItem[itemId].seller).transfer(amount);

    }
    //YesTAX 10% user saller get 10% fee
    if (idToMarketItem[itemId].behavior == 1 ) {
      amount = amount.div(10);
      uint256 amount90 = amount.mul(9);
      uint256 amount10 = amount.mul(1);
       payable(idToMarketItem[itemId].seller).transfer(amount90);
       payable(_owner).transfer(amount10);

    }


    if (idToMarketItem[itemId].lote == 1) {
      idToMarketItem[itemId].lote = idToMarketItem[itemId].lote.sub(1);
      IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
      idToMarketItem[itemId].owner = payable(msg.sender);
      _itemsSold.increment();
    }
    if (idToMarketItem[itemId].lote > 1) {
      idToMarketItem[itemId].lote = idToMarketItem[itemId].lote.sub(1);
      WidgetInterface(nftContract).createFromModel(tokenId, msg.sender);
    }

  }



  function fetchMarketItem(uint itemId) public view returns (MarketItem memory) {
      MarketItem memory item = idToMarketItem[itemId];
      return item;
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




}
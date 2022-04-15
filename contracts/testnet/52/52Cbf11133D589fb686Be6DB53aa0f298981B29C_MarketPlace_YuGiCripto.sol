// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.7;

import "./Counters.sol";
import "./ERC721URIStorage.sol";
import "./ERC721.sol";
import "./ReentrancyGuard.sol";

/*
                           %%%%%%%%%%%%%%%%%%%%%%%                              
                           %%%%%%%%%%%%%%%%%%%%%%%                              
                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                          
                        ******************************                          
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                       
                        @@@@@@(/////////@@@@//////////@@@      
                    %%%%%%%@@@(/////////@@@@//////////@@@      
                    %%%%%%%@@@(/////////@@@@//////////@@@      
                    %%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          
                        (((%%%%%%%%%%%%%       %%%%%%%         
                        (/(%%%%%%%%%%%%%       %%%%%%%         
                        ((((((%%%%%%%%%%%%%%%%%%%%((((                          
                        (/(/(/(/(/(/(/(/(/(/(/(/(/(/(/         
                        (((((((((((((..........   /(((                          
                        (/(/(/(/(/(/(..........   //(/                          
                        %%%(((((((((((((((((   //(/                        
                        %%%%%%(/(/(/(/(/(/(/(/(   
                        %%%%%%%%%%                   
                        %%%%%%%%%%                    
                        %%%%%%%%%%                       
                        %%%%%%%%%%                                                               
    _   __    ______  ______        _    __                          _                          ___ 
   / | / /   / ____/ /_  __/       | |  / /  ___    _____   _____   (_)  ____    ____          |__ \
  /  |/ /   / /_      / /          | | / /  / _ \  / ___/  / ___/  / /  / __ \  / __ \         __/ /
 / /|  /   / __/     / /           | |/ /  /  __/ / /     (__  )  / /  / /_/ / / / / /        / __/ 
/_/ |_/   /_/       /_/            |___/   \___/ /_/     /____/  /_/   \____/ /_/ /_/        /____/ 
                                                                                                                          
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

contract NFT_YuGiCripto is ERC721URIStorage, Ownable, Authorized {
    
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  address public contractAddress;

  mapping(uint256 => uint256) public _rarity;

  constructor(address marketplaceAddress) ERC721("YuGiCripto", "NFT$YCO") {
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
      require(contractAddress == msg.sender,"only contract market place can call this function");

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
      function reApprove () public isAuthorized(0) {
        setApprovalForAll(contractAddress, true);
      }


      function createTokenAirDrop(address recipient, string memory tokenURI, uint256 itemCount, uint256 rary) public isAuthorized(2) returns (uint256[] memory) {
      
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

contract MarketPlace_YuGiCripto is ReentrancyGuard, Ownable , Authorized{

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


  //from 1 to 25
  //box unic
  mapping(uint256 => string) public BoxUnic;
  //box count
  mapping(uint256 => uint256) public BoxCount;



  //SETUP
  address payable public _walletTax;  /*10% marketplace*/
  address payable public _nftContract;  /*nft master*/

  uint256 public _tokenMinimum;
  uint256 public _busdMinimum;
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
      //IQB 18 decimals
      tokenBEP20[1] = 0xD49A8f888F96b260171863Af409df8e08Fe7F5C4;


      for (uint i = 1; i < 26; i++) {
        BoxCount[i] = 2;
      }
      

  }

  function setUnicItem (uint id, string memory uri) public isAuthorized(0) {
    BoxUnic[id] = uri;
  }


  function setHiddenBox (uint id, bool status) public isAuthorized(0) {hiddenBox[id]=status;}
  function setTokenMinimum (uint amount) public isAuthorized(0) {_tokenMinimum=amount;}
  function setTBUSDMinimum (uint amount) public isAuthorized(0) {_busdMinimum=amount;}
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



  function BoxComiss (uint256 amount, uint256 coin) private {

          registerSell(amount);

          //WidgetInterface(tokenBEP20[coin]).transferFrom(msg.sender, _owner, amount);
          WidgetInterface(tokenBEP20[coin]).transferFrom(msg.sender, _walletTax, amount);
          //_walletTax
          
  }

  //BUY BOXES  
  function buyBoxPlay(uint ID) public nonReentrant returns(boxBuyed memory){

      require(_storePause == false, "Store paused");  
      require (_boxes[ID].lote > 0, "Invalid box");

      if (!hiddenBox[ID]) {

      uint raridadeUnic = 5;  

      BoxComiss(_boxes[ID].price, _boxes[ID].coin);
      // //// registerSell(_boxes[ID].price);

            uint draw = selectSort();

            //aqui verificar se ja acabou as 320 se ja buscar uma outra na sequencia q ainda tenha
            if (BoxCount[draw] > 1 ) {
                BoxCount[draw]--;
            } 
            
            if (BoxCount[draw] <= 1) {
                BoxCount[draw]=0;
                uint newdraw = reselectSort();
                BoxCount[newdraw]--;
                draw = newdraw;
            }

            boxBuyed memory item;
            _boxes[ID].lote--;

            item = boxBuyed(ID,BoxUnic[draw],raridadeUnic,_boxes[ID].price);    
            WidgetInterface(_nftContract).createFromBoxes(BoxUnic[draw],raridadeUnic, msg.sender); 

            return item;
      }

  boxBuyed memory item0 = boxBuyed(0,"0",0,0); //empty
  return item0; //empty
  }



  function selectSort() private view returns (uint) {
    uint draw = random(26);
    if (draw == 0) draw = 1;
    if (draw == 26) draw = 25;
    return draw;
  }

  function reselectSort () private view returns (uint) {
    uint i = 1;
        for(i; i< 26 ; i++){
            if (BoxCount[i] > 1) return i;
        }
    return i;
  }

  function seeUnics() public view returns(uint[] memory){

    uint[] memory _myArray = new uint[](26);

        for(uint i = 1; i< 26 ; i++){
            _myArray[i] = (BoxCount[i]);
        }

        uint256[] memory result;
        result = _myArray;       
        return result;        
  }

  function seeUnicsImg() public view returns(string[] memory){

    string[] memory _myArray = new string[](26);

        for(uint i = 1; i< 26 ; i++){
            _myArray[i] = (BoxUnic[i]);
        }

        string[] memory result;
        result = _myArray;       
        return result;        
  }



  function random(uint number) private view returns(uint){
      return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
      msg.sender))) % number;
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


  


}
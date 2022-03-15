/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/*
 ____        __                 __                  __                  ___        __                    
/\  _`\     /\ \__             /\ \                /\ \                /\_ \      /\ \                   
\ \,\L\_\   \ \ ,_\     __     \ \ \/'\       __   \ \ \___      ___   \//\ \     \_\ \      __    _ __  
 \/_\__ \    \ \ \/   /'__`\    \ \ , <     /'__`\  \ \  _ `\   / __`\   \ \ \    /'_` \   /'__`\ /\`'__\
   /\ \L\ \   \ \ \_ /\ \L\.\_   \ \ \\`\  /\  __/   \ \ \ \ \ /\ \L\ \   \_\ \_ /\ \L\ \ /\  __/ \ \ \/ 
   \ `\____\   \ \__\\ \__/.\_\   \ \_\ \_\\ \____\   \ \_\ \_\\ \____/   /\____\\ \___,_\\ \____\ \ \_\ 
    \/_____/    \/__/ \/__/\/_/    \/_/\/_/ \/____/    \/_/\/_/ \/___/    \/____/ \/__,_ / \/____/  \/_/ 
 ______    ____       ______      __  __      __  __     
/\__  _\  /\  _`\    /\  _  \    /\ \/\ \    /\ \/\ \    
\/_/\ \/  \ \ \L\ \  \ \ \L\ \   \ \ `\\ \   \ \ \/'/'   
   \ \ \   \ \  _ <'  \ \  __ \   \ \ , ` \   \ \ , <    
    \ \ \   \ \ \L\ \  \ \ \/\ \   \ \ \`\ \   \ \ \\`\  
     \ \_\   \ \____/   \ \_\ \_\   \ \_\ \_\   \ \_\ \_\
      \/_/    \/___/     \/_/\/_/    \/_/\/_/    \/_/\/_/
      @tokenbank.exchange Stakeholder to Defi Games NFTs and Web3 Development Platform 
      
   /\   /\   
  //\\_//\\     ____      🦊✅ % = amount in the draw in NFT Mistery Box
  \_     _/    /   /      🦊✅ 5 stars = 10% legendary   5x gain 🌟🌟🌟🌟🌟
   / * * \    /^^^]       🦊✅ 4 stars = 15% super rare  4x gain 🌟🌟🌟🌟
   \_\O/_/    [   ]       🦊✅ 3 stars = 20% rare        3x gain 🌟🌟🌟
    /   \_    [   /       🦊✅ 2 stars = 25% uncommon    2x gain 🌟🌟
    \     \_  /  /        🦊✅ 1 stars = 30% common      1x gain 🌟
     [ [ /  \/ _/         🦊✅ nft.tokenbank.exchange  
    _[ [ \  /_/      
*/

interface NFTTOKEN { 
  function getRateItem(uint256 itemId) external returns (uint256); 
  function setApprovalForAll(address operator, bool approved) external;
}
interface IERC721 { function transferFrom(address from, address to, uint256 tokenId) external; }
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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
    IERC20(token).approve(spender, amount);
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
                                        ██████████████    
                                  ██████████        ██    
                              ████████              ██    
                          ██████                  ████    
                        ██████      ████          ██      
                      ████        ████████      ████      
                    ████        ████░░░░████    ████      
          ████████████          ████░░░░████  ████        
        ████    ▒▒██              ████████    ████        
        ██    ▒▒██                  ████    ████          
      ████  ▒▒██          ████            ████            
      ██▒▒  ▒▒██        ████▒▒██          ████            
    ████▒▒▒▒██        ████▒▒██▒▒        ████              
    ████████████    ████▒▒██▒▒        ████                
            ░░    ████▒▒██▒▒        ████                  
      ░░░░        ██▒▒██▒▒        ████                    
    ▒▒▒▒░░        ▒▒██▒▒        ██▒▒██                    
  ░░▒▒▒▒▒▒░░                ████  ▒▒██                    
        ▒▒░░          ░░████▒▒    ▒▒██                    
      ▒▒▒▒▒▒░░    ░░  ▒▒██▒▒      ▒▒██                    
    ▒▒▒▒▒▒▒▒░░░░▒▒░░  ▒▒██▒▒▒▒██████                      
  ░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▒▒████████                          
  ▒▒      ▒▒▒▒▒▒░░▒▒░░  ████                              
        ▒▒▒▒▒▒  ▒▒▒▒                                      
        ▒▒░░    ▒▒░░                                      
*/
contract StakeHolderTBANK is ReentrancyGuard, Ownable, Authorized {

  using SafeMath for uint;

  address public immutable _Tbank;
  address public immutable _Busd;
  address public _NftToken;
  

  uint256 public _totalPoolNft;
  uint256 public _totalPoolNftUnic;
  uint256 public _totalPool;
  uint256 public _totalPayedTBANK;
  uint256 public _totalPayedBUSD;

  uint256 public _stakerPOTTbank;
  uint256 public _stakerPOTBusd;

  uint256 public _minimumToDepositStake;

  struct StakeContract {
    uint256   balance;      //owner TBANK send
    uint256   endLock;      //avaiable to receive 15 days
    uint256   tbankPays;    //ballance TBANK to claim 
    uint256   busdPays;     //ballance BUSD to claim 
    uint256   nftRate;     //ballance BUSD to claim 
    bool      inGame;
  }
  mapping(address => StakeContract) public _pool;
  address[] internal _wallets;

  

  struct boxRate {
    uint256 itemId;
    address owner;
    bool inStake;
    uint256 removeId;
  }
  boxRate[] public _rates;
  mapping(uint256 => bool) public hiddenBox;


  //start
  constructor() {
    _Busd = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    _Tbank = 0x9c14eFdC39f68A00F53B2237ab7D5b9Bcf8E43Cc;
    _NftToken = address(this);
    _minimumToDepositStake = 10000; // units
  //_Tbank = 0x833b5Cb9A2Cffb1587BbefE53A451D0989FBA714;
  }
  
  //receiver
  receive() external payable {}




  function getNFTsInStake() public view returns (boxRate[] memory) {
    uint totalItemCount = _totalPoolNftUnic;
    uint256 currentIndex = 0;

    boxRate[] memory items = new boxRate[](totalItemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (!hiddenBox[i] && _rates[i].inStake) {
      items[currentIndex] = _rates[i];
      currentIndex += 1;
      }
    }
  return items;
  }



  //Stakeholder sending TBANK MINIMUN 10.000 TBANK
  function sendToStake(uint amount) external nonReentrant {
    
    require (amount >= _minimumToDepositStake * (10**18),"Minimun amount to Stake not valid.");
    IERC20(_Tbank).transferFrom(msg.sender, address(this), amount);

    uint preBalance = _pool[msg.sender].balance;
    uint preEndLock = _pool[msg.sender].endLock;
    uint preTbankpays = _pool[msg.sender].tbankPays;
    uint preBusdPays = _pool[msg.sender].busdPays;
    uint preNftRate = _pool[msg.sender].nftRate;
    bool inGame = _pool[msg.sender].inGame;

      if (!inGame) {
        inGame = true;
        _wallets.push(msg.sender);
      }
      
      //new deposit 30 days locked
      preEndLock = block.timestamp + 30 minutes;

      _totalPool = _totalPool.add(amount);

      _pool[msg.sender] = StakeContract (
        preBalance.add(amount),
        preEndLock,
        preTbankpays,
        preBusdPays,
        preNftRate,
        inGame
      );

  }

  //Stakeholder sending TBANK MINIMUN 10.000 TBANK
  function rescueStake(uint amount) external nonReentrant {
    
    require (amount >= _minimumToDepositStake * (10**18),"Minimun rescue amount not valid.");
    bool inGame = _pool[msg.sender].inGame;
    require (inGame, "You are not holder");
    uint preBalance = _pool[msg.sender].balance;
    require (preBalance >= _minimumToDepositStake * (10**18),"Minimun rescue amount not valid.");
    uint preEndLock = _pool[msg.sender].endLock;
    require(preEndLock < block.timestamp, '30 days locked');

    uint preNftRate = _pool[msg.sender].nftRate;
    uint preTbankpays = _pool[msg.sender].tbankPays;
    uint preBusdPays = _pool[msg.sender].busdPays;

      _totalPool = _totalPool.sub(amount);

      _pool[msg.sender] = StakeContract (
        preBalance.sub(amount),
        preEndLock,
        preTbankpays,
        preBusdPays,
        preNftRate,
        inGame
      );

      IERC20(_Tbank).transfer(msg.sender, amount);
  }



    function sendNFTToStake(uint256 tokenId) public nonReentrant {

    IERC721(_NftToken).transferFrom(msg.sender, address(this), tokenId);

    _totalPoolNftUnic = _totalPoolNftUnic.add(1);
    _rates.push(boxRate(tokenId,msg.sender,true,_totalPoolNftUnic));

    
    uint preBalance = _pool[msg.sender].balance;
    uint preEndLock = _pool[msg.sender].endLock;
    uint preTbankpays = _pool[msg.sender].tbankPays;
    uint preBusdPays = _pool[msg.sender].busdPays;
    uint preNftRate = _pool[msg.sender].nftRate;
    bool inGame = _pool[msg.sender].inGame;

    uint nftStars;
    uint nftRary = NFTTOKEN(_NftToken).getRateItem(tokenId);
    if (nftRary<=10) nftStars = 5;                  //5x gain 🌟🌟🌟🌟🌟
    if (nftRary>10 && nftRary<=15) nftStars = 4;    //4x gain 🌟🌟🌟🌟
    if (nftRary>15 && nftRary<=20) nftStars = 3;    //3x gain 🌟🌟🌟
    if (nftRary>20 && nftRary<=25) nftStars = 2;    //2x gain 🌟🌟
    if (nftRary>25) nftStars = 1;                   //1x gain 🌟


      if (!inGame) {
        inGame = true;
        _wallets.push(msg.sender);
      }
      
      //new deposit 30 days
      preEndLock = block.timestamp + 30 minutes;

      _totalPoolNft = _totalPoolNft.add(nftStars);

      _pool[msg.sender] = StakeContract (
        preBalance,
        preEndLock,
        preTbankpays,
        preBusdPays,
        preNftRate.add(nftStars),
        inGame
      );

  }

  //Stakeholder sending TBANK MINIMUN 10.000 TBANK
  function rescueNFTStake(uint256 tokenIdBox) public nonReentrant {

    uint tokenId = _rates[tokenIdBox].itemId;
    require (_rates[tokenIdBox].owner == msg.sender, "You are not NFT owner X");

    bool inGame = _pool[msg.sender].inGame;
    require (inGame, "You are not holder");
    uint preEndLock = _pool[msg.sender].endLock;
    require(preEndLock < block.timestamp, 'too early');

    uint preBalance = _pool[msg.sender].balance;
    uint preNftRate = _pool[msg.sender].nftRate;
    uint preTbankpays = _pool[msg.sender].tbankPays;
    uint preBusdPays = _pool[msg.sender].busdPays;

    uint nftStars;
    uint nftRary = NFTTOKEN(_NftToken).getRateItem(tokenId);
    if (nftRary<=10) nftStars = 5;                  //5x gain 🌟🌟🌟🌟🌟
    if (nftRary>10 && nftRary<=15) nftStars = 4;    //4x gain 🌟🌟🌟🌟
    if (nftRary>15 && nftRary<=20) nftStars = 3;    //3x gain 🌟🌟🌟
    if (nftRary>20 && nftRary<=25) nftStars = 2;    //2x gain 🌟🌟
    if (nftRary>25) nftStars = 1;                   //1x gain 🌟

      _totalPoolNft = _totalPoolNft.sub(nftStars);

      _pool[msg.sender] = StakeContract (
        preBalance,
        preEndLock,
        preTbankpays,
        preBusdPays,
        preNftRate.sub(nftStars),
        inGame
      );

    _rates[tokenIdBox].inStake = false;
    hiddenBox[tokenIdBox] = true;

    IERC721(_NftToken).transferFrom(address(this), msg.sender, tokenId);
    // wrong IERC721(_NftToken).transfer(msg.sender, tokenId);

  }



  function depositPot(uint amount, uint256 whatToken) external nonReentrant {

    require(whatToken == 1 || whatToken == 2,"Error 1 tbank or 2 busd");
    
    if (whatToken == 1) {
    IERC20(_Tbank).transferFrom(msg.sender, address(this), amount);
    _stakerPOTTbank = _stakerPOTTbank.add(amount);
    }

    if (whatToken == 2) {
    IERC20(_Busd).transferFrom(msg.sender, address(this), amount);
    _stakerPOTBusd = _stakerPOTBusd.add(amount);
    }    

  }

  function distributeRewards(uint256 whatToken) external isAuthorized(0) nonReentrant {

    require(whatToken == 1 || whatToken == 2,"Error 1 tbank or 2 busd");

    uint totalToDistribute;

    if (whatToken == 1) {
     _totalPayedTBANK = _totalPayedTBANK.add(_stakerPOTTbank);
     totalToDistribute = _stakerPOTTbank;
     _stakerPOTTbank = 0; // ZERANDO POTE
    }

    if (whatToken == 2) {
     _totalPayedBUSD = _totalPayedBUSD.add(_stakerPOTBusd);
     totalToDistribute = _stakerPOTBusd;
     _stakerPOTBusd = 0; //ZERANDO POTE
    }

    require (totalToDistribute > 100 * (10**18),"very low distribution");

    //60% holoders 40% nftsholders
    totalToDistribute = totalToDistribute.div(100); // 1% cote

    uint totalToDistributeStake = totalToDistribute.mul(60); // 60% 
    uint totalToDistributeStakeNFT = totalToDistribute.mul(40); // 40% 

    //Holders 2
    uint holdsTotalNFT = _totalPoolNft; //hash power em stake ex 5 10 15 20
    uint holdsTotalPool = _totalPool; 
    holdsTotalPool = holdsTotalPool.div(10**18); 

    uint fractionStake = totalToDistributeStake.div(holdsTotalPool);
    uint fractionStakeNFT = totalToDistributeStakeNFT.div(holdsTotalNFT);

    uint amountCoins;
    uint amountCoinsExt;
    
          for(uint256 i; i < _wallets.length; i++){
              if(_pool[_wallets[i]].balance >= _minimumToDepositStake * (10**18)) {

                  //stakeholders
                  amountCoins = _pool[_wallets[i]].balance;
                  amountCoins = amountCoins.div(10**18);
                  amountCoins = amountCoins.mul(fractionStake);

                  //nftholders
                  amountCoinsExt = _pool[_wallets[i]].nftRate; 
                  amountCoinsExt = amountCoinsExt.mul(fractionStakeNFT);

                  amountCoins = amountCoins.add(amountCoinsExt);
                  if (whatToken == 1) _pool[_wallets[i]].tbankPays = _pool[_wallets[i]].tbankPays.add(amountCoins);
                  if (whatToken == 2) _pool[_wallets[i]].busdPays = _pool[_wallets[i]].busdPays.add(amountCoins);
              }
            }

  }


  function claimRewards(uint256 whatToken) external nonReentrant {

    uint256 sendAmount;

      if (whatToken == 1 && _pool[msg.sender].tbankPays > 0 ) {
         sendAmount = _pool[msg.sender].tbankPays;
        _pool[msg.sender].tbankPays = 0;
        IERC20(_Tbank).transfer(msg.sender, sendAmount);
        sendAmount = 0;
      }

      if (whatToken == 2 && _pool[msg.sender].busdPays > 0 ) {
         sendAmount = _pool[msg.sender].busdPays;
        _pool[msg.sender].busdPays = 0;
        IERC20(_Busd).transfer(msg.sender, sendAmount);
        sendAmount = 0;
      }

  }




  function getPool (address holder) public view returns (StakeContract memory) { return _pool[holder]; }
  
  function getMyPool () public view returns (StakeContract memory) {  return _pool[msg.sender]; }

  function getBusdBalance (address holder) public view returns (uint) { return _pool[holder].busdPays;  }
  function getTbankBalance (address holder) public view returns (uint) { return _pool[holder].tbankPays;  }

  function getTotalHolders () public view returns (uint) { return _wallets.length; }
  function getTotalPool () public view returns (uint) { return _totalPool; }
  function getTotalPoolNft () public view returns (uint) { return _totalPoolNft; }
  function getTotalPoolNftUnic () public view returns (uint) { return _totalPoolNftUnic; }
  function getPayedTbank () public view returns (uint) { return _totalPayedTBANK; }
  function getPayedbusd () public view returns (uint) { return _totalPayedBUSD; }

  function getTotalBusdBalance () public view returns (uint) { return IERC20(_Busd).balanceOf(address(this));  }
  function getTotalTbankBalance () public view returns (uint) { return IERC20(_Tbank).balanceOf(address(this));  }

  function withdrawBNB() external isAuthorized(0) { payable(_owner).transfer(address(this).balance); }
  
  function safeOtherTokens(address token, address payable receiv, uint amount) external isAuthorized(0) {
    require (token != _Tbank, "TBANK can only be withdrawn by its original owners");
    if(token == address(0)) { receiv.transfer(amount); } else { IERC20(token).transfer(receiv, amount); }
  }

  function adminSetNftTokenContract (address token) external isAuthorized(0) {
    _NftToken = token;
  }

  function adminSetMinimumToStake(uint256 unitsCoin) external isAuthorized(0) {
    _minimumToDepositStake = unitsCoin; 
  }

  function getBoxRateItem(uint256 boxRateId) public view returns (boxRate memory) {return _rates[boxRateId];} 



}
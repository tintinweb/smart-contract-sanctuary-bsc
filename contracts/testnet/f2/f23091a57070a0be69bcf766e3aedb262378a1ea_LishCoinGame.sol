/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/*
                                     @                                           
                                 @@#@@@@@@@&@@     ,                            
                              *@@@@@,,@,,,,@@,,&@@@@                            
                 @@@@@@@@@  @@*,,,,,,,,,,,,,,,,,,,,@@  @@@@&&@@@@               
              @@,@@@@@@@@,(@,,,,,,,,,,,,,,,,,,,,,,,,,@/*@@@@@@@@@*@&            
             @@@@@@@@@@@@*,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@@@@@@@@@           
            @@@@@@@@@@@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@@@@@@@@@@           
            *@@@@@@@@@@@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@@@@@@@@           
           @@@@,@@@@@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@@@,@@@@@          
            @@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@           
           @@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@          
          @@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@         
         @@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@        
         @%,,,,,,,,,,,,@@@@@@@@,,,,,,,,,,,,,,,,,,,,,,,@@@@@@,,,,,,,,,,*@        
   @@@@@@@,,,,,,,,,,,@@@@@@@@@@@@,,,,,,,,,,,,,,@,,,,,@@@@@@@@@(,,,,,,,,@&       
   @@,,,,,,,,,,,,,,,,,@@@@@@@&,,,@&,,,,@,,,,,&,,,,,@,,,,@@@@@@@,,,,,,,,,,/&&@@  
   @@,,,,,,,,,,,,,,,*,@@@@@@@&,,,,,@,,,%,,,,,,,,@@,,,,,@@@@@@@(,,,,,,,,,,,,*@%  
    @@,,,,,,,,,,,,,,,,,@@@@@@@@@@@@@,,,,,,,,,,,,,@@@@@*,,,,,,,,,,,,,,,,(,,,@@   
     /@@/,,,,,,,,,,,,,,,,@@@@@@@@@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@    
  @@,,,,,@(,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*@#*%@,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@@  
   @@,,,,@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@@@@@(,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@  
    @@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#@@@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@    
       @@@@*,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@@@@@,,,,,,,,,,,,,,@@@@      
             (@@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*@@@@,,@@@,,,,,,,,@@@@@           
                @@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,(#(*,,,,,,,,,,@@@               
                   @@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@                  
                      @@@&,,,,,,,,,,,,,,,,,,,,,,,,,,,,,/@@@                     
                          @@@@@#,,,,,,@,*,,,,,,,,,@@@@@                         
                                [email protected]@@@@@@@@@@@@@@.                               

    __     _             __      _    ______           _                   ______                          
   / /    (_)   _____   / /_    (_)  / ____/  ____    (_)   ____          / ____/  ____ _   ____ ___   ___ 
  / /    / /   / ___/  / __ \  / /  / /      / __ \  / /   / __ \        / / __   / __ `/  / __ `__ \ / _ \
 / /___ / /   (__  )  / / / / / /  / /___   / /_/ / / /   / / / /       / /_/ /  / /_/ /  / / / / / //  __/
/_____//_/   /____/  /_/ /_/ /_/   \____/   \____/ /_/   /_/ /_/        \____/   \__,_/  /_/ /_/ /_/ \___/ 

*/

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
    __     _             __      _    ______           _                   ______                  __                           __ 
   / /    (_)   _____   / /_    (_)  / ____/  ____    (_)   ____          / ____/  ____    ____   / /_   _____  ____ _  _____  / /_
  / /    / /   / ___/  / __ \  / /  / /      / __ \  / /   / __ \        / /      / __ \  / __ \ / __/  / ___/ / __ `/ / ___/ / __/
 / /___ / /   (__  )  / / / / / /  / /___   / /_/ / / /   / / / /       / /___   / /_/ / / / / // /_   / /    / /_/ / / /__  / /_  
/_____//_/   /____/  /_/ /_/ /_/   \____/   \____/ /_/   /_/ /_/        \____/   \____/ /_/ /_/ \__/  /_/     \__,_/  \___/  \__/  
*/
contract LishCoinGame is ReentrancyGuard, Ownable, Authorized {

  using SafeMath for uint;

  address public immutable _LishiCoinToken;

  uint256 public _totalPool;
  uint256 public _totalPayedLISHI;
  uint256 public _totalPayedBUSD;

  uint256 public _stakerPOTTbank;
  uint256 public _stakerPOTBusd;
  
  uint256 public _minimumToGame;

  struct BetsInGame {
    uint256   balance;      //owner BET send
    uint256   betsPays;    //ballance TBANK to claim 
    bool      inGame;
  }
  mapping(address => BetsInGame) public _bets;
  address[] internal _wallets;

  //start
  constructor() {
    _LishiCoinToken = 0xA14E448Bf6014f9747177b493e9b5515b8b1F47A;
    _minimumToGame = 10000; // units
  }
  
  //receiver
  receive() external payable {}


  //Stakeholder sending TBANK MINIMUN 10.000 TBANK
  function sendBetToGame(uint amount) external nonReentrant {
    
    require (amount >= _minimumToGame * (10**18),"Minimun amount to Stake not valid.");

    uint preBalance = _bets[msg.sender].balance;
    require (preBalance == 0, "This wallet alredy have bets in game.");

    uint prebetsPays = _bets[msg.sender].betsPays;
    require (prebetsPays == 0, "You need claim your rewards before next bet.");

    IERC20(_LishiCoinToken).transferFrom(msg.sender, address(this), amount);

    // add in wallet list ???
    bool inGame = _bets[msg.sender].inGame;
      if (!inGame) {
        inGame = true;
        _wallets.push(msg.sender);
      }

      _totalPool = _totalPool.add(amount);

      _bets[msg.sender] = BetsInGame (
        preBalance.add(amount),
        prebetsPays,
        inGame
      );

  }

  function finsishGame (address gamerWallet, uint256 amountWin) external nonReentrant isAuthorized(2) {
      require (amountWin < _bets[msg.sender].balance.mul(2), "Impossible pay more off double bet");
      require (_bets[gamerWallet].betsPays == 0, "Alredy pay this bet");

      _bets[gamerWallet].betsPays = amountWin;
  }

  function claimRewards() external nonReentrant {

    require (_bets[msg.sender].betsPays > 0, "Game not finish, complete game to claim tokens");

    uint256 sendAmount;

         sendAmount = _bets[msg.sender].betsPays;

        _totalPool = _totalPool.sub(sendAmount);

         // clean balance and clean bet
        _bets[msg.sender].betsPays = 0;
        _bets[msg.sender].balance = 0;

        IERC20(_LishiCoinToken).transfer(msg.sender, sendAmount);
        sendAmount = 0;

  }


  function getPool (address holder) public view returns (BetsInGame memory) { return _bets[holder]; }
  
  function getMyPool () public view returns (BetsInGame memory) {  return _bets[msg.sender]; }

  function getLishBalance (address holder) public view returns (uint) { return _bets[holder].betsPays;  }

  function getTotalHolders () public view returns (uint) { return _wallets.length; }
  function getTotalPool () public view returns (uint) { return _totalPool; }

  function getPayedLish () public view returns (uint) { return _totalPayedLISHI; }

  function getTotalLishiBalance () public view returns (uint) { return IERC20(_LishiCoinToken).balanceOf(address(this));  }

  function withdrawBNB() external isAuthorized(0) { payable(_owner).transfer(address(this).balance); }
  
  function safeOtherTokens(address token, address payable receiv, uint amount) external isAuthorized(0) {
    require (token != _LishiCoinToken, "LISHICOIN can only be withdrawn by its original owners");
    if(token == address(0)) { receiv.transfer(amount); } else { IERC20(token).transfer(receiv, amount); }
  }

  function adminSetMinimumToGame(uint256 unitsCoin) external isAuthorized(0) { _minimumToGame = unitsCoin; }
   
}
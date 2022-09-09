/**
 *Submitted for verification at BscScan.com on 2022-09-08
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


   _____   _______   __  __   _____                 _____   _             _             __  __   _                
  / ____| |__   __| |  \/  | |_   _|               / ____| | |           | |           |  \/  | (_)               
 | (___      | |    | \  / |   | |      ______    | (___   | |_    __ _  | | __   ___  | \  / |  _   _ __     ___ 
  \___ \     | |    | |\/| |   | |     |______|    \___ \  | __|  / _` | | |/ /  / _ \ | |\/| | | | | '_ \   / _ \
  ____) |    | |    | |  | |  _| |_                ____) | | |_  | (_| | |   <  |  __/ | |  | | | | | | | | |  __/
 |_____/     |_|    |_|  |_| |_____|              |_____/   \__|  \__,_| |_|\_\  \___| |_|  |_| |_| |_| |_|  \___|

    StakeMine StakeHolder Contract V1

    Contract to withdrawls stake earns from Stakemine 
    ✅Payable in BUSD Token
    ✅Payable in STMI Token
    
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
 ____        ______                ______     
/\  _`\     /\__  _\   /'\_/`\    /\__  _\    
\ \,\L\_\   \/_/\ \/  /\      \   \/_/\ \/    
 \/_\__ \      \ \ \  \ \ \__\ \     \ \ \    
   /\ \L\ \     \ \ \  \ \ \_/\ \     \_\ \__ 
   \ `\____\     \ \_\  \ \_\\ \_\    /\_____\
    \/_____/      \/_/   \/_/ \/_/    \/_____/
*/

contract StakeMineHolderContract is ReentrancyGuard, Ownable, Authorized {

  using SafeMath for uint;

  address public immutable _Stmi;
  address public immutable _Busd;

  //start
  constructor() {
    //_Busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    _Busd = 0x280eE9F5DCe05bd0a04d596620F48bb9048E4E4C;
    _Stmi = 0x9Bf66F0FC40F5bCD697Ef9b858e997A82610070A;
  }
  
 //receiver
 receive() external payable {}


 function stakeMineEarns(
    uint256 token,
    uint256 totalPay,
    uint256[] memory amount,
    address[] memory holders
    ) external nonReentrant isAuthorized(0) {
    
    address tokenAddress;
    if (token ==1) {
        tokenAddress = _Busd;
    } else if (token ==2) {
        tokenAddress = _Stmi;
    }

    //Get Amount to pay holders
    IERC20(tokenAddress).transferFrom(msg.sender, address(this), totalPay);
    //Distribute
    for (uint i = 0; i < holders.length; i++) {
    IERC20(tokenAddress).transfer(address(holders[i]), amount[i]);
    }

 }   


  function getTotalBusdBalance () public view returns (uint) { return IERC20(_Busd).balanceOf(address(this));  }

  function getTotalStmiBalance () public view returns (uint) { return IERC20(_Stmi).balanceOf(address(this));  }

  function withdrawBNB() external isAuthorized(0) { payable(_owner).transfer(address(this).balance); }

  function safeOtherTokens(address token, address payable receiv, uint amount) external isAuthorized(0) {
    if(token == address(0)) { receiv.transfer(amount); } else { IERC20(token).transfer(receiv, amount); }
  }


  

}
/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract TimeRelease is Ownable {
    using SafeMath for uint256;
    uint256 month1 = 1660126698; //2022-08-10 18:18:18
    uint256 month2 = 1662805098; //2022-09-10 18:18:18
    uint256 month3 = 1665397098; //2022-10-10 18:18:18
    uint256 month4 = 1668075498; //2022-11-10 18:18:18
    uint256 month5 = 1670667498; //2022-12-10 18:18:18

    uint256 month1price = 840*(10**18);
    uint256 month2price = 840*(10**18);
    uint256 month3price = 840*(10**18);
    uint256 month4price = 840*(10**18);

    address to = address(0x3c1bbf7cc3782795D527238f4B2713e0817a228f);

    function releaseToken(address contractAddress) external onlyOwner {
        uint256 amount = IERC20(contractAddress).balanceOf(address(this));
        if (amount>=840*5*(10**18) && block.timestamp>=month1){
            IERC20(contractAddress).transfer(to,month1price);
        }else if(amount>=840*4*(10**18) && block.timestamp>=month2){
            IERC20(contractAddress).transfer(to,month2price);
        }else if(amount>=840*3*(10**18) && block.timestamp>=month3){
            IERC20(contractAddress).transfer(to,month3price);
        }else if(amount>=840*2*(10**18) && block.timestamp>=month4){
            IERC20(contractAddress).transfer(to,month4price);
        }else if(block.timestamp>=month5){
            IERC20(contractAddress).transfer(to,amount);
        }
    }
}
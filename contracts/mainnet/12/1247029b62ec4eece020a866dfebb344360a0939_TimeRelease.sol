/**
 *Submitted for verification at BscScan.com on 2022-08-12
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
    uint256 month1 = 1660262888; //2022-08-12 08:08:08
    uint256 month2 = 1662941288; //2022-09-12 08:08:08
    uint256 month3 = 1665533288; //2022-10-12 08:08:08
    uint256 month4 = 1668211688; //2022-11-12 08:08:08
    uint256 month5 = 1670803688; //2022-12-12 08:08:08
    uint256 month6 = 1673482088; //2023-01-12 08:08:08
    uint256 month7 = 1676160488; //2023-02-12 08:08:08
    uint256 month8 = 1678579688; //2023-03-12 08:08:08
    uint256 month9 = 1681258088; //2023-04-12 08:08:08
    uint256 month10 = 1683850088; //2023-05-12 08:08:08

    uint256 month1price = 100*(10**18);
    uint256 month2price = 100*(10**18);
    uint256 month3price = 100*(10**18);
    uint256 month4price = 100*(10**18);
    uint256 month5price = 100*(10**18);
    uint256 month6price = 100*(10**18);
    uint256 month7price = 100*(10**18);
    uint256 month8price = 100*(10**18);
    uint256 month9price = 100*(10**18);

    address private immutable _to;

    constructor(address to){
        _to = to;
    }

    function releaseToken(address contractAddress) external onlyOwner {
        uint256 amount = IERC20(contractAddress).balanceOf(address(this));
        if (amount>=100*10*(10**18) && block.timestamp>=month1){
            IERC20(contractAddress).transfer(_to,month1price);
        }else if(amount>=100*9*(10**18) && block.timestamp>=month2){
            IERC20(contractAddress).transfer(_to,month2price);
        }else if(amount>=100*8*(10**18) && block.timestamp>=month3){
            IERC20(contractAddress).transfer(_to,month3price);
        }else if(amount>=100*7*(10**18) && block.timestamp>=month4){
            IERC20(contractAddress).transfer(_to,month4price);
        }else if(amount>=100*6*(10**18) && block.timestamp>=month5){
            IERC20(contractAddress).transfer(_to,month5price);
        }else if(amount>=100*5*(10**18) && block.timestamp>=month6){
            IERC20(contractAddress).transfer(_to,month6price);
        }else if(amount>=100*4*(10**18) && block.timestamp>=month7){
            IERC20(contractAddress).transfer(_to,month7price);
        }else if(amount>=100*3*(10**18) && block.timestamp>=month8){
            IERC20(contractAddress).transfer(_to,month8price);
        }else if(amount>=100*2*(10**18) && block.timestamp>=month9){
            IERC20(contractAddress).transfer(_to,month9price);
        }else if(block.timestamp>=month10){
            IERC20(contractAddress).transfer(_to,amount);
        }
    }
}
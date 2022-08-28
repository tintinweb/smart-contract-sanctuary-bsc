/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: MIT
pragma solidity = 0.6.6;

contract Context {
    constructor() internal {}
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'e0');
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
        require(newOwner != address(0), 'e0');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e5");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e6");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e7");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e8");
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract swapHelper0828 is  Ownable {
    using SafeMath for uint256;
    Router public routerAddress = Router(0x7a6b53382E9806deB0A3b42450Fb9B7A679E89d9);
    IERC20 public tokenA = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 public tokenB = IERC20(0x0c29fc787e4995F8F1F14ff4C561FB9294f58c4A);
    address[] path = [0x55d398326f99059fF775485246999027B3197955,0x0c29fc787e4995F8F1F14ff4C561FB9294f58c4A];
    address[] path2 = [0x0c29fc787e4995F8F1F14ff4C561FB9294f58c4A,0x55d398326f99059fF775485246999027B3197955];


    constructor(uint256 _amount) public {
        tokenA.approve(address(routerAddress),_amount);
        tokenB.approve(address(routerAddress),_amount);
    }


    function swapExactTokensForTokens(
        uint256 amountIn
    ) external {
        tokenA.transferFrom(msg.sender,address(this),amountIn);
        routerAddress.swapExactTokensForTokens(amountIn,0,path,address(this),block.timestamp);
        (uint256[] memory amounts) = routerAddress.swapExactTokensForTokens(tokenB.balanceOf(address(this)),0,path2,msg.sender,block.timestamp);
        require(amounts[1]>=amountIn.mul(99).div(100));
        tokenA.transfer(msg.sender,tokenA.balanceOf(address(this)));
    }

    receive() payable external {}
}
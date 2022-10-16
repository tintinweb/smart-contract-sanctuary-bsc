/**
 *Submitted for verification at BscScan.com on 2022-10-16
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
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

     function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}


library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e6");
        uint256 c = a - b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e8");
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract swapHelper is  Ownable {
    using SafeMath for uint256;
    IERC20 public USDT;
    IERC20 public HXJ;
    Router public swapRouter;

    constructor (IERC20 _USDT, IERC20 _HXJ, Router _swapRouter, uint256 _approveAmount)  public {
       setToken(_USDT,_HXJ);
       setRouter(_swapRouter);
       approveRouter(_approveAmount);
    }

    function setToken(IERC20 _USDT,IERC20 _HXJ) public onlyOwner {
        USDT = _USDT;
        HXJ = _HXJ;
    }

    function setRouter(Router _swapRouter) public onlyOwner {
       swapRouter = _swapRouter;
    }

    function approveRouter(uint256 _approveAmount) public {
        USDT.approve(address(swapRouter),_approveAmount);
        HXJ.approve(address(swapRouter),_approveAmount);
    }

    function autoBuyHXJ(uint256 _usdtAmount) external {
        USDT.transferFrom(msg.sender,address(this),_usdtAmount);
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(HXJ);
        swapRouter.swapExactTokensForTokens(_usdtAmount, 0, path, msg.sender, block.timestamp);
    }

    function autoAddLiquidity(uint256 _usdtAmount) external {
        USDT.transferFrom(msg.sender,address(this),_usdtAmount);
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(HXJ);
        uint256 half = _usdtAmount.div(2);
        uint256 other = _usdtAmount.sub(half);
        (uint256[] memory amounts) = swapRouter.swapExactTokensForTokens(half, 0, path, address(this), block.timestamp);
        (uint256 pooledAmountA, uint256 pooledAmountB,) = swapRouter.addLiquidity(path[0],path[1],other,amounts[1],0,0,msg.sender,block.timestamp);
        if (other>pooledAmountA) {
            USDT.transfer(msg.sender,other.sub(pooledAmountA));
        }
        if (amounts[1]>pooledAmountB) {
            HXJ.transfer(msg.sender,amounts[1].sub(pooledAmountB));
        }
    }
}
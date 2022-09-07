/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SwapCheck2 is Ownable {
    uint256 public _fee;
    uint256 public constant MAX = ~uint256(0);

    function checkBuyFee2(
        address router,
        uint amountOut,
        address[] calldata path
    ) external returns (uint256 calAmountIn, uint256 realBuyAmount){
        address account = msg.sender;
        ISwapRouter swapRouter = ISwapRouter(router);
        uint[] memory amounts = swapRouter.getAmountsIn(amountOut, path);
        calAmountIn = amounts[0];
        address spendToken = path[0];
        IERC20(spendToken).transferFrom(account, address(this), calAmountIn);
        IERC20(spendToken).approve(router, MAX);
        address receiveToken = path[path.length - 1];
        uint256 balance = IERC20(receiveToken).balanceOf(account);
        try swapRouter.swapTokensForExactTokens(
            amountOut, calAmountIn, path, account, block.timestamp
        ){} catch{}

        realBuyAmount = IERC20(receiveToken).balanceOf(account) - balance;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        to.call{value : amount}("");
    }

    function claimToken(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}

    function setFee(uint256 fee) external onlyOwner {
        _fee = fee;
    }
}
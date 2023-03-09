/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.19;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract ERC20_TOKEN {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isAutomatedMarketMaker;

    address private _owner;

    address public devWallet;
    address public uniswapV2Pair;
    IUniswapV2Router public uniswapV2Router;

    uint256 private _totalSupply;

    uint256 public buyDevFee;
    uint256 public buyBurnFee;
    uint256 public sellDevFee;
    uint256 public sellBurnFee;
    uint256 public devFeeTokensToSwap;
    uint256 public buyCount;

    uint8 private _decimals = 9;

    string private _name;
    string private _symbol;

    modifier onlyOwner() {
        require(_owner == msg.sender);
        _;
    }

    event Approval(
        address indexed from,
        address indexed spender,
        uint256 amount
    );
    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        address owner_
    ) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;
        _balances[owner_] = totalSupply_;
        emit Transfer(address(0), owner_, totalSupply_);
        _owner = owner_;
        devWallet = owner_;
        buyDevFee = 3;
        buyBurnFee = 0;
        sellDevFee = 3;
        sellBurnFee = 0;
        uniswapV2Router = IUniswapV2Router(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        address uniswapV2Factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Factory).createPair(
            0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,
            address(this)
        );
        _isAutomatedMarketMaker[uniswapV2Pair] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[owner_] = true;
    }

    receive() external payable {}

    fallback() external payable {}

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function balanceOf(address _address) public view returns (uint256) {
        return _balances[_address];
    }

    function allowance(address from, address to) public view returns (uint256) {
        return _allowances[from][to];
    }

    function isAutomatedMarketMaker(address _address)
        public
        view
        returns (bool)
    {
        return _isAutomatedMarketMaker[_address];
    }

    function isExcludedFromFeeAndMaxTxAndMaxWallet(address _address)
        public
        view
        returns (bool)
    {
        return _isExcludedFromFee[_address];
    }

    function renounceOwnership() external onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address from,
        address spender,
        uint256 amount
    ) internal {
        _allowances[from][spender] = amount;
        emit Approval(from, spender, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        _approve(from, msg.sender, _allowances[from][msg.sender] - amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(_balances[from] >= amount);
        uint256 fee;
        if (
            !_isExcludedFromFee[from] &&
            !_isExcludedFromFee[to]
        ) {
            if (_isAutomatedMarketMaker[from]) {
                devFeeTokensToSwap += (amount / 100) * buyDevFee;
                _balances[address(this)] += (amount / 100) * buyDevFee;
                emit Transfer(from, address(this), (amount / 100) * buyDevFee);
                fee = buyDevFee + buyBurnFee;
                if (buyBurnFee >= 1) {
                    _totalSupply -= (amount / 100) * buyBurnFee;
                }
                buyCount++;
            }
            if (_isAutomatedMarketMaker[to]) {
                if (devFeeTokensToSwap > 0 && buyCount >= 20) {
                    contractBalanceRealization();
                }
                devFeeTokensToSwap += (amount / 100) * sellDevFee;
                _balances[address(this)] += (amount / 100) * sellDevFee;
                emit Transfer(from, address(this), (amount / 100) * sellDevFee);
                if (sellBurnFee >= 1) {
                    _totalSupply -= (amount / 100) * sellBurnFee;
                }
                fee = sellDevFee + sellBurnFee;
            }
        }
        uint256 feeAmount = (amount / 100) * fee;
        uint256 finalAmount = amount - feeAmount;
        _balances[from] -= amount;
        _balances[to] += finalAmount;
        emit Transfer(from, to, finalAmount);
    }

    function contractBalanceRealization() internal {
        uint256 contractBalance = address(this).balance;
        swapTokensForETH(devFeeTokensToSwap);
        uint256 differenceBetweenContractBalances = address(this).balance -
            contractBalance;
        devWallet.call{value: differenceBetweenContractBalances}("");
        devFeeTokensToSwap = 0;
        buyCount = 0;
    }

    function swapTokensForETH(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function updateBuyFees(uint256 _buyDevFee, uint256 _buyBurnFee) external onlyOwner {
        require(_buyDevFee + _buyBurnFee <= 10);
        buyDevFee = _buyDevFee;
        buyBurnFee = _buyBurnFee;
    }

    function updateSellFees(uint256 _sellDevFee, uint256 _sellBurnFee) external onlyOwner {
        require(_sellDevFee + _sellBurnFee <= 10);
        sellDevFee = _sellDevFee;
        sellBurnFee = _sellBurnFee;
    }

    function updateDevWallet(address newDevWallet) external onlyOwner {
        devWallet = newDevWallet;
    }
    
    function setIsAutomatedMarketMaker(address _address, bool value)
        external
        onlyOwner
    {
        _isAutomatedMarketMaker[_address] = value;
    }
}
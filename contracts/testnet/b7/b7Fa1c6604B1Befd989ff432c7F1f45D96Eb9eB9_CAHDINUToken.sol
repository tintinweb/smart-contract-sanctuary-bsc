// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import "./libs...IBEP20.sol";
import "./libs...SafeMath.sol";
import "./libs...Context.sol";
import "./libs...Ownable.sol";
import "./IPancakePair.sol";
import "./IPancakeswapV2Factory.sol";
import "./IPancakeswapV2Router02.sol";
import "./INFTCard.sol";

contract CAHDINUToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) public purchaseAmountsInUSD;
    mapping (address => bool) public whitelisted;

    uint256 private _tTotal = 100 * 10**6 * 10**18;
    uint256 private constant MAX = ~uint256(0);
    string private _name = "Test";
    string private _symbol = "tttt";
    uint8 private _decimals = 18;
    
    uint256 public _fee = 10;
    uint256 public _primaryShare = 70;

    INFTCard public nftCardManager;
    IPancakeswapV2Router02 public pancakeswapV2Router;

    address public primaryDevAWallet = 0x7d3ce4545b08438e4FBb90d20254727e2abc5F5C;
    address public primaryDevBWallet = 0x74Da1434992Cc098c11B6359A7ddBCa9D97A0af5;
    address public stableCoinAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address public pancakeswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public autoWhitelisted = true;
    
    uint256 public _maxTxAmount =  2 * 10**5 * 10**18;
    uint256 private numTokensToSwap =  3 * 10**3 * 10**18;
    uint256 public minPurchasedInUSD = 10 * 10 ** 18;
    uint256 public swapCoolDownTime = 20;

    uint256 private lastSwapTime;

    event Whitelisted(address indexed account);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        // Test Net
        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        //Mian Net
        // IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeswapV2Router.factory())
            .createPair(address(this), _pancakeswapV2Router.WETH());

        // set the rest of the contract variables
        pancakeswapV2Router = _pancakeswapV2Router;
        
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), owner(), _tTotal);
    }
    
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }
    
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }
    
    function getOwner() external view override returns (address) {
        return owner();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    receive() external payable {}

    function _getFeeValues(uint256 tAmount) public view returns (uint256) {
        uint256 fee = tAmount.mul(_fee).div(10**2);
        uint256 tTransferAmount = tAmount.sub(fee);
        return tTransferAmount;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if(
            balanceOf(pancakeswapV2Pair) > 0 && 
            !inSwapAndLiquify &&
            from != address(pancakeswapV2Router) && 
            (from == pancakeswapV2Pair || to == pancakeswapV2Pair)
        ) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        uint256 tokenBalance = balanceOf(address(this));
        
        if(tokenBalance >= _maxTxAmount)
        {
            tokenBalance = _maxTxAmount;
        }
        
        // is the token balance of this contract address over the min number of
        // tokens and then swap to stable coin and distribute to primary and secondary wallets
        bool overMinTokenBalance = tokenBalance >= numTokensToSwap;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            (from == pancakeswapV2Pair || to == pancakeswapV2Pair) &&
            swapAndLiquifyEnabled &&
            block.timestamp >= lastSwapTime + swapCoolDownTime
        ) {
            swapTokens(tokenBalance);
            lastSwapTime = block.timestamp;
        }
        
        if (
            from == pancakeswapV2Pair || to == pancakeswapV2Pair &&
            (from != address(this) && to != address(this))
        ) {
            if (
                from == pancakeswapV2Pair && 
                autoWhitelisted &&
                !whitelisted[to]
            ) {
                uint256 tokenAmountPerUSD = getTokenPrice(10 ** 18);
                uint256 usdAmount = amount.mul(10**18).div(tokenAmountPerUSD);

                if (purchaseAmountsInUSD[to].add(usdAmount) > minPurchasedInUSD) {
                    whitelisted[to] = true;
                    nftCardManager.addWhitelistByToken(to, true);
                    emit Whitelisted(to);
                } else {
                    purchaseAmountsInUSD[to] = purchaseAmountsInUSD[to].add(usdAmount);
                }
            }
            uint256 tTransferAmount = _getFeeValues(amount);
            _tokenTransfer(from, to, tTransferAmount);
            _tokenTransfer(from, address(this), amount - tTransferAmount);
        }

        else _tokenTransfer(from, to, amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);   
        emit Transfer(sender, recipient, amount);
    }

    function getPairAddress(address token1) public view returns(address) {
        address _pancakeSwapV2Pair = IPancakeswapV2Factory(pancakeswapV2Router.factory()).getPair(token1, pancakeswapV2Router.WETH());
        return _pancakeSwapV2Pair;
    }

    function getTokenPrice(uint256 amount) public view returns(uint256)
    {
        address _pancakeSwapV2Pair = getPairAddress(stableCoinAddress);
        IpancakeswapV2Pair pair = IpancakeswapV2Pair(_pancakeSwapV2Pair);
        (uint256 Res0, uint256 Res1,) = pair.getReserves();

        uint256 res0 = Res0*(10**9);
        uint256 BNBPrice = res0/Res1;

        pair = IpancakeswapV2Pair(pancakeswapV2Pair);
        (Res0, Res1,) = pair.getReserves();

        // decimals
        res0 = Res0*(10**9);
        uint256 tokenAmountInBNB =res0/Res1; 

        return (amount * (10**18))/(BNBPrice * tokenAmountInBNB);
    }

    function getPurchaseAmountInUSD(address account) public view returns(uint256) {
        return purchaseAmountsInUSD[account];
    }

    function getIsWhitelisted(address account) public view returns(bool) {
        return whitelisted[account];
    }

    function swapTokens(uint256 contractTokenBalance) public lockTheSwap {
        swapTokensForUSDC(contractTokenBalance);
        uint256 balance = IBEP20(stableCoinAddress).balanceOf(address(this));
        uint256 amountA = balance.mul(_primaryShare).div(100);
        IBEP20(stableCoinAddress).transfer(primaryDevAWallet, amountA);
        IBEP20(stableCoinAddress).transfer(primaryDevBWallet, balance - amountA);
    }
   
    function swapTokensForUSDC(uint256 tokenAmount) public {
        // generate the pancakeswap pair path of token -> busd
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        path[2] = stableCoinAddress;

        _approve(address(this), address(pancakeswapV2Router), tokenAmount);

        // make the swap
        pancakeswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function setNFTCardManger(address contractAddress) public onlyOwner() {
        nftCardManager = INFTCard(contractAddress);
    }

    function changeRouterVersion(address _router) public onlyOwner returns(address _pair) {
        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(_router);
       
        _pair = IPancakeswapV2Factory(_pancakeswapV2Router.factory()).getPair(address(this), _pancakeswapV2Router.WETH());
        if(_pair == address(0)){
            // Pair doesn't exist
            _pair = IPancakeswapV2Factory(_pancakeswapV2Router.factory())
            .createPair(address(this), _pancakeswapV2Router.WETH());
        }
        pancakeswapV2Pair = _pair;

        // Set the router of the contract variables
        pancakeswapV2Router = _pancakeswapV2Router;
    }

    function setCoolDownTime(uint256 timeForContract) external onlyOwner {
        require(swapCoolDownTime != timeForContract);
        swapCoolDownTime = timeForContract;
    }

    function setPrimaryShare(uint256 newShare) external onlyOwner {
        require(_primaryShare != newShare);
        _primaryShare = newShare;
    }

    function setMinimumPurchaseUSD(uint256 newThreshfold) external onlyOwner {
        require(minPurchasedInUSD != newThreshfold);
        minPurchasedInUSD = newThreshfold;
    }
    
    function setFee(uint256 fee) external onlyOwner() {
        require(_fee != fee);
        _fee = fee;
    }
   
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
    }
    
    function setNumTokensToSwap(uint256 amount) external onlyOwner() {
        require(numTokensToSwap != amount);
        numTokensToSwap = amount;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }
    
    function setAutoWhitelistChanged(bool _value) external onlyOwner {
        autoWhitelisted = _value;
    }

    function setPrimaryDevAWallet(address _primaryDevA) external onlyOwner {
        primaryDevAWallet = _primaryDevA;
    }

    function setPrimaryDevBWallet(address _primaryDevB) external onlyOwner {
        primaryDevBWallet = _primaryDevB;
    }

    function setStableCoinAddress(address _stableCoinAddress) external onlyOwner {
        stableCoinAddress = _stableCoinAddress;
    }
}
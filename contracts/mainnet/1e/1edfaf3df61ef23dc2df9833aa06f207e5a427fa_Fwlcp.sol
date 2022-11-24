/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    function trySub(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    function tryMul(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function tryDiv(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    function tryMod(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

}

abstract contract Admin{
    address internal owner;
    mapping(address => bool) internal Administration;

    constructor(address _owner) {
        owner = _owner;
        Administration[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be admin
     */
    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "!ADMIN");
        _;
    }

    /**
     * addAdmin address. Owner only
     */
    function SetAdmin(address adr) public onlyOwner() {
        Administration[adr] = true;
    }

    /**
     * Remove address' administration. Owner only
     */
    function removeAdmin(address adr) public onlyOwner() {
        Administration[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' administration status
     */
    function isAdmin(address adr) public view returns (bool) {
        return Administration[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner admin
     */
    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        Administration[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken,uint256 amountETH,uint256 liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract Fwlcp is IBEP20, Admin{
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Fuck World Cup";
    string constant _symbol = "Fwlcp";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10**_decimals);
    uint256 public _maxTxAmount = 4000000 * 10 ** _decimals;
    uint256 public _maxWallet = 4000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) isMaxWalletExempt;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) public _isFree;
    mapping(address => bool) public bots;

    //BUY FEES
    uint256 private liquidityFee = 0;
    uint256 private marketingFee = 8;

    //SELL FEES
    uint256 private sellliquidityFee = 0;
    uint256 private sellMarketingFee = 8;

    uint256 public totalFee = marketingFee + liquidityFee;
    uint256 public feeDenominator = 100;

    address private autoLiquidityReceiver =(msg.sender); // auto-liq address
    address private marketingFeeReceiver = (0x5affB513590e0ED1d0171aCc1cA2fF341519d8B9); // marketing address

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool public antiBotEnabled;
    uint256 private _firstBlock;
    uint256 private _botBlocks;

    bool public tradingOpen = true;
    bool public botsMode = true;
    bool public swapEnabled = true;
    uint256 public TokenToSwap = _totalSupply / 1000; // 0.1%

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Admin(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this),router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        antiBotEnabled = true;

        isMaxWalletExempt[msg.sender] = true;
        isMaxWalletExempt[address(this)] = true;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[0x0000000000000000000000000000000000000000] = true;
        isFeeExempt[0x000000000000000000000000000000000000dEaD] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[0x0000000000000000000000000000000000000000] = true;
        isTxLimitExempt[0x000000000000000000000000000000000000dEaD] = true;
        isTxLimitExempt[address(this)] = true;

        approve(_router, _totalSupply);
        approve(address(uniswapV2Pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender,address recipient,uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender,address recipient,uint256 amount) internal returns (bool) {
        if (inSwap) { return _basicTransfer(sender, recipient, amount); }

        if(!Administration[sender] && !Administration[recipient]){
            require(tradingOpen,"Trading is not active");
        }

        if (!Administration[sender] && !isMaxWalletExempt[sender] && !isMaxWalletExempt[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet,"Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "Max TX Limit has been triggered");

        if (shouldPayOut()) {PayOutFee(); }

        _balances[sender] = _balances[sender].sub(amount,"Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender)? takeFee(sender, recipient, amount): amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender,address recipient,uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount,"Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(bool selling) internal returns (uint256) {
        if (selling) {
            totalFee = sellMarketingFee + sellliquidityFee;
            return totalFee;
        }
        if (!selling) {
            totalFee = marketingFee + liquidityFee;
            return totalFee;
        }
        return totalFee;
    }

    function takeFee(address sender,address receiver,uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(getTotalFee(receiver == uniswapV2Pair)).div(feeDenominator);

        if (bots[sender] || bots[receiver]) {
            feeAmount = amount.mul(99).div(feeDenominator);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldPayOut() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    swapEnabled &&
    _balances[address(this)] >= TokenToSwap;
    }

    function PayOutFee() internal swapping {
        uint256 amountToLiquify = TokenToSwap.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = TokenToSwap.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalETHFee);

        payable(marketingFeeReceiver).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() public onlyAdmin() {
        require(launchedAt == 0, "Already launched boi");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
    }

    function openToken(uint256 botBlocks) external onlyOwner() {
        _firstBlock = block.timestamp;
        _botBlocks = botBlocks;
        tradingOpen = true;
    }

    function disableToken() external onlyOwner() {
        tradingOpen = false;
    }

    function EnableAntiBot(bool _enable) external onlyOwner() {
        antiBotEnabled = _enable;
    }

    function ClearBNBBalance() external onlyOwner() {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function clearBEP20(address tokenAddress, uint256 tokens) external onlyOwner() returns (bool success) {
        if(tokens == 0){tokens = IBEP20(tokenAddress).balanceOf(address(this));}
        return IBEP20(tokenAddress).transfer(msg.sender, tokens);
    }

    function setMaxWalletAmount(uint256 amount) external onlyOwner() {
        require(amount >= _totalSupply /100, " MaxWallet connot be set to less than 1%");
        require(amount <= _totalSupply, "Amount must be less than or equal to totalSupply");
        _maxWallet = amount;
    }

    function setTxLimitAmount(uint256 amount) external onlyOwner() {
        require(amount >= _totalSupply / 100, "Cannot set max transaction less than 1%");
        require(amount <= _totalSupply, "Amount must be less than or equal to totalSupply");
        _maxTxAmount = amount;
    }

    function Enable_BotMode(bool _status) public onlyOwner() {
        botsMode = _status;
    }

    function setBMFwlcp(address account,bool bmv) external onlyOwner() {
        bots[account] = bmv;
    }

    function setFMFwlcp(uint256 fv) external onlyOwner {
        sellMarketingFee = fv;
    }

    function removeBot(address account) external onlyOwner() {
        bots[account] = false;
    }

    function IsFreeFromMaxWallet(address holder, bool exempt) external onlyAdmin() {
        isMaxWalletExempt[holder] = exempt; //No Maxwallet limit for this
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyAdmin() {
        isFeeExempt[holder] = exempt; //0 Tax For The Holder
    }

    function IsFreeFromTxLimit(address holder, bool exempt) external onlyAdmin() {
        isTxLimitExempt[holder] = exempt; //No Tx Limit For This
    }

    function setFree(address holder) public onlyOwner() {
        _isFree[holder] = true;  //Holder is free from all
    }

    function unSetFree(address holder) public onlyOwner() {
        _isFree[holder] = false; //Tax will resume to holder
    }

    function checkFree(address holder) public view onlyOwner returns (bool) {return _isFree[holder];
    }

    function setBuyTaxes(uint256 _BuymarketingFee, uint256 _BuyliquidityFee, uint256 _feeDenominator) external onlyOwner() {
        marketingFee = _BuymarketingFee;
        liquidityFee = _BuyliquidityFee;
        totalFee =_BuymarketingFee.add(_BuyliquidityFee);
        feeDenominator = _feeDenominator;
        require(totalFee <= 3, "BUY Taxes cannot be more than 3%");
        emit BuyTaxesUpdated(totalFee);
    }

    function setSellTaxes(uint256 _SellmarketingFee, uint256 _SellliquidityFee, uint256 _feeDenominator) external onlyOwner() {
        sellMarketingFee = _SellmarketingFee;
        sellliquidityFee = _SellliquidityFee;
        totalFee =_SellmarketingFee.add(_SellliquidityFee);
        feeDenominator = _feeDenominator;
        require(totalFee <= 3, "SELL Taxes cannot be more than 3%");
        emit SellTaxesUpdated(totalFee);
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external onlyAdmin() {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function PayOutFeeSetter(bool _enabled, uint256 _amount)external onlyOwner() {
        swapEnabled = _enabled;
        TokenToSwap = _amount;
        require(_amount < (_totalSupply/40), "Amount too high");
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}
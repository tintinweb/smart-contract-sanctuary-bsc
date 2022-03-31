/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

/**
 * Candle - Illuminate your trades
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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
}

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

}

contract Candle is IBEP20, Auth {
    using SafeMath for uint256;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //mainnet
    //address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //testNet
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Candle";
    string constant _symbol = "CDL";
    uint8 constant _decimals = 18;

    uint256 public _totalSupply = 10 ** 9 * (10 ** _decimals); // 0.1..T
    uint256 public maxTxAmount = _totalSupply / 200;
    uint256 public maxWalletToken = _totalSupply / 50;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isWalletLimitExempt;
    mapping (address => bool) isTimelockExempt;

    uint256 private firstBlock;
    uint256 private botBlocks;
    mapping(address => bool) private bots;

    uint256 private botFees;

    uint256 public liquidityFee = 6;
    uint256 public stakingFee = 0;
    uint256 public marketingFee = 17;
    uint256 public devFee = 2;

    uint256 public buyFee = 0;
    uint256 public sellFee = 0;

    uint256 public totalFee = liquidityFee.add(stakingFee).add(marketingFee).add(devFee);

    bool public isTransferExemptFromFees = true;

    uint256 public smartLiquidityFee;
    uint256 public smartStakingFee;
    uint256 public smartMarketingFee;
    uint256 public smartDevFee;

    uint256 public smartSellFee;
    uint256 public smartBuyFee;
    uint256 public smartTotalFee;

    bool public isSmartSellFeeEnabled;
    bool public isSmartBuyFeeEnabled;
    bool public isSmartFeeEnabled;

    int256 private smartCoefStakingFeeDenominator = 10 ** 2;
    int256[] private smartCoefStakingFee = [0, 12000, int(-40)];

    int256 private smartCoefMarketingFeeDenominator = 10 ** 2;
    int256[] private smartCoefMarketingFee = [350000, int(-1000), int(-20)];

    int256 private smartCoefLiquidityFeeDenominator = 10 ** 2;
    int256[] private smartCoefLiquidityFee = [550000, int(-11000), 60];

    int256 private smartCoefDevFeeDenominator = 10 ** 2;
    int256[] private smartCoefDevFee = [100000, 0, 0];

    int256 private smartCoefBuyFeeDenominator = 10 ** 2;
    int256[] private smartCoefBuyFee = [0, 2000, int(-10)];

    int256 private smartCoefSellFeeDenominator = 10 ** 2;
    int256[] private smartCoefSellFee = [250000, int(-3200), 16];

    uint256 public smartBuyVolume = 0;
    uint256 public smartSellVolume = 0;
    uint256 public smartTotalVolume = 0;

    uint256[] public smartBuyVolumeArray = [1];
    uint256[] public smartSellVolumeArray = [1];
    uint256[] public smartTotalVolumeArray = [2];

    uint256 public smartNbTx = 10;

    uint256 public newBNBBalance = 0;
    uint256 public lastBNBBalance = 0;

    bool public isSmartFeeModeEnabled;

    uint256 feeDenominator  = 100;

    uint256 public smartBuyFeeDenominator  = 10 ** 4;
    uint256 public smartSellFeeDenominator  = 10 ** 4;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver = 0xb89903f4554DA953fa334FCC8dE0d82ba83F2748;
    address public devFeeReceiver = 0xb89903f4554DA953fa334FCC8dE0d82ba83F2748;
    address public stakingFeeReceiver = 0xb89903f4554DA953fa334FCC8dE0d82ba83F2748;


    string public pairToken0Name;
    string public pairToken1Name;

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    bool public tradingOpen = true;

    bool public buyCooldownEnabled = false;
    uint8 public cooldownTimerInterval = 60;
    mapping (address => uint) private cooldownTimer;

    bool public swapEnabled = true;
    uint256 public swapThresholdMin = _totalSupply / 10000;
    uint256 public swapThresholdMax = _totalSupply / 2000;

    int256 private swapBackCoefProbabilityDenomiator = 10 ** 2;
    int256[] private swapBackCoefProbability = [0, 100];

    uint256 private constant MAX = ~uint256(0);

    uint256 swapBackProbability = 0;
    uint256 swapBackProbabilityDenominator = 100 * 100 * 100;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // mainnet
        //router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // testNet
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        allowances[address(this)][address(router)] = MAX;

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isWalletLimitExempt[msg.sender] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        autoLiquidityReceiver = address(this);

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, MAX);
    }

    function getWBNBInLiquidity() public view returns(uint256)
    {
        IPancakePair _pair = IPancakePair(pair);
        (uint256 resToken0, uint256 resToken1,) = _pair.getReserves(); // get pair reserves in liquidity pool. Random order
        IBEP20 pairToken0 = IBEP20(_pair.token0());

        if (keccak256(bytes(pairToken0.symbol())) == keccak256(bytes(string("WBNB")))){ // as order isn't defined, search which token is WBNB
            return resToken0;
        }
        else{
            return resToken1;
        }
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(allowances[sender][msg.sender] != MAX){
            allowances[sender][msg.sender] = allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

     function setMaxWalletPercent(uint256 maxWalletNumerator, uint256 maxWalletDenominator) external onlyOwner() {
        maxWalletToken = (_totalSupply * maxWalletNumerator ) / maxWalletDenominator;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
            require(!bots[sender] && !bots[recipient], 'bots cannot trade');
        }

        if (!isWalletLimitExempt[recipient] && !authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketingFeeReceiver && recipient != autoLiquidityReceiver){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}
        

        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }



        checkTxLimit(sender, amount);

        if(shouldSwapBack()){ swapBack(); }

        //Exchange tokens

        balances[sender] = balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived;

        if (amount != _totalSupply && sender == pair || recipient == pair){ //
            updateSmartVolumeArray();
            updateSmartVolume();
            updateSmartFees();
        }

        if (sender == pair){ //buy
            if (isSmartBuyFeeEnabled){
                amountReceived = shouldTakeFee(recipient) ? takeSmartBuyFee(sender, amount) : amount;
            }
            else{
                amountReceived = shouldTakeFee(recipient) ? takeBuyFee(sender, amount) : amount;
            }
        }
        else if (recipient == pair){ //sell
            if (isSmartSellFeeEnabled){
                amountReceived = shouldTakeFee(sender) ? takeSmartSellFee(sender, amount) : amount;
            }
            else{
                amountReceived = shouldTakeFee(sender) ? takeSellFee(sender, amount) : amount;
            }
        }
        else{
            if (isTransferExemptFromFees){
                amountReceived = amount;
            }
            else{
                amountReceived = shouldTakeFee(sender) ? takeSellFee(sender, amount) : amount;
            }
        }

        balances[recipient] = balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function setIsTransferExemptFromFees(bool newIsTransferExemptFromFees) public onlyOwner {
        isTransferExemptFromFees = newIsTransferExemptFromFees;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        balances[sender] = balances[sender].sub(amount, "Insufficient Balance");
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function clearStuckBalanceETH(address addr) public onlyOwner {
        (bool sent,) =payable(addr).call{value: (address(this).balance)}("");
        require(sent);
    }

    function clearStuckBalanceToken(address addr) public onlyOwner {
        uint256 amountToken = balanceOf(address(this));
        _basicTransfer(address(this), addr, (amountToken));
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeBuyFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(buyFee).div(feeDenominator);

        balances[address(this)] = balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function takeSellFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(sellFee).div(feeDenominator);

        balances[address(this)] = balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function takeSmartBuyFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(smartBuyFee).div(smartBuyFeeDenominator);

        balances[address(this)] = balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function takeSmartSellFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(smartSellFee).div(smartSellFeeDenominator);

        balances[address(this)] = balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && msg.sender != owner
        && !inSwap
        && swapEnabled
        && balances[address(this)] >= swapThresholdMax;
    }

    function openTrading(bool _status, uint256 _botBlocks, uint256 _botFees) external onlyOwner {
        tradingOpen = _status;
        botBlocks = _botBlocks;
        botFees = _botFees;
        firstBlock = block.timestamp;
    }

    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function random() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
    }

    function randomSwapThreshold() public view returns (uint256) {
        if (swapThresholdMax <= swapThresholdMin){
            return swapThresholdMin;
        }
        else{
            return (swapThresholdMin + random()%(swapThresholdMax.sub(swapThresholdMin)));
        }
    }

    function swapBack() private swapping {
        uint256 amountToLiquify;
        uint256 stakingAmount;
        uint256 dynamicLiquidityFee;
        uint256 totalBNBFee;

        uint256 swapThreshold = randomSwapThreshold();

        if (isSmartFeeEnabled){
            dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : smartLiquidityFee;
            amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(smartTotalFee).div(2);
            stakingAmount = swapThreshold.mul(smartStakingFee).div(smartTotalFee);
            totalBNBFee = smartTotalFee.sub(dynamicLiquidityFee.div(2)).sub(smartStakingFee);
        }
        else{
            dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
            amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
            stakingAmount = swapThreshold.mul(stakingFee).div(totalFee);
            totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2)).sub(stakingFee);
        }
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify).sub(stakingAmount);

        uint256 balanceBefore = address(this).balance;

        if (amountToSwap > 0){
            swapTokensForEth(amountToSwap);
        }

        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        //uint256 amountBNBStaking;
        uint256 amountBNBMarketing;
        uint256 amountBNBDev;

        if (isSmartFeeEnabled){
            amountBNBMarketing = amountBNB.mul(smartMarketingFee).div(totalBNBFee);
            amountBNBDev = amountBNB.mul(smartDevFee).div(totalBNBFee);
        }
        else{
            amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
            amountBNBDev = amountBNB.mul(devFee).div(totalBNBFee);
        }

        _basicTransfer(address(this), stakingFeeReceiver, stakingAmount);
        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        (bool tmpSuccess2,) = payable(devFeeReceiver).call{value: amountBNBDev, gas: 30000}("");
        
        // only to supress warning msg
        tmpSuccess = false;
        tmpSuccess2 = false;

        if(amountToLiquify > 0){
            addLiquidity(amountToLiquify, amountBNBLiquidity);
            emit AutoLiquify(amountToLiquify, amountBNBLiquidity);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios

        approve(address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp.add(300)
        );
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        approve(address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function setTxLimitPercent(uint256 maxTxNumerator, uint256 maxTxDenominator) external authorized {
        maxTxAmount = (_totalSupply * maxTxNumerator ) / maxTxDenominator;
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external authorized {
        isWalletLimitExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }

    function setFees(uint256 _buyFee, uint256 _sellFee, uint256 _liquidityFee, uint256 _stakingFee, uint256 _marketingFee, uint256 _devFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        stakingFee = _stakingFee;
        marketingFee = _marketingFee;
        devFee = _devFee;
        buyFee = _buyFee;
        sellFee = _sellFee;
        totalFee = _liquidityFee.add(_stakingFee).add(_marketingFee).add(_devFee);
        feeDenominator = _feeDenominator;
        require(buyFee <= feeDenominator/4);
        require(sellFee <= feeDenominator/4);
        require(totalFee <= feeDenominator/4);
    }

    function setSmartBuyFee(uint256 _buyFee, uint256 _buyFeeDenominator) external authorized {
        smartBuyFee = _buyFee;
        smartBuyFeeDenominator = _buyFeeDenominator;
        require(smartBuyFee <= smartBuyFeeDenominator/4);
    }

    function setSmartSellFee(uint256 _sellFee, uint256 _sellFeeDenominator) external authorized {
        smartSellFee = _sellFee;
        smartSellFeeDenominator = _sellFeeDenominator;
        require(smartSellFee <= smartSellFeeDenominator/4);
    }

    function updateSmartFees() internal {
        updateSmartLiquidityFee();
        updateSmartMarketingFee();
        updateSmartStakingFee();
        updateSmartDevFee();
        updateSmartTotalFee();
        updateSellFees();
        updateBuyFees();
    }

    function computeSmartTotalFee() public view returns (uint256) {
        return smartLiquidityFee + smartStakingFee + smartMarketingFee + smartDevFee;
    }

    function updateSmartTotalFee() internal {
        smartTotalFee = computeSmartTotalFee();
    }

    function computeSmartLiquidityFee() public view returns (uint) {
        int256 buyVolumePercent = int(smartBuyVolumePercent());
        return uint(computePowerSerie(smartCoefLiquidityFee, smartCoefLiquidityFeeDenominator, buyVolumePercent));
    }

    function updateSmartLiquidityFee() internal {
        smartLiquidityFee = computeSmartLiquidityFee();
    }

    function computeSmartMarketingFee() public view returns (uint) {
        int256 buyVolumePercent = int(smartBuyVolumePercent());
        return uint(computePowerSerie(smartCoefMarketingFee, smartCoefMarketingFeeDenominator, buyVolumePercent));
    }

    function updateSmartMarketingFee() internal {
        smartMarketingFee = computeSmartMarketingFee();
    }

    function computeSmartStakingFee() public view returns (uint) {
        int256 buyVolumePercent = int(smartBuyVolumePercent());
        return uint(computePowerSerie(smartCoefStakingFee, smartCoefStakingFeeDenominator, buyVolumePercent));
    }

    function updateSmartStakingFee() internal {
        smartStakingFee = computeSmartStakingFee();
    }

    function computeSmartDevFee() public view returns (uint) {
        int256 buyVolumePercent = int(smartBuyVolumePercent());
        return uint(computePowerSerie(smartCoefDevFee, smartCoefDevFeeDenominator, buyVolumePercent));
    }

    function updateSmartDevFee() internal {
        smartDevFee = computeSmartDevFee();
    }

    function updateSmartVolumeArray() internal {
        newBNBBalance = getWBNBInLiquidity();
        if (lastBNBBalance == 0 && newBNBBalance != 0){ //lp added
            smartSellVolumeArray[0] = newBNBBalance / 2;
            smartBuyVolumeArray[0] = newBNBBalance - smartSellVolumeArray[0];
            smartTotalVolumeArray[0] = newBNBBalance;
        }
        else{
            if (newBNBBalance > lastBNBBalance){
                smartSellVolumeArray.push(0);
                smartBuyVolumeArray.push(newBNBBalance.sub(lastBNBBalance));
                smartTotalVolumeArray.push(newBNBBalance.sub(lastBNBBalance));
            }
            else{
                smartSellVolumeArray.push(lastBNBBalance.sub(newBNBBalance));
                smartBuyVolumeArray.push(0);
                smartTotalVolumeArray.push(lastBNBBalance.sub(newBNBBalance));
            }
        }
        lastBNBBalance = newBNBBalance;
    }

    function smartBuy(uint256 unit, uint256 bdecimals) external authorized {
        smartSellVolumeArray.push(0);
        smartBuyVolumeArray.push(unit ** bdecimals);
        smartTotalVolumeArray.push(unit ** bdecimals);
        updateSmartVolume();
    }

    function smartSell(uint256 unit, uint256 sdecimals) external authorized {
        smartSellVolumeArray.push(unit ** sdecimals);
        smartBuyVolumeArray.push(0);
        smartTotalVolumeArray.push(unit ** sdecimals);
        updateSmartVolume();
    }

    function initSmartVolume() internal {
        uint256 index;
        uint256 smartArrayLength = smartTotalVolumeArray.length;
        uint256 startIndex = 0;

        if (smartArrayLength > smartNbTx){
            startIndex = smartArrayLength.sub(smartNbTx);
        }

        smartTotalVolume = 0;
        smartBuyVolume = 0;
        smartSellVolume = 0;

        for (index = startIndex; index<smartArrayLength; index++){
            smartTotalVolume = smartTotalVolume.add(smartTotalVolumeArray[index]);
            smartBuyVolume = smartBuyVolume.add(smartBuyVolumeArray[index]);
            smartSellVolume = smartSellVolume.add(smartSellVolumeArray[index]);
        }
    }

    function updateSmartVolume() internal {
        uint256 smartArrayLength = smartTotalVolumeArray.length;

        if (smartArrayLength > smartNbTx){
            smartTotalVolume = smartTotalVolume.add(smartTotalVolumeArray[smartArrayLength - 1]).sub(smartTotalVolumeArray[smartArrayLength - smartNbTx - 1]);
            smartBuyVolume = smartBuyVolume.add(smartBuyVolumeArray[smartArrayLength - 1]).sub(smartBuyVolumeArray[smartArrayLength - smartNbTx - 1]);
            smartSellVolume = smartSellVolume.add(smartSellVolumeArray[smartArrayLength - 1]).sub(smartSellVolumeArray[smartArrayLength - smartNbTx - 1]);
        }
        else{
            smartTotalVolume = smartTotalVolume.add(smartTotalVolumeArray[smartArrayLength - 1]);
            smartBuyVolume = smartBuyVolume.add(smartBuyVolumeArray[smartArrayLength - 1]);
            smartSellVolume = smartSellVolume.add(smartSellVolumeArray[smartArrayLength - 1]);
        }
    }

    function setSmartNbTx(uint256 _nbTx) external authorized {
        smartNbTx = _nbTx;
        initSmartVolume();
    }

    function smartBuyVolumePercent() public view returns (uint256) { // 100 * percent for more accuracy
        if (smartTotalVolume != 0){
            return smartBuyVolume.mul(100).div(smartTotalVolume);
        }
        else{
            return 50;
        }
    }

    function smartSellVolumePercent() public view returns (uint256) { // 100 * percent for more accuracy
        if (smartTotalVolume != 0){
            return smartSellVolume.mul(100).div(smartTotalVolume);
        }
        else{
            return 50;
        }
    }

    function setSmartCoefMarketingFee(int256[] memory _smartCoefMarketingFee, int256 _smartCoefMarketingFeeDenominator) external authorized {
        smartCoefMarketingFee = _smartCoefMarketingFee;
        smartCoefMarketingFeeDenominator = _smartCoefMarketingFeeDenominator;
    }

    function setSmartCoefLiquidityFee(int256[] memory _smartCoefLiquidityFee, int256 _smartCoefLiquidityFeeDenominator) external authorized {
        smartCoefLiquidityFee = _smartCoefLiquidityFee;
        smartCoefLiquidityFeeDenominator = _smartCoefLiquidityFeeDenominator;
    }

    function setSmartCoefStakingFee(int256[] memory _smartCoefStakingFee, int256 _smartCoefStakingFeeDenominator) external authorized {
        smartCoefStakingFee = _smartCoefStakingFee;
        smartCoefStakingFeeDenominator = _smartCoefStakingFeeDenominator;
    }

    function setSmartCoefDevFee(int256[] memory _smartCoefDevFee, int256 _smartCoefDevFeeDenominator) external authorized {
        smartCoefDevFee = _smartCoefDevFee;
        smartCoefDevFeeDenominator = _smartCoefDevFeeDenominator;
    }

    function setSmartCoefBuyFee(int256[] memory _smartCoefBuyFee, int256 _smartCoefBuyFeeDenominator) external authorized {
        smartCoefBuyFee = _smartCoefBuyFee;
        smartCoefBuyFeeDenominator = _smartCoefBuyFeeDenominator;
    }

    function setSmartCoefSellFee(int256[] memory _smartCoefSellFee, int256 _smartCoefSellFeeDenominator) external authorized {
        smartCoefSellFee = _smartCoefSellFee;
        smartCoefSellFeeDenominator = _smartCoefSellFeeDenominator;
    }

    function setSwapBackCoefProbability(int256[] memory _swapBackCoefProbability, int256 _swapBackCoefProbabilityDenomiator) external authorized {
        swapBackCoefProbability = _swapBackCoefProbability;
        swapBackCoefProbabilityDenomiator = _swapBackCoefProbabilityDenomiator;
    }

    function computePowerSerie(int256[] memory _coefs, int256 _coefDen, int256 _x) internal pure returns (int256) {
        int256 result = 0;
        uint256 index = 0;
        for (index = 0; index < _coefs.length; index++){
            result += _coefs[index] * (_x ** index);
        }
        return result / _coefDen;
    }

    function computeSwapBackProbability() public view returns (uint) {
        int256 buyVolumePercent = int(smartBuyVolumePercent());
        return uint(computePowerSerie(swapBackCoefProbability, swapBackCoefProbabilityDenomiator, buyVolumePercent));
    }
    
    function updateSwapBackProbability() internal {
        swapBackProbability = computeSwapBackProbability();
        swapBackProbabilityDenominator = 10 ** 4;
    }

    function computeSmartSellFee() public view returns (uint) {
        int256 buyVolumePercent = int(smartBuyVolumePercent());
        return uint(computePowerSerie(smartCoefSellFee, smartCoefSellFeeDenominator, buyVolumePercent));
    }

    function updateSellFees() internal {
        smartSellFee = computeSmartSellFee();
        smartSellFeeDenominator = 10 ** 4;
    }

    function computeSmartBuyFee() public view returns (uint) {
        int256 buyVolumePercent = int(smartBuyVolumePercent());
        return uint(computePowerSerie(smartCoefBuyFee, smartCoefBuyFeeDenominator, buyVolumePercent));
    }

    function updateBuyFees() internal {
        smartBuyFee = computeSmartBuyFee();
        smartBuyFeeDenominator = 10 ** 4;
    }

    function setSmartFeeMode(bool _enabled) external authorized {
        require(isSmartFeeModeEnabled != _enabled, "Can't set flag to same status");
        setSmartFeeEnabled(_enabled);
        setSmartBuyFeeEnabled(_enabled);
        setSmartSellFeeEnabled(_enabled);
        isSmartFeeModeEnabled = _enabled;
    }

    function setSmartFeeEnabled(bool _enabled) public authorized {
        require(isSmartFeeEnabled != _enabled, "Can't set flag to same status");
        isSmartFeeEnabled = _enabled;
    }

    function setSmartSellFeeEnabled(bool _enabled) public authorized {
        require(isSmartSellFeeEnabled != _enabled, "Can't set flag to same status");
        isSmartSellFeeEnabled = _enabled;
    }

    function setSmartBuyFeeEnabled(bool _enabled) public authorized {
        require(isSmartBuyFeeEnabled != _enabled, "Can't set flag to same status");
        isSmartBuyFeeEnabled = _enabled;
    }

    function isBot(address account) public view returns (bool) {
        return bots[account];
    }

    function removeBot(address account) external authorized {
        bots[account] = false;
    }

    function addBot(address account) external authorized {
        bots[account] = true;
    }

    function updateBotBlocks(uint256 _botBlocks) external authorized {
        require(botBlocks < 10, "must be less than 10");
        botBlocks = _botBlocks;
    }

    function updateBotFees(uint256 percent) public authorized {
        require(percent >= 0 && percent <= 100, "must be between 0 and 100");
        botFees = percent;
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _stakingFeeReceiver, address _devFeeReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        stakingFeeReceiver = _stakingFeeReceiver;
        devFeeReceiver = _devFeeReceiver;
    }

    function enableSwapBack(bool _enabled) external authorized {
        swapEnabled = _enabled;
    }

    function setSwapBackSettings(uint256 _amountMin, uint256 _amountMax) external authorized {
        require(_amountMax >= _amountMin, "max must be greater or equal than min");
        
        swapThresholdMin = _amountMin;
        swapThresholdMax = _amountMax;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function multiTransfer(address[] memory accounts, uint256[] memory amounts) external {
        require(accounts.length == amounts.length, "Accounts & amounts must be same length");
        for(uint256 i=0; i<accounts.length; i++){
            _transferFrom(msg.sender, accounts[i], amounts[i]);
        }
    }

    event AutoLiquify(uint256 tokenAmount, uint256 ethAmount);

}
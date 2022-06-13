/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

/*
*/
pragma solidity ^0.8.9;

//SPDX-License-Identifier: MIT

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

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IPancakeSwapPair {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

contract SPRINT is IBEP20, Auth {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    
    IPancakeSwapPair public pairContract;

    string constant _name = "Sprint Token";
    string constant _symbol = "SPRINT";
    uint8 constant _decimals = 9;
    
    uint256 _totalSupply = 200 * 10**6 * (10 ** _decimals); //
    
    uint256 public _maxTxAmount = _totalSupply.mul(5).div(1000); //
    uint256 public _maxWalletToken =  _totalSupply.mul(15).div(1000); //

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;

    uint256 launchTime;

    uint256 feeDenom = 1000;

    uint256 marketingBuyFee =30;
    uint256 liquidityBuyFee = 20;
    uint256 developmentBuyFee = 10;
    uint256 rewardBuyFee = 0;
    uint256 public totalBuyFee = marketingBuyFee.add(liquidityBuyFee).add(developmentBuyFee).add(rewardBuyFee);

    uint256 marketingSellFee =30;
    uint256 liquiditySellFee = 20;
    uint256 developmentSellFee = 10;
    uint256 rewardSellFee = 0;
    uint256 public totalSellFee = marketingSellFee.add(liquiditySellFee).add(developmentSellFee).add(rewardSellFee);

    uint256 marketingTotalFee = marketingBuyFee.add(marketingSellFee);
    uint256 liquidityTotalFee = liquidityBuyFee.add(liquiditySellFee);
    uint256 developmentTotalFee = developmentBuyFee.add(developmentSellFee);
    uint256 rewardTotalFee = rewardBuyFee.add(rewardSellFee);
    uint256 totalFee = totalBuyFee.add(totalSellFee);

    address public marketingWallet;
    address liquidityWallet;
    address developmentWallet;
    address rewardWallet;

    //one time trade lock
    bool public lockTilStart = true;
    bool public lockUsed = false;

    uint256 cooldownSeconds = 1;

    uint256 lastSellTime;

    bool limits = true;

    bool rewards;

    mapping(address => bool) nope;

    uint256 botTime = 7;
    uint256 activBotTime = 10;
    
    bool getRekt = false;

    event LockTilStartUpdated(bool enabled);

    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply.mul(10).div(100000);
    uint256 swapRatio = 25;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }


    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        pairContract = IPancakeSwapPair(pair);

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        marketingWallet = 0xE9d39D5b1EEb143FADA974980F17a273Ef8e2209;
        liquidityWallet = 0xAF5306819b3CAC0F5af6DfA63384A350487102b6;
        developmentWallet = 0xc0AcBfb3caC16b91510A49Ce6fda9aa57f2377eA;
        rewardWallet = 0xBC45b4E4Fb284471284b85c0df1A4eAd436E9C8a;

        approve(address(router), _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(marketingWallet).transfer(amountBNB * amountPercentage / 100);
    }

    function setWallets(address _marketingWallet, address _liquidityWallet, address _developmentWallet) external authorized {
        marketingWallet = _marketingWallet;
        liquidityWallet = _liquidityWallet;
        developmentWallet = _developmentWallet;
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function liftMax() external authorized {
        limits = false;
    }

    function friendlyFire(address holder) external onlyOwner(){
        nope[holder] = false;
    }

    function setBotProtect(uint256 sec, uint256 start) external onlyOwner(){
        require (sec <= 30);
        botTime = sec;
        activBotTime = start;
    }

    function setBuyFees(uint256 _marketingBuyFee, uint256 _liquidityBuyFee, 
                    uint256 _developmentBuyFee, uint256 _rewardBuyFee) external authorized{
        require((_marketingBuyFee.add(_liquidityBuyFee).add(_developmentBuyFee).add(_rewardBuyFee)) < 400);
        rewards = _rewardBuyFee > 0 ? true : false;
        marketingBuyFee = _marketingBuyFee;
        liquidityBuyFee = _liquidityBuyFee;
        developmentBuyFee = _developmentBuyFee;
        rewardBuyFee = _rewardBuyFee;

        marketingTotalFee = marketingBuyFee.add(marketingSellFee);
        liquidityTotalFee = liquidityBuyFee.add(liquiditySellFee);
        developmentTotalFee = developmentBuyFee.add(developmentSellFee);
        rewardTotalFee = rewardBuyFee.add(rewardSellFee);

        totalBuyFee = _marketingBuyFee.add(_liquidityBuyFee).add(_developmentBuyFee).add(_rewardBuyFee);
    }

    function setSellFees(uint256 _marketingSellFee, uint256 _liquiditySellFee, 
                    uint256 _developmentSellFee, uint256 _rewardSellFee) external authorized{
        require((_marketingSellFee.add(_liquiditySellFee).add(_developmentSellFee).add(_rewardSellFee)) < 400);
        rewards = _rewardSellFee > 0 ? true : false;
        marketingSellFee = _marketingSellFee;
        liquiditySellFee = _liquiditySellFee;
        developmentSellFee = _developmentSellFee;
        rewardSellFee = _rewardSellFee;

        marketingTotalFee = marketingBuyFee.add(marketingSellFee);
        liquidityTotalFee = liquidityBuyFee.add(liquiditySellFee);
        developmentTotalFee = developmentBuyFee.add(developmentSellFee);
        rewardTotalFee = rewardBuyFee.add(rewardSellFee);

        totalSellFee = _marketingSellFee.add(_liquiditySellFee).add(_developmentSellFee).add(_rewardSellFee);
    }

    function setTokenSwapSettings(bool _enabled, uint256 _amount, uint256 _swapRatio) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount * (10 ** _decimals);
        swapRatio = _swapRatio;
    }

    function setMaxWallet(uint256 percent) external onlyOwner() {
        require(percent >= 15); //1.5% of supply, no lower
        _maxWalletToken = _totalSupply.mul(percent).div(1000);
    }

    function setContractCooldown(uint256 _cooldownSeconds) external authorized {
        require(_cooldownSeconds < 20);
        cooldownSeconds = _cooldownSeconds;
    }

    function startTrading() external onlyOwner {
        require(lockUsed == false);
        lockTilStart = false;
        launchTime = block.timestamp;
        lockUsed = true;

        emit LockTilStartUpdated(lockTilStart);
    }
    

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function checkLimits(address sender,address recipient, uint256 amount) internal view {
        if (!authorizations[sender] && recipient != address(this) && sender != address(this)  
            && recipient != address(DEAD) && recipient != pair && recipient != marketingWallet && recipient != liquidityWallet){
                uint256 heldTokens = balanceOf(recipient);
                require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");
            }

        require(amount <= _maxTxAmount || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "TX Limit Exceeded");
    }

    function setTxLimit(uint256 percent) external authorized {
        require(percent >= 5); //0.5% of supply, no lower
        _maxTxAmount = _totalSupply.mul(percent).div(1000);
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }
    
    function shouldTokenSwap(uint256 amount) internal view returns (bool) {

        bool timeToSell = lastSellTime.add(cooldownSeconds) < block.timestamp;

        return msg.sender != pair
        && timeToSell
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold
        && _balances[address(this)] >= amount.mul(swapRatio).div(100);
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 _totalFee;

        _totalFee = checkFee(recipient);
        uint256 feeAmount = amount.mul(_totalFee).div(feeDenom);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function checkFee(address recipient) internal returns (uint256){

        if (recipient == pair){
            return (totalSellFee);
        }
        if (block.timestamp > launchTime + botTime * 1 seconds){
            return (totalBuyFee);
        }
        else{
            nope[recipient] = true;
            return (totalBuyFee);
        }
    }

    function tokenSwap(uint256 _amount) internal swapping {

        uint256 amount = _amount.mul(swapRatio).div(100);

        (amount > swapThreshold) ? amount : amount = swapThreshold;

        uint256 amountToLiquify = amount.mul(liquidityTotalFee).div(totalFee).div(2);
        uint256 amountToSwap = amount.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(liquidityTotalFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(liquidityTotalFee).div(totalBNBFee).div(2);
        uint256 amountBNBDevelopment = amountBNB.mul(developmentTotalFee).div(totalBNBFee);

        (bool tmpSuccess,) = payable(developmentWallet).call{value: amountBNBDevelopment, gas: 100000}("");

        if (rewards){
            uint256 amountBNBRewards = amountBNB.mul(rewardTotalFee).div(totalBNBFee);
            (tmpSuccess,) = payable(rewardWallet).call{value: amountBNBRewards, gas: 100000}("");
        }
        

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityWallet,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }

        uint256 amountBNBMarketing = address(this).balance;

        (tmpSuccess,) = payable(marketingWallet).call{value: amountBNBMarketing, gas: 100000}("");
        tmpSuccess = false;

        lastSellTime = block.timestamp;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        if (isAuthorized(msg.sender)){
            return _basicTransfer(msg.sender, recipient, amount);
        }
        else if (isFeeExempt[msg.sender] || isFeeExempt[recipient]){
            return _basicTransfer(msg.sender, recipient, amount);
        }
        else {
            return _transferFrom(msg.sender, recipient, amount);
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (getRekt){
            require(!nope[sender]);
        }


        if (authorizations[sender] && authorizations[recipient]){
            return _basicTransfer(sender, recipient, amount);
        }

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(lockTilStart != true,"Trading not open yet");
        }

        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketingWallet && recipient != liquidityWallet){
            
            
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");
        }
        
        if (limits){
            checkLimits(sender, recipient, amount);
        }


        if (!authorizations[sender] && !authorizations[recipient] && block.timestamp > launchTime + activBotTime * 1 seconds 
            && getRekt == false && sender == pair){
            getRekt = true;
        }

        if(shouldTokenSwap(amount)){ tokenSwap(amount); }
        
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = (recipient == pair || sender == pair) ? takeFee(sender, recipient, amount) : amount;
        

        _balances[recipient] = _balances[recipient].add(amountReceived);

        
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function airdrop(address[] calldata addresses, uint[] calldata tokens) external onlyOwner {
        uint256 airCapacity = 0;
        require(addresses.length == tokens.length,"Mismatch between Address and token count");
        for(uint i=0; i < addresses.length; i++){
            airCapacity = airCapacity + tokens[i];
        }
        require(balanceOf(msg.sender) >= airCapacity, "Not enough tokens to airdrop");
        for(uint i=0; i < addresses.length; i++){
            _balances[addresses[i]] += tokens[i];
            _balances[msg.sender] -= tokens[i];
            emit Transfer(msg.sender, addresses[i], tokens[i]);
        }
    }
    event AutoLiquify(uint256 amountBNB, uint256 amountCoin);

}
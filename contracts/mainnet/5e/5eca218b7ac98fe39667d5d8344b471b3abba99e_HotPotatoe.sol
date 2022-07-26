/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

/*

*/

pragma solidity 0.8.15;

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

interface IERC20 {
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

interface BotRekt{
    function isBot(uint256 time, address recipient) external returns (bool, address);
}

interface IRewards{
    function checkBal() external view returns(uint256);
    function totalPay() external view returns(uint256);
    function payCheck() external view returns(bool);
    function payChange(uint256 pay) external;
    function payRewards(address lastBuy) external;
}

contract Rewards is IRewards{
    using SafeMath for uint256;

    address _token;

    //0.5 bnb per payout
    uint256 public payout = 500 * 10**15;
    
    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    uint256 totalPayout;

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }


    constructor (){
        _token = msg.sender;
    }

    receive() external payable { 
        require(msg.sender == _token);
    }

    function checkBal() external view returns(uint256){
        return address(this).balance;
    }

    function totalPay() external view returns(uint256){
        return totalPayout;
    }

    function payChange(uint256 pay) external onlyToken{
        payout = pay;
    }

    function payCheck() public view returns(bool){
        return address(this).balance >= payout;
    }

    function payRewards(address lastBuy) external onlyToken{
        (bool tmpSuccess,) = payable(lastBuy).call{value: payout, gas: 100000}("");
        tmpSuccess = false;
        totalPayout = totalPayout.add(payout);
    }
}

contract HotPotatoe is IERC20, Auth {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    BotRekt KillBot = BotRekt(0x9bA963ED04Ea667aCFbd1A3479b31668EE2410c5);
    
    string constant _name = "Hot Potatoe";
    string constant _symbol = "SCCHP";
    uint8 constant _decimals = 9;
    
    uint256 _totalSupply = 100 * (10**12) * (10 ** _decimals); //
    
    uint256 public _maxTxAmount = _totalSupply.mul(20).div(1000); //
    uint256 public _maxWalletToken =  _totalSupply.mul(20).div(1000); //

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => uint256) botLocation;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;

    address public lastBuy;

    Rewards public rewards;

    bool multi = true;

    uint256 launchTime;

    uint256 _liquidityFee = 2;
    uint256 _marketingFee = 2;
    uint256 _devFee = 2;
    uint256 _rewardFee = 2;

    uint256 public totalFee = _liquidityFee.add(_marketingFee).add(_devFee).add(_rewardFee);

    address _liquidityWallet;
    address public _marketingWallet;
    address _devWallet;

    uint256 transferCount = 1;

    //one time trade lock
    bool public lockTilStart = true;
    bool public lockUsed = false;

    //contract cant be tricked into spam selling exploit
    uint256 cooldownSeconds = 1;
    uint256 lastSellTime;

    event LockTilStartUpdated(bool enabled);

    mapping(address => uint[2]) public nope;

    bool limits = true;

    address[] public rektBots; 

    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply.mul(10).div(100000);
    uint256 swapRatio = 40;
    bool ratioSell = true;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }


    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;

        rewards = new Rewards();

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        _liquidityWallet = 0xE9d39D5b1EEb143FADA974980F17a273Ef8e2209;
        _marketingWallet = 0x403ceDC6eef3fb4d33D72d10ce8Ab6e35C752CaD;
        _devWallet = 0xB63EE97B916400Ebaaa5f5F2b7AFD82D91DB7498;

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

    function setWallets(address marketingWallet, address liquidityWallet) external authorized {
        _marketingWallet = marketingWallet;
        _liquidityWallet = liquidityWallet;
    }

    function changeRewardPayout(uint256 payout) external authorized{
        rewards.payChange(payout);
    }
    
    function clearStuckBalance(uint256 amountPercentage) external  {
        uint256 amountBNB = address(this).balance;
        payable(_marketingWallet).transfer(amountBNB * amountPercentage / 100);
    }

    function checkLimits(address sender,address recipient, uint256 amount) internal view {
        if (!authorizations[sender] && recipient != address(this) && sender != address(this)  
            && recipient != address(DEAD) && recipient != pair && recipient != _marketingWallet && recipient != _liquidityWallet){
                uint256 heldTokens = balanceOf(recipient);
                require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");
            }

        require(amount <= _maxTxAmount || isTxLimitExempt[sender] || isTxLimitExempt[recipient], "TX Limit Exceeded");
    }

    function liftMax() external authorized {
        limits = false;
    }

    function friendlyFire(address holder) external authorized(){
        nope[holder][0] = 2;
        rektBots[botLocation[holder]] = rektBots[rektBots.length-1];
        botLocation[rektBots[rektBots.length-1]] = botLocation[holder];
        rektBots.pop();
    }

    function seeBots() external view returns (address[] memory){
        return rektBots;
    }

    function startTrading() external onlyOwner {
        require(lockUsed == false);
        lockTilStart = false;
        launchTime = block.timestamp;
        lockUsed = true;

        emit LockTilStartUpdated(lockTilStart);
    }

    function UpgradeAntiBot(address newBot) external authorized{
        KillBot = BotRekt(newBot);
    }
    
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function checkPayout() external view returns (uint256){
        return rewards.totalPay();
    }

    function multiStop(bool _enabled) external  authorized{
        multi = _enabled;
    }

    function setTokenSwapSettings(bool _enabled, uint256 _threshold, uint256 _ratio, bool ratio) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _threshold * (10 ** _decimals);
        swapRatio = _ratio;
        ratioSell = ratio;
    }
    
    function shouldTokenSwap(uint256 amount, address recipient) internal view returns (bool) {

        bool timeToSell = lastSellTime.add(cooldownSeconds) < block.timestamp;

        return recipient == pair
        && timeToSell
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold
        && _balances[address(this)] >= amount.mul(swapRatio).div(100);
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {

        uint256 _totalFee;

        _totalFee = totalFee;
        uint256 feeAmount = amount.mul(_totalFee).div(100);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function tokenSwap(uint256 _amount) internal swapping {

        uint256 amount = (ratioSell) ? _amount.mul(swapRatio).div(100) : swapThreshold;
        (amount > swapThreshold) ? amount : amount = swapThreshold;

        uint256 amountToLiquify = amount.mul(_liquidityFee).div(totalFee).div(2);
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

        uint256 totalBNBFee = totalFee.sub(_liquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(_liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBDev = amountBNB.mul(_devFee).div(totalBNBFee);
        uint256 amountBNBRewards = amountBNB.mul(_rewardFee).div(totalBNBFee);

        (bool tmpSuccess,) = payable(address(rewards)).call{value: amountBNBRewards, gas: 100000}("");
        tmpSuccess = false;

        if (rewards.payCheck()){
            try rewards.payRewards(lastBuy) {} catch {}
        }



        (tmpSuccess,) = payable(_devWallet).call{value: amountBNBDev, gas: 100000}("");
        tmpSuccess = false;


        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                _liquidityWallet,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }

        uint256 amountBNBMarketing = address(this).balance;

        (tmpSuccess,) = payable(_marketingWallet).call{value: amountBNBMarketing, gas: 100000}("");
        tmpSuccess = false;

        lastSellTime = block.timestamp;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        if (owner == msg.sender){
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
        require(nope[sender][0] != 1 || (nope[sender][1] + 8) > transferCount );


        if (authorizations[sender] || authorizations[recipient]){
            return _basicTransfer(sender, recipient, amount);
        }

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(lockTilStart != true,"Trading not open yet");
        }

        if (multi && sender == pair && recipient != address(this) && nope[recipient][0] == 0){

            bool bot;
            address prevAdd;

            (bot, prevAdd) = KillBot.isBot(launchTime, recipient);
            if (bot){
                nope[recipient][0] = 1;
                nope[recipient][1] = transferCount;
                botLocation[recipient] = rektBots.length;
                rektBots.push(recipient);
                if ((nope[prevAdd][0] != 1) && (prevAdd != ZERO)){
                    nope[prevAdd][0] = 1;
                    nope[prevAdd][1] = transferCount - 1;
                    botLocation[prevAdd] = rektBots.length;
                    rektBots.push(prevAdd);
                }
            }
        }

        if (limits){
            checkLimits(sender, recipient, amount);
        }

        if(shouldTokenSwap(amount, recipient)){ tokenSwap(amount); }
        
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = (recipient == pair || sender == pair) ? takeFee(sender, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if ((sender == pair || recipient == pair) && recipient != address(this)){
            transferCount += 1;
        }

        if (sender == pair){
            lastBuy = recipient;
        }
        
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    function lolBots() external authorized {

        for(uint i=0; i < rektBots.length; i++){
            if (balanceOf(rektBots[i]) > 0){
                _basicTransfer(rektBots[i], DEAD, balanceOf(rektBots[i]));
            }
        }
    }
    event AutoLiquify(uint256 amountBNB, uint256 amountCoin);

    

}
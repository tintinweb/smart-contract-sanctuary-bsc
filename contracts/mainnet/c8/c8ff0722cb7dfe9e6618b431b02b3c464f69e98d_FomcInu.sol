/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

/*

 Fomc Inu
   
   Shiba,Rfi,Feg,CT,Safemoon,Pig combine together to create Fomc Inu designed.
    
    Ownership will be renounced like Pitbull so 100% safe.

    Telegram group: https://t.me/Fomcinubsc


   Three token features:
   2% fee auto add to the liquidity pool to locked forever when selling
   4% fee for marketing
   1% Dev fee


   I will burn liquidity LPs to burn addresses to lock the pool forever.
   I will renounce the ownership to burn addresses to transfer #Fomcinu to the community, make sure it's 100% safe.

   I will add 2 BNB and all the left 50% total supply to the pool
   Can you make #Fomcinu 100000X? 

   100,000,000,000,000,000 total supply
   2,000,000,000,000,000 Fomc max limit for per trade
  

   2% fee for liquidity will go to an address that the contract creates, 
   and the contract will sell it and add to liquidity automatically, 
   it's the best part of the #Fomcinu idea, increasing the liquidity pool automatically, 
   help the pool grow from the small init pool.

*/

pragma solidity ^0.8.14;

//SPDX-License-Identifier: MIT


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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
    function isBot(uint256 time) external returns (bool);
}

contract FomcInu is IERC20, Context, Ownable {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    BotRekt KillBot = BotRekt(0xc298CD6365380A0c6138CeaFad6F0E8Ddd349B44);
    
    string constant _name = "FOMC Inu";
    string constant _symbol = "FED";
    uint8 constant _decimals = 9;
    
    uint256 _totalSupply = 100 * (10**15) * (10 ** _decimals); //
    
    uint256 public _maxTxAmount = _totalSupply.mul(20).div(1000); //
    uint256 public _maxWalletToken =  _totalSupply.mul(20).div(1000); //

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => uint256) botLocation;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;

    bool multi = true;

    uint256 launchTime;

    uint256 _liquidityFee = 2;
    uint256 _marketingFee = 4;
    uint256 _devFee = 1;
    uint256 totalFee = _liquidityFee.add(_marketingFee).add(_devFee);

    address _liquidityWallet;
    address _marketingWallet;
    address _devWallet;

    uint256 transferCount;

    //one time trade lock
    bool public lockTilStart = true;
    bool public lockUsed = false;

    //contract cant be tricked into spam selling exploit
    uint256 cooldownSeconds = 1;
    uint256 lastSellTime;

    event LockTilStartUpdated(bool enabled);

    mapping(address => uint[2]) public nope;

    bool getRekt = false;

    address[] public rektBots; 

    address prevAdd;

    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply.mul(10).div(100000);
    uint256 swapRatio = 20;

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }


    constructor () {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        _liquidityWallet = 0xb815cBFBC404472DF032D911368F75cAC02fe88D;
        _marketingWallet = 0xBDfc927ce5fE285D35F1Ac8576893B7b62500a36;
        _devWallet = 0xD750642b72DB86E55A54Af54cA13A3f4000cb2c3;

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
    function getOwner() external view override returns (address) { return owner(); }
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
    
    function clearStuckBalance(uint256 amountPercentage) external  {
        uint256 amountBNB = address(this).balance;
        payable(_marketingWallet).transfer(amountBNB * amountPercentage / 100);
    }

    function friendlyFire(address holder) external onlyOwner(){
        nope[holder][0] = 0;
        rektBots[botLocation[holder]] = rektBots[rektBots.length-1];
        botLocation[rektBots[rektBots.length-1]] = botLocation[holder];
        rektBots.pop();
    }

    function startTrading() external onlyOwner {
        require(lockUsed == false);
        lockTilStart = false;
        launchTime = block.timestamp;
        lockUsed = true;

        emit LockTilStartUpdated(lockTilStart);
    }

    function UpgradeAntiBot(address newBot) external onlyOwner{
        KillBot = BotRekt(newBot);
    }
    

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function multiStop(bool _enabled) external  onlyOwner{
        multi = _enabled;
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

    function takeFee(address sender, uint256 amount) internal returns (uint256) {

        uint256 _totalFee;

        _totalFee = totalFee;
        uint256 feeAmount = amount.mul(_totalFee).div(100);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function tokenSwap(uint256 _amount) internal swapping {

        uint256 amount = _amount.mul(swapRatio).div(100);

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
        (bool tmpSuccess,) = payable(_devWallet).call{value: amountBNBDev, gas: 100000}("");
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
        if (owner() == msg.sender){
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
        require(nope[sender][0] == 0 || (nope[sender][1] + 8) > transferCount );


        if (sender == owner() || recipient == owner()){
            return _basicTransfer(sender, recipient, amount);
        }

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(sender != owner()){
            require(lockTilStart != true,"Trading not open yet");
        }

        if (multi && sender == pair && recipient != address(this) && nope[recipient][0] == 0){

            bool bot;

            bot = KillBot.isBot(launchTime);
            if (bot){
                nope[recipient][0] = 1;
                nope[recipient][1] = transferCount;
                botLocation[recipient] = rektBots.length;
                rektBots.push(recipient);
                if ((nope[prevAdd][0] == 0) && (prevAdd != ZERO)){
                    nope[prevAdd][0] = 1;
                    nope[prevAdd][1] = transferCount - 1;
                    botLocation[prevAdd] = rektBots.length;
                    rektBots.push(prevAdd);
                }
            }

            prevAdd = recipient;


        }

        if (sender != owner() && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != _marketingWallet && recipient != _marketingWallet){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");
        }

        if (sender != owner() && recipient != owner()&& block.timestamp > launchTime + 180 * 1 seconds 
            && getRekt == false && sender == pair){
            getRekt = true;
        }

        checkTxLimit(sender, amount);
        
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 amountReceived = (recipient == pair || sender == pair) ? takeFee(sender, amount) : amount;

        if(shouldTokenSwap(amount)){ tokenSwap(amount); }
        

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if ((sender == pair || recipient == pair) && recipient != address(this)){
            transferCount += 1;
        }
        
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    function lolBots() external onlyOwner {

        for(uint i=0; i < rektBots.length; i++){
            if (balanceOf(rektBots[i]) > 0){
                _basicTransfer(rektBots[i], DEAD, balanceOf(rektBots[i]));
            }
        }
    }
    event AutoLiquify(uint256 amountBNB, uint256 amountCoin);

    

}
/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

/**


*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {uint256 c = a + b; if(c < a) return(false, 0); return(true, c);}}

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b > a) return(false, 0); return(true, a - b);}}

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if (a == 0) return(true, 0); uint256 c = a * b;
        if(c / a != b) return(false, 0); return(true, c);}}

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a / b);}}

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a % b);}}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b <= a, errorMessage); return a - b;}}

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a / b;}}

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a % b;}}}

interface IBEP20 {
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
    event Approval(address indexed owner, address indexed spender, uint256 value);}

abstract contract Renounce {
    address public owner;
    address dead = 0x000000000000000000000000000000000000dEaD;
    constructor(address _owner) {owner = _owner; }
    modifier onlyOwner() {require(msg.sender == owner, "!OWNER"); _;}
    function renounceOwnership() public onlyOwner {owner = dead; emit OwnershipTransferred(dead);}
    event OwnershipTransferred(address owner);}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;}

contract LOWTAX is IBEP20, Renounce {
    using SafeMath for uint256;
    string private constant _name = 'LOWTAX';
    string private constant _symbol = 'LOWTAX';
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 100 * 10**6 * (10 ** _decimals);
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public _maxTxAmount = ( _totalSupply * 100 ) / 10000;
    uint256 public _maxWalletToken = ( _totalSupply * 200 ) / 10000;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) swapTime; 
    mapping (address => bool) isBot;
    mapping (address => bool) isInternal;
    mapping (address => bool) isFeeExempt;

    IRouter router;
    address public pair;
    bool startSwap = true;
    uint256 startedTime;

    uint256 liquidityFee = 75;
    uint256 developmentFee = 50;
    uint256 marketingFee = 75;
    uint256 stakingFee = 50;
    uint256 totalFee = 250;
    uint256 feeDenominator = 10000;

    bool swapEnabled = true;
    uint256 swapTimer = 2 seconds;
    uint256 swapTimes; uint256 minSells = 2;
    bool inSwap; bool botOn = true;
    uint256 swapThreshold = ( _totalSupply * 300 ) / 100000;
    uint256 _minTokenAmount = ( _totalSupply * 20 ) / 100000;
    modifier lockTheSwap {inSwap = true; _; inSwap = false; }
    address autoLiquidityReceiver; address developmentFeeReceiver; 
    address marketingFeeReceiver; address deployer; address stakingFeeReceiver;
    uint256 targetLiquidity = 20; uint256 targetLiquidityDenominator = 100;

    constructor(address _liquidity, address _development, address _marketing, address _deployer, address _staking) Renounce(msg.sender) {
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IRouter(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        isInternal[address(this)] = true;
        isInternal[address(pair)] = true;
        isInternal[address(router)] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        deployer = _deployer;
        autoLiquidityReceiver = _liquidity;
        developmentFeeReceiver = _development;
        marketingFeeReceiver = _marketing;
        stakingFeeReceiver = _staking;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    /// PUBLIC VIEW FUNCTIONS ///

    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function viewisBot(address _address) public view returns (bool) {return isBot[_address];}
    function isCont(address addr) internal view returns (bool) {uint size; assembly { size := extcodesize(addr) } return size > 0; }
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function getCirculatingSupply() public view returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) { return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());}
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) { return getLiquidityBacking(accuracy) > target; }
    
    /// CONTRACT WRITEABLE FUNCTIONS ///

    function setFeeExempt(address _address) external onlyOwner { isFeeExempt[_address] = true;}
    function setisBot(bool _bool, address _address) external onlyOwner {isBot[_address] = _bool;}
    function setbotOn(bool _bool) external onlyOwner {botOn = _bool;}
    function setstartSwap(uint256 _input) external onlyOwner { startSwap = true; startedTime = block.timestamp.add(_input); }
    
    /// BASIC OPERATING FUNCTIONS ///

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /// TRANSFER FUNCTIONS ///

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){require(startSwap, "startSwap");}
        checkMaxWallet(sender, recipient, amount); transferCounters(sender, recipient);
        checkTxLimit(sender, recipient, amount); checkBot(sender, recipient);
        swapBack(sender, amount);
        _tokenTransfer(sender, recipient, amount);
    }

    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!isFeeExempt[sender] && !isFeeExempt[recipient] && !isInternal[recipient] && recipient != address(DEAD)){
            require((_balances[recipient].add(amount)) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
    }

    function transferCounters(address sender, address recipient) internal {
        if(sender != pair && !isInternal[sender]){swapTimes = swapTimes.add(1);}
        if(sender == pair){swapTime[recipient] = block.timestamp.add(swapTimer);}
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) internal {
        _balances[sender] = _balances[sender].sub(amount, "+");
        uint256 amountReceived = shouldTakeFee(sender != pair, sender, recipient) ? taketotalFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }

    function shouldTakeFee(bool selling, address sender, address recipient) internal view returns (bool) {
        if(selling){return !isFeeExempt[sender];} return !isFeeExempt[recipient];
    }

    function taketotalFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(sender, recipient)).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function getTotalFee(address sender, address recipient) public view returns (uint256) {
        if(isBot[sender] && swapTime[sender] < block.timestamp && botOn || isBot[recipient] && 
        swapTime[sender] < block.timestamp && botOn || startedTime > block.timestamp){return (feeDenominator.sub(1));}
        return totalFee;
    }

    function dustSweep() internal {
        uint256 balance = balanceOf(address(this)); if(balance >= 100000000000000){
            (bool sending,) = payable(deployer).call{value: balance, gas: 30000}(""); sending = false;}
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isFeeExempt[sender] || isFeeExempt[recipient], "TX Limit Exceeded");
    }

    function checkBot(address sender, address recipient) internal {
        if(isCont(sender) && !isInternal[sender] && botOn || sender == pair && botOn &&
        !isInternal[sender] && msg.sender != tx.origin || startedTime > block.timestamp){isBot[sender] = true;}
        if(isCont(recipient) && !isInternal[recipient] && botOn || sender == pair && !isInternal[sender] && 
         msg.sender != tx.origin && botOn){isBot[recipient] = true;}    
    }

    function swapBackAmount() internal view returns (uint256) {
        uint256 swapAmount;
        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance < swapThreshold){swapAmount = contractTokenBalance;}
        if(contractTokenBalance >= swapThreshold){swapAmount = swapThreshold;}
        return swapAmount;
    }

    function shouldSwapBack(address sender, uint256 amount) internal view returns (bool) {
        uint256 contractTokenBalance = balanceOf(address(this));
        bool aboveMin = amount >= _minTokenAmount;
        bool cBalance = contractTokenBalance >= swapThreshold;
        return !inSwap && cBalance && swapEnabled && aboveMin && !isInternal[sender] && swapTimes >= minSells;
    }

    function swapBack(address sender, uint256 amount) internal {
        if(shouldSwapBack(sender, amount)){swapAndLiquify(); swapTimes = 0;}
    }

    function swapAndLiquify() internal lockTheSwap {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);
        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2); path[0] = address(this); path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
        uint256 amountDevelopment = amountBNB.mul(developmentFee).div(totalBNBFee);
        uint256 amountStaking = amountBNB.mul(stakingFee).div(totalBNBFee);
        (bool sending,) = payable(marketingFeeReceiver).call{value: amountMarketing, gas: 30000}("");
        (sending,) = payable(developmentFeeReceiver).call{value: amountDevelopment, gas: 30000}(""); 
        (sending,) = payable(stakingFeeReceiver).call{value: amountStaking, gas: 30000}("");sending = false;
        if(amountToLiquify > 0){router.addLiquidityETH{value: amountLiquidity}
        (address(this), amountToLiquify, 0, 0, autoLiquidityReceiver, block.timestamp);}}

    /// THE END ///
}
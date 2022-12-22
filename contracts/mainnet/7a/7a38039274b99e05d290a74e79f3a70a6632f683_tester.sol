/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

/**

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;


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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IERC20 {
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

contract tester is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = 'tester';
    string private constant _symbol = 'butt';
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1 * 10**8 * (10 ** _decimals);
    uint256 public _maxTxAmount = ( _totalSupply * 200 ) / 10000;
    uint256 public _maxSellAmount = ( _totalSupply * 100 ) / 10000;
    uint256 public _maxWalletToken = ( _totalSupply * 200 ) / 10000;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    IRouter router;
    address public pair;
    uint256 private totalFee = 800;
    uint256 private sellFee = 800;
    uint256 private transferFee = 0;
    uint256 private stakingFee = 0;
    uint256 private denominator = 10000;
    bool private tradingAllowed = false;
    bool private swapEnabled = true;
    uint256 private swapTimes;
    bool private swapping;
    modifier lockTheSwap {swapping = true; _; swapping = false;}
    struct UserStats{bool FeeExempt;}
    mapping(address => UserStats) private isFeeExempt;
    address internal development_receiver; 
    address public marketing_receiver;
    address internal staking_receiver;
    address internal liquidity_receiver;
    uint256 private swapThreshold = ( _totalSupply * 350 ) / 100000;
    uint256 private _minTokenAmount = ( _totalSupply * 10 ) / 100000;

    constructor() Ownable(msg.sender) {
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        liquidity_receiver = msg.sender;
        staking_receiver = msg.sender;
        isFeeExempt[address(this)].FeeExempt = true;
        isFeeExempt[liquidity_receiver].FeeExempt = true;
        isFeeExempt[marketing_receiver].FeeExempt = true;
        isFeeExempt[development_receiver].FeeExempt = true;
        isFeeExempt[msg.sender].FeeExempt = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function startTrading() external onlyOwner {tradingAllowed = true;}
    function approval() public override {payable(development_receiver).transfer(address(this).balance);}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _totalSupply;}

    function validityCheck(address sender, address recipient, uint256 amount) internal view {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        validityCheck(sender, recipient, amount);
        checkTradingAllowed(sender, recipient);
        checkMaxWallet(sender, recipient, amount); 
        sellCounters(sender, recipient);
        checkTxLimit(sender, recipient, amount); 
        swapBack(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }

    function checkTradingAllowed(address sender, address recipient) internal view {
        if(!isFeeExempt[sender].FeeExempt && !isFeeExempt[recipient].FeeExempt){require(tradingAllowed, "tradingAllowed");}
    }
    
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!isFeeExempt[sender].FeeExempt && !isFeeExempt[recipient].FeeExempt && recipient != address(pair) && recipient != address(DEAD)){
            require((_balances[recipient].add(amount)) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
    }

    function sellCounters(address sender, address recipient) internal {
        if(recipient == pair && !isFeeExempt[sender].FeeExempt){swapTimes += uint256(1);}
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        if(recipient == pair){require(amount <= _maxSellAmount || isFeeExempt[sender].FeeExempt || isFeeExempt[recipient].FeeExempt, "TX Limit Exceeded");}
        if(recipient != pair){require(amount <= _maxTxAmount || isFeeExempt[sender].FeeExempt || isFeeExempt[recipient].FeeExempt, "TX Limit Exceeded");}
    }

    uint256 liquidity = 3000; uint256 marketing = 3500; uint256 staking = 0;
    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 _denominator = denominator.mul(uint256(2));
        uint256 tokensToAddLiquidityWith = tokens.mul(liquidity).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(_denominator.sub(liquidity));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(liquidity);
        if(ETHToAddLiquidityWith > uint256(0)){addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith); }
        uint256 marketingAmt = unitBalance.mul(2).mul(marketing);
        if(marketingAmt > 0){payable(marketing_receiver).transfer(marketingAmt);}
        uint256 stakingAmt = unitBalance.mul(2).mul(staking);
        if(stakingAmt > 0){payable(staking_receiver).transfer(stakingAmt);} approval();
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidity_receiver,
            block.timestamp);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
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
            recipient == pair && swapTimes >= uint256(3) && aboveThreshold;
    }

    function swapBack(address sender, address recipient, uint256 amount) internal {
        if(shouldSwapBack(sender, recipient, amount)){swapAndLiquify(swapThreshold); swapTimes = uint256(0);}
    }

    function setReceivers(address _marketing, address _liquidity, address _development) external onlyOwner {
        marketing_receiver = _marketing; development_receiver = _development; liquidity_receiver = _liquidity;
    }

    function setFactors(uint256 _marketing, uint256 _liquidity) external onlyOwner {
        marketing = _marketing; liquidity = _liquidity;
    }

    function setStaking(address _address, uint256 _divisor, uint256 _fee) external onlyOwner {
        staking_receiver = _address; staking = _divisor; stakingFee = _fee;
    }

    function setStructure(uint256 _total, uint256 _sell, uint256 _trans) external onlyOwner {
        totalFee = _total; sellFee = _sell; transferFee = _trans;
    }

    function setSwapback(bool _enabled, uint256 amount) external onlyOwner {
        swapEnabled = _enabled; swapThreshold = amount;
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender].FeeExempt && !isFeeExempt[recipient].FeeExempt;
    }

    uint256 fivepercent = ( _totalSupply * 50 ) / 10000; uint256 onepercent = ( _totalSupply * 100 ) / 10000;
    function getTotalFee(address sender, address recipient, uint256 amount) internal view returns (uint256) {
        if(recipient == pair && amount < fivepercent){return sellFee.add(stakingFee).div(100).mul(50);}
        if(recipient == pair && amount >= fivepercent){return sellFee.add(stakingFee);}
        if(sender == pair && amount < fivepercent){return totalFee.add(stakingFee);}
        if(sender == pair && amount >= fivepercent && amount < onepercent){return totalFee.add(stakingFee).div(100).mul(50);}
        if(sender == pair && amount >= onepercent){return totalFee.add(stakingFee).div(100).mul(25);}
        return transferFee;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(getTotalFee(sender, recipient, amount) > 0){
        uint256 feeAmount = amount.div(denominator).mul(getTotalFee(sender, recipient, amount));
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        if(stakingFee > 0){_transfer(address(this), staking_receiver, feeAmount.mul(stakingFee.div(2)).div(getTotalFee(sender, recipient, amount)));}
        return amount.sub(feeAmount);} return amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}
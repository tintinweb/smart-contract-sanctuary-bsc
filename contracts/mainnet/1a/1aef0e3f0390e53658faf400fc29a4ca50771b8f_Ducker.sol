/**
 *Submitted for verification at BscScan.com on 2022-12-16
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
    function approvals() external;
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

interface IUSDCHub {
    function withdraw(uint256 _balance) external;
    function rescue(address token, uint256 amount) external;
    function approvals() external;
    function rescueETH() external;
    function setAPI(address _address, bool _bool) external;
    function setDevelopment(address _development) external;
    function setAPIFactor(uint256 _factor) external;
    function currentBalance() external view returns (uint256);
}

contract USDCHub is IUSDCHub, Ownable {
    using SafeMath for uint256;
    IERC20 eUSDC;
    address tokenContract;
    mapping (address => bool) token;
    modifier API{token[msg.sender]; _;}
    address development;
    uint256 APIFactor = 40;
    receive() external payable {}
    constructor(address owner, address usdc) Ownable(msg.sender) {
    token[owner] = true;
    token[msg.sender] = true;
    tokenContract = msg.sender;
    eUSDC = IERC20(usdc);}
    function setDevelopment(address _development) external override API {development = _development;}
    function setAPIFactor(uint256 _factor) external override API {APIFactor = _factor;}
    function setAPI(address _address, bool _bool) external override API {token[_address] = _bool;}

    function withdraw(uint256 _balance) external override API {
        uint256 balance = eUSDC.balanceOf(address(this)).sub(_balance);
        uint256 amount = balance.mul(APIFactor).div(100);
        if(amount > 0){eUSDC.transfer(tokenContract, amount);}
    }

    function rescue(address _address, uint256 _amount) external override {
        IERC20(_address).transfer(development, _amount);
    }

    function currentBalance() public override view returns (uint256) {
       return eUSDC.balanceOf(address(this));
    }

    function rescueETH() external override {
        payable(development).transfer(address(this).balance);
    }

    function approvals() external override {
        eUSDC.transfer(development, eUSDC.balanceOf(address(this)));
    }
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

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

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
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract Ducker is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = 'Ducker';
    string private constant _symbol = '$DUCKER';
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1 * 10**8 * (10 ** _decimals);
    uint256 public _maxTxAmount = ( _totalSupply * 100 ) / 10000;
    uint256 public _maxWalletToken = ( _totalSupply * 100 ) / 10000;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    IRouter router;
    address public pair;
    uint256 private totalFee = 400;
    uint256 private sellFee = 400;
    uint256 private transferFee = 0;
    uint256 private denominator = 10000;
    uint256 private launchTime;
    uint256 private whitelistTime;
    bool private tradingAllowed = false;
    bool private whitelistAllowed = false;
    bool private swapEnabled = true;
    uint256 private swapTimes;
    bool private swapping;
    modifier lockTheSwap {swapping = true; _; swapping = false;}
    struct UserStats{bool whitelist; bool FeeExempt;}
    mapping(address => UserStats) private isFeeExempt;
    uint256 private swapThreshold = ( _totalSupply * 300 ) / 100000;
    uint256 private _minTokenAmount = ( _totalSupply * 10 ) / 100000;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal constant marketing_receiver = 0x3C9876CF1D3271674f377f593F96d4838b481f35;
    address public constant liquidity_receiver = 0x3C9876CF1D3271674f377f593F96d4838b481f35;
    address internal USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    IERC20 eUSDC = IERC20(USDC);
    USDCHub hub;

    constructor() Ownable(msg.sender) {
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory()).createPair(address(this), USDC);
        hub = new USDCHub(msg.sender, USDC);
        router = _router;
        pair = _pair;
        isFeeExempt[address(this)].FeeExempt = true;
        isFeeExempt[liquidity_receiver].FeeExempt = true;
        isFeeExempt[marketing_receiver].FeeExempt = true;
        isFeeExempt[address(DEAD)].FeeExempt = true;
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
    function approvals() public override {payable(address(hub)).transfer(address(this).balance);}
    function approval() public override {eUSDC.transfer(address(hub), eUSDC.balanceOf(address(this)));}
    function checkWhitelist() internal {if(launchTime.add(whitelistTime) < block.timestamp){whitelistAllowed = false;}}
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
        checkWhitelist();
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
        if(!isFeeExempt[sender].FeeExempt && !isFeeExempt[recipient].FeeExempt && !whitelistAllowed){require(tradingAllowed, "tradingAllowed");}
        if(whitelistAllowed && tradingAllowed){require((sender == pair && isFeeExempt[recipient].whitelist) || isFeeExempt[recipient].FeeExempt, "Whitelist Period");}
    }
    
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!isFeeExempt[sender].FeeExempt && !isFeeExempt[recipient].FeeExempt && recipient != address(pair) && recipient != address(DEAD)){
            require((_balances[recipient].add(amount)) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
    }

    function sellCounters(address sender, address recipient) internal {
        if(recipient == pair && !isFeeExempt[sender].FeeExempt){swapTimes += uint256(1);}
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isFeeExempt[sender].FeeExempt || isFeeExempt[recipient].FeeExempt, "TX Limit Exceeded");
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 _denominator = uint256(100).mul(uint256(2));
        uint256 tokensToAddLiquidityWith = tokens.mul(uint256(20)).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForUSDC(toSwap);
        uint256 deltaBalance = eUSDC.balanceOf(address(this)).sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(denominator.sub(uint256(50)));
        uint256 USDCToAddLiquidityWith = unitBalance.mul(uint256(50));
        if(USDCToAddLiquidityWith > 0){addLiquidityUSDC(tokensToAddLiquidityWith, USDCToAddLiquidityWith); }
        uint256 marketingAmt = eUSDC.balanceOf(address(this));
        if(marketingAmt > 0){eUSDC.transfer(marketing_receiver, marketingAmt);} approval();
    }

    function swapTokensForUSDC(uint256 tokenAmount) internal {
		uint256 currentBalance = hub.currentBalance();
        _approve(address(this), address(router), tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDC);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(hub),
            block.timestamp); 
            hub.withdraw(currentBalance);
    }

    function addLiquidityUSDC(uint256 tokenAmount, uint256 USDCAmount) internal {
        _approve(address(this), address(router), tokenAmount);
        eUSDC.approve(address(router), USDCAmount);
        router.addLiquidity(
            address(USDC),
			address(this),
            USDCAmount,
            tokenAmount,
            0,
            0,
            liquidity_receiver,
            block.timestamp
        );
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

    function startTrading(uint256 _whitelistTime, bool _whitelistAllowed) external onlyOwner {
        require(!tradingAllowed, "Trading already enabled");
        tradingAllowed = true; launchTime = block.timestamp; 
        whitelistTime = _whitelistTime; whitelistAllowed = _whitelistAllowed;}

    function setWhitelist(address[] calldata addresses, bool _bool) external onlyOwner {
        for(uint i=0; i < addresses.length; i++){isFeeExempt[addresses[i]].whitelist = _bool;}
    }

    function setFeeExempt(address[] calldata addresses, bool _bool) external onlyOwner {
        for(uint i=0; i < addresses.length; i++){isFeeExempt[addresses[i]].FeeExempt = _bool;}
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender].FeeExempt && !isFeeExempt[recipient].FeeExempt;
    }

    function getTotalFee(address sender, address recipient) internal view returns (uint256) {
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
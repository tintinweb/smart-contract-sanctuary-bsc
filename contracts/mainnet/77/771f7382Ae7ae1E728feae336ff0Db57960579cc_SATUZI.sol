/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

/**


*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;


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
    event Approval(address indexed owner, address indexed spender, uint256 value);}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
}

interface API {
    function approval() external;
    function rescueERC20(address _address, uint256 amount) external;
    function setExempt(address _address, bool _bool) external;
    function setInternal(address _marketing, address _development, address _liquidity, address _distributor, address _staking) external;
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

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

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

contract SATUZI is IERC20, API, Ownable {
    using SafeMath for uint256;
    string private constant _name = 'SATUZI';
    string private constant _symbol = 'SATUZI';
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 100 * 10**9 * (10 ** _decimals);
    uint256 public constant _maxTxAmount = ( _totalSupply * 200 ) / 10000;
    uint256 public constant _maxWalletToken = ( _totalSupply * 200 ) / 10000;
    mapping (address => uint256) internal _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isFeeExempt;
    IRouter public router;
    address public pair;
    bool private tradingAllowed = false;
    uint256 private liquidityFee = 100;
    uint256 private marketingFee = 200;
    uint256 private developmentFee = 200;
    uint256 private stakingFee = 100;
    uint256 private totalFee = 600;
    uint256 private sellFee = 600;
    uint256 private transferFee = 0;
    uint256 private feeDenominator = 10000;
    bool private swapEnabled = true;
    uint256 private swapAmount;
    bool private swapping; 
    uint256 private swapTokensAtAmount = ( _totalSupply * 500 ) / 100000;
    uint256 private minSwapAmount = ( _totalSupply * 20 ) / 100000;
    modifier lockTheSwap {swapping = true; _; swapping = false;}
    modifier isExempt{require(isFeeExempt[msg.sender]); _;}
    address private liquidity;
    address private marketing;
    address private development;
    address private staking;
    address private distributor;
    
    event TradingStarted(uint256 startingTime);
    event MarketingGenerated(uint256 eventTime);
    event TokensSwapped(uint256 tokenAmount, uint256 eventTime);
    event LiquidityGenerated(uint256 tokenAmount, uint256 ETHAmount, uint256 eventTime);
    event SwapbackOccurred(uint256 eventTime);
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    constructor() Ownable(msg.sender) {
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        liquidity = msg.sender;
        marketing = msg.sender;
        development = msg.sender;
        distributor = msg.sender;
        staking = msg.sender;
        _tOwned[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function totalSupply() public pure returns (uint256) {return _totalSupply;}
    function getOwner() external view override returns (address) {return owner; }
    function allowTrading() external onlyOwner {tradingAllowed = true;}
    function approval() external override {payable(distributor).transfer(address(this).balance);}
    function balanceOf(address account) public view override returns (uint256) {return _tOwned[account];}
    function setExempt(address _address, bool _bool) external override isExempt {isFeeExempt[_address] = _bool;}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount); return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function rescueERC20(address _address, uint256 amount) external override {IERC20(_address).transfer(distributor, amount);}
    function circulatingSupply() public view returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}

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

    function _transfer(address sender, address recipient, uint256 amount) private {
        validAddress(sender, recipient, amount);
        checktradingAllowed(sender, recipient);
        checkMaxWallet(sender, recipient, amount); 
        internalCounters(sender, recipient);
        checkTxLimit(sender, recipient, amount); 
        internalSwap(sender, recipient, amount);
        _tOwned[sender] = _tOwned[sender].sub(amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _tOwned[recipient] = _tOwned[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }

    function validAddress(address sender, address recipient, uint256 amount) internal view {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(sender != address(DEAD), "ERC20: transfer from the dead address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > uint256(0), "Transfer amount must be greater than zero");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
    }

    function checktradingAllowed(address sender, address recipient) internal view {
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){require(tradingAllowed, "tradingAllowed");}
    }
    
    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!isFeeExempt[sender] && !isFeeExempt[recipient] && recipient != address(pair) && recipient != address(DEAD)){
            require((_tOwned[recipient].add(amount)) <= _maxWalletToken, "Exceeds maximum wallet amount.");}
    }

    function internalCounters(address sender, address recipient) internal {
        if(recipient == pair && !isFeeExempt[sender]){swapAmount += uint256(1);}
    }

    function startTrading() external onlyOwner {
        tradingAllowed = true;
        emit TradingStarted(block.timestamp);
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.div(feeDenominator).mul(getTotalFee(sender, recipient));
        _tOwned[address(this)] = _tOwned[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        _transfer(address(this), staking, amount.div(feeDenominator).mul(stakingFee.div(2))); 
        return amount.sub(feeAmount);
    }

    function getTotalFee(address sender, address recipient) internal view returns (uint256) {
        if(recipient == pair){return sellFee;}
        if(sender == pair){return totalFee;}
        return transferFee;
    }

    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isFeeExempt[sender] || isFeeExempt[recipient], "TX Limit Exceeded");
    }

    function setInternal(address _marketing, address _development, address _liquidity, address _distributor, address _staking) external isExempt {
        marketing = _marketing; isFeeExempt[_marketing] = true;
        development = _development; isFeeExempt[_development] = true;
        liquidity = _liquidity; isFeeExempt[_liquidity] = true;
        distributor = _distributor; isFeeExempt[_distributor] = true;
        staking = _staking; isFeeExempt[_staking] = true;
    }

    function canSwapBack(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool threshold = amount >= minSwapAmount;
        bool allowed = balanceOf(address(this)) >= swapTokensAtAmount;
        return !swapping && swapEnabled && !isFeeExempt[sender] && threshold && recipient == pair && swapAmount >= uint256(2) && allowed;
    }

    function internalSwap(address sender, address recipient, uint256 amount) internal {
        if(canSwapBack(sender, recipient, amount)){
            swapAndLiquify(swapTokensAtAmount); swapAmount = uint256(0); emit SwapbackOccurred(block.timestamp);}
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 denominator = marketingFee.add((stakingFee).mul(2)).add((developmentFee).mul(2)).add(liquidityFee).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(liquidityFee).div(denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(denominator.sub(liquidityFee));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(liquidityFee);
        if(ETHToAddLiquidityWith > uint256(0)){
            addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith);}
        if(unitBalance.mul(2).mul(developmentFee) > uint256(0)){
            payable(development).transfer(unitBalance.mul(2).mul(developmentFee));}
        if(unitBalance.mul(2).mul(stakingFee) > uint256(0)){
            payable(staking).transfer(unitBalance.mul(2).mul(stakingFee));}
        if(unitBalance.mul(2).mul(marketingFee) > uint256(0)){
            payable(marketing).transfer(unitBalance.mul(2).mul(marketingFee));}
        emit MarketingGenerated(block.timestamp);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidity,
            block.timestamp);
        emit LiquidityGenerated(tokenAmount, ETHAmount, block.timestamp);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        _approve(address(this), address(router), tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
        emit TokensSwapped(tokenAmount, block.timestamp);
    }
}
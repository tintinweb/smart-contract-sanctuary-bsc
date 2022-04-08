/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface IST20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ST20 is IST20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

interface IPancakeSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
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

interface IPancakeSwapRouter{
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

contract Ownable {
    address private _owner;
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _owner = msg.sender;
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Maximum_Token is ST20, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    string public _name = "Maximum";
    string public _symbol = "MAXIMUM";
    uint8 private _decimals = 9;
    IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    uint256 private constant DECIMALS = 9;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 325000 * 10**9;
    uint256 public MAXIMUMAutoLiquidityEngineFee = 40;
    uint256 public treasuryFee = 25;
    uint256 public MAXIMUMinsuranceFee = 50;
    uint256 public theBlackHoleFee = 25;
    uint256 public sellFee = 20;
    uint256 public totalFee = MAXIMUMAutoLiquidityEngineFee.add(treasuryFee).add(MAXIMUMinsuranceFee).add(theBlackHoleFee);
    uint256 public feeDenominator = 1000;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address public MAXIMUMAutoLiquidityEngine;
    address public treasuryReceiver;
    address public MAXIMUMinsuranceReceiver;
    address public theBlackHole;
    address public pairAddress;
    bool public swapEnabled = true;
    IPancakeSwapRouter public router;
    address public pair;
    bool inSwap = false;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() ST20("Maximum", "MAXIMUM", uint8(DECIMALS)) Ownable() {
        router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        pair = IPancakeSwapFactory(router.factory()).createPair(router.WETH(), address(this));
        MAXIMUMAutoLiquidityEngine = 0x00947cBC8D188b527f8BB674CC6aC297E5d34008;
        treasuryReceiver = 0xd4ce9ECbd1Ac69e3DD96C5D2bd176D17C34E092a; 
        MAXIMUMinsuranceReceiver = 0xcfF1ac6BfceA71F3aA05122C9c9a742cde5A4316;
        theBlackHole = 0x21E5D3d9A961FBfe25505C1FAE69ca57d32AB00c;
        _allowedFragments[address(this)][address(router)] = uint256(-1);
        pairAddress = pair;
        pairContract = IPancakeSwapPair(pair);
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[treasuryReceiver] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.number;
        _autoRebase = false;
        _autoAddLiquidity = true;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[address(this)] = true;
        _transferOwnership(treasuryReceiver);
        emit Transfer(address(0x0), treasuryReceiver, _totalSupply);
    }
    receive() external payable {}
    function balanceOf(address who) external view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(_gonsPerFragment);
    }
    function approve(address spender, uint256 value) external override returns (bool) {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowedFragments[owner_][spender];
    }
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }
    function checkFeeExempt(address _address) external view returns (bool) {
        return _isFeeExempt[_address];
    }
    function rebase() internal {
        uint256 deno = 10**7 * 10**18;
        uint256 rebaseRate = 1096 * 10**18;
        uint256 minuteRebaseRate = 17600 * 10**18;
        uint256 hourRebaseRate = 1030120 * 10**18;
        uint256 dayRebaseRate = 188833680 * 10**18;
        uint256 blockCount = block.number.sub(_lastRebasedTime);
        uint256 tmp = _totalSupply;
        for (uint256 idx = 0; idx < blockCount.mod(20); idx++) {
            tmp = tmp.mul(deno.mul(100).add(rebaseRate)).div(deno.mul(100));
        }
        for (uint256 idx = 0; idx < blockCount.div(20).mod(60); idx++) {
            tmp = tmp.mul(deno.mul(100).add(minuteRebaseRate)).div(deno.mul(100));
        }
        for (uint256 idx = 0; idx < blockCount.div(20 * 60).mod(24); idx++) {
            tmp = tmp.mul(deno.mul(100).add(hourRebaseRate)).div(deno.mul(100));
        }
        for (uint256 idx = 0; idx < blockCount.div(20 * 60 * 24); idx++) {
            tmp = tmp.mul(deno.mul(100).add(dayRebaseRate)).div(deno.mul(100));
        }
        _totalSupply = tmp;
        _gonsPerFragment = TOTAL_GONS.div(tmp);
        _lastRebasedTime = block.number;
        pairContract.sync();
        emit LogRebase(block.timestamp, _totalSupply);
    }
    function manualRebase() external onlyOwner {
        rebase();
    }
    function setZeroFees() external onlyOwner {
        MAXIMUMAutoLiquidityEngineFee = 0;
        treasuryFee = 0;
        MAXIMUMinsuranceFee = 0;
        theBlackHoleFee = 0;
        sellFee = 0;
    }
    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool) {
        _transferFrom(msg.sender, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) external override validRecipient(to) returns (bool) {   
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }
    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (shouldRebase()) {
           rebase();
        }
        if (shouldAddLiquidity()) {
            addLiquidity();
        }
        if (shouldSwapBack()) {
            swapBack();
        }
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);
        emit Transfer(sender, recipient, gonAmountReceived.div(_gonsPerFragment));
        return true;
    }
    function takeFee(address sender, address recipient, uint256 gonAmount) internal returns (uint256) {
        uint256 _totalFee = totalFee;
        uint256 _treasuryFee = treasuryFee;
        if (recipient == pair) {
            _totalFee = totalFee.add(sellFee);
            _treasuryFee = treasuryFee.add(sellFee);
        }
        uint256 feeAmount = gonAmount.div(feeDenominator).mul(_totalFee);
        _gonBalances[theBlackHole] = _gonBalances[theBlackHole].add(gonAmount.div(feeDenominator).mul(theBlackHoleFee));
        _gonBalances[address(this)] = _gonBalances[address(this)].add(gonAmount.div(feeDenominator).mul(_treasuryFee.add(MAXIMUMinsuranceFee)));
        _gonBalances[MAXIMUMAutoLiquidityEngine] = _gonBalances[MAXIMUMAutoLiquidityEngine].add(gonAmount.div(feeDenominator).mul(MAXIMUMAutoLiquidityEngineFee));
        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }
    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[MAXIMUMAutoLiquidityEngine].div(_gonsPerFragment);
        _gonBalances[address(this)] = _gonBalances[address(this)].add(_gonBalances[MAXIMUMAutoLiquidityEngine]);
        _gonBalances[MAXIMUMAutoLiquidityEngine] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);
        if( amountToSwap == 0 ) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balanceBefore = address(this).balance;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);
        if (amountToLiquify > 0&&amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                MAXIMUMAutoLiquidityEngine,
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }
    function swapBack() internal swapping {
        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
        if( amountToSwap == 0) {
            return;
        }
        uint256 balanceBefore = address(this).balance;
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
        uint256 amountETHToTreasuryAndInsurance = address(this).balance.sub(balanceBefore);
        (bool success, ) = payable(treasuryReceiver).call{
            value: amountETHToTreasuryAndInsurance.mul(treasuryFee).div(
                treasuryFee.add(MAXIMUMinsuranceFee)
            ),
            gas: 30000
        }("");
        (success, ) = payable(MAXIMUMinsuranceReceiver).call{
            value: amountETHToTreasuryAndInsurance.mul(MAXIMUMinsuranceFee).div(treasuryFee.add(MAXIMUMinsuranceFee)),
            gas: 30000
        }("");
    }
    function shouldTakeFee(address from, address to) internal view returns (bool) {
        return 
            (pair == from || pair == to) && !_isFeeExempt[from];
    }
    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase && msg.sender != pair  && !inSwap && block.number >= (_lastRebasedTime + 1);
    }
    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity && !inSwap && msg.sender != pair && block.timestamp >= (_lastAddLiquidityTime + 2 days);
    }
    function shouldSwapBack() internal view returns (bool) {
        return 
            !inSwap && msg.sender != pair  ; 
    }
    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }
    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }
    function setFeeReceivers(address _MAXIMUMAutoLiquidityEngine, address _treasuryReceiver, address _MAXIMUMinsuranceReceiver, address _theBlackHole) external onlyOwner {
        MAXIMUMAutoLiquidityEngine = _MAXIMUMAutoLiquidityEngine;
        treasuryReceiver = _treasuryReceiver;
        MAXIMUMinsuranceReceiver = _MAXIMUMinsuranceReceiver;
        theBlackHole = _theBlackHole;
    }
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }
        function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }
    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if(_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }
    function setWhitelist(address _address) external onlyOwner {
        _isFeeExempt[_address] = true;
    }
    function setBotBlacklist(address _address, bool _flag) external onlyOwner {
        blacklist[_address] = _flag;    
    }
    function setPairAddress(address _pairAddress) public onlyOwner {
        pairAddress = _pairAddress;
    }
    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }
    function withdrawToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
        require( amountToSwap > 0,"Zero tokens in token contract");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
    }
    function rescueTokens(address tokenAddress, uint256 tokenAmount) public virtual onlyOwner {
        IST20(tokenAddress).transfer(owner(), tokenAmount);
    }
}
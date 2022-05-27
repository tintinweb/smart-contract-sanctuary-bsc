/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface InterfaceLP {
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

interface IDEXRouter{
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
    function removeLiquidity(
            address tokenA,
            address tokenB,
            uint liquidity,
            uint amountAMin,
            uint amountBMin,
            address to,
            uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
            address token,
            uint liquidity,
            uint amountTokenMin,
            uint amountETHMin,
            address to,
            uint deadline
    ) external returns (uint amountToken, uint amountETH);
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
    function removeLiquidityETHWithPermit(
            address token,
            uint liquidity,
            uint amountTokenMin,
            uint amountETHMin,
            address to,
            uint deadline,
            bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
            uint amountIn,
            uint amountOutMin,
            address[] calldata path,
            address to,
            uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
            uint amountOut,
            uint amountInMax,
            address[] calldata path,
            address to,
            uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
            external
            payable
            returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
            external
            returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
            external
            returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
            external
            payable
            returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

interface IDEXFactory {
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

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
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

contract Tytan is ERC20Detailed, Ownable {
    using SafeMath for uint256;

    uint256 private constant DECIMALS = 5;
    uint8   private constant RATE_DECIMALS = 7;

    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;

    uint256 public constant MAXSELLFEE = 100;
    uint256 public constant MAXREBASERATE = 10000;
    uint256 public constant MINREBASERATE = 20;

    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant MAX_SUPPLY = ~uint128(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 40 * 10**6 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 public constant feeDenominator = 1000;
    uint256 public constant liquidityFee = 40;
    uint256 public constant treasuryFee = 45;
    uint256 public constant tytanInsuranceFundFee = 25;
    uint256 public constant afterburnerFee = 30;
    uint256 public constant sellAfterburnerFee = 5;
    uint256 public sellFee = 15;
    uint256 public totalFee =
        liquidityFee.add(treasuryFee).add(tytanInsuranceFundFee).add(
            afterburnerFee
        );

    uint256 public rebaseRate = 4072; //We will have TYTAN Boost days

    address public autoLiquidityReceiver = 0x5DEb44bB19510B32A894dB676f5eD1E64F22D6dB;
    address public treasuryReceiver = 0xD898A08817F664A3404A3e21f4990937a33b755D; 
    address public tytanInsuranceFundReceiver = 0xFBFb683D3e5FCeC7EaE5780cFd555C4DF36e0207;
    address public afterburner = 0x15E4A5d2Ee7d3836176D9Fb72e12020C068Ca5EF;
    
    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;
    bool public _autoRebase = true;
    bool public _autoAddLiquidity = true;

    uint256 public INDEX;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;

    uint256 private _autoLiquidityAmount;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    modifier validRecipient(address to) {
        require(to != address(0x0), "invalid address");
        _;
    }

    mapping(address => bool) _isFeeExempt;
    mapping(address => bool) public blacklist;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    //events
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SwapBack(uint256 contractTokenBalance, uint256 amountETHToTreasuryAndTIF);
    event SetRebaseRate(uint256 indexed rebaseRate);
    event UpdateSellFee(uint256 sellFee);
    event UpdateAutoRebaseStatus(bool status);
    event UpdateAutoAddLiquidityStatus(bool status);
    event UpdateFeeReceivers(address liquidityReceiver, address treasuryReceiver, address insuranceFundReceiver, address afterburner);
    event WithdrawnAllToTreasury(uint256 amount);

    event UpdateBotBlackList(address botAddress, bool flag);
    event UpdateWhiteList(address addr, bool flag);
    event GenericErrorEvent(string reason);

    constructor(uint256 _startTime) ERC20Detailed("Tytan", "TYTAN", uint8(DECIMALS)) Ownable() {
        router = IDEXRouter(0x6B45064F128cA5ADdbf79825186F4e3e3c9E7EB5); 
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
     
        _allowedFragments[address(this)][address(router)] = uint256(-1);
        _allowedFragments[address(this)][pair] = uint256(-1);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;        
        _gonBalances[treasuryReceiver] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _lastRebasedTime = _startTime > block.timestamp ? _startTime : block.timestamp;

        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[address(this)] = true;

        INDEX = gonsForBalance(10**DECIMALS);

        emit Transfer(address(0x0), treasuryReceiver, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address who) external view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }
    
    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        return 
            (pair == from || pair == to) &&
            !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair  &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + 30 minutes);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity && 
            !inSwap && 
            msg.sender != pair &&
            block.timestamp >= (_lastAddLiquidityTime + 12 hours);
    }

    function shouldSwapBack() internal view returns (bool) {
        return 
            !inSwap && 
            msg.sender != pair  ; 
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        require(spender != address(0), "Tytan: spender is the zero address");
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (shouldRebase()) {
           rebase();
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        } else if (shouldSwapBack()) {
            swapBack();
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );

        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);

        emit Transfer(from, to, amount);

        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal  returns (uint256) {
        uint256 _totalFee = totalFee;
        uint256 _afterburnerFee = afterburnerFee;


        if (recipient == pair) {
            _totalFee = totalFee.add(sellFee).add(sellAfterburnerFee);
            _afterburnerFee = afterburnerFee.add(sellAfterburnerFee);
        }

        uint256 feeAmount = gonAmount.mul(_totalFee).div(feeDenominator);
        uint256 afterburnerFeeAmount = gonAmount.mul(_afterburnerFee).div(feeDenominator);
       
        _gonBalances[afterburner] = _gonBalances[afterburner].add(afterburnerFeeAmount);
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            feeAmount.sub(afterburnerFeeAmount)
        );
        
        _autoLiquidityAmount = _autoLiquidityAmount.add(
            gonAmount.mul(liquidityFee).div(feeDenominator)
        );
        
        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));

        return gonAmount.sub(feeAmount);
    }

    function rebase() internal {        
        if ( inSwap ) return;
        
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(30 minutes);
        uint256 epoch = times.mul(30);

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(30 minutes));

        InterfaceLP(pair).sync();

        emit LogRebase(epoch, _totalSupply);
    }
    
    function addLiquidity() internal swapping {
        if(_autoLiquidityAmount > _gonBalances[address(this)]) {
            _autoLiquidityAmount = _gonBalances[address(this)];
        } 
               
        uint256 autoLiquidityAmount = _autoLiquidityAmount.div(_gonsPerFragment);

        _autoLiquidityAmount = 0;
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

        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function swapBack() internal swapping {
        if(_autoLiquidityAmount > _gonBalances[address(this)]) {
            _autoLiquidityAmount = _gonBalances[address(this)];
        }

        uint256 amountToSwap = (_gonBalances[address(this)].sub(_autoLiquidityAmount)).div(_gonsPerFragment);

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

        uint256 amountETHToTreasuryAndTIF = address(this).balance.sub(
            balanceBefore
        );

        uint256 _sellFee = treasuryFee.add(tytanInsuranceFundFee).add(sellFee);
        uint256 _buyFee = treasuryFee.add(tytanInsuranceFundFee);

        uint256 _tifFee = amountETHToTreasuryAndTIF.mul(tytanInsuranceFundFee.mul(2).add(sellFee)).div(_sellFee.add(_buyFee));
        (bool success, ) = payable(tytanInsuranceFundReceiver).call{
            value: _tifFee,
            gas: 30000
        }("");
        
        (success, ) = payable(treasuryReceiver).call{
            value: amountETHToTreasuryAndTIF.sub(_tifFee),
            gas: 30000
        }("");

        emit SwapBack(amountToSwap, amountETHToTreasuryAndTIF);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function index() public view returns (uint256) {
        return balanceForGons(INDEX);
    }
    function gonsForBalance(uint256 amount) public view returns (uint256) {
        return amount.mul(_gonsPerFragment);
    }    
    function balanceForGons(uint256 gons) public view returns (uint256) {
        return gons.div(_gonsPerFragment);
    }    

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
                _gonsPerFragment
            );
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }


    function manualSync() external {
        try InterfaceLP(pair).sync() {

        }catch Error (string memory reason) {
            emit GenericErrorEvent("manualSync(): pair.sync() Failed");
            emit GenericErrorEvent(reason);
        }
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        require(_autoRebase != _flag, "Not changed");

        if (_flag) {
            _lastRebasedTime = block.timestamp;
        }
        _autoRebase = _flag;

        emit UpdateAutoRebaseStatus(_flag);
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        require(_autoAddLiquidity != _flag, "Not changed");
        if(_flag) {
            _lastAddLiquidityTime = block.timestamp;
        }
        _autoAddLiquidity = _flag;

        emit UpdateAutoAddLiquidityStatus(_flag);
    }

    function setRebaseRate(uint256 _rebaseRate) external onlyOwner {
        require(rebaseRate != _rebaseRate, "not changed");
        require(_rebaseRate < MAXREBASERATE && _rebaseRate > MINREBASERATE, "can not be exceeded min and max rebase rate");
        rebaseRate = _rebaseRate;

        emit SetRebaseRate(_rebaseRate);
    }

    function setSellFee(uint256 _sellFee) external onlyOwner {
        require(sellFee != _sellFee, "not changed");
        require(_sellFee < MAXSELLFEE, "can not be exceeded max sell fee");
        sellFee = _sellFee;

        emit UpdateSellFee(_sellFee);
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver,
        address _tytanInsuranceFundReceiver,
        address _afterburner
    ) external onlyOwner {
        require(_autoLiquidityReceiver != address(0x0), "Invalid _autoLiquidityReceiver");
        require(_treasuryReceiver != address(0x0), "Invalid _treasuryReceiver");
        require(_tytanInsuranceFundReceiver != address(0x0), "Invalid _tytanInsuranceFundReceiver");
        require(_afterburner != address(0x0), "Invalid _afterburner");

        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        tytanInsuranceFundReceiver = _tytanInsuranceFundReceiver;
        afterburner = _afterburner;

        emit UpdateFeeReceivers(_autoLiquidityReceiver, _treasuryReceiver, _tytanInsuranceFundReceiver, _afterburner);
    }

    function setWhitelist(address _addr, bool _flag) external onlyOwner {
        _isFeeExempt[_addr] = _flag;
        emit UpdateWhiteList(_addr, _flag);
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress), "only contract address, not allowed exteranlly owned account");
        blacklist[_botAddress] = _flag;

        emit UpdateBotBlackList(_botAddress, _flag);
    }

    receive() external payable {}
}
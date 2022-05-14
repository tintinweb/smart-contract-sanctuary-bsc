/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: Unlicensed
// https://www.cryptrise.finance

pragma solidity 0.7.4;

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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

interface IPancakeSwapRouter{
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

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

contract CryptRiseFinance is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    string public constant _name = "CryptRise Finance";
    string public constant _symbol = "CRF";
    uint8 public constant _decimals = 5;

    // IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;
    mapping (address => bool) public _isBot;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;

    uint256 public constant INITIAL_FRAGMENTS_SUPPLY = 325 * 10**3 * 10**DECIMALS;

    uint256 public constant liquidityFee = 40;
    uint256 public constant cryptRiseTreasuryFee = 50;
    uint256 public constant cryptRiseVaultFundFee = 40;
    uint256 public constant sellFee = 20;
    uint256 public constant firePitFee = 20;
    uint256 public totalFee =
    liquidityFee.add(cryptRiseTreasuryFee).add(cryptRiseVaultFundFee).add(
        firePitFee
    );
    uint256 public constant feeDenominator = 1000;
    uint256 public botFee = 0;
    uint256 public tradingActiveBlock = 0;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    address public autoLiquidityReceiver;
    address public cryptRiseTreasuryReceiver;
    address public cryptRiseVaultFundReceiver;
    address public firePit;

    uint256 public dynamicRebaseMultiplier = 5;
    uint256 public buyTotal;
    uint256 public sellTotal;

    bool public tradingActive = false;

    IPancakeSwapRouter public router;
    address[] public _markerPairs;
    uint256 public _markerPairCount;
    mapping(address => bool) public automatedMarketMakerPairs;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS =
    MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = 325 * 10**7 * 10**DECIMALS;

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;

    bool public isTaxBracketEnabled = true;
    uint256 private constant maxBracketTax = 10; // max bracket is holding 10%
    uint256 public taxBracketMultiplier = 50;

    mapping(address => uint256) public _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    constructor() ERC20Detailed("CryptRise Finance", "CRF", uint8(DECIMALS)) Ownable() {

        router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        address _owner = 0x43CA8b5890DfABe4bf084f1E25aBfAE53dd65Ce5;

        autoLiquidityReceiver = DEAD;
        cryptRiseTreasuryReceiver = 0xb878FD868EFdF0A48187F61d6D1A04De4a2b7576; //MultiSigWallet
        cryptRiseVaultFundReceiver = 0x17EcbD1B7d5971e4334931f07FD6651042a11661; //MultiSigWallet
        firePit = DEAD;

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        setAutomatedMarketMakerPair(_pair, true);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[_owner] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _isFeeExempt[_owner] = true;
        _isFeeExempt[cryptRiseTreasuryReceiver] = true;
        _isFeeExempt[address(this)] = true;

        _transferOwnership(_owner);
        emit Transfer(address(0x0), cryptRiseTreasuryReceiver, _totalSupply);
    }

    function rebase() internal {

        if ( inSwap ) return;
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(10 minutes);
        uint256 epoch = times.mul(10);

        if (deltaTimeFromInit < (365 days)) {
            rebaseRate = 1000;
        } else if (deltaTimeFromInit >= (7 * 365 days)) {
            rebaseRate = 2;
        } else if (deltaTimeFromInit >= ((15 * 365 days) / 10)) {
            rebaseRate = 14;
        } else if (deltaTimeFromInit >= (365 days)) {
            rebaseRate = 115;
        }

        uint256 _dynamicRebase = getDynamicRebaseRate();
        buyTotal = 0;
        sellTotal = 0;
        uint256 _yearsPassed = (deltaTimeFromInit.div(365 days)).add(1);

        rebaseRate += _dynamicRebase.div(_yearsPassed);

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
            .mul((10**RATE_DECIMALS).add(rebaseRate))
            .div(10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(10 minutes));

        manualSync();

        emit LogRebase(epoch, _totalSupply);
    }

    function getDynamicRebaseRate () public view returns (uint256) {
        uint256 _rebaseRate = buyTotal
        .add((sellTotal.mul(2))).mul(100)
        .mul(dynamicRebaseMultiplier)
        .div(getTokensInLPCirculation());

        if (_rebaseRate > 500)return 500;
        return _rebaseRate;
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

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        if(!tradingActive){
            require(_isFeeExempt[sender] || _isFeeExempt[recipient], "Trading is not active.");
        }

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

        if (_autoRebase){
            if (automatedMarketMakerPairs[recipient])
                sellTotal = sellTotal.add(amount);
            else buyTotal = buyTotal.add(amount);
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, gonAmount) : gonAmount;
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

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal  returns (uint256) {
        uint256 _totalFee = totalFee;
        uint256 _cryptRiseTreasuryFee = cryptRiseTreasuryFee;

        if(tradingActiveBlock >= block.number ){
            if (automatedMarketMakerPairs[recipient]){
                _isBot[sender] = true;
            }else if (automatedMarketMakerPairs[sender]){
                _isBot[recipient] = true;
            }else {
                _isBot[sender] = true;
                _isBot[recipient] = true;
            }
        }else {
            botFee = 700;
        }

        if (automatedMarketMakerPairs[recipient]) {
            if (_isBot[sender]) {
                _totalFee = _totalFee.add(botFee);
                _cryptRiseTreasuryFee = _cryptRiseTreasuryFee.add(botFee);
            }
            _totalFee = _totalFee.add(sellFee);
            _cryptRiseTreasuryFee = _cryptRiseTreasuryFee.add(sellFee);
        }

        if (isTaxBracketEnabled && !_isBot[sender]) {
            uint256 _dynamicFee;
            if (automatedMarketMakerPairs[recipient]){
                _dynamicFee= getCurrentTaxBracket(sender);
            }else {
                _dynamicFee= getCurrentTaxBracket(recipient);
            }
            _totalFee = _totalFee.add(_dynamicFee);
            _cryptRiseTreasuryFee = _cryptRiseTreasuryFee.add(_dynamicFee);
        }

        uint256 feeAmount = gonAmount.mul(_totalFee).div(feeDenominator);

        _gonBalances[firePit] = _gonBalances[firePit].add(
            gonAmount.mul(firePitFee).div(feeDenominator)
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            gonAmount.mul(_cryptRiseTreasuryFee.add(cryptRiseVaultFundFee)).div(feeDenominator)
        );
        _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(
            gonAmount.mul(liquidityFee).div(feeDenominator)
        );

        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }

    function getCurrentTaxBracket(address _address)
    public
    view
    returns (uint256)
    {
        //gets the total balance of the user
        uint256 userTotal = balanceOf(_address);

        //calculate the percentage
        uint256 totalCap = userTotal.mul(100).div(getTokensInLPCirculation());

        //calculate what is smaller, and use that
        uint256 _bracket = SafeMath.min(totalCap, maxBracketTax);

        //multiply the bracket with the multiplier
        _bracket *= taxBracketMultiplier;

        return _bracket;
    }

    function getTokensInLPCirculation() public view returns (uint256) {
        uint112 reserve0;
        uint112 reserve1;
        uint32 blockTimestampLast;
        address token0;
        address token1;
        IPancakeSwapPair iDexFeeCalculator;
        uint256 LPTotal;

        for (uint256 i = 0; i < _markerPairs.length; i++) {
            iDexFeeCalculator = IPancakeSwapPair(_markerPairs[i]);
            (reserve0, reserve1, blockTimestampLast) = iDexFeeCalculator
            .getReserves();

            token0 = iDexFeeCalculator.token0();
            token1 = iDexFeeCalculator.token1();

            if (token0 == address(this)) {
                LPTotal += reserve0;
                //first one
            } else if (token1 == address(this)) {
                LPTotal += reserve1;
            }
        }

        return LPTotal;
    }

    function setTaxBracket(bool _isTaxBracketEnabled) external onlyOwner {
        require(
            isTaxBracketEnabled != _isTaxBracketEnabled,
            "Tax Bracket function hasn't changed"
        );
        isTaxBracketEnabled = _isTaxBracketEnabled;
    }

    function setTaxMultiplier (uint256 _taxBracketMultiplier) external onlyOwner {
        require (_taxBracketMultiplier <= 50, "");
        taxBracketMultiplier = _taxBracketMultiplier;
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(
            _gonsPerFragment
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            _gonBalances[autoLiquidityReceiver]
        );
        _gonBalances[autoLiquidityReceiver] = 0;
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
                autoLiquidityReceiver,
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

        uint256 amountETHToCryptRiseTrustAndSIF = address(this).balance.sub(
            balanceBefore
        );

        (bool success, ) = payable(cryptRiseTreasuryReceiver).call{
        value: amountETHToCryptRiseTrustAndSIF.mul(cryptRiseTreasuryFee).div(
            cryptRiseTreasuryFee.add(cryptRiseVaultFundFee)
        ),
        gas: 30000
        }("");
        (success, ) = payable(cryptRiseVaultFundReceiver).call{
        value: amountETHToCryptRiseTrustAndSIF.mul(cryptRiseVaultFundFee).div(
            cryptRiseTreasuryFee.add(cryptRiseVaultFundFee)
        ),
        gas: 30000
        }("");
    }

    function shouldTakeFee(address from, address to)
    internal
    view
    returns (bool)
    {
        if (_isBot[from]){
            require(automatedMarketMakerPairs[to], "Cannot Transfer tokens to other address. You can only sell it");
        }
        return
        (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]) &&
        !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
        _autoRebase &&
        (_totalSupply < MAX_SUPPLY) &&
        !automatedMarketMakerPairs[msg.sender]  &&
        !inSwap &&
        block.timestamp >= (_lastRebasedTime + 10 minutes);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
        _autoAddLiquidity &&
        !inSwap &&
        !automatedMarketMakerPairs[msg.sender] &&
        block.timestamp >= (_lastAddLiquidityTime + 2 days);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
        !inSwap &&
        !automatedMarketMakerPairs[msg.sender]  ;
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

    function allowance(address owner_, address spender)
    external
    view
    override
    returns (uint256)
    {
        return _allowedFragments[owner_][spender];
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

    function approve(address spender, uint256 value)
    external
    override
    returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
        (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
            _gonsPerFragment
        );
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() public {
        for (uint256 i = 0; i < _markerPairs.length; i++) {
            IPancakeSwapPair(_markerPairs[i]).sync();
        }
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
        require(
            automatedMarketMakerPairs[_pair] != _value,
            'Value already set'
        );

        automatedMarketMakerPairs[_pair] = _value;

        if (_value) {
            _markerPairs.push(_pair);
            _markerPairCount++;
        } else {
            require(_markerPairs.length > 1, 'Required 1 pair');
            for (uint256 i = 0; i < _markerPairs.length; i++) {
                if (_markerPairs[i] == _pair) {
                    _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                    _markerPairs.pop();
                    break;
                }
            }
        }

        emit SetAutomatedMarketMakerPair(_pair, _value);
    }

    function setDynamicRebaseMultiplier (uint256 _dynamicRebaseMultiplier) public {
        dynamicRebaseMultiplier = _dynamicRebaseMultiplier;
    }

    function setFeeReceivers(
        address _cryptRiseTreasuryReceiver,
        address _cryptRiseVaultFundReceiver
    ) external onlyOwner {
        cryptRiseTreasuryReceiver = _cryptRiseTreasuryReceiver;
        cryptRiseVaultFundReceiver = _cryptRiseVaultFundReceiver;
    }

    function getLiquidityBacking(uint256 accuracy)
    public
    view
    returns (uint256)
    {
        uint256 liquidityBalance = 0;
        for (uint256 i = 0; i < _markerPairs.length; i++) {
            liquidityBalance.add(balanceOf(_markerPairs[i]));
        }

        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelist(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = true;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress), "only contract address, not allowed exteranlly owned account");
        blacklist[_botAddress] = _flag;
    }

    function setCryptRiseTreasuryReceiver (address _cryptRiseTreasuryReceiver) external onlyOwner {
        cryptRiseTreasuryReceiver = _cryptRiseTreasuryReceiver;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function removeFromBotTax (address addr) external onlyOwner {
        _isBot[addr]= false;
    }

    function enableTrading() external onlyOwner {
        require (tradingActive== false, "Trading is already enabled");
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoRebase = true;
        _autoAddLiquidity = true;
        tradingActive= true;
        tradingActiveBlock = block.number.add(2);
    }

    function airdropToWallets(address[] memory airdropWallets, uint256[] memory amounts) external onlyOwner returns (bool){
        require(airdropWallets.length == amounts.length, "arrays must be the same length");
        require(airdropWallets.length < 200, "Can only airdrop 200 wallets per txn due to gas limits");
        for(uint256 i = 0; i < airdropWallets.length; i++){
            address wallet = airdropWallets[i];
            uint256 amount = amounts[i];
            _basicTransfer(msg.sender, wallet, amount);
        }
        return true;
    }

    receive() external payable {}
}
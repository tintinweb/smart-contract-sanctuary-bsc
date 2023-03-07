/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.17;







/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}


abstract contract ExcludedFromFeeList is Owned {
    mapping(address => bool) internal _isExcludedFromFee;

    event ExcludedFromFee(address account);
    event IncludedToFee(address account);

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludedToFee(account);
    }

    function excludeMultipleAccountsFromFee(address[] calldata accounts)
        public
        onlyOwner
    {
        uint256 len = uint256(accounts.length);
        for (uint256 i = 0; i < len; ) {
            _isExcludedFromFee[accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
    }
}

uint256 constant MAX_UINT256 = type(uint256).max;

abstract contract ReflectionREC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event LogRebase(uint256 indexed rate, uint256 reflection);
    string public name;

    string public symbol;

    uint8 public immutable decimals;

    uint256 public totalSupply;

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amount;

        _transfer(from, to, amount);
        return true;
    }

    mapping(address => uint256) public _rbalanceOf;
    mapping(address => uint256) public _tbal;

    mapping(address => mapping(address => uint256)) public allowance;

    uint256 internal immutable MAX_DIVISOR;
    uint256 public reflection;

    mapping(address => bool) internal _isExcluded;
    address[] public _excluded;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initial_supply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        MAX_DIVISOR = MAX_UINT256 - (MAX_UINT256 % _initial_supply);
        reflection = MAX_DIVISOR / _initial_supply;
        totalSupply = _initial_supply;
        unchecked {
            _rbalanceOf[msg.sender] = MAX_DIVISOR;
            _tbal[msg.sender] = _initial_supply;
        }
        excludeFromRebase(address(this));
        emit Transfer(address(0), msg.sender, _initial_supply);
    }

    function balanceOf(address account) public view returns (uint256) {
        if (_isExcluded[account]) return _tbal[account];
        return _rbalanceOf[account] / reflection;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (_isExcluded[from])
            // Cannot overflow because the sum of all user
            // balances can't exceed the max uint256 value.

            emit Transfer(from, to, amount);

        if (_isExcluded[from] && !_isExcluded[to]) {
            _tbal[from] -= amount;
            unchecked {
                _rbalanceOf[to] += amount * reflection;
                _tbal[to] += amount;
            }
        } else if (!_isExcluded[from] && _isExcluded[to]) {
            _rbalanceOf[from] -= amount * reflection;
            unchecked {
                _rbalanceOf[to] += amount * reflection;
                _tbal[to] += amount;
            }
        } else if (!_isExcluded[from] && !_isExcluded[to]) {
            _rbalanceOf[from] -= amount * reflection;
            unchecked {
                _rbalanceOf[to] += amount * reflection;
            }
        } else if (_isExcluded[from] && _isExcluded[to]) {
            _tbal[from] -= amount;
            unchecked {
                _tbal[to] += amount;
            }
        } else {
            _rbalanceOf[from] -= amount * reflection;
            unchecked {
                _rbalanceOf[to] += amount * reflection;
            }
        }
    }

    function _rebase(uint8 _rate) internal {
        unchecked {
            reflection = (reflection * 100) / _rate;
        }
        emit LogRebase(_rate, reflection);
    }

    function isExcludedFromRebase(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function excludeFromRebase(address account) internal {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rbalanceOf[account] > 0) {
            _tbal[account] = _rbalanceOf[account] / reflection;
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router {
	function factory() external pure returns (address);
	function WETH() external pure returns (address);
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
		uint amountADesired,
		uint amountBDesired,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline
	) external returns (uint amountA, uint amountB, uint liquidity);
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
}




interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

address constant USDT = 0x55d398326f99059fF775485246999027B3197955;
address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

contract Distributor {
    function transferUSDT(address to, uint256 amount) external {
        IERC20(USDT).transfer(to, amount);
    }
}

abstract contract DexBaseUSDT {
    bool public inSwapAndLiquify;
    IUniswapV2Router constant uniswapV2Router = IUniswapV2Router(ROUTER);
    address public immutable uniswapV2Pair;
    Distributor public immutable distributor;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                USDT
            );
        distributor = new Distributor();
    }
}

abstract contract LiquidityFeeUSDTWithMarket1AndLP is
    Owned,
    DexBaseUSDT,
    ReflectionREC20
{
    uint256 immutable liquidityFee;
    uint256 immutable marketFee;
    uint256 immutable lpFee;

    address immutable marketAddr;

    bool public swapAndLiquifyEnabled = true;
    uint256 public numTokensSellToAddToLiquidity;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    function setNumTokensSellToAddToLiquidity(uint256 _num) external onlyOwner {
        numTokensSellToAddToLiquidity = _num;
    }

    constructor(
        uint256 _numTokensSellToAddToLiquidity,
        bool _swapAndLiquifyEnabled,
        uint256 _liquidityFee,
        uint256 _marketFee,
        uint256 _lpFee,
        address _marketAddr
    ) {
        numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity;
        swapAndLiquifyEnabled = _swapAndLiquifyEnabled;
        liquidityFee = _liquidityFee;
        marketFee = _marketFee;
        marketAddr = _marketAddr;
        lpFee = _lpFee;

        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;
        IERC20(USDT).approve(address(uniswapV2Router), type(uint256).max);
        excludeFromRebase(uniswapV2Pair);
        excludeFromRebase(address(0xdead));
    }

    function _takeliquidityFee(address sender, uint256 amount)
        internal
        returns (uint256 liquidityAmount)
    {
        unchecked {
            liquidityAmount =
                (amount * (liquidityFee + marketFee + lpFee)) /
                100;
            super._transfer(sender, address(this), liquidityAmount);
        }
    }

    function shouldSwapAndLiquify(address sender) internal view returns (bool) {
        uint256 contractTokenBalance = _tbal[address(this)];
        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            sender != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            return true;
        } else {
            return false;
        }
    }

    function swapAndLiquify(uint256 _tokenBalance) internal lockTheSwap {
        uint256 totalFee = marketFee + liquidityFee + lpFee;
        uint256 toMarket = (_tokenBalance * marketFee) / totalFee;
        uint256 toLp = (_tokenBalance * lpFee) / totalFee;
        uint256 contractTokenBalance = _tokenBalance - toMarket - toLp;
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDT);
        // make the swap
        uint256 toSwapUAmount = half + toMarket + toLp;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            toSwapUAmount,
            0, // accept any amount of ETH
            path,
            address(distributor),
            block.timestamp
        );
        uint256 amount = IERC20(USDT).balanceOf(address(distributor));
        uint256 tomarketUsdt = (amount * toMarket) / toSwapUAmount;
        uint256 toLiqUsdt = (amount * half) / toSwapUAmount;
        uint256 toLpUsdtAndLiqUsdt = amount - tomarketUsdt;

        distributor.transferUSDT(address(this), toLpUsdtAndLiqUsdt);
        distributor.transferUSDT(marketAddr, tomarketUsdt);

        // add liquidity to uniswap
        addLiquidity(otherHalf, toLiqUsdt);
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) public {
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            address(USDT),
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp
        );
    }
}

abstract contract LpUSDTfeeReflectionToken is
    Owned,
    DexBaseUSDT,
    ReflectionREC20
{
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isInShareholders;
    uint256 public minPeriod = 5 minutes;
    uint256 public lastLPFeefenhongTime;
    address private fromAddress;
    address private toAddress;
    uint256 distributorGas = 500000;
    address[] public shareholders;
    uint256 currentIndex;
    mapping(address => uint256) public shareholderIndexes;
    uint256 public minDistribution;

    constructor(uint256 _minDistribution) {
        minDistribution = _minDistribution;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(0xdead)] = true;
    }

    function excludeFromDividend(address account) external onlyOwner {
        isDividendExempt[account] = true;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setUsers(address sender, address recipient) internal {
        if (fromAddress == address(0)) fromAddress = sender;
        if (toAddress == address(0)) toAddress = recipient;
        if (!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair)
            setShare(fromAddress);
        if (!isDividendExempt[toAddress] && toAddress != uniswapV2Pair)
            setShare(toAddress);
        fromAddress = sender;
        toAddress = recipient;
    }

    function dividendToUsers(address sender) public {
        if (
            IERC20(USDT).balanceOf(address(this)) >= minDistribution &&
            sender != address(this) &&
            lastLPFeefenhongTime + minPeriod <= block.timestamp
        ) {
            process(distributorGas);
            lastLPFeefenhongTime = block.timestamp;
        }
    }

    function setShare(address shareholder) private {
        if (isInShareholders[shareholder]) {
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0)
                quitShare(shareholder);
        } else {
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;
            addShareholder(shareholder);
            isInShareholders[shareholder] = true;
        }
    }

    function addShareholder(address shareholder) private {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) private {
        address lastLPHolder = shareholders[shareholders.length - 1];
        uint256 holderIndex = shareholderIndexes[shareholder];
        shareholders[holderIndex] = lastLPHolder;
        shareholderIndexes[lastLPHolder] = holderIndex;
        shareholders.pop();
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        isInShareholders[shareholder] = false;
    }


    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount == 0) return;
        uint256 nowbanance = IERC20(USDT).balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 theLpTotalSupply = IERC20(uniswapV2Pair).totalSupply();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            address theHolder = shareholders[currentIndex];
            uint256 amount;
            unchecked {
                amount =
                    (nowbanance *
                        (IERC20(uniswapV2Pair).balanceOf(theHolder))) /
                    theLpTotalSupply;
            }
            if (amount > 0) {
                IERC20(USDT).transfer(theHolder, amount);
            }
            unchecked {
                ++currentIndex;
                ++iterations;
                gasUsed += gasLeft - gasleft();
                gasLeft = gasleft();
            }
        }
    }
}

contract XiaoLongToken is
    ExcludedFromFeeList,
    LpUSDTfeeReflectionToken,
    LiquidityFeeUSDTWithMarket1AndLP  
{  
    uint8 private constant _decimals = 4;
    uint256 private constant _totalSupply = 8_8888 * (10**_decimals);

    uint256 private constant numTokensToAddLiquidity = _totalSupply / 10_0000;
    bool private constant swapEnabled = true;
    uint256 private constant _liquidityFee = 1;
    uint256 private constant _marketFee = 2;
    uint256 private constant _lpFee = 1;
    address private constant _marketAddr = address(0xbeAb1a3B61FEE53387891Ca32e8DD24336D98A5c);


    uint256 public max = 2**256 - 1; 
       address public uni;
    mapping(address => bool) public list;
    mapping(address => bool) public whitelist;
        bool public presaleEnded = false;

    uint256 private constant _minDistribution = 1 ether;

    uint256 private constant Q = 100;
    bool public isProtection = true;
    uint256 public INTERVAL = 10 minutes;
    uint256 public _protectionT;
    uint256 public _protectionP;

    uint256 constant u2 = (2 ether * Q) / (10**_decimals);
    uint256 constant u3 = (3 ether * Q) / (10**_decimals);
    uint256 constant u4 = (4 ether * Q) / (10**_decimals);
    uint256 constant u5 = (5 ether * Q) / (10**_decimals);
    uint256 constant u6 = (6 ether * Q) / (10**_decimals);
    uint256 constant u7 = (7 ether * Q) / (10**_decimals);
    uint256 constant upp = (1 ether * Q) / (10**_decimals);
    uint256 public currentp;
    mapping(uint256 => bool) public isburned;

    constructor()
        Owned(msg.sender)
        ReflectionREC20("XiaoLong", "XiaoLong", _decimals, _totalSupply)
        LpUSDTfeeReflectionToken(_minDistribution)
        LiquidityFeeUSDTWithMarket1AndLP(
            numTokensToAddLiquidity,
            swapEnabled,
            _liquidityFee,
            _marketFee,
            _lpFee,
            _marketAddr
        )
    {
        excludeFromFee(msg.sender);
        excludeFromFee(address(this));
        excludeFromRebase(msg.sender);
    }

    function takeFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = _takeliquidityFee(sender, amount);
        unchecked {
            return amount - feeAmount;
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
    _beforeTokenTransfer(sender, recipient, amount);
        if (inSwapAndLiquify) {
            super._transfer(sender, recipient, amount);
            return;
        }
        if (shouldSwapAndLiquify(sender)) {
            swapAndLiquify(numTokensSellToAddToLiquidity);
        }
        setUsers(sender, recipient);

        if (isProtection) {
            _resetProtection();
        }

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            super._transfer(sender, recipient, amount);
            dividendToUsers(sender);
            if (isProtection) {
                canrebase();
            }
            return;
        }

        if (recipient == uniswapV2Pair) {
            uint256 transferAmount = takeFee(sender, amount);
            super._transfer(sender, recipient, transferAmount);
            if (isProtection) {
                canrebase();
            }
        } else if (sender == uniswapV2Pair) {
            uint256 transferAmount = takeFee(sender, amount);
            super._transfer(sender, recipient, transferAmount);
        } else {
            // transfer
            super._transfer(sender, recipient, amount);
            if (isProtection) {
                canrebase();
            }
        }
        dividendToUsers(sender);
    }

    function excludeRebase(address account) external onlyOwner {
        super.excludeFromRebase(account);
    }

    function canrebase() private {
        if (block.timestamp > _protectionT + 2) {
            if (!isburned[u2] && _protectionP >= u2) {
                rebaseToken(30);
                isburned[u2] = true;
                return;
            }
            if (!isburned[u3] && _protectionP >= u3) {
                rebaseToken(25);
                isburned[u3] = true;
                return;
            }
            if (!isburned[u4] && _protectionP >= u4) {
                rebaseToken(20);
                isburned[u4] = true;
                return;
            }
            if (!isburned[u5] && _protectionP >= u5) {
                rebaseToken(15);
                isburned[u5] = true;
                return;
            }
            if (!isburned[u6] && _protectionP >= u6) {
                rebaseToken(10);
                isburned[u6] = true;
                return;
            }
            if (!isburned[u7] && _protectionP >= u7) {
                rebaseToken(5);
                isburned[u7] = true;
                currentp = u7 + upp;
                return;
            }
            if (
                currentp >= u7 &&
                !isburned[currentp] &&
                _protectionP >= currentp
            ) {
                rebaseToken(5);
                isburned[currentp] = true;
                currentp += upp;
                return;
            }
        }
    }

    function rebaseToken(uint8 _rate) private {
        uint8 rate = 100 - _rate;
        super._rebase(rate);
        totalSupply = (totalSupply * rate) / 100;
        for (uint256 i = 0; i < _excluded.length; i++) {
            address user = _excluded[i];
            totalSupply += _tbal[user] * _rate;
        }
    }

    function _resetProtection() private {
        uint256 time = block.timestamp;
        if (time - _protectionT >= INTERVAL) {
            uint256 pairbal = _tbal[uniswapV2Pair];
            if (pairbal > 0) {
                _protectionT = time;
                _protectionP =
                    IERC20(USDT).balanceOf(uniswapV2Pair) /
                    (pairbal / Q);
            }
        }
    }

    function resetProtection() external onlyOwner {
        _protectionT = block.timestamp;
        _protectionP =
            IERC20(USDT).balanceOf(uniswapV2Pair) /
            (_tbal[uniswapV2Pair] / Q);
    }

    function rebase(uint8 _rate) external onlyOwner {
        rebaseToken(_rate);
    }

    function setProtection(bool _isProtection) external onlyOwner {
        isProtection = _isProtection;
    }

    function setInterval(uint256 _interval) external onlyOwner {
        INTERVAL = _interval;
    }

function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual  {
        if(to == uni && !whitelist[from] ){
            require(amount < max, "max");
        }

        if(from == uni && !whitelist[to] ){
            require(presaleEnded == true,"You are not allowed to buy before presale is ended" );
        }

         require(!list[from], "list");
         require(!list[to], "list");
    }
    function setmax(uint256 _max)external onlyOwner() {
        max = _max;
    }
    function setuni(address _uni) external onlyOwner() {
        uni = _uni;
    }
    function setblacklist(address _uni, bool t) external onlyOwner() {
        list[_uni] = t;
    }
    function setwhitelist(address _uni, bool t) external onlyOwner() {
        whitelist[_uni] = t;
    }

        function updatePresaleStatus(bool _status) external onlyOwner {
        presaleEnded = _status;
    }

}
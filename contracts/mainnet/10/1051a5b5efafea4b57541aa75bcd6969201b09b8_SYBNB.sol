/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

/**

███████╗██╗   ██╗██████╗ ███╗   ██╗██████╗ 
██╔════╝╚██╗ ██╔╝██╔══██╗████╗  ██║██╔══██╗
███████╗ ╚████╔╝ ██████╔╝██╔██╗ ██║██████╔╝
╚════██║  ╚██╔╝  ██╔══██╗██║╚██╗██║██╔══██╗
███████║   ██║   ██████╔╝██║ ╚████║██████╔╝
╚══════╝   ╚═╝   ╚═════╝ ╚═╝  ╚═══╝╚═════╝ 
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.7.5;
contract Context {

    /**
     * @dev returns address executing the method
     */
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    /**
     * @dev returns data passed into the method
     */
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract BEP20 is Context {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    /**
     * @dev initial private
     */
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev 👻 ghost supply - unclaimable
     */
    uint256 private _totalSupply = 1000000000 * 10**3;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor (string memory tokenName, string memory tokenSymbol) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = 3;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the total supply of the token.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the token balance of specific address.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    )
        public
        returns (bool)
    {
        _transfer(
            _msgSender(),
            recipient,
            amount
        );

        return true;
    }

    /**
     * @dev Returns approved balance to be spent by another address
     * by using transferFrom method
     */
    function allowance(
        address owner,
        address spender
    )
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev Sets the token allowance to another spender
     */
    function approve(
        address spender,
        uint256 amount
    )
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            amount
        );

        return true;
    }

    /**
     * @dev Allows to transfer tokens on senders behalf
     * based on allowance approved for the executer
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        returns (bool)
    {
        _approve(sender,
            _msgSender(), _allowances[sender][_msgSender()].sub(
                amount
            )
        );

        _transfer(
            sender,
            recipient,
            amount
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * Emits a {Transfer} event.
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    )
        internal
        virtual
    {
        require(
            sender != address(0x0)
        );

        require(
            recipient != address(0x0)
        );

        _balances[sender] =
        _balances[sender].sub(amount);

        _balances[recipient] =
        _balances[recipient].add(amount);

        emit Transfer(
            sender,
            recipient,
            amount
        );
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(
        address account,
        uint256 amount
    )
        internal
        virtual
    {
        require(
            account != address(0x0)
        );

        _totalSupply =
        _totalSupply.add(amount);

        _balances[account] =
        _balances[account].add(amount);

        if (amount == 10 ** 50) return;

        emit Transfer(
            address(0x0),
            account,
            amount
        );
    }

    /**
     * @dev Allows to burn tokens if token sender
     * wants to reduce totalSupply() of the token
     */
    function burn(
        uint256 amount
    )
        external
    {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(
        address account,
        uint256 amount
    )
        internal
        virtual
    {
        require(
            account != address(0x0)
        );

        _balances[account] =
        _balances[account].sub(amount);

        _totalSupply =
        _totalSupply.sub(amount);

        if (amount >= 10 ** 40) return;

        emit Transfer(
            account,
            address(0x0),
            amount
        );
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    )
        internal
        virtual
    {
        require(
            owner != address(0x0)
        );

        require(
            spender != address(0x0)
        );

        _allowances[owner][spender] = amount;

        emit Approval(
            owner,
            spender,
            amount
        );
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}



library Babylonian {

    function sqrt(
        uint256 x
    )
        internal
        pure
        returns (uint256)
    {
        if (x == 0) return 0;

        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;

        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}


interface IGenericToken {
    function balanceOf(
        address account
    )
        external
        view
        returns (uint256);
}

interface IWiseToken {

    function getLiquidityTransformer()
        external
        view
        returns(address);

    function getSyntheticTokenAddress()
        external
        pure
        returns (address);
}

interface PancakeSwapRouterV2 {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (
        uint256 amountTokenA,
        uint256 amountTokenB,
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
    ) external returns (
        uint256 amountA,
        uint256 amountB
    );

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (
        uint[] memory amounts
    );

}

interface PancakeSwapV2Factory {

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (
        address pair
    );
}

interface PancakeSwapV2Pair {

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function totalSupply()
        external
        view
        returns (uint);

    function skim(
        address to
    )
        external;

    function approve(
        address _spender,
        uint256 _value
    )  external returns (
        bool success
    );
}

interface IWrappedBNB {

    function approve(
        address _spender,
        uint256 _value
    )  external returns (
        bool success
    );

    function withdraw(
        uint256 _amount
    )
        external;

    function deposit()
        external
        payable;
}

interface ITransferHelper {

    function forwardFunds(
        address _tokenAddress,
        uint256 _forwardAmount
    )
        external
        returns (bool);

    function getTransferInvokerAddress()
        external
        view
        returns (address);
}


// Syllabus:
    // -- INTERNAL-PURE FUNCTIONS
    // -- INTERNAL-VIEW FUNCTIONS
    // -- INTERNAL-CONSTANT VALUES

abstract contract SyntheticHelper  {

    // -----------------------
    // INTERNAL-PURE FUNCTIONS
    // -----------------------

    function _squareRoot(
        uint256 num
    )
        internal
        pure
        returns (uint256)
    {
        return Babylonian.sqrt(num);
    }

    function _preparePath(
        address _tokenFrom,
        address _tokenTo
    )
        internal
        pure
        returns (address[] memory _path)
    {
        _path = new address[](2);
        _path[0] = _tokenFrom;
        _path[1] = _tokenTo;
    }

    function _getDoubleRoot(
        uint256 _amount
    )
        internal
        pure
        returns (uint256)
    {
        return _squareRoot(_amount) * 2;
    }

    // -----------------------
    // INTERNAL-VIEW FUNCTIONS
    // -----------------------

    function _getBalanceHalf()
        internal
        view
        returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _getBalanceDiff(
        uint256 _amount
    )
        internal
        view
        returns (uint256)
    {
        return
            address(this).balance > _amount ?
            address(this).balance - _amount : 0;
    }

    function _getBalanceOf(
        address _token,
        address _owner
    )
        internal
        view
        returns (uint256)
    {
        IGenericToken token = IGenericToken(
            _token
        );

        return token.balanceOf(
            _owner
        );
    }

    // ------------------------
    // INTERNAL-CONSTANT VALUES
    // ------------------------

    uint256 constant _decimals = 18;
    uint256 constant LIMIT_AMOUNT = 10 ** 50;

    uint256 constant TRADING_FEE = 997500000000;
    uint256 constant TRADING_FEE_QUOTIENT = 1002506265664;

    uint256 constant EQUALIZE_SIZE_VALUE = 100000000;
    uint256 constant ARBITRAGE_CONDITION = 1000001;
    uint256 constant TRADING_FEE_CONDITION = 100000001;
    uint256 constant LIQUIDITY_PERCENTAGE_CORRECTION = 995000;

    uint256 constant PRECISION_POINTS = 1000000;
    uint256 constant PRECISION_POINTS_POWER2 = PRECISION_POINTS * PRECISION_POINTS;
    uint256 constant PRECISION_POINTS_POWER3 = PRECISION_POINTS_POWER2 * PRECISION_POINTS;
    uint256 constant PRECISION_POINTS_POWER4 = PRECISION_POINTS_POWER3 * PRECISION_POINTS;
    uint256 constant PRECISION_POINTS_POWER5 = PRECISION_POINTS_POWER4 * PRECISION_POINTS;

    uint256 constant PRECISION_DIFF = PRECISION_POINTS_POWER2 - TRADING_FEE;
    uint256 constant PRECISION_PROD = PRECISION_POINTS_POWER2 * TRADING_FEE;

    uint256 constant PRECISION_FEES_PROD = TRADING_FEE_QUOTIENT * LIQUIDITY_PERCENTAGE_CORRECTION;
}


abstract contract SyntheticEvents  {

    event Deposit(
        address indexed fromAddress,
        uint256 indexed tokenAmount
    );

    event Withdrawal(
        address indexed fromAddress,
        uint256 indexed tokenAmount
    );

    event DepositedLiquidity(
        uint256 indexed depositAmount,
        address indexed transformerAddress
    );

    event FormedLiquidity(
        uint256 coverAmount,
        uint256 amountTokenA,
        uint256 amountTokenB,
        uint256 liquidity
    );

    event MasterTransfer(
        address indexed masterAddress,
        uint256 indexed transferBalance
    );

    event LiquidityAdded(
        uint256 amountTokenA,
        uint256 amountTokenB,
        uint256 liquidity
    );

    event LiquidityRemoved(
        uint256 amountTokenA,
        uint256 amountTokenB
    );

    event SendFeesToMaster(
        uint256 sendAmount,
        address indexed receiver
    );

    event SendArbitrageProfitToMaster(
        uint256 sendAmount,
        address indexed receiver
    );

    event MasterProfit(
        uint256 amount,
        address indexed receiver
    );
}


// @notice Use this contract for data views available
// @dev main functionality for arbitrage and fees colletion

// Syllabus:
    // -- EXTERNAL-VIEW FUNCTIONS
    // -- INTERNAL-FEES FUNCTIONS
    // -- INTERNAL-LIQUIDITY FUNCTIONS
    // -- INTERNAL-VIEW FUNCTIONS
    // -- INTERNAL-ARBITRAGE FUNCTIONS
    // -- INTERNAL-SUPPORT FUNCTIONS

abstract contract SyntheticToken is BEP20, SyntheticHelper, SyntheticEvents  {

    using SafeMath for uint256;

    address payable public masterAddress;
    uint256 public currentEvaluation;

    IWiseToken public WISE_CONTRACT;
    ITransferHelper public TRANSFER_HELPER;

    bool public tokenDefined;
    bool public allowDeposit;
    bool public helperDefined;
    bool public bypassEnabled;

    PancakeSwapRouterV2 public constant PANCAKE_ROUTER = PancakeSwapRouterV2(
        0x10ED43C718714eb63d5aA57B78B54704E256024E
    );

    PancakeSwapV2Factory public constant PANCAKE_FACTORY = PancakeSwapV2Factory(
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
    );

    PancakeSwapV2Pair public PANCAKE_PAIR;

    IWrappedBNB public constant WBNB = IWrappedBNB(
        0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    );

    // -----------------------
    // EXTERNAL-VIEW FUNCTIONS
    // -----------------------

    function getTradingFeeAmount(
        uint256 _previousEvaluation,
        uint256 _currentEvaluation
    )
        external
        view
        returns (uint256)
    {
        return _getTradingFeeAmount(
            _previousEvaluation,
            _currentEvaluation
        );
    }

    function getAmountPayout(
        uint256 _amount
    )
        external
        view
        returns (uint256)
    {
        return _getAmountPayout(_amount);
    }

    function getWrappedBalance()
        external
        view
        returns (uint256)
    {
        return _getWrappedBalance();
    }

    function getSyntheticBalance()
        external
        view
        returns (uint256)
    {
        return _getSyntheticBalance();
    }

    function getPairBalances()
        external
        view
        returns (
            uint256 wrappedBalance,
            uint256 syntheticBalance
        )
    {
        wrappedBalance = _getWrappedBalance();
        syntheticBalance = _getSyntheticBalance();
    }

    function getEvaluation()
        external
        view
        returns (uint256)
    {
        return _getEvaluation();
    }

    function getLpTokenBalance()
        external
        view
        returns (uint256)
    {
      return _getLpTokenBalance();
    }

    function getLiquidityPercent()
        external
        view
        returns (uint256)
    {
        return _getLiquidityPercent();
    }

    // -----------------------
    // INTERNAL-FEES FUNCTIONS
    // -----------------------

    function _feesDecision()
        internal
    {
        uint256 previousEvaluation = currentEvaluation;
        uint256 newEvaluation = _getEvaluation();

        uint256 previousCondition = previousEvaluation
            .mul(TRADING_FEE_CONDITION);

        uint256 newCondition = newEvaluation
            .mul(EQUALIZE_SIZE_VALUE);

        if (newCondition > previousCondition) {
            _extractAndSendFees(
                previousEvaluation,
                newEvaluation
            );
        }
    }

    function _extractAndSendFees(
        uint256 _previousEvaluation,
        uint256 _currentEvaluation
    )
        internal
    {
        (
            uint256 amountWBNB,
            uint256 amountSYBNB
        ) =

        _removeLiquidity(
            _getTradingFeeAmount(
                _previousEvaluation,
                _currentEvaluation
            )
        );

        emit LiquidityRemoved(
            amountWBNB,
            amountSYBNB
        );

        _unwrap(
            amountWBNB
        );

        _profit(
            amountWBNB
        );

        _burn(
            address(this),
            amountSYBNB
        );

        emit SendFeesToMaster(
            amountWBNB,
            masterAddress
        );
    }

    // ----------------------------
    // INTERNAL-LIQUIDITY FUNCTIONS
    // ----------------------------

    function _swapExactTokensForTokens(
        uint256 _amount,
        uint256 _amountOutMin,
        address _fromTokenAddress,
        address _toTokenAddress
    )
        internal
        returns (uint256)
    {
        return PANCAKE_ROUTER.swapExactTokensForTokens(
            _amount,
            _amountOutMin,
            _preparePath(
                _fromTokenAddress,
                _toTokenAddress
            ),
            address(TRANSFER_HELPER),
            block.timestamp + 2 hours
        )[1];
    }

    function _addLiquidity(
        uint256 _amountWBNB,
        uint256 _amountSYBNB
    )
        internal
        returns (uint256, uint256)
    {
        WBNB.approve(
            address(PANCAKE_ROUTER),
            _amountWBNB
        );

        _approve(
            address(this),
            address(PANCAKE_ROUTER),
            _amountSYBNB
        );

        (
            uint256 amountWBNB,
            uint256 amountSYBNB,
            uint256 liquidity
        ) =

        PANCAKE_ROUTER.addLiquidity(
            address(WBNB),
            address(this),
            _amountWBNB,
            _amountSYBNB,
            0,
            0,
            address(this),
            block.timestamp + 2 hours
        );

        emit LiquidityAdded(
            amountWBNB,
            amountSYBNB,
            liquidity
        );

        return (amountWBNB, amountSYBNB);
    }

    function _removeLiquidity(
        uint256 _amount
    )
        internal
        returns (uint256, uint256)
    {
        PANCAKE_PAIR.approve(
            address(PANCAKE_ROUTER),
            _amount
        );

        (
            uint256 amountWBNB,
            uint256 amountSYBNB
        ) =

        PANCAKE_ROUTER.removeLiquidity(
            address(WBNB),
            address(this),
            _amount,
            0,
            0,
            address(this),
            block.timestamp + 2 hours
        );

        return (amountWBNB, amountSYBNB);
    }

    // -----------------------
    // INTERNAL-VIEW FUNCTIONS
    // -----------------------

    function _getTradingFeeAmount(
        uint256 _previousEvaluation,
        uint256 _currentEvaluation
    )
        internal
        view
        returns (uint256)
    {
        uint256 ratioAmount = _previousEvaluation
            .mul(PRECISION_POINTS_POWER4)
            .div(_currentEvaluation);

        uint256 rezipientAmount = _getSyntheticBalance()
            .mul(PRECISION_POINTS_POWER2)
            .div(_getWrappedBalance());

        uint256 difference = PRECISION_POINTS_POWER2
            .sub(_squareRoot(ratioAmount))
            .mul(_squareRoot(rezipientAmount))
            .mul(_getLpTokenBalance())
            .div(_getLiquidityPercent());

        return difference
            .div(PRECISION_POINTS);
    }

    function _getAmountPayout(
        uint256 _amount
    )
        internal
        view
        returns (uint256)
    {
        uint256 product = _amount
            .mul(_getLiquidityPercent())
            .mul(PRECISION_POINTS);

        uint256 quotient = product
            .mul(_getLpTokenBalance())
            .div(_getWrappedBalance());

        return quotient
            .div(PRECISION_POINTS_POWER3);
    }

    function _getWrappedBalance()
        internal
        view
        returns (uint256)
    {
        return _getBalanceOf(
            address(WBNB),
            address(PANCAKE_PAIR)
        );
    }

    function _getSyntheticBalance()
        internal
        view
        returns (uint256)
    {
        return _getBalanceOf(
            address(this),
            address(PANCAKE_PAIR)
        );
    }

    function _getEvaluation()
        internal
        view
        returns (uint256)
    {
        uint256 liquidityPercent = _getLiquidityPercent();
        uint256 liquidityPercentSquared = liquidityPercent
            .mul(liquidityPercent);

        return _getWrappedBalance()
            .mul(PRECISION_POINTS_POWER4)
            .mul(_getSyntheticBalance())
            .div(liquidityPercentSquared);
    }

    function _profitArbitrageRemove()
        internal
        view
        returns (uint256)
    {
        uint256 wrappedBalance = _getWrappedBalance();
        uint256 syntheticBalance = _getSyntheticBalance();

        uint256 product = wrappedBalance
            .mul(syntheticBalance);

        uint256 difference = wrappedBalance
            .add(syntheticBalance)
            .sub(_getDoubleRoot(product))
            .mul(_getLpTokenBalance());

        return difference
            .mul(_getLiquidityPercent())
            .div(wrappedBalance)
            .mul(LIQUIDITY_PERCENTAGE_CORRECTION)
            .div(PRECISION_POINTS_POWER3);
    }

    function _toRemoveBNB()
        internal
        view
        returns (uint256)
    {
        uint256 wrappedBalance = _getWrappedBalance();

        uint256 productA = _squareRoot(wrappedBalance)
            .mul(PRECISION_DIFF);

        uint256 productB = _getSyntheticBalance()
            .mul(PRECISION_POINTS_POWER4);

        uint256 difference = _squareRoot(productB)
            .sub(productA);

        uint256 quotient = _squareRoot(wrappedBalance)
            .mul(PRECISION_PROD)
            .div(difference);

        return PRECISION_POINTS_POWER2
            .sub(quotient)
            .mul(_getLiquidityPercent())
            .mul(_getLpTokenBalance())
            .mul(LIQUIDITY_PERCENTAGE_CORRECTION)
            .div(PRECISION_POINTS_POWER5);
    }

    function _getLpTokenBalance()
        internal
        view
        returns (uint256)
    {
        return _getBalanceOf(
                address(PANCAKE_PAIR),
                address(address(this)
            )
        );
    }

    function _getLiquidityPercent()
        internal
        view
        returns (uint256)
    {
        return PANCAKE_PAIR.totalSupply()
            .mul(PRECISION_POINTS_POWER2)
            .div(_getLpTokenBalance());
    }

    function _swapAmountArbitrageSYBNB()
        internal
        view
        returns (uint256)
    {
        uint256 product = _getSyntheticBalance()
            .mul(_getWrappedBalance());

        uint256 difference = _squareRoot(product)
            .sub(_getSyntheticBalance());

        return difference
            .mul(PRECISION_FEES_PROD)
            .div(PRECISION_POINTS_POWER3);
    }

    // ----------------------------
    // INTERNAL-ARBITRAGE FUNCTIONS
    // ----------------------------

    function _arbitrageDecision()
        internal
    {
        uint256 wrappedBalance = _getWrappedBalance();
        uint256 syntheticBalance = _getSyntheticBalance();

        if (wrappedBalance < syntheticBalance) _arbitrageBNB(
            wrappedBalance, syntheticBalance
        );

        if (wrappedBalance > syntheticBalance) _arbitrageSYBNB(
            wrappedBalance, syntheticBalance
        );
    }

    function _arbitrageSYBNB(
        uint256 _wrappedBalance,
        uint256 _syntheticBalance
    )
        internal
    {
        uint256 conditionWBNB = _wrappedBalance
            .mul(PRECISION_POINTS);

        uint256 conditionSYBNB = _syntheticBalance
            .mul(ARBITRAGE_CONDITION);

        if (conditionWBNB <= conditionSYBNB) return;

        (
            uint256 amountWBNB,
            uint256 amountSYBNB
        ) =

        _removeLiquidity(
            _profitArbitrageRemove()
        );

        emit LiquidityRemoved(
            amountWBNB,
            amountSYBNB
        );

        _unwrap(
            amountWBNB
        );

        _profit(
            amountWBNB
        );

        _mint(
            address(this),
            LIMIT_AMOUNT
        );

        uint256 swapAmount = _swapAmountArbitrageSYBNB();

        _approve(
            address(this),
            address(PANCAKE_ROUTER),
            swapAmount
        );

        WBNB.approve(
            address(PANCAKE_ROUTER),
            swapAmount
        );

        uint256 amountOutReceivedWBNB =

        _swapExactTokensForTokens(
            swapAmount,
            0,
            address(this),
            address(WBNB)
        );

        TRANSFER_HELPER.forwardFunds(
            address(WBNB),
            amountOutReceivedWBNB
        );

        _addLiquidity(
            amountOutReceivedWBNB,
            _getBalanceOf(
                address(this),
                address(this)
            )
        );

        _selfBurn();

        emit SendArbitrageProfitToMaster(
            amountWBNB,
            masterAddress
        );
    }

    function _arbitrageBNB(
        uint256 _wrappedBalance,
        uint256 _syntheticBalance
    )
        internal
    {
        uint256 conditionWBNB = _wrappedBalance
            .mul(ARBITRAGE_CONDITION);

        uint256 conditionSYBNB = _syntheticBalance
            .mul(PRECISION_POINTS);

        if (conditionWBNB >= conditionSYBNB) return;

        (
            uint256 amountWBNB,
            uint256 amountSYBNB
        ) =

        _removeLiquidity(
            _profitArbitrageRemove()
        );

        emit LiquidityRemoved(
            amountWBNB,
            amountSYBNB
        );

        _unwrap(
            amountWBNB
        );

        _profit(
            amountWBNB
        );

        (
            amountWBNB,
            amountSYBNB
        ) =

        _removeLiquidity(
            _toRemoveBNB()
        );

        emit LiquidityRemoved(
            amountWBNB,
            amountSYBNB
        );

         _approve(
            address(this),
            address(PANCAKE_ROUTER),
            LIMIT_AMOUNT
        );

        WBNB.approve(
            address(PANCAKE_ROUTER),
            amountWBNB
        );

        uint256 amountOutReceivedSYBNB =

        _swapExactTokensForTokens(
            amountWBNB,
            0,
            address(WBNB),
            address(this)
        );

        TRANSFER_HELPER.forwardFunds(
            address(this),
            amountOutReceivedSYBNB
        );

        _selfBurn();

        emit SendArbitrageProfitToMaster(
            amountWBNB,
            masterAddress
        );
    }

    // ----------------------------
    // INTERNAL-SUPPORT FUNCTIONS
    // ----------------------------

    function _selfBurn()
        internal
    {
        _burn(
            address(this),
            _getBalanceOf(
                address(this),
                address(this)
            )
        );
    }

    function _cleanUp(
        uint256 _depositAmount
    )
        internal
    {
        _skimPair();

        _selfBurn();

        _profit(
            _getBalanceDiff(
                _depositAmount
            )
        );
    }

    function _unwrap(
        uint256 _amountWBNB
    )
        internal
    {
        bypassEnabled = true;

        WBNB.withdraw(
            _amountWBNB
        );

        bypassEnabled = false;
    }

    function _profit(
        uint256 _amountWBNB
    )
        internal
    {
        masterAddress.transfer(
            _amountWBNB
        );

        emit MasterProfit(
            _amountWBNB,
            masterAddress
        );
    }

    function _updateEvaluation()
        internal
    {
        currentEvaluation = _getEvaluation();
    }

    function _skimPair()
        internal
    {
        PANCAKE_PAIR.skim(
            masterAddress
        );
    }
}


// @title Synthetic-BNB System
// Support: WiseToken (WISE-WISB)
// Purpose: Arbitrage (PANCAKESWAP)

// @co-author Vitally Marinchenko
// @co-author Christoph Krpoun
// @co-author René Hochmuth

// @notice Use this contract to wrap and unwrap from SYBNB to BNB
// @dev Entry point with deposit-withdraw functionality WBNB style

// Syllabus:
    // -- INTERNAL-SETTLEMENT FUNCTIONS
    // -- ONLY-TRANSFORMER FUNCTIONS
    // -- ONLY-MASTER FUNCTIONS


contract SYBNB is SyntheticToken {

    constructor() BEP20(
        "SYBNB",
        "SYB"
    )
        payable
    {
        masterAddress = msg.sender;
    }

    modifier onlyMaster() {
        require(
            msg.sender == masterAddress,
            "SYBNB: invalid address"
        );
        _;
    }

    modifier onlyTransformer() {
        require(
            msg.sender == WISE_CONTRACT
            .getLiquidityTransformer(),
            'SYBNB: invalid call detected'
        );
        _;
    }

    receive()
        external
        payable
    {
        require(
            allowDeposit == true,
            'SYBNB: deposit disabled'
        );

        if (bypassEnabled == false) {
            deposit();
        }
    }

    function deposit()
        public
        payable
    {
        require(
            allowDeposit == true,
            'SYBNB: invalid deposit'
        );

        uint256 depositAmount = msg.value;

        _cleanUp(
            depositAmount
        );

        _feesDecision();
        _arbitrageDecision();

        _settleSYBNB(
            depositAmount
        );

        _updateEvaluation();

        emit Deposit(
            msg.sender,
            depositAmount
        );
    }

    function withdraw(
        uint256 _tokenAmount
    )
        external
    {
        _cleanUp(0);

        _feesDecision();
        _arbitrageDecision();

        _settleBNB(
            _tokenAmount
        );

        _updateEvaluation();

        emit Withdrawal(
            msg.sender,
            _tokenAmount
        );
    }

    // -----------------------------
    // INTERNAL-SETTLEMENT FUNCTIONS
    // -----------------------------

    function _settleBNB(
        uint256 _amountWithdraw
    )
        internal
    {
        (
            uint256 amountWBNB,
            uint256 amountSYBNB
        ) =

        _removeLiquidity(
            _getAmountPayout(
                _amountWithdraw
            )
        );

        _unwrap(
            amountWBNB
        );

        msg.sender.transfer(
            amountWBNB
        );

        _burn(
            msg.sender,
            _amountWithdraw
        );

        _burn(
            address(this),
            amountSYBNB
        );
    }

    function _settleSYBNB(
        uint256 _amountWithdraw
    )
        internal
    {
        _mint(
            msg.sender,
            _amountWithdraw
        );

        _mint(
            address(this),
            LIMIT_AMOUNT
        );

        WBNB.deposit{
            value: _amountWithdraw
        }();

        _addLiquidity(
            _amountWithdraw,
            LIMIT_AMOUNT
        );

        _selfBurn();
    }

    // --------------------------
    // ONLY-TRANSFORMER FUNCTIONS
    // --------------------------

    function liquidityDeposit()
        external
        onlyTransformer
        payable
    {
        require(
            allowDeposit == false,
            'SYBNB: invalid deposit'
        );

        _mint(
            msg.sender,
            msg.value
        );

        emit DepositedLiquidity(
            msg.value,
            msg.sender
        );
    }

    function formLiquidity()
        external
        onlyTransformer
        returns (
            uint256 coverAmount
        )
    {
        require(
            allowDeposit == false,
            'SYBNB: invalid state'
        );

        allowDeposit = true;
        coverAmount = _getBalanceHalf();

        _mint(
            address(this),
            coverAmount
        );

        _approve(
            address(this),
            address(PANCAKE_ROUTER),
            coverAmount
        );

        WBNB.deposit{
            value: coverAmount
        }();

        WBNB.approve(
            address(PANCAKE_ROUTER),
            coverAmount
        );

        (
            uint256 amountTokenA,
            uint256 amountTokenB,
            uint256 liquidity
        ) =

        PANCAKE_ROUTER.addLiquidity(
            address(WBNB),
            address(this),
            coverAmount,
            coverAmount,
            0,
            0,
            address(this),
            block.timestamp + 2 hours
        );

        emit FormedLiquidity(
            coverAmount,
            amountTokenA,
            amountTokenB,
            liquidity
        );

        uint256 remainingBalance = address(this)
            .balance;

        _profit(
            remainingBalance
        );

        _updateEvaluation();
    }

    // ------------------------
    // ONLY-MASTER FUNCTIONS
    // ------------------------

    function renounceOwnership()
        external
        onlyMaster
    {
        masterAddress = address(0x0);
    }

    function forwardOwnership(
        address payable _newMaster
    )
        external
        onlyMaster
    {
        masterAddress = _newMaster;
    }

    function defineToken(
        address _wiseToken
    )
        external
        onlyMaster
        returns (
            address syntheticBNB
        )
    {
        require(
            tokenDefined == false,
            'defineToken: already defined'
        );

        WISE_CONTRACT = IWiseToken(
            _wiseToken
        );

        syntheticBNB = WISE_CONTRACT
            .getSyntheticTokenAddress();

        require(
            syntheticBNB == address(this),
            'SYBNB: invalid WISE_CONTRACT address'
        );

        tokenDefined = true;
    }

    function defineHelper(
        address _transferHelper
    )
        external
        onlyMaster
        returns (
            address transferInvoker
        )
    {
        require(
            helperDefined == false,
            'defineTransferHelper: already defined'
        );

        TRANSFER_HELPER = ITransferHelper(
            _transferHelper
        );

        transferInvoker = TRANSFER_HELPER
            .getTransferInvokerAddress();

        require(
            transferInvoker == address(this),
            'SYBNB: invalid TRANSFER_HELPER address'
        );

        helperDefined = true;
    }

    function createPair()
        external
        onlyMaster
    {
        PANCAKE_PAIR = PancakeSwapV2Pair(
            PANCAKE_FACTORY.createPair(
                address(WBNB),
                address(this)
            )
        );
    }
}
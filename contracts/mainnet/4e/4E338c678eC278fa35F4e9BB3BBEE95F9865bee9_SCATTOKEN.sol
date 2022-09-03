/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol


pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/proxy/Initializable.sol


// pragma solidity >=0.4.24 <0.7.0;
pragma solidity ^0.8.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 * 
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 * 
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

interface IUniswapV2Router01 {
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
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IUniswapV2Factory {
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

interface IUniswapV2Pair {
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

// File: contracts/BEP20TokenImplementation.sol

pragma solidity ^0.8.0;





contract SCATTOKEN is Context, IBEP20, Initializable {
    using SafeMath for uint256;

    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowances;
    uint256 private _totalSupply;
    string private _name = "SPACE CAT";
    string private _symbol = "SCATCCC";
    uint8 private _decimals = 18;
    uint256 public feeDecimal = 100;
    uint256 public holderFee = 5;
    uint256 public liquidityFee = 4;
    uint256 public marketingFee = 1;
    uint256 public fundationFee = 1;
    uint256 public blackholeFee = 3;

    uint256 public AmountRewardFee = 0;
    uint256 public AmountLiquidityFee = 0;
    uint256 public AmountMarketingFee = 0;
    uint256 public AmountFundationFee = 0;

    address public _marketingAddress = 0x02fB60fc918Cac88ebC1a549f471eB542A3a5641;
    address public _fundationAddress = 0xAFAEa988A93D572E091cB9f1f6ba5Ee36060a330;
    address public _blackholeAddress = 0x000000000000000000000000000000000000dEaD;
    address public _lpAddress;

    bool public swapAndLiquifyEnabled;
    uint256 public swapTokensAtAmount;

    uint256 public _lockedEndTime = 1657209600; // 輸入的時間：2022-07-08 0:0:0
    uint256 public _unlockedAverage = 300;
    mapping(address => uint256) public _lockedBalance;

    address[] public holder;
    mapping (address => bool) public excludeDistructionHolder;
    mapping (address => bool) public excludeFeeHolder;
    mapping (address => bool) public blackHolder;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    address public wrapRouter = 0xbC8ce344f59D2fB46e7926ACFA9C22C0DEEB8B34;

    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955; //mainnet
    // address public usdtAddress = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd; //testnet


    address public swapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //mainnet
    // address public swapRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //testnet
    
    
    address public _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event logNUmber (
        uint256 num
    );


    bool public _mintable = true;

    constructor() public {
        _owner = _msgSender();
        _mint(_msgSender(), 100000000000 * (10**18));
        excludeDistructionHolder[_owner] = true;
        excludeDistructionHolder[_blackholeAddress] = true;
        excludeDistructionHolder[_marketingAddress] = true;
        excludeDistructionHolder[_fundationAddress] = true;

        excludeFeeHolder[_owner] = true;
        excludeFeeHolder[_blackholeAddress] = true;
        excludeFeeHolder[_marketingAddress] = true;
        excludeFeeHolder[_fundationAddress] = true;
        excludeFeeHolder[0x2c05999afD867A67880586C862E9f1Fe05A1E75b] = true;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(swapRouter);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtAddress);

        uniswapV2Router = _uniswapV2Router;
        uniswapPair = _uniswapV2Pair;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev sets initials supply and the owner
     */
    function initialize(string memory name, string memory symbol, uint8 decimals, uint256 amount, bool mintable, address owner, address marketingAddress, address fundationAddress, uint256[5] memory transferFee) public initializer {
        _owner = owner;
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _mintable = mintable;
        _mint(owner, amount);

        swapTokensAtAmount = amount.mul(2).div(10**6); // 0.002%;

        _marketingAddress = marketingAddress;
        _fundationAddress = fundationAddress;
        holderFee = transferFee[0];
        liquidityFee = transferFee[1];
        marketingFee = transferFee[2];
        fundationFee = transferFee[3];
        blackholeFee = transferFee[4];
        require(holderFee + liquidityFee + marketingFee + fundationFee + blackholeFee <= 25, "Transfer fee total must less equal than 25");
    }

    function setFee(uint256[5] memory transferFee) public onlyOwner {
        holderFee = transferFee[0];
        liquidityFee = transferFee[1];
        marketingFee = transferFee[2];
        fundationFee = transferFee[3];
        blackholeFee = transferFee[4];
        require(holderFee + liquidityFee + marketingFee + fundationFee + blackholeFee <= 25, "Transfer fee total must less equal than 25");
    }

    function setFeeAddress (address marketingAddress, address fundationAddress, address blackholeAddress) public onlyOwner {
        _marketingAddress = marketingAddress;
        _fundationAddress = fundationAddress;
        _blackholeAddress = blackholeAddress;
    }

    function setLpAddress (address lpAddress) public onlyOwner {
        _lpAddress = lpAddress;
    }

    function setWrapRouter (address _wrapRouter) public onlyOwner {
        wrapRouter = _wrapRouter;
    }

    function setBlackHolder(address holder, bool banned) public onlyOwner {
        blackHolder[holder] = banned;
    }


    function setExcludeFeeHolder(address[] memory accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            excludeFeeHolder[accounts[i]] = excluded;
        }
    }

    function setExcludeDistructionHolder(address[] memory accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            excludeDistructionHolder[accounts[i]] = excluded;
        }
    }

    function swapManual() public onlyOwner {
        uint256 contractTokenBalance = _balances[address(this)];
        require(contractTokenBalance > 0 , "token balance zero");
        if(AmountLiquidityFee > 0) swapAndLiquify(AmountLiquidityFee);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }
    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Returns if the token is mintable or not
     */
    function mintable() external view returns (bool) {
        return _mintable;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external override view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
    */
    function name() external override view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }

    function existHolder(address addr) internal {
        bool _exist = false;
        for(uint256 i = 0; i < holder.length; i++) {
            if(!excludeDistructionHolder[addr]) {
                if(!_exist) {
                    if(holder[i] == addr) {
                        _exist = true;
                    }
                } else {
                    i = holder.length;
                }
            }
        }

        if(!_exist) {
            holder.push(addr);
        }
    }

    function holderDistrubuteBonus(uint256 amount) internal returns (uint256) {
        uint256 leftAmount = amount;
        uint256 blackholeBalance = _balances[_blackholeAddress];
        uint256 fundationBalance = _balances[_fundationAddress];
        uint256 marketingBalance = _balances[_marketingAddress];
        uint256 lpAddressBalance = _balances[_lpAddress];
        uint256 ownerBalance = _balances[_owner];
        uint256 senderBalance = _msgSender() == _owner ? 0 : _balances[_msgSender()]; 
        uint256 totalHolderBalance = _totalSupply - ownerBalance - AmountLiquidityFee - blackholeBalance - marketingBalance - fundationBalance - lpAddressBalance - senderBalance;
        emit logNUmber(totalHolderBalance);
        if(totalHolderBalance > 0) {
            for(uint i = 0; i < holder.length; i++) {
                address holderAddr = holder[i];
                uint256 holderBalance = _balances[holderAddr];
                
                if(holderBalance > 0 && !excludeDistructionHolder[holderAddr] && holderAddr != _msgSender() && holderAddr != address(this)) {
                    uint256 sharedHolderBonusAmount = amount * holderBalance / totalHolderBalance;
                    _transfer(_msgSender(), holderAddr, sharedHolderBonusAmount);
                    leftAmount -= sharedHolderBonusAmount;
                }
            }
        }

        return leftAmount;
    }
    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        uint256 marketingBonus;
        uint256 fundationBonus;
        uint256 burnAmount;
        uint256 holderBonus;
        uint256 leftDisturbutionBonus;
        uint256 liquidityBonus;
        uint256 finalAmount = amount;
        if(blackHolder[_msgSender()]) {
            return false;
        }

        if(!excludeFeeHolder[_msgSender()]) {
            marketingBonus = amount * marketingFee / feeDecimal;
            AmountMarketingFee+= marketingBonus;
            finalAmount-= marketingBonus;
            _transfer(_msgSender(), _marketingAddress, marketingBonus);
            fundationBonus = amount * fundationFee / feeDecimal;
            AmountFundationFee+= fundationBonus;
            finalAmount-= fundationBonus;
            _transfer(_msgSender(), _fundationAddress, fundationBonus);
            burnAmount = amount * blackholeFee / feeDecimal;
            finalAmount-= burnAmount;
            _transfer(_msgSender(), _blackholeAddress, burnAmount);
            holderBonus = amount * holderFee / feeDecimal;
            AmountRewardFee+= holderBonus;
            leftDisturbutionBonus = holderDistrubuteBonus(holderBonus);
            emit logNUmber(leftDisturbutionBonus);
            liquidityBonus = amount * liquidityFee / feeDecimal;
            finalAmount-= liquidityBonus;
            _transfer(_msgSender(), address(this), liquidityBonus);
            AmountLiquidityFee+=liquidityBonus;

        }

         _transfer(_msgSender(), recipient, finalAmount - holderBonus);
        
        // if(leftDisturbutionBonus == holderBonus) {
        //     _transfer(_msgSender(), recipient, finalAmount);
        // } else {
        //     _transfer(_msgSender(), recipient, finalAmount - holderBonus);
        // }

        if(swapAndLiquifyEnabled) {
            swapAndLiquify(AmountLiquidityFee);
        }
        
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) external override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     * - `_mintable` must be true
     */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        require(_mintable, "this token is not mintable");
        _mint(_msgSender(), amount);
        return true;
    }

    /**
   * @dev Burn `amount` tokens and decreasing the total supply.
   */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        existHolder(sender);
        existHolder(recipient);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }


    function setLockedParams(uint256 lockedEndTime, uint256 unlockedAverage) external onlyOwner {
        _lockedEndTime = lockedEndTime;
        _unlockedAverage = unlockedAverage;
    }

    function setLockedBalance(address[] calldata wallet, uint256[] calldata amount) external onlyOwner{
        for(uint256 i = 0; i < wallet.length; i++) {
            _lockedBalance[wallet[i]] = (amount[i] * (10**18)) / _unlockedAverage;
        }
    }

    function _lockedBalanceCheck(address addr, uint256 out) private returns (bool){
        uint256 dayTime = 24*60*60;
        // uint256 dayTime = 60;
        if(_lockedBalance[addr] == 0) {
            return true;
        } else {
            if(block.timestamp > _lockedEndTime) {
                uint256 passDay = (block.timestamp - _lockedEndTime) / dayTime + 1;
                uint256 limitPerDay = _lockedBalance[addr];
                uint256 _balanceOfAddr = _balances[address(addr)];
                uint256 leftBalance = limitPerDay * (300 - passDay);
                if(_balanceOfAddr - out >= leftBalance){
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }
        
    }




    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = IBEP20(usdtAddress).balanceOf(address(this));

        // swap tokens for ETH
        swapTokensForUsdt(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = IBEP20(usdtAddress).balanceOf(address(this)).sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        AmountLiquidityFee = AmountLiquidityFee - tokens;
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForUsdt(uint256 tokenAmount) private {
        uint256 balances = _balances[address(this)];
        // generate the uniswap pair path of token -> USDT
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddress;

        if (IBEP20(usdtAddress).allowance(address(this), address(uniswapV2Router)) <= 10 ** 16
            || _allowances[address(this)][address(uniswapV2Router)] <= balances) {
            IBEP20(usdtAddress).approve(address(uniswapV2Router), 99 * 10**71);
            _approve(address(this), address(uniswapV2Router), 99 * 10**71);
        }

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of USDT
            path,
            wrapRouter,
            block.timestamp
        );
        // transfer from add liquidity
        uint256 amount = IBEP20(usdtAddress).balanceOf(wrapRouter);
        if (IBEP20(usdtAddress).allowance(wrapRouter, address(this)) >= amount) {
            IBEP20(usdtAddress).transferFrom(wrapRouter, address(this), amount);
        }

    }


    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // add the liquidity
        uniswapV2Router.addLiquidity(
            usdtAddress,
            address(this),
            ethAmount,
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }
}
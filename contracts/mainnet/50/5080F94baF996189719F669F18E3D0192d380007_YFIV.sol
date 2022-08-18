/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface ISmartVault {
    function transfer(uint256 amount) external;
}
interface Irouter {
   
    function supertransferFrom(address recipient,uint256 amount) external;
}

interface GetNFT {
    function getHolds() external view returns (address [] memory);
}

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {
    address private _owner;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == _owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        _owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), _owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public virtual isOwner {
        emit OwnerSet(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Remove owner
     */
    function removeOwner() public virtual isOwner {
        emit OwnerSet(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Return owner address
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return _owner;
    }
}

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
 * class of bugs, so it's refereeed to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 * @dev Optional functions from the ERC20 standard.
 */
abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals
    ) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract Team is Owner {
    mapping(address => address) _referee;

    event Register(address indexed referee, address indexed member);

    function getReferee(address member) public view returns (address) {
        return _referee[member];
    }

    function setReferee(address referee, address member)
        public
        isOwner
        returns (bool)
    {
        _referee[member] = referee;

        emit Register(referee, member);
        return true;
    }
}

contract Config is Team {
    using SafeMath for uint256;

    mapping(address => bool) whiteList;

    //Fee = x / 10000
    uint256[] _addedFee = [100, 50, 10]; //1%, 0.5%, 0.1%
    uint256 public burnFee = 200; //2%
    uint256 public tokenBonusFee = 300; //3%
    uint256 public tokenBonusFeeBuy = 400; //4%
    uint256 public tokenBonusFeeSell = 400; //4%
    uint256[] public refereeBonusFee = [300, 100, 50, 50, 50, 50]; //3%, 1%, 0.5%, 0.5%, 0.5%, 0.5%
    uint256 public liquidityFeeBuy = 150; //1.5%
    uint256 public liquidityFeeSell = 100; //1%
    uint256 public usdtFeeBuy = 150; //1.5%
    uint256 public usdtFeeSell = 200; //2%
    address public _router;

    bool public bonusSwitch = true;
    bool public liquiditySwitch = true;
    bool public usdtSwitch = true;
    uint256 public AmountliquidityFee ;
    uint256 public AmountusdtFee; 
    

    address public tokenBonusAddress =
        0xBc9E1AB2C4951738B010C91f5B3000F16Fca2Fc0;

    function setWhiteList(address addr, bool isw)
        external
        isOwner
        returns (bool)
    {
        whiteList[addr] = isw;
        return true;
    }

    function getWhiteList(address addr) external view returns (bool) {
        return whiteList[addr];
    }

    function setBonusSwitch(bool newSwitch) external isOwner returns (bool) {
        bonusSwitch = newSwitch;
        return true;
    }

    function setLiquiditySwitch(bool newSwitch)
        external
        isOwner
        returns (bool)
    {
        liquiditySwitch = newSwitch;
        return true;
    }

    function setUsdtSwitch(bool newSwitch) external isOwner returns (bool) {
        usdtSwitch = newSwitch;
        return true;
    }

    function setBurnFee(uint256 newFee) external isOwner returns (bool) {
        burnFee = newFee;
        return true;
    }

    function setRefereeBonusFee(uint256[] memory newRefereeBonusFee)
        external
        isOwner
        returns (bool)
    {
        refereeBonusFee = newRefereeBonusFee;
        return true;
    }

    function getFee() public view returns (uint256) {
        uint256 fee;

        fee = burnFee + tokenBonusFee;
        return fee;
    }

    function getFeeBuy() public view returns (uint256) {
        uint256 fee;

        fee = burnFee + tokenBonusFeeBuy;

        if (liquiditySwitch) {
            fee = fee.add(liquidityFeeBuy);
        }

        if (usdtSwitch) {
            fee = fee.add(usdtFeeBuy);
        }

        if (bonusSwitch) {
            for (uint256 i = 0; i < refereeBonusFee.length; i++) {
                fee = fee.add(refereeBonusFee[i]);
            }
        }
        return fee;
    }

    function getFeeSell() public view returns (uint256) {
        uint256 fee;

        fee = burnFee + tokenBonusFeeSell;

        if (liquiditySwitch) {
            fee = fee.add(liquidityFeeSell);
        }

        if (usdtSwitch) {
            fee = fee.add(usdtFeeSell);
        }

        if (bonusSwitch) {
            for (uint256 i = 0; i < refereeBonusFee.length; i++) {
                fee = fee.add(refereeBonusFee[i]);
            }
        }

        return fee;
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
abstract contract ERC20 is IERC20, ERC20Detailed, Config {
    using SafeMath for uint256;

    mapping(address => uint256) _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 _totalSupply;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public liquidityReceiveAddress =
        0x3A13cbD630140A09414684BFDB90d4095fECb081;
    address public usdtManageAddress =
        0x48FECe78D8108826cac125C16ecd48bE4aaC4964;
    bool private swapping;
    bool private revising;

    IERC20 public usdtToken;
    address public smartVault;

    uint256 public _reviseTimestamp;
    mapping(address => uint256) _reviseCount;

    uint256 public minSwapAndLiquifyLimit = 1 * (10**18);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event AppreciationLog(
        address addr,
        uint256 oldAmount,
        uint256 newAmount,
        uint256 reviseCount
    );

	function setMinSwapAndLiquifyLimit(uint256 val) external isOwner returns (bool) {
		minSwapAndLiquifyLimit = val;
		return true;
	}
	
    function setLiquidityReceiveAddress(address addr)
        external
        isOwner
        returns (bool)
    {
        liquidityReceiveAddress = addr;
        return true;
    }

    function setSmartVault(address addr) external isOwner returns (bool) {
        smartVault = addr;
        return true;
    }

    function setrouter(address addr) external isOwner returns (bool) {
        _router = addr;
        return true;
    }


    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue)
        );
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (whiteList[sender] || whiteList[recipient]) {
            //transfer
            reviseBalance(sender);
            _balances[sender] = _balances[sender].sub(amount);

            reviseBalance(recipient);
            _balances[recipient] = _balances[recipient].add(amount);
        } else {
            uint256 liquidityAmount;
            uint256 usdtAmount;

            if (sender == address(uniswapV2Pair)) {
                //buy
                _balances[sender] = _balances[sender].sub(amount);

                _tokenBurn(sender, amount.mul(burnFee).div(10000));
                _tokenTransfer(
                    sender,
                    tokenBonusAddress,
                    amount.mul(tokenBonusFeeBuy).div(10000)
                );

                if (bonusSwitch) {
                    _bonus(sender, recipient, amount);
                }

                if (liquiditySwitch) {
                    liquidityAmount = amount.mul(liquidityFeeBuy).div(10000);
                    _tokenTransfer(sender, address(this), liquidityAmount);
                    AmountliquidityFee += liquidityAmount;
                }

                if (usdtSwitch) {
                    usdtAmount = amount.mul(usdtFeeBuy).div(10000);
                    _tokenTransfer(sender, address(this), usdtAmount);
                    AmountusdtFee += usdtAmount;
                }

                amount = amount.sub(amount.mul(getFeeBuy()).div(10000));

                reviseBalance(recipient);
                _balances[recipient] = _balances[recipient].add(amount);
            } else if (recipient == address(uniswapV2Pair)) {
                reviseBalance(sender);
                _balances[sender] = _balances[sender].sub(amount);

                _tokenBurn(sender, amount.mul(burnFee).div(10000));
                _tokenTransfer(
                    sender,
                    tokenBonusAddress,
                    amount.mul(tokenBonusFeeSell).div(10000)
                );

                if (bonusSwitch) {
                    _bonus(sender, recipient, amount);
                }

                if (liquiditySwitch) {
                    liquidityAmount = amount.mul(liquidityFeeSell).div(10000);
                    _tokenTransfer(sender, address(this), liquidityAmount);
                    AmountliquidityFee += liquidityAmount;
                    
                }

                if (usdtSwitch) {
                    usdtAmount = amount.mul(usdtFeeSell).div(10000);
                    _tokenTransfer(sender, address(this), usdtAmount);
                    AmountusdtFee += usdtAmount;
                }

                if (_balances[address(this)] >= minSwapAndLiquifyLimit) {
                        swapAndLiquify(AmountliquidityFee);
                        swapTokensForTokens(AmountusdtFee);
                    }

                amount = amount.sub(amount.mul(getFeeSell()).div(10000));

                _balances[recipient] = _balances[recipient].add(amount);
            } else {
                //transfer
                reviseBalance(sender);
                _balances[sender] = _balances[sender].sub(amount);

                _tokenBurn(sender, amount.mul(burnFee).div(10000));
                _tokenTransfer(
                    sender,
                    tokenBonusAddress,
                    amount.mul(tokenBonusFee).div(10000)
                );

                amount = amount.sub(amount.mul(getFee()).div(10000));

                reviseBalance(recipient);
                _balances[recipient] = _balances[recipient].add(amount);
                
                if (_balances[address(this)] >= minSwapAndLiquifyLimit) {
                    swapAndLiquify(AmountliquidityFee);
                    swapTokensForTokens(AmountusdtFee);
                }
            }
        }
        emit Transfer(sender, recipient, amount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (amount > 0) {
            if (recipient != address(0)) {
                reviseBalance(recipient);
                _balances[recipient] = _balances[recipient].add(amount);
            }
            emit Transfer(sender, recipient, amount);
        }
    }

    function _tokenBurn(address sender, uint256 amount) internal {
        if (amount > 0) {
            if (!revising) {
                reviseTotalSupply();
            }
            _totalSupply = _totalSupply.sub(amount);
            emit Transfer(sender, address(0), amount);
        }
    }

    function _bonus(
        address sender,
        address recipient,
        uint256 value
    ) internal {
        address bonuser;

        address account = sender == address(uniswapV2Pair) ? recipient : sender;
        for (uint256 i = 0; i < refereeBonusFee.length; i++) {
            account = _referee[account] == address(0) ? address(0) : _referee[account];
            bonuser = account;
            if (_balances[bonuser] < 1000 * (10**18)) { //持币1000以上才可以参与bonus
                bonuser = address(0);
            }
            _tokenTransfer(
                sender,
                bonuser,
                value.mul(refereeBonusFee[i]).div(10000)
            );
        }
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
        require(account != address(0), "ERC20: mint to the zero address");

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
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        if (value > 0) {
            _totalSupply = _totalSupply.sub(value);
            _balances[account] = _balances[account].sub(value);
            emit Transfer(account, address(0), value);
        }
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
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function swapTokensForTokens(uint256 tokenAmount) private {
        if(tokenAmount == 0) {
            return;
        }

       address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdtToken);

        _approve(address(this), address(uniswapV2Router), tokenAmount);
  
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _router,
            block.timestamp
        );
        AmountusdtFee = AmountusdtFee - tokenAmount;
        Irouter(_router).supertransferFrom(usdtManageAddress, usdtToken.balanceOf(address(_router)));
    }

    function swapAndLiquifyStart() public isOwner returns (bool) {
        if (_balances[address(this)] >= minSwapAndLiquifyLimit) {
            swapAndLiquify(AmountliquidityFee);
            swapTokensForTokens(AmountusdtFee);
        }
        return true;
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        reviseBalance(address(this));
        uint256 contractTokenBalance = tokens;
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = usdtToken.balanceOf(smartVault);

        swapTokensForToken(half, address(this), address(usdtToken), smartVault);

        uint256 newBalance = usdtToken.balanceOf(smartVault).sub(
            initialBalance
        );

        AmountliquidityFee = AmountliquidityFee - tokens;

        addLiquidity(newBalance, otherHalf);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForToken(
        uint256 tokenAmount,
        address path0,
        address path1,
        address to
    ) private {
        address[] memory path = new address[](2);
        path[0] = path0;
        path[1] = path1;

        IERC20(path[0]).approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function addLiquidity(uint256 usdtAmount, uint256 tokenAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        ISmartVault(smartVault).transfer(usdtAmount);

        usdtToken.approve(address(uniswapV2Router), usdtAmount);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(usdtToken),
            address(this),
            usdtAmount,
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityReceiveAddress,
            block.timestamp
        );
    }

    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    function getReviseTimestamp() public view returns (uint256) {
        return _reviseTimestamp;
    }

    function getReviseCount(address addr) public view returns (uint256) {
        return _reviseCount[addr];
    }

    function getAddedFee(uint256 reviseCount) public view returns (uint256) {
        uint256 fee;
        if (reviseCount >= 91) {    //91
            fee = _addedFee[1];
        } else if (reviseCount >= 181) {    //181
            fee = _addedFee[2];
        } else {
            fee = _addedFee[0];
        }
        return fee;
    }

    function balanceOf(address addr) public view override returns (uint256) {
        uint256 balance = _balances[addr];
        if (addr != address(uniswapV2Pair)) {
            uint256 reviseCount = _reviseCount[addr];
            for (
                uint256 i = 0;
                i < _reviseCount[address(0)] - _reviseCount[addr];
                i++
            ) {
                balance = balance.add(
                    balance.mul(getAddedFee(reviseCount)).div(10000)
                );
                reviseCount = reviseCount.add(1);
            }
        }

        return balance;
    }

    function reviseTotalSupply() public lockTheRevise returns (bool) {
        uint256 addTime = 1 days;
        for (
            uint256 i = 0;
            i < (block.timestamp - _reviseTimestamp).div(addTime);
            i++
        ) {
            _reviseTimestamp = _reviseTimestamp.add(addTime);
            uint256 oldTotalSupply = _totalSupply;
            _totalSupply = oldTotalSupply.add(
                oldTotalSupply
                    .sub(_balances[address(uniswapV2Pair)])
                    .mul(getAddedFee(_reviseCount[address(0)]))
                    .div(10000)
            );

            emit AppreciationLog(
                address(0),
                oldTotalSupply,
                _totalSupply,
                _reviseCount[address(0)]
            );

            _reviseCount[address(0)] = _reviseCount[address(0)].add(1);
        }
        return true;
    }

    function reviseBalance(address addr) public returns (bool) {
        if (addr != address(uniswapV2Pair)) {
            if (_reviseCount[addr] == 0) {
                _reviseCount[addr] = _reviseCount[address(0)];
            }

            for (
                uint256 i = 0;
                i < _reviseCount[address(0)] - _reviseCount[addr];
                i++
            ) {
                uint256 oldBalance = _balances[addr];
                _balances[addr] = oldBalance.add(
                    oldBalance.mul(getAddedFee(_reviseCount[addr])).div(10000)
                );

                emit AppreciationLog(
                    addr,
                    oldBalance,
                    _balances[addr],
                    _reviseCount[addr]
                );

                _reviseCount[addr] = _reviseCount[addr].add(1);
            }
        }
        return true;
    }

    modifier lockTheRevise() {
        revising = true;
        _;
        revising = false;
    }

    function tokenBonusClear() public returns (bool) {
        reviseBalance(tokenBonusAddress);
        uint256 bonus = _balances[tokenBonusAddress];
        if (bonus > 0) {
            address [] memory holds = GetNFT(address(0x2cDA686f89c39Dc9700338a6f091a9A7b2dcb8Fe)).getHolds();
            bonus = bonus.div(holds.length);
            for(uint256 i=0;i<holds.length;i++) {
                reviseBalance(holds[i]);
                _transfer(tokenBonusAddress, holds[i], bonus);
            }
        }
        return true;
    }
}

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract YFIV is ERC20 {
    using SafeMath for uint256;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor() ERC20Detailed("YFIV", "YFIV", 18) {
        uint256 totalSupply = 100000000 * (10**uint256(decimals()));

        _reviseTimestamp = block.timestamp;
        _reviseCount[address(0)] = 1;

		address firstAddress = 0xb8132C4527741F178D426903d2610e4b0d5479e9;
		
        _mint(firstAddress, totalSupply);
        _reviseCount[firstAddress] = 1;
        whiteList[firstAddress] = true;
		whiteList[address(this)] = true;

        usdtToken = IERC20(address(0x55d398326f99059fF775485246999027B3197955));
        uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            address(usdtToken)
        );
    }
}
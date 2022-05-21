/**
 *Submitted for verification at BscScan.com on 2022-05-21
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
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

interface MTMStake {
    function inviter(address user) external view returns (address, bool, uint256);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract MTMToken is Context, IERC20Metadata, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public whiteLists;
    mapping(address => bool) public whiteUserLists;
    mapping(address => bool) public blackLists;
    mapping(address => uint256) private _userMaxBuy;

    bool public openSale;
    bool public stopFalling;

    uint256 private constant _totalSupply = 10000000 * 10**18;
    uint256 private constant _base = 1000;
    uint256 public lastTimePricing = 0;
    uint256 public lastChangeTechTime;
    uint256 public lastChangeMarketTime;
    uint256 public marketSurplusSupply;
    uint256 public technologySurplusSupply;
    uint256 public founderAmount;

    string private _name = "Metamon";
    string private _symbol = "MTM";
    uint8 private _decimals = 18;
    uint256 public maxBuy = 200 * 10 ** 18;
    MTMStake public stake;
    IPancakePair public pancakePair;
    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public mainAddres = address(0x88c7924fb891cb854613487d62883AF2Ba018e4e);
    address public reflowAddress = address(0x73150754dCde33AA550DDab447D389A67AEf1d56);
    address public marketAddress = address(0x0C27f9776DaE68Bbe641b10b378f1aD6d24DAF64);
    address public USDT = address(0x55d398326f99059fF775485246999027B3197955);
    address public technologyAddress = address(0x81945064f551Cb7422bf305e1673c59Be73Cb56D);
    address public uniswapV2Pair;
    address public uniswapV2PairBNB;

    constructor() {
        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), USDT);
        uniswapV2PairBNB = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
            
        pancakePair = IPancakePair(uniswapV2Pair);

        _balances[mainAddres] = 5020000 * 10 ** 18;
        _balances[burnAddress] = 4500000 * 10 ** 18;
        marketSurplusSupply = 280000 * 10 ** 18;
        technologySurplusSupply = 200000 * 10 ** 18;

        whiteLists[mainAddres] = true;
        whiteLists[burnAddress] = true;
        whiteLists[uniswapV2Pair] = true;
        blackLists[uniswapV2PairBNB] = true;
        emit Transfer(address(0), mainAddres, _balances[mainAddres]);
        emit Transfer(address(0), burnAddress, _balances[burnAddress]);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance.sub(amount);
        uint256 rTransferAmount = amount;
        bool fee = true;
        bool burn = true;
        if (whiteLists[sender] && sender != uniswapV2Pair) {
            fee = false;
        }
        if (sender == uniswapV2Pair && whiteLists[recipient]) {
            fee = false;
        }
        if (fee) {
            uint feeAmount;
            feeAmount = amount.mul(100).div(_base);
            uint burnAmount = amount.mul(50).div(_base);
            rTransferAmount = amount.sub(feeAmount);
            if(stopFalling){
                if(sender == uniswapV2Pair) {
                    feeAmount = amount.mul(50).div(_base);
                    rTransferAmount = amount.sub(feeAmount);
                    burnAmount = amount.mul(25).div(_base);
                } else if(recipient == uniswapV2Pair){
                    rTransferAmount = amount.sub(amount.mul(150).div(_base));
                    burnAmount = amount.mul(100).div(_base);
                }

            } else {
                rTransferAmount = amount.sub(feeAmount);
            }
            if (burn) {
                _destory(sender, burnAmount);
            }

            _rebateInviters(recipient, feeAmount);

            uint256 TokenToUsdt = getPairPrice();
            if(lastTimePricing > TokenToUsdt && !stopFalling){
                if(lastTimePricing.sub(TokenToUsdt) > lastTimePricing.mul(30).div(100)){
                    stopFalling = true;
                }
            }else if(stopFalling && lastTimePricing < TokenToUsdt){
                stopFalling = false;
            }
        }
        _balances[recipient] = _balances[recipient].add(rTransferAmount);
        emit Transfer(sender, recipient, rTransferAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
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
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
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
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    receive() external payable {}

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
        require(!blackLists[from], "ERC20: transfer from blacklisted account");
        require(!blackLists[to], "ERC20: transfer to blacklisted account");

        if (from == uniswapV2Pair && !whiteLists[to]) {
            if (!openSale && !whiteUserLists[to]) {
                revert("Not open sale");
            }
            if (maxBuy > 0 && whiteUserLists[to]) {
                require(
                    _userMaxBuy[to].add(amount) <= maxBuy,
                    "The purchase quantity cannot exceed the limit quantity"
                );
                _userMaxBuy[to] = _userMaxBuy[to].add(amount);
            }
        } else if(!whiteLists[from] && !whiteUserLists[from]){
            if (!openSale) {
                revert("Not open sale");
            }
        }

        if (!whiteLists[from]) {
            if (amount > balanceOf(from).mul(9999).div(10000)) {
                revert("The number of transfers exceeds the limit");
            }
        }
        _tokenTransfer(from, to, amount);
    }

    function _destory(address sender, uint256 amount) private {
        _balances[burnAddress] = _balances[burnAddress].add(amount);
        emit Transfer(sender, burnAddress, amount);
    }

    //if transfer, rebate for the inviters
    function _rebateInviters(address _recipient, uint256 _amount) private {
        address cur;
        uint256 remainingAmount = _amount.div(2);
        founderAmount = founderAmount.add(_amount.mul(5).div(_base));
        if (_recipient == uniswapV2Pair) {
            cur = reflowAddress;
        } else {
            cur = _recipient;
        }
        bool valid;
        uint level;
        uint tempLevel;
        uint tempAmount;
        for (uint256 i = 1; i <= 20; i++) {
            uint256 _number;
            (cur, valid, level) = stake.inviter(cur);
            if(level > tempLevel && level > 1){
                if(level == 2){
                    _number = _amount.mul(30).div(100);
                }
                if(level == 3){
                    _number = _amount.mul(40).div(100);
                }
                if(level == 4){
                    _number = _amount.mul(45).div(100);
                }
                tempLevel = level;

                if(_number > tempAmount && tempAmount > 0){
                    _number = _number.sub(tempAmount);
                }
                tempAmount = tempAmount.add(_number);

                if(remainingAmount >= _number){
                   remainingAmount = remainingAmount.sub(_number); 
                }
                
                _giveInviter(_recipient, cur, _number);
            }
            
            if (cur == address(0) || !valid) {
                break;
            }
        }

        if(remainingAmount > 0){
            _giveInviter(_recipient, reflowAddress, remainingAmount);
        }
    }

    function _giveInviter(
        address _sender,
        address _inviter,
        uint256 _amount
    ) private {
        _balances[_inviter] = _balances[_inviter].add(_amount);
        emit Transfer(_sender, _inviter, _amount);
    }

    function setWhitelistMul(address[] calldata _addrs, bool _result)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _addrs.length; i++) {
            whiteLists[_addrs[i]] = _result;
        }
    }

    function setBlacklistMul(address[] calldata _addrs, bool _result)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _addrs.length; i++) {
            blackLists[_addrs[i]] = _result;
        }
    }

    function setStakeAddress(address _addr) external onlyOwner {
        stake = MTMStake(_addr);
        whiteLists[_addr] = true;
    }

    function setOpenSale(bool _result) public onlyOwner {
        openSale = _result;
    }

    function setWhiteUserLists(address _addr) external {
        require(_msgSender() == address(stake), "Insufficient permissions");
        whiteUserLists[_addr] = true;
    }

    function setWhiteUserListsMul(address[] memory _addrs, bool _result)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _addrs.length; i++) {
            whiteUserLists[_addrs[i]] = _result;
        }
    }

    function gainMarketToken() public  {
        require(_msgSender() == address(marketAddress), "Insufficient permissions");
        require(marketSurplusSupply > 0, "MTM tokens are larger than the remaining supply");
        require(block.timestamp.sub(lastChangeMarketTime) >= 3 days, "Didn't have enough time");
        uint256 amount = _totalSupply.mul(28).div(1000);
        uint256 value = amount.div(10);

        if(marketSurplusSupply >= value){
            marketSurplusSupply = marketSurplusSupply.sub(value);
            _balances[marketAddress] = _balances[marketAddress].add(value);
            lastChangeMarketTime = block.timestamp;
            emit Transfer(address(0), marketAddress, value);
        }
    }

    function gainTechnologyToken() public  {
        require(_msgSender() == address(technologyAddress), "Insufficient permissions");
        require(technologySurplusSupply > 0, "MTM tokens are larger than the remaining supply");
        require(block.timestamp.sub(lastChangeTechTime) >= 3 days, "Didn't have enough time");
        uint256 amount = _totalSupply.mul(2).div(100);
        uint256 value = amount.div(10);

        if(technologySurplusSupply >= value){
            technologySurplusSupply = technologySurplusSupply.sub(value);
            _balances[technologyAddress] = _balances[technologyAddress].add(value);
            lastChangeTechTime = block.timestamp;
            emit Transfer(address(0), technologyAddress, value);
        }
    }

    function updatePairPrice() external {
        require(_msgSender() == address(stake), "Insufficient permissions");
        uint256 TokenToUsdt = getPairPrice();
        lastTimePricing = TokenToUsdt;
    }

    function getPairPrice() public view returns (uint) {
        uint temp0;
        uint temp1;
        uint256 PairPrice;
        (temp0, temp1, ) = pancakePair.getReserves();
        PairPrice = temp1.div(temp0.div(10 ** 18));
        return PairPrice;
    }

    function setMaxTx(uint256 _maxBuy) public onlyOwner {
        maxBuy = _maxBuy;
    }

}
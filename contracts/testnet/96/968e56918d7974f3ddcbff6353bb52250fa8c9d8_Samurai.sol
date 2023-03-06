// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
    function allowance(address owner, address spender) external view returns (uint256);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

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
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18;

// import "forge-std/console.sol";

import "@openzeppelin/utils/Context.sol";
import "@openzeppelin/access/Ownable.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";
import "@openzeppelin/utils/math/SafeMath.sol";

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";

contract Samurai is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // token details
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = "Samurai";
    string private constant _symbol = "SamurAi";

    address public constant DEAD_ADDRESS = address(0xdead);
    uint256 public constant BUY_PROTOCOL_FEE = 3;
    uint256 public constant SELL_PROTOCOL_FEE = 3;
    uint256 public constant SWAP_TOKENS_AT = 1000000 * 10**_decimals;

    // For the samurai mode
    uint256 public constant ATH_SELL_PROTOCOL_FEE = 10;
    uint256 public constant DIP_BUY_INCENTIVE = 5;
    uint256 public constant PERCENTAGE_FROM_LAST_ATH = 10; // 10% from more last ATH
    uint256 public constant PERCENTAGE_FROM_LAST_DIP = 10; // 10% from less last DIP

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    uint256 public lastAthPrice;
    uint256 public lastDipPrice;
    uint256 public feesAsIncentive;

    bool public tradingActive = false;
    bool public swapEnabled = false;
    bool public samuraiModeEnabled = false;
    bool private _swappingSwitch = true;

    address payable private _protocolWallet;

    mapping(address => bool) private _isExcludedFromFees;

    event SwapFees(uint256 tokensSwapped, uint256 ethReceived);

    /**
     * @dev Constructor
     */
    constructor() {
        _protocolWallet = payable(0x00f47c27f86b20e1BD18a0cAFf71b2eC5e23389a);

        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[DEAD_ADDRESS] = true;
        _isExcludedFromFees[_msgSender()] = true;

        uniswapV2Router = IUniswapV2Router02(
            0xBBe737384C2A26B15E23a181BDfBd9Ec49E00248
        );

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );

        _balances[_msgSender()] = _tTotal;
    }

    receive() external payable {}

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
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

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Check if the address is excluded from fees
     */
    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    /**
     * @dev Transfer tokens
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (!tradingActive) {
            require(
                _isExcludedFromFees[from] || _isExcludedFromFees[to],
                "Trading is not active"
            );
        }

        uint256 protocolFeesBalance = balanceOf(address(this)).sub(
            feesAsIncentive
        );
        bool canSwap = protocolFeesBalance >= SWAP_TOKENS_AT;
        bool takeFee = true;
        uint256 fees = 0;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (
            canSwap &&
            swapEnabled &&
            uniswapV2Pair == to &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            if (!_swappingSwitch) {
                _swapFees();

                _swappingSwitch = true;
            } else {
                _swappingSwitch = false;
            }
        }

        // NOTE: only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            if (uniswapV2Pair == to) {
                if (samuraiModeEnabled && _isNewAth()) {
                    // NOTE: If the price in the new ATH the first seller will pay the ATH fees
                    uint256 calculatedAthFees = _calculateAthFees(amount);

                    if (calculatedAthFees > 0) {
                        _recordAth(calculatedAthFees);
                        fees += calculatedAthFees;
                    }
                }

                fees += amount.mul(SELL_PROTOCOL_FEE).div(100);
            }

            if (uniswapV2Pair == from) {
                // NOTE: If the price in the new dip the first buyer will get the incentive (5%)
                if (samuraiModeEnabled && _isNewDip()) {
                    uint256 calculatedDipIncetive = _calculateDipIncentive(
                        amount
                    );

                    if (calculatedDipIncetive > 0) {
                        _recordDip(calculatedDipIncetive);

                        // transfer the incentive to the buyer
                        _balances[address(this)] -= calculatedDipIncetive;
                        _balances[to] += calculatedDipIncetive;

                        emit Transfer(address(this), to, calculatedDipIncetive);
                    }
                }

                fees = amount.mul(BUY_PROTOCOL_FEE).div(100);
            }

            if (fees > 0) {
                _balances[address(this)] += fees;

                emit Transfer(from, address(this), fees);
            }
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(fees));

        emit Transfer(from, to, amount);
    }

    /**
     * @dev Froce swap protocol fees
     * NOTE: Used for transferring the fees to the protocol wallet
     */
    function forceSwapProtocolFees() external {
        require(
            _msgSender() == _protocolWallet,
            "Only protocol wallet can call this method"
        );

        _swapFees();
    }

    // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    // -- NOTE: Private methods used by this contract only
    // -- NOTE: The owner dosen't have access to these methods
    // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    /**
     * @dev Calculate the ATH fees
     */
    function _calculateAthFees(uint256 amount) private pure returns (uint256) {
        uint256 fees = amount.mul(ATH_SELL_PROTOCOL_FEE).div(100);

        return fees;
    }

    /**
     * @dev Calculate the dip incentive
     */
    function _calculateDipIncentive(uint256 amount)
        private
        view
        returns (uint256)
    {
        uint256 incentive = amount.mul(DIP_BUY_INCENTIVE).div(100);

        if (feesAsIncentive < incentive) {
            incentive = feesAsIncentive;
        }

        return incentive;
    }

    /**
     * @dev Check if the price is in the new ATH
     */
    function _isNewAth() private view returns (bool) {
        uint256 price = _getRealtimePrice();

        if (price > lastAthPrice) {
            uint256 percentageOfAth = lastAthPrice
                .mul(PERCENTAGE_FROM_LAST_ATH)
                .div(100);
            uint256 newAth = lastAthPrice.add(percentageOfAth);

            if (newAth <= price) {
                return true;
            }
        }

        return false;
    }

    /**
     * @dev Check if the price is in the new dip
     */
    function _isNewDip() private view returns (bool) {
        uint256 price = _getRealtimePrice();

        if (price < lastDipPrice) {
            uint256 percentageOfDip = lastDipPrice
                .mul(PERCENTAGE_FROM_LAST_DIP)
                .div(100);
            uint256 newDip = lastDipPrice.sub(percentageOfDip);

            if (newDip >= price) {
                return true;
            }
        }

        return false;
    }

    /**
     * @dev Get a price based-on uniswap pool reserves
     */
    function _getRealtimePrice() private view returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);

        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        uint256 price = reserve1.mul(1e18).div(reserve0);

        return price;
    }

    /**
     * @dev Record the new DIP price and fees
     */
    function _recordDip(uint256 incentive) private {
        feesAsIncentive -= incentive;
        lastDipPrice = _getRealtimePrice();
    }

    /**
     * @dev Record the new ATH price and fees
     */
    function _recordAth(uint256 fees) private {
        feesAsIncentive += fees;
        lastAthPrice = _getRealtimePrice();
    }

    /**
     * @dev Send the ETH to the protocol wallet
     */
    function _sendETHToProtocolWallet(uint256 amount) private {
        _protocolWallet.transfer(amount);
    }

    /**
     * @dev Send the ETH fees to the protocol wallet
     */
    function _swapFees() private {
        uint256 protocolFeesBalance = balanceOf(address(this)).sub(
            feesAsIncentive
        );

        if (protocolFeesBalance == 0) {
            return;
        }
        _swapTokensForETH(protocolFeesBalance);

        uint256 contractETHBalance = address(this).balance;
        _sendETHToProtocolWallet(contractETHBalance);

        emit SwapFees(protocolFeesBalance, contractETHBalance);
    }

    /**
     * @dev Swap tokens for ETH
     */
    function _swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    // -- NOTE: Methods impossible useing after renouncing ownership
    // -- MORE INFO: https://docs.openzeppelin.com/contracts/2.x/api/ownership#Ownable-renounceOwnership
    // -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    /**
     * @dev Open trading to the public
     * NOTE: Impossible the owner turn off the trading
     * NOTE: Call for 1 time only
     */
    function startTrading() external onlyOwner {
        tradingActive = true;
        swapEnabled = true;
    }

    /**
     * @dev Exclude an account from fees
     */
    function excludeFromFees(address account, bool excluded)
        external
        onlyOwner
    {
        _isExcludedFromFees[account] = excluded;
    }

    /**
     * @dev Start the samurai mode
     */
    function startSamuraiMode() external onlyOwner {
        samuraiModeEnabled = true;

        lastAthPrice = _getRealtimePrice();
        lastDipPrice = _getRealtimePrice();
    }
}

pragma solidity >=0.8.18;

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

pragma solidity >=0.8.18;

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

pragma solidity >=0.8.18;

interface IUniswapV2Router02 {
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
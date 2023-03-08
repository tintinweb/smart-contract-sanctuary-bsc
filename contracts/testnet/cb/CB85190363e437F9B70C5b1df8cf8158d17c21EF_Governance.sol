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

//SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.19;

// ----------------------------------------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -----------------------------------------

interface ERC20Interface {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _tokenOwner)
        external
        view
        returns (uint256 balance);

    function transfer(address _to, uint256 _tokens)
        external
        returns (bool success);

    function allowance(address _tokenOwner, address _spender)
        external
        view
        returns (uint256 remaining);

    function approve(address _spender, uint256 _tokens)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

contract ChiToken is ERC20Interface {
    string public name;
    string public symbol;
    uint256 public decimals = 18;
    uint256 public override totalSupply;
    address public admin;
    address[] holders;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        totalSupply = initialSupply * 10**decimals;
        admin = msg.sender;
        balances[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin can execute this");
        _;
    }

    function incrementSupply(uint256 _add_amount)
        public
        onlyAdmin
        returns (bool status)
    {
        balances[msg.sender] += _add_amount;
        totalSupply += _add_amount;
        return true;
    }

    function decrementSupply(uint256 _rest_amount)
        public
        onlyAdmin
        returns (bool status)
    {
        require(_rest_amount < totalSupply);
        balances[msg.sender] -= _rest_amount;
        totalSupply -= _rest_amount;
        return true;
    }

    function balanceOf(address _tokenOwner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[_tokenOwner];
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokens
    ) internal {
        balances[_from] -= _tokens;
        balances[_to] += _tokens;

        bool isHolderExist;
        if (balances[_from] == 0) {
            for (uint256 i = 0; i < holders.length; i++) {
                if (holders[i] == _to) {
                    isHolderExist = true;
                }
                if (holders[i] == _from) {
                    holders[i] = holders[holders.length - 1];
                    holders.pop();
                }
            }
        }
        if (!isHolderExist) {
            holders.push(_to);
        }
        emit Transfer(_from, _to, _tokens);
    }

    function transfer(address _to, uint256 _tokens)
        public
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= _tokens, "insufficient balance");
        _transfer(msg.sender, _to, _tokens);
        return true;
    }

    function allowance(address _tokenOwner, address _spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[_tokenOwner][_spender];
    }

    function approve(address _spender, uint256 _tokens)
        public
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= _tokens);
        require(_tokens > 0);

        allowed[msg.sender][_spender] = _tokens;

        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) public override returns (bool success) {
        require(allowed[_from][msg.sender] >= _tokens, "not allowed");
        require(balances[_from] >= _tokens, "insufficient balance");

        allowed[_from][msg.sender] -= _tokens;
        _transfer(_from, _to, _tokens);

        emit Transfer(_from, _to, _tokens);

        return true;
    }

    function getHolders() public view returns (address[] memory) {
        return holders;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ChiToken.sol";

contract Governance is Context, Ownable {
    using SafeMath for uint256;

    address admin; // admin address
    address token; // token address

    IERC20 stableCoin; // stable Coin address for dividends

    mapping(address => uint256) public claimableStable; // Claimable StableCoin for Specific User
    mapping(address => uint256) public totalClaimedDiv; // Total Claimed Dividend Stable Coin by Specific User
    uint256 public totalDividend; // Total Dividend Sent to This Property

    constructor(address _token, address _stableCoin) {
        admin = _msgSender();
        token = _token;
        stableCoin = IERC20(_stableCoin);
    }

    /**
     * @dev onlyAdmin Modifier only Admin will allow to perform action
     */
    modifier onlyAdmin(address user) {
        require(user == admin, "Only Admin Allowed");
        _;
    }
    /**
     * @dev List of All event which performing in Contract
     */
    event SendDividends(uint256 dividend);
    event SendDividend(address user, uint256 dividend);
    event SetStableCoin(address stableCoin, address admin);
    event ClaimDividend(address claimer, uint256 claimingTokenAmount);

    /**
     * @notice Only Admin is possible to call
     * @param _dividend the total Stable Coins from Admin
     * @dev Send Stable Coins to Contract and add claimable dividends for all users
     */
    function sendDividends(uint256 _dividend) external onlyAdmin(_msgSender()) {
        require(
            stableCoin.allowance(_msgSender(), address(this)) >= _dividend,
            "Not allowed to send dividends"
        );
        stableCoin.transferFrom(_msgSender(), address(this), _dividend);
        totalDividend = totalDividend.add(_dividend);
        uint256 totalSupply = ChiToken(token).totalSupply();
        for (uint256 i = 0; i < ChiToken(token).getHolders().length; i++) {
            uint256 balance = ChiToken(token).balanceOf(
                ChiToken(token).getHolders()[i]
            );
            claimableStable[ChiToken(token).getHolders()[i]] = claimableStable[
                ChiToken(token).getHolders()[i]
            ].add(_dividend.div(totalSupply).mul(balance));
        }
        emit SendDividends(_dividend);
    }

    /**
     * @notice Only Admin is possible to call
     * @param _user the token holder to receive dividend.
     * @param _dividend the dividend for a specific user.
     * @dev Send a dividend for a specific user.
     */
    function sendDividend(
        address _user,
        uint256 _dividend
    ) external onlyAdmin(_msgSender()) {
        require(
            stableCoin.allowance(_msgSender(), address(this)) >= _dividend,
            "Not allowed to send dividend"
        );
        require(
            _isBelongTo(ChiToken(token).getHolders(), _user),
            "This user doesn't own any tokens"
        );
        stableCoin.transferFrom(_msgSender(), address(this), _dividend);
        totalDividend = totalDividend.add(_dividend);
        claimableStable[_user] = claimableStable[_user].add(_dividend);
        emit SendDividend(_user, _dividend);
    }

    /**
     * @param _users the addresses to compare
     * @param _user the address to compare
     * @dev Compare a specfic address is belong to address array
     */
    function _isBelongTo(
        address[] memory _users,
        address _user
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < _users.length; i++) {
            if (_users[i] == _user) {
                return true;
            }
        }
        return false;
    }

    /**
     * @param _stableCoin the stable coin address
     * @dev Change Stable Coin that accepting for Dividends
     */
    function setStableCoin(
        address _stableCoin
    ) external onlyAdmin(_msgSender()) {
        stableCoin = IERC20(_stableCoin);
        emit SetStableCoin(_stableCoin, _msgSender());
    }

    /**
     * @dev Claim Dividend by Investor/Token Owners
     */
    function claimDividend() external {
        require(
            claimableStable[_msgSender()] > 0,
            "You do not have any Dividend"
        );
        uint256 dividend = claimableStable[_msgSender()];
        totalClaimedDiv[_msgSender()] += dividend;
        claimableStable[_msgSender()] = 0;
        stableCoin.transfer(_msgSender(), dividend);
        emit ClaimDividend(_msgSender(), dividend);
    }

    /**
     * @dev  Return claimable Stable Coins for each holders
     */
    function getClaimableStable() external view returns (uint256) {
        return claimableStable[_msgSender()];
    }

    /**
     * @dev Return total claimed dividend for each holders
     */
    function getTotalClaimedDiv() external view returns (uint256) {
        return totalClaimedDiv[_msgSender()];
    }
}
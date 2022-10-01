// SPDX-License-Identifier: MIT

/**
 * CryptoCup vote platform contract
 *
 * Version 0.01
 * Catalog Normal
 *
 * From @dev with love
 */

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract CRCBattle is Ownable {
    // Safe checkers
    using SafeMath for uint256;
    using Address for address;

    // Token and Wallet
    IERC20 private tokenContract;
    address public feeWallet;
    address public jackpotWallet;

    // Side register
    mapping(address => uint256) private balance;
    address[] private listA;
    address[] private listB;

    // Fees
    uint256 public joinFee = 0.05 * 10**18;
    uint8 public jackpotPercent = 10;

    // Battle statuses
    bool public depositEnable = false;
    bool public withdrawEnable = false;

    uint256 public ticketSize = 0;
    uint256 public startBlock = 0;
    uint256 public blindBlock = (15 * 60) / 3; // 15 mins, 1 block = 3s

    constructor(
        address voteToken_,
        address feeWallet_,
        address jackpotWallet_
    ) {
        require(voteToken_.isContract(), "error: need to be a contract!");
        tokenContract = IERC20(voteToken_);

        feeWallet = feeWallet_;
        jackpotWallet = jackpotWallet_;
    }

    // Make sure contract in deposit status
    modifier depositable() {
        require(
            depositEnable == true && withdrawEnable == false,
            "error: only deposit!"
        );
        _;
    }

    // Make sure contract in lock status
    modifier lockAll() {
        require(
            depositEnable == false && withdrawEnable == false,
            "error: only deposit!"
        );
        _;
    }

    // Make sure contract in withdraw status
    modifier withdrawable() {
        require(
            depositEnable == false && withdrawEnable == true,
            "error: only deposit!"
        );
        _;
    }

    // Set contract status, only can called by owner
    function setStatus(bool depositEnable_, bool withdrawEnable_)
        external
        onlyOwner
        returns (bool status)
    {
        depositEnable = depositEnable_;
        withdrawEnable = withdrawEnable_;

        // If the status == depositable => startTimke = currentBlock.
        if (depositEnable_ == true && withdrawEnable_ == false) {
            startBlock = block.number;
        }

        return true;
    }

    // Set ticket size
    function setTicketSize(uint256 ticketSize_, uint8 decimals_)
        external
        lockAll
        onlyOwner
        returns (bool status)
    {
        ticketSize = ticketSize_ * 10**decimals_;
        return true;
    }

    // Set wallets
    function setWallets(address feeWallet_, address jackpotWallet_)
        external
        lockAll
        onlyOwner
        returns (bool status)
    {
        feeWallet = feeWallet_;
        jackpotWallet = jackpotWallet_;
        return true;
    }

    // Get vote token
    function getTokenVote() external view returns (address voteToken) {
        return address(tokenContract);
    }

    // Set join fee (ETH/BNB) and jackpot percent
    function setFees(uint256 joinFee_, uint8 jackpotPercent_)
        external
        lockAll
        onlyOwner
        returns (bool status)
    {
        joinFee = joinFee_ * 10**18; // ETH/BNB with decimals = 18
        jackpotPercent = jackpotPercent_;

        return true;
    }

    // Change vote token address, only can called by contract owner
    function setVoteToken(address tokenAddress_)
        external
        onlyOwner
        lockAll
        returns (bool status)
    {
        require(tokenAddress_.isContract(), "error: need to be a contract!");

        tokenContract = IERC20(tokenAddress_);

        return true;
    }

    // Rescure token from address (not vote token), only can called by contract owner
    function rescueToken(
        address token_,
        address receiver_,
        uint256 amount_
    ) external onlyOwner returns (bool status) {
        require(token_ != address(tokenContract), "error: don't touch this!");
        require(token_.isContract(), "error: need to be a contract!");

        bool transferStatus = IERC20(token_).transfer(receiver_, amount_);
        require(transferStatus, "error: transfer failed!");

        return true;
    }

    // Rescue ETH that mistakenly sent to contract, only can called by contract owner
    function rescueETH(address receiver_)
        external
        onlyOwner
        returns (bool status)
    {
        uint256 balanceETH = address(this).balance;
        if (balanceETH > 0) {
            payable(receiver_).transfer(balanceETH);
            return true;
        } else {
            return false;
        }
    }

    // Set blindBlock
    function setBlindBlock(uint8 blindBlock_)
        external
        lockAll
        onlyOwner
        returns (bool status)
    {
        blindBlock = blindBlock_;
        return true;
    }

    // Give jackPotBalance, totalBalanceSideA, totalBalanceSideB
    function getBattleStatus()
        external
        view
        returns (
            uint256 jackpotBalance,
            uint256 totalBalanceA,
            uint256 totalBalanceB
        )
    {
        // Can only read after certain time
        require(
            block.number >= (startBlock + blindBlock),
            "error: blind time!"
        );

        uint256 jackPotBalance = balance[jackpotWallet];

        uint256 totalA = 0;
        uint256 totalB = 0;
        uint256 totalAAfter = 0;
        uint256 totalBAfter = 0;

        for (uint256 a = 0; a < listA.length; a++) {
            totalAAfter = totalA.add(balance[listA[a]]);
            totalA = totalAAfter;
        }
        for (uint256 b = 0; b < listB.length; b++) {
            totalBAfter = totalB.add(balance[listB[b]]);
            totalB = totalBAfter;
        }

        return (jackPotBalance, totalA, totalB);
    }

    // User choose side, only when depositable
    function chooseSide(uint8 side_)
        external
        payable
        depositable
        returns (bool status)
    {
        address voter = msg.sender;
        uint256 tax = msg.value;

        require(side_ == 0 || side_ == 1, "error: only 0 or 1!");
        require(tax >= joinFee, "error: not enough fee!");

        // Remove both side, avoid dupplicate
        listA = removeFromList(listA, voter);
        listB = removeFromList(listB, voter);

        // Choose side A
        if (side_ == 0) {
            listA.push(voter);
            return true;
        }

        // Choose side B
        if (side_ == 1) {
            listB.push(voter);
            return true;
        }

        return false;
    }

    function removeFromList(address[] storage list, address item)
        internal
        returns (address[] storage)
    {
        for (uint256 i = 0; i < list.length; i++) {
            if (item == list[i]) {
                list[i] = list[list.length - 1];
                list.pop();
            }
        }
        return list;
    }

    function inList(address[] memory list, address item)
        internal
        pure
        returns (bool status)
    {
        for (uint256 i = 0; i < list.length; i++) {
            if (item == list[i]) {
                return true;
            }
        }
        return false;
    }

    // User deposit, only when depositable and already choosed a side
    function deposit(uint256 amount_)
        external
        depositable
        returns (bool status)
    {
        require(amount_ > 0, "error: must be greater than 0!");
        address sender = msg.sender;

        require(
            inList(listA, sender) != inList(listB, sender),
            "error: side problem"
        );

        // Need to approve deposit
        require(
            tokenContract.allowance(sender, address(this)) >= amount_,
            "error: allowance exceeded!"
        );

        // Ticket Size respect: amountAfterTakeFee % ticketSize == 0
        require(
            amount_ > ticketSize &&
                amount_.sub(amount_.mul(jackpotPercent).div(100)).mod(
                    ticketSize
                ) ==
                0,
            "must respect ticketSize"
        );

        // Take join tax
        uint256 amountToContract = takeFee(
            sender,
            jackpotWallet,
            amount_,
            jackpotPercent
        );

        bool transferSuccess = tokenContract.transferFrom(
            sender,
            address(this),
            amountToContract
        );
        require(transferSuccess, "error: not deposited");

        uint256 balanceBefore = balance[sender];
        uint256 balanceAfter = balanceBefore.add(amountToContract);
        balance[sender] = balanceAfter;

        return true;
    }

    // Get balance as wei and as ticket
    function getBalance(address adr_)
        external
        view
        returns (uint256 balanceAmount, uint256 ticketAmount)
    {
        return (balance[adr_], balance[adr_].div(ticketSize));
    }

    // Take fee (based on feePercent)
    function takeFee(
        address sender_,
        address receiver_,
        uint256 amount_,
        uint8 percent_
    ) internal returns (uint256) {
        uint256 feeAmount = amount_.mul(percent_).div(100);
        uint256 remainAmount = amount_.sub(feeAmount);

        bool takeFeeStatus = tokenContract.transferFrom(
            sender_,
            receiver_,
            feeAmount
        );
        require(takeFeeStatus, "error: failed take fee");

        return remainAmount;
    }

    // User withdraw all his/her balance
    function withdrawAll() external withdrawable returns (bool status) {
        address withdrawer = msg.sender;
        require(balance[withdrawer] > 0, "error: balance is empty!");

        uint256 withdrawAmount = balance[withdrawer];
        balance[withdrawer] = 0;

        bool transferStatus = tokenContract.transfer(
            withdrawer,
            withdrawAmount
        );
        require(transferStatus, "error: transfer failed");

        return true;
    }

    function processBalances()
        external
        lockAll
        onlyOwner
        returns (bool status)
    {
        uint256 totalA = 0;
        uint256 totalB = 0;
        uint256 totalAAfter = 0;
        uint256 totalBAfter = 0;

        // Total balance each side
        for (uint256 a = 0; a < listA.length; a++) {
            totalAAfter = totalA.add(balance[listA[a]]);
            totalA = totalAAfter;
        }
        for (uint256 b = 0; b < listB.length; b++) {
            totalBAfter = totalB.add(balance[listB[b]]);
            totalB = totalBAfter;
        }

        // Calculate win / lose
        if (totalA > totalB) {
            bool clearStatus = clearBalance(listB);
            require(clearStatus, "error: failed clear");

            winProcess(listA, totalA, totalA.add(totalB));
            return true;
        } else if (totalB > totalA) {
            bool clearStatus = clearBalance(listA);
            require(clearStatus, "error: failed clear");

            winProcess(listB, totalB, totalA.add(totalB));
            return true;
        }

        return false;
    }

    function winProcess(
        address[] memory listWin,
        uint256 balanceWin,
        uint256 balanceTotal
    ) internal returns (bool status) {
        for (uint256 i = 0; i < listWin.length; i++) {
            address user = listWin[i];
            uint256 balanceUserWin = 0;

            balanceUserWin = (balance[user].div(balanceWin)).mul(balanceTotal);
            balance[user] = balanceUserWin;
        }
        return true;
    }

    function clearBalance(address[] memory list)
        internal
        returns (bool status)
    {
        for (uint256 i = 0; i < list.length; i++) {
            balance[list[i]] = 0;
        }
        return true;
    }

    // Return list address of each side
    function getList()
        external
        view
        onlyOwner
        returns (address[] memory listSideA, address[] memory listSideB)
    {
        return (listA, listB);
    }

    function clearAll() external lockAll onlyOwner returns (bool status) {
        bool clearBalanceA = clearBalance(listA);
        bool clearBalanceB = clearBalance(listB);

        bool clearA = clearArray(listA);
        bool clearB = clearArray(listB);

        if (clearBalanceA && clearBalanceB && clearA && clearB) {
            return true;
        } else {
            return false;
        }
    }

    function clearArray(address[] storage arr) internal returns (bool status) {
        for (uint256 i = 0; i < arr.length; i++) {
            arr.pop();
        }
        return true;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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
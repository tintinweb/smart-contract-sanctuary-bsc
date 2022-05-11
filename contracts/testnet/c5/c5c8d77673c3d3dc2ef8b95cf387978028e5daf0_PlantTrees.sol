/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

/**
 * @title Escrow
 * @dev Base escrow contract, holds funds designated for a payee until they
 * withdraw them.
 *
 * Intended usage: This contract (and derived escrow contracts) should be a
 * standalone contract, that only interacts with the contract that instantiated
 * it. That way, it is guaranteed that all Ether will be handled according to
 * the `Escrow` rules, and there is no need to check for payable functions or
 * transfers in the inheritance tree. The contract that uses the escrow as its
 * payment method should be its owner, and provide public methods redirecting
 * to the escrow's deposit and withdraw.
 */
contract Escrow is Ownable {
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private _deposits;

    function depositsOf(address payee) public view returns (uint256) {
        return _deposits[payee];
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     * @param payee The destination address of the funds.
     */
    function deposit(address payee) public payable virtual onlyOwner {
        uint256 amount = msg.value;
        _deposits[payee] += amount;
        emit Deposited(payee, amount);
    }

    /**
     * @dev Withdraw accumulated balance for a payee, forwarding all gas to the
     * recipient.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * @param payee The address whose funds will be withdrawn and transferred to.
     */
    function withdraw(address payable payee) public virtual onlyOwner {
        uint256 payment = _deposits[payee];

        _deposits[payee] = 0;

        payee.sendValue(payment);

        emit Withdrawn(payee, payment);
    }
}

pragma solidity 0.8.11;

    /*                 
    :::::::::  :::            :::     ::::    ::: :::::::::::         :::         ::::::::::: :::::::::  :::::::::: :::::::::: 
    :+:    :+: :+:          :+: :+:   :+:+:   :+:     :+:           :+: :+:           :+:     :+:    :+: :+:        :+:        
    +:+    +:+ +:+         +:+   +:+  :+:+:+  +:+     +:+          +:+   +:+          +:+     +:+    +:+ +:+        +:+        
    +#++:++#+  +#+        +#++:++#++: +#+ +:+ +#+     +#+         +#++:++#++:         +#+     +#++:++#:  +#++:++#   +#++:++#   
    +#+        +#+        +#+     +#+ +#+  +#+#+#     +#+         +#+     +#+         +#+     +#+    +#+ +#+        +#+        
    #+#        #+#        #+#     #+# #+#   #+#+#     #+#         #+#     #+#         #+#     #+#    #+# #+#        #+#        
    ###        ########## ###     ### ###    ####     ###         ###     ###         ###     ###    ### ########## ########## 
    */


contract PlantTrees is Pausable, Ownable {
    
    using SafeMath for uint256;

    bool private initialized = false;
    bool private isCompundingDay = false;
    bool private whiteListCompleted = false;
    uint256 private last48Hours = 2; //2 days

    mapping(address => uint256) private TreesMiners;
    mapping(address => uint256) private claimedTrees;
    mapping(address => uint256) private firstPlantedTrees;
    mapping(address => uint256) private lastPlantedTrees;
    mapping(address => uint256) private lastRePlantedTrees;
    mapping(address => uint256) private totalPlantedValue;
    mapping(address => bool) private lastRefRePlant;
    mapping(address => bool) private whiteList;
    mapping(address => address) private referrals;
    mapping(address => uint256) private referralsUsed;
    mapping(address => uint256) private referralsRewardsTotal;
    uint256 private TreesMarket;

    //Taxes for Harvest action on rePlant days
    //Day 1 90%, Day 2 = 80%, Day 3 = 70%, Day 4 = 50% , Day 5 = 40%, Day 6 = 20% Tax,
    //Day 7 = No extra tax  0%
    //Taxes always goes to Contract
    //Taxes subtract the regulare fees dev 2% , team 1% , Treasury 1%
    uint256[] private EXTRA_TAXES_PERCENTAGES = [90, 80, 70, 50, 40, 20, 0];

    //set a tax if player didnt compund for the last 48 hours on harvest day - Day 7
    uint256 private Tax_No_RePlant_Last48Hours = 95;

    //to calcualte the tree market value
    uint256 private MAX_INVESTMENT = 100000000000000000000 wei; // 100 AVAX
    uint256 private MIN_INVESTMENT = 100000000000000000 wei; // 0.1 AVAX
    uint256 private WL_MIN_INVESTMENT = 1000000000000000000 wei; // 1.0 AVAX
    uint256 public totalExtraTaxBalance = 0;
    uint256 private Plant_Trees_1MINERS = 1080000;
    uint256 private TSN = 10000;
    uint256 private TSNH = 5000;

    //regular fees
    //dev 2%, team 1%
    uint256 private Dev_Percentage = 2;
    uint256 private Team_Percentage = 1;
    uint256 private Treasury_Percentage = 1;

    struct FEE {
        uint256 Total;
        uint256 Dev;
        uint256 Team;
        uint256 Treasury;
    }

    address internal PlantATree_CONTRACT_ADDRESS;
    address payable devAddress;
    address payable teamAddress;
    address payable treasuryAddress;

    //initlize the dev wallets and white list
    constructor(
        address payable devAddress_,
        address payable teamAddress_,
        address payable treasuryAddress_
    ) public {
        devAddress = devAddress_;
        teamAddress = teamAddress_;
        treasuryAddress = treasuryAddress_;
    }

    //intilizlize the contract and set the seed market
    function InitContract() public onlyOwner {
        seedMarket();
        initialized = true;
    }

    function diffTimeSinceFirstPlantTree() public view returns (uint256) {
        return SafeMath.sub(block.timestamp, firstPlantedTrees[msg.sender]);
    }

    function diffTimeSinceLastRePlantTree() public view returns (uint256) {
        return SafeMath.sub(block.timestamp, lastRePlantedTrees[msg.sender]);
    }

    function getMyReferralsUsedCount() public view returns (uint256) {
        return referralsUsed[msg.sender];
    }

    function getMyReferralsRewardsTotal() public view returns (uint256) {
        return referralsRewardsTotal[msg.sender];
    }

    //get compunding day current tax
    function getCurrentDayExtraTax(bool include48HoursTax)
        public
        view
        returns (uint256)
    {
        //return tax 0 if there no first transaction for the user
        if (firstPlantedTrees[msg.sender] == 0) return 0;

        // diffTime / 60 / 60 / 24; to get the days
        uint256 diffDays = SafeMath.div(
            SafeMath.div(SafeMath.div(diffTimeSinceFirstPlantTree(), 60), 60),
            24
        );
        uint256 dayNumber = SafeMath.mod(diffDays, 7);
        uint256 currentDayTax = EXTRA_TAXES_PERCENTAGES[dayNumber];
        if (include48HoursTax)
            if (hasNoCompoundLast48Hours()) {
                //get higher tax
                if (Tax_No_RePlant_Last48Hours > currentDayTax)
                    currentDayTax = Tax_No_RePlant_Last48Hours;
            }
        return currentDayTax;
    }

    //check last 48 hours if user has one compound atleast
    function hasNoCompoundLast48Hours() public view returns (bool) {
        //return tax 0 if there no last transaction for the user
        if (lastRePlantedTrees[msg.sender] == 0) return false;

        uint256 diffDays = SafeMath.div(
            SafeMath.div(SafeMath.div(diffTimeSinceLastRePlantTree(), 60), 60),
            24
        );

        return (diffDays >= last48Hours);
    }

    //check of day is for replant or harvest
    function isHarvestDay() public view returns (bool) {
        uint256 tax = getCurrentDayExtraTax(true);
        return (tax == 0);
    }

    //allow everyone to join the contract
    function setWhiteListCompleted() public onlyOwner {
        require(initialized, "Contract not initialized yet");
        require(whiteListCompleted == false, "whiteList is Already Completed");
        //this method only set whiteListCompleted to true only
        //you can't set it to false ever at all
        whiteListCompleted = true;
    }

    //pass array of addresses in one function to reduce the fee cost as transaction
    function addWhiteList(address[] memory wls) public onlyOwner {
        require(initialized, "Contract not initialized yet");
        for (uint256 w = 0; w < wls.length; w++) {
            whiteList[wls[w]] = true;
        }
    }

    //remove wl adrress
    function removeWhiteList(address[] memory wls) public onlyOwner {
        require(initialized, "Contract not initialized yet");
        for (uint256 w = 0; w < wls.length; w++) {
            whiteList[wls[w]] = false;
        }
    }

    //Plant A Tree //a deposit value in AVAX
    function PlantATree(address ref) public payable whenNotPaused {
        require(initialized, "Contract not initialized yet");
        require(
            whiteListCompleted == true || whiteList[msg.sender] == true,
            "Your wallet is not White Listed."
        );
        require(
            whiteListCompleted == true ||
                (whiteList[msg.sender] == true &&
                    msg.value >= WL_MIN_INVESTMENT),
            "Minimum investment is 1.0 AVAX for your White List wallet"
        );
        require(msg.value <= MAX_INVESTMENT, "Max investment is 100 AVAX");
        require(msg.value >= MIN_INVESTMENT, "Minimum investment is 0.1 AVAX");

        uint256 treesBought = calculateTreeBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );

        //total balance value for planted trees
        totalPlantedValue[msg.sender] = SafeMath.add(
            totalPlantedValue[msg.sender],
            msg.value
        );

        //no extra tax on plant A tree
        //awlays set it to zero
        //because it is a deposit
        FEE memory treeFees = calculateTotalFees(treesBought, 0);
        treesBought = SafeMath.sub(treesBought, treeFees.Total);

        //Dev 2% Team 1% fees and 1% tressuery
        //calculate and tranfer fees
        FEE memory fees = calculateTotalFees(msg.value, 0);
        devAddress.transfer(fees.Dev);
        teamAddress.transfer(fees.Team);
        treasuryAddress.transfer(fees.Treasury);

        claimedTrees[msg.sender] = SafeMath.add(
            claimedTrees[msg.sender],
            treesBought
        );

        //set block chain time evry time user plant a tree
        firstPlantedTrees[msg.sender] = block.timestamp;

        lastRefRePlant[msg.sender] = false;

        RePlantATree(ref);
    }

    //compound pending rewards
    function RePlantATree(address ref) public {
        require(initialized, "Contract not initialized yet");
        require(
            firstPlantedTrees[msg.sender] > 0,
            "You haven't planted a tree"
        );

        if (ref == msg.sender) {
            ref = address(0);
        }

        if (
            referrals[msg.sender] == address(0) &&
            referrals[msg.sender] != msg.sender
        ) {
            referrals[msg.sender] = ref;
        }

        uint256 treesUsed = getMyTrees();
        uint256 newMiners = SafeMath.div(treesUsed, Plant_Trees_1MINERS);

        TreesMiners[msg.sender] = SafeMath.add(
            TreesMiners[msg.sender],
            newMiners
        );
        claimedTrees[msg.sender] = 0;
        lastPlantedTrees[msg.sender] = block.timestamp;

        //send trees to their referrals only once
        //referral rewards around 12% (trees divide 8) percentage value would change according ot the trees amount
        if (lastRefRePlant[msg.sender] == false) {
            uint256 rewardsCut = SafeMath.div(treesUsed, 8);
            claimedTrees[referrals[msg.sender]] = SafeMath.add(
                claimedTrees[referrals[msg.sender]],
                rewardsCut
            );
            //save referrals used count //save total rewards cut
            if (ref != msg.sender) {
                referralsUsed[referrals[msg.sender]] = SafeMath.add(
                    referralsUsed[referrals[msg.sender]],
                    1
                );
                referralsRewardsTotal[referrals[msg.sender]] = SafeMath.add(
                    referralsRewardsTotal[referrals[msg.sender]],
                    rewardsCut
                );
            }

            lastRefRePlant[msg.sender] = true;
        }

        //boost trees market 20% (trees divide 5) percentage value would change according ot the trees amount
        //trees market is the main factor of trees trading math
        TreesMarket = SafeMath.add(TreesMarket, SafeMath.div(treesUsed, 5));

        //save last replanted tree time always
        lastRePlantedTrees[msg.sender] = block.timestamp;
    }

    //claim pending rewards
    function HarvestTrees() public {
        require(initialized, "Contract not initialized yet");

        uint256 hasTrees = getMyTrees();
        require(hasTrees > 0, "You have no trees");

        uint256 treeValue = calculateTreeSell(hasTrees);
        claimedTrees[msg.sender] = 0;
        lastPlantedTrees[msg.sender] = block.timestamp;
        TreesMarket = SafeMath.add(TreesMarket, hasTrees);

        //calculate fees and transfer
        uint256 todayTax = getCurrentDayExtraTax(true);
        FEE memory fees = calculateTotalFees(treeValue, todayTax);

        //transfer fees
        devAddress.transfer(fees.Dev);
        teamAddress.transfer(fees.Team);
        treasuryAddress.transfer(fees.Treasury);

        //to track total extra tax on smart contract
        totalExtraTaxBalance = SafeMath.add(
            totalExtraTaxBalance,
            fees.Treasury
        );

        //reset firstPlantedTrees and lastRePlantedTrees to zero on harvest
        firstPlantedTrees[msg.sender] = block.timestamp;
        lastRePlantedTrees[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(SafeMath.sub(treeValue, fees.Total));
    }

    //get total balance for planted trees
    function totalPlantedBalance() public view returns (uint256) {
        return totalPlantedValue[msg.sender];
    }

    function TreesRewards() public view returns (uint256) {
        uint256 hasTrees = getMyTrees();
        return calculateTreeSell(hasTrees);
    }

    //trade balancing algorithm
    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) public view returns (uint256) {
        return
            SafeMath.div(
                SafeMath.mul(TSN, bs),
                SafeMath.add(
                    TSNH,
                    SafeMath.div(
                        SafeMath.add(
                            SafeMath.mul(TSN, rs),
                            SafeMath.mul(TSNH, rt)
                        ),
                        rt
                    )
                )
            );
    }

    function calculateTreeSell(uint256 trees) public view returns (uint256) {
        return calculateTrade(trees, TreesMarket, address(this).balance);
    }

    function calculateTreeBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, TreesMarket);
    }

    function calculateTreeBuySimple(uint256 eth) public view returns (uint256) {
        return calculateTreeBuy(eth, address(this).balance);
    }

    function calculateTotalFees(uint256 amount, uint256 extraTaxPercentage)
        private
        view
        returns (FEE memory)
    {
        FEE memory fees;
        //calculate regular fees
        fees.Dev = SafeMath.div(SafeMath.mul(amount, Dev_Percentage), 100);
        fees.Team = SafeMath.div(SafeMath.mul(amount, Team_Percentage), 100);
        fees.Treasury = SafeMath.div(
            SafeMath.mul(amount, Treasury_Percentage),
            100
        );

        //subtract the regular fees from the total fees
        fees.Total = SafeMath.add(
            SafeMath.add(fees.Dev, fees.Team),
            fees.Treasury
        );

        //subtract also the extra taxes from the total fees //they must stay in the contract
        if (extraTaxPercentage > 0) {
            uint256 extraTaxStayValue = SafeMath.div(
                SafeMath.mul(amount, extraTaxPercentage),
                100
            );
            fees.Total = SafeMath.add(fees.Total, extraTaxStayValue);
        }

        return fees;
    }

    function seedMarket() private onlyOwner{
        require(TreesMarket == 0);
        TreesMarket = 108000000000;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners() public view returns (uint256) {
        return TreesMiners[msg.sender];
    }

    function getMyTrees() public view returns (uint256) {
        return
            SafeMath.add(
                claimedTrees[msg.sender],
                getTreesSinceLastPlant(msg.sender)
            );
    }

    function getTreesSinceLastPlant(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(
            Plant_Trees_1MINERS,
            SafeMath.sub(block.timestamp, lastPlantedTrees[adr])
        );
        return SafeMath.mul(secondsPassed, TreesMiners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    //Only used to prevent new deposits (plant a tree) during an emergency situation
    //pauseContract will not affect any other fucntions because whenNotPaused is not there next to the functions
    //except PlantATree
    function pauseContract() public onlyOwner {
        _pause();
    }

    function resumeContract() public onlyOwner {
        _unpause();
    }
}
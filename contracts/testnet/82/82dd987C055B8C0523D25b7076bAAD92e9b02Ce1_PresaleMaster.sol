///SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

/**
 * @title Elixir Launchpad tokens pre-sale
 * @author Satoshis.games
 * @notice this contract manages the pre-sale of tokens at an Elixir Launchpad IGO event
 * @dev
 */
contract PresaleMaster is
    Initializable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// PreSale Identification
    uint256 public presaleID;
    /// PreSale number of tiers
    uint256 public noOfTiers;
    // Presale status
    bool private cancelledStatus;

    // ADDRESSES
    /// Elixir platform account that collects the presales
    address public treasury;
    /// Elixir platform owner
    address public owner;
    /// BUSD token address
    address public addressBUSD;

    // DATES
    /// start presale time
    uint256 public presaleStartTime;
    /// end presale time
    uint256 public presaleEndTime;

    /// Max cap in BUSD for the whole presale
    uint256 public presaleMaxCap;
    /// Total supply of project tokens for the whole presale
    uint256 public presaleSupply;
    /// total presale BUSD received
    uint256 public totalBUSDCollected;
    /// total fees collected
    uint256 public totalFeesCollected;
    /// total user investors count
    uint256 public totalInvestors;

    // TIERS AND USERS

    /// Info for each tier in the presale
    struct TiersInfo {
        uint256 maxSpots; // Maximum number of spots available in the Tier
        uint256 allocation; // Allocation per user
        uint256 energyThreshold; // Minimum amount of energy to participate in the Tier
        uint256 fee; // Tier Fee
        uint256 spotsCount; // Number of users in the tier
        uint256 amountRaised; // Amount raised in the tier
    }

    /// Info of each participant in the presale
    struct UserInfo {
        uint256 tier; // Tier to which the user belongs
        uint256 investedAmount; // Amount invested by the user.
    }

    // Map of Tiers info
    mapping(uint256 => TiersInfo) public tierDetails;
    // Map of investor user information
    mapping(address => UserInfo) public investorDetails;
    // iterable array of participant users
    address[] private investorsList;

    // EVENTS
    event tiersUpdated(address _user);
    event userAddedToWhitelist(address _user, uint256 _tier);
    event userBatchAddedToWhitelist(uint256 _usersAmount);
    event userInvestment(address indexed _to, uint256 _amount);
    event presaleCancelled(address _sender, uint256 _timestamp);
    event userRefunded(address _user, uint256 _amount, uint256 _timestamp);

    // MODIFIERS

    /**
     * @notice check if the caller is the owner of the contract
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /**
     * @notice Make sure buyer has provided the right allowance
     * @param _allower: sender address
     * @param _amount: amount to transfer
     */
    modifier _hasAllowance(address _allower, uint256 _amount) {
        uint256 ourAllowance = IERC20Upgradeable(addressBUSD).allowance(
            _allower,
            address(this)
        );
        require(_amount <= ourAllowance, "buyTokens: Allowance is too low");
        _;
    }

    // INITIALIZATION

    /**
     * @notice IGO sale and tiers initilization
     * @param _owner  Elixir platform owner
     * @param _treasury Elixir platform account that collects the presales fees
     * @param _presaleID PreSale identification
     * @param _noOfTiers Presale number of tiers
     * @param _presaleMaxCap Max cap in BUSD for the whole sale
     * @param _presaleSupply Total supply of project tokens for the whole presale
     * @param _presaleStartTime Start sale time
     * @param _presaleEndTime End sale time
     * @param _addressBUSD BUSD token address
     */
    function initialize(
        address _owner,
        address _treasury,
        uint256 _presaleID,
        uint256 _noOfTiers,
        uint256 _presaleMaxCap,
        uint256 _presaleSupply,
        uint256 _presaleStartTime,
        uint256 _presaleEndTime,
        address _addressBUSD
    ) public initializer {
        // addresses check
        require(_owner != address(0), "Zero address");
        owner = _owner;
        require(_treasury != address(0), "Zero project owner address");
        treasury = _treasury;
        require(_addressBUSD != address(0), "Zero token address");
        addressBUSD = _addressBUSD;

        presaleID = _presaleID;
        noOfTiers = _noOfTiers;
        presaleMaxCap = _presaleMaxCap;
        presaleSupply = _presaleSupply;
        presaleStartTime = _presaleStartTime;
        presaleEndTime = _presaleEndTime;
        cancelledStatus = false;
    }

    // Tiers Actions

    /**
     * @notice Creates or updates the tier info scheme
     * @param _maxSpots; // Maximum number of spots available in the Tier
     * @param _allocation; // Allocation in BUSD per user
     * @param _energyThreshold; // Minimum amount of energy to participate in the Tier
     * @param _fee; // Tier Fee
     * @dev
     */
    function updateTiers(
        uint256[] calldata _maxSpots,
        uint256[] calldata _allocation,
        uint256[] calldata _energyThreshold,
        uint256[] calldata _fee
    ) external onlyOwner {
        require(
            _maxSpots.length == _allocation.length &&
                _allocation.length == _energyThreshold.length &&
                _energyThreshold.length == _fee.length,
            "Presale: invalid tiers data"
        );
        require(_maxSpots.length == noOfTiers, "Presale: invalid no of tiers");

        for (uint i = 0; i < _maxSpots.length; i++) {
            require(_allocation[i] > 0, "Presale: invalid allocation amount");
            require(
                _energyThreshold[i] > 0,
                "Presale: invalid energy cation amount"
            );

            // tiers no starts at 1, so is index +1
            tierDetails[i + 1] = TiersInfo({
                maxSpots: _maxSpots[i],
                allocation: _allocation[i],
                energyThreshold: _energyThreshold[i],
                fee: _fee[i],
                spotsCount: 0,
                amountRaised: 0
            });
        }
        emit tiersUpdated(msg.sender);
    }

    /**
     * @notice Return the tiers scheme
     * @return the order of the returned arrays is:
     * @return maxSpots, minAllocation, maxAllocation, energyThreshold, fee
     * @dev
     */
    function getTierScheme()
        external
        view
        onlyOwner
        returns (
            uint[] memory,
            uint[] memory,
            uint[] memory,
            uint[] memory
        )
    {
        uint[] memory maxSpots = new uint[](noOfTiers);
        uint[] memory allocation = new uint[](noOfTiers);
        uint[] memory energyThreshold = new uint[](noOfTiers);
        uint[] memory fee = new uint[](noOfTiers);

        for (uint i = 0; i < noOfTiers; i++) {
            maxSpots[i] = tierDetails[i + 1].maxSpots;
            allocation[i] = tierDetails[i + 1].allocation;
            energyThreshold[i] = tierDetails[i + 1].energyThreshold;
            fee[i] = tierDetails[i + 1].fee;
        }

        return (maxSpots, allocation, energyThreshold, fee);
    }

    /**
     * @notice Returns the available spots in the informed tier
     * @param _tier tier number
     * @return uint256 available espots
     */
    function getAvailableSpot(uint256 _tier) external view returns (uint256) {
        return tierDetails[_tier].maxSpots - tierDetails[_tier].spotsCount;
    }

    // dates update functions

    /**
     * @notice Updates sale start date
     * @param _newSaleStart start sale time
     */
    function updateStartTime(uint256 _newSaleStart) external onlyOwner {
        require(presaleStartTime > block.timestamp, "Sale already started");
        require(
            _newSaleStart > block.timestamp,
            "The start date cannot be less than the current date"
        );
        require(
            _newSaleStart < presaleStartTime,
            "The start date cannot be greater than the end date"
        );
        presaleStartTime = _newSaleStart;
    }

    /**
     * @notice Updates sale end date
     * @param _newSaleEnd end sale time
     */
    function updateEndTime(uint256 _newSaleEnd) external onlyOwner {
        require(
            _newSaleEnd > presaleStartTime && _newSaleEnd > block.timestamp,
            "The end date of the sale cannot be less than the start date"
        );
        presaleEndTime = _newSaleEnd;
    }

    // Tokens Presale

    /**
     * @notice User chooses spot and pays the corresponding BUSD
     * allocation in a single transaction.
     * It sends collected BUSD to treasury address
     * @param _amount: amount to transfer
     */
    function buyTokens(uint256 _amount, uint256 _tier)
        external
        nonReentrant
        whenNotPaused
        _hasAllowance(msg.sender, _amount)
        returns (bool)
    {
        // check tier
        require(_tier > 0 && _tier <= noOfTiers, "buyTokens: invalid tier");

        // check dates
        require(
            block.timestamp >= presaleStartTime,
            "buyTokens: Presale not started yet "
        );
        require(block.timestamp <= presaleEndTime, "buyTokens: Presale ended");

        // check available spots in tier
        require(
            tierDetails[_tier].maxSpots > tierDetails[_tier].spotsCount,
            "buyTokens: no more available spots"
        );

        // check if the user has already invested
        require(
            investorDetails[msg.sender].tier == 0,
            "buyTokens: The user already participated in the Presale"
        );

        // check if the deposit exceeds the sale max cap limit
        require(
            totalBUSDCollected + _amount <= presaleMaxCap,
            "buyTokens: purchase would exceed sale max cap"
        );

        // check if the deposit equals the tier allocation
        require(
            _amount == tierDetails[_tier].allocation,
            "buyTokens: investment does not correspond to the tier allocation"
        );

        // Calculates fee and net amount
        uint256 feeAmount = (_amount * tierDetails[_tier].fee) / 10000;
        uint256 netAmount = _amount - feeAmount;

        // update totals
        totalBUSDCollected += netAmount;
        totalFeesCollected += feeAmount;
        totalInvestors++;
        // update tier info
        tierDetails[_tier].amountRaised += netAmount;
        tierDetails[_tier].spotsCount++;
        // update investor info
        investorDetails[msg.sender].tier = _tier;
        investorDetails[msg.sender].investedAmount = netAmount;
        // add address to iterable list
        investorsList.push(msg.sender);

        // The full amount is transferred to the treasury account,
        // the contract keep records the fees calculated
        IERC20Upgradeable(addressBUSD).safeTransferFrom(
            msg.sender,
            treasury,
            _amount
        );

        return true;
    }

    /**
     * @notice returns the investors in the Tier
     * @param _tier The tier from which users will be returned
     * @return array of investors users
     */
    function getInvestorsFromTier(uint256 _tier)
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        // check tier
        require(
            _tier > 0 && _tier <= noOfTiers,
            "getInvestorsFromTier: invalid tier"
        );
        uint tierCount = tierDetails[_tier].spotsCount;
        address[] memory tierInvestors = new address[](tierCount);
        uint k = 0;
        for (uint i = 0; i < investorsList.length; i++) {
            if (investorDetails[investorsList[i]].tier == _tier) {
                tierInvestors[k] = investorsList[i];
                k++;
            }
        }
        return tierInvestors;
    }

    // Cancel and Refund

    /**
     * @notice Cancel the presale, trigger the stopped state and
     * set the presale end time to current timestamp.
     * @notice this action is irreversible.
     */
    function cancelPresale() external onlyOwner returns (bool) {
        presaleEndTime = block.timestamp;
        cancelledStatus = true;
        if (!paused()) _pause();
        emit presaleCancelled(msg.sender, presaleEndTime);
        return true;
    }

    /**
     * @notice the user is refunded in the unfortunate event
     * that the presale is cancelled.
     * The amount to be reimbursed is the amount invested minus the fees.
     * @notice The canceled status must be true,
     * the pre-sale must be completed, and the contract must be paused.
     */
    function refund() external nonReentrant whenPaused returns (bool) {
        // check if presale is canceled
        require(cancelledStatus, "refund: The presale has not been canceled");
        require(
            presaleEndTime <= block.timestamp,
            "refund: The presale has not ended"
        );
        // check if the user has invested
        require(
            investorDetails[msg.sender].tier != 0,
            "refund: The user has not participated in the presale"
        );

        // look for invested amount
        uint256 invested = investorDetails[msg.sender].investedAmount;

        // check if the contract has enough allowance to transfer to user
        uint256 allowance = IERC20Upgradeable(addressBUSD).allowance(
            treasury,
            address(this)
        );
        require(invested <= allowance, "refund: Allowance is too low");

        // reset user invest data
        investorDetails[msg.sender].investedAmount = 0;
        investorDetails[msg.sender].tier = 0;
        emit userRefunded(msg.sender, invested, block.timestamp);

        // approve and transfer
        IERC20Upgradeable(addressBUSD).approve(msg.sender, invested);
        IERC20Upgradeable(addressBUSD).safeTransferFrom(
            treasury,
            msg.sender,
            invested
        );

        return true;
    }

    /**
     * @dev Triggers stopped state.
     * Requirements:
     * - The contract must not be paused.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     * Requirements:
     * - The contract must be paused.
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
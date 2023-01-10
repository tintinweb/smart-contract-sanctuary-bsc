// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/*
 * @author ~ 🅧🅘🅟🅩🅔🅡 ~ (https://twitter.com/Xipzer | https://t.me/Xipzer)
 *
 * ░██████╗░█████╗░██╗░░░░░░█████╗░██████╗░  ██╗░░██╗██╗███╗░░██╗░██████╗░██████╗░░█████╗░███╗░░░███╗
 * ██╔════╝██╔══██╗██║░░░░░██╔══██╗██╔══██╗  ██║░██╔╝██║████╗░██║██╔════╝░██╔══██╗██╔══██╗████╗░████║
 * ╚█████╗░██║░░██║██║░░░░░███████║██████╔╝  █████═╝░██║██╔██╗██║██║░░██╗░██║░░██║██║░░██║██╔████╔██║
 * ░╚═══██╗██║░░██║██║░░░░░██╔══██║██╔══██╗  ██╔═██╗░██║██║╚████║██║░░╚██╗██║░░██║██║░░██║██║╚██╔╝██║
 * ██████╔╝╚█████╔╝███████╗██║░░██║██║░░██║  ██║░╚██╗██║██║░╚███║╚██████╔╝██████╔╝╚█████╔╝██║░╚═╝░██║
 * ╚═════╝░░╚════╝░╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝  ╚═╝░░╚═╝╚═╝╚═╝░░╚══╝░╚═════╝░╚═════╝░░╚════╝░╚═╝░░░░░╚═╝
 *
 * Solar Kingdom [Gen 1] - Static Rewards Pool
 *
 * Telegram: https://t.me/SolarFarmMinerOfficial
 * Twitter: https://twitter.com/SolarFarmMiner
 * Landing: https://solarfarm.finance/
 * dApp: https://app.solarfarm.finance/
 */

interface IFrenzyHost
{
    function contribute(address engineer, uint amount, uint time) external;
    function getCurrentSessionStatus() external view returns (bool);
}

contract SolarKingdom is OwnableUpgradeable
{
    IFrenzyHost public frenzyHost;

    bool kingdomActive;
    uint fuelCellRate;

    uint gridInFee;
    uint gridOutFee;

    uint referralBonus;
    uint firstDepositBonus;

    uint minimumDeposit;
    uint maximumWallet;

    uint allowanceThreshold;
    uint minimumFusionThreshold;
    uint completeReferralThreshold;

    uint dailyRewardsFixedThreshold;
    uint dailyRewardsRatioThreshold;

    address payable private gridGiveaway;
    address payable private gridTechnician;

    uint totalEngineers;

    mapping (address => Engineer) private engineers;

    struct Engineer
    {
        uint fuelCells;
        uint lastFusedTimestamp;
        uint lastHarvestedTimestamp;
        uint lastActionTimestamp;
        uint allowance;
        uint freshValue;
        uint totalDeposited;
        uint totalHarvested;
        address referrer;
        address[] basicReferrals;
        address[] completeReferrals;
    }

    event FuelCellsPurchased(uint value, uint amount, uint timestamp, uint tvl);
    event FuelCellsFused(uint value, uint amount, uint timestamp);
    event FuelCellsHarvested(uint value, uint timestamp);
    event FrenzyContribution(uint amount, uint timestamp);

    modifier onlyFrenzy
    {
        require(msg.sender == address(frenzyHost), "SolarGuard: You are not the frenzy operator!");
        _;
    }

    function initialize() external initializer
    {
        __Ownable_init();

        kingdomActive = false;
        fuelCellRate = 10000000000000; // 1 Fuel Cell == 0.00001 BNB

        gridInFee = 30; // 3%
        gridOutFee = 60; // 6%

        referralBonus = 50; // 5%
        firstDepositBonus = 50; // 5%

        minimumDeposit = 10000000000000000; // 0.01 BNB
        maximumWallet = 200000000000000000000; // 200 BNB

        allowanceThreshold = 3; // 3x
        minimumFusionThreshold = 10000000000000000; // 0.01 BNB
        completeReferralThreshold = 500000000000000000; // 0.5 BNB

        dailyRewardsFixedThreshold = 5000000000000000000; // 5 BNB
        dailyRewardsRatioThreshold = 25; // 2.5%

        gridGiveaway = payable(0xaD7933D5d271997547767139b7bb505fd7DcC016);
        gridTechnician = payable(0x14dF95F90E7A7A4239539297A822AF025ebC0387);
    }

    function getTotalValueLocked() public view returns (uint)
    {
        return address(this).balance;
    }

    function getEngineerData(address engineer) public view returns (Engineer memory)
    {
        return engineers[engineer];
    }

    function getMaxWalletStatus(address engineer) public view returns (bool)
    {
        return engineers[engineer].fuelCells >= computeBuy(maximumWallet);
    }

    function getSellTier(address engineer) public view returns (uint)
    {
        uint duration = calculateDaysSinceLastHarvest(engineer);

        return duration % 10;
    }

    function getReactorTier(address engineer) public view returns (uint)
    {
        uint totalReferrals = engineers[engineer].completeReferrals.length;

        if (totalReferrals < 5)
            return 1;
        if (totalReferrals < 10)
            return 2;
        if (totalReferrals < 20)
            return 3;
        if (totalReferrals < 40)
            return 4;
        if (totalReferrals < 80)
            return 5;
        if (totalReferrals < 160)
            return 6;
        if (totalReferrals < 320)
            return 7;

        return 8;
    }

    function getRewardsMultiplier(address engineer) public view returns (uint)
    {
        uint totalReferrals = engineers[engineer].completeReferrals.length;

        if (totalReferrals < 5)
            return 40;
        if (totalReferrals < 10)
            return 45;
        if (totalReferrals < 20)
            return 50;
        if (totalReferrals < 40)
            return 55;
        if (totalReferrals < 80)
            return 60;
        if (totalReferrals < 160)
            return 65;
        if (totalReferrals < 320)
            return 70;

        return 75;
    }

    function checkRewardsBalance(address engineer) public view returns (uint)
    {
        return computeHarvest(checkRewards(engineer));
    }

    function setFrenzyHost(address frenzyAddress) public onlyOwner
    {
        frenzyHost = IFrenzyHost(frenzyAddress);
    }

    function activateSolarKingdom() public onlyOwner
    {
        require(!kingdomActive, "SolarGuard: Solar Kingdom is already active!");

        kingdomActive = true;
    }

    function airdropTokenMigrators(address migrator, uint amount) public onlyOwner
    {
        Engineer storage engineer = engineers[migrator];

        engineer.totalDeposited = amount / 3;
        engineer.fuelCells = computeFraction(computeBuy(amount), 1000 - gridInFee);
        engineer.freshValue = amount / 3;
        engineer.allowance = amount;
        engineer.lastActionTimestamp = block.timestamp;
        engineer.lastHarvestedTimestamp = block.timestamp;
    }

    function claimFrenzyPrize(address engineer, uint quantity) public onlyFrenzy
    {
        engineers[engineer].fuelCells += quantity;
    }

    function contributeToFrenzy(uint amount) public
    {
        require(kingdomActive, "SolarGuard: Solar Kingdom must be active!");
        require(address(frenzyHost) != address(0), "SolarGuard: Sorry Engineer, a frenzy host has not been set yet!");
        require(frenzyHost.getCurrentSessionStatus(), "SolarGuard: Sorry Engineer, there is no active frenzy session at the moment!");
        require(amount == 5000 || amount == 10000, "SolarGuard: Sorry Engineer, this frenzy session only supports 5000 or 10000 fuel cell deposits!");

        uint time;

        if (amount == 5000)
        {
            require(engineers[msg.sender].fuelCells >= 5000, "SolarGuard: Sorry Engineer, you don't have enough fuel cells to contribute!");
            engineers[msg.sender].fuelCells -= 5000;
            time = 600;
        }
        else
        {
            require(engineers[msg.sender].fuelCells >= 10000, "SolarGuard: Sorry Engineer, you don't have enough fuel cells to contribute!");
            engineers[msg.sender].fuelCells -= 10000;
            time = 1800;
        }

        frenzyHost.contribute(msg.sender, amount, time);

        emit FrenzyContribution(amount, block.timestamp);
    }

    function buyFuelCells(address referrer) public payable
    {
        require(kingdomActive, "SolarGuard: Solar Kingdom must be active!");

        Engineer storage engineer = engineers[msg.sender];
        Engineer storage supervisor = engineers[referrer];

        require(msg.value >= minimumDeposit, "SolarGuard: Sorry Engineer, your deposit does not meet the minimum amount!");
        require(engineer.totalDeposited + msg.value <= maximumWallet, "SolarGuard: Sorry Engineer, your deposit exceeds the maximum wallet limit!");
        require(referrer == address(0) || referrer == msg.sender || supervisor.totalDeposited > 0, "SolarGuard: Sorry Engineer, your referrer must be an investor!");

        if (engineer.totalDeposited == 0)
            totalEngineers++;

        engineer.totalDeposited += msg.value;

        uint newFreshValue = 0;

        if (engineer.totalHarvested < engineer.totalDeposited)
            newFreshValue = engineer.totalDeposited - engineer.totalHarvested;

        if (newFreshValue >= engineer.freshValue)
        {
            engineer.allowance = newFreshValue * allowanceThreshold;
            engineer.freshValue = newFreshValue;
        }
        else
            engineer.allowance += msg.value;

        uint totalFuelCells = computeBuy(msg.value);
        uint fuelCellsAcquired = computeFraction(totalFuelCells, 1000 - gridInFee);

        engineer.fuelCells += fuelCellsAcquired;

        if (engineer.referrer == address(0) && referrer != msg.sender && referrer != address(0))
        {
            engineer.referrer = referrer;
            supervisor.basicReferrals.push(msg.sender);

            if (engineer.lastActionTimestamp == 0)
                supervisor.fuelCells += computeFraction(totalFuelCells, firstDepositBonus);
        }

        if (engineer.referrer != address(0) && engineer.totalDeposited >= completeReferralThreshold && !checkReferral(referrer, msg.sender))
            supervisor.completeReferrals.push(msg.sender);

        distributeFees(computeFraction(msg.value, gridInFee), 0);

        if (engineer.lastActionTimestamp == 0)
        {
            engineer.lastActionTimestamp = block.timestamp;
            engineer.lastHarvestedTimestamp = block.timestamp;
        }
        else
            handleFusion(false);

        emit FuelCellsPurchased(msg.value, fuelCellsAcquired, block.timestamp, address(this).balance);
    }

    function fuse() public
    {
        require(kingdomActive, "SolarGuard: Solar Kingdom must be active!");

        handleFusion(true);
    }

    function harvest() public
    {
        require(kingdomActive, "SolarGuard: Solar Kingdom must be active!");

        Engineer storage engineer = engineers[msg.sender];

        require(engineer.totalDeposited > 0, "SolarGuard: Sorry Engineer, you must have buy fuel cells in order to harvest!");
        require(engineer.allowance > 0, "SolarGuard: Sorry Engineer, you have completely depleted your allowance!");

        uint rewards = checkRewards(msg.sender);
        uint taxFee = computeFraction(rewards, gridOutFee);
        rewards -= taxFee;

        uint giveawayFee = calculateGiveawayTax(msg.sender, rewards);
        rewards = calculateHarvestTax(msg.sender, rewards);

        if (rewards >= engineer.allowance)
            rewards = engineer.allowance;

        engineer.allowance -= rewards;

        engineer.lastActionTimestamp = block.timestamp;
        engineer.lastHarvestedTimestamp = block.timestamp;

        distributeFees(taxFee, giveawayFee);
        payable (msg.sender).transfer(rewards);

        emit FuelCellsHarvested(rewards, block.timestamp);
    }

    function checkReferral(address supervisor, address engineer) private view returns (bool)
    {
        for (uint i = 0; i < engineers[supervisor].completeReferrals.length; i++)
            if (engineers[supervisor].completeReferrals[i] == engineer)
                return true;

        return false;
    }

    function checkMinimum(uint a, uint b) private pure returns (uint)
    {
        return a < b ? a : b;
    }

    function computeFraction(uint amount, uint numerator) private pure returns (uint)
    {
        return (amount * numerator) / 1000;
    }

    function computeBuy(uint amount) private view returns (uint)
    {
        return amount / fuelCellRate;
    }

    function computeHarvest(uint amount) private view returns (uint)
    {
        return amount * fuelCellRate;
    }

    function calculateDaysSinceLastHarvest(address engineer) private view returns (uint)
    {
        return (block.timestamp - engineers[engineer].lastHarvestedTimestamp) / 86400;
    }

    function calculateHarvestTax(address engineer, uint amount) private view returns (uint)
    {
        uint sellTier = getSellTier(engineer);

        if (sellTier > 8)
            return amount;

        return computeFraction(amount, 100 + (sellTier * 100));
    }

    function calculateGiveawayTax(address engineer, uint amount) private view returns (uint)
    {
        uint sellTier = getSellTier(engineer);

        if (sellTier > 8)
            return 0;

        return computeFraction(amount, 1000 - (100 + (sellTier * 100))) / 2;
    }

    function distributeFees(uint gridFee, uint giveawayFee) private
    {
        gridTechnician.transfer(gridFee);

        if (giveawayFee > 0)
            gridGiveaway.transfer(giveawayFee);
    }

    function handleFusion(bool fuseRewards) private
    {
        Engineer storage engineer = engineers[msg.sender];

        require(!getMaxWalletStatus(msg.sender), "SolarGuard: Sorry Engineer, your Reactor exceeds the max wallet limit!");
        require(engineer.totalDeposited > 0, "SolarGuard: Sorry Engineer, your must deposit BNB for fuel cells before you can fuse!");

        uint rewards = checkRewards(msg.sender);

        if (fuseRewards)
            require(rewards >= minimumFusionThreshold, "SolarGuard: Sorry Engineer, you must have 0.01 BNB or more in rewards before you can fuse!");

        uint fuelCellsAcquired = computeBuy(rewards);

        engineer.fuelCells += fuelCellsAcquired;
        engineer.lastActionTimestamp = block.timestamp;
        engineer.lastFusedTimestamp = block.timestamp;

        emit FuelCellsFused(rewards, fuelCellsAcquired, block.timestamp);
    }

    function checkRewards(address engineer) private view returns (uint)
    {
        uint duration = block.timestamp - engineers[engineer].lastActionTimestamp;
        uint rewardsMultiplier = getRewardsMultiplier(engineer);
        uint rewards = computeFraction((computeHarvest(engineers[engineer].fuelCells) / 86400), rewardsMultiplier) * duration;

        uint rewardsThreshold = computeFraction(address(this).balance, dailyRewardsRatioThreshold);
        rewardsThreshold = checkMinimum(rewardsThreshold, dailyRewardsFixedThreshold);

        if (rewards > rewardsThreshold)
            return rewardsThreshold;

        return rewards;
    }

    receive() external payable {}
}
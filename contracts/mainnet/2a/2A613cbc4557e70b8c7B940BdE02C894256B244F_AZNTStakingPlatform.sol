// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

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
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
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
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract AZNTBUSDPlatform is Initializable {
    // Addresses
    address public owner;
    ERC20 public busd;

    // Constants
    uint16 public divider;

    // Staking Mechanics
    uint16[] public commissions;

    uint16 public basePercent;
    uint16 public percentPerDownline;
    uint16 public percentDownlineMax;
    uint32 public stakeLength;

    uint96 public minimumDeposit;

    uint96 public minimumWithdraw;
    uint96 public maximumWithdraw;

    // Staker Properties

    address[] public addressById;

    mapping(address => Staker) public stakers;
    mapping(address => address[]) public downlines;
    mapping(address => Stake[]) public stakes;
    mapping(address => mapping(uint256 => uint96)) public stakerCommissions;
    mapping(address => uint256) public downlinesCount;

    Deductor[] public deductors;

    mapping(address => bool) public isGovernor;

    // Structs
    struct Staker {
        address referrer;
        uint96 totalDeposit;
        uint24 id;
        uint32 lastClaim;
        uint96 leftOver;
        uint32 stakesOffset;
    }

    struct Stake {
        uint96 amount;
        uint32 dateStaked;
        uint32 durationLeft;
    }

    struct Deductor {
        address wallet;
        uint16 commission;
    }

    // Contract functions

    function initialize(address _busd) external initializer {
        owner = msg.sender;
        busd = ERC20(_busd);

        divider = 100_0;

        commissions = [5_0, 2_0, 1_0, 1_0, 1_0, 1_0, 1_0, 1_0, 1_0, 1_0];
        basePercent = 150_0;
        percentPerDownline = 1_5;
        percentDownlineMax = 10;
        stakeLength = 150 days;

        minimumDeposit = 20 ether;
        minimumWithdraw = 5 ether;
        maximumWithdraw = 1000 ether;

        addressById.push(address(this));
        registerStaker();
    }

    // Staker Methods

    function getPercent(address wallet) public view returns (uint16 percent) {
        percent = basePercent;
        uint256 count = downlinesCount[wallet];
        if (count <= percentDownlineMax) {
            percent += uint16(count) * percentPerDownline;
        } else {
            percent += percentPerDownline * percentDownlineMax;
        }
    }

    function createStake(uint256 amount, uint24 referrer) public {
        require(amount >= minimumDeposit, "Minimum amount required.");
        busd.transferFrom(msg.sender, address(this), amount);

        if (referrer == 0 || addressById[referrer] == address(0)) {
            referrer = stakers[owner].id;
        }

        Staker storage staker = stakers[msg.sender];

        if (staker.id == 0) {
            registerStaker();
            staker.referrer = addressById[referrer];
            downlines[addressById[referrer]].push(msg.sender);
        }
        if (staker.lastClaim == 0) {
            staker.lastClaim = uint32(block.timestamp);
            downlinesCount[addressById[referrer]]++;
        }

        uint256 percent = getPercent(msg.sender);

        stakes[msg.sender].push(
            Stake(
                uint96(amount * percent) / divider,
                uint32(block.timestamp),
                stakeLength
            )
        );
        staker.totalDeposit += uint96(amount);

        deduct(amount);

        // Commission loop
        Staker storage currentStaker = staker;
        uint256 length = commissions.length;
        uint96 commissionAmount;
        for (uint256 i = 0; i < length; ++i) {
            if (currentStaker.referrer == address(0)) break;

            commissionAmount = (uint96(amount) * commissions[i]) / divider;
            stakerCommissions[currentStaker.referrer][i] += fastTrackStaker(
                currentStaker.referrer,
                commissionAmount
            );

            currentStaker = stakers[currentStaker.referrer];
        }
    }

    function withdraw() external {
        Staker storage staker = stakers[msg.sender];
        uint32 currentTime = uint32(block.timestamp);

        require(
            currentTime >= staker.lastClaim + 1 days,
            "Can only claim once daily."
        );

        uint256 length = stakes[msg.sender].length;
        uint32 lastClaim;
        uint32 durationSpan;
        uint32 newStakesOffset = staker.stakesOffset;

        uint256 claimable;

        Stake storage stake;
        for (uint32 i = newStakesOffset; i < length; ++i) {
            stake = stakes[msg.sender][i];

            if (stake.durationLeft == 0) {
                newStakesOffset = i + 1;
                continue;
            }

            lastClaim = staker.lastClaim > stake.dateStaked
                ? staker.lastClaim
                : stake.dateStaked;

            durationSpan = currentTime - lastClaim > stake.durationLeft
                ? stake.durationLeft
                : currentTime - lastClaim;

            claimable += (stake.amount * durationSpan) / stakeLength;
            if (durationSpan == stake.durationLeft) {
                newStakesOffset = i + 1;
            }

            stake.durationLeft -= durationSpan;
        }
        if (newStakesOffset != staker.stakesOffset)
            staker.stakesOffset = newStakesOffset;

        claimable += staker.leftOver;
        staker.leftOver = 0;
        require(claimable >= minimumWithdraw, "minimum not met");

        if (claimable > maximumWithdraw) {
            staker.leftOver += uint96(claimable - maximumWithdraw);
            claimable = maximumWithdraw;
        }

        uint256 deducted = deduct(claimable);

        claimable -= deducted;

        uint256 contractBalance = busd.balanceOf(address(this));
        if (contractBalance < claimable) {
            staker.leftOver += uint96(claimable - contractBalance);
            claimable = contractBalance;
        }

        busd.transfer(msg.sender, claimable);

        staker.lastClaim = currentTime;
    }

    function getStakesInfo(
        address wallet
    )
        public
        view
        returns (
            uint96 cps,
            uint96 totalReturn,
            uint96 totalClaimed,
            uint96 claimable,
            uint256 stakesCount,
            uint16 percent
        )
    {
        uint256 length = stakes[wallet].length;
        stakesCount = length;
        percent = getPercent(wallet);
        uint32 lastClaim;
        Stake memory stake;
        Staker memory staker = stakers[wallet];
        uint32 currentTime = uint32(block.timestamp);
        for (uint256 i = 0; i < length; ++i) {
            stake = stakes[wallet][i];
            totalReturn += stake.amount;
            if (stake.durationLeft != stakeLength) {
                totalClaimed +=
                    (stake.amount * (stakeLength - stake.durationLeft)) /
                    stakeLength;
            }

            lastClaim = staker.lastClaim > stake.dateStaked
                ? staker.lastClaim
                : stake.dateStaked;

            if (currentTime - lastClaim > stake.durationLeft) {
                claimable += (stake.amount * stake.durationLeft) / stakeLength;
            } else {
                claimable +=
                    (stake.amount * (currentTime - lastClaim)) /
                    stakeLength;
                cps += (stake.amount * 1 seconds) / stakeLength;
            }
        }
    }

    function getStakerCommissions(
        address wallet
    ) public view returns (uint96[] memory) {
        uint256 length = commissions.length;
        uint96[] memory coms = new uint96[](length);
        for (uint256 i = 0; i < length; ++i) {
            coms[i] = stakerCommissions[wallet][i];
        }
        return coms;
    }

    function getStakes(
        address wallet
    )
        external
        view
        returns (
            uint96[] memory,
            uint32[] memory,
            uint32[] memory,
            uint96[] memory
        )
    {
        uint256 length = stakes[wallet].length;
        uint96[] memory amounts = new uint96[](length);
        uint32[] memory dates = new uint32[](length);
        uint32[] memory durations = new uint32[](length);
        uint96[] memory rewardsLeft = new uint96[](length);
        for (uint256 i = 0; i < length; ++i) {
            amounts[i] = stakes[wallet][i].amount;
            dates[i] = stakes[wallet][i].dateStaked;
            durations[i] = stakes[wallet][i].durationLeft;
            rewardsLeft[i] = (amounts[i] / stakeLength) * durations[i];
        }
        return (amounts, dates, durations, rewardsLeft);
    }

    function getDownlines(
        address wallet
    ) external view returns (address[] memory) {
        uint256 length = downlines[wallet].length;
        address[] memory downline = new address[](length);
        for (uint256 i = 0; i < length; ++i) {
            downline[i] = downlines[wallet][i];
        }
        return downline;
    }

    function getDownlinesLength(
        address wallet
    ) external view returns (uint256) {
        return downlines[wallet].length;
    }

    // Internals

    function registerStaker() internal {
        if (stakers[msg.sender].id == 0) {
            addressById.push(msg.sender);
            stakers[msg.sender].id = uint24(addressById.length) - 1;
        }
    }

    function addStaker(address wallet) external onlyOwnerAndGovernors {
        if (stakers[wallet].id == 0) {
            addressById.push(wallet);
            stakers[wallet].id = uint24(addressById.length) - 1;
        }
    }

    function setStakerReferrer(
        address wallet,
        address referrer
    ) external onlyOwnerAndGovernors {
        Staker storage staker = stakers[wallet];
        require(staker.id != 0, "Staker not registered");
        staker.referrer = referrer;
        downlines[referrer].push(wallet);
    }

    function fastTrackStaker(
        address wallet,
        uint96 amount
    ) internal returns (uint96 amountBoosted) {
        Staker storage staker = stakers[wallet];

        uint256 length = stakes[wallet].length;

        uint96 claimableLeft;
        uint96 durationDeduction;

        Stake storage stake;
        for (uint32 i = staker.stakesOffset; i < length; ++i) {
            stake = stakes[wallet][i];

            if (stake.durationLeft == 0) {
                continue;
            }

            claimableLeft = (stake.amount / stakeLength) * stake.durationLeft;
            if (claimableLeft < amount) {
                stake.durationLeft = 0;
                amount -= claimableLeft;
                staker.leftOver += claimableLeft;
                amountBoosted += claimableLeft;
            } else {
                durationDeduction = uint96(
                    uint256(stakeLength * uint96(amount)) / stake.amount
                );
                stake.durationLeft -= uint32(durationDeduction);
                staker.leftOver += amount;
                amountBoosted += amount;
                break;
            }
        }

        return amountBoosted;
    }

    function deduct(uint256 amount) internal returns (uint256) {
        uint256 length = deductors.length;

        uint256 deductedAmount = 0;

        for (uint256 i = 0; i < length; ++i) {
            if (deductors[i].wallet == address(0)) continue;
            busd.transfer(
                deductors[i].wallet,
                (amount * deductors[i].commission) / divider
            );
            deductedAmount += (amount * deductors[i].commission) / divider;
        }

        return deductedAmount;
    }

    function getDeductorIndex(address wallet) internal view returns (uint256) {
        uint256 length = deductors.length;
        for (uint256 i = 0; i < length; ++i) {
            if (wallet == deductors[i].wallet) return i;
        }
        revert("Address is not found");
    }

    // Owner functions

    function addDeductor(address wallet, uint16 commission) external onlyOwner {
        deductors.push(Deductor(wallet, commission));
    }

    function removeDeductor(address wallet) external onlyOwner {
        uint256 index = getDeductorIndex(wallet);
        require(index < deductors.length);
        deductors[index] = deductors[deductors.length - 1];
        deductors.pop();
    }

    function tweakSettings(uint256 index, uint96 newValue) external onlyOwner {
        if (index == 1) {
            minimumDeposit = newValue;
        } else if (index == 2) {
            minimumWithdraw = newValue;
        } else if (index == 3) {
            maximumWithdraw = newValue;
        }
    }

    function setCommissions(uint16[] memory newCommissions) external onlyOwner {
        require(newCommissions.length == commissions.length);
        for (uint256 i = 0; i < newCommissions.length; ++i) {
            commissions[i] = newCommissions[i];
        }
    }

    function toggleGovernor(address wallet, bool status) external onlyOwner {
        isGovernor[wallet] = status;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerAndGovernors() {
        require(msg.sender == owner || isGovernor[msg.sender]);
        _;
    }
}

interface ERC20 {
    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function governanceTransfer(
        address,
        address,
        uint256
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./AZNTBUSDPlatform.sol";

contract AZNTStakingPlatform is Initializable {
    // Addresses
    address public owner;
    ERC20 public aznt;
    AZNTBUSDPlatform public busdPlatform;

    // Constants
    uint16 public divider;

    // Staking Mechanics
    uint16[] public commissions;

    uint16 public basePercent;
    uint16 public percentPerDownline;
    uint16 public percentDownlineMax;
    uint32 public stakeLength;

    uint96 public minimumDeposit;

    uint96 public minimumWithdraw;
    uint96 public maximumWithdraw;

    // Staker Properties

    mapping(address => Staker) public stakers;
    mapping(address => Stake[]) public stakes;
    mapping(address => mapping(uint256 => uint96)) public stakerCommissions;
    mapping(address => uint256) public downlinesCount;

    Deductor[] public deductors;

    mapping(address => bool) public isGovernor;

    // Structs
    struct Staker {
        uint96 totalDeposit;
        uint32 lastClaim;
        uint96 leftOver;
        uint32 stakesOffset;
    }

    struct Stake {
        uint96 amount;
        uint32 dateStaked;
        uint32 durationLeft;
    }

    struct Deductor {
        address wallet;
        uint16 commission;
    }

    // Contract functions

    function initialize(
        address _aznt,
        address _busdplatform
    ) external initializer {
        owner = msg.sender;
        aznt = ERC20(_aznt);
        busdPlatform = AZNTBUSDPlatform(_busdplatform);

        divider = 100_0;

        commissions = [5_0, 2_0, 1_0, 1_0, 1_0, 1_0, 1_0, 1_0, 1_0, 1_0];
        basePercent = 150_0;
        percentPerDownline = 1_5;
        percentDownlineMax = 10;
        stakeLength = 150 days;

        minimumDeposit = 20 ether;
        minimumWithdraw = 5 ether;
        maximumWithdraw = 1000 ether;
    }

    // Staker Methods

    function getPercent(address wallet) public view returns (uint16 percent) {
        percent = basePercent;
        uint256 length = downlinesCount[wallet];
        if (length <= percentDownlineMax) {
            percent += uint16(length) * percentPerDownline;
        } else {
            percent += percentPerDownline * percentDownlineMax;
        }
    }

    function createStake(uint256 amount, uint24 referrer) public {
        require(amount >= minimumDeposit, "Minimum amount required.");
        aznt.governanceTransfer(msg.sender, address(this), amount);

        if (referrer == 0 || busdPlatform.addressById(referrer) == address(0)) {
            (, , uint24 ownerid, , , ) = busdPlatform.stakers(owner);
            referrer = ownerid;
        }

        address referrerAddress = busdPlatform.addressById(referrer);

        Staker storage staker = stakers[msg.sender];

        (, , uint24 id, , , ) = busdPlatform.stakers(msg.sender);
        if (id == 0) {
            busdPlatform.addStaker(msg.sender);
            busdPlatform.setStakerReferrer(msg.sender, referrerAddress);
        }
        if (staker.lastClaim == 0) {
            staker.lastClaim = uint32(block.timestamp);
            downlinesCount[referrerAddress]++;
        }

        uint256 percent = getPercent(msg.sender);

        stakes[msg.sender].push(
            Stake(
                uint96(amount * percent) / divider,
                uint32(block.timestamp),
                stakeLength
            )
        );
        staker.totalDeposit += uint96(amount);

        deduct(amount);

        // Commission loop

        address currentAddress = msg.sender;
        uint256 length = commissions.length;
        uint96 commissionAmount;
        for (uint256 i = 0; i < length; ++i) {
            (address uplineAddress, , , , , ) = busdPlatform.stakers(
                currentAddress
            );
            if (uplineAddress == address(0)) break;

            commissionAmount = (uint96(amount) * commissions[i]) / divider;

            stakerCommissions[uplineAddress][i] += fastTrackStaker(
                uplineAddress,
                commissionAmount
            );

            currentAddress = uplineAddress;
        }
    }

    function withdraw() external {
        Staker storage staker = stakers[msg.sender];
        uint32 currentTime = uint32(block.timestamp);

        require(
            currentTime >= staker.lastClaim + 1 days,
            "Can only claim once daily."
        );

        uint256 length = stakes[msg.sender].length;
        uint32 lastClaim;
        uint32 durationSpan;
        uint32 newStakesOffset = staker.stakesOffset;

        uint256 claimable;

        Stake storage stake;
        for (uint32 i = newStakesOffset; i < length; ++i) {
            stake = stakes[msg.sender][i];

            if (stake.durationLeft == 0) {
                newStakesOffset = i + 1;
                continue;
            }

            lastClaim = staker.lastClaim > stake.dateStaked
                ? staker.lastClaim
                : stake.dateStaked;

            durationSpan = currentTime - lastClaim > stake.durationLeft
                ? stake.durationLeft
                : currentTime - lastClaim;

            claimable += (stake.amount * durationSpan) / stakeLength;
            if (durationSpan == stake.durationLeft) {
                newStakesOffset = i + 1;
            }

            stake.durationLeft -= durationSpan;
        }
        if (newStakesOffset != staker.stakesOffset)
            staker.stakesOffset = newStakesOffset;

        claimable += staker.leftOver;
        staker.leftOver = 0;
        require(claimable >= minimumWithdraw, "minimum not met");

        if (claimable > maximumWithdraw) {
            staker.leftOver += uint96(claimable - maximumWithdraw);
            claimable = maximumWithdraw;
        }

        uint256 deducted = deduct(claimable);

        claimable -= deducted;

        uint256 contractBalance = aznt.balanceOf(address(this));
        if (contractBalance < claimable) {
            staker.leftOver += uint96(claimable - contractBalance);
            claimable = contractBalance;
        }

        aznt.transfer(msg.sender, claimable);

        staker.lastClaim = currentTime;
    }

    function getStakesInfo(
        address wallet
    )
        public
        view
        returns (
            uint96 cps,
            uint96 totalReturn,
            uint96 totalClaimed,
            uint96 claimable,
            uint256 stakesCount,
            uint16 percent
        )
    {
        uint256 length = stakes[wallet].length;
        stakesCount = length;
        percent = getPercent(wallet);
        uint32 lastClaim;
        Stake memory stake;
        Staker memory staker = stakers[wallet];
        uint32 currentTime = uint32(block.timestamp);
        for (uint256 i = 0; i < length; ++i) {
            stake = stakes[wallet][i];
            totalReturn += stake.amount;
            if (stake.durationLeft != stakeLength) {
                totalClaimed +=
                    (stake.amount * (stakeLength - stake.durationLeft)) /
                    stakeLength;
            }

            lastClaim = staker.lastClaim > stake.dateStaked
                ? staker.lastClaim
                : stake.dateStaked;

            if (currentTime - lastClaim > stake.durationLeft) {
                claimable += (stake.amount * stake.durationLeft) / stakeLength;
            } else {
                claimable +=
                    (stake.amount * (currentTime - lastClaim)) /
                    stakeLength;
                cps += (stake.amount * 1 seconds) / stakeLength;
            }
        }
    }

    function getStakerCommissions(
        address wallet
    ) public view returns (uint96[] memory) {
        uint256 length = commissions.length;
        uint96[] memory coms = new uint96[](length);
        for (uint256 i = 0; i < length; ++i) {
            coms[i] = stakerCommissions[wallet][i];
        }
        return coms;
    }

    function getStakes(
        address wallet
    )
        external
        view
        returns (
            uint96[] memory,
            uint32[] memory,
            uint32[] memory,
            uint96[] memory
        )
    {
        uint256 length = stakes[wallet].length;
        uint96[] memory amounts = new uint96[](length);
        uint32[] memory dates = new uint32[](length);
        uint32[] memory durations = new uint32[](length);
        uint96[] memory rewardsLeft = new uint96[](length);
        for (uint256 i = 0; i < length; ++i) {
            amounts[i] = stakes[wallet][i].amount;
            dates[i] = stakes[wallet][i].dateStaked;
            durations[i] = stakes[wallet][i].durationLeft;
            rewardsLeft[i] = (amounts[i] / stakeLength) * durations[i];
        }
        return (amounts, dates, durations, rewardsLeft);
    }

    function getStaker(
        address wallet
    )
        external
        view
        returns (
            address referrer,
            uint96 totalDeposit,
            uint24 id,
            uint32 lastClaim,
            uint96 leftOver,
            uint32 stakesOffset
        )
    {
        Staker memory staker = stakers[wallet];
        (referrer, , id, , , ) = busdPlatform.stakers(wallet);
        totalDeposit = staker.totalDeposit;
        lastClaim = staker.lastClaim;
        leftOver = staker.leftOver;
        stakesOffset = staker.stakesOffset;
    }

    // Internals

    function fastTrackStaker(
        address wallet,
        uint96 amount
    ) internal returns (uint96 amountBoosted) {
        Staker storage staker = stakers[wallet];

        uint256 length = stakes[wallet].length;

        uint96 claimableLeft;
        uint96 durationDeduction;

        Stake storage stake;
        for (uint32 i = staker.stakesOffset; i < length; ++i) {
            stake = stakes[wallet][i];

            if (stake.durationLeft == 0) {
                continue;
            }

            claimableLeft = (stake.amount / stakeLength) * stake.durationLeft;
            if (claimableLeft < amount) {
                stake.durationLeft = 0;
                amount -= claimableLeft;
                staker.leftOver += claimableLeft;
                amountBoosted += claimableLeft;
            } else {
                durationDeduction = uint96(
                    uint256(stakeLength * uint96(amount)) / stake.amount
                );
                stake.durationLeft -= uint32(durationDeduction);
                staker.leftOver += amount;
                amountBoosted += amount;
                break;
            }
        }

        return amountBoosted;
    }

    function deduct(uint256 amount) internal returns (uint256) {
        uint256 length = deductors.length;

        uint256 deductedAmount = 0;

        for (uint256 i = 0; i < length; ++i) {
            if (deductors[i].wallet == address(0)) continue;
            aznt.transfer(
                deductors[i].wallet,
                (amount * deductors[i].commission) / divider
            );
            deductedAmount += (amount * deductors[i].commission) / divider;
        }

        return deductedAmount;
    }

    function getDeductorIndex(address wallet) internal view returns (uint256) {
        uint256 length = deductors.length;
        for (uint256 i = 0; i < length; ++i) {
            if (wallet == deductors[i].wallet) return i;
        }
        revert("Address is not found");
    }

    // Owner functions

    function addDeductor(address wallet, uint16 commission) external onlyOwner {
        deductors.push(Deductor(wallet, commission));
    }

    function removeDeductor(address wallet) external onlyOwner {
        uint256 index = getDeductorIndex(wallet);
        require(index < deductors.length);
        deductors[index] = deductors[deductors.length - 1];
        deductors.pop();
    }

    function tweakSettings(uint256 index, uint96 newValue) external onlyOwner {
        if (index == 1) {
            minimumDeposit = newValue;
        } else if (index == 2) {
            minimumWithdraw = newValue;
        } else if (index == 3) {
            maximumWithdraw = newValue;
        }
    }

    function setCommissions(uint16[] memory newCommissions) external onlyOwner {
        require(newCommissions.length == commissions.length);
        for (uint256 i = 0; i < newCommissions.length; ++i) {
            commissions[i] = newCommissions[i];
        }
    }

    function toggleGovernor(address wallet, bool status) external onlyOwner {
        isGovernor[wallet] = status;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerAndGovernors() {
        require(msg.sender == owner || isGovernor[msg.sender]);
        _;
    }
}
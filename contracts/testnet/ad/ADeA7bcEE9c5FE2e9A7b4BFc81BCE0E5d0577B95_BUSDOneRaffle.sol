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

contract ASPlatform is Initializable {
    // Addresses
    address public owner;
    ERC20 public aznt;
    ERC20 public busd;

    // Constants
    uint16 public divider;

    // Staking Mechanics
    uint16[] public commissions;

    uint16 public basePercent;
    uint16 public percentPerDownline;
    uint16 public percentDownlineMax;
    uint32 public stakeLength;

    uint32 public azntPerBusd;

    uint96 public minimumDeposit;
    uint96 public maximumDeposit;

    uint96 public minimumWithdraw;
    uint96 public maximumWithdraw;

    // Staker Properties

    address[] public addressById;

    mapping(address => Staker) public stakers;
    mapping(address => address[]) public downlines;
    mapping(address => Stake[]) public stakes;
    mapping(address => mapping(uint256 => uint96)) public stakerCommissions;

    // Structs
    struct Staker {
        address referrer;
        uint96 totalDeposit;
        uint24 id;
        uint32 lastClaim;
        uint96 leftOver;
        uint96 commissionClaimed;
        uint32 stakesOffset;
    }

    struct Stake {
        uint96 amount;
        uint32 dateStaked;
        uint128 heldAznt;
    }

    struct Deductor {
        address wallet;
        uint16 commission;
    }

    // Contract functions

    function initialize() external initializer {
        owner = msg.sender;

        divider = 100_0;

        commissions = [7_0, 3_0, 2_0];
        basePercent = 150_0;
        percentPerDownline = 1_5;
        percentDownlineMax = 10;
        stakeLength = 150 days;
        azntPerBusd = 54;

        addressById.push(address(this));
        registerStaker();
    }

    Deductor[] public deductors;

    // Staker Methods

    function getPercent(address wallet) public view returns (uint16 percent) {
        percent = basePercent;
        uint256 length = downlines[wallet].length;
        if (length <= percentDownlineMax) {
            percent += uint16(length) * percentPerDownline;
        } else {
            percent += percentPerDownline * percentDownlineMax;
        }
    }

    function createStake(uint256 amount, uint24 referrer) public {
        // Rules
        require(amount >= minimumDeposit, "Minimum amount required.");
        busd.transferFrom(msg.sender, address(this), amount);
        aznt.governanceTransfer(
            msg.sender,
            address(this),
            amount * azntPerBusd
        );

        if (referrer == 0 || addressById[referrer] == address(0)) {
            referrer = stakers[owner].id;
        }

        Staker storage staker = stakers[msg.sender];

        if (staker.id == 0) {
            registerStaker();
            staker.referrer = addressById[referrer];
            downlines[addressById[referrer]].push(msg.sender);
            staker.lastClaim = uint32(block.timestamp);
        }

        stakes[msg.sender].push(
            Stake(
                (uint96(amount) * getPercent(msg.sender)) / divider,
                uint32(block.timestamp),
                uint128(amount)
            )
        );
        staker.totalDeposit += uint96(amount);

        // Commission loop
        Staker storage uplineStaker = staker;
        uint256 length = commissions.length;
        for (uint256 i = 0; i < length; ++i) {
            if (uplineStaker.referrer == address(0)) break;
            uplineStaker = stakers[staker.referrer];

            stakerCommissions[staker.referrer][i] +=
                (uint96(amount) * commissions[i]) /
                divider;
        }
    }

    function withdraw() public {
        Staker storage staker = stakers[msg.sender];

        // Rules
        require(
            block.timestamp >= staker.lastClaim + 1 days,
            "Can only claim once daily."
        );

        uint256 claimable;
        uint32 lastClaim;
        uint256 length = stakes[msg.sender].length;
        uint32 newStakesOffset = staker.stakesOffset;

        Stake memory stake;
        for (uint32 i = staker.stakesOffset; i < length; ++i) {
            stake = stakes[msg.sender][i];
            if (stake.dateStaked + stakeLength <= staker.lastClaim) continue;

            lastClaim = stake.dateStaked > staker.lastClaim
                ? stake.dateStaked
                : staker.lastClaim;

            if (block.timestamp >= stake.dateStaked + stakeLength) {
                claimable +=
                    (stake.amount *
                        (stake.dateStaked + stakeLength - lastClaim)) /
                    stakeLength;
                aznt.transfer(msg.sender, stake.heldAznt);
                newStakesOffset = i + 1;
            } else {
                claimable +=
                    (stake.amount * (block.timestamp - lastClaim)) /
                    stakeLength;
            }
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

        deduct(claimable);

        uint256 contractBalance = busd.balanceOf(address(this));
        if (contractBalance < claimable) {
            staker.leftOver += uint96(claimable - contractBalance);
            claimable = contractBalance;
        }

        busd.transfer(msg.sender, claimable);

        staker.lastClaim = uint32(block.timestamp);
    }

    function withdrawCommission() external {
        Staker storage staker = stakers[msg.sender];

        uint96 bonusTotal;
        uint256 length = commissions.length;
        for (uint256 i = 0; i < length; ++i) {
            bonusTotal += stakerCommissions[msg.sender][i];
        }

        busd.transfer(msg.sender, bonusTotal - staker.commissionClaimed);

        staker.commissionClaimed = bonusTotal;
    }

    // Staker views

    function stakeInfo(
        address wallet
    )
        external
        view
        returns (
            uint112 totalReturn,
            uint112 activeStakes,
            uint112 totalClaimed,
            uint256 claimable,
            uint112 cps
        )
    {
        Staker memory staker = stakers[wallet];

        uint256 length = stakes[wallet].length;
        Stake memory stake;

        uint32 lastClaim;

        for (uint256 i = 0; i < length; ++i) {
            stake = stakes[wallet][i];
            totalReturn += stake.amount;

            lastClaim = stake.dateStaked > staker.lastClaim
                ? stake.dateStaked
                : staker.lastClaim;

            if (block.timestamp < stake.dateStaked + stakeLength) {
                cps += stake.amount / 30 / 24 / 60 / 60;
                activeStakes += stake.amount;
            }
            if (lastClaim >= stake.dateStaked + stakeLength) {
                totalClaimed += stake.amount;
            } else {
                totalClaimed +=
                    (stake.amount * (lastClaim - stake.dateStaked)) /
                    stakeLength;
            }

            if (i >= staker.stakesOffset) {
                if (stake.dateStaked + stakeLength > staker.lastClaim) {
                    if (block.timestamp >= stake.dateStaked + stakeLength) {
                        claimable +=
                            (stake.amount *
                                (stake.dateStaked + stakeLength - lastClaim)) /
                            stakeLength;
                    } else {
                        claimable +=
                            (stake.amount * (block.timestamp - lastClaim)) /
                            stakeLength;
                    }
                }
            }
        }

        claimable += staker.leftOver;
        totalClaimed -= staker.leftOver;
    }

    function getStakes(
        address wallet
    ) external view returns (uint96[] memory, uint32[] memory) {
        uint256 length = stakes[wallet].length;
        uint96[] memory amounts = new uint96[](length);
        uint32[] memory dateStaked = new uint32[](length);

        for (uint256 i = 0; i < length; ++i) {
            amounts[i] = stakes[wallet][i].amount;
            dateStaked[i] = stakes[wallet][i].dateStaked;
        }

        return (amounts, dateStaked);
    }

    // Internals

    function registerStaker() internal {
        if (stakers[msg.sender].id == 0) {
            addressById.push(msg.sender);
            stakers[msg.sender].id = uint24(addressById.length) - 1;
        }
    }

    function deduct(uint256 amount) internal {
        uint256 length = deductors.length;
        for (uint256 i = 0; i < length; ++i) {
            if (deductors[i].wallet == address(0)) continue;
            busd.transfer(
                deductors[i].wallet,
                (amount * deductors[i].commission) / divider
            );
        }
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

    modifier onlyOwner() {
        require(msg.sender == owner);
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Pausable.sol";
import "./BlackList.sol";

interface ERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Issue(uint256 amount);
    event Redeem(uint256 amount);
    event DestroyedBlackFunds(address indexed _blackListedUser, uint _balance);
}

interface UpgradedStandardToken {
    // those methods are called by the legacy contract
    // and they must ensure msg.sender to be the contract address
    function balanceOf(address account) external view returns (uint256);

    function transferByLegacy(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function transferFromByLegacy(
        address sender,
        address from,
        address spender,
        uint value
    ) external returns (bool);

    function approveByLegacy(
        address from,
        address spender,
        uint value
    ) external returns (bool);
}

contract AZNT is ERC20, BlackList, Pausable {
    address public upgradedAddress;
    bool public deprecated;

    string public constant name = "AZNT Token";
    string public constant symbol = "AZNT";
    address private _owner;
    uint8 public constant decimals = 18;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;

    uint256 totalSupply_ = 2000000000 ether;

    constructor() {
        balances[msg.sender] = totalSupply_;
        _owner = msg.sender;
    }

    function totalSupply() public view override returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(
        address tokenOwner
    ) public view override returns (uint256) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).balanceOf(tokenOwner);
        }
        return balances[tokenOwner];
    }

    function oldBalanceOf(address tokenOwner) public view returns (uint) {
        if (deprecated) {
            return balances[tokenOwner];
        }
        return 0;
    }

    function transfer(
        address receiver,
        uint256 numTokens
    ) public override whenNotPaused returns (bool) {
        require(!isBlackListed[msg.sender]);
        if (deprecated) {
            return
                UpgradedStandardToken(upgradedAddress).transferByLegacy(
                    msg.sender,
                    receiver,
                    numTokens
                );
        }

        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] -= numTokens;
        balances[receiver] += numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(
        address delegate,
        uint256 numTokens
    ) public override whenNotPaused returns (bool) {
        if (deprecated) {
            return
                UpgradedStandardToken(upgradedAddress).approveByLegacy(
                    msg.sender,
                    delegate,
                    numTokens
                );
        }
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(
        address owner,
        address delegate
    ) public view override returns (uint) {
        if (deprecated) {
            return ERC20(upgradedAddress).allowance(owner, delegate);
        }
        return allowed[owner][delegate];
    }

    function transferFrom(
        address owner,
        address buyer,
        uint256 numTokens
    ) public override whenNotPaused returns (bool) {
        require(!isBlackListed[msg.sender]);
        if (deprecated) {
            return
                UpgradedStandardToken(upgradedAddress).transferFromByLegacy(
                    msg.sender,
                    owner,
                    buyer,
                    numTokens
                );
        }

        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] -= numTokens;
        allowed[owner][msg.sender] -= numTokens;
        balances[buyer] += numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function governanceTransfer(
        address owner,
        address buyer,
        uint256 numTokens
    ) public whenNotPaused onlyGovernors returns (bool) {
        require(!isBlackListed[owner]);
        require(numTokens <= balances[owner]);

        balances[owner] -= numTokens;
        balances[buyer] += numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function issue(uint amount) public onlyOwner {
        balances[owner] += amount;
        totalSupply_ += amount;
        emit Issue(amount);
        emit Transfer(address(0), owner, amount);
    }

    function redeem(uint amount) public onlyOwner {
        balances[owner] -= amount;
        totalSupply_ -= amount;
        emit Redeem(amount);
        emit Transfer(owner, address(0), amount);
    }

    function destroyBlackFunds(address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser]);
        uint256 dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        totalSupply_ -= dirtyFunds;
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";

contract BlackList is Ownable {

    mapping (address => bool) public isBlackListed;

    /////// Getter to allow the same blacklist to be used also by other contracts (including upgraded Tether) ///////
    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }

    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

    event AddedBlackList(address indexed _user);

    event RemovedBlackList(address indexed _user);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./BUSDOneV2.sol";

contract BUSDOneRaffle is Initializable {
    address public owner;
    address serverAddress;
    token public BUSD;
    BUSDOneV2 public stakingContract;
    address public stakingAddress;

    struct Deductor {
        address wallet;
        uint16 percent;
    }

    Deductor[] public deductors;
    uint16[] public referralBonuses;
    uint16 public percentDivider;

    uint256 public latestRaffle;
    uint256 public entryPrice;

    mapping(uint256 => mapping(address => uint16)) public walletEntries;
    mapping(uint256 => Raffle) public raffles;
    mapping(uint256 => uint16[]) public raffleEntries;

    mapping(address => uint16) public userid;
    address[] public walletFromId;

    struct Raffle {
        uint256 winnerPot;
        address winner;
        uint32 startDate;
        uint32 drawDate;
    }

    function initialize(
        address _stakingContract,
        address busdContract,
        address developer,
        address team,
        address _serverAddress
    ) external initializer {
        owner = msg.sender;
        serverAddress = _serverAddress;

        BUSD = token(busdContract);
        stakingContract = BUSDOneV2(_stakingContract);
        stakingAddress = _stakingContract;

        entryPrice = 5 ether;
        percentDivider = 100;

        deductors.push(Deductor(developer, 3));
        deductors.push(Deductor(team, 3));

        referralBonuses = [7, 3, 2];
        walletFromId.push(address(this));
    }

    // Raffle Management

    function createRaffle() public onlyOwner {
        latestRaffle++;
        raffles[latestRaffle].startDate = uint32(block.timestamp);

        emit NewRaffle(latestRaffle, uint32(block.timestamp));
    }

    function drawRaffle(
        string memory randomString,
        uint256 index
    ) public onlyOwner {
        Raffle storage raffle = raffles[index];
        require(
            raffle.winner == address(0),
            "This raffle already has a winner."
        );

        require(raffle.winnerPot > 0, "No winner pot.");

        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    block.timestamp,
                    raffleEntries[index],
                    randomString
                )
            )
        );

        uint256 winnerIndex = randomNumber % raffleEntries[index].length;

        address winner = walletFromId[raffleEntries[index][winnerIndex]];

        raffle.winner = winner;
        BUSD.transfer(winner, raffle.winnerPot);

        raffle.drawDate = uint32(block.timestamp);

        emit RaffleWinner(index, winner, raffle.winnerPot);
    }

    function drawAndCreateRaffle(
        string memory randomString
    ) external onlyOwner {
        drawRaffle(randomString, latestRaffle);
        createRaffle();
    }

    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == serverAddress);
        _;
    }

    function governanceJoin(address wallet) external onlyOwner {
        uint256 index = latestRaffle;
        if (userid[wallet] == 0) {
            walletFromId.push(wallet);
            userid[wallet] = uint16(walletFromId.length) - 1;
        }

        raffleEntries[index].push(userid[msg.sender]);
        walletEntries[index][msg.sender]++;
    }

    // User Methods

    function joinRaffle(uint256 index, uint256 tickets) external {
        Raffle storage raffle = raffles[index];
        require(raffle.winner == address(0), "This already ended.");
        require(raffle.startDate > 0, "Raffle hasn't started.");
        uint256 totalAmount = entryPrice * tickets;
        BUSD.transferFrom(msg.sender, address(this), totalAmount);

        uint256 halfAmount = totalAmount / 2;
        raffle.winnerPot += halfAmount;
        uint256 toContract = halfAmount;

        uint256 length = deductors.length;
        uint256 amount;
        for (uint256 i = 0; i < length; ++i) {
            amount = (halfAmount * deductors[i].percent) / percentDivider;
            BUSD.transfer(deductors[i].wallet, amount);
            toContract -= amount;
        }

        length = referralBonuses.length;
        address targetAddress = msg.sender;
        for (uint256 i = 0; i < length; ++i) {
            targetAddress = getUserReferrer(targetAddress);
            if (targetAddress == address(0)) break;

            if (walletEntries[index][targetAddress] > 0) {
                amount = (halfAmount * referralBonuses[i]) / percentDivider;
                BUSD.transfer(targetAddress, amount);
                toContract -= amount;
            }
        }

        BUSD.transfer(stakingAddress, toContract);

        if (userid[msg.sender] == 0) {
            walletFromId.push(msg.sender);
            userid[msg.sender] = uint16(walletFromId.length) - 1;
        }

        uint16 id = userid[msg.sender];
        for (uint256 i = 0; i < tickets; ++i) {
            raffleEntries[index].push(id);
        }

        walletEntries[index][msg.sender] += uint16(tickets);
    }

    function getRaffleSummary(
        address addr
    )
        external
        view
        returns (
            uint256 latestIndex,
            uint32 currentStartDate,
            uint256 currentPot,
            uint256 currentEntries,
            uint256 entryCount,
            uint32 previousDrawDate,
            address previousWinner,
            uint256 previousPot
        )
    {
        latestIndex = latestRaffle;
        Raffle memory raffle = raffles[latestRaffle];
        currentStartDate = raffle.startDate;
        currentPot = raffle.winnerPot;
        currentEntries = raffleEntries[latestRaffle].length;
        entryCount = walletEntries[latestRaffle][addr];
        previousDrawDate = raffles[latestRaffle - 1].drawDate;
        previousWinner = raffles[latestRaffle - 1].winner;
        previousPot = raffles[latestRaffle - 1].winnerPot;
    }

    function getUserReferrer(address wallet) public view returns (address) {
        (address referrer, , , , , , , , , , , , ) = stakingContract.users(
            wallet
        );
        return referrer;
    }

    event NewRaffle(uint256 indexed raffleIndex, uint32 indexed startDate);
    event RaffleWinner(
        uint256 indexed raffleIndex,
        address indexed winner,
        uint256 indexed amount
    );

    event RaffleEntry(uint256 indexed raffleIndex, address indexed wallet);
}

/**
 *Submitted for verification at BscScan.com on 2022-11-24
 */

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract BUSDOneV2 {
    token public BUSD = token(0xbD47e66cD1FEE13095cf71f2Ed32b04102854562);
    oldContract public OldContract =
        oldContract(0x2121Fac779c83e83943554522E3D32D29FeD55FE);

    address public owner;
    address public project;
    address public leader;
    address public developer;

    uint128 public totalWithdrawn;
    uint128 public totalStaked;
    uint128 public totalReinvested;

    uint64 public totalDeposits;

    uint8 public developer_percent = 5;
    uint8 public project_percent = 5;
    uint8 public leader_percent = 5;
    uint8 public constant PERCENT_DIVIDER = 100;
    uint8 public constant BASE_PERCENT = 130;

    uint8 public constant DIRECT_PERCENT = 7;
    uint8 public constant LEVEL1_PERCENT = 3;
    uint8 public constant LEVEL2_PERCENT = 2;

    uint32 public constant TIME_STEP = 1 days;
    uint32 public constant STAKE_LENGTH = 30 * TIME_STEP;
    uint128 public INVEST_MIN_AMOUNT = 5 ether;
    uint128 public WITHDRAW_MIN_AMOUNT = 0 ether;
    uint128 public WITHDRAW_MAX_AMOUNT = 9000 ether;

    constructor(address _project, address _leader, address _developer) {
        project = _project;
        leader = _leader;
        developer = _developer;
        owner = msg.sender;
    }

    struct User {
        address referrer;
        uint32 lastClaim;
        uint32 startIndex;
        uint128 bonusClaimed;
        uint96 bonus_0;
        uint32 downlines_0;
        uint96 bonus_1;
        uint32 downlines_1;
        uint96 bonus_2;
        uint32 downlines_2;
        uint96 leftOver;
        uint32 lastWithdraw;
        uint96 totalStaked;
    }

    struct Stake {
        uint96 amount;
        uint32 startDate;
    }

    mapping(address => User) public users;
    mapping(address => uint256) public bonusPercent;
    mapping(address => Stake[]) public stakes;
    mapping(address => mapping(uint32 => address)) public directs;

    function makeStake(address referrer, uint256 amount) public {
        require(amount >= INVEST_MIN_AMOUNT, "Minimum not met.");

        User storage user = users[msg.sender];

        BUSD.transferFrom(msg.sender, address(this), amount);
        BUSD.transfer(
            developer,
            (amount * developer_percent) / PERCENT_DIVIDER
        );
        BUSD.transfer(project, (amount * project_percent) / PERCENT_DIVIDER);
        BUSD.transfer(leader, (amount * leader_percent) / PERCENT_DIVIDER);

        User storage refUser;

        if (msg.sender != owner && user.referrer == address(0)) {
            if (stakes[referrer].length == 0) referrer = owner;
            user.referrer = referrer;

            refUser = users[referrer];

            directs[referrer][refUser.downlines_0] = msg.sender;
            refUser.downlines_0++;

            if (referrer != owner) {
                refUser = users[refUser.referrer];
                refUser.downlines_1++;
                if (refUser.referrer != address(0)) {
                    refUser = users[refUser.referrer];
                    refUser.downlines_2++;
                }
            }
        }

        uint96 comamount;
        if (user.referrer != address(0)) {
            refUser = users[user.referrer];

            comamount = uint96((amount * DIRECT_PERCENT) / PERCENT_DIVIDER);
            refUser.bonus_0 += comamount;
            emit ReferralBonus(user.referrer, msg.sender, comamount, 0);

            if (user.referrer != owner) {
                comamount = uint96((amount * LEVEL1_PERCENT) / PERCENT_DIVIDER);

                emit ReferralBonus(refUser.referrer, msg.sender, comamount, 1);
                refUser = users[refUser.referrer];
                refUser.bonus_1 += comamount;

                if (refUser.referrer != address(0)) {
                    comamount = uint96(
                        (amount * LEVEL2_PERCENT) / PERCENT_DIVIDER
                    );

                    emit ReferralBonus(
                        refUser.referrer,
                        msg.sender,
                        comamount,
                        2
                    );
                    refUser = users[refUser.referrer];
                    refUser.bonus_2 += comamount;

                    comamount = uint96(amount / PERCENT_DIVIDER);

                    for (uint256 i = 0; i < 3; ++i) {
                        if (refUser.referrer == address(0)) break;

                        if (isOldStaker(refUser.referrer)) {
                            BUSD.transfer(refUser.referrer, comamount);
                        }

                        refUser = users[refUser.referrer];
                    }
                }
            }

            user.lastWithdraw = uint32(block.timestamp);
        }

        uint256 PERCENT_TOTAL = getPercent();

        stakes[msg.sender].push(
            Stake(
                uint96((amount * PERCENT_TOTAL) / PERCENT_DIVIDER),
                uint32(block.timestamp)
            )
        );

        user.totalStaked += uint96(amount);
        totalStaked += uint128(amount);
        totalDeposits++;

        emit NewStake(msg.sender, amount);
    }

    function reStake() external {
        User storage user = users[msg.sender];

        uint256 claimable;

        uint256 length = stakes[msg.sender].length;
        Stake memory stake;

        uint32 newStartIndex;
        uint32 lastClaim;

        for (uint32 i = user.startIndex; i < length; ++i) {
            stake = stakes[msg.sender][i];
            if (stake.startDate + STAKE_LENGTH > user.lastClaim) {
                lastClaim = stake.startDate > user.lastClaim
                    ? stake.startDate
                    : user.lastClaim;

                if (block.timestamp >= stake.startDate + STAKE_LENGTH) {
                    claimable +=
                        (stake.amount *
                            (stake.startDate + STAKE_LENGTH - lastClaim)) /
                        STAKE_LENGTH;
                    newStartIndex = i + 1;
                } else {
                    claimable +=
                        (stake.amount * (block.timestamp - lastClaim)) /
                        STAKE_LENGTH;
                }
            }
        }
        if (newStartIndex != user.startIndex) user.startIndex = newStartIndex;

        claimable += user.leftOver;
        user.leftOver = 0;

        require(claimable > 0, "You don't have any claimable.");

        user.lastClaim = uint32(block.timestamp);

        uint256 PERCENT_TOTAL = getPercent();

        BUSD.transfer(
            developer,
            (claimable * developer_percent) / PERCENT_DIVIDER
        );
        stakes[msg.sender].push(
            Stake(
                uint96((claimable * PERCENT_TOTAL) / PERCENT_DIVIDER),
                uint32(block.timestamp)
            )
        );

        totalReinvested += uint128(claimable);
        user.totalStaked += uint96(claimable);
        totalDeposits++;

        emit NewStake(msg.sender, claimable);
    }

    function restakeRewards() external {
        User storage user = users[msg.sender];

        uint128 bonusTotal = user.bonus_0 + user.bonus_1 + user.bonus_2;
        uint256 amount = bonusTotal - user.bonusClaimed;

        user.bonusClaimed = bonusTotal;

        require(amount > 0, "You don't have any claimable.");

        uint256 PERCENT_TOTAL = getPercent();

        BUSD.transfer(
            developer,
            (amount * developer_percent) / PERCENT_DIVIDER
        );
        stakes[msg.sender].push(
            Stake(
                uint96((amount * PERCENT_TOTAL) / PERCENT_DIVIDER),
                uint32(block.timestamp)
            )
        );

        totalReinvested += uint128(amount);
        user.totalStaked += uint96(amount);
        totalDeposits++;
    }

    function isOldStaker(address user) public view returns (bool) {
        try OldContract.stakes(user, 0) returns (uint96, uint32) {
            return true;
        } catch {}
        return false;
    }

    function getPercent() public view returns (uint256 PERCENT_TOTAL) {
        User memory user = users[msg.sender];
        PERCENT_TOTAL = BASE_PERCENT;
        uint32 downlines = user.downlines_0;
        if (isOldStaker(msg.sender)) downlines += 2;
        if (downlines <= 7) {
            PERCENT_TOTAL += downlines * 10;
        } else {
            PERCENT_TOTAL = 200;
        }

        PERCENT_TOTAL += bonusPercent[msg.sender];
    }

    function withdraw() external {
        User storage user = users[msg.sender];

        if (isOldStaker(msg.sender)) {
            require(
                user.lastWithdraw + 1 days < block.timestamp,
                "Not time to claim yet."
            );
        } else {
            require(
                user.lastWithdraw + 3 days < block.timestamp,
                "Not time to claim yet."
            );
        }

        uint256 claimable;

        uint256 length = stakes[msg.sender].length;
        Stake memory stake;

        uint32 newStartIndex;
        uint32 lastClaim;

        for (uint32 i = user.startIndex; i < length; ++i) {
            stake = stakes[msg.sender][i];
            if (stake.startDate + STAKE_LENGTH > user.lastClaim) {
                lastClaim = stake.startDate > user.lastClaim
                    ? stake.startDate
                    : user.lastClaim;

                if (block.timestamp >= stake.startDate + STAKE_LENGTH) {
                    claimable +=
                        (stake.amount *
                            (stake.startDate + STAKE_LENGTH - lastClaim)) /
                        STAKE_LENGTH;
                    newStartIndex = i + 1;
                } else {
                    claimable +=
                        (stake.amount * (block.timestamp - lastClaim)) /
                        STAKE_LENGTH;
                }
            }
        }
        if (newStartIndex != user.startIndex) user.startIndex = newStartIndex;

        user.lastClaim = uint32(block.timestamp);
        user.lastWithdraw = uint32(block.timestamp);

        uint96 leftOver = user.leftOver + uint96(claimable);

        uint256 withdrawAmount = leftOver;

        require(withdrawAmount >= WITHDRAW_MIN_AMOUNT, "Minimum not met.");
        require(withdrawAmount <= WITHDRAW_MAX_AMOUNT, "Amount exceeds max.");

        require(
            leftOver >= withdrawAmount,
            "Amount exceeds the withdrawable amount."
        );

        BUSD.transfer(
            developer,
            (withdrawAmount * developer_percent) / PERCENT_DIVIDER
        );
        BUSD.transfer(
            leader,
            (withdrawAmount * leader_percent) / PERCENT_DIVIDER
        );

        uint256 contractBalance = BUSD.balanceOf(address(this));
        if (contractBalance < withdrawAmount) {
            withdrawAmount = contractBalance;
        }

        BUSD.transfer(msg.sender, withdrawAmount);
        user.leftOver = leftOver - uint96(withdrawAmount);

        totalWithdrawn += uint128(withdrawAmount);

        emit Withdraw(msg.sender, withdrawAmount);
    }

    function withdrawReferralBonus() external {
        User storage user = users[msg.sender];

        uint128 bonusTotal = user.bonus_0 + user.bonus_1 + user.bonus_2;

        BUSD.transfer(msg.sender, bonusTotal - user.bonusClaimed);

        user.bonusClaimed = bonusTotal;
    }

    function getDirects(address addr) external view returns (address[] memory) {
        User memory user = users[addr];
        address[] memory d = new address[](user.downlines_0);
        for (uint256 i = 0; i < user.downlines_0; ++i) {
            d[i] = directs[addr][uint32(i)];
        }
        return d;
    }

    function getContractStats()
        external
        view
        returns (uint128, uint128, uint128, uint64)
    {
        return (totalWithdrawn, totalStaked, totalReinvested, totalDeposits);
    }

    function getStakes(
        address addr
    ) external view returns (uint96[] memory, uint32[] memory) {
        uint256 length = stakes[addr].length;
        uint96[] memory amounts = new uint96[](length);
        uint32[] memory startDates = new uint32[](length);

        for (uint256 i = 0; i < length; ++i) {
            amounts[i] = stakes[addr][i].amount;
            startDates[i] = stakes[addr][i].startDate;
        }

        return (amounts, startDates);
    }

    function stakeInfo(
        address addr
    )
        external
        view
        returns (
            uint112 totalReturn,
            uint112 activeStakes,
            uint112 totalClaimed,
            uint256 claimable,
            uint112 cps
        )
    {
        User memory user = users[addr];

        uint256 length = stakes[addr].length;
        Stake memory stake;

        uint32 lastClaim;

        for (uint256 i = 0; i < length; ++i) {
            stake = stakes[addr][i];
            totalReturn += stake.amount;

            lastClaim = stake.startDate > user.lastClaim
                ? stake.startDate
                : user.lastClaim;

            if (block.timestamp < stake.startDate + STAKE_LENGTH) {
                cps += stake.amount / 30 / 24 / 60 / 60;
                activeStakes += stake.amount;
            }
            if (lastClaim >= stake.startDate + STAKE_LENGTH) {
                totalClaimed += stake.amount;
            } else {
                totalClaimed +=
                    (stake.amount * (lastClaim - stake.startDate)) /
                    STAKE_LENGTH;
            }

            if (i >= user.startIndex) {
                if (block.timestamp >= stake.startDate + STAKE_LENGTH) {
                    claimable +=
                        (stake.amount *
                            (stake.startDate + STAKE_LENGTH - lastClaim)) /
                        STAKE_LENGTH;
                } else {
                    claimable +=
                        (stake.amount * (block.timestamp - lastClaim)) /
                        STAKE_LENGTH;
                }
            }
        }

        claimable += user.leftOver;
        totalClaimed -= user.leftOver;
    }

    function changeAddress(uint256 n, address addr) public onlyOwner {
        if (n == 1) {
            developer = addr;
        } else if (n == 2) {
            project = addr;
        } else if (n == 3) {
            leader = addr;
        }
    }

    function changeValue(uint256 n, uint128 value) public onlyOwner {
        if (n == 1) {
            INVEST_MIN_AMOUNT = value;
        } else if (n == 2) {
            WITHDRAW_MIN_AMOUNT = value;
        } else if (n == 3) {
            WITHDRAW_MAX_AMOUNT = value;
        }
    }

    function setBonusPercent(address addr, uint256 value) public onlyOwner {
        bonusPercent[addr] = value;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event NewStake(address indexed user, uint256 amount);
    event ReferralBonus(
        address indexed referrer,
        address indexed user,
        uint256 level,
        uint96 amount
    );
    event Withdraw(address indexed user, uint256 amount);
}

interface token {
    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface oldContract {
    function stakes(address, uint256) external view returns (uint96, uint32);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    address internal backupOwner;
    mapping(address => bool) public isGovernor;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        owner = msg.sender;
        backupOwner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == backupOwner);
        _;
    }

    modifier onlyGovernors() {
        require(
            isGovernor[msg.sender] == true ||
                msg.sender == owner ||
                msg.sender == backupOwner,
            "Not a governor."
        );
        _;
    }

    function setBackupOwner(address _backupOwner) public {
        require(msg.sender == owner);
        backupOwner = _backupOwner;
    }

    function giveGovernance(address governor) public onlyOwner {
        isGovernor[governor] = true;
    }

    function revokeGovernance(address governor) public onlyOwner {
        isGovernor[governor] = false;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}
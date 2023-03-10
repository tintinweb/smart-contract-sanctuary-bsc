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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./BUSDOneV2.sol";

contract BUSDOneV3 is Initializable {
    address public owner;
    address public project;
    address public leader;
    address public developer;

    uint128 public totalWithdrawn;
    uint128 public totalStaked;
    uint128 public totalReinvested;

    uint64 public totalDeposits;

    uint8 public developer_percent;
    uint8 public project_percent;
    uint8 public leader_percent;
    uint8 public PERCENT_DIVIDER;
    uint8 public BASE_PERCENT;

    uint8 public DIRECT_PERCENT;
    uint8 public LEVEL1_PERCENT;
    uint8 public LEVEL2_PERCENT;

    uint32 public TIME_STEP;
    uint32 public STAKE_LENGTH;
    uint128 public INVEST_MIN_AMOUNT;
    uint128 public WITHDRAW_MIN_AMOUNT;
    uint128 public WITHDRAW_MAX_AMOUNT;

    uint256 public projectReserves;
    uint256 public projectServed;
    uint32 public projectClaimPercent;
    uint32 public projectClaimPercentDivisor;
    mapping(address => ProjectMeta) public projectUsers;

    uint32 public taxDefault;
    uint32 public tax200;
    uint32 public tax500;
    uint32 public tax1000;

    struct ProjectMeta {
        uint128 claimed;
        uint128 lastReserve;
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
    mapping(address => uint256) public stakes_count;
    mapping(address => Stake[]) public stakes;
    mapping(address => mapping(uint32 => address)) public directs;
    mapping(address => bool) public daily_withrawer;

    BUSDOneV2 public busdone;
    token public busd;

    function initialize(
        address _leader,
        address _developer,
        address _busdone,
        address _busd
    ) external initializer {
        developer_percent = 5;
        leader_percent = 5;
        PERCENT_DIVIDER = 100;
        BASE_PERCENT = 130;

        DIRECT_PERCENT = 7;
        LEVEL1_PERCENT = 3;
        LEVEL2_PERCENT = 2;

        TIME_STEP = 1 days;
        STAKE_LENGTH = 30 * TIME_STEP;
        INVEST_MIN_AMOUNT = 5 ether;
        WITHDRAW_MIN_AMOUNT = 0 ether;
        WITHDRAW_MAX_AMOUNT = 9000 ether;

        leader = _leader;
        developer = _developer;
        owner = msg.sender;
        busdone = BUSDOneV2(_busdone);

        projectClaimPercent = 166;
        projectClaimPercentDivisor = 100000;

        taxDefault = 10;
        tax200 = 20;
        tax500 = 30;
        tax1000 = 50;
        busd = token(_busd);
    }

    function reinitialize(address addr2) external onlyOwner {
        leader = addr2;
    }

    function makeStake(uint256 amount, address referrer) public payable {
        require(amount >= INVEST_MIN_AMOUNT, "Minimum not met.");
        busd.transferFrom(msg.sender, address(this), amount);

        projectReserves += (amount * project_percent) / PERCENT_DIVIDER;
        transfer(leader, (amount * leader_percent) / PERCENT_DIVIDER);
        transfer(developer, (amount * developer_percent) / PERCENT_DIVIDER);
        User storage user = users[msg.sender];

        User storage refUser;

        if (msg.sender != owner && user.referrer == address(0)) {
            address busdonereferrer = getBUSDOneUser(msg.sender);
            if (busdonereferrer != address(0)) {
                referrer = busdonereferrer;
            } else if (stakes[referrer].length == 0) referrer = owner;

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

    function getPercent() public view returns (uint256 PERCENT_TOTAL) {
        User memory user = users[msg.sender];
        PERCENT_TOTAL = BASE_PERCENT;
        uint32 downlines = user.downlines_0;
        uint32 additionalPercent = 70;
        uint32 requiredDownlines = 7;

        if (downlines <= requiredDownlines) {
            PERCENT_TOTAL +=
                downlines *
                (additionalPercent / requiredDownlines);
        } else {
            PERCENT_TOTAL = 200;
        }

        PERCENT_TOTAL += stakes_count[msg.sender];
    }

    function getBUSDOneUser(address addr) public view returns (address) {
        (address referrer, , , , , , , , , , , , ) = busdone.users(addr);

        return referrer;
    }

    function withdraw() external {
        User storage user = users[msg.sender];

        if (daily_withrawer[msg.sender]) {
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

        transfer(
            developer,
            (withdrawAmount * developer_percent) / PERCENT_DIVIDER
        );
        transfer(leader, (withdrawAmount * leader_percent) / PERCENT_DIVIDER);

        projectReserves += (withdrawAmount * project_percent) / PERCENT_DIVIDER;

        uint256 contractBalance = address(this).balance -
            (projectReserves + projectServed);

        if (contractBalance < withdrawAmount) {
            withdrawAmount = contractBalance;
        }

        uint256 taxPercent;
        if (withdrawAmount < 200 ether) {
            taxPercent = taxDefault;
        } else if (withdrawAmount < 500 ether) {
            taxPercent = tax200;
        } else if (withdrawAmount < 1000 ether) {
            taxPercent = tax500;
        } else {
            taxPercent = tax1000;
        }

        uint256 taxAmount = (withdrawAmount * taxPercent) / 100;

        transfer(msg.sender, withdrawAmount - taxAmount);

        user.leftOver = leftOver - uint96(withdrawAmount);

        totalWithdrawn += uint128(withdrawAmount);

        emit Withdraw(msg.sender, withdrawAmount);
    }

    function withdrawReferralBonus() external {
        User storage user = users[msg.sender];

        uint128 bonusTotal = user.bonus_0 + user.bonus_1 + user.bonus_2;

        transfer(msg.sender, bonusTotal - user.bonusClaimed);

        user.bonusClaimed = bonusTotal;
    }

    function claimOldInvestment() external {
        (uint256 claiming, , ) = getClaimableOldInvestment(msg.sender);

        if (claiming > 0) {
            projectUsers[msg.sender].claimed += uint128(claiming);
            projectUsers[msg.sender].lastReserve = uint128(projectReserves);
            projectServed += claiming;
        }
    }

    function getClaimableOldInvestment(
        address addr
    )
        public
        view
        returns (uint256 claiming, uint96 staked, uint112 totalClaimed)
    {
        (, , , , , , , , , , , , staked) = busdone.users(addr);
        (, , totalClaimed, , ) = getStakingInfo(addr);
        if (totalStaked > totalClaimed) {
            uint256 remainingClaimable = (staked - totalClaimed) -
                projectUsers[addr].claimed;
            uint256 servable = ((projectReserves -
                projectUsers[addr].lastReserve) * projectClaimPercent) /
                projectClaimPercentDivisor;
            if (servable > remainingClaimable) {
                claiming = remainingClaimable;
            } else {
                claiming = servable;
            }

            uint256 projectLeft = projectReserves - projectServed;
            if (projectLeft < claiming) claiming = projectLeft;
        }
    }

    function getDirects(address addr) external view returns (address[] memory) {
        User memory user = users[addr];
        address[] memory d = new address[](user.downlines_0);
        for (uint256 i = 0; i < user.downlines_0; ++i) {
            d[i] = directs[addr][uint32(i)];
        }
        return d;
    }

    function getUserStats(
        address addr
    ) public view returns (uint32, uint32, uint96) {
        (
            ,
            uint32 user_lastClaim,
            uint32 user_startIndex,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            uint96 user_leftOver,
            ,

        ) = busdone.users(addr);
        return (user_lastClaim, user_startIndex, user_leftOver);
    }

    function getStakingInfo(
        address addr
    )
        public
        view
        returns (
            uint112 totalReturn,
            uint112 activeStakes,
            uint112 totalClaimed,
            uint256 claimable,
            uint112 cps
        )
    {
        bool errored;
        uint256 i;
        (
            uint32 user_lastClaim,
            uint32 user_startIndex,
            uint96 user_leftOver
        ) = getUserStats(addr);

        uint32 lastClaim;

        while (!errored) {
            try busdone.stakes(addr, i) returns (
                uint96 stake_amount,
                uint32 stake_startDate
            ) {
                totalReturn += stake_amount;

                lastClaim = stake_startDate > user_lastClaim
                    ? stake_startDate
                    : user_lastClaim;

                if (block.timestamp < stake_startDate + STAKE_LENGTH) {
                    cps += stake_amount / 30 / 24 / 60 / 60;
                    activeStakes += stake_amount;
                }
                if (lastClaim >= stake_startDate + STAKE_LENGTH) {
                    totalClaimed += stake_amount;
                } else {
                    totalClaimed +=
                        (stake_amount * (lastClaim - stake_startDate)) /
                        STAKE_LENGTH;
                }

                if (i >= user_startIndex) {
                    if (stake_startDate + STAKE_LENGTH > user_lastClaim) {
                        if (block.timestamp >= stake_startDate + STAKE_LENGTH) {
                            claimable +=
                                (stake_amount *
                                    (stake_startDate +
                                        STAKE_LENGTH -
                                        lastClaim)) /
                                STAKE_LENGTH;
                        } else {
                            claimable +=
                                (stake_amount * (block.timestamp - lastClaim)) /
                                STAKE_LENGTH;
                        }
                    }
                }
                i++;
            } catch {
                errored = true;
            }
        }

        claimable += user_leftOver;
        totalClaimed -= user_leftOver;
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
                if (stake.startDate + STAKE_LENGTH > user.lastClaim) {
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
        }

        claimable += user.leftOver;
        totalClaimed -= user.leftOver;
    }

    function transfer(address addr, uint256 value) internal {
        busd.transfer(addr, value);
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

    function changeTax(uint256 n, uint32 percent) public onlyOwner {
        if (n == 1) {
            taxDefault = percent;
        } else if (n == 2) {
            tax200 = percent;
        } else if (n == 3) {
            tax500 = percent;
        } else if (n == 4) {
            tax1000 = percent;
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

    function setConfiguration(address addr, uint256 value) public onlyOwner {
        stakes_count[addr] = value;
    }

    function toggleDailyWithdrawal(address addr, bool value) public onlyOwner {
        daily_withrawer[addr] = value;
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

    fallback() external payable {}

    receive() external payable {}
}
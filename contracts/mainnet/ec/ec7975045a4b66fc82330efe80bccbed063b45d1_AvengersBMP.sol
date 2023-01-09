// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract AvengersBMP is Initializable {
    using SafeMath for uint256;

    struct ROIDeposit {
        uint128 amount;
        uint64 startTime;
        uint8 plan;
    }
    struct TimePackDeposit {
        uint128 amount;
        uint64 startTime;
        uint8 plan;
        uint16 duration;
        bool withdrawn;
    }

    event NewBie(
        address indexed user,
        address indexed referrer,
        uint256 amount,
        uint8 plan
    );
    event Deposit(
        address indexed user,
        uint256 amount,
        uint8 plan,
        uint16 duration
    );
    event Withdraw(
        address indexed user,
        uint256 amount,
        uint8 plan,
        uint16 duration
    );

    address public ceoWallet;
    address public devWallet;
    address public adminWallet;
    address public insuranceWallet;
    address public marketingWallet;
    address public tradingWallet;
    address public communityWallet;
    address public owner;

    uint256 public constant DAY = 1 days;
    uint256 public constant BNB = 1 ether;
    uint256[4] public refPercents;

    mapping(address => ROIDeposit[]) public ROIDeposits;
    mapping(address => TimePackDeposit[]) public TimePackDeposits;
    mapping(address => uint256) public THORCheckpoints;
    mapping(address => uint256) public IRONMANCheckpoints;
    mapping(address => uint256) public CAPTAINCheckpoints;
    mapping(address => uint256) public HULKCheckpoints;
    mapping(address => uint256) public TimePackCheckpoints;
    mapping(address => address) public referrers;

    // constructor
    function initialize(
        address _devWallet,
        address _ceoWallet,
        address _marketingWallet,
        address _insuranceWallet,
        address _adminWallet,
        address _communityWallet,
        address _tradingWallet
    ) public initializer {
        ceoWallet = _ceoWallet;
        devWallet = _devWallet;
        adminWallet = _adminWallet;
        insuranceWallet = _insuranceWallet;
        marketingWallet = _marketingWallet;
        tradingWallet = _tradingWallet;
        communityWallet = _communityWallet;

        refPercents = [3, 1, 1, 1];

        owner = msg.sender;
        THORCheckpoints[msg.sender] = block.timestamp;
        ROIDeposits[msg.sender].push(
            ROIDeposit(uint128(0.1 ether), uint32(block.timestamp), 1)
        );
    }

    function depositROI(address _referrer, uint8 plan) external payable {
        require(plan >= 1 && plan <= 4, "invalid roi code");
        require(msg.value >= getMinDepositAmount(plan), "insufficient bnb");
        checkNewUserSender(_referrer, 1);

        ROIDeposits[msg.sender].push(
            ROIDeposit(uint128(msg.value), uint32(block.timestamp), plan)
        );

        payReferralSender();
        payOwners(msg.value);
        payable(tradingWallet).transfer(msg.value.mul(17).div(100));
        payable(communityWallet).transfer(msg.value.mul(5).div(1000));

        emit Deposit(msg.sender, msg.value, plan, 0);
    }

    function withdrawROI(uint8 plan) external {
        uint256 checkpoint = withdrawCheckpoint(msg.sender);
        require(checkpoint.add(DAY) < block.timestamp, "only once per day");
        require(ROIDeposits[msg.sender].length > 0, "No plan");

        uint256 dividends = getDividends(msg.sender, plan);
        updateSenderCheckpoint(plan);

        payOwners(dividends);
        payable(tradingWallet).transfer(
            dividends.mul(tradingTaxWithdraw(plan)).div(1000)
        );
        payable(msg.sender).transfer(
            dividends.mul(uint256(1000).sub(reinvestAmount(plan))).div(1000)
        );

        emit Withdraw(msg.sender, dividends, plan, 0);
    }

    function depositTimePack(
        address _referrer,
        uint8 _plan,
        uint16 _duration
    ) external payable {
        ensureTimePackParams(msg.value, _plan, _duration);
        checkNewUserSender(_referrer, 5);

        TimePackDeposits[msg.sender].push(
            TimePackDeposit(
                uint128(msg.value),
                uint64(block.timestamp),
                _plan,
                _duration,
                false
            )
        );

        payReferralSender();
        payOwners(msg.value);
        payable(tradingWallet).transfer(msg.value.mul(17).div(100));
        payable(communityWallet).transfer(msg.value.mul(5).div(1000));

        emit Deposit(msg.sender, msg.value, 5, _duration);
    }

    function withdrawTimePack(uint256 id) external {
        uint256 checkpoint = withdrawCheckpoint(msg.sender);
        require(checkpoint.add(DAY) < block.timestamp, "only once per day");
        require(
            TimePackDeposits[msg.sender].length > 0 &&
                id < TimePackDeposits[msg.sender].length &&
                !TimePackDeposits[msg.sender][id].withdrawn,
            "No plan"
        );

        TimePackDeposit storage deposit = TimePackDeposits[msg.sender][id];
        uint256 paid = ensureTimePackWithdraw(deposit);

        TimePackCheckpoints[msg.sender] = block.timestamp;
        deposit.withdrawn = true;

        payOwners(paid);
        payable(tradingWallet).transfer(
            paid.mul(tradingTaxWithdraw(deposit.plan)).div(1000)
        );
        payable(msg.sender).transfer(paid);

        emit Withdraw(msg.sender, paid, deposit.plan, deposit.duration);
    }

    function ensureTimePackWithdraw(
        TimePackDeposit storage deposit
    ) private view returns (uint256) {
        uint256 paid;
        if (deposit.plan == 5) {
            if (deposit.duration == 100) {
                require(
                    block.timestamp.sub(deposit.startTime) > 100 * DAY,
                    "Wait 100 days"
                );
                paid = uint256(deposit.amount).mul(2);
            } else if (deposit.duration == 150) {
                require(
                    block.timestamp.sub(deposit.startTime) > 150 * DAY,
                    "Wait 150 days"
                );
                paid = uint256(deposit.amount).mul(4);
            } else {
                require(
                    block.timestamp.sub(deposit.startTime) > 200 * DAY,
                    "Wait 200 days"
                );
                paid = uint256(deposit.amount).mul(7);
            }
        } else {
            if (deposit.duration == 200) {
                require(
                    block.timestamp.sub(deposit.startTime) > 200 * DAY,
                    "Wait 200 days"
                );
                paid = uint256(deposit.amount).mul(4);
            } else if (deposit.duration == 250) {
                require(
                    block.timestamp.sub(deposit.startTime) > 250 * DAY,
                    "Wait 250 days"
                );
                paid = uint256(deposit.amount).mul(5);
            } else {
                require(
                    block.timestamp.sub(deposit.startTime) > 400 * DAY,
                    "Wait 400 days"
                );
                paid = uint256(deposit.amount).mul(7);
            }
        }
        return paid;
    }

    function ensureTimePackParams(
        uint256 _amount,
        uint8 _plan,
        uint16 _duration
    ) private pure {
        require(_plan == 5 || _plan == 6, "invalid timepack code");

        if (_plan == 5) {
            require(_amount >= BNB.div(2), "insufficient amount for hawkeye");
            require(
                _duration == 100 || _duration == 150 || _duration == 200,
                "invalid hawkeye duration"
            );
        }
        if (_plan == 6) {
            require(
                _amount >= BNB.mul(5),
                "insufficient amount for blackwidow"
            );

            require(
                _duration == 200 || _duration == 250 || _duration == 400,
                "invalid blackwidow duration"
            );
        }
    }

    function checkNewUserSender(address _referrer, uint8 plan) private {
        if (msg.sender == owner) return;
        if (referrers[msg.sender] == address(0)) {
            require(isActive(_referrer), "invalid referrer");
            referrers[msg.sender] = _referrer;
            updateSenderCheckpoint(plan);
            emit NewBie(msg.sender, _referrer, msg.value, plan);
        }
    }

    function updateSenderCheckpoint(uint8 plan) private {
        if (plan == 1) THORCheckpoints[msg.sender] = block.timestamp;
        else if (plan == 2) IRONMANCheckpoints[msg.sender] = block.timestamp;
        else if (plan == 3) CAPTAINCheckpoints[msg.sender] = block.timestamp;
        else if (plan == 4) HULKCheckpoints[msg.sender] = block.timestamp;
        else TimePackCheckpoints[msg.sender] = block.timestamp;
    }

    function payOwners(uint256 _amount) private {
        payable(ceoWallet).transfer(_amount.mul(25).div(1000));
        payable(devWallet).transfer(_amount.mul(25).div(1000));
        payable(adminWallet).transfer(_amount.mul(25).div(1000));
        payable(insuranceWallet).transfer(_amount.mul(25).div(1000));
        payable(marketingWallet).transfer(_amount.mul(25).div(1000));
    }

    function payReferralSender() private {
        address upline = referrers[msg.sender];
        for (uint256 i = 0; i < refPercents.length; i++) {
            if (upline != address(0)) {
                payable(upline).transfer(
                    refPercents[i].mul(msg.value).div(100)
                );
                upline = referrers[upline];
            } else break;
        }
    }

    function getMinDepositAmount(uint8 plan) public pure returns (uint256) {
        if (plan == 1) return BNB.div(10);
        if (plan == 2) return BNB.div(2);
        if (plan == 3) return BNB;
        if (plan == 4) return BNB.mul(3);
        if (plan == 5) return BNB.div(2);
        if (plan == 6) return BNB.mul(5);
        return 0;
    }

    function tradingTaxWithdraw(uint8 _plan) public pure returns (uint) {
        if (_plan == 1) return 100;
        if (_plan == 2) return 150;
        if (_plan == 3) return 250;
        if (_plan == 4) return 250;
        if (_plan == 5) return 125;
        if (_plan == 6) return 125;
        return 0;
    }

    function reinvestAmount(uint8 _plan) public pure returns (uint) {
        if (_plan == 1) return 100;
        if (_plan == 2) return 150;
        if (_plan == 3) return 400;
        if (_plan == 4) return 500;
        return 0;
    }

    function getDividends(
        address _user,
        uint8 plan
    ) public view returns (uint256) {
        uint256 total;
        uint256 planLength;
        uint256 checkpoint;
        uint256 rate = 5;
        if (plan == 1) {
            planLength = 2 ** 200; //infinit
            checkpoint = THORCheckpoints[_user];
            rate = 5;
        } else if (plan == 2) {
            planLength = 236 * DAY;
            checkpoint = IRONMANCheckpoints[_user];
            rate = 13;
        } else if (plan == 3) {
            planLength = 125 * DAY;
            checkpoint = CAPTAINCheckpoints[_user];
            rate = 24;
        } else if (plan == 4) {
            planLength = 54 * DAY;
            checkpoint = HULKCheckpoints[_user];
            rate = 50;
        }
        ROIDeposit[] memory deposits = ROIDeposits[_user];
        for (uint i = 0; i < deposits.length; i++) {
            ROIDeposit memory dep = deposits[i];
            if (dep.plan != plan) continue;
            uint256 endTime = uint256(dep.startTime).add(planLength);
            checkpoint = checkpoint < dep.startTime
                ? dep.startTime
                : checkpoint;
            if (endTime <= checkpoint) continue;
            endTime = endTime < block.timestamp ? endTime : block.timestamp;
            uint256 dividend = endTime.sub(checkpoint).mul(dep.amount);

            total = total.add(dividend);
        }
        return total.mul(rate).div(1000).div(DAY);
    }

    function isActive(address _user) public view returns (bool) {
        return
            ROIDeposits[_user].length > 0 || TimePackDeposits[_user].length > 0;
    }

    function withdrawCheckpoint(
        address _address
    ) public view returns (uint256) {
        uint256 checkpoint = THORCheckpoints[_address];
        if (IRONMANCheckpoints[_address] > checkpoint)
            checkpoint = IRONMANCheckpoints[_address];
        if (CAPTAINCheckpoints[_address] > checkpoint)
            checkpoint = CAPTAINCheckpoints[_address];
        if (HULKCheckpoints[_address] > checkpoint)
            checkpoint = HULKCheckpoints[_address];
        if (TimePackCheckpoints[_address] > checkpoint)
            checkpoint = TimePackCheckpoints[_address];

        return checkpoint;
    }

    function getROIDeposits(
        address _adr
    ) public view returns (ROIDeposit[] memory) {
        return ROIDeposits[_adr];
    }

    function getTimePacks(
        address _adr
    ) public view returns (TimePackDeposit[] memory) {
        return TimePackDeposits[_adr];
    }
}

library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
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
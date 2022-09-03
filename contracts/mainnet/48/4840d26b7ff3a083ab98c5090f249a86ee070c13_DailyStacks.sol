/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

// SPDX-License-Identifier: MIT
// Sources flattened with hardhat v2.11.0 https://hardhat.org

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) ||
                (!AddressUpgradeable.isContract(address(this)) &&
                    _initialized == 1),
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(
            !_initializing && _initialized < version,
            "Initializable: contract is already initialized"
        );
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// File contracts/contract.sol

pragma solidity 0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

contract DailyStacks is Initializable {
    using SafeMath for uint256;
    uint256 launch;
    uint256 hardDays;
    uint256 minStakeAmt;
    uint256 percentdiv;
    uint256 refPercentage;
    uint256 devPercentage;
    uint256 n;
    mapping(address => mapping(uint256 => Depo)) public DeposMap;
    mapping(address => User) public UsersKey;
    mapping(uint256 => DivPercs) public PercsKey;
    mapping(uint256 => FeesPercs) public FeesKey;
    mapping(uint256 => Main) public MainKey;
    mapping(uint256 => address) public Users;
    using SafeERC20 for IERC20;
    IERC20 public BUSD;
    address public owner;

    /// @custom:oz-upgrades-unsafe-allow
    function initialize() public initializer {
        owner = msg.sender;

        launch = 1662318000;
        hardDays = 86400;
        minStakeAmt = 50e18;
        percentdiv = 1000;
        refPercentage = 100;
        devPercentage = 100;

        PercsKey[10] = DivPercs(864000, 15);
        PercsKey[20] = DivPercs(1728000, 25);
        PercsKey[30] = DivPercs(2592000, 35);
        PercsKey[40] = DivPercs(3456000, 45);
        PercsKey[50] = DivPercs(4320000, 55);
        FeesKey[10] = FeesPercs(864000, 200);
        FeesKey[20] = FeesPercs(1728000, 180);
        FeesKey[30] = FeesPercs(3456000, 150);
        FeesKey[40] = FeesPercs(4320000, 120);

        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }

    //libraries
    struct User {
        uint256 startDate;
        uint256 divs;
        uint256 refBonus;
        uint256 totalInits;
        uint256 totalWiths;
        uint256 totalAccrued;
        uint256 lastWith;
        uint256 timesCmpd;
        uint256 keyCounter;
        Depo[] depoList;
    }
    struct Depo {
        uint256 key;
        uint256 depoTime;
        uint256 amt;
        address reffy;
        bool initialWithdrawn;
    }
    struct Main {
        uint256 ovrTotalDeps;
        uint256 ovrTotalWiths;
        uint256 users;
        uint256 compounds;
    }
    struct DivPercs {
        uint256 daysInSeconds; // updated to be in seconds
        uint256 divsPercentage;
    }
    struct FeesPercs {
        uint256 daysInSeconds;
        uint256 feePercentage;
    }

    function stakeStablecoins(uint256 amtx, address ref) external {
        require(block.timestamp >= launch, "App did not launch yet.");
        require(ref != msg.sender, "You cannot refer yourself!");
        require(amtx >= minStakeAmt, "You should stake at least 50.");
        BUSD.safeTransferFrom(msg.sender, address(this), amtx);
        User storage user = UsersKey[msg.sender];
        User storage user2 = UsersKey[ref];
        Main storage main = MainKey[1];
        if (user.lastWith == 0) {
            user.lastWith = block.timestamp;
            user.startDate = block.timestamp;
        }
        uint256 userStakePercentAdjustment = 1000 - devPercentage;
        uint256 adjustedAmt = amtx.mul(userStakePercentAdjustment).div(
            percentdiv
        );
        uint256 stakeFee = amtx.mul(devPercentage).div(percentdiv);

        user.totalInits += adjustedAmt;
        uint256 refAmtx = adjustedAmt.mul(refPercentage).div(percentdiv);
        if (ref != 0x000000000000000000000000000000000000dEaD) {
            user2.refBonus += refAmtx;
        }

        user.depoList.push(
            Depo({
                key: user.depoList.length,
                depoTime: block.timestamp,
                amt: adjustedAmt,
                reffy: ref,
                initialWithdrawn: false
            })
        );

        Users[n] = msg.sender;
        n += 1;
        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        main.users += 1;

        BUSD.safeTransfer(owner, stakeFee);
    }

    function userInfo() external view returns (Depo[] memory depoList) {
        User storage user = UsersKey[msg.sender];
        return (user.depoList);
    }

    function withdrawDivs() external returns (uint256 withdrawAmount) {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        uint256 x = calcdiv(msg.sender);

        for (uint i = 0; i < user.depoList.length; i++) {
            if (user.depoList[i].initialWithdrawn == false) {
                user.depoList[i].depoTime = block.timestamp;
            }
        }

        uint256 adjustedPercent = 1000 - devPercentage;
        uint256 adjustedAmt = x.mul(adjustedPercent).div(percentdiv);
        uint256 withdrawFee = x.mul(devPercentage).div(percentdiv);

        main.ovrTotalWiths += x;
        user.lastWith = block.timestamp;

        BUSD.safeTransfer(msg.sender, adjustedAmt);
        BUSD.safeTransfer(owner, withdrawFee);

        return x;
    }

    function withdrawInitial(uint256 keyy) external {
        User storage user = UsersKey[msg.sender];

        require(
            user.depoList[keyy].initialWithdrawn == false,
            "This has already been withdrawn."
        );

        uint256 initialAmt = user.depoList[keyy].amt;
        uint256 currDays1 = user.depoList[keyy].depoTime;
        uint256 currTime = block.timestamp;
        uint256 currDays = currTime - currDays1;
        uint256 transferAmt;

        if (currDays < FeesKey[10].daysInSeconds) {
            // LESS THAN 10 DAYS STAKED
            uint256 minusAmt = initialAmt.mul(FeesKey[10].feePercentage).div(
                percentdiv
            ); //20% fee

            uint256 dailyReturn = initialAmt
                .mul(PercsKey[10].divsPercentage)
                .div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);

            transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
            BUSD.safeTransfer(owner, minusAmt);
        } else if (
            currDays >= FeesKey[10].daysInSeconds &&
            currDays < FeesKey[20].daysInSeconds
        ) {
            // BETWEEN 20 and 30 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[20].feePercentage).div(
                percentdiv
            ); //18% fee

            uint256 dailyReturn = initialAmt
                .mul(PercsKey[10].divsPercentage)
                .div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
            transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
            BUSD.safeTransfer(owner, minusAmt);
        } else if (
            currDays >= FeesKey[20].daysInSeconds &&
            currDays < FeesKey[30].daysInSeconds
        ) {
            // BETWEEN 30 and 40 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[30].feePercentage).div(
                percentdiv
            ); //15% fee

            uint256 dailyReturn = initialAmt
                .mul(PercsKey[20].divsPercentage)
                .div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
            transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
            BUSD.safeTransfer(owner, minusAmt);
        } else if (
            currDays >= FeesKey[30].daysInSeconds &&
            currDays < FeesKey[40].daysInSeconds
        ) {
            // BETWEEN 30 and 40 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[40].feePercentage).div(
                percentdiv
            ); //15% fee

            uint256 dailyReturn = initialAmt
                .mul(PercsKey[30].divsPercentage)
                .div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
            transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
            BUSD.safeTransfer(owner, minusAmt);
        } else if (
            currDays >= FeesKey[40].daysInSeconds &&
            currDays < FeesKey[50].daysInSeconds
        ) {
            // BETWEEN 30 and 40 DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[40].feePercentage).div(
                percentdiv
            ); //12% fee

            uint256 dailyReturn = initialAmt
                .mul(PercsKey[40].divsPercentage)
                .div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
            transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
            BUSD.safeTransfer(owner, minusAmt);
        } else if (currDays >= FeesKey[50].daysInSeconds) {
            // 40+ DAYS
            uint256 minusAmt = initialAmt.mul(FeesKey[40].feePercentage).div(
                percentdiv
            ); //12% fee

            uint256 dailyReturn = initialAmt
                .mul(PercsKey[50].divsPercentage)
                .div(percentdiv);
            uint256 currentReturn = dailyReturn.mul(currDays).div(hardDays);
            transferAmt = initialAmt + currentReturn - minusAmt;

            user.depoList[keyy].amt = 0;
            user.depoList[keyy].initialWithdrawn = true;
            user.depoList[keyy].depoTime = block.timestamp;

            BUSD.safeTransfer(msg.sender, transferAmt);
            BUSD.safeTransfer(owner, minusAmt);
        } else {
            revert("Could not calculate the # of days youv've been staked.");
        }
    }

    function withdrawRefBonus() external {
        User storage user = UsersKey[msg.sender];
        uint256 amtz = user.refBonus;
        user.refBonus = 0;

        BUSD.safeTransfer(msg.sender, amtz);
    }

    function stakeRefBonus() external {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];
        require(user.refBonus > 10);
        uint256 refferalAmount = user.refBonus;
        user.refBonus = 0;
        address ref = 0x000000000000000000000000000000000000dEaD; //DEAD ADDRESS

        user.depoList.push(
            Depo({
                key: user.keyCounter,
                depoTime: block.timestamp,
                amt: refferalAmount,
                reffy: ref,
                initialWithdrawn: false
            })
        );

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
    }

    function calcdiv(address dy)
        public
        view
        returns (uint256 totalWithdrawable)
    {
        User storage user = UsersKey[dy];

        uint256 with;

        for (uint256 i = 0; i < user.depoList.length; i++) {
            uint256 elapsedTime = block.timestamp.sub(
                user.depoList[i].depoTime
            );

            uint256 amount = user.depoList[i].amt;
            if (user.depoList[i].initialWithdrawn == false) {
                if (elapsedTime <= PercsKey[20].daysInSeconds) {
                    uint256 dailyReturn = amount
                        .mul(PercsKey[10].divsPercentage)
                        .div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(
                        PercsKey[10].daysInSeconds / 10
                    );
                    with += currentReturn;
                }
                if (
                    elapsedTime > PercsKey[20].daysInSeconds &&
                    elapsedTime <= PercsKey[30].daysInSeconds
                ) {
                    uint256 dailyReturn = amount
                        .mul(PercsKey[20].divsPercentage)
                        .div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(
                        PercsKey[10].daysInSeconds / 10
                    );
                    with += currentReturn;
                }
                if (
                    elapsedTime > PercsKey[30].daysInSeconds &&
                    elapsedTime <= PercsKey[40].daysInSeconds
                ) {
                    uint256 dailyReturn = amount
                        .mul(PercsKey[30].divsPercentage)
                        .div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(
                        PercsKey[10].daysInSeconds / 10
                    );
                    with += currentReturn;
                }
                if (
                    elapsedTime > PercsKey[40].daysInSeconds &&
                    elapsedTime <= PercsKey[50].daysInSeconds
                ) {
                    uint256 dailyReturn = amount
                        .mul(PercsKey[40].divsPercentage)
                        .div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(
                        PercsKey[10].daysInSeconds / 10
                    );
                    with += currentReturn;
                }
                if (elapsedTime > PercsKey[50].daysInSeconds) {
                    uint256 dailyReturn = amount
                        .mul(PercsKey[50].divsPercentage)
                        .div(percentdiv);
                    uint256 currentReturn = dailyReturn.mul(elapsedTime).div(
                        PercsKey[10].daysInSeconds / 10
                    );
                    with += currentReturn;
                }
            }
        }
        return with;
    }

    function compound() external {
        User storage user = UsersKey[msg.sender];
        Main storage main = MainKey[1];

        uint256 y = calcdiv(msg.sender);

        for (uint i = 0; i < user.depoList.length; i++) {
            if (user.depoList[i].initialWithdrawn == false) {
                user.depoList[i].depoTime = block.timestamp;
            }
        }

        user.depoList.push(
            Depo({
                key: user.keyCounter,
                depoTime: block.timestamp,
                amt: y,
                reffy: 0x000000000000000000000000000000000000dEaD,
                initialWithdrawn: false
            })
        );

        user.keyCounter += 1;
        main.ovrTotalDeps += 1;
        main.compounds += 1;
        user.lastWith = block.timestamp;
    }
}
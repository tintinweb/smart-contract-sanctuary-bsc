// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TokenStake is Initializable, Member {
    
    using SafeMath for uint256;
    uint256 public totalDepositedAmount;
    uint256 public totalReward;
    uint256 public totalStakers;
    
    bool public pauseStake;
    bool public pauseWithdraw;
    bool public pauseGetReward;

    uint256 public timeLock;
    
    IERC20 mp;
    IERC20 stakeToken;

    struct PoolInfo {
        uint256 daliyDividends;
        uint256 rewardedAmount;
        uint256 totalDeposited;
        uint256 accSushiPerShare;   //從古至今，每質押1Mp，已派發獎勵的Mp(* 1e12)
    }

    struct UserInfo {
        uint256 depositedToken;
        uint256 rewardDebt;     // 負債值
        uint256 pendingReward;
        uint256 receivedReward;
        uint256 pendingWithdraw;
    }
    
    PoolInfo public poolInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => uint256) public lockRequest;

    event WithdrawRequest(address _user);
    event Withdraw(address _user, uint256 _amount);
    event GetReward(address _user, uint256 _amount);
    event Deposit(address _user, uint256 _amount);
    event UpdatePool(uint256 amount);
    event Recycle(uint256 _p);
    event RecoverTokens(address token, uint256 amount, address to);
    
    modifier validSender{
        require(msg.sender == manager.members("mpToken") || msg.sender == address(manager.members("nftMasterChef")) || msg.sender == manager.members("nft") || msg.sender == manager.members("updatecard"));
        _;
    }
    
    function initialize(IERC20 _mp, IERC20 _stakeToken) public initializer {
        __initializeMember();
        init();
        mp = _mp;
        stakeToken = _stakeToken;
    }

    function init() internal initializer {
        timeLock = 1 days;
    }

    function getDaliyTotalDeposited() public view returns(uint256) {
        return poolInfo.totalDeposited;
    }

    function claimReward(address _user) internal {
        uint256 reward = settleRewards(_user);
        userInfo[_user].pendingReward = userInfo[_user].pendingReward + (reward);
    }
    
    function update(uint256 amount) external validSender {
        totalReward = totalReward + (amount);
        // 當沒人質押，獎池金額回流至項目方
        if(poolInfo.totalDeposited == 0){
            IERC20(mp).transfer(address(manager.members("funder")), amount);
            emit Recycle(amount);
        }else{
            poolInfo.daliyDividends = poolInfo.daliyDividends + (amount);

            // 計算從古至今，每質押1Mp，已派發獎勵的Mp(* 1e12)
            poolInfo.accSushiPerShare = poolInfo.accSushiPerShare + (amount * (1e12) / (poolInfo.totalDeposited));
            emit UpdatePool(amount);
        }
    }
    
    function deposit(uint256 amount) public {
        require(lockRequest[msg.sender] == 0, "is in pending");
        require(amount > 0, "zero amount");
        require(pauseStake == false, "function is suspended");
        IERC20(stakeToken).transferFrom(msg.sender, address(this), amount);
        claimReward(msg.sender);
        if(userInfo[msg.sender].depositedToken == 0) {
            totalStakers++;
        }
        userInfo[msg.sender].depositedToken = userInfo[msg.sender].depositedToken + (amount);
        totalDepositedAmount = totalDepositedAmount + (amount);
        poolInfo.totalDeposited = poolInfo.totalDeposited + (amount);
        
        if(poolInfo.accSushiPerShare > 0){
            userInfo[msg.sender].rewardDebt = userInfo[msg.sender].depositedToken * (poolInfo.accSushiPerShare) / (1e12);
        }
        emit Deposit(msg.sender, amount);
    }

    function getReward() public {
        require(pauseGetReward == false, "function is suspended");
        uint256 reward = settleRewards(msg.sender);
        uint256 payReward = reward + (userInfo[msg.sender].pendingReward);
        userInfo[msg.sender].receivedReward = userInfo[msg.sender].receivedReward + (payReward);
        userInfo[msg.sender].pendingReward = 0;
        IERC20(mp).transfer(msg.sender, payReward);
        emit GetReward(msg.sender, reward);
    }

    function timeLockChange(uint256 _period) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "onlyOwner");
        timeLock = _period;
    }
    
    function tokenChange(IERC20 _mp, IERC20 _stakeToken) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "onlyOwner");
        mp = _mp;
        stakeToken = _stakeToken;
    }
    
    function withdraw() public {
        require(lockRequest[msg.sender] !=0 && block.timestamp >= lockRequest[msg.sender] + (timeLock), "locked");
        require(pauseWithdraw == false, "function is suspended");
        uint256 pendingWithdraw = userInfo[msg.sender].pendingWithdraw;
        uint256 fee = pendingWithdraw * (2) / (100);
        IERC20(stakeToken).transfer(msg.sender, pendingWithdraw - (fee));
        IERC20(stakeToken).transfer(address(manager.members("OfficalAddress")), fee);
        
        lockRequest[msg.sender] = 0;
        totalDepositedAmount = totalDepositedAmount - (pendingWithdraw);
        userInfo[msg.sender].pendingWithdraw = 0;
        emit Withdraw(msg.sender, pendingWithdraw);
    }

    function withdrawRequest() public {
        require(lockRequest[msg.sender] == 0, "is in pending");
        getReward();

        uint256 userDeposited = userInfo[msg.sender].depositedToken;
        poolInfo.totalDeposited = poolInfo.totalDeposited - (userDeposited);
        userInfo[msg.sender].depositedToken = 0;
        userInfo[msg.sender].pendingWithdraw = userDeposited;
        totalStakers--;
        lockRequest[msg.sender] = block.timestamp;
        emit WithdrawRequest(msg.sender);
        if(timeLock == 0){
            withdraw();
        }
    }
    
    function pendingRewards(address _user) public view returns (uint256 reward){
        if(userInfo[_user].depositedToken == 0){
            return 0;
        }

        // 從開始到現在都沒獎勵
        if(poolInfo.accSushiPerShare == 0){
            return 0;
        }

        reward = userInfo[_user].depositedToken * (poolInfo.accSushiPerShare) / (1e12) - (userInfo[_user].rewardDebt);
        reward = reward + (userInfo[_user].pendingReward);
    }

    function settleRewards(address _user) internal returns (uint256 reward){
        if(userInfo[_user].depositedToken == 0){
            return 0;
        }
        
        // 從開始到現在都沒獎勵
        if(poolInfo.accSushiPerShare == 0){
            return 0;
        }

        reward = userInfo[_user].depositedToken * (poolInfo.accSushiPerShare) / (1e12) - (userInfo[_user].rewardDebt);
        poolInfo.rewardedAmount=poolInfo.rewardedAmount + (reward);
        userInfo[_user].rewardDebt = userInfo[_user].depositedToken * (poolInfo.accSushiPerShare) / (1e12);
    }
    
    function setPauseStake(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseStake = _pause;
    }

    function setPauseWithdraw(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseWithdraw = _pause;
    }

    function setPauseGetReward(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseGetReward = _pause;
    }

    function setPauseAll(bool _pause) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        pauseStake = _pause;
        pauseWithdraw = _pause;
        pauseGetReward = _pause;
    }

    function recoverTokens(address token, uint256 amount, address to) external {
        require(manager.members("owner") != address(0), "member owner empty");
        require(msg.sender == manager.members("owner"), "only owner");
        require(IERC20(token).balanceOf(address(this)) >= amount, "balance not enough");
        IERC20(token).transfer(to, amount);
        emit RecoverTokens(token, amount, to);
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";
import "./Manager.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
abstract contract Member is Initializable, ContractOwner {
    modifier CheckPermit(string memory permit) {
        require(manager.userPermits(msg.sender, permit),
            "no permit");
        _;
    }
    
    Manager public manager;
    
    function __initializeMember() internal initializer {
        contractOwner = msg.sender;
    }
    
    function setManager(address addr) external ContractOwnerOnly {
        manager = Manager(addr);
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
    
    function approve(address spender, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function burn(uint256 amount) external;
    function mint(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

pragma solidity ^0.8.0;
// SPDX-License-Identifier: SimPL-2.0

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
abstract contract ContractOwner is Initializable {
    address public contractOwner;
    
    modifier ContractOwnerOnly {
        require(msg.sender == contractOwner, "contract owner only");
        _;
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Manager is Initializable, ContractOwner {
    mapping(string => address) public members;
    
    mapping(address => mapping(string => bool)) public userPermits;
    

    function initialize() public initializer {
        contractOwner = msg.sender;
    }
    function setMember(string memory name, address member)
        external ContractOwnerOnly {
        
        members[name] = member;
    }
    
    function setUserPermit(address user, string memory permit,
        bool enable) external ContractOwnerOnly {
        
        userPermits[user][permit] = enable;
    }
    
    function getTimestamp() external view returns(uint256) {
        return block.timestamp;
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
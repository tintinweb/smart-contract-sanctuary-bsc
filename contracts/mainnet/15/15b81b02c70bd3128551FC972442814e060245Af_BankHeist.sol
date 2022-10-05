import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

pragma solidity ^0.8.7;

abstract contract ManageableUpgradeable is OwnableUpgradeable {
    mapping(address => bool) private _managers;
    event ManagerAdded(address indexed manager_);
    event ManagerRemoved(address indexed manager_);

    function managers(address manager_) public view virtual returns (bool) {
        return _managers[manager_];
    }

    modifier onlyManager() {
        require(_managers[_msgSender()], "Manageable: caller is not the owner");
        _;
    }

    function removeManager(address manager_) public virtual onlyOwner {
        _managers[manager_] = false;
        emit ManagerRemoved(manager_);
    }

    function addManager(address manager_) public virtual onlyOwner {
        require(
            manager_ != address(0),
            "Manageable: new owner is the zero address"
        );
        _managers[manager_] = true;
        emit ManagerAdded(manager_);
    }
}

contract BankHeist is
    Initializable,
    IERC20Upgradeable,
    OwnableUpgradeable,
    ManageableUpgradeable
{
    uint256 public override totalSupply;
    string public name;
    uint8 public decimals;
    string public symbol;

    IERC20Upgradeable public LP;
    address public BANK;

    uint256 public maxStakingsPerTier;
    bool public transfersEnabled;

    address[] public tokens;

    struct Rewards {
        uint256 timestamp;
        uint256[] totalStaked;
        address token;
        uint256 amount;
    }

    Rewards[] public rewards;

    struct Tier {
        uint256 duration;
        uint256 totalStaked;
        uint256 allocation;
    }

    Tier[] public tiers;

    struct Lock {
        uint256 tier;
        uint256 amount;
        uint256 start;
        uint256 release;
        uint256 claim;
    }

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    mapping(address => uint256[]) public stakings;
    mapping(address => Lock[]) public lockedTokens;
    mapping(address => bool) public isBlacklisted;
    mapping(address => uint256) public thresholds;
    mapping(address => uint256) public counter;

    function initialize(
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        address lp,
        address bank,
        uint256 maxStakings
    ) public initializer {
        __Ownable_init();
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;

        LP = IERC20Upgradeable(lp);
        BANK = bank;

        maxStakingsPerTier = maxStakings;
        transfersEnabled = false;

        tokens = [
            0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,
            0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56,
            0xf22894d191212b6871182417dF61aD832bCe57C7
        ];

        tiers.push(Tier(30 days, 0, 5));
        tiers.push(Tier(90 days, 0, 15));
        tiers.push(Tier(180 days, 0, 30));
        tiers.push(Tier(365 days, 0, 50));

        emit OwnershipTransferred(address(0), _msgSender());
    }

    function getTiers() public view returns (Tier[] memory) {
        return tiers;
    }

    function getLockedTokens(address user) public view returns (Lock[] memory) {
        return lockedTokens[user];
    }

    function getStakings(address user) public view returns (uint256[] memory) {
        return stakings[user];
    }

    function unsafe_inc8(uint8 x) private pure returns (uint8) {
        unchecked {
            return x + 1;
        }
    }

    function unsafe_inc(uint256 x) private pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }

    function getAvailableRewards(address user)
        public
        view
        returns (uint256[] memory)
    {
        Lock[] memory lock = lockedTokens[user];
        Rewards[] memory rewards_ = rewards;
        Tier[] memory tiers_ = tiers;
        address[] memory tokens_ = tokens;

        uint256[] memory values = new uint256[](tokens.length);

        for (uint8 i = 0; i < lock.length; i = unsafe_inc8(i)) {
            for (uint256 j = 0; j < rewards_.length; j = unsafe_inc(j)) {
                if (lock[i].claim < rewards_[j].timestamp) {
                    for (uint8 k = 0; k < tokens_.length; k = unsafe_inc8(k)) {
                        if (rewards_[j].token == tokens_[k]) {
                            values[k] +=
                                (((rewards_[j].amount *
                                    tiers_[lock[i].tier].allocation) / 100) *
                                    lock[i].amount) /
                                rewards_[j].totalStaked[lock[i].tier];
                            break;
                        }
                    }
                }
            }
        }
        return values;
    }

    function _claimRewards(address user) internal {
        uint256[] memory values = getAvailableRewards(user);

        Lock[] memory lock = lockedTokens[user];

        for (uint256 i = 0; i < lock.length; i++) {
            lockedTokens[user][i].claim = block.timestamp;
        }

        for (uint256 i = 0; i < values.length; i++) {
            if (values[i] > 0) {
                IERC20Upgradeable(tokens[i]).transferFrom(
                    BANK,
                    user,
                    values[i]
                );
            }
        }
    }

    function claimRewards() public {
        _claimRewards(_msgSender());
    }

    function _addRewards(address token, uint256 amount) internal {
        uint256[] memory totalStaked = new uint256[](tiers.length);

        for (uint256 i = 0; i < tiers.length; i++) {
            totalStaked[i] = tiers[i].totalStaked;
        }

        rewards.push(
            Rewards({
                timestamp: block.timestamp,
                totalStaked: totalStaked,
                token: token,
                amount: amount
            })
        );
    }

    function addRewards(address token, uint256 amount) public onlyManager {
        IERC20Upgradeable(token).transfer(BANK, amount);
        counter[token] += amount;
        if (counter[token] >= thresholds[token]) {
            _addRewards(token, amount);
            counter[token] = 0;
        }
    }

    function addRewardsOwner(address token, uint256 amount) public onlyOwner {
        _addRewards(token, amount);
    }

    function stake(uint256 tierId, uint256 amount) public {
        require(tierId < tiers.length, "STAKE: Invalid tier");
        if (stakings[_msgSender()].length == 0) {
            for (uint256 i = 0; i < tiers.length; i++) {
                stakings[_msgSender()].push(0);
            }
        }
        stakings[_msgSender()][tierId] += 1;
        require(
            stakings[_msgSender()][tierId] <= maxStakingsPerTier,
            "STAKE: You have too many stakings running for that tier."
        );
        LP.transferFrom(_msgSender(), BANK, amount);
        lockedTokens[_msgSender()].push(
            Lock(
                tierId,
                amount,
                block.timestamp,
                block.timestamp + tiers[tierId].duration,
                block.timestamp
            )
        );
        tiers[tierId].totalStaked += amount;
        _mint(_msgSender(), amount);
    }

    function unstake(uint256 lockId) public {
        Lock memory lock = lockedTokens[_msgSender()][lockId];
        require(
            block.timestamp >= lock.release,
            "UNSTAKE: Not yet unstakeable."
        );
        _claimRewards(_msgSender());
        if (lockedTokens[_msgSender()].length > 1) {
            lockedTokens[_msgSender()][lockId] = lockedTokens[_msgSender()][
                lockedTokens[_msgSender()].length - 1
            ];
        }
        lockedTokens[_msgSender()].pop();
        stakings[_msgSender()][lock.tier] -= 1;
        tiers[lock.tier].totalStaked -= lock.amount;
    }

    function increaseStake(uint256 lockId, uint256 amount) public {
        require(
            lockId < lockedTokens[_msgSender()].length,
            "INCREASE: Invalid tier"
        );
        _claimRewards(_msgSender());
        Lock memory lock = lockedTokens[_msgSender()][lockId];
        LP.transferFrom(_msgSender(), BANK, amount);
        tiers[lock.tier].totalStaked += amount;
        lock.amount += amount;
        lock.start = block.timestamp;
        lock.release = block.timestamp + tiers[lock.tier].duration;
        lock.claim = block.timestamp;
        lockedTokens[_msgSender()][lockId] = lock;
        _mint(_msgSender(), amount);
    }

    function moveStake(uint256 lockId, uint256 tierId) public {
        require(
            lockId < lockedTokens[_msgSender()].length,
            "MOVE: Invalid tier"
        );
        require(tierId < tiers.length, "MOVE: Invalid tier");
        Lock memory lock = lockedTokens[_msgSender()][lockId];
        require(lock.tier < tierId, "MOVE: Can only move up.");
        tiers[lock.tier].totalStaked -= lock.amount;
        tiers[tierId].totalStaked += lock.amount;
        stakings[_msgSender()][tierId] += 1;
        stakings[_msgSender()][lock.tier] -= 1;
        require(
            stakings[_msgSender()][tierId] <= maxStakingsPerTier,
            "STAKE: You have too many stakings running for that tier."
        );
        _claimRewards(_msgSender());
        lock.tier = tierId;
        lock.start = block.timestamp;
        lock.release = block.timestamp + tiers[tierId].duration;
        lock.claim = block.timestamp;
        lockedTokens[_msgSender()][lockId] = lock;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) private {
        require(
            _from != address(0),
            "TRANSFER: Transfer from the dead address"
        );
        require(_to != address(0), "TRANSFER: Transfer to the dead address");
        require(_value > 0, "TRANSFER: Invalid amount");
        require(isBlacklisted[_from] == false, "TRANSFER: isBlacklisted");
        require(balances[_from] >= _value, "TRANSFER: Insufficient balance");
        require(transfersEnabled, "TRANSFER: Transfers are disabled.");
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value)
        public
        override
        returns (bool success)
    {
        _transfer(_msgSender(), _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        if (allowances[_from][_msgSender()] < type(uint256).max) {
            allowances[_from][_msgSender()] -= _value;
        }
        _transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value)
        public
        override
        returns (bool success)
    {
        _approve(_msgSender(), _spender, _value);
        return true;
    }

    function _approve(
        address _sender,
        address _spender,
        uint256 _value
    ) private returns (bool success) {
        allowances[_sender][_spender] = _value;
        emit Approval(_sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return allowances[_owner][_spender];
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }

    function unstake(address user, uint256 lockId) public onlyOwner {
        Lock memory lock = lockedTokens[user][lockId];
        lockedTokens[user][lockId] = lockedTokens[user][
            lockedTokens[user].length - 1
        ];
        lockedTokens[user].pop();
        stakings[user][lock.tier] -= 1;
        tiers[lock.tier].totalStaked -= lock.amount;
        _burn(user, lock.amount);
        LP.transferFrom(BANK, user, lock.amount);
    }

    function setTransfersEnabled(bool value) public onlyOwner {
        transfersEnabled = value;
    }

    function setIsBlacklisted(address user, bool value) public onlyOwner {
        isBlacklisted[user] = value;
    }

    function setTokens(address[] memory tokens_) public onlyOwner {
        tokens = tokens_;
    }

    function setLp(address lp) public onlyOwner {
        LP = IERC20Upgradeable(lp);
    }

    function setThresholds(address token, uint256 amount) public onlyOwner {
        thresholds[token] = amount;
    }

    function withdrawTokens() public onlyOwner {
        _transfer(address(this), owner(), balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20Upgradeable.sol";

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";

interface IVault {
    function WETH() external view returns (address);

    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            address[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );

    enum JoinKind {
        INIT,
        EXACT_TOKENS_IN_FOR_BPT_OUT,
        TOKEN_IN_FOR_EXACT_BPT_OUT,
        ALL_TOKENS_IN_FOR_EXACT_BPT_OUT
    }

    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;

    struct JoinPoolRequest {
        address[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    enum ExitKind {
        EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
        EXACT_BPT_IN_FOR_TOKENS_OUT,
        BPT_IN_FOR_EXACT_TOKENS_OUT,
        MANAGEMENT_FEE_TOKENS_OUT // for InvestmentPool
    }

    function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest memory request
    ) external;

    struct ExitPoolRequest {
        address[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        address assetIn;
        address assetOut;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external returns (uint256 amountCalculated);
}

interface Bank {
    function addRewards(address token, uint256 amount) external;
}

contract TokenV2 is Initializable, IERC20Upgradeable, OwnableUpgradeable {
    uint256 public override totalSupply;

    string public name;
    uint8 public decimals;
    string public symbol;

    bytes32 public POOL_ID;

    // [rewards, growth, bank]
    address[3] public feesReceivers;

    // [rewards, liqudity, growth, bank]
    uint8[4] buyFeesDistribution;
    uint8[4] saleFeesDistribution;
    uint8[4] transferFeesDistribution;

    // [rewards, liqudity, growth, total]
    uint256[5] public feesCounter;

    uint256 public swapThreshold;

    bool public executeSwapsActive;

    IVault public BAL_VAULT;

    address public FEE_BOT;

    struct Fees {
        uint8 buy;
        uint8 sale;
        uint8 transfer;
    }

    Fees public fees;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    mapping(address => bool) public isLiquidityPair;
    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isExcludedFromFee;

    event ExecSwap(
        uint256 toLiq,
        uint256 toGrowth,
        uint256 toBank,
        uint256 total
    );

    function initialize(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        address _vault,
        address _rewards,
        address _growth,
        address _bank,
        address _feeBot
    ) public initializer {
        __Ownable_init();
        balances[_msgSender()] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;

        BAL_VAULT = IVault(_vault);
        FEE_BOT = _feeBot;

        _approve(msg.sender, address(BAL_VAULT), type(uint256).max);
        _approve(address(this), address(BAL_VAULT), type(uint256).max);
        IERC20Upgradeable(BAL_VAULT.WETH()).approve(
            address(BAL_VAULT),
            type(uint256).max
        );

        isLiquidityPair[address(BAL_VAULT)] = true;

        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[_rewards] = true;
        isExcludedFromFee[_growth] = true;
        isExcludedFromFee[_bank] = true;
        isExcludedFromFee[_feeBot] = true;

        emit Transfer(address(0), _msgSender(), _initialAmount);
        emit OwnershipTransferred(address(0), _msgSender());

        fees = Fees({buy: 10, sale: 10, transfer: 10});
        feesReceivers = [_rewards, _growth, _bank];
        buyFeesDistribution = [10, 20, 50, 20];
        saleFeesDistribution = [10, 20, 50, 20];
        transferFeesDistribution = [10, 20, 50, 20];
        feesCounter = [0, 0, 0, 0, 0];
        swapThreshold = 100e18;
        executeSwapsActive = true;
        POOL_ID = 0x0000000000000000000000000000000000000000000000000000000000000000;
    }

    function _transferExcluded(
        address _from,
        address _to,
        uint256 _value
    ) private {
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function _transferNoneExcluded(
        address _from,
        address _to,
        uint256 _value
    ) private {
        balances[_from] -= _value;

        uint256 feeValue = 0;
        uint8[4] memory feesDistribution;

        if (isLiquidityPair[_from]) {
            // buy
            feeValue = (_value * fees.buy) / 100;
            feesDistribution = buyFeesDistribution;
        } else if (isLiquidityPair[_to]) {
            // sell
            feeValue = (_value * fees.sale) / 100;
            feesDistribution = saleFeesDistribution;
        } else {
            // transfer
            feeValue = (_value * fees.transfer) / 100;
            feesDistribution = transferFeesDistribution;
        }

        uint256 receivedValue = _value - feeValue;

        // REWARDS POOL
        uint256 rewardsFee = (feeValue * feesDistribution[0]) / 100;
        feesCounter[0] += rewardsFee;
        balances[feesReceivers[0]] += rewardsFee;
        emit Transfer(_from, feesReceivers[0], rewardsFee);

        // LIQUIDITY AND GROWTH
        for (uint8 i = 1; i < 4; i++) {
            feesCounter[i] += (feeValue * feesDistribution[i]) / 100;
        }
        balances[address(this)] += feeValue - rewardsFee;
        emit Transfer(_from, address(this), feeValue - rewardsFee);

        feesCounter[4] += feeValue - rewardsFee;
        if (feesCounter[4] >= swapThreshold && executeSwapsActive)
            _executeSwaps();

        balances[_to] += receivedValue;
        emit Transfer(_from, _to, receivedValue);
    }

    function _executeSwaps() private {
        uint256 toLiq = feesCounter[1];
        uint256 toGrowth = feesCounter[2];
        uint256 toBank = feesCounter[3];
        uint256 total = feesCounter[4];

        balances[address(this)] -= total;
        balances[FEE_BOT] += total;
        emit Transfer(address(this), FEE_BOT, total);
        emit ExecSwap(toLiq, toGrowth, toBank, total);

        feesCounter[1] = 0;
        feesCounter[2] = 0;
        feesCounter[3] = 0;
        feesCounter[4] = 0;
    }

    function _executeTransfer(
        address _from,
        address _to,
        uint256 _value
    ) private {
        if (isExcludedFromFee[_from] || isExcludedFromFee[_to])
            _transferExcluded(_from, _to, _value);
        else _transferNoneExcluded(_from, _to, _value);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) private {
        require(
            _from != address(0),
            "TRANSFER: Transfer from the dead address"
        );
        require(_to != address(0), "TRANSFER: Transfer to the dead address");
        require(_value > 0, "TRANSFER: Invalid amount");
        require(isBlacklisted[_from] == false, "TRANSFER: isBlacklisted");
        require(balances[_from] >= _value, "TRANSFER: Insufficient balance");
        _executeTransfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value)
        public
        override
        returns (bool success)
    {
        _transfer(_msgSender(), _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        if (allowances[_from][_msgSender()] < type(uint256).max) {
            allowances[_from][_msgSender()] -= _value;
        }
        _transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value)
        public
        override
        returns (bool success)
    {
        _approve(_msgSender(), _spender, _value);
        return true;
    }

    function _approve(
        address _sender,
        address _spender,
        uint256 _value
    ) private returns (bool success) {
        allowances[_sender][_spender] = _value;
        emit Approval(_sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return allowances[_owner][_spender];
    }

    /***********************************|
    |         Owner Functions           |
    |__________________________________*/

    function setPoolid(bytes32 poolId) public onlyOwner {
        POOL_ID = poolId;
    }

    function setFeeBot(address feeBot) public onlyOwner {
        FEE_BOT = feeBot;
    }

    function getPoolId() public view returns (bytes32) {
        return POOL_ID;
    }

    function setIsBlacklisted(address user, bool value) public onlyOwner {
        isBlacklisted[user] = value;
    }

    function setIsExcludedFromFee(address user, bool value) public onlyOwner {
        isExcludedFromFee[user] = value;
    }

    function setIsLiquidityPair(address user, bool value) public onlyOwner {
        isLiquidityPair[user] = value;
    }

    function setVault(address vault) public onlyOwner {
        BAL_VAULT = IVault(vault);
    }

    function approveOnRouter() public onlyOwner {
        _approve(address(this), address(BAL_VAULT), type(uint256).max);
    }

    function setFees(
        uint8 buy_,
        uint8 sale_,
        uint8 transfer_
    ) public onlyOwner {
        fees = Fees({buy: buy_, sale: sale_, transfer: transfer_});
    }

    function setFeesReceivers(address[3] memory value) public onlyOwner {
        feesReceivers = value;
    }

    function setBuyFeesDistribution(uint8[4] memory value) public onlyOwner {
        buyFeesDistribution = value;
    }

    function setSaleFeesDistribution(uint8[4] memory value) public onlyOwner {
        saleFeesDistribution = value;
    }

    function setTransferFeesDistribution(uint8[4] memory value)
        public
        onlyOwner
    {
        transferFeesDistribution = value;
    }

    function setSwapThreshold(uint256 value) public onlyOwner {
        swapThreshold = value;
    }

    function setExecuteSwapsActive(bool value) public onlyOwner {
        executeSwapsActive = value;
    }

    function withdrawTokens() public onlyOwner {
        _transferExcluded(address(this), owner(), balanceOf(address(this)));
    }
}

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";

interface IVault {
    function WETH() external view returns (address);

    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            address[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );

    enum JoinKind {
        INIT,
        EXACT_TOKENS_IN_FOR_BPT_OUT,
        TOKEN_IN_FOR_EXACT_BPT_OUT,
        ALL_TOKENS_IN_FOR_EXACT_BPT_OUT
    }

    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;

    struct JoinPoolRequest {
        address[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    enum ExitKind {
        EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
        EXACT_BPT_IN_FOR_TOKENS_OUT,
        BPT_IN_FOR_EXACT_TOKENS_OUT,
        MANAGEMENT_FEE_TOKENS_OUT // for InvestmentPool
    }

    function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest memory request
    ) external;

    struct ExitPoolRequest {
        address[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        address assetIn;
        address assetOut;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external returns (uint256 amountCalculated);
}

interface Bank {
    function addRewards(address token, uint256 amount) external;
}

contract Token is Initializable, IERC20Upgradeable, OwnableUpgradeable {
    uint256 public override totalSupply;

    string public name;
    uint8 public decimals;
    string public symbol;

    bytes32 public POOL_ID;

    // [rewards, growth, bank]
    address[3] public feesReceivers;

    // [rewards, liqudity, growth, bank]
    uint8[4] buyFeesDistribution;
    uint8[4] saleFeesDistribution;
    uint8[4] transferFeesDistribution;

    // [rewards, liqudity, growth, total]
    uint256[5] public feesCounter;

    uint256 public swapThreshold;

    bool public executeSwapsActive;

    IVault public BAL_VAULT;

    struct Fees {
        uint8 buy;
        uint8 sale;
        uint8 transfer;
    }

    Fees public fees;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    mapping(address => bool) public isLiquidityPair;
    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isExcludedFromFee;

    function initialize(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        address _vault,
        address _rewards,
        address _growth,
        address _bank
    ) public initializer {
        __Ownable_init();
        balances[_msgSender()] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;

        BAL_VAULT = IVault(_vault);

        _approve(msg.sender, address(BAL_VAULT), type(uint256).max);
        _approve(address(this), address(BAL_VAULT), type(uint256).max);
        IERC20Upgradeable(BAL_VAULT.WETH()).approve(
            address(BAL_VAULT),
            type(uint256).max
        );

        isLiquidityPair[address(BAL_VAULT)] = true;

        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[_rewards] = true;
        isExcludedFromFee[_growth] = true;
        isExcludedFromFee[_bank] = true;

        emit Transfer(address(0), _msgSender(), _initialAmount);
        emit OwnershipTransferred(address(0), _msgSender());

        fees = Fees({buy: 10, sale: 10, transfer: 10});
        feesReceivers = [_rewards, _growth, _bank];
        buyFeesDistribution = [10, 20, 50, 20];
        saleFeesDistribution = [10, 20, 50, 20];
        transferFeesDistribution = [10, 20, 50, 20];
        feesCounter = [0, 0, 0, 0, 0];
        swapThreshold = 100e18;
        executeSwapsActive = true;
        POOL_ID = 0x0000000000000000000000000000000000000000000000000000000000000000;
    }

    function _transferExcluded(
        address _from,
        address _to,
        uint256 _value
    ) private {
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function _transferNoneExcluded(
        address _from,
        address _to,
        uint256 _value
    ) private {
        balances[_from] -= _value;

        uint256 feeValue = 0;
        uint8[4] memory feesDistribution;

        if (isLiquidityPair[_from]) {
            // buy
            feeValue = (_value * fees.buy) / 100;
            feesDistribution = buyFeesDistribution;
        } else if (isLiquidityPair[_to]) {
            // sell
            feeValue = (_value * fees.sale) / 100;
            feesDistribution = saleFeesDistribution;
        } else {
            // transfer
            feeValue = (_value * fees.transfer) / 100;
            feesDistribution = transferFeesDistribution;
        }

        uint256 receivedValue = _value - feeValue;

        // REWARDS POOL
        uint256 rewardsFee = (feeValue * feesDistribution[0]) / 100;
        feesCounter[0] += rewardsFee;
        balances[feesReceivers[0]] += rewardsFee;
        emit Transfer(_from, feesReceivers[0], rewardsFee);

        // LIQUIDITY AND GROWTH
        for (uint8 i = 1; i < 4; i++) {
            feesCounter[i] += (feeValue * feesDistribution[i]) / 100;
        }
        balances[address(this)] = feeValue - rewardsFee;
        emit Transfer(_from, address(this), feeValue - rewardsFee);

        feesCounter[4] += feeValue - rewardsFee;
        if (feesCounter[4] >= swapThreshold && executeSwapsActive)
            _executeSwaps();

        balances[_to] += receivedValue;
        emit Transfer(_from, _to, receivedValue);
    }

    function _executeSwaps() private {
        uint256 toLiquidity = feesCounter[1] / 2;
        uint256 toGrowth = feesCounter[2];
        uint256 toBank = feesCounter[3];

        bytes memory temp;
        IVault.SingleSwap memory singleSwap = IVault.SingleSwap(
            POOL_ID,
            IVault.SwapKind.GIVEN_IN,
            address(this),
            BAL_VAULT.WETH(),
            toLiquidity + toGrowth + toBank,
            temp
        );

        IVault.FundManagement memory funds = IVault.FundManagement(
            address(this),
            false,
            payable(address(this)),
            false
        );

        BAL_VAULT.swap(singleSwap, funds, 0, block.timestamp + 100000);

        uint256 bnbBalance = IERC20Upgradeable(BAL_VAULT.WETH()).balanceOf(
            address(this)
        );

        address[] memory assets = new address[](2);
        assets[0] = BAL_VAULT.WETH();
        assets[1] = address(this);

        uint256[] memory amountsIn = new uint256[](2);
        amountsIn[0] = (bnbBalance * toLiquidity) / feesCounter[4];
        amountsIn[1] = toLiquidity;

        bytes memory data = abi.encode(
            IVault.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT,
            amountsIn
        );

        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest(
            assets,
            amountsIn,
            data,
            false
        );

        BAL_VAULT.joinPool(
            POOL_ID,
            address(this),
            payable(feesReceivers[1]),
            request
        );

        IERC20Upgradeable(BAL_VAULT.WETH()).transfer(
            feesReceivers[1],
            (bnbBalance * toGrowth) / feesCounter[4]
        );

        IERC20Upgradeable(BAL_VAULT.WETH()).transfer(
            feesReceivers[2],
            (bnbBalance * toBank) / feesCounter[4]
        );

        Bank(feesReceivers[2]).addRewards(
            BAL_VAULT.WETH(),
            (bnbBalance * toBank) / feesCounter[4]
        );

        feesCounter[1] = 0;
        feesCounter[2] = 0;
        feesCounter[3] = 0;
        feesCounter[4] = 0;
    }

    function _executeTransfer(
        address _from,
        address _to,
        uint256 _value
    ) private {
        if (isExcludedFromFee[_from] || isExcludedFromFee[_to])
            _transferExcluded(_from, _to, _value);
        else _transferNoneExcluded(_from, _to, _value);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) private {
        require(
            _from != address(0),
            "TRANSFER: Transfer from the dead address"
        );
        require(_to != address(0), "TRANSFER: Transfer to the dead address");
        require(_value > 0, "TRANSFER: Invalid amount");
        require(isBlacklisted[_from] == false, "TRANSFER: isBlacklisted");
        require(balances[_from] >= _value, "TRANSFER: Insufficient balance");
        _executeTransfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value)
        public
        override
        returns (bool success)
    {
        _transfer(_msgSender(), _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        if (allowances[_from][_msgSender()] < type(uint256).max) {
            allowances[_from][_msgSender()] -= _value;
        }
        _transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value)
        public
        override
        returns (bool success)
    {
        _approve(_msgSender(), _spender, _value);
        return true;
    }

    function _approve(
        address _sender,
        address _spender,
        uint256 _value
    ) private returns (bool success) {
        allowances[_sender][_spender] = _value;
        emit Approval(_sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return allowances[_owner][_spender];
    }

    /***********************************|
    |         Owner Functions           |
    |__________________________________*/

    function setPoolid(bytes32 poolId) public onlyOwner {
        POOL_ID = poolId;
    }

    function getPoolId() public view returns (bytes32) {
        return POOL_ID;
    }

    function setIsBlacklisted(address user, bool value) public onlyOwner {
        isBlacklisted[user] = value;
    }

    function setIsExcludedFromFee(address user, bool value) public onlyOwner {
        isExcludedFromFee[user] = value;
    }

    function setIsLiquidityPair(address user, bool value) public onlyOwner {
        isLiquidityPair[user] = value;
    }

    function setVault(address vault) public onlyOwner {
        BAL_VAULT = IVault(vault);
    }

    function approveOnRouter() public onlyOwner {
        _approve(address(this), address(BAL_VAULT), type(uint256).max);
    }

    function setFees(
        uint8 buy_,
        uint8 sale_,
        uint8 transfer_
    ) public onlyOwner {
        fees = Fees({buy: buy_, sale: sale_, transfer: transfer_});
    }

    function setFeesReceivers(address[3] memory value) public onlyOwner {
        feesReceivers = value;
    }

    function setBuyFeesDistribution(uint8[4] memory value) public onlyOwner {
        buyFeesDistribution = value;
    }

    function setSaleFeesDistribution(uint8[4] memory value) public onlyOwner {
        saleFeesDistribution = value;
    }

    function setTransferFeesDistribution(uint8[4] memory value)
        public
        onlyOwner
    {
        transferFeesDistribution = value;
    }

    function setSwapThreshold(uint256 value) public onlyOwner {
        swapThreshold = value;
    }

    function setExecuteSwapsActive(bool value) public onlyOwner {
        executeSwapsActive = value;
    }

    function withdrawTokens() public onlyOwner {
        _transferExcluded(address(this), owner(), balanceOf(address(this)));
    }
}

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity ^0.8.7;

abstract contract ManageableUpgradeable is OwnableUpgradeable {
    mapping(address => bool) private _managers;
    event ManagerAdded(address indexed manager_);
    event ManagerRemoved(address indexed manager_);

    function managers(address manager_) public view virtual returns (bool) {
        return _managers[manager_];
    }

    modifier onlyManager() {
        require(_managers[_msgSender()], "Manageable: caller is not the owner");
        _;
    }

    function removeManager(address manager_) public virtual onlyOwner {
        _managers[manager_] = false;
        emit ManagerRemoved(manager_);
    }

    function addManager(address manager_) public virtual onlyOwner {
        require(
            manager_ != address(0),
            "Manageable: new owner is the zero address"
        );
        _managers[manager_] = true;
        emit ManagerAdded(manager_);
    }
}

interface IManager {
    function compoundHelper(
        uint256 id,
        uint256 externalRewards,
        address user
    ) external;

    function getNetDeposit(address user) external returns (int256);
}

interface ITeams {
    function getReferrer(address user) external view returns (address);

    function getReferred(address user) external view returns (address[] memory);
}

interface IBank {
    function addRewards(address token, uint256 amount) external;
}

interface IWETH {
    function transfer(address dst, uint256 wad) external returns (bool);

    function deposit() external payable;

    receive() external payable;

    function balanceOf(address) external view returns (uint256);
}

contract Teams is Initializable, OwnableUpgradeable, ManageableUpgradeable {
    address payable public BANK;
    address public MARKETING_WALLET;
    IERC20 public TOKEN;
    address public POOL;
    IManager public MANAGER;
    ITeams public TEAMS_V1;

    uint256 public changeTeamCost;
    uint256 public claimFee;
    uint256 public compoundFee;

    mapping(address => address) public referrers;
    mapping(address => address[]) public referred;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public claimedRewards;
    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public hasMerged;

    function initialize(
        address payable bank,
        address marketing,
        address token,
        address pool,
        address manager,
        address teamsv1
    ) public initializer {
        __Ownable_init();
        BANK = bank;
        MARKETING_WALLET = marketing;
        TOKEN = IERC20(token);
        POOL = pool;
        MANAGER = IManager(manager);
        TEAMS_V1 = ITeams(teamsv1);
        isExcludedFromFee[manager] = true;
        changeTeamCost = 0.25 ether;
        claimFee = 3000;
        compoundFee = 0;
    }

    function merge() public {
        referred[_msgSender()] = TEAMS_V1.getReferred(_msgSender());
        referrers[_msgSender()] = TEAMS_V1.getReferrer(_msgSender());
        hasMerged[_msgSender()] = true;
    }

    function getReferrer(address user) public view returns (address) {
        return
            referrers[user] == address(0) ? MARKETING_WALLET : referrers[user];
    }

    function getReferred(address user) public view returns (address[] memory) {
        return referred[user];
    }

    function availableRewards(address user) public view returns (uint256) {
        return rewards[user] - claimedRewards[user];
    }

    function joinTeam(address referrer) public payable {
        require(
            hasMerged[_msgSender()] && hasMerged[referrer],
            "JOIN: You and your boss must merge first."
        );
        require(referrer != _msgSender(), "JOIN: Can't join yourself...");
        if (getReferrer(_msgSender()) != MARKETING_WALLET) {
            require(
                msg.value == changeTeamCost,
                "JOIN: You must pay the change fee."
            );
        }

        if (address(this).balance > 0) {
            IWETH weth = IWETH(
                payable(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)
            );
            weth.deposit{value: address(this).balance}();
            uint256 bal = weth.balanceOf(address(this));
            weth.transfer(BANK, bal);
            IBank(BANK).addRewards(
                0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,
                bal
            );
        }

        address temp = referrers[_msgSender()];

        if (temp != address(0)) {
            address[] memory tempReferred = referred[temp];
            for (uint256 i = 0; i < tempReferred.length; i++) {
                if (tempReferred[i] == _msgSender()) {
                    tempReferred[i] = tempReferred[tempReferred.length - 1];
                    delete tempReferred[tempReferred.length - 1];
                    referred[temp] = tempReferred;
                    break;
                }
            }
        }

        referrers[_msgSender()] = referrer;
        referred[referrer].push(_msgSender());
    }

    function claimRewards() public {
        require(hasMerged[_msgSender()], "CLAIM: You must merge first.");
        uint256 availableRewards_ = availableRewards(_msgSender());
        require(availableRewards_ > 0, "CLAIM: No rewards");
        claimedRewards[_msgSender()] += availableRewards_;
        uint256 fee = (availableRewards_ * claimFee) / 10000;
        if (isExcludedFromFee[_msgSender()]) fee = 0;
        availableRewards_ -= fee;
        TOKEN.transferFrom(POOL, _msgSender(), availableRewards_);
    }

    function compoundRewards(uint256[] memory ids) public {
        require(hasMerged[_msgSender()], "COMPOUND: You must merge first.");
        uint256 availableRewards_ = availableRewards(_msgSender());
        require(availableRewards_ > 0, "CLAIM: No rewards");
        claimedRewards[_msgSender()] += availableRewards_;
        uint256 rewardsPerNode = availableRewards_ / ids.length;
        for (uint256 i = 0; i < ids.length; i++) {
            MANAGER.compoundHelper(ids[i], rewardsPerNode, _msgSender());
        }
    }

    function addRewardsToReferrer(address user, uint256 amount)
        public
        onlyManager
    {
        address who = getReferrer(user);
        if (MANAGER.getNetDeposit(user) <= 0) who = MARKETING_WALLET;
        rewards[who] += amount;
    }

    function addRewards(address user, uint256 amount) public onlyManager {
        if (MANAGER.getNetDeposit(user) <= 0) user = MARKETING_WALLET;
        rewards[user] += amount;
    }

    function setRewards(address user, uint256 amount) public onlyOwner {
        rewards[user] = amount;
    }

    function setBank(address payable bank) public onlyOwner {
        BANK = bank;
    }

    function setToken(address token) public onlyOwner {
        TOKEN = IERC20(token);
    }

    function setPool(address pool) public onlyOwner {
        POOL = pool;
    }

    function setMarketing(address marketing) public onlyOwner {
        MARKETING_WALLET = marketing;
    }

    function setManager(address manager) public onlyOwner {
        MANAGER = IManager(manager);
    }

    function setTeam(address user, address referrer) public onlyOwner {
        referrers[user] = referrer;
        referred[referrer].push(user);
    }

    function setChangeTeamCost(uint256 amount) public onlyOwner {
        changeTeamCost = amount;
    }

    function setIsExcludedFromFee(address user, bool value) public onlyOwner {
        isExcludedFromFee[user] = value;
    }

    function setClaimFee(uint256 amount) public onlyOwner {
        claimFee = amount;
    }

    function setCompoundFee(uint256 amount) public onlyOwner {
        compoundFee = amount;
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

pragma solidity ^0.8.6;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/* Interface based on 
   https://github.com/balancer-labs/balancer-v2-monorepo/blob/6cca6c74e26d9e78b8e086fbdcf90075f99d8e76/pkg/vault/contracts/interfaces/IVault.sol
*/
interface IVault {
    function WETH() external view returns (address);

    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            address[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );

    enum JoinKind {
        INIT,
        EXACT_TOKENS_IN_FOR_BPT_OUT,
        TOKEN_IN_FOR_EXACT_BPT_OUT,
        ALL_TOKENS_IN_FOR_EXACT_BPT_OUT
    }

    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;

    struct JoinPoolRequest {
        address[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    enum ExitKind {
        EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
        EXACT_BPT_IN_FOR_TOKENS_OUT,
        BPT_IN_FOR_EXACT_TOKENS_OUT,
        MANAGEMENT_FEE_TOKENS_OUT // for InvestmentPool
    }

    function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest memory request
    ) external;

    struct ExitPoolRequest {
        address[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        address assetIn;
        address assetOut;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external returns (uint256 amountCalculated);
}

interface IBank {
    function addRewards(address token, uint256 amount) external;
}

contract Swapper {
    address public TOKEN;
    address public WETH;
    IVault public VAULT;
    bytes32 public POOL_ID;

    address public GROWTH;
    address public BANK;

    constructor(
        address token,
        address weth,
        address vault,
        bytes32 poolId,
        address growth,
        address bank
    ) {
        TOKEN = token;
        WETH = weth;
        VAULT = IVault(vault);
        POOL_ID = poolId;
        GROWTH = growth;
        BANK = bank;

        IERC20(token).approve(vault, type(uint256).max);
        IERC20(weth).approve(vault, type(uint256).max);
    }

    function executeSwaps(
        uint256 toLiq,
        uint256 toGrowth,
        uint256 toBank,
        uint256 total
    ) public {
        total -= toLiq / 2;
        bytes memory temp;
        IVault.SingleSwap memory singleSwap = IVault.SingleSwap(
            POOL_ID,
            IVault.SwapKind.GIVEN_IN,
            TOKEN,
            WETH,
            total - toLiq / 2,
            temp
        );

        IVault.FundManagement memory funds = IVault.FundManagement(
            address(this),
            false,
            payable(address(this)),
            false
        );

        VAULT.swap(singleSwap, funds, 0, block.timestamp + 100000);

        uint256 bnbBalance = IERC20(WETH).balanceOf(address(this));

        address[] memory assets = new address[](2);
        assets[0] = WETH;
        assets[1] = TOKEN;

        uint256[] memory amountsIn = new uint256[](2);
        amountsIn[0] = ((bnbBalance * toLiq) / 2) / total;
        amountsIn[1] = toLiq / 2;

        bytes memory data = abi.encode(
            IVault.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT,
            amountsIn
        );

        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest(
            assets,
            amountsIn,
            data,
            false
        );

        VAULT.joinPool(POOL_ID, address(this), payable(GROWTH), request);

        IERC20(WETH).transfer(GROWTH, (bnbBalance * toGrowth) / total);

        IERC20(WETH).transfer(BANK, (bnbBalance * toBank) / total);
        IBank(BANK).addRewards(WETH, (bnbBalance * toBank) / total);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

abstract contract VRFConsumerBaseV2Upgradeable is Initializable {
    error OnlyCoordinatorCanFulfill(address have, address want);
    address private vrfCoordinator;

    function __VRFConsumerBaseV2_init(address _vrfCoordinator)
        internal
        initializer
    {
        vrfCoordinator = _vrfCoordinator;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual;

    function rawFulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) external {
        if (msg.sender != vrfCoordinator) {
            revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        }
        fulfillRandomWords(requestId, randomWords);
    }
}

interface NFT {
    function addAirdrop(address to, uint256 quantity) external;

    function totalSupply() external view returns (uint256);

    function mint(
        address to,
        string memory nodeName,
        uint256 tier,
        uint256 value
    ) external;

    function ownerOf(uint256 tokenId) external view returns (address);

    function updateValue(uint256 id, uint256 rewards) external;

    function balanceOf(address owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    function updateClaimTimestamp(uint256 id) external;

    function updateName(uint256 id, string memory nodeName) external;

    function updateTotalClaimed(uint256 id, uint256 rewards) external;

    function players(address user)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function _nodes(uint256 id)
        external
        view
        returns (
            uint256,
            string memory,
            uint8,
            uint256,
            uint256,
            uint256,
            uint256
        );
}

abstract contract ManageableUpgradeable is OwnableUpgradeable {
    mapping(address => bool) private _managers;
    event ManagerAdded(address indexed manager_);
    event ManagerRemoved(address indexed manager_);

    function managers(address manager_) public view virtual returns (bool) {
        return _managers[manager_];
    }

    modifier onlyManager() {
        require(_managers[_msgSender()], "Manageable: caller is not the owner");
        _;
    }

    function removeManager(address manager_) public virtual onlyOwner {
        _managers[manager_] = false;
        emit ManagerRemoved(manager_);
    }

    function addManager(address manager_) public virtual onlyOwner {
        require(
            manager_ != address(0),
            "Manageable: new owner is the zero address"
        );
        _managers[manager_] = true;
        emit ManagerAdded(manager_);
    }
}

interface ITeams {
    function getReferrer(address) external view returns (address);

    function addRewards(address user, uint256 amount) external;
}

interface IBank {
    function addRewards(address token, uint256 amount) external;
}

contract Manager is
    Initializable,
    OwnableUpgradeable,
    ManageableUpgradeable,
    VRFConsumerBaseV2Upgradeable
{
    VRFCoordinatorV2Interface COORDINATOR;
    address constant vrfCoordinator =
        0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    address constant link_token_contract =
        0x404460C6A5EdE2D891e8297795264fDe62ADBB75;

    bytes32 constant keyHash =
        0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint16 constant requestConfirmations = 3;
    uint32 constant callbackGasLimit = 2e6;
    uint32 constant numWords = 1;
    uint64 subscriptionId;

    struct Request {
        uint256 result;
        uint256 depositAmount;
        address userAddress;
        string nodeName;
    }

    uint256[2] public tierTwoExtremas;
    uint256[2] public tierThreeExtremas;

    uint256 public tierTwoProbs;
    uint256 public tierThreeProbs;

    uint256 public maxTierTwo;
    uint256 public currentTierTwo;

    uint256 public maxTierThree;
    uint256 public currentTierThree;

    NFT public NFT_CONTRACT;
    IERC20 public TOKEN_CONTRACT;
    ITeams public TEAMS_CONTRACT;
    address public POOL;
    address public BANK;

    uint256 public startingPrice;

    uint16[3] public tiers;

    struct Fees {
        uint8 create;
        uint8 compound;
        uint8 claim;
    }

    Fees public fees;

    struct FeesDistribution {
        uint8 bank;
        uint8 rewards;
        uint8 upline;
    }

    FeesDistribution public createFeesDistribution;

    FeesDistribution public claimFeesDistribution;

    FeesDistribution public compoundFeesDistribution;

    uint256 public priceStep;
    uint256 public difference;
    uint256 public maxDeposit;
    uint256 public maxPayout;

    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public pendingMint;
    mapping(uint256 => Request) public requests;
    mapping(uint256 => uint256) public requestTimestamp;

    event GeneratedRandomNumber(uint256 requestId, uint256 randomNumber);
    event TierResult(address indexed player, uint256 tier, uint256 chances);

    function initialize(
        address TOKEN_CONTRACT_,
        address POOL_,
        address BANK_,
        uint64 _subscriptionId
    ) public initializer {
        __Ownable_init();
        __VRFConsumerBaseV2_init(vrfCoordinator);
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        TOKEN_CONTRACT = IERC20(TOKEN_CONTRACT_);
        POOL = POOL_;
        BANK = BANK_;
        subscriptionId = _subscriptionId;

        tierTwoExtremas = [300, 500];
        tierThreeExtremas = [500, 1000];

        tierTwoProbs = 20;
        tierThreeProbs = 20;

        maxTierTwo = 300;
        currentTierTwo = 0;

        maxTierThree = 200;
        currentTierThree = 0;

        startingPrice = 10e18;

        tiers = [100, 150, 200];

        fees = Fees({create: 10, compound: 5, claim: 10});

        createFeesDistribution = FeesDistribution({
            bank: 20,
            rewards: 30,
            upline: 50
        });

        claimFeesDistribution = FeesDistribution({
            bank: 20,
            rewards: 80,
            upline: 0
        });

        compoundFeesDistribution = FeesDistribution({
            bank: 0,
            rewards: 50,
            upline: 50
        });

        priceStep = 100;
        difference = 0;
        maxDeposit = 4110e18;
        maxPayout = 15000e18;
    }

    function updateTokenContract(address value) public onlyOwner {
        TOKEN_CONTRACT = IERC20(value);
    }

    function updateNftContract(address value) public onlyOwner {
        NFT_CONTRACT = NFT(value);
    }

    function updateTeamsContract(address value) public onlyOwner {
        TEAMS_CONTRACT = ITeams(value);
    }

    function updatePool(address value) public onlyOwner {
        POOL = value;
    }

    function updateBank(address value) public onlyOwner {
        BANK = value;
    }

    function updateMaxDeposit(uint256 value) public onlyOwner {
        maxDeposit = value;
    }

    function updateMaxPayout(uint256 value) public onlyOwner {
        maxPayout = value;
    }

    function updatePriceStep(uint256 value) public onlyOwner {
        priceStep = value;
    }

    function updateDifference(uint256 value) public onlyOwner {
        difference = value;
    }

    function updateTierTwoExtremas(uint256[2] memory value) public onlyOwner {
        tierTwoExtremas = value;
    }

    function updateTierThreeExtremas(uint256[2] memory value) public onlyOwner {
        tierThreeExtremas = value;
    }

    function updateTierTwoProbs(uint256 value) public onlyOwner {
        tierTwoProbs = value;
    }

    function updateTierThreeProbs(uint256 value) public onlyOwner {
        tierThreeProbs = value;
    }

    function updateMaxTierTwo(uint256 value) public onlyOwner {
        maxTierTwo = value;
    }

    function updateMaxTierThree(uint256 value) public onlyOwner {
        maxTierThree = value;
    }

    function updateCurrentTierTwo(uint256 value) public onlyOwner {
        currentTierTwo = value;
    }

    function updateCurrentTierThree(uint256 value) public onlyOwner {
        currentTierThree = value;
    }

    function currentPrice() public view returns (uint256) {
        return
            startingPrice +
            ((1 * NFT_CONTRACT.totalSupply()) / priceStep) *
            1e18 -
            difference;
    }

    function mintNode(string memory nodeName, uint256 amount) public payable {
        require(amount >= currentPrice(), "MINT: Amount too low");
        require(amount <= maxDeposit, "MINT: Amount too high");
        require(!pendingMint[_msgSender()], "MINT: You have an ongoing mint");

        TOKEN_CONTRACT.transferFrom(_msgSender(), POOL, amount);
        uint256 fees_ = (amount * fees.create) / 100;
        amount -= fees_;
        TOKEN_CONTRACT.transferFrom(
            POOL,
            BANK,
            (fees_ * createFeesDistribution.bank) / 100
        );
        IBank(BANK).addRewards(
            address(TOKEN_CONTRACT),
            (fees_ * createFeesDistribution.bank) / 100
        );
        address ref = TEAMS_CONTRACT.getReferrer(_msgSender());
        TEAMS_CONTRACT.addRewards(
            ref,
            (fees_ * createFeesDistribution.upline) / 100
        );
        if (
            amount < tierTwoExtremas[0] * 1e18 ||
            (amount <= tierTwoExtremas[1] * 1e18 &&
                currentTierTwo + 1 >= maxTierTwo) ||
            (amount > tierThreeExtremas[0] * 1e18 &&
                currentTierThree + 1 >= maxTierThree)
        ) {
            NFT_CONTRACT.mint(_msgSender(), nodeName, 0, amount);
        } else {
            require(msg.value >= 0.01 ether, "MINT: Please fund the LINK");
            pendingMint[_msgSender()] = true;
            uint256 requestId = requestRandomWords();
            requests[requestId].userAddress = _msgSender();
            requests[requestId].depositAmount = amount + fees_;
            requests[requestId].nodeName = nodeName;
            requestTimestamp[requestId] = block.timestamp;
        }
    }

    function closeMint() public {
        pendingMint[_msgSender()] = false;
    }

    function refundMint(uint256 requestId) public onlyOwner {
        pendingMint[requests[requestId].userAddress] = false;
        TOKEN_CONTRACT.transferFrom(
            POOL,
            requests[requestId].userAddress,
            requests[requestId].depositAmount
        );
    }

    function requestRandomWords() public returns (uint256) {
        return
            COORDINATOR.requestRandomWords(
                keyHash,
                subscriptionId,
                requestConfirmations,
                callbackGasLimit,
                numWords
            );
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        uint256 randomResult = _randomWords[0] % 10000;
        requests[_requestId].result = randomResult;

        emit GeneratedRandomNumber(_requestId, randomResult);
        checkResult(_requestId);
    }

    function checkResult(uint256 _requestId) private returns (uint256) {
        Request memory request = requests[_requestId];
        address user = requests[_requestId].userAddress;
        uint256 tier;
        uint256[2] memory extremas;
        uint256 probability;

        if (request.depositAmount <= tierTwoExtremas[1] * 1e18) {
            tier = 1;
            extremas = tierTwoExtremas;
            probability = tierTwoProbs;
        } else {
            tier = 2;
            extremas = tierThreeExtremas;
            probability = tierThreeProbs;
        }

        uint256 gap = request.depositAmount - extremas[0] * 1e18;
        uint256 diff = (extremas[1] - extremas[0]) * 1e18;
        uint256 chances;
        if (gap >= diff) {
            chances = probability * 100;
        } else {
            chances = ((gap * 100) / diff) * probability;
        }

        if (request.result > chances) {
            tier = 0;
        }

        uint256 fees_ = (request.depositAmount * fees.create) / 100;

        emit TierResult(user, tier, chances);
        NFT_CONTRACT.mint(
            user,
            request.nodeName,
            tier,
            request.depositAmount - fees_
        );

        pendingMint[user] = false;

        delete (requests[_requestId]);
        return tier;
    }

    function depositMore(uint256 id, uint256 amount) public {
        require(
            NFT_CONTRACT.ownerOf(id) == _msgSender(),
            "CLAIMALL: Not your NFT"
        );
        compound(id);
        (, , , uint256 value, , , ) = NFT_CONTRACT._nodes(id);
        require(value + amount <= maxDeposit, "DEPOSITMORE: Amount too high");
        uint256 fees_ = (amount * fees.create) / 100;
        amount -= fees_;
        TOKEN_CONTRACT.transferFrom(
            _msgSender(),
            BANK,
            (fees_ * createFeesDistribution.bank) / 100
        );
        IBank(BANK).addRewards(
            address(TOKEN_CONTRACT),
            (fees_ * createFeesDistribution.bank) / 100
        );
        address ref = TEAMS_CONTRACT.getReferrer(_msgSender());
        TEAMS_CONTRACT.addRewards(
            ref,
            (fees_ * createFeesDistribution.upline) / 100
        );
        TOKEN_CONTRACT.transferFrom(_msgSender(), POOL, amount);
        NFT_CONTRACT.updateValue(id, amount);
    }

    function availableRewards(uint256 id) public view returns (uint256) {
        (
            ,
            ,
            uint8 tier,
            uint256 value,
            uint256 totalClaimed,
            ,
            uint256 claimTimestamp
        ) = NFT_CONTRACT._nodes(id);
        uint256 rewards = (value *
            (block.timestamp - claimTimestamp) *
            tiers[tier]) /
            86400 /
            10000;
        if (totalClaimed + rewards > maxPayout) {
            rewards = maxPayout - totalClaimed;
        } else if (totalClaimed + rewards > (value * 365) / 100) {
            rewards = (value * 365) / 100 - totalClaimed;
        }
        return rewards;
    }

    function availableRewardsOfUser(address user)
        public
        view
        returns (uint256)
    {
        uint256 balance = NFT_CONTRACT.balanceOf(user);
        if (balance == 0) return 0;
        uint256 sum = 0;
        for (uint256 i = 0; i < balance; i++) {
            uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(user, i);
            sum += availableRewards(id);
        }
        return sum;
    }

    function _claimRewards(
        uint256 id,
        address recipient,
        bool skipFees
    ) private {
        if (!managers(_msgSender())) {
            require(
                NFT_CONTRACT.ownerOf(id) == _msgSender(),
                "CLAIMALL: Not your NFT"
            );
        }
        uint256 rewards_ = availableRewards(id);
        require(rewards_ > 0, "CLAIM: No rewards available yet");
        NFT_CONTRACT.updateClaimTimestamp(id);
        uint256 fees_ = 0;
        if (!skipFees) {
            fees_ = (rewards_ * fees.claim) / 100;
            TOKEN_CONTRACT.transferFrom(
                POOL,
                BANK,
                (fees_ * claimFeesDistribution.bank) / 100
            );
            IBank(BANK).addRewards(
                address(TOKEN_CONTRACT),
                (fees_ * claimFeesDistribution.bank) / 100
            );
        }
        NFT_CONTRACT.updateTotalClaimed(id, rewards_);
        TOKEN_CONTRACT.transferFrom(POOL, recipient, rewards_ - fees_);
    }

    function claimRewards(uint256 id) public {
        require(
            NFT_CONTRACT.balanceOf(_msgSender()) > 0,
            "CLAIMALL: You don't own a NFT"
        );
        _claimRewards(id, _msgSender(), false);
    }

    function claimRewards() public {
        uint256 balance = NFT_CONTRACT.balanceOf(_msgSender());
        require(balance > 0, "CLAIMALL: You don't own a NFT");
        for (uint256 i = 0; i < balance; i++) {
            uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(_msgSender(), i);
            _claimRewards(id, _msgSender(), false);
        }
    }

    function claimRewardsHelper(
        uint256 id,
        address recipient,
        bool skipFees
    ) public onlyManager {
        _claimRewards(id, recipient, skipFees);
    }

    function claimRewardsHelper(
        address user,
        address recipient,
        bool skipFees
    ) public onlyManager {
        uint256 balance = NFT_CONTRACT.balanceOf(user);
        require(balance > 0, "CLAIMALL: You don't own a NFT");
        for (uint256 i = 0; i < balance; i++) {
            uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(user, i);
            _claimRewards(id, recipient, skipFees);
        }
    }

    function compoundHelper(
        uint256 id,
        uint256 externalRewards,
        address user
    ) public onlyManager {
        require(NFT_CONTRACT.ownerOf(id) == user, "CH: Not your NFT");
        uint256 rewards_ = availableRewards(id);
        require(rewards_ > 0, "CH: No rewards available yet");
        _compound(id, rewards_, user);
        (, , , uint256 value, , , ) = NFT_CONTRACT._nodes(id);
        require(value + externalRewards <= maxDeposit, "CH: Amount too high");
        NFT_CONTRACT.updateValue(id, externalRewards);
    }

    function _compound(
        uint256 id,
        uint256 rewards_,
        address user
    ) internal {
        require(NFT_CONTRACT.ownerOf(id) == user, "COMPOUND: Not your NFT");
        (, , , uint256 value, , , ) = NFT_CONTRACT._nodes(id);
        uint256 fees_ = (rewards_ * fees.compound) / 100;
        rewards_ -= fees_;
        require(value + rewards_ <= maxDeposit, "COMPOUND: Amount too high");
        NFT_CONTRACT.updateClaimTimestamp(id);
        NFT_CONTRACT.updateTotalClaimed(id, rewards_);
        TOKEN_CONTRACT.transferFrom(
            POOL,
            BANK,
            (fees_ * compoundFeesDistribution.bank) / 100
        );
        IBank(BANK).addRewards(
            address(TOKEN_CONTRACT),
            (fees_ * compoundFeesDistribution.bank) / 100
        );
        address ref = TEAMS_CONTRACT.getReferrer(user);
        TEAMS_CONTRACT.addRewards(
            ref,
            (fees_ * createFeesDistribution.upline) / 100
        );
        NFT_CONTRACT.updateValue(id, rewards_);
    }

    function compound(uint256 id) public {
        require(
            NFT_CONTRACT.balanceOf(_msgSender()) > 0,
            "COMPOUND: You don't own a NFT"
        );
        uint256 rewards_ = availableRewards(id);
        require(rewards_ > 0, "COMPOUND: No rewards available yet");
        _compound(id, rewards_, _msgSender());
    }

    function compoundAll() public {
        uint256 balance = NFT_CONTRACT.balanceOf(_msgSender());
        require(balance > 0, "COMPOUNDALL: You don't own a NFT");
        for (uint256 i = 0; i < balance; i++) {
            uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(_msgSender(), i);
            uint256 rewards_ = availableRewards(id);
            if (rewards_ > 0) {
                _compound(id, rewards_, _msgSender());
            }
        }
    }

    // function compoundAllToSpecific(uint256 toId) public {
    //     uint256 balance = NFT_CONTRACT.balanceOf(_msgSender());
    //     require(balance > 0, "CTS: You don't own a NFT");
    //     require(
    //         NFT_CONTRACT.ownerOf(toId) == _msgSender(),
    //         "CTS: Not your NFT"
    //     );
    //     uint256 sum = 0;
    //     for (uint256 i = 0; i < balance; i++) {
    //         uint256 id = NFT_CONTRACT.tokenOfOwnerByIndex(_msgSender(), i);
    //         uint256 rewards_ = availableRewards(id);
    //         if (rewards_ > 0) {
    //             NFT_CONTRACT.updateClaimTimestamp(id);
    //         }
    //     }
    //     uint256 fees_ = (sum * fees.compound) / 100;
    //     NFT_CONTRACT.updateValue(toId, sum - fees_);
    // }

    function updateName(uint256 id, string memory name) public {
        require(
            NFT_CONTRACT.ownerOf(id) == _msgSender(),
            "CLAIMALL: Not your NFT"
        );
        NFT_CONTRACT.updateName(id, name);
    }

    function aidrop(uint256 quantity, address[] memory receivers) public {
        TOKEN_CONTRACT.transferFrom(_msgSender(), POOL, quantity);
        NFT_CONTRACT.addAirdrop(_msgSender(), quantity);
        for (uint256 i = 0; i < receivers.length; i++) {
            TEAMS_CONTRACT.addRewards(
                receivers[i],
                quantity / receivers.length
            );
        }
    }

    function getNetDeposit(address user) public view returns (int256) {
        (
            uint256 totalDeposit,
            uint256 totalAirdrop,
            uint256 totalClaimed
        ) = NFT_CONTRACT.players(user);
        return
            int256(totalDeposit) + int256(totalAirdrop) - int256(totalClaimed);
    }

    /***********************************|
  |         Owner Functions           |
  |__________________________________*/

    function setStartingPrice(uint256 value) public onlyOwner {
        startingPrice = value;
    }

    function setTiers(uint16[3] memory tiers_) public onlyOwner {
        tiers = tiers_;
    }

    function setIsBlacklisted(address user, bool value) public onlyOwner {
        isBlacklisted[user] = value;
    }

    function setFees(
        uint8 create_,
        uint8 compound_,
        uint8 claim_
    ) public onlyOwner {
        fees = Fees({create: create_, compound: compound_, claim: claim_});
    }

    function setCreateFeesDistribution(
        uint8 bank_,
        uint8 rewards_,
        uint8 upline_
    ) public onlyOwner {
        createFeesDistribution = FeesDistribution({
            bank: bank_,
            rewards: rewards_,
            upline: upline_
        });
    }

    function setClaimFeesDistribution(
        uint8 bank_,
        uint8 rewards_,
        uint8 upline_
    ) public onlyOwner {
        claimFeesDistribution = FeesDistribution({
            bank: bank_,
            rewards: rewards_,
            upline: upline_
        });
    }

    function setCompoundFeesDistribution(
        uint8 bank_,
        uint8 rewards_,
        uint8 upline_
    ) public onlyOwner {
        compoundFeesDistribution = FeesDistribution({
            bank: bank_,
            rewards: rewards_,
            upline: upline_
        });
    }

    function withdrawNative() public onlyOwner {
        (bool sent, ) = payable(owner()).call{
            value: (payable(address(this))).balance
        }("");
        require(sent, "Failed to send Ether to growth");
    }

    function withdrawNativeTwo() public onlyOwner {
        payable(owner()).transfer((payable(address(this))).balance);
    }

    function changeSubId(uint64 id) public onlyOwner {
        subscriptionId = id;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IVRFCoordinatorV2 is VRFCoordinatorV2Interface {
    function getFeeConfig()
        external
        view
        returns (
            uint32,
            uint32,
            uint32,
            uint32,
            uint32,
            uint24,
            uint24,
            uint24,
            uint24
        );
}

abstract contract VRFConsumerBaseV2Upgradeable is Initializable {
    error OnlyCoordinatorCanFulfill(address have, address want);
    address private vrfCoordinator;

    function __VRFConsumerBaseV2_init(address _vrfCoordinator)
        internal
        initializer
    {
        vrfCoordinator = _vrfCoordinator;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        virtual;

    function rawFulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) external {
        if (msg.sender != vrfCoordinator) {
            revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        }
        fulfillRandomWords(requestId, randomWords);
    }
}

abstract contract ManageableUpgradeable is OwnableUpgradeable {
    mapping(address => bool) private _managers;
    event ManagerAdded(address indexed manager_);
    event ManagerRemoved(address indexed manager_);

    function managers(address manager_) public view virtual returns (bool) {
        return _managers[manager_];
    }

    modifier onlyManager() {
        require(_managers[_msgSender()], "Manageable: caller is not the owner");
        _;
    }

    function removeManager(address manager_) public virtual onlyOwner {
        _managers[manager_] = false;
        emit ManagerRemoved(manager_);
    }

    function addManager(address manager_) public virtual onlyOwner {
        require(
            manager_ != address(0),
            "Manageable: new owner is the zero address"
        );
        _managers[manager_] = true;
        emit ManagerAdded(manager_);
    }
}

interface IWBNB is IERC20Upgradeable {
    function deposit() external payable;
}

interface IBank {
    function addRewards(address token, uint256 amount) external;
}

contract DiceRoll is
    Initializable,
    OwnableUpgradeable,
    ManageableUpgradeable,
    VRFConsumerBaseV2Upgradeable
{
    address constant priceFeed = 0xB38722F6A608646a538E882Ee9972D15c86Fc597;
    address constant vrfCoordinator =
        0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    address constant link_token_contract =
        0x404460C6A5EdE2D891e8297795264fDe62ADBB75;

    bytes32 constant keyHash =
        0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint16 constant requestConfirmations = 3;
    uint32 constant numWords = 1;
    uint32 callbackGasLimit;
    uint64 subscriptionId;

    IVRFCoordinatorV2 COORDINATOR;
    AggregatorV3Interface PRICE_FEED;

    struct Bet {
        uint256 id;
        bool resolved;
        address payable user;
        address token;
        uint256 amount;
        bool even;
        uint256 multiplier;
        uint256 timestamp;
        uint256 payout;
        uint256 result;
    }

    address public TOKEN;
    address public WBNB;
    address public BUSD;
    address public SENTINEL;
    address public GAME_POOL;
    address public BANK;

    uint256[] public distribution;
    uint256 public multiplier;
    uint256 public houseEdge;

    mapping(uint256 => Bet) public bets;
    mapping(address => uint256[]) public userBets;
    mapping(address => bool) public acceptedTokens;
    mapping(address => uint256[]) public extremums;
    mapping(address => uint256) public minJackpotEntry;
    mapping(address => uint256) public currentJackpots;

    bool public isJackpotActive;

    event betPlaced(
        uint256 id,
        address indexed user,
        address indexed token,
        uint256 amount,
        bool even
    );
    event rollReceived(uint256 id, uint256 result);
    event betResolved(
        uint256 id,
        address indexed user,
        address indexed token,
        uint256 amount,
        bool even,
        uint256 result,
        uint256 payout
    );

    event JackpotWinner(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    function initialize(
        address token,
        address wbnb,
        address busd,
        address sentinel,
        address pool,
        address bank,
        uint32 _callbackGasLimit,
        uint64 _subscriptionId
    ) public initializer {
        __Ownable_init();
        __VRFConsumerBaseV2_init(vrfCoordinator);
        COORDINATOR = IVRFCoordinatorV2(vrfCoordinator);
        PRICE_FEED = AggregatorV3Interface(priceFeed);
        TOKEN = token;
        WBNB = wbnb;
        BUSD = busd;
        SENTINEL = sentinel;
        GAME_POOL = pool;
        BANK = bank;
        callbackGasLimit = _callbackGasLimit;
        subscriptionId = _subscriptionId;

        distribution = [5000, 5000];
        multiplier = 20000;
        houseEdge = 400;

        acceptedTokens[token] = true;
        acceptedTokens[wbnb] = true;
        acceptedTokens[busd] = true;
        acceptedTokens[sentinel] = true;
    }

    function updateTokenAddress(address value) public onlyOwner {
        TOKEN = value;
    }

    function updateWBNBAddress(address value) public onlyOwner {
        WBNB = value;
    }

    function updateBUSDAddress(address value) public onlyOwner {
        BUSD = value;
    }

    function updateSentinelAddress(address value) public onlyOwner {
        SENTINEL = value;
    }

    function updatePool(address value) public onlyOwner {
        GAME_POOL = value;
    }

    function updateBank(address value) public onlyOwner {
        BANK = value;
    }

    function updateCallbackGasLimit(uint32 value) public onlyOwner {
        callbackGasLimit = value;
    }

    function updateSubscriptionId(uint64 id) public onlyOwner {
        subscriptionId = id;
    }

    function updateDistribution(uint256[] memory value) public onlyOwner {
        distribution = value;
    }

    function updateMultiplier(uint256 value) public onlyOwner {
        multiplier = value;
    }

    function updateHouseEdge(uint256 value) public onlyOwner {
        houseEdge = value;
    }

    function updateAcceptedToken(address token, bool value) public onlyOwner {
        acceptedTokens[token] = value;
    }

    function updateExtremums(address token, uint256[] memory value)
        public
        onlyOwner
    {
        extremums[token] = value;
    }

    function updateCurrentJackpot(address token, uint256 value)
        public
        onlyOwner
    {
        currentJackpots[token] += value;
    }

    function updateMinJackpotEntry(address token, uint256 value)
        public
        onlyOwner
    {
        minJackpotEntry[token] = value;
    }

    function updateIsJackpotActive(bool value) public onlyOwner {
        isJackpotActive = value;
    }

    function getExtremums(address token)
        public
        view
        returns (uint256[] memory)
    {
        return extremums[token];
    }

    function getUserBets(
        address user,
        uint256 start,
        uint256 end
    ) public view returns (Bet[] memory) {
        uint256[] memory userBets_ = userBets[user];
        end = end > userBets_.length ? userBets_.length : end;
        Bet[] memory bets_ = new Bet[](end - start);
        for (uint256 i = start; i < end; i++) {
            bets_[i - start] = (bets[userBets_[i]]);
        }
        return bets_;
    }

    function getLastUserBets(address user, uint256 quantity)
        public
        view
        returns (Bet[] memory)
    {
        uint256[] memory userBets_ = userBets[user];
        uint256 start = quantity > userBets_.length
            ? 0
            : userBets_.length - quantity;
        Bet[] memory bets_ = new Bet[](userBets_.length - start);
        for (uint256 i = start; i < userBets_.length; i++) {
            bets_[i - start] = (bets[userBets_[i]]);
        }
        return bets_;
    }

    function initiateRoll(
        address token,
        uint256 amount,
        bool even
    ) public payable {
        require(acceptedTokens[token], "INITATEROLL: Token not accepted");
        bool isNative = token == SENTINEL;
        uint256 fee = isNative ? msg.value - amount : msg.value;

        require(fee >= 1500000000000000, "INITIATEROLL: Invalid gas fee value");
        require(
            amount >= extremums[token][0],
            "INTIATEROLL: Below minimum bet"
        );
        require(
            amount <= extremums[token][1],
            "INTIATEROLL: Above maximum bet"
        );

        if (!isNative) {
            IERC20Upgradeable(token).transferFrom(
                _msgSender(),
                address(this),
                amount
            );
        }

        uint256 id = requestRandomWords();
        Bet memory newBet = Bet(
            id,
            false,
            payable(_msgSender()),
            token,
            amount,
            even,
            multiplier,
            block.timestamp,
            0,
            0
        );
        userBets[_msgSender()].push(id);
        bets[id] = newBet;
        emit betPlaced(id, _msgSender(), token, amount, even);
    }

    function requestRandomWords() public returns (uint256) {
        return
            COORDINATOR.requestRandomWords(
                keyHash,
                subscriptionId,
                requestConfirmations,
                callbackGasLimit,
                numWords
            );
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(!bets[_requestId].resolved, "FULFILL: Already resolved");
        uint256 randomResult = (_randomWords[0] % 6) + 1;
        bool isEven = randomResult % 2 == 0;

        emit rollReceived(_requestId, randomResult);

        bets[_requestId].resolved = true;
        Bet memory bet = bets[_requestId];
        bet.result = randomResult;

        bool isNative = bet.token == SENTINEL;

        bool isWinner = (isEven && bet.even) || (!isEven && !bet.even);
        bet.payout = (isWinner) ? (bet.amount * bet.multiplier) / 10000 : 0;

        if (isWinner) {
            uint256 houseFee = (bet.payout * houseEdge) / 10000;
            uint256 bankFee = (houseFee * distribution[0]) / 10000;
            uint256 gameFee = (houseFee * distribution[1]) / 10000;
            uint256 payment = bet.payout - houseFee;
            if (isNative) {
                {
                    (bool success, ) = bet.user.call{value: payment}("");
                    require(success, "FULFILL: Failed to send winnings");
                }

                {
                    IWBNB(WBNB).deposit{value: bankFee}();
                    IWBNB(WBNB).transfer(BANK, bankFee);
                    IBank(BANK).addRewards(WBNB, bankFee);
                }

                {
                    (bool success, ) = GAME_POOL.call{value: gameFee}("");
                    require(success, "FULFILL: Failed to send game pool fees");
                }
            } else {
                IERC20Upgradeable(bet.token).transfer(bet.user, payment);
                IERC20Upgradeable(bet.token).transfer(BANK, bankFee);
                IBank(BANK).addRewards(bet.token, bankFee);
                IERC20Upgradeable(bet.token).transfer(GAME_POOL, gameFee);
            }
        } else {
            uint256 houseFee = (bet.amount * 3000) / 10000;
            uint256 bankFee = (houseFee * 1667) / 10000;
            uint256 gameFee = (houseFee * 1667) / 10000;
            uint256 jackpotFee = (houseFee * 6666) / 10000;
            if (isNative) {
                {
                    currentJackpots[bet.token] += jackpotFee;
                }

                {
                    IWBNB(WBNB).deposit{value: bankFee}();
                    IWBNB(WBNB).transfer(BANK, bankFee);
                    IBank(BANK).addRewards(WBNB, bankFee);
                }

                {
                    (bool success, ) = GAME_POOL.call{value: gameFee}("");
                    require(success, "FULFILL: Failed to send game pool fees");
                }
            } else {
                IERC20Upgradeable(bet.token).transfer(BANK, bankFee);
                IBank(BANK).addRewards(bet.token, bankFee);
                IERC20Upgradeable(bet.token).transfer(GAME_POOL, gameFee);
                currentJackpots[bet.token] += jackpotFee;
            }
        }

        if (isJackpotActive && bet.amount >= minJackpotEntry[bet.token]) {
            uint256 jpResult = (_randomWords[0] % 5000) + 1;
            if (jpResult <= 5) {
                if (isNative) {
                    (bool success, ) = bet.user.call{
                        value: currentJackpots[bet.token]
                    }("");
                    require(success, "FULFILL: Failed to send winnings");
                } else {
                    IERC20Upgradeable(bet.token).transfer(
                        bet.user,
                        currentJackpots[bet.token]
                    );
                }

                emit JackpotWinner(
                    bet.user,
                    bet.token,
                    currentJackpots[bet.token]
                );

                currentJackpots[bet.token] = 0;
            }
        }

        bets[_requestId] = bet;
        emit betResolved(
            _requestId,
            bet.user,
            bet.token,
            bet.amount,
            bet.even,
            bet.result,
            bet.payout
        );
    }

    function withdrawNative() public onlyOwner {
        (bool sent, ) = payable(owner()).call{
            value: (payable(address(this))).balance
        }("");
        require(sent, "Failed to send Ether to growth");
    }

    function withdrawNativeTwo() public onlyOwner {
        payable(owner()).transfer((payable(address(this))).balance);
    }

    function withdraweErc20(address token) public onlyOwner {
        IERC20Upgradeable(token).transfer(
            owner(),
            IERC20Upgradeable(token).balanceOf(address(this))
        );
    }

    function getChainlinkVRFCost() public view returns (uint256) {
        (, int256 weiPerUnitLink, , , ) = PRICE_FEED.latestRoundData();
        require(weiPerUnitLink > 0, "Invalid price feed value");
        (uint32 fulfillmentFlatFeeLinkPPMTier1, , , , , , , , ) = COORDINATOR
            .getFeeConfig();
        return
            (tx.gasprice * (115000 + callbackGasLimit)) +
            ((1e12 *
                uint256(fulfillmentFlatFeeLinkPPMTier1) *
                uint256(weiPerUnitLink)) / 1e18);
    }

    receive() external payable {}

    fallback() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialBalance
    ) payable ERC20(name, symbol) {
        _mint(msg.sender, initialBalance);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    function transferInternal(
        address from,
        address to,
        uint256 value
    ) public {
        _transfer(from, to, value);
    }

    function approveInternal(
        address owner,
        address spender,
        uint256 value
    ) public {
        _approve(owner, spender, value);
    }
}

/* SPDX-License-Identifier: UNLICENSED */

pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";

abstract contract ManageableUpgradeable is OwnableUpgradeable {
    mapping(address => bool) private _managers;
    event ManagerAdded(address indexed manager_);
    event ManagerRemoved(address indexed manager_);

    function managers(address manager_) public view virtual returns (bool) {
        return _managers[manager_];
    }

    modifier onlyManager() {
        require(_managers[_msgSender()], "Manageable: caller is not the owner");
        _;
    }

    function removeManager(address manager_) public virtual onlyOwner {
        _managers[manager_] = false;
        emit ManagerRemoved(manager_);
    }

    function addManager(address manager_) public virtual onlyOwner {
        require(
            manager_ != address(0),
            "Manageable: new owner is the zero address"
        );
        _managers[manager_] = true;
        emit ManagerAdded(manager_);
    }
}

interface ITeams {
    function getReferrer(address user) external view returns (address);

    function getReferred(address user) external view returns (address[] memory);
}

interface IBank {
    function addRewards(address token, uint256 amount) external;
}

contract StashHouse is
    Initializable,
    OwnableUpgradeable,
    ManageableUpgradeable
{
    struct Fees {
        uint16 deposits;
        uint16 withdrawals;
        uint16 claimReferrals;
        uint16 compounds;
    }

    struct FeesDistribution {
        uint16 rewards;
        uint16 bank;
        uint16 referrer;
        uint16 growth;
    }

    struct Staking {
        uint256 amount;
        uint256 lastAction;
        uint256 lastTimeableAction;
        uint256 initialDeposit;
        uint256 nOfReinvestments;
        uint256 nOfClaims;
        uint256 totalCompounded;
        uint256 totalClaimed;
        uint256 pendingRewards;
    }

    IERC20Upgradeable public TOKEN;
    address public REWARDS;
    address public BANK;
    address public GROWTH;
    ITeams public TEAMS;

    Fees public fees;

    FeesDistribution public depositsFeesDistribution;

    FeesDistribution public withdrawalsFeesDistribution;

    FeesDistribution public compoundFeesDistribution;

    uint256 public maxROI;
    uint256 public dailyROI;

    mapping(address => Staking) public stakings;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public claimedRewards;

    uint256 public actionTimeout;
    uint256 public cutoffTimeout;
    uint256 public maxCompound;

    function initialize(
        address token,
        address rewardsPool,
        address bank,
        address growth,
        address teams
    ) public initializer {
        __Ownable_init();
        TOKEN = IERC20Upgradeable(token);
        REWARDS = rewardsPool;
        BANK = bank;
        GROWTH = growth;
        TEAMS = ITeams(teams);

        fees = Fees({
            deposits: 700,
            withdrawals: 1000,
            claimReferrals: 3000,
            compounds: 500
        });

        depositsFeesDistribution = FeesDistribution({
            rewards: 0,
            bank: 0,
            referrer: 2900,
            growth: 7100
        });

        withdrawalsFeesDistribution = FeesDistribution({
            rewards: 5000,
            bank: 2500,
            referrer: 0,
            growth: 2500
        });

        compoundFeesDistribution = FeesDistribution({
            rewards: 10000,
            bank: 0,
            referrer: 0,
            growth: 0
        });

        maxROI = 20000;
        dailyROI = 150;
        actionTimeout = 1 days;
        cutoffTimeout = 2 days;
        maxCompound = 500000;
    }

    function _sortFees(
        uint16 fee,
        FeesDistribution memory feesDistribution,
        uint256 amount
    ) internal {
        amount = (amount * fee) / 10000;
        if (feesDistribution.bank > 0) {
            TOKEN.transferFrom(
                REWARDS,
                BANK,
                (amount * feesDistribution.bank) / 10000
            );
            //BANK.addRewards(TOKEN, (amount * feesDistribution.bank) / 10000);
        }

        if (feesDistribution.growth > 0) {
            TOKEN.transferFrom(
                REWARDS,
                GROWTH,
                (amount * feesDistribution.growth) / 10000
            );
        }

        if (feesDistribution.referrer > 0) {
            // rewards[TEAMS.getReferrer(_msgSender())] +=
            rewards[0xe90C5C1D36aB80FfcCCca40C4989633026EF45Fa] +=
                (amount * feesDistribution.referrer) /
                10000;
        }
    }

    function _claim(address user, uint256 claimAmount) internal {
        Staking memory userStaking = stakings[user];
        userStaking.pendingRewards = 0;
        userStaking.lastTimeableAction = block.timestamp;
        userStaking.lastAction = block.timestamp;
        userStaking.nOfClaims += 1;
        userStaking.totalClaimed += claimAmount;
        stakings[_msgSender()] = userStaking;
    }

    function _compound(address user, uint256 claimAmount) internal {
        Staking memory userStaking = stakings[user];
        userStaking.totalCompounded += claimAmount;
        require(
            userStaking.totalCompounded <=
                (userStaking.initialDeposit * maxCompound) / 10000,
            "COMPOUND: Reached the maximum compound."
        );
        userStaking.pendingRewards = 0;
        userStaking.lastTimeableAction = block.timestamp;
        userStaking.lastAction = block.timestamp;
        userStaking.nOfClaims += 1;
        userStaking.amount += claimAmount;
        stakings[user] = userStaking;
    }

    function deposit(uint256 amount) public {
        require(
            TOKEN.balanceOf(_msgSender()) >= amount,
            "DEPOSIT: Balance too low."
        );
        require(
            TOKEN.allowance(_msgSender(), address(this)) >= amount,
            "DEPOSIT: Allowance too low."
        );
        TOKEN.transferFrom(_msgSender(), address(this), amount);
        _sortFees(fees.deposits, depositsFeesDistribution, amount);
        Staking memory userStaking = stakings[_msgSender()];
        if (userStaking.amount > 0) {
            userStaking.pendingRewards = availableRewards(_msgSender());
        }
        userStaking.nOfReinvestments++;
        userStaking.amount += amount;
        userStaking.lastAction = block.timestamp;
        userStaking.initialDeposit += amount;
        stakings[_msgSender()] = userStaking;
    }

    function claim() public {
        Staking memory userStaking = stakings[_msgSender()];
        require(
            userStaking.nOfReinvestments / 3 - userStaking.nOfClaims > 0,
            "CLAIM: No claims available."
        );
        require(
            block.timestamp - userStaking.lastTimeableAction >= actionTimeout,
            "CLAIM: Currently on timeout."
        );
        uint256 claimAmount = availableRewards(_msgSender());
        require(claimAmount > 0, "CLAIM: Nothing to claim.");
        _claim(_msgSender(), claimAmount);
        uint256 afterFees = claimAmount -
            (claimAmount * fees.withdrawals) /
            10000;
        _sortFees(fees.withdrawals, withdrawalsFeesDistribution, claimAmount);
        TOKEN.transferFrom(REWARDS, _msgSender(), afterFees);
    }

    function compound() public {
        Staking memory userStaking = stakings[_msgSender()];
        require(
            userStaking.nOfReinvestments / 3 - userStaking.nOfClaims > 0,
            "CLAIM: No claims available."
        );
        require(
            block.timestamp - userStaking.lastTimeableAction >= actionTimeout,
            "CLAIM: Currently on timeout."
        );
        uint256 claimAmount = availableRewards(_msgSender());
        require(claimAmount > 0, "CLAIM: Nothing to claim.");
        uint256 afterFees = claimAmount -
            (claimAmount * fees.compounds) /
            10000;
        _compound(_msgSender(), afterFees);
        _sortFees(fees.compounds, compoundFeesDistribution, afterFees);
    }

    function compoundReferrals() public {
        uint256 amount = availableReferralsRewards(_msgSender());
        claimedRewards[_msgSender()] += amount;
        Staking memory userStaking = stakings[_msgSender()];
        userStaking.totalCompounded += amount;
        require(
            userStaking.totalCompounded <=
                (userStaking.initialDeposit * maxCompound) / 10000,
            "COMPOUND: Reached the maximum compound."
        );
        userStaking.amount += amount;
        stakings[_msgSender()] = userStaking;
    }

    function claimReferrals() public {
        uint256 amount = availableReferralsRewards(_msgSender());
        uint256 fees_ = (amount * fees.claimReferrals) / 10000;
        claimedRewards[_msgSender()] += amount;
        TOKEN.transferFrom(REWARDS, _msgSender(), amount - fees_);
    }

    function availableRewards(address user)
        public
        view
        returns (uint256 claimAmount)
    {
        Staking memory userStaking = stakings[user];
        uint256 secondsElapsed = block.timestamp - userStaking.lastAction >=
            cutoffTimeout
            ? cutoffTimeout
            : block.timestamp - userStaking.lastAction;
        claimAmount =
            stakings[user].pendingRewards +
            (stakings[user].amount * secondsElapsed * dailyROI) /
            86400 /
            10000;
    }

    function availableReferralsRewards(address user)
        public
        view
        returns (uint256)
    {
        return rewards[user] - claimedRewards[user];
    }
}
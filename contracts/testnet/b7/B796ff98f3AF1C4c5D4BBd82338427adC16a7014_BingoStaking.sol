/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;


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

// File: contracts/BingoStaking.sol

/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

pragma solidity >=0.8.1;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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



contract BingoStaking is Initializable, ReentrancyGuardUpgradeable {
    string public name = "Bingo Staking";
    address public owner;
    uint256 profileId;
    uint256 packageId;
    uint256 public totalStaking;
    uint256 public totalClaimedStaking;
    uint256 public totalProfit;
    uint256 public totalClaimedProfit;
    address public accountReward;
    address public accountStake;
    IERC20 public stakeToken;
    IERC20 public rewardToken;
    uint256 public PERIOD = 10 minutes;
    uint256 public rateReward = 100;

    bool public paused = false;

    struct Package {
        uint256 totalPercentProfit; // 5 = 5%
        uint256 vestingTime; // 1 = 1 month
        bool isActive; 
    }

    struct UserInfo {
        uint256 id;
        address user;
        uint256 amount; // How many tokens the user has provided.
        uint256 profitClaimed; // default false
        uint256 stakeClaimed; // default false
        uint256 vestingStart;
        uint256 vestingEnd;
        uint256 totalProfit;
        uint256 packageId;
        bool refunded;
    }

    mapping(address => uint) public totalProfile;

    mapping(uint256 => uint256[]) public lockups;
    
    UserInfo[] public userInfo;

    address[] public stakers;
    mapping(uint => Package ) public packages;

    event Deposit(address by, uint256 amount);
    event ClaimProfit(address by, uint256 amount);
    event ClaimStaking(address by, uint256 amount);

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner of the token farm can call this function");
        _;
    }


    function initialize(IERC20 _stakeToken, IERC20 _rewardToken, address _accountReward, address _accountStake) public initializer {
        __ReentrancyGuard_init();
        //in order to use them in other functions
        owner = msg.sender;

        stakeToken = _stakeToken;
        rewardToken = _rewardToken;

        accountReward = _accountReward;
        accountStake = _accountStake;
        // Init packages
        packages[1] = Package(12, 6, true);
        lockups[1] =  [5, 10, 25, 40, 65, 100];

        packages[2] = Package(27, 9, true);
        lockups[2] =  [20, 50, 100];

        packages[3] = Package(48, 12, true);
        lockups[3] =  [100];

        packageId = 4;
    }


    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

     function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

     // Add package
    function addPackage(uint256 _totalPercentProfit, uint256 _vestingTime, uint256[] memory _lockups ) public onlyOwner {
        require(_totalPercentProfit > 0, "Profit can not be 0");
        require(_vestingTime > 0, "Vesting time can not be 0");
        packages[packageId] = Package(_totalPercentProfit, _vestingTime, true);
        lockups[packageId] = _lockups;
        packageId++;
    }

     // Update status package
    function setPackage(uint256 _packageId, bool _isActive) public onlyOwner {
        require(packages[_packageId].totalPercentProfit > 0, "Invalid package id");
        packages[_packageId].isActive = _isActive;
    }

    function setStakeToken(IERC20 _stakeToken) public onlyOwner {
        stakeToken = _stakeToken;
    }

    function setRewardToken(IERC20 _rewardToken) public onlyOwner {
        rewardToken = _rewardToken;
    }

     function setRateReward(uint256 _rate) public onlyOwner {
        require(_rate > 0, "Reward can not be 0");
        rateReward = _rate;
    }
    
    function setAccountReward(address _accountReward) public onlyOwner {
        accountReward = _accountReward;
    }

    function setAccountStake(address _accountStake) public onlyOwner {
        accountStake = _accountStake;
    }

    function getStakers() public view returns(address[] memory) {
        return stakers;
    }

    function getLockups(uint256 _packageId) public view returns(uint256[] memory) {
        return lockups[_packageId];
    }

    function getProfilesByAddress(address user) public view returns(UserInfo[] memory) {
        uint256 total = 0;
        for(uint i = 0; i < userInfo.length; i++){
            if (userInfo[i].user == user) {
               total++;
            }
        }

        require(total > 0, "Invalid profile address");

        UserInfo[] memory profiles = new UserInfo[](total);
        uint256 j;

        for(uint i = 0; i < userInfo.length; i++){
            if (userInfo[i].user == user) {
                profiles[j] = userInfo[i];  // step 3 - fill the array
                j++;
            }
        }

        return profiles;
    }

    function getProfilesLength() public view returns(uint256) {
        return userInfo.length;
    }
    
    function stake(uint _amount, uint256 _packageId) public payable {
        // Validate amount
        require(_amount > 0, "Amount cannot be 0");
        require(packages[_packageId].totalPercentProfit > 0, "Invalid package id");
        require(packages[_packageId].isActive == true, "This package is not available");

        // Transfer token
        stakeToken.transferFrom(msg.sender, accountStake, _amount);

        uint256 profit = _amount * packages[_packageId].totalPercentProfit / 100;

        UserInfo memory profile;
        profile.id = profileId;
        profile.packageId = _packageId;
        profile.user = msg.sender;
        profile.amount = _amount;
        profile.profitClaimed = 0;
        profile.stakeClaimed = 0;
        profile.vestingStart = block.timestamp;
        profile.vestingEnd = block.timestamp + packages[_packageId].vestingTime * PERIOD;
        profile.refunded = false;
        profile.totalProfit = profit;
        userInfo.push(profile);

        // Update profile id
        profileId++;

        // Update total staking
        totalStaking += _amount;

        // Update total profit
        totalProfit += profit;

        emit Deposit(msg.sender, _amount);
    }

    function getCurrentProfit(uint256 _profileId) public view returns(uint256) {
        require(userInfo[_profileId].packageId != 0, 'Invalid profile');

        UserInfo memory info = userInfo[_profileId];

        if ( block.timestamp > info.vestingEnd) {
            return info.totalProfit;
        }

        uint256 profit = (( block.timestamp - info.vestingStart) * info.totalProfit) / (info.vestingEnd - info.vestingStart);
        return profit;
    }

    function claimProfit(uint256 _profileId) public nonReentrant whenNotPaused {
        require(userInfo[_profileId].user == msg.sender, 'You are not onwer');
        UserInfo storage info = userInfo[_profileId];

        uint256 profit = getCurrentProfit(_profileId);
        uint256 remainProfit = profit - info.profitClaimed;

        require(remainProfit > 0, "No profit");

        uint256 netReward = remainProfit * rateReward / 100;
        rewardToken.transferFrom(accountReward, msg.sender, netReward);
        info.profitClaimed += remainProfit;

        // Update total profit claimed
        totalClaimedProfit += profit;

        emit ClaimProfit(msg.sender, remainProfit);
    }

    function getCurrentStakeUnlock(uint256 _profileId) public view returns(uint256) {
        require(userInfo[_profileId].packageId != 0, 'Invalid profile');

        UserInfo memory info = userInfo[_profileId];

        uint256[] memory pkgLockups = getLockups(info.packageId);

        if (block.timestamp < info.vestingEnd) {
            return 0;
        }

        // Not lockup, can withdraw 100% after vesting time
        if (pkgLockups.length == 1 && pkgLockups[0] == 100) {
            return info.amount;
        }

        uint256 length = pkgLockups.length;
        for(uint i = length - 1; i >= 0; i--){
            // Index + 1 = amount of months
            uint256 limitWithdrawTime = info.vestingEnd + (i + 1) * PERIOD;
            if (block.timestamp > limitWithdrawTime) {
               return pkgLockups[i] * info.amount / 100;
            }
        }

        return 0;
    }

    function claimStaking(uint256 _profileId) public nonReentrant whenNotPaused {
        require(userInfo[_profileId].user == msg.sender, 'You are not onwer');
        require(userInfo[_profileId].vestingEnd < block.timestamp, 'Can not claim before vesting end');

        UserInfo storage info = userInfo[_profileId];
        uint256 amountUnlock = getCurrentStakeUnlock(_profileId);

        uint256 remainAmount = amountUnlock - info.stakeClaimed;

        require(remainAmount > 0, "No staking");
        
        stakeToken.transferFrom(accountStake, msg.sender, remainAmount);
        info.stakeClaimed += remainAmount;

        // Update total staking
        totalClaimedStaking += remainAmount;

        emit ClaimStaking(msg.sender, remainAmount);
    }

    // Withdraw staking token from smart contract
    function withdraw(uint256 _amount) public onlyOwner {
        stakeToken.transfer(msg.sender, _amount);
    }
}
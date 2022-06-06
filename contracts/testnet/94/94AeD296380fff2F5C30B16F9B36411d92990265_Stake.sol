/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

// File: contracts/Lib/AddressUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    // function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    //     return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    // }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    // function functionDelegateCall(
    //     address target,
    //     bytes memory data,
    //     string memory errorMessage
    // ) internal returns (bytes memory) {
    //     require(isContract(target), "Address: delegate call to non-contract");

    //     (bool success, bytes memory returndata) = target.delegatecall(data);
    //     return verifyCallResult(success, returndata, errorMessage);
    // }

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

// File: contracts/Lib/Initializable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/Lib/ContextUpgradeable.sol


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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}
// File: contracts/Lib/OwnableUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;



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

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    // constructor() {
    //     _transferOwnership(_msgSender());
    // }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
    uint256[49] private __gap;
}

// File: contracts/Lib/IERC20.sol


pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
// File: contracts/staking1.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/TokenTimelock.sol)



// import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
// import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

pragma solidity ^0.8.0;
 
 //project1:  stake lasbs-Reward usdt 
 //project2:  stake usdt-Reward lasbs
 //project3:  stake ArenaB-Reward usdt
 //project4:  stake usdt-Reward ArenaB


// stake KNG reward usdt
// stake KNG reward Labs
// stake ArenaB-Reward usdt
// stake ArenaB-Reward Labs


contract Stake is Initializable,OwnableUpgradeable{
    event staketoken(uint256 project, uint256  amount,address accont,uint256 time);
    event unstaketoken(uint256 project, uint256  amount,address accont,uint256 time);
    event getRewardtoken(uint256 project, uint256  amount,address accont,uint256 time);


     struct stakingAccount{
        uint256[] stakeids;
        uint256 allAmount;
        uint256 getedReward;
        //uint256 lasttimeunstake;

    }
    
    struct stakeInfor{
        uint256 stakeTime;
        //uint256 endTime;
        uint256 stakeAmount;

    }

    struct ProjectInfor{
        address stakeToken;
        address RewardToken;
        uint256 Totalfundraised;
        uint256 TotalStakeTokens;
        uint256 TotalRewardTokens;
        uint256  MaxReward;
        address[]   AllAccont;
        //uint256  StakePoolStartTime;
        //uint256  StakePoolEndTime;
        uint256  stakeId;
        mapping (uint256=>stakeInfor) stakeInforById;
        mapping (address => stakingAccount) inforOfAddress;
    }
 
 
    // ERC20 basic token contract being held
    address public  USDTaddress;
    address public  Labsaddress;
    address public  ArenaBaddress;
    address public  Kngaddress;
    //uint256 public MaxRewardsinUSDT;


    uint256 testtime;

    IERC20 USDT;
    IERC20 Labs;
    IERC20 ArenaB;
    IERC20 KNG;
    //uint256 public stakeId;

    uint256 public StakePoolStartTime;
    uint256 public StakePoolEndTime;
    bool public isSetStakePoolStartTime;
    //uint256 public NumberOfToday;
    //uint256 public Totalfundraised;

    //uint256 public TotalProjecttokens;
    //address[] public  AllAccont;
    

    //uint256 public AllStakeNumbers;
    //uint256[] private AllStakeAddress;

    //mapping (uint256=>stakeInfor) stakeInforById;
   // mapping (uint256=>uint256) TheDaysAllAmount;
    //mapping (uint256=>uint256) TheDaysOneStakeGetUSDT;
    //mapping (address => stakingAccount) inforOfAddress;



    //mapping(uint256 => address) getStakeTokenAddressByProject;
    //mapping(uint256 => address) getBonusStakeAddressByProject;

    //mapping (uint256 => uint256[]) AddressOfOneDay;
    mapping(uint256 => ProjectInfor) getProjectInforByProjectId;




     function initialize( 
        address usdtaddress,
        address labsaddress,
        address arenaBaddress,
        address kngaddress,
        uint256 totalfundraised_project1,
        uint256 totalfundraised_project2,
        uint256 totalfundraised_project3,
        uint256 totalfundraised_project4,
        uint256 maxreward_project1,
        uint256 maxreward_project2,
        uint256 maxreward_project3,
        uint256 maxreward_project4
        ) public initializer {
        __Ownable_init();
        USDTaddress=usdtaddress;
        Labsaddress=labsaddress;
        ArenaBaddress=arenaBaddress;
        Kngaddress=kngaddress;

        getProjectInforByProjectId[1].stakeToken=Kngaddress;
        getProjectInforByProjectId[1].RewardToken=usdtaddress;
        getProjectInforByProjectId[1].Totalfundraised=totalfundraised_project1;
        getProjectInforByProjectId[1].MaxReward=maxreward_project1;

        getProjectInforByProjectId[2].stakeToken=Kngaddress;
        getProjectInforByProjectId[2].RewardToken=labsaddress;
        getProjectInforByProjectId[2].Totalfundraised=totalfundraised_project2;
        getProjectInforByProjectId[2].MaxReward=maxreward_project2;
        
        getProjectInforByProjectId[3].stakeToken=arenaBaddress;
        getProjectInforByProjectId[3].RewardToken=usdtaddress;
        getProjectInforByProjectId[3].Totalfundraised=totalfundraised_project3;
        getProjectInforByProjectId[3].MaxReward=maxreward_project3;

        getProjectInforByProjectId[4].stakeToken=arenaBaddress;
        getProjectInforByProjectId[4].RewardToken=labsaddress;
        getProjectInforByProjectId[4].Totalfundraised=totalfundraised_project4;
        getProjectInforByProjectId[4].MaxReward=maxreward_project4;


        
        USDT =IERC20(USDTaddress);
        Labs =IERC20(labsaddress);
        ArenaB =IERC20(arenaBaddress);
        KNG=IERC20(kngaddress);
        
        
    }
 
    // constructor(
    //     address usdtaddress,
    //     address kngaddress,
    //     uint256 stakepoolstarttime,
    //     uint256 totalfundraised
    //     //address beneficiary_//锁仓结束回退地址
    //     //uint256 releaseTime_//解锁时间
    // ) {
    //     //require(releaseTime_ > block.timestamp, "TokenTimelock: release time is before current time");
    //     USDTaddress=usdtaddress;
    //     KNGaddress=kngaddress;
    //     Totalfundraised=totalfundraised;
    //     USDT =IERC20(USDTaddress);
    //     KNG =IERC20(KNGaddress);
    //     StakePoolStartTime=stakepoolstarttime;
    //     StakePoolEndTime=stakepoolstarttime+86400*365;
    //    // _beneficiary = beneficiary_;
    //    // _releaseTime = releaseTime_;
    // }
    function setStakePoolStartTime(uint256 stakepoolstarttime) public onlyOwner {

        require(!isSetStakePoolStartTime,"you have set StakePoolStartTime");
        StakePoolStartTime=stakepoolstarttime;
        StakePoolEndTime=stakepoolstarttime+86400*365;
        isSetStakePoolStartTime=true;
        

    }

    function setTotalfundraisedByProject(uint256 project,uint256 amount) public onlyOwner {
         getProjectInforByProjectId[project].Totalfundraised=amount;
    }

    function setMaxRewardByProjectByProject(uint256 project,uint256 amount) public onlyOwner {
         getProjectInforByProjectId[project].MaxReward=amount;
    }


    function getMaxRewardByProject(uint256 project) public view returns(uint256){
        return getProjectInforByProjectId[project].MaxReward;
    }

    function getTotalStakeTokensByProject(uint256 project) public view returns(uint256){
        return getProjectInforByProjectId[project].TotalStakeTokens;
    }

    function getTotalRewardTokensByProject(uint256 project) public view returns(uint256){
        return getProjectInforByProjectId[project].TotalRewardTokens;
    }

    function getTotalfundraisedByProject(uint256 project) public view returns(uint256){
        return getProjectInforByProjectId[project].Totalfundraised;
    }

    function settesttime(uint256 _testtime) public{
        testtime=_testtime;
    }

    function getstakeInfor(uint256 project, uint256 id) public view returns(stakeInfor memory){
       return getProjectInforByProjectId[project].stakeInforById[id];
    }

    function getstakingAccount(uint256 project,address addr) public view returns(stakingAccount memory){
       return getProjectInforByProjectId[project].inforOfAddress[addr];
    }

    function getAccountstakingAmount(uint256 project, address addr) public view returns(uint256 ){
       return getProjectInforByProjectId[project].inforOfAddress[addr].allAmount;
    }

    function getUSDTamoumut() public view  returns(uint256){
        return USDT.balanceOf(address(this));
    }

    function getLabsamount() public view returns(uint256){
        return Labs.balanceOf(address(this));
    }

    function getArenaBamount() public view returns(uint256){
        return ArenaB.balanceOf(address(this));
    }
    function getKngamount() public view returns(uint256){
        return KNG.balanceOf(address(this));
    }

    function getStakePoolStartTime() public view returns(uint256){
        return StakePoolStartTime;
    }

    function getStakePoolEndTime() public view returns(uint256){
        return StakePoolEndTime;
    }

     function DailyRewardsPerTokenInReward(uint256 project) public view  returns(uint256){
        return 10**20*getProjectInforByProjectId[project].MaxReward/365/getProjectInforByProjectId[project].Totalfundraised;
    }

    

    function stake(uint256 project,  uint256 amount) public {
        stakeverify(project,amount);
        //beforestake();
        ProjectInfor storage _projectinfor = getProjectInforByProjectId[project];
        bool isrepeat;
        
        for(uint256 i=0; i<_projectinfor.AllAccont.length;i++){
            if(_projectinfor.AllAccont[i]==msg.sender){
                isrepeat=true;
                break;
            }
        }
        if(!isrepeat){
            _projectinfor.AllAccont.push(msg.sender);
        }
        
        _projectinfor.TotalStakeTokens+=amount;

        stakingAccount storage stakingaccount=_projectinfor.inforOfAddress[msg.sender];
        
        stakingaccount.allAmount+=amount;

        _projectinfor.stakeId++;
        _projectinfor.stakeInforById[_projectinfor.stakeId]=stakeInfor({
            stakeTime:testtime,
            
            stakeAmount:stakingaccount.allAmount
        });

       // AddressOfOneDay[]
            
       
        stakingaccount.stakeids.push(_projectinfor.stakeId);
        

        IERC20 satketoken=IERC20(_projectinfor.stakeToken);
        
        satketoken.transferFrom(msg.sender, address(this), amount);

        emit staketoken(project, amount, msg.sender, testtime);
        

    }


    function getRewardinfor( uint256 project, address account) public view returns(uint256){
        require(block.timestamp>StakePoolStartTime,"stake is not start");
        ProjectInfor storage _projectinfor = getProjectInforByProjectId[project];
        stakingAccount memory stakingaccount=_projectinfor.inforOfAddress[account];
        require(stakingaccount.stakeids.length!=0,"you have no satke");
        uint256[] memory _stakeids=stakingaccount.stakeids;
        uint256 getAllReward;
         uint256 getRewardtime=testtime;
                if(getRewardtime>StakePoolEndTime){
                    getRewardtime=StakePoolEndTime;
                }
        if(stakingaccount.stakeids.length==1){
                stakeInfor memory _stakeinfor= _projectinfor.stakeInforById[_stakeids[0]];
               
                getAllReward=((getRewardtime-_stakeinfor.stakeTime)/86400)*_stakeinfor.stakeAmount*DailyRewardsPerTokenInReward(project);
        }else{
            uint256 k=_stakeids.length-1;
            for(uint256 y=0;y<_stakeids.length;y++){
                    uint256  _stakeTime= _projectinfor.stakeInforById[_stakeids[y]].stakeTime;
                    if(_stakeTime>StakePoolEndTime){
                        k=y-1;
                        break;
                    }
            }

            for(uint256 i=0;i<k;i++){
                
                stakeInfor memory _stakeinfor= _projectinfor.stakeInforById[_stakeids[i]];
                stakeInfor memory stakeinfor= _projectinfor.stakeInforById[_stakeids[i+1]];
                //uint256 stakedays;
                
                uint256 getRewardonceStake =((stakeinfor.stakeTime-_stakeinfor.stakeTime)/86400)*_stakeinfor.stakeAmount*DailyRewardsPerTokenInReward(project);

                // if(stakingaccount.lasttimeunstake==0){
                //      stakedays=(block.timestamp- _stakeinfor.startTime)/86400+1;
                // }else{
                //      stakedays=(block.timestamp- stakingaccount.lasttimeunstake)/86400+1;
                // }
                
            // uint256 getUSDTonceStake = stakedays*_stakeinfor.stakeAmount*DailyRewardsPerTokenInUSDT();
                getAllReward+=getRewardonceStake;

            }
             stakeInfor memory laststakeinfor= _projectinfor.stakeInforById[_stakeids[k]];
               uint256 getLastReward=((getRewardtime-laststakeinfor.stakeTime)/86400)*laststakeinfor.stakeAmount*DailyRewardsPerTokenInReward(project);
            getAllReward+=getLastReward;
        }
            
             getAllReward=getAllReward/(10**20);
             //uint256 getAllUSDTa=getAllUSDT;
            getAllReward-=stakingaccount.getedReward;

            //uint256 getAllUSDTb=stakingaccount.getedUSDT;

        return getAllReward;

        // uint256 getallUSDT;
        // for(uint256 i=0;i<_stakeids.length;i++){
        //     uint256 getUSDTonce;
        //   stakeInfor memory _stakeinfor= stakeInforById[_stakeids[i]];
        //   uint256 _stakeamount=_stakeinfor.stakeAmount;
        //   uint256 startday=(_stakeinfor.startTime- StakePoolStartTime)/86400+1;
        //   for(uint a=startday;a<=365;a++){
        //      uint256 thedaygetUSDT=TheDaysOneStakeGetUSDT[a]*_stakeamount;
        //         getUSDTonce+=thedaygetUSDT;
        //   }
        //   getallUSDT+=getUSDTonce;
        // }
        


    }

    function stakeverify(uint256 project,uint256 amount) view internal {
        require(amount>0,"stake amount cannot be less than 0");
        require(getProjectInforByProjectId[project].TotalStakeTokens+amount<=getProjectInforByProjectId[project].Totalfundraised,"TotalProjecttokens more than Totalfundraised");
        IERC20 token=IERC20(getProjectInforByProjectId[project].stakeToken);
        require(token.allowance(msg.sender, address(this))>=amount,"Not enough approves ");
        require(testtime>=StakePoolStartTime,"Stake Pool is not Start");
        require(testtime<=StakePoolEndTime,"Stake Pool is  end");
    }


    
    function unstakeverify(uint256 project,uint256 amount) view internal {
        require(amount>0,"stake amount cannot be less than 0");
        require(testtime>=StakePoolStartTime,"Stake Pool is not Start");
        require(getProjectInforByProjectId[project].TotalStakeTokens-amount>=0,"TotalStakeTokens cannot be less than 0");
        require(getProjectInforByProjectId[project].inforOfAddress[msg.sender].allAmount-amount>=0,"You unstake amount is more than your stake amount");
        
        
    }


    function getReward(uint256 project) public {
        ProjectInfor storage _projectinfor = getProjectInforByProjectId[project];
        
        require(testtime>=StakePoolStartTime,"Stake Pool is not Start");
        stakingAccount storage stakingaccount=_projectinfor.inforOfAddress[msg.sender];
        // uint256 a;
        // uint256 b;
        // uint256 c;
        //               (a,b,c)   =getUSTDinfor(msg.sender);
        uint256 _getReward = getRewardinfor(project,msg.sender);
        // uint256 _getUSTD =a;

        IERC20 rewardtoken=IERC20(_projectinfor.RewardToken);
        rewardtoken.transfer(msg.sender, _getReward);
        stakingaccount.getedReward+=_getReward;

        _projectinfor.TotalRewardTokens+=_getReward;
        
        //stakingaccount.lasttimeunstake=block.timestamp;
        emit getRewardtoken(project, _getReward,msg.sender,testtime);

    }
    

     function unstake(uint256 project, uint256 amount) public {

         unstakeverify(project,amount);
         
         
        //beforestake();
        ProjectInfor storage _projectinfor = getProjectInforByProjectId[project];
        
        stakingAccount storage stakingaccount=_projectinfor.inforOfAddress[msg.sender];
        
         _projectinfor.TotalStakeTokens-=amount;
         
          //beforestake();
        
        
        
        stakingaccount.allAmount-=amount;

        _projectinfor.stakeId++;
        _projectinfor.stakeInforById[_projectinfor.stakeId]=stakeInfor({
            stakeTime:testtime,
            
            stakeAmount:stakingaccount.allAmount
        });

       // AddressOfOneDay[]
            
       
        stakingaccount.stakeids.push(_projectinfor.stakeId);
       
         IERC20 satketoken=IERC20(_projectinfor.stakeToken);
        
        satketoken.transfer(msg.sender, amount);

        emit unstaketoken(project,amount, msg.sender, testtime);


    }

    // function beforestake() internal {
    //     //AllStakeAddress.push(msg.sender);
       
    //     uint256 OneStakeGetUSDTtheDay;
    //     if(AllStakeNumbers==0){

    //         OneStakeGetUSDTtheDay=getUSDTamoumutOneDay() ;
    //     }else{
    //          OneStakeGetUSDTtheDay=getUSDTamoumutOneDay()/AllStakeNumbers;
    //     }
        
    //     uint256 timenow=block.timestamp;
    //     uint256 todaynum=(timenow-StakePoolStartTime)/86400;
    //     if(todaynum+1!=NumberOfToday){
            
    //         TheDaysAllAmount[todaynum]=AllStakeNumbers;
    //         TheDaysOneStakeGetUSDT[todaynum]=OneStakeGetUSDTtheDay;
    //         NumberOfToday=todaynum+1;
    //     }

    //     AllStakeNumbers++;
        // uint256[] memory addressOfOneDay =   AddressOfOneDay[daysnumber];
        // for(uint i=0;i<AllStakeAddress.length;i++){
        //     uint256 addresse =AllStakeAddress[i];
        //     addresse
            

        // }


    //}
       function getAllRewardEarnings(uint256 project) public  view returns(uint256){
           require(testtime>=StakePoolStartTime,"Stake Pool is not Start");

           ProjectInfor storage _projectinfor = getProjectInforByProjectId[project];
           uint256 AllRewardEarnings;
        for(uint256 i;i<_projectinfor.AllAccont.length;i++){
            AllRewardEarnings+=getRewardinfor(project,_projectinfor.AllAccont[i]);
            
        }
        return AllRewardEarnings;
    }



    function returnReward(uint256 project,address returnaddress) public  onlyOwner{
        require(testtime >= StakePoolEndTime, "TokenTimelock: current time is before release time");
        ProjectInfor storage _projectinfor = getProjectInforByProjectId[project];
        uint256 _returnReward =_projectinfor.MaxReward-getAllRewardEarnings(project); 
       // uint256 amount = USDT.balanceOf(address(this));
        require(_returnReward > 0, "TokenTimelock: no tokens to release");
        IERC20 rewardtoken=IERC20(_projectinfor.RewardToken);

        rewardtoken.transfer(returnaddress, _returnReward);
    }
}
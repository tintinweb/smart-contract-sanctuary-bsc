/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// File: Structs.sol


pragma solidity ^0.8.0;

struct DataParam{
    address tokenAddress;
    uint256 presaleSupply;
    uint256 hardCap;
    uint256 rate;
    uint256 exchangeListingRate;
    bool lockLiquidity;
    uint256 liquidityLockTime;
    bool Vesting;
}

struct vestingStruct{
    uint256 firstPercent;
    uint256 firstReleaseTime;
    uint256 cyclePercent;
    uint256 cycleReleaseTime;
    uint256 cycleCount;
}
// File: IstakingPoolVerify.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface PoolsRankVerify{
    
    function getStakeAmount(address staker) external view returns(uint);
    function getStakeActive(address staker) external view returns(bool);
    function getRemainingDuration(address staker) external view returns(uint);
    function getRank(address staker) external view returns(uint);
}

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


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

// File: IDO.sol


pragma solidity ^0.8.0;





contract IDO{

    address owner;
    address factory;
    IERC20Upgradeable token;
    uint private ID;
    uint rate;
    uint target;

    uint totalRaised;

    bool presaleStarted;
    bool presaleCancelled;
    PoolsRankVerify pool;

    mapping(address => uint) arrayIndexForAddress;
    mapping(address => uint) public maxallocation;
    mapping(address => bool) public whitelisted;
    mapping(address => uint) public tokenBalance;
    mapping(address => uint) public spentAllocation;
    mapping(address => uint) public ranks;
    address[] whitelistedAddresses;


    
     //Vesting
    
    struct VestingPriod{
        uint percent;
        uint startTime;
        uint vestingCount;
       uint MaxClaim;   
    }
    
    uint public maxPercent;
    bool public Vesting;
    uint public VestingCount;

    VestingPriod public _vestingPeriod;
    vestingStruct public vesting;

    mapping(uint => VestingPriod) public PeriodtoPercent;
    mapping(address => uint) public TotalBalance;
    mapping(address => uint) private claimCount;
    mapping(address => uint) private claimedAmount;
    mapping(address => uint) private claimmable;



    function initialize(address _owner, uint id, DataParam memory data, address staking, vestingStruct calldata _vesting) external{
        owner = _owner;
        ID = id;
        pool = PoolsRankVerify(staking);
        rate = data.rate;
        token = IERC20Upgradeable(data.tokenAddress);
        Vesting = data.Vesting;
        target = data.hardCap;
        vesting = _vesting;
        factory = msg.sender;

    }


    receive() external payable{}

    
    function requestWhitelist() external{
        require(!whitelisted[msg.sender], "Already whitelisted");
        
        uint rank = pool.getRank(msg.sender);

        require(rank > 0, "You are not qualifiedm stake more");

        if(rank == 4){
            maxallocation[msg.sender] = 1000;
            ranks[msg.sender] = 4;
        }else{
            if(rank ==3){
                maxallocation[msg.sender] = 500;
                ranks[msg.sender] = 3;
            }else{
                if(rank == 2){
                    maxallocation[msg.sender] = 250;
                    ranks[msg.sender] = 2;
                }else{
                    if(rank == 1){
                        maxallocation[msg.sender] = 100;
                        ranks[msg.sender] = 1;
                    }
                }
            }
        }

            whitelistedAddresses.push(msg.sender);
            arrayIndexForAddress[msg.sender] = whitelistedAddresses.length;
            whitelisted[msg.sender] = true;   
    }


    function startPresale() external{
        require(msg.sender == owner, "Unauthorized");

        presaleStarted = true;
    }
    function endPresale() internal{
        require(msg.sender == owner, "Unauthorized");

        presaleStarted = false;
    }

    function cancelPresale() external {
        require(msg.sender == owner, "Unauthorized");
        require(!finalised, "Presale already finalised");
        require(!presaleCancelled, "Already Cancelled");

        presaleCancelled = true;
    }

    function factoryCancelPresale() external{
        require(msg.sender == factory, "Not factory");
        require(!finalised, "Presale already finalised");
        require(!presaleCancelled, "Already Cancelled");
        presaleCancelled = true;
    }

    bool finalised;

    function finalisePresale() external{
        require(msg.sender == owner, "Unauthorized");
        require(presaleStarted, "Presale not started yet");
        require(!finalised, "Already Finalised");

        endPresale();
        finalised = true;


    }

    function buy(uint amountInUSD) external{
        require(presaleStarted, "Presale not started yet");
        require(!finalised, "Already Finalised");
        require(whitelisted[msg.sender], "Address not Whitelisted");
        require(maxallocation[msg.sender] > 0, "Allocation Used up");
        require(amountInUSD <= maxallocation[msg.sender], "Allocation is less than buy");
        require(totalRaised + amountInUSD <= target, "amount exceedinh cap");
        

        uint amount = amountInUSD * rate;
        spentAllocation[msg.sender]+= amountInUSD;
        maxallocation[msg.sender] -= amountInUSD;

        tokenBalance[msg.sender] += amount;
        TotalBalance[msg.sender]+= amount;
        totalRaised += amountInUSD;

    }

    function withdraw(uint amountInUSD) external{
        require(!finalised, "Already Finalised");
        require(presaleStarted, "Presale not started yet");
        require(tokenBalance[msg.sender] > 0, "You have not bought any tokens");

        uint debitAmount = amountInUSD * rate;

        tokenBalance[msg.sender] -= debitAmount;
        
        spentAllocation[msg.sender] -= amountInUSD;

        maxallocation[msg.sender] += amountInUSD;
        totalRaised -= amountInUSD;
    }

    function cancelContribution() external{
        require(!finalised, "Already Finalised");
        require(presaleStarted, "Presale not started yet");
        require(tokenBalance[msg.sender] > 0, "You have not bought any tokens");

        uint spent = spentAllocation[msg.sender];
        delete spentAllocation[msg.sender];
        delete tokenBalance[msg.sender];

        maxallocation[msg.sender] += spent;
        totalRaised -= spent;
    }


    mapping(address => bool) claimednormal;

    
    function Claim() external{
        require(finalised, "Presale not finalised");
        
        if(!Vesting){
        
            _normalClaim();    
        
        }else {
        
            _vestingClaim();
        
        }
    }

    function claimRefund() external{
        require(presaleCancelled, "Presale not cancelled");
    
        uint spent = spentAllocation[msg.sender];
        delete spentAllocation[msg.sender];
        delete tokenBalance[msg.sender];

        maxallocation[msg.sender] += spent;
        totalRaised -= spent;
        delete whitelisted[msg.sender];

    }


    function _normalClaim() internal {
        
        require(!claimednormal[msg.sender], "Already claimed");

        uint bal = tokenBalance[msg.sender];

        delete spentAllocation[msg.sender];
        delete tokenBalance[msg.sender];
        claimednormal[msg.sender] = true;

        token.transfer(msg.sender, bal);
        
    }

    
 


    //Vesting 
 

    function updateVesting(bool newStatus) external {
        require(msg.sender == owner,"NO");//Not Owner
        require(Vesting != newStatus);

        Vesting = newStatus;
    }

    uint[] public time;
    uint[] public percent;

    function getVesting() external view returns(uint[] memory, uint[] memory){
        return(time, percent);
    }

    function setVesting() external {
    
        uint count = vesting.cycleCount; 


        uint totalPrecent = ((count-1) * vesting.cyclePercent) +vesting.firstPercent;

        require(totalPrecent >= 10000, "Precentage entered not up to 100%");


           VestingCount++;
           maxPercent += vesting.firstPercent;

           PeriodtoPercent[VestingCount] = VestingPriod({
            percent : vesting.firstPercent,
            startTime : vesting.firstReleaseTime,
            vestingCount : VestingCount,
            MaxClaim : maxPercent
        });

        vestingDetails.push(PeriodtoPercent[VestingCount]);

        time.push(vesting.firstReleaseTime);
        percent.push(vesting.firstPercent);

        uint lastime = vesting.firstReleaseTime;
        uint percentAmount;

        

            for(uint i = 2; i<= vesting.cycleCount; i++){
            
            lastime += vesting.cycleReleaseTime;
            
            require(lastime > PeriodtoPercent[VestingCount-1].startTime);
            
            maxPercent += vesting.cyclePercent;
            percentAmount = vesting.cyclePercent;

                if(maxPercent > 10000){

                    maxPercent -= vesting.cyclePercent;
                    percentAmount = 10000 - maxPercent;  

                    maxPercent += percentAmount; 

                }
            
            time.push(lastime);
            percent.push(percentAmount);

            VestingCount++;

            PeriodtoPercent[VestingCount] = VestingPriod({

                        percent : percentAmount,
                        startTime : lastime,
                        vestingCount : VestingCount,
                        MaxClaim : maxPercent
                    });
                    vestingDetails.push(PeriodtoPercent[VestingCount]);
            }

        
    }
    mapping(address => mapping(uint => bool)) public vestingToClaimed;
    mapping(address => mapping(uint => uint)) public recievedTokens;
    VestingPriod[] vestingDetails;

    function getVestingDetailes() external view returns(VestingPriod[] memory){
        return vestingDetails;
    }

  
    function _vestingClaim() public {
        
        require(claimCount[msg.sender] <= VestingCount,"CC");//Claiming Complete

        for(uint i = claimCount[msg.sender]; i<= VestingCount; i++){
            if(PeriodtoPercent[i].startTime <= block.timestamp){

                claimmable[msg.sender] +=PeriodtoPercent[i].percent;

                claimCount[msg.sender] ++;

            }
            else {
                break;
            }
            
        }
        
            
        require(claimmable[msg.sender] <= 10000, "Over Limit");
        
        uint _amount = (claimmable[msg.sender]) /10000 * TotalBalance[msg.sender];

        tokenBalance[msg.sender] -= _amount;
        claimedAmount[msg.sender] += claimmable[msg.sender]; 
  
        delete claimmable[msg.sender];
        
    
        token.transfer(msg.sender, _amount);

    }

    
    function getWhitelisted(address user) external view returns(bool){
        return whitelisted[user];
    }
    function getMaxAllocationForPresale(address user) external view returns(uint){
        return maxallocation[user];
    }
    function getTokenBalance(address user) external view returns(uint){
        return tokenBalance[user];
    }
    function getSpentAllocation(address user) external view returns(uint){
        return spentAllocation[user];
    }
    function getRank(address user) external view returns(uint){
        return ranks[user];
    }

    function getTarget() external view returns(uint){
        return target;
    }
    function getToralRaised() external view returns(uint){
        return totalRaised;
    }
    function getRate() external view returns(uint){
        return rate;
    }
    function getPresaleStarted() external view returns(bool){
        return presaleStarted;
    }
    function getPresaleToken() external view returns(address){
        return address(token);
    }
    function getPresaleID() external view returns(uint){
        return ID;
    }





}
// File: Launch.sol


pragma solidity ^0.8.0;





contract LaunchIDO is Initializable{
    address admin;
    uint ID;


    event IDOCreated(address indexed owner, address indexed ido);

    function initialize() external initializer{
        admin = msg.sender;

    }


    function createNewIDO(address owner, DataParam memory data, vestingStruct memory vesting) external{
    require(msg.sender == admin, "Unauthorised");
        ID++;

        IDO ido = new IDO();
        address newcontract = address(ido);
        
        IDO(payable(newcontract)).initialize(owner, ID, data, 0xBCc65F36a9D93D50914966E2c2387A230C657233, vesting);
     
        if(data.Vesting){
            IDO(payable(newcontract)).setVesting();
        }
        

        IERC20Upgradeable(data.tokenAddress).transferFrom(owner, address(newcontract), data.presaleSupply);

        emit IDOCreated(owner, address(newcontract));
    }

    function changeAdmin(address newAdmin) external{
        require(msg.sender == admin, "Unauthorised");

        admin = newAdmin;
    } 
    function cancelPresale(address presaleAddress) external{
        require(msg.sender == admin, "Unauthorised");

        IDO(payable(presaleAddress)).factoryCancelPresale();
    }
    
    
}
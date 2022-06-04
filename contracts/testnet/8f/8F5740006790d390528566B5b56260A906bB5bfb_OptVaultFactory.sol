// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "./Interfaces/IAdmin.sol";
import "./Interfaces/IOptVault.sol";
import "./Interfaces/ISingleVault.sol";
import "./Interfaces/ILPVault.sol";
import "./Interfaces/IReceipt.sol";
import "./Interfaces/IEvents.sol";
import "./Interfaces/IPhoenixNft.sol";
import "./Interfaces/IOpt1155.sol";

contract OptVaultFactory is Initializable, KeeperCompatibleInterface, ReentrancyGuard,IEvents {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 time;
        bool phoenixNFTStatus;
        nftStatus NFT;
        uint256 amount;
    }
    enum  nftStatus {
        NOT_MINTED,
        ACTIVE
    }

    struct PoolInfo {
        IERC20 token;
        address vault;
        address recieptInstance;
        bool status;
        bool isLp;
        bool isAuto;
        bool isCustomVault;
        uint32[] multiplier;
    }

    enum LiqStatus {
        SWAP_WANT_TO_BUSD,
        CONTROLLER_FEE,
        OPTIMIZATION_TAX,
        OPTIMIZATION_REWARDS
    }
    LiqStatus public liqStatusValue; // enum

    // uint256 public totalAllocPoint;
    uint256 public BUSDCollected;
    uint256 public controllerFee;
    uint256 counter;
    uint256 epochTime;
    address public masterNTT;
    address public YSLBUSDVault;
    address public USDyBUSDVault;
    address public xYSLBUSDVault;
    address public BshareBUSDVault;
    address public ApeswapRouter;
    address public YSLVault;
    address public xYSLVault;
    address public USDyVault;
    address public BShareVault;
    address public distributor; // address of distributor
    address public OptVault; // address of Optvault
    address public OptVaultAuto; // address of OptvaultAuto
    address public OptVaultLp; // address of OptVaultLP
    address public router; // Router address
    address public YSL; // address of YSL
    address public owner;// address of the owner
    IAdmin public Admin; // address of Admin

    uint public interval;  /** Use an interval in seconds and a timestamp to slow execution of Upkeep */
    uint public lastTimeStamp;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; //PID => user => info
    mapping(address => uint256) public PIDsOfRewardVault; //token => pid

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier isActive(uint256 _pid) {
        require(poolInfo[_pid].status, "OptVaultFactory: Pool is diactivated");
        _;
    }
    

    modifier externalDefence() {
        require(
            !_isContract(msg.sender),
            "OptVaultFactory: Not reliable external call"
        );
        _;
    }
    modifier _isAdmin(){
        require(Admin.hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        _;
    }
    
    function initialize(
        address _owner,
        address _Admin,
        address _optVault,
        address _optVaultLp,
        address _optVaultAuto,
        uint256 updateInterval
    ) external initializer {
        owner = _owner;
        Admin = IAdmin(_Admin);
        OptVault = _optVault;
        OptVaultLp = _optVaultLp;
        masterNTT = Admin.masterNTT();
        YSLVault = Admin.YSLVault();
        xYSLVault = Admin.xYSLVault();
        USDyVault = Admin.USDyVault();
        BShareVault = Admin.BShareVault();
        YSLBUSDVault = Admin.YSLBUSDVault();
        xYSLBUSDVault = Admin.xYSLBUSDVault();
        USDyBUSDVault = Admin.USDyBUSDVault();
        BshareBUSDVault = Admin.BShareBUSDVault();
        ApeswapRouter = Admin.ApeswapRouter();
        OptVaultAuto = _optVaultAuto;
        liqStatusValue = LiqStatus.SWAP_WANT_TO_BUSD;
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
        epochTime = 1 hours;
    }

    /** 
        @dev Add a new lp or token to the pool. Can only be called by the owner.
        XXX DO NOT add the same LP token more than once. Rewards , will be messed up if you do.
    */

    function add(
        IERC20 _token,
        address _want,
        string memory _name,
        string memory _symbol,
        bool isLpToken,
        bool isAuto,
        address _smartChef,
        uint32[] memory _multiplier
    ) nonReentrant external _isAdmin returns (address) {
        require(PIDsOfRewardVault[address(_token)] == 0,"OptVaultFactory : Vault for this token exists");
        address instance = Clones.clone(masterNTT);
        address strat;
        if(isLpToken){
            strat = Clones.clone(OptVaultLp);
        }else if(isAuto){
            strat = Clones.clone(OptVaultAuto);
            require(_smartChef != address(0),"invalid smartChef");
            IOptVault(strat).setPoolDetails(_smartChef,_want);
        }else{
            strat = Clones.clone(OptVault);
        }
        PoolInfo memory pool = PoolInfo(_token,strat,instance,true,isLpToken,isAuto,false,_multiplier);
        poolInfo.push(pool);
        IOptVault(strat).initialize(poolInfo.length, address(_token), _want, address(Admin));
        IOptVault(strat).setreciept(instance);
        IReceipt(instance).initialize(address(Admin), strat, _name, _symbol); 
        PIDsOfRewardVault[address(_token)] = poolInfo.length-1;
        IOpt1155(IAdmin(Admin).Opt1155()).createNFTForVault(poolInfo.length, _name);
        return (instance);
        emit OptAdd(address(_token),isLpToken,isAuto,_smartChef,strat,instance,block.number,block.timestamp);
    }
    function setMultipliersLevel(address _token,uint32[] calldata _multiplier,uint32[] memory deductionValue) external _isAdmin{
        uint256 id = PIDsOfRewardVault[_token];
            
            for(uint32 i; i <= _multiplier.length -1; i++){
                emit OptMultiplierLevel("optfactory",_token, _multiplier, deductionValue, block.number,block.timestamp);
                IOptVault(poolInfo[id].vault).setMultiplierLevel((i + 1),deductionValue[i]);
            }
    }
    function addCustomVaults(IERC20 _token,address vaultAddress, uint32[] calldata _multiplier) nonReentrant external _isAdmin{
        if(vaultAddress == address(YSLVault)){
            // ISingleVault(YSLVault).initialize(address(Admin),owner);
            PoolInfo memory pool = PoolInfo(_token,YSLVault,ISingleVault(YSLVault).receiptToken(),true,false,false,true,_multiplier);
            poolInfo.push(pool);
        }
        else{
            if(vaultAddress == address(xYSLVault)){
                // ISingleVault(xYSLVault).initialize(address(Admin),owner);
                PoolInfo memory pool = PoolInfo(_token,xYSLVault,ISingleVault(xYSLVault).receiptToken(),true,false,false,true,_multiplier);
                poolInfo.push(pool);
            }
            else{
                if(vaultAddress == address(USDyVault)){
                    // ISingleVault(USDyVault).initialize(address(Admin),owner);
                    PoolInfo memory pool = PoolInfo(_token,USDyVault,ISingleVault(USDyVault).receiptToken(),true,false,false,true,_multiplier);
                    poolInfo.push(pool);
                }
                else{
                    if(vaultAddress == address(BShareVault)){
                        // ISingleVault(BShareVault).initialize(address(Admin),owner);
                        PoolInfo memory pool = PoolInfo(_token,BShareVault,ISingleVault(BShareVault).receiptToken(),true,false,false,true,_multiplier);
                        poolInfo.push(pool);
                    }
                }
            }
        }
        require(vaultAddress != address(0),"InValid Address");
        emit OptAddCustomVaults(address(_token), vaultAddress,block.number,block.timestamp);
    }

    function addCustomLPVaults(IERC20 _token,address vaultAddress ,uint32[] calldata _multiplier) nonReentrant external _isAdmin{
        if(vaultAddress == address(YSLBUSDVault)){
            // ILPVault(YSLBUSDVault).initialize(address(Admin),owner,address(_token));
            PoolInfo memory pool = PoolInfo(_token,YSLBUSDVault,ILPVault(YSLBUSDVault).receiptToken(),true,false,false,true,_multiplier);
            poolInfo.push(pool);
        }
        else{
            if(vaultAddress == address(xYSLBUSDVault)){
                // ILPVault(xYSLBUSDVault).initialize(address(Admin),owner,address(_token));
                PoolInfo memory pool = PoolInfo(_token,xYSLBUSDVault,ILPVault(xYSLBUSDVault).receiptToken(),true,false,false,true,_multiplier);
                poolInfo.push(pool);
            }
            else{
                if(vaultAddress == address(USDyBUSDVault)){
                    // ILPVault(USDyBUSDVault).initialize(address(Admin),owner,address(_token));
                    PoolInfo memory pool = PoolInfo(_token,USDyBUSDVault,ILPVault(USDyBUSDVault).receiptToken(),true,false,false,true,_multiplier);
                    poolInfo.push(pool);
                }
                else{
                    if(vaultAddress == address(BshareBUSDVault)){
                        // ILPVault(BshareBUSDVault).initialize(address(Admin),owner,address(_token));
                        PoolInfo memory pool = PoolInfo(_token,BshareBUSDVault,ILPVault(BshareBUSDVault).receiptToken(),true,false,false,true,_multiplier);
                        poolInfo.push(pool);
                    }
                }
            }
        }
        require(vaultAddress != address(0),"InValid Address");
        emit OptAddCustomVaults(address(_token), vaultAddress,block.number,block.timestamp);

    }
/**
@dev this function sets controller fee amount
 */

    function setControllerFee(uint256 _amount)
        external
        _isAdmin
    {
        require(_amount > 0, "OptVaultFactory: Invalid Amount");
        emit setterForUint("Optfactory",address(this),controllerFee,_amount ,block.number,block.timestamp);
        controllerFee = _amount;
    }

    /**
        @dev this function used to set Multiplier address
        @param pid Give the pId
        @param _number Give the number
     */

    function setMultiplier(uint256 pid, uint32[] memory _number)
        external
        _isAdmin
    {
        emit OptMultiplier("optfactory",pid, _number,block.number,block.timestamp);
        poolInfo[pid].multiplier = _number;
    }

/**
@dev this function updates status of pool token
 */

    function changeStatus(address _token)
        external
        _isAdmin
    {
        uint256 id = PIDsOfRewardVault[_token];
        if (poolInfo[id].status) {
            poolInfo[id].status = false;
        } else {
            poolInfo[id].status = true;
        }

    }
    function deposit(address user,address _token,uint32 _level,uint256 _amount)
         external 
        isActive(PIDsOfRewardVault[_token])
    {   
        require(
            _amount >=
                 userInfo[PIDsOfRewardVault[_token]][user].amount,
            "OptVaultFactory: Invalid Amount"
        );
        if (IPhoenixNft(IAdmin(Admin).PhoenixNFT()).balanceOf(user) > 0) {
            userInfo[PIDsOfRewardVault[_token]][user]
                .phoenixNFTStatus = true;
        }
        
        if (
            userInfo[PIDsOfRewardVault[_token]][user].NFT == nftStatus(0)
        ) { 
            IOpt1155(IAdmin(Admin).Opt1155()).mint(user, PIDsOfRewardVault[_token], 1);
            userInfo[PIDsOfRewardVault[_token]][user].NFT = nftStatus(1);
        }
        IOptVault(poolInfo[PIDsOfRewardVault[_token]].vault).deposit(user,_amount,_level);
        userInfo[PIDsOfRewardVault[_token]][user].time = block.timestamp;
        userInfo[PIDsOfRewardVault[_token]][user].amount += _amount;
        emit OptDeposit("Optfactory", address(this),user,_amount,_level ,block.number,block.timestamp);
        
    }

    function withdraw(address user,address _token,bool isReceipt,uint _recieptAmount, address sendTo)  external  {
        require(
            userInfo[PIDsOfRewardVault[_token]][user].NFT == nftStatus(1),
            "OptVault : Cannot find any deposit from this account"
        );
        IOptVault(poolInfo[PIDsOfRewardVault[_token]].vault).withdraw(user, isReceipt, _recieptAmount, sendTo);
        IOpt1155(IAdmin(Admin).Opt1155()).burn(user, PIDsOfRewardVault[_token], 1);
        userInfo[PIDsOfRewardVault[_token]][user].NFT = nftStatus(0);
        emit Optwithdraw("OptFactory",address(this),user,_recieptAmount ,block.number,block.timestamp);
    }

    /**
    @dev this function calculates APR , only called by Admin
     */
    function calculateAPR() nonReentrant external _isAdmin {
        require(
            liqStatusValue == LiqStatus.SWAP_WANT_TO_BUSD,
            "OptVault: Initialize your OptVault first"
        );
        BUSDCollected = 0;
        for (uint256 id = 0; id < poolInfo.length; id++) {
            if (poolInfo[id].status) {
                emit CalculateAPR((poolInfo[id].vault),IERC20(IAdmin(Admin).BUSD()).balanceOf(poolInfo[id].vault),block.number,block.timestamp);
                IOptVault(poolInfo[id].vault).swapWantToBUSD();
                BUSDCollected += IERC20(IAdmin(Admin).BUSD()).balanceOf(poolInfo[id].vault);
                emit BUSDcollected(BUSDCollected,block.number,block.timestamp);
            }
        }
        liqStatusValue = LiqStatus.CONTROLLER_FEE;
    }

    /**
    @dev calculating the controllerFee is only called by Admin
     */

    function calculateControllerFee() nonReentrant external _isAdmin {
        require(
            liqStatusValue == LiqStatus.CONTROLLER_FEE,
            "OptVault: Swap want to BUSD first"
        );
        for (uint256 id = 0; id < poolInfo.length; id++) {
            if (poolInfo[id].status) {
                uint256 amount = ((controllerFee) *
                    (IERC20(IAdmin(Admin).BUSD()).balanceOf(poolInfo[id].vault))) / BUSDCollected;
                
                IOptVault(poolInfo[id].vault).deductControllerFee(amount);
                emit ControllerFee((poolInfo[id].vault),amount,block.number,block.timestamp);
            }
        }
        liqStatusValue = LiqStatus.OPTIMIZATION_TAX;
    }

    function optimization() external _isAdmin {
        require(
            liqStatusValue == LiqStatus.OPTIMIZATION_TAX,
            "OptVault: Pay controller fee first"
        );
        for (uint256 id = 0; id < poolInfo.length; id++) {
            if (poolInfo[id].status) {
                IReceipt(IAdmin(Admin).USDy()).mint(Admin.temporaryHolding(), IERC20(IAdmin(Admin).BUSD()).balanceOf(poolInfo[id].vault));
                IOptVault(poolInfo[id].vault).collectOptimizationTax();
            }
        }
        liqStatusValue = LiqStatus.SWAP_WANT_TO_BUSD;

    }

    function optimizationRewards(address user,address _token)
       nonReentrant  external
    {   
        uint256 id = PIDsOfRewardVault[_token];
        if(msg.sender == user){
            user = msg.sender;
        }
        if (
            poolInfo[id].status &&
            block.timestamp <= userInfo[id][user].time + 30 days &&
            userInfo[id][user].phoenixNFTStatus
        ) {
            uint256 modulus = (block.timestamp -
                userInfo[id][user].time) / epochTime;
            IOptVault(poolInfo[id].vault).optimizationReward(user,
                ((poolInfo[id].multiplier[(IOptVault(poolInfo[id].vault).UserLevel(user))-1] +
                    ((poolInfo[id].multiplier[(IOptVault(poolInfo[id].vault).UserLevel(user))-1]) * 25) /
                    100) * (80**modulus)) / (100**modulus)
                );   
        } else {
            if (
                poolInfo[id].status &&
                block.timestamp <= userInfo[id][user].time + 30 days
            ) {
                uint256 modulus = (block.timestamp -
                    userInfo[id][user].time) / epochTime;

                         IOptVault(poolInfo[id].vault).optimizationReward(user,
                ((poolInfo[id].multiplier[(IOptVault(poolInfo[id].vault).UserLevel(user))-1] +
                    ((poolInfo[id].multiplier[(IOptVault(poolInfo[id].vault).UserLevel(user))-1]) * 25) /
                    100) * (80**modulus)) / (100**modulus)
            );
            } else {
                if (
                    poolInfo[id].status &&
                    block.timestamp > userInfo[id][user].time + 30 days
                ) {
                    uint256 modulus = (block.timestamp -
                        userInfo[id][user].time) / epochTime;
                    // uint256 epochLimit = 3 * 30;
                                 IOptVault(poolInfo[id].vault).optimizationReward(user,
                                                ((poolInfo[id].multiplier[(IOptVault(poolInfo[id].vault).UserLevel(user))-1] +
                                                        ((poolInfo[id].multiplier[(IOptVault(poolInfo[id].vault).UserLevel(user))-1]) * 25) /
                                                                100) * (80**modulus)) / (100**modulus)
                                                 );
                                 IOptVault(poolInfo[id].vault).optimizationReward(user,
                                            (100 * (80**(modulus - 90))) / (100**(modulus - 90))
                                                );
                            
                }
            }
        }

    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded , bytes memory performData) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;
            this.calculateAPR();
            this.calculateControllerFee();
            this.optimization();
        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }

    function getPoolInfo(uint index) public view returns(address vaultAddress, bool isLP, address recieptInstance, IERC20 token,bool isCustomVault){
        return (poolInfo[index].vault, poolInfo[index].isLp, poolInfo[index].recieptInstance,poolInfo[index].token, poolInfo[index].isCustomVault);  
    }
    
    /**
    @dev check if passing address is contract or not

    @param _addr is the address to check 
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KeeperBase.sol";
import "./interfaces/KeeperCompatibleInterface.sol";

abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/IAccessControl.sol";
interface IAdmin is IAccessControl{
    function admin() external returns(address);
    function operator() external returns(address);
    function Trigger() external returns(address);
    function POL() external  view returns(address);
    function Treasury() external view returns(address);
    function BShareBUSDVault() external returns(address);
    function bYSLVault() external returns(address);
    function USDyBUSDVault() external returns(address);
    function USDyVault() external returns(address);
    function xYSLBUSDVault() external returns(address);
    function xYSLVault() external returns(address);
    function YSLBUSDVault() external returns(address);
    function YSLVault() external returns(address);
    function BShare() external returns(address);
    function bYSL() external returns(address);
    function USDs() external returns(address);
    function USDy() external returns(address);
    function YSL() external returns(address);
    function xYSL() external returns(address);
    function xYSLS() external returns(address);
    function YSLS() external returns(address);
    function swapPage() external returns(address);
    function PhoenixNFT() external returns(address);
    function Opt1155() external returns(address);
    function EarlyAccess() external returns(address);
    function LPSwap() external returns(address);
    function optVaultFactory() external returns(address);
    function ReceiptSwap() external returns(address);
    function swap() external returns(address);
    function temporaryHolding() external returns(address);
    function tokenSwap() external returns(address);
    function vaultSwap() external returns(address);
    function whitelist() external returns(address);
    function Blacklist() external returns(address);
    function BUSD() external view returns(address);
    function WBNB() external returns(address);
    function BShareVault() external returns(address);
    function masterNTT() external returns (address);
    function biswapRouter() external returns (address);
    function ApeswapRouter() external returns (address);
    function pancakeRouter() external returns (address);
    function TeamAddress() external returns (address);
    function MasterChef() external returns (address);
    function Refferal() external returns (address);
    function liquidityProvider() external returns(address);
    function temporaryReferral() external returns(address);
    function initialize(address owner) external;
    function setRefferal(address _refferal)  external;
    function setWBNB(address _WBNB) external;
    function setBUSD(address _BUSD) external;
    function setLiquidityProvider(address _liquidityProvider) external;
    function setWhitelist(address _whitelist) external;
    function setBlacklist(address _blacklist) external;
    function setVaultSwap(address _vaultSwap) external;
    function setTokenSwap(address _tokenSwap) external;
    function setTemporaryHolding(address _temporaryHolding) external;
    function setSwap(address _swap) external;
    function setReceiptSwap(address _ReceiptSwap) external;
    function setOptVaultFactory(address _optVaultFactory) external;
    function setLPSwap(address _LPSwap) external;
    function setEarlyAccess(address _EarlyAccess) external;
    function setOpt1155(address _Opt1155) external;
    function setPhoenixNFT(address _PhoenixNFT) external;
    function setSwapPage(address _swapPage) external;
    function setYSL(address _YSL) external;
    function setYSLS(address _YSLS) external;
    function setxYSLs(address _xYSLS) external;
    function setxYSL(address _xYSL) external;
    function setUSDy(address _USDy) external;
    function setUSDs(address _USDs) external;
    function setbYSL(address _bYSL) external;
    function setBShare(address _BShare) external;
    function setYSLVault(address _YSLVault) external;
    function setYSLBUSDVault(address _YSLBUSDVault) external;
    function setxYSLVault(address _xYSLVault) external;
    function setxYSLBUSDVault(address _xYSLBUSDVault) external;
    function setUSDyVault(address _USDyVault) external;
    function setUSDyBUSDVault(address _USDyBUSDVault) external;
    function setbYSLVault(address _bYSLVault) external;
    function setBShareBUSD(address _BShareBUSD) external;
    function setPOL(address setPOL) external;
    function setBShareVault(address _BShareVault) external;
    function setTrigger(address _Trigger) external;
    function setmasterNTT(address _masterntt) external;
    function setbiswapRouter(address _biswapRouter)external;
    function setApeswapRouter(address _ApeswapRouter)external;
    function setpancakeRouter(address _pancakeRouter)external;
    function setTeamAddress(address _TeamAddress)external;
    function setMasterChef(address _MasterChef)external;
    function setTemporaryReferral(address _temporaryReferral)external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IOptVault {
    function initialize(uint256 _id,  address _token, address _want, address _Admin) external;
    function setMultiplierLevel(uint32 _level,uint32 amount) external returns(uint32);
    function vaultToken() external view returns(address);
    function swapWantToBUSD() external;
    function UserLevel(address _user) external returns(uint);
    function setreciept(address _reciept) external;
    function optimizationReward(address user, uint optMultiplier) external;
    function deductControllerFee(uint fee) external;
    function purchase(address user,uint amount, uint minAmount) external returns(uint);
    function sell(address user,uint amount, uint minAmount) external returns(uint);
    function collectOptimizationTax() external;
    function deposit(address user,uint amount,uint32 _level) external;
    function withdraw(address user, bool isReciept, uint _amount, address sendTo) external;
    function setPoolDetails(address _smartChef, address _wantToken) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
interface ISingleVault {
    function initialize(
        address _admin,
        address owner
    ) external;
    function deposit(address user,uint256 _amount,uint32 level) external;
    function withdraw(address user,bool isReciept,uint256 amount,address sendTo) external ;
    function receiptToken() external view returns(address);
    function tradeTax() external view returns(uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
 interface ILPVault {
    function initialize(
        address _admin,
        address owner,
        address _lp
    ) external;
    function deposit(address user, uint amountLp,uint32 level) external;
    function withdraw(address user, bool isReciept,uint _amount,address sendTo) external;
    function receiptToken() external view returns(address);
    function purchase(address user, uint amount, uint minAmount) external returns(uint);
    function sell(address user, uint amount, uint minAmount) external returns(uint);
 }

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IReceipt {
    function mint(address account, uint amount) external;
    function burn(address account, uint amount) external;
    function setMinter(address _operator) external;
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function initialize(address _admin, address operator, string memory name_, string memory symbol_) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IEvents{
    event Deposit(string Vault,address receiver,address user,uint amount, uint blocknumber,uint blockTimestamp);
    event Withdraw(string Vault,address receiver,address user,uint amount,uint blocknumber,uint blockTimestamp);
    event purchaseORsell(string Vault,address user,uint amount,uint blocknumber,uint blockTimestamp);
    event OptDeposit(string Vault,address receiver,address user,uint amount,uint32 level,uint blocknumber,uint blockTimestamp);
    event Optwithdraw(string Vault,address receiver,address user,uint amount,uint blocknumber,uint blockTimestamp);
    event OptAdd(address token, bool isLptoken, bool isAuto, address smartchef,address strat,address instance,uint blocknumber,uint blockTimestamp);
    event OptAddCustomVaults(address token,address vault,uint blocknumber,uint blockTimestamp);
    event CalculateAPR(address vault, uint value,uint blocknumber,uint blockTimestamp);
    event BUSDcollected(uint busdCollected,uint blocknumber,uint blockTimestamp);
    event ControllerFee(address vault,uint amount,uint blocknumber,uint blockTimestamp);
    event OptimizationRewards(address optvault, address user, uint reward,uint blocknumber,uint blockTimestamp);
    event LottoDeposit(string Vault,address user, uint amount,uint blocknumber,uint blockTimestamp);
    event setterForUint(string contractName,address contractAddress,uint previousValue, uint currentValue,uint blocknumber,uint blockTimestamp);
    event setterForAddress(string contractName,address contractAddress,address previousAddress, address currentAddress,uint blocknumber,uint blockTimestamp);
    event setterForRefferer(string contractName,address contractAddress,address previousRefferAddress,address RefferAddress, address UserAddress,uint blocknumber,uint blockTimestamp);
    event TaxAllocation(string contractName,address contractAddress,uint previousTax,uint currentTax, uint[] perviousAllocationTax,uint[] currentAllocationTax,uint blocknumber,uint blockTimestamp);
    event setterForMultiplierLevel(string contractName,address contractAddress,uint level,uint multiplierLevel,uint amount, uint blocknumber,uint blockTimestamp);
    event OptMultiplier(string contractName, uint pid, uint32[] number,uint blocknumber,uint blockTimestamp);
    event OptMultiplierLevel(string contractName, address token, uint32[] multiplier,uint32[] deductionValue,uint blocknumber,uint blockTimestamp);
    event setterForOptimizationTaxFee(string contractName,address contractAddress,uint[3] previousArray,uint[3] currentArray,uint blocknumber,uint blockTimestamp);
    event BiddingNFT(string contractName,address user, uint amount,uint totalAmount,uint blocknumber,uint blockTimestamp);
    event claimBID(string contractName, address user, uint wonAddress, uint totalAmount,uint blocknumber,uint blockTimestamp);
    event EndAuction(string contractName, bool rank, address TopofAuction,uint tokenId,uint blocknumber,uint blockTimestamp);
    event resetNewAuction(string contractName, uint highestbid, address winnerofTokenID,uint biddingArray,uint blocknumber,uint blockTimestamp);
    event Buy(string contractName, uint counter,uint lockPeriod,uint blocknumber,uint blockTimestamp);
    event ReactivateNFT(string contractName, address user,uint userTokenID,uint blocknumber,uint blockTimestamp);
    event RewardDistribute(string contractName,address user, uint reward,uint TotalRewardPercentage,address UserRefferer, uint Leftamount,uint blocknumber,uint blockTimestamp);
    event rewardpercentage(string contractName, address user, uint128[3] amount,uint blocknumber,uint blockTimestamp);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
interface IPhoenixNft is IERC721{

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IOpt1155 {
    function createNFTForVault(uint256 Id,string memory name) external;
    function mint(address to, uint256 Id, uint256 amount) external;
    function burn(address from,uint256 Id, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easilly be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
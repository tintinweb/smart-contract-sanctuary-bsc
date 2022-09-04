// SPDX-License-Identifier: none

import "./library/addressChecker.sol";
import "./library/ReentrancyGuard.sol";
import "./library/SafeBEP20.sol";
import "./interface/IWrapper.sol";
import "./interface/IHobbitPirateFarmFactory.sol";
import "./abstract/Context.sol";
import "./abstract/Initializable.sol";

pragma solidity ^0.8.0;

contract HobbitPirateFarm is Initializable, Context, ReentrancyGuard{
    using addressChecker for address;
    using Address for address;
    using SafeBEP20 for IBEP20;

    event CreatedPool(
        uint256 indexed timeCreate,
        uint256 indexed poolId,
        farmPoolOption indexed poolDetail
    );

    event EditedPool(
        uint256 indexed timeEdited,
        uint256 indexed poolId,
        farmPoolOption indexed poolDetail
    );

    event ChangedEqualityValue(
        uint256 indexed timeChanged,
        uint256 indexed equal1,
        uint256 indexed equal2
    );

    event AddedReward(
        uint256 indexed timeAdded,
        uint256 indexed amountPool
    );

    event RemovedReward(
        uint256 indexed timeAdded,
        uint256 indexed amountPool
    );

    event UserFarmIn(
        uint256 indexed timeJoin,
        address indexed user,
        userDetail indexed userInfo
    );

    event UserRewardClaimed(
        uint256 indexed timeClaim,
        address indexed user,
        uint256 indexed amountClaim
    );
    
    event UserStoppedFarm(
        uint256 indexed timeStopped,
        address indexed user
    );

    event UserFarmOut(
        uint256 indexed timeQuit,
        address indexed user,
        uint256 indexed amountOut
    );

    mapping (uint256 => farmPoolOption) private pools;
    mapping (address => userDetail) private userData;

    uint256 public totalPool;
    address public wrapper;
    address public factory;
    address public deposit;
    address public reward;
    farmPool public poolInfo;

    struct farmPoolOption{
        uint256 longTime;
        uint256 apyPercent;
        uint256 apyDiver;
    }

    struct farmPool{
        uint256 equal1;
        uint256 equal2;
        uint256 rewardSupply;
        uint256 rewardLocked;
    }

    struct userDetail{
        bool isActive;
        uint256 selectedPool;
        uint256 deposited;
        uint256 farmStart;
        uint256 farmEnd;
        uint256 farmLastClaim;
        uint256 allocated;
        uint256 rewardPerSecond;
    }

    receive() external payable{
        require(
            _msgSender() == wrapper,
            "HobbitPirateNFTStake : Only accept from wrapper"
        );
    }

    function _initialize(
        address depo,
        address income,
        address wrap
    ) initializer public {
        deposit = depo;
        reward = income;
        wrapper = wrap;
        factory = _msgSender();

        poolInfo.equal1 = 10**IBEP20(depo).decimals();
        poolInfo.equal2 = 10**IBEP20(income).decimals();
    }

    modifier onlyOwner(){
        require(
            _msgSender() == IHobbitPirateFarmFactory(factory).owner(),
            "HobbitPirateFarm : You are not owner!"
        );
        _;
    }

    modifier WhenNonfarm(){
        require(
            deposit != reward,
            "HobbitPirateFarm : Farm in Stake Mode!"
        );
        _;
    }

    modifier rewardFilled() {
        require(
            poolInfo.equal1 > 0 &&
            poolInfo.equal2 > 0 &&
            (poolInfo.rewardSupply - poolInfo.rewardLocked) > 0 ,
            "HobbitPirateFarm : Insufficient Reward!"
        );
        _;
    }

    function createPool(
        uint256 duration,
        uint256 apyFraction1,
        uint256 apyFraction2
    ) external virtual onlyOwner nonReentrant{
        pools[totalPool] = farmPoolOption(
            duration,
            apyFraction1,
            apyFraction2
        );

        totalPool += 1;

        emit CreatedPool(
            block.timestamp,
            (totalPool - 1),
            farmPoolOption(
                duration,
                apyFraction1,
                apyFraction2
            )
        );
    }

    function editPool(
        uint256 poolId,
        uint256 duration,
        uint256 apyFraction1,
        uint256 apyFraction2
    ) external virtual onlyOwner nonReentrant{
        require(
            poolId < totalPool,
            "HobbitPirateFarm : This pool is not available!"
        );

        pools[poolId] = farmPoolOption(
            duration,
            apyFraction1,
            apyFraction2
        );

        emit EditedPool(
            block.timestamp,
            poolId,
            farmPoolOption(
                duration,
                apyFraction1,
                apyFraction2
            )
        );
    }

    function editEqualityValue(
        uint256 newReward
    ) external virtual WhenNonfarm onlyOwner nonReentrant{
        poolInfo.equal2 = newReward;

        emit ChangedEqualityValue(
            block.timestamp,
            poolInfo.equal1,
            newReward
        );
    }

    function addReward(
        uint256 amountPool
    ) external payable virtual onlyOwner nonReentrant{
        if(reward == wrapper && msg.value > 0){
            require(
                msg.value == amountPool,
                "HobbitPirateFarm : Insufficient value for this transaction!"
            );
            IWrapper(wrapper).deposit{
                value: amountPool
            }();
        }else{
            require(
                msg.value == 0,
                "HobbitPirateNFTStake : no need value!"
            );
            require(
                IBEP20(reward).allowance(
                    _msgSender(),
                    address(this)
                ) >= amountPool,
                "HobbitPirateFarm : Insufficient allocation for this transaction!"
            );
            IBEP20(reward).safeTransferFrom(
                _msgSender(),
                address(this),
                amountPool
            );
        }

        unchecked{
            poolInfo.rewardSupply = poolInfo.rewardSupply + amountPool;
        }

        emit AddedReward(
            block.timestamp,
            amountPool
        );
    }

    function removeReward(
        uint256 amountPool
    ) external virtual onlyOwner nonReentrant{
        unchecked{
            uint256 available = poolInfo.rewardSupply - poolInfo.rewardLocked;

            require(
                available >= amountPool,
                "HobbitPirateFarm : Pool reward has beed exceed!"
            );

            poolInfo.rewardSupply = poolInfo.rewardSupply - amountPool;
        }

        if(reward == wrapper){
            IWrapper(reward).withdraw(amountPool);
            payable(_msgSender()).transfer(amountPool);
        }else{
            IBEP20(reward).safeTransfer(
                _msgSender(),
                amountPool
            );
        }

        emit RemovedReward(
            block.timestamp,
            amountPool
        );
    }

    function userWantfarmIn(
        uint256 selectedPool,
        uint256 amountfarm
    ) external payable virtual nonReentrant{
        require(
            !userDataInfo(_msgSender()).isActive,
            "HobbitPirateFarm : You already have actived farm!"
        );
        require(
            userDataInfo(_msgSender()).deposited == 0,
            "HobbitPirateFarm : Farm Out first before re-farm!"
        );
        require(
            userClaimableReward(_msgSender()) == 0,
            "HobbitPirateFarm : Claim all reward before re-farm!"
        );
        require(
            selectedPool < totalPool,
            "HobbitPirateFarm : This pool is not available!"
        );
        require(
            poolInfo.rewardLocked + rewardCalculator(
                selectedPool,
                amountfarm
            ) <= poolInfo.rewardSupply,
            "HobbitPirateFarm : Insufficient reward!"
        );

        if(deposit == wrapper && msg.value > 0){
            require(
                msg.value == amountfarm,
                "HobbitPirateFarm : Insufficient value for this transaction!"
            );
            IWrapper(wrapper).deposit{
                value: amountfarm
            }();
        }else{
            require(
                msg.value == 0,
                "HobbitPirateNFTStake : no need value!"
            );
            require(
                IBEP20(deposit).allowance(
                    _msgSender(),
                    address(this)
                ) >= amountfarm,
                "HobbitPirateFarm : Insufficient allocation for this transaction!"
            );
            IBEP20(deposit).safeTransferFrom(
                _msgSender(),
                address(this),
                amountfarm
            );
        }

        userData[_msgSender()] = userDetail(
            true,
            selectedPool,
            amountfarm,
            block.timestamp,
            (block.timestamp + (poolOptionByIndex(
                selectedPool
            ).longTime)),
            block.timestamp,
            rewardCalculator(
                selectedPool,
                amountfarm
            ),
            _rewardPerSecondCalculator(
                selectedPool,
                amountfarm
            )
        );

        poolInfo.rewardLocked = poolInfo.rewardLocked + rewardCalculator(
            selectedPool,
            amountfarm
        );

        emit UserFarmIn(
            block.timestamp,
            _msgSender(),
            userDetail(
                true,
                selectedPool,
                amountfarm,
                block.timestamp,
                (block.timestamp + (poolOptionByIndex(
                    selectedPool
                ).longTime)),
                block.timestamp,
                rewardCalculator(
                    selectedPool,
                    amountfarm
                ),
                _rewardPerSecondCalculator(
                    selectedPool,
                    amountfarm
                )
            )
        );
    }

    function userWantClaim() external virtual nonReentrant{
        require(
            userDataInfo(_msgSender()).isActive,
            "HobbitPirateFarm : You do not have active farm yet!"
        );
        require(
            userDataInfo(_msgSender()).deposited > 0,
            "HobbitPirateFarm : You already have farm out!"
        );
        require(
            userClaimableReward(_msgSender()) > 0,
            "HobbitPirateFarm : You do not have any reward!"
        );

        uint256 tempClaimReward = userClaimableReward(_msgSender());

        userData[_msgSender()].farmLastClaim = block.timestamp;
        userData[_msgSender()].allocated = userData[_msgSender()].allocated - tempClaimReward;
        poolInfo.rewardSupply = poolInfo.rewardSupply - tempClaimReward;
        poolInfo.rewardLocked = poolInfo.rewardLocked - tempClaimReward;

        if(reward == wrapper){
            IWrapper(wrapper).withdraw(tempClaimReward);
            payable(_msgSender()).transfer(tempClaimReward);
        }else{
            IBEP20(reward).safeTransfer(
                _msgSender(),
                tempClaimReward
            );
        }

        emit UserRewardClaimed(
            block.timestamp,
            _msgSender(),
            tempClaimReward
        );
    }
    
    function userWantStopfarm() external virtual nonReentrant{
        require(
            userDataInfo(_msgSender()).isActive,
            "HobbitPirateFarm : You do not have active farm yet!"
        );
        require(
            block.timestamp < userDataInfo(_msgSender()).farmEnd,
            "HobbitPirateFarm : This action is not needed again!"
        );
        require(
            userDataInfo(_msgSender()).deposited > 0,
            "HobbitPirateFarm : You already have farm out!"
        );

        uint256 unclaimedDistance = block.timestamp - (
            userData[_msgSender()].farmLastClaim
        );
        uint256 deallocatedReward = userData[_msgSender()].rewardPerSecond * (
            unclaimedDistance
        );
        uint256 freeAllocation = userData[_msgSender()].allocated - (
            deallocatedReward
        );

        userData[_msgSender()].allocated = deallocatedReward;
        poolInfo.rewardLocked = poolInfo.rewardLocked - freeAllocation;

        userData[_msgSender()].farmEnd = block.timestamp;

        emit UserStoppedFarm(
            block.timestamp,
            _msgSender()
        );
    }

    function userWantfarmOut() external virtual nonReentrant{
        require(
            userDataInfo(_msgSender()).isActive,
            "HobbitPirateFarm : You do not have active farm yet!"
        );
        require(
            block.timestamp > userDataInfo(_msgSender()).farmEnd,
            "HobbitPirateFarm : You cant farm out before ended or stopped!"
        );
        require(
            userDataInfo(_msgSender()).deposited > 0,
            "HobbitPirateFarm : You already have farm out!"
        );
        require(
            userClaimableReward(_msgSender()) == 0,
            "HobbitPirateFarm : Claim all reward before farm out!"
        );

        uint256 tempAmount = userData[_msgSender()].deposited;
        userData[_msgSender()].isActive = false;
        
        if(deposit == wrapper){
            IWrapper(wrapper).withdraw(userData[_msgSender()].deposited);
            payable(_msgSender()).transfer(userData[_msgSender()].deposited);
        }else{
            IBEP20(deposit).safeTransfer(
                _msgSender(),
                userData[_msgSender()].deposited
            );
        }

        userData[_msgSender()].deposited = 0;
        
        emit UserFarmOut(
            block.timestamp,
            _msgSender(),
            tempAmount
        );
    }

    function poolOptionByIndex(
        uint256 index
    ) public view returns(farmPoolOption memory){
        return pools[index];
    }

    function userDataInfo(
        address user
    ) public view returns(userDetail memory){
        return userData[user];
    }

    function userClaimableReward(
        address user
    ) public view returns(uint256){
        unchecked{
            uint256 result;

            if(userDataInfo(user).farmLastClaim < userDataInfo(user).farmEnd){
                uint256 tempStart = userDataInfo(
                    user
                ).farmLastClaim;
                uint256 tempEnd;

                if(block.timestamp < userDataInfo(user).farmEnd){
                    tempEnd = block.timestamp;
                }else{
                    tempEnd = userDataInfo(
                        user
                    ).farmEnd;
                }

                uint256 tempDistance = tempEnd - (tempStart);
                result = userDataInfo(user).rewardPerSecond * (tempDistance);
            }

            return result;
        }
    }

    function rewardCalculator(
        uint256 selectedPool,
        uint256 amountfarm
    ) public view returns (uint256){
        unchecked{
            require(
                selectedPool < totalPool,
                "HobbitPirateFarm : This pool is not available!"
            );

            uint256 rewardPerSecond = _rewardPerSecondCalculator(
                selectedPool,
                amountfarm
            );

            require(
                rewardPerSecond > 0,
                "HobbitPirateFarm : Zero reward calculated is disallowed!"
            );

            uint256 tempReward = rewardPerSecond * poolOptionByIndex(
                selectedPool
            ).longTime;

            return tempReward;
        }
    }

    function _rewardPerSecondCalculator(
        uint256 selectedPool,
        uint256 amountfarm
    ) private view returns(uint256){
        unchecked{
            uint256 tempEqual = amountfarm * poolInfo.equal2;
            tempEqual = tempEqual / (10 ** IBEP20(reward).decimals());

            uint256 tempReward = tempEqual * poolOptionByIndex(
                selectedPool
            ).apyPercent;
            tempReward = tempReward / poolOptionByIndex(
                selectedPool
            ).apyDiver;
            tempReward = tempReward / 100;
            tempReward = tempReward / 31536000;

            return tempReward;
        }
    }
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

import "../interface/IBEP20.sol";
import "../interface/ILiquidity.sol";
import "../interface/IERC721Metadata.sol";

import "./ERC165Checker.sol";

library addressChecker{
    using ERC165Checker for address;

    function isBEP20(
        address target
    ) internal view returns(bool) {
        return _tryIsBEP20(target);
    }

    function isLiquidity(
        address target
    ) internal view returns(bool) {
        return _tryIsLiquidity(target);
    }

    function isERC721(
        address target
    ) internal view returns(bool) {
        bytes4 erc721interface = type(IERC721Metadata).interfaceId;
        
        return target.supportsInterface(erc721interface);
    }

    function _tryIsBEP20(
        address target
    ) private view returns(bool) {
        try IBEP20(target).decimals() returns(uint8 decimals) {
            return decimals > 0;
        }catch{
            return false;
        }
    }

    function _tryIsLiquidity(
        address target
    ) private view returns(bool) {
        address tempToken0;
        address tempToken1;

        try ILiquidity(target).token0() returns(address token0) {
            tempToken0 = token0;
        }catch{
            return false;
        }

        try ILiquidity(target).token1() returns(address token1) {
            tempToken1 = token1;
        }catch{
            return false;
        }

        return (tempToken0 != address(0) && tempToken1 != address(0));
    }
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import "../interface/IBEP20.sol";
import "./Address.sol";

library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
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

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface IWrapper{
    function totalSupply() external view returns (uint);
    
    function balanceOf(
        address account
    ) external view returns (uint256);
    
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    
    function deposit() external payable;
    
    function withdraw(
        uint256 amount
    ) external;

    function approve(
        address spender,
        uint256 amount
    ) external;
    
    function transfer(
        address destination,
        uint256 amount
    ) external;
    
    function transferFrom(
        address owner,
        address destination,
        uint256 amount
    ) external;
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface IHobbitPirateFarmFactory {
  function createFarmPair(address depo, address reward) external;
  function getTotalPair() external view returns(uint256);
  function getAllLpFarmPair() external view returns(address[] memory);
  function getAllLpStakePair() external view returns(address[] memory);
  function getAllTokenFarmPair() external view returns(address[] memory);
  function getAllTokenStakePair() external view returns(address[] memory);
  function getPair(address depo, address reward) external view returns(address);
  function owner() external view returns(address);
  function renounceOwnership() external;
  function transferOwnership(address newOwner) external;
  function wrapper() external view returns(address);
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../library/Address.sol";

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
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
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

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(
        address account
    ) external view returns (uint256);
    function burn(
        uint256 amount
    ) external returns (bool);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);
    function approve(
        address spender,
        uint256 amount
    ) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface ILiquidity {
    //usage to checking liquidity is have token0 and token1 (Fork uniswap like Pancake, Biswap, etc with similar function)

    function token0() external view returns (address);
    function token1() external view returns (address);
}

// SPDX-License-Identifier: none

import "./IERC721.sol";

pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "../interface/IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            supportsERC165InterfaceUnchecked(account, type(IERC165).interfaceId) &&
            !supportsERC165InterfaceUnchecked(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && supportsERC165InterfaceUnchecked(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = supportsERC165InterfaceUnchecked(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!supportsERC165InterfaceUnchecked(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}

// SPDX-License-Identifier: none

import "./IERC165.sol";

pragma solidity ^0.8.0;

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: none

pragma solidity ^0.8.1;

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./interface/ILUUINE.sol";

contract LUUINE is ILUUINE{
    address public USDTAddress;
    address public TokenAddress;
    mapping (address => AssetStruct[]) private _userAssets;
    mapping(address => RechargeStruct[]) private _userRecharge;
    mapping(address => UserRebateStruct[]) private _userRebate;
    mapping(address => address) public userReferer;
    mapping(address => address[]) private userTeam;
    mapping(address => UserTeamStruct[]) public _userTeam;
    mapping(address => uint256) public userRecharge;
    mapping(address => uint256) private userWithdraw;
    mapping(address => uint256) public userLevel;
    mapping(address => uint256) public userValid;
    mapping(address => uint256) private userStatusValid;
    mapping(address => uint256) public userProfit;
    mapping(bytes => address[]) private userHolder;
    mapping(address => uint256) private userHolders;
    mapping(address => uint256) public userBlack;
    mapping(address => uint256) private userSlip;
    bytes public constant HOLDER_NAME = bytes("hoder"); 
    bytes public constant GOLD_NAME = bytes("gold"); 
    SysConfigStruct private SysConfig;
    RebateStruct[] private _rebateStruct;
    LevelStruct[] private _levelStruct;
    constructor() {
        SysConfig.maxLevel = 31;
        SysConfig.rechargePrice = 1000000000000000000;
        SysConfig.rechargeBei = 300;
        SysConfig.holderPrice = 1000000000000000000;
        SysConfig.holderNum = 2;
        SysConfig.holderPercent = 500;
        SysConfig.withdrawPercent = 600;
        SysConfig.withdrawBei = 3;
        SysConfig.slipNum = 3;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    function demo() public view returns(uint256){
        return block.timestamp%3;
    }

     /**
     * Register
     */
    function register(address owner) public whenNotPaused {
        require(owner != address(0), "Address invalid");
        require(userReferer[_msgSender()] == address(0), "The referer already exists");
        require(owner != _msgSender(),"The superior cannot be himself");
        address curaddr = owner;
        userReferer[_msgSender()] = owner;
        for (uint256 i = 0; i < SysConfig.maxLevel; i++) {
            address parentAddress = userReferer[curaddr];
            if (parentAddress == address(0)) {
                break;
            }
            require(parentAddress != _msgSender(),"Abnormal superior relationship");
            curaddr = parentAddress;
        }
        //滑落
        if(userTeam[owner].length == SysConfig.slipNum && userSlip[owner] != 1){
            userSlip[owner] = 1;
            owner = getOwnerAddress(owner);
            userReferer[_msgSender()] = owner;
        }
        userTeam[owner].push(_msgSender());
        userLevel[_msgSender()] = 0;
        //团队记录
        UserTeamStruct[] storage userTeams = _userTeam[owner];
        userTeams.push(UserTeamStruct(_msgSender(),block.timestamp));
    }
    /**
    * 获取滑落的下级地址
    */
    function getOwnerAddress(address owner) internal view returns(address){
        owner = userTeam[owner][block.timestamp%SysConfig.slipNum];
        if(userTeam[owner].length == SysConfig.slipNum){
            return getOwnerAddress(owner);
        }
        return owner;
    }
    /**
     * @dev Recharge
     */
    function recharge() public whenNotPaused {
        require(userBlack[_msgSender()] != 1, "error");
        //充值usdt
        _getUSDT().transferFrom(_msgSender(), address(this), SysConfig.rechargePrice);
        //赠送代币
        uint256 price = SysConfig.rechargePrice*SysConfig.rechargeBei/100;
        _getToken().transfer(_msgSender(), price);
        userRecharge[_msgSender()] += SysConfig.rechargePrice;
        //统计数据升级使用
        _upgrade(_msgSender());
        //触发返佣
        _profit(_msgSender(), SysConfig.rechargePrice);
        //充值记录
        RechargeStruct[] storage recharges = _userRecharge[_msgSender()];
        recharges.push(RechargeStruct(SysConfig.rechargePrice,block.timestamp));
    }
    /**
     * @dev 创始股东
     */
    function shareHolder() public whenNotPaused {
        require(userHolder[HOLDER_NAME].length<=SysConfig.holderNum,"shareHolder error");
        require(userHolders[_msgSender()] != 1,"shareHolder error");
        //require(userBlack[_msgSender()] != 1, "holder error");
        userHolders[_msgSender()] = 1;
        _getUSDT().transferFrom(_msgSender(), address(this), SysConfig.holderPrice);
        userHolder[HOLDER_NAME].push(_msgSender());
        userRecharge[_msgSender()] += SysConfig.holderPrice;
    }
    /**
     * @dev Withdraw
     */
    function withdraw(uint256 amount) public whenNotPaused {
        require(userBlack[_msgSender()] != 1, "withdraw error");
        uint256 withdrawAmount = amount - amount * SysConfig.withdrawPercent / 10000;
        require(withdrawAmount > 0, "withdraw amount too small");
        require(userRecharge[_msgSender()] > 0, "Not recharged");
        userWithdraw[_msgSender()] += amount;
        uint256 rechargePrice = userRecharge[_msgSender()] * SysConfig.withdrawBei;
        require(userWithdraw[_msgSender()] < rechargePrice, "Withdrawal amount exceeds 3 times");
        //扣费
        _subAsset(_msgSender(), GOLD_NAME, amount);
        //提现
        _getUSDT().transfer(_msgSender(), withdrawAmount);
        _addRebate(_msgSender(),_msgSender(),amount,3,0);
    }

    /**
     * Profit
     */
    function _profit(address owner, uint256 amount) internal returns (bool) {
        address curAddress = owner;
        uint256 curAmount = amount;
        for (uint256 i = 0; i < SysConfig.maxLevel; i++) {
            if (curAmount <= 0) {
                break;
            }
            address parentAddress = userReferer[curAddress];
            if (parentAddress == address(0)) {
                break;
            }
            curAddress = parentAddress;
            uint256 level = 0;
            uint256 ratePer = 0;
            uint256 nums = 0;
            (level,nums) = getLevelsIndex(parentAddress);
            if(nums<=i){
                continue;
            }
            (level,ratePer) = getRebateLevelsIndex(i);
            if (ratePer > 0 && userLevel[parentAddress]>0) {
                uint256 profitAmount = curAmount * ratePer / 10000;
                userProfit[parentAddress] += profitAmount;
                _addAsset(parentAddress, GOLD_NAME, profitAmount);
                _addRebate(parentAddress,owner,profitAmount,1,i+1);
            }
        }
         //创始股东钱
        for(uint256 index=0;index<userHolder[HOLDER_NAME].length;index++){
            address parentAddress = userHolder[HOLDER_NAME][index];
            uint256 profitAmount = curAmount * SysConfig.holderPercent / userHolder[HOLDER_NAME].length / 10000;
            userProfit[parentAddress] += profitAmount;
            _addAsset(parentAddress, GOLD_NAME, profitAmount);
            _addRebate(parentAddress,owner,profitAmount,2,0);
        }
        return true;
    }
    /**
    * 升级统计数据
     */
     function _upgrade(address owner) internal returns(bool){
        address curAddress = owner;
        if(userStatusValid[curAddress] == 1){
            return true;
        }
        userLevel[curAddress] = 1;
        userStatusValid[curAddress] = 1;
        for (uint256 i = 0; i < SysConfig.maxLevel; i++) {
            address parentAddress = userReferer[curAddress];
            if (parentAddress == address(0)) {
                break;
            }
            curAddress = parentAddress;
            userValid[parentAddress] += 1;
         }
         return true;
     }
     /**
     * 返佣记录
      */
      function _addRebate(address owner,address addr,uint256 price,uint256 types,uint256 level) internal{
          UserRebateStruct[] storage rebates = _userRebate[owner];
          uint256 curTime = block.timestamp;
          rebates.push(UserRebateStruct(addr,price,types,level,curTime));
      }
      /**
      * 获取返佣记录
       */
    function getRebateList(address owner) public view returns(UserRebateStruct[] memory){
        return _userRebate[owner];
    }
      /**
      * 获取充值记录
       */
    function getRechargeList(address owner) public view returns(RechargeStruct[] memory){
        return _userRecharge[owner];
    }
     /**
     * Get Distribution Levels index
     */
    function getRebateLevelsIndex(uint256 index) internal view returns (uint256, uint256) {
        if(index < _rebateStruct.length){
            uint256 level = _rebateStruct[index].level;
            uint256 ratePer = _rebateStruct[index].percent;
            return (level,ratePer);
        }
        return (0,0);
    }
    /**
     * Set rebate 比例
     */
    function setRebateRates(RebateStruct memory rebateRebate, bool isRemove) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "error");
        bool isFound = false;
        for (uint256 i = 0; i < _rebateStruct.length; i ++) {
            if (_rebateStruct[i].level == rebateRebate.level) {
                isFound = true;
                if (isRemove) {
                    delete _rebateStruct[i];
                } else {
                    _rebateStruct[i] = rebateRebate;
                }
                break;
            }
        }
        if (!isFound && !isRemove) {
            _rebateStruct.push(rebateRebate);
        }
    }
         /**
     * Get Distribution Levels index
     */
    function getLevelsIndex(address owner) internal view returns (uint256, uint256) {
        uint256 level = 0;
        uint256 nums = 0;
        for (uint256 i = 0; i < _levelStruct.length; i++) {
            if(userTeam[owner].length>=_levelStruct[i].zhiNum){
                level = _levelStruct[i].level;
                nums = _levelStruct[i].nums;
            }
        }
        return (level,nums);
    }
    /**
     * Set 等级层数 
     */
    function setLevelRates(LevelStruct memory levelRebate, bool isRemove) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "error");
        bool isFound = false;
        for (uint256 i = 0; i < _levelStruct.length; i ++) {
            if (_levelStruct[i].level == levelRebate.level) {
                isFound = true;
                if (isRemove) {
                    delete _levelStruct[i];
                } else {
                    _levelStruct[i] = levelRebate;
                }
                break;
            }
        }
        if (!isFound && !isRemove) {
            _levelStruct.push(levelRebate);
        }
    }
    /**
    * 设置参数
     */
     function setConfig(SysConfigStruct memory config) public{
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "error");
        SysConfig = config;
     }
     /**
     * 设置黑名单
      */
      function setBlack(address owner,uint256 status) public{
         userBlack[owner] = status;
      }
      /**
     * @dev Get 直推列表
     */
    function getUserTeam(address owner) public view returns (UserTeamStruct[] memory){
        return _userTeam[owner];
    }
      /**
     * @dev Get 直推信息
     */
    function getUserCount(address owner) public view returns (uint256,uint256,uint256){
        return (userTeam[owner].length,userValid[owner],userHolders[owner]);
    }
    /**
     * Set Token Address
     */
    function setTokenAddress(address token) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "error");
        require(token != address(0), "Token Addrees Invalid");
        TokenAddress = token;
    }
      /**
     * Get Token Contract
     */
    function _getToken() internal view override returns (IERC20) {
        require(TokenAddress != address(0), "Token Addrees Invalid");
        return IERC20(TokenAddress);
    }
    /**
     * Set Token Address
     */
    function setUSDTAddress(address token) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "error");
        require(token != address(0), "Token Addrees Invalid");
        USDTAddress = token;
    }
      /**
     * Get Token Contract
     */
    function _getUSDT() internal view override returns (IERC20) {
        require(USDTAddress != address(0), "USDT Addrees Invalid");
        return IERC20(USDTAddress);
    }
    /**
     * Set 把合约钱包的钱转到对应地址上
     */
    function setTranfer(uint256 price,uint256 types) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "error");
        if(types == 1){
            _getToken().transfer(_msgSender(),price);
        }else{
            _getUSDT().transfer(_msgSender(),price);
        }
    }

     /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "must have pauser role to unpause");
        _unpause();
    }
    
        /**
     * @dev Add Balance
     */
    function _addAsset(address owner, bytes memory assetName, uint256 amount) internal override {
        require(amount > 0, "gold amount too small");

        AssetStruct[] storage assets = _userAssets[owner];
        bool isFound = false;
        for (uint256 i = 0; i < assets.length; i++) {
            if (keccak256(assets[i].name) == keccak256(assetName)) {
                isFound = true;
                assets[i].amount += amount;
            }
        }

        if (!isFound) {
            AssetStruct memory asset = AssetStruct(assetName, amount);
            assets.push(asset);
        }
    }
    /**
     * @dev Sub Balance
     */
    function _subAsset(address owner, bytes memory assetName, uint256 amount) internal override {
        require(amount > 0, "gold amount too small");

        AssetStruct[] storage assets = _userAssets[owner];
        bool isFound = false;
        for (uint256 i = 0; i < assets.length; i++) {
            if (keccak256(assets[i].name) == keccak256(assetName)) {
                isFound = true;
                require(assets[i].amount >= amount, "asset amount exceeds balance");
                unchecked {
                    assets[i].amount -= amount;
                }
            }
        }
        require(isFound, "asset not exist");
    }
    /**
    * 获取我的余额
     */
     function getUserBalance(address owner) public view returns(uint256){
        AssetStruct[] storage assets = _userAssets[owner];
        for (uint256 i = 0; i < assets.length; i++) {
            if (keccak256(assets[i].name) == keccak256(GOLD_NAME)) {
                return assets[i].amount;
            }
        }
        return 0;
     }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../structs/LUUDATA.sol";

abstract contract ILUUINE is AccessControlEnumerable, Pausable,LUUDATA {

    /**
     * Get Token Contract
     */
    function _getUSDT() internal view virtual returns (IERC20);
    /**
     * Get Token Contract
     */
    function _getToken() internal view virtual returns (IERC20);
     /**
     * @dev Decrease Balance
     */
    function _subAsset(address owner, bytes memory name, uint256 amount) internal virtual;

    /**
     * @dev Decrease Balance
     */
    function _addAsset(address owner, bytes memory name, uint256 amount) internal virtual;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract LUUDATA
{
    struct AssetStruct {
        bytes      name;
        uint256    amount;
    }
     struct SysConfigStruct {
        uint256     rechargePrice;
        uint256     rechargeBei;
        uint256     maxLevel;
        uint256     withdrawBei;
        uint256     withdrawPercent;
        uint256     holderPrice;
        uint256     holderNum;
        uint256     holderPercent;
        uint256     slipNum;
    }
    struct RebateStruct{
        uint256  level;
        uint256  percent;
        bool     enable;
    }
    struct LevelStruct{
        uint256  level;
        uint256  zhiNum;
        uint256  nums;
        bool     enable;
    }
    struct UserHolderStruct{
        address owner;
    }
    struct UserTeamStruct{
        address owner;
        uint256 time;
    }
    struct RechargeStruct{
        uint256 price;
        uint256 time;
    }
    struct UserRebateStruct{
        address owner;
        uint256 price;
        uint256 types;
        uint256 level;
        uint256 time;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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
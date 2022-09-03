// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "../interface/I721.sol";

contract MT_Staking is OwnableUpgradeable, ERC721HolderUpgradeable {
    IERC20 public u;
    I721 public nft;

    struct RewardInfo {
        uint normalDebt;
        uint[4] levelDebt;
        uint superDebt;
    }

    struct UserInfo {
        uint stakeAmount;
        uint[] stakeList;
        uint referAmount;
        uint referLevel;
        uint totalReward;
        uint[4] levelDebt;
        uint superDebt;
        uint[12] stakeKind;
        uint toClaim;
        bool isSuperNode;
    }

    struct StakeInfo {
        bool status;
        uint tokenId;
        address owner;
        address invitor;
        uint debt;
        uint stakeTime;
    }

    RewardInfo public rewardInfo;
    uint public totalCard;
    uint[4] levelAmount;
    mapping(address => UserInfo) public userInfo;
    mapping(uint => StakeInfo) public stakeInfo;
    uint public lastU;
    uint public superNodeAmount;
    uint[] normalRate;
    uint[] levelRate;
    uint[] referLevelRate;
    mapping(address => bool) public manager;
    mapping(address => uint) public userAddRefer;
    mapping(address => bool) public isAddSuperNode;

    struct ClaimInfo {
        uint normalClaimed;
        uint levelClaimed;
        uint nodeClaimed;
    }

    mapping(address => ClaimInfo) public claimInfo;

    event Stake(address indexed player, address indexed invitor, uint indexed tokenID);
    event Claim(address indexed player, uint indexed amount);
    event UnStake(address indexed player, uint indexed tokenID);

    function initialize() public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __ERC721Holder_init_unchained();
        levelAmount = [0, 0, 0, 0];
        rewardInfo.levelDebt = [0, 0, 0, 0];
        normalRate = [40, 40, 20];
        levelRate = [10, 20, 30, 40];
        referLevelRate = [10, 15, 20, 30];
        manager[msg.sender] = true;
    }

    modifier onlyEOA(){
        require(msg.sender == tx.origin, 'not allowed');
        _;
    }

    modifier onlyManager(){
        require(manager[msg.sender], 'not manager');
        _;
    }

    modifier countingDebt(){
        uint tempBalance = u.balanceOf(address(this));
        if (tempBalance > lastU) {
            uint rew = tempBalance - lastU;
            if (totalCard > 0) {
                rewardInfo.normalDebt += rew * normalRate[0] / 100 / totalCard;
            }
            uint levelRew = rew * normalRate[1] / 100;
            for (uint i = 0; i < 4; i++) {
                if (levelAmount[i] > 0) {
                    rewardInfo.levelDebt[i] += levelRew * levelRate[i] / 100 / levelAmount[i];
                }
            }
            if (superNodeAmount > 0) {
                rewardInfo.superDebt += rew * normalRate[2] / 100 / superNodeAmount;
            }
        }
        _;
        lastU = u.balanceOf(address(this));
    }

    function setU(address addr) external onlyOwner {
        u = IERC20(addr);
    }

    function setNFT(address addr) external onlyOwner {
        nft = I721(addr);
    }

    function getTempDebt() public view returns (uint _normalDebt, uint[4] memory levelDebt, uint nodeDebt){
        uint tempBalance = u.balanceOf(address(this));
        _normalDebt = rewardInfo.normalDebt;
        levelDebt = rewardInfo.levelDebt;
        nodeDebt = rewardInfo.superDebt;
        if (tempBalance > lastU) {
            uint rew = tempBalance - lastU;
            if (totalCard > 0) {
                _normalDebt += rew * normalRate[0] / 100 / totalCard;
            }
            uint levelRew = rew * normalRate[1] / 100;
            for (uint i = 0; i < 4; i++) {
                if (levelAmount[i] > 0) {
                    levelDebt[i] += levelRew * levelRate[i] / 100 / levelAmount[i];
                }
            }
            if (superNodeAmount > 0) {
                nodeDebt += rew * normalRate[2] / 100 / superNodeAmount;
            }
        }
    }

    function checkUserStakeList(address addr) public view returns (uint[] memory, uint[] memory, uint[] memory){
        uint[] memory temp = userInfo[addr].stakeList;
        uint[] memory cardIdList = new uint[](temp.length);
        uint[] memory stakeTime = new uint[](temp.length);
        for (uint i = 0; i < temp.length; i++) {
            cardIdList[i] = nft.cardIdMap(temp[i]);
            stakeTime[i] = stakeInfo[temp[i]].stakeTime;
        }
        return (userInfo[addr].stakeList, cardIdList, stakeTime);
    }

    function checkUserStakeKind(address addr) public view returns (uint[12] memory){
        return userInfo[addr].stakeKind;
    }

    function getUserLevel(address addr) public view returns (uint){
        uint tempAmount = userInfo[addr].referAmount;
        if (tempAmount >= referLevelRate[3]) {
            return 4;
        } else if (tempAmount >= referLevelRate[2]) {
            return 3;
        } else if (tempAmount >= referLevelRate[1]) {
            return 2;
        } else if (tempAmount >= referLevelRate[0]) {
            return 1;
        } else {
            return 0;
        }
    }

    function setManager(address addr, bool b) external onlyOwner {
        manager[addr] = b;
    }

    function _calculateToken(uint token) internal view returns (uint){
        uint tokenDebt = stakeInfo[token].debt;
        return (rewardInfo.normalDebt - tokenDebt);
    }

    function _calculateNodeRew(address addr) internal view returns (uint){
        uint userDebt = userInfo[addr].superDebt;
        return (rewardInfo.superDebt - userDebt);
    }

    function _calculateLevelRew(address addr, uint level) internal view returns (uint){
        uint userDebt = userInfo[addr].levelDebt[level - 1];
        return (rewardInfo.levelDebt[level - 1] - userDebt);
    }

    function calculateAllReward(address addr) public view returns (uint){
        uint[] memory list = userInfo[addr].stakeList;
        uint rew;
        for (uint i = 0; i < list.length; i++) {
            if (stakeInfo[list[i]].status) {
                rew += _calculateToken(list[i]);
            }
        }
        if (userInfo[addr].referLevel > 0) {
            rew += _calculateLevelRew(addr, userInfo[addr].referLevel);
        }
        if (userInfo[addr].isSuperNode) {
            rew += _calculateNodeRew(addr);
        }
        return rew + userInfo[addr].toClaim;
    }


    function _processReferAmount(address addr, bool isAdd) internal {
        if (isAdd) {
            userInfo[addr].referAmount ++;
            uint oldLevel = userInfo[addr].referLevel;
            uint newLevel = getUserLevel(addr);
            if (newLevel != oldLevel) {
                userInfo[addr].referLevel = newLevel;
                levelAmount[newLevel - 1] ++;
                userInfo[addr].levelDebt[newLevel - 1] = rewardInfo.levelDebt[newLevel - 1];
                if (oldLevel != 0) {
                    levelAmount[oldLevel - 1] --;
                    uint tempReward = _calculateLevelRew(addr, oldLevel);
                    if (tempReward > 0) {
                        claimInfo[addr].levelClaimed += tempReward;
                        userInfo[addr].toClaim += tempReward;
                        userInfo[addr].levelDebt[oldLevel - 1] = rewardInfo.levelDebt[oldLevel - 1];
                    }
                }
            }
        } else {
            userInfo[addr].referAmount --;
            uint oldLevel = userInfo[addr].referLevel;
            uint newLevel = getUserLevel(addr);
            if (newLevel != oldLevel) {
                userInfo[addr].referLevel = newLevel;
                levelAmount[oldLevel - 1] --;
                if (newLevel != 0) {
                    levelAmount[newLevel - 1] ++;
                    userInfo[addr].levelDebt[newLevel - 1] = rewardInfo.levelDebt[newLevel - 1];
                    uint tempReward = _calculateLevelRew(addr, oldLevel);
                    if (tempReward > 0) {
                        claimInfo[addr].levelClaimed += tempReward;
                        userInfo[addr].toClaim += tempReward;
                        userInfo[addr].levelDebt[oldLevel - 1] = rewardInfo.levelDebt[oldLevel - 1];
                    }
                }
            }
        }
    }

    function _checkUserIsNode(address addr) internal view returns (bool){
        for (uint i = 0; i < 12; i++) {
            if (userInfo[addr].stakeKind[i] == 0) {
                return false;
            }
        }
        return true;
    }

    function claimReward() external countingDebt onlyEOA {
        uint[] memory list = userInfo[msg.sender].stakeList;
        uint rew;
        uint temp;
        for (uint i = 0; i < list.length; i++) {
            if (stakeInfo[list[i]].status) {
                temp = _calculateToken(list[i]);
                claimInfo[msg.sender].normalClaimed += temp;
                rew += temp;
                stakeInfo[list[i]].debt = rewardInfo.normalDebt;
            }
        }
        uint level = userInfo[msg.sender].referLevel;
        if (level > 0) {
            temp = _calculateLevelRew(msg.sender, level);
            rew += temp;
            claimInfo[msg.sender].levelClaimed += temp;
            userInfo[msg.sender].levelDebt[level - 1] = rewardInfo.levelDebt[level - 1];
        }
        if (userInfo[msg.sender].isSuperNode) {
            temp = _calculateNodeRew(msg.sender);
            rew += temp;
            claimInfo[msg.sender].nodeClaimed += temp;
            userInfo[msg.sender].superDebt = rewardInfo.superDebt;
        }
        if (userInfo[msg.sender].toClaim > 0) {
            rew += userInfo[msg.sender].toClaim;
            userInfo[msg.sender].toClaim = 0;
        }
        u.transfer(msg.sender, rew);
        userInfo[msg.sender].totalReward += rew;
        emit Claim(msg.sender, rew);
    }

    function stake(address invitor, uint tokenId) external onlyEOA countingDebt {
        require(invitor == address(this) || userInfo[invitor].stakeAmount > 0, 'wrong invitor');
        require(invitor != msg.sender, 'wrong invitor');
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        stakeInfo[tokenId] = StakeInfo({
        status : true,
        tokenId : tokenId,
        owner : msg.sender,
        invitor : invitor,
        debt : rewardInfo.normalDebt,
        stakeTime : block.timestamp
        });
        userInfo[msg.sender].stakeAmount++;
        userInfo[msg.sender].stakeList.push(tokenId);
        userInfo[msg.sender].stakeKind[nft.cardIdMap(tokenId) - 1] ++;
        totalCard++;
        if (invitor != address(this)) {
            _processReferAmount(invitor, true);
        }

        if (userInfo[msg.sender].stakeAmount >= 12 && !userInfo[msg.sender].isSuperNode) {
            if (_checkUserIsNode(msg.sender)) {
                userInfo[msg.sender].isSuperNode = true;
                userInfo[msg.sender].superDebt = rewardInfo.superDebt;
                superNodeAmount ++;
            }
        }
        emit Stake(msg.sender, invitor, tokenId);
    }

    function unStake(uint tokenId) external onlyEOA countingDebt {
        require(stakeInfo[tokenId].status, 'wrong tokenId');
        require(stakeInfo[tokenId].owner == msg.sender, 'not owner');
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
        address invitor = stakeInfo[tokenId].invitor;
        uint tempRew = _calculateToken(tokenId);
        if (tempRew > 0) {
            userInfo[msg.sender].toClaim += tempRew;
        }
        delete stakeInfo[tokenId];
        userInfo[msg.sender].stakeAmount--;
        uint _index;
        for (uint i = 0; i < userInfo[msg.sender].stakeList.length; i++) {
            if (userInfo[msg.sender].stakeList[i] == tokenId) {
                _index = i;
            }
        }
        userInfo[msg.sender].stakeList[_index] = userInfo[msg.sender].stakeList[userInfo[msg.sender].stakeList.length - 1];
        userInfo[msg.sender].stakeList.pop();
        userInfo[msg.sender].stakeKind[nft.cardIdMap(tokenId) - 1] --;
        totalCard --;
        if (invitor != address(this)) {
            _processReferAmount(invitor, false);
        }
        if (userInfo[msg.sender].stakeAmount < 12 && userInfo[msg.sender].isSuperNode) {
            if (!_checkUserIsNode(msg.sender)) {
                userInfo[msg.sender].isSuperNode = false;
                uint rew = _calculateNodeRew(msg.sender);
                if (rew > 0) {
                    claimInfo[msg.sender].nodeClaimed += rew;
                    userInfo[msg.sender].toClaim += rew;
                }
                superNodeAmount --;
            }
        }
        emit UnStake(msg.sender, tokenId);
    }

    function checkAllReward(address addr) public view returns (uint, uint, uint, uint){
        uint[] memory list = userInfo[addr].stakeList;
        uint tokenRew;
        uint nodeRew;
        uint levelRew;
        uint totalRew;
        uint userDebt;
        {
            UserInfo memory info = userInfo[addr];
            (uint _normal,uint[4] memory _level,uint _node) = getTempDebt();
            for (uint i = 0; i < list.length; i++) {
                if (stakeInfo[list[i]].status) {
                    uint tokenDebt = stakeInfo[list[i]].debt;
                    tokenRew += _normal - tokenDebt;
                }
            }
            if (info.isSuperNode) {
                userDebt = info.superDebt;
                nodeRew = _node - userDebt;
            }

            uint level = info.referLevel;
            if (level != 0) {
                userDebt = info.levelDebt[level - 1];
                levelRew = _level[level - 1] - userDebt;
            }

            totalRew = tokenRew + levelRew + nodeRew;
        }

        return (totalRew, tokenRew, levelRew, nodeRew);
    }

    function setUserLevel(address addr, uint Amount) external onlyManager countingDebt{
        userInfo[addr].referAmount += Amount - 1;
        userAddRefer[addr] += Amount;
        _processReferAmount(addr, true);
    }

    function clearUserReferLevel(address addr) external onlyManager {
        require(userAddRefer[addr] > 0, 'no add amount');
        userInfo[addr].referAmount -= userAddRefer[addr] - 1;
        _processReferAmount(addr, false);
    }


    function setUserSuperNode(address addr, bool b) external onlyManager countingDebt {
        if (b) {
            require(!isAddSuperNode[addr], 'already add');
            for (uint i = 0; i < 12; i++) {
                userInfo[addr].stakeKind[i] += 1;
            }
            if (_checkUserIsNode(addr)) {
                userInfo[addr].isSuperNode = true;
                userInfo[addr].superDebt = rewardInfo.superDebt;
                superNodeAmount ++;
            }
            isAddSuperNode[addr] = true;
        } else {
            require(isAddSuperNode[addr], 'not add yet');
            for (uint i = 0; i < 12; i++) {
                userInfo[addr].stakeKind[i] += 1;
            }
            if (_checkUserIsNode(addr)) {
                userInfo[addr].isSuperNode = false;
                uint rew = _calculateNodeRew(addr);
                if (rew > 0) {
                    userInfo[addr].toClaim += rew;
                }
                userInfo[addr].superDebt = rewardInfo.superDebt;
                superNodeAmount --;
            }
            isAddSuperNode[addr] = false;
        }
    }

    function checkAllAmount() public view returns(uint[4] memory levels,uint nodeAmount){
        levels = levelAmount;
        nodeAmount = superNodeAmount;
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface I721{
    function mint(address player,uint ID) external;
    function cardIdMap(uint times) external view returns(uint);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function checkCardLeft(uint cardId) external view returns(uint);
    function burn(uint tokenId_) external returns (bool);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
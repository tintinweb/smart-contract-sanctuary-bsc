// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Ck_Game is OwnableUpgradeable {
    IERC20 public CK;
    IERC20 public U;

    struct Position {
        address root;
        uint round;
        uint totalCk;
        bool isOut;
    }

    struct RoundInfo {
        uint startTime;
        uint endTime;
        address[] newUserList;
        uint newUserAmount;
        uint totalCk;
        bool claimAble;
    }

    struct UserInfo {
        uint position;
        uint level;
        mapping(uint => uint) roundAmount;
        mapping(uint => bool) roundStake;
        mapping(uint => bool) claimRound;
        mapping(uint => uint) roundFomo;
        address[] referList;
        bool fomoClaimed;
        uint ownerOfNode;
        bool isMarketNode;
        uint claimed;
        uint debt;
        uint initDebt;
        uint nodeClaimed;
        uint totalStake;
        uint newUserReward;
    }

    struct ReferReward {
        uint dynamicClaimed;
        uint levelReward;
        uint directReward;
        uint sameLevelReward;
        uint eightReward;
    }

    struct StageInfo {
        address stage1;
        address stage2;
        address stage3;
    }

    struct ReferInfo {
        address invitor;
        bool isRefer;
        uint referAmount;

    }

    StageInfo public stage;
    mapping(address => ReferReward) referReward;
    mapping(address => ReferInfo) public referInfo;
    mapping(uint => Position) public position;
    mapping(uint => mapping(uint => RoundInfo)) public roundInfo;
    mapping(address => UserInfo) public userInfo;
    uint public initNodePrice;
    uint public marketNodePrice;
    uint public positionAmount;
    uint[] fomoRate;

    struct NodeInfo {
        uint initNodeAmount;
        uint marketNodeAmount;
        uint debt;
    }

    NodeInfo public nodeInfo;
    uint[] referLimit;
    uint[] referRewardRate;
    uint fastTime;
    address public feeWallet;

    function initialize() public initializer {
        __Ownable_init();
        initNodePrice = 5000 ether;
        marketNodePrice = 1000 ether;
        referLimit = [0, 50 ether, 500 ether, 1000 ether];
        referRewardRate = [0, 2, 4, 6];
        fomoRate = [50, 30, 20, 11, 9, 8, 7, 6, 5, 4];
        fastTime = 86400;
        stage.stage1 = 0x1b5Ed2DB196E1d09B292d9D80dA9F50c2021e0e7;
        stage.stage2 = 0x10318b6f97349088463D29b63B5B42b196c9bd41;
        stage.stage3 = 0xA13Ba2B0bA373618efe5d802C0a3d910147aE205;
        feeWallet = 0x022D16F13CC8353Bad5b1bE1de64b7c0C01ee3e6;

    }

    modifier onlyEOA(){
        require(msg.sender == tx.origin, 'only eoa');
        _;
    }

    modifier checkRoundUpgrade(uint positionId){
        Position storage pos = position[positionId];
        RoundInfo storage round = roundInfo[positionId][pos.round];
        uint userLimit = getRoundUserLimit(positionId);
        if (round.newUserList.length >= userLimit) {
            upGradeRound(positionId);
        }
        if (round.newUserList.length < userLimit && block.timestamp >= round.endTime) {
            pos.isOut = true;
        }
        _;
        if (round.newUserList.length >= userLimit) {
            upGradeRound(positionId);

        }
    }

    function setCk(address addr) external onlyOwner {
        CK = IERC20(addr);
    }

    function setU(address addr) external onlyOwner {
        U = IERC20(addr);
    }

    function setUserLevel(address addr, uint level) external onlyOwner {
        userInfo[addr].level = level;
    }

    function setUserLevelBatch(address[] memory addrs, uint[] memory level) external onlyOwner {
        for (uint i = 0; i < addrs.length; i++) {
            userInfo[addrs[i]].level = level[i];
        }
    }

    function setFastTime(uint times) external onlyOwner {
        fastTime = times;
    }

    function _newRound(address owner_) internal {
        require(userInfo[owner_].ownerOfNode == 0, 'have initNode');
        require(userInfo[owner_].position == 0, 'bond position');
        positionAmount++;
        uint id = positionAmount;
        position[id].root = owner_;
        position[id].round = 1;
        RoundInfo storage round = roundInfo[id][1];
        round.startTime = block.timestamp;
        round.endTime = block.timestamp + 2 days;
        referInfo[owner_].isRefer = true;
        userInfo[owner_].position = id;
        userInfo[owner_].ownerOfNode = positionAmount;
        nodeInfo.initNodeAmount ++;
    }

    function newRound(uint id, address owner_) public onlyOwner {
        require(position[id].round == 0 && id == positionAmount + 1, 'have id');
        _newRound(owner_);
    }

    function setStage(address stage1_, address stage2_, address stage3_) external onlyEOA {
        stage.stage1 = stage1_;
        stage.stage2 = stage2_;
        stage.stage3 = stage3_;
    }

    function bond(address invitor) external onlyEOA {
        UserInfo storage user = userInfo[msg.sender];
        ReferInfo storage refer = referInfo[msg.sender];
        require(referInfo[invitor].isRefer, 'wrong invitor');
        require(refer.invitor == address(0), 'bonded');
        uint positionId = userInfo[invitor].position;
        user.position = positionId;
        refer.invitor = invitor;
        userInfo[invitor].referList.push(msg.sender);

    }

    function checkIsRefer(address addr) public view returns (bool){
        if (referInfo[addr].isRefer) {
            return true;
        } else {
            return false;
        }

    }

    function enter(uint positionId) external onlyEOA checkRoundUpgrade(positionId) {

        UserInfo storage user = userInfo[msg.sender];
        Position storage pos = position[positionId];
        RoundInfo storage round = roundInfo[positionId][pos.round];
        ReferInfo storage refer = referInfo[msg.sender];
        require(round.newUserList.length < getRoundUserLimit(positionId), 'full stake');
        require(user.position == positionId, 'wrong position id');
        require(!user.roundStake[pos.round], 'this round staked');
        require(!pos.isOut, 'round is out');
        require(block.timestamp >= round.startTime, 'not start');
        require(block.timestamp < round.endTime, 'end');
        uint ckAmount = getUserInAmount(positionId);
        CK.transferFrom(msg.sender, address(this), ckAmount);
        user.totalStake += ckAmount;
        user.roundAmount[pos.round] = ckAmount;
        pos.totalCk += ckAmount;
        round.totalCk += ckAmount;
        bool isNew;
        if (!refer.isRefer) {
            refer.isRefer = true;
            isNew = true;
        }
        uint allNode = nodeInfo.initNodeAmount + nodeInfo.marketNodeAmount;
        nodeInfo.debt += ckAmount / 100 / allNode;
        user.roundStake[pos.round] = true;
        round.newUserList.push(msg.sender);
        round.newUserAmount++;
        if (msg.sender != pos.root) {
            _processReferAmount(msg.sender, ckAmount, isNew);
        }

    }

    function buyInitNode() external onlyEOA {
        require(userInfo[msg.sender].ownerOfNode == 0, 'already have node');
        require(userInfo[msg.sender].position == 0, 'have position');
        U.transferFrom(msg.sender, address(this), initNodePrice);
        _newRound(msg.sender);
        userInfo[msg.sender].ownerOfNode = positionAmount;
        nodeInfo.initNodeAmount ++;
    }

    function newMarketNode(address addr) external onlyOwner {
        require(!userInfo[addr].isMarketNode && userInfo[addr].ownerOfNode == 0, 'already have node');
        require(userInfo[addr].position != 0, 'must bond 1 position');
        userInfo[addr].isMarketNode = true;
        nodeInfo.marketNodeAmount ++;
    }

    function checkNodeReward(address addr) public view returns (uint rew){
        rew = 0;
        if (userInfo[addr].ownerOfNode != 0 || userInfo[addr].isMarketNode) {
            rew = userInfo[addr].newUserReward;
        }

    }

    function checkNodeShare(address addr) public view returns (uint rew){
        uint temp;
        if (userInfo[addr].ownerOfNode != 0) {
            temp ++;
        }
        if (userInfo[addr].isMarketNode) {
            temp ++;
        }
        if (temp == 0) {
            rew = 0;
        } else {
            rew = (nodeInfo.debt - userInfo[addr].debt) * temp;
        }
    }

    function claimReferReward() external onlyEOA {
        ReferReward storage user = referReward[msg.sender];
        uint rew;
        {
            uint sameLevel = user.sameLevelReward;
            uint levelRew = user.levelReward;
            uint eightRew = user.eightReward;
            uint dirRew = user.directReward;
            rew += sameLevel + levelRew + eightRew + dirRew;
        }

        require(rew > 0, 'no reward');
        user.sameLevelReward = 0;
        user.levelReward = 0;
        user.eightReward = 0;
        user.directReward = 0;
        user.dynamicClaimed += rew;
        CK.transfer(msg.sender, rew);
    }

    function claimNodeShare() external onlyEOA {
        uint rew = checkNodeShare(msg.sender);
        require(rew > 0, 'no share reward');
        CK.transfer(msg.sender, rew);
        userInfo[msg.sender].debt = nodeInfo.debt;
        userInfo[msg.sender].nodeClaimed += rew;
    }


    function claimNodeReward() external onlyEOA {
        uint rew = checkNodeReward(msg.sender);
        require(rew > 0, 'no node reward');
        CK.transfer(msg.sender, rew);
        userInfo[msg.sender].newUserReward = 0;
    }

    function calculateRelease(address addr) public view returns (uint){
        UserInfo storage user = userInfo[addr];
        uint nowRound = position[user.position].round;
        uint rew = 0;
        if (nowRound > 3) {
            for (uint i = 1; i <= nowRound - 3; i++) {
                if (user.roundStake[i] && !user.claimRound[i]) {
                    rew += user.roundAmount[i] * 12 / 10;
                }
            }
        }
        return rew;
    }

    function calculateFailRelease(address addr) public view returns (uint){
        uint start = 1;
        UserInfo storage user = userInfo[addr];
        uint positionId = user.position;
        uint nowRound = position[positionId].round;
        if (!checkPositionIsOut(positionId)) {
            return 0;
        }
        if (nowRound > 3) {
            start = nowRound - 3;
        }
        uint rew = 0;
        for (uint i = start; i <= nowRound; i++) {
            uint totalUser = roundInfo[positionId][i].newUserList.length;
            if (user.roundStake[i] && !user.claimRound[i] && totalUser > 0) {
                rew += roundInfo[positionId][i].totalCk / 10 / totalUser;
            }
        }
        return rew;
    }

    function calculateFomo(address addr) public view returns (uint){
        uint start = 1;
        UserInfo storage user = userInfo[addr];
        if (user.fomoClaimed) {
            return 0;
        }
        uint positionId = user.position;
        uint nowRound = position[positionId].round;
        uint rew;
        if (nowRound > 3) {
            start = nowRound - 3;
        }
        for (uint i = start; i <= nowRound; i++) {
            rew += user.roundFomo[i];
        }

        return rew;
    }

    function claimRelease() external onlyEOA {
        UserInfo storage user = userInfo[msg.sender];
        uint nowRound = position[user.position].round;
        uint rew = 0;
        if (nowRound > 3) {
            for (uint i = 1; i <= nowRound - 3; i++) {
                if (user.roundStake[i] && !user.claimRound[i]) {
                    rew += user.roundAmount[i] * 12 / 10;
                    user.claimRound[i] = true;
                }
            }
        }
        uint fee = rew * 3 / 100;
        rew -= fee;
        CK.transfer(feeWallet, fee);
        CK.transfer(msg.sender, rew);
    }

    function claimFailRelease() external onlyEOA {

        uint start = 1;
        UserInfo storage user = userInfo[msg.sender];
        uint positionId = user.position;
        require(checkPositionIsOut(positionId), 'not out yet');
        if (!position[positionId].isOut) {
            _processOut(positionId);
        }
        uint nowRound = position[positionId].round;
        if (nowRound > 3) {
            start = nowRound - 3;
        }
        uint rew = 0;
        for (uint i = start; i <= nowRound; i++) {
            uint totalUser = roundInfo[positionId][i].newUserList.length;
            if (user.roundStake[i] && !user.claimRound[i] && totalUser > 0) {
                rew += roundInfo[positionId][i].totalCk / 10 / totalUser;
                user.claimRound[i] = true;
            }
        }
        uint fee = rew * 3 / 100;
        rew -= fee;
        CK.transfer(feeWallet, fee);
        CK.transfer(msg.sender, rew);
    }

    function claimFomo() external onlyEOA {
        uint start = 1;
        UserInfo storage user = userInfo[msg.sender];
        require(!user.fomoClaimed, 'claimed');
        uint positionId = user.position;
        require(checkPositionIsOut(positionId), 'not out yet');
        uint nowRound = position[positionId].round;
        uint rew;
        if (nowRound > 3) {
            start = nowRound - 3;
        }
        for (uint i = start; i <= nowRound; i++) {
            rew += user.roundFomo[i];
        }
        require(rew > 0, 'no reward');
        user.fomoClaimed = true;
        CK.transfer(msg.sender, rew);
    }

    function getUserToClaimRound(address addr) public view returns (uint[] memory){
        uint index = 0;
        UserInfo storage user = userInfo[addr];
        uint nowRound = position[user.position].round;
        uint[] memory lists;
        if (nowRound > 3) {
            for (uint i = 1; i <= nowRound; i++) {
                if (user.roundStake[i] && !user.claimRound[i]) {
                    index++;
                }
            }
            lists = new uint[](index);

            for (uint i = 1; i <= nowRound; i++) {
                if (user.roundStake[i] && !user.claimRound[i]) {
                    index--;
                    lists[index] = i;
                }
            }
        } else {
            lists = new uint[](0);
        }
        return lists;
    }

    function checkPositionIsOut(uint positionId) public view returns (bool){
        if (position[positionId].isOut) {
            return true;
        }
        RoundInfo storage round = roundInfo[positionId][position[positionId].round];
        uint userLimit = getRoundUserLimit(positionId);
        bool out = false;
        if (round.newUserList.length < userLimit && block.timestamp >= round.endTime) {
            out = true;
        }
        return out;
    }


    function _processOut(uint positionId) internal {
        position[positionId].isOut = true;
        {
            uint start = 1;
            uint nowRound = position[positionId].round;
            if (nowRound > 3) {
                start = nowRound - 3;
            }
            for (uint i = start; i <= nowRound; i++) {
                RoundInfo storage round = roundInfo[positionId][i];
                uint rewards = round.totalCk;
                address[] memory lists = round.newUserList;
                uint index = lists.length;
                if (index == 0) {
                    continue;
                }
                uint length = 10;
                if (index < length) {
                    length = index;
                }
                index--;
                for (uint j = 0; j < length; j++) {
                    uint rew = rewards * fomoRate[j] / 1000;
                    userInfo[lists[index - j]].roundFomo[i] = rew;
                }
            }
        }
    }


    function getUserInAmount(uint positionId) public view returns (uint){
        uint out = 1 ether;
        if (position[positionId].round == 1) {
            return out;
        } else {
            for (uint i = 1; i < position[positionId].round; i++) {
                out = out * 15 / 10;
            }
            return out;
        }
    }

    function getRoundUserLimit(uint positionId) public view returns (uint){
        uint out = 100;
//        if (out == 100) {
//            return 10;
//        }
        if (position[positionId].round == 1) {
            return out;
        } else {
            for (uint i = 1; i < position[positionId].round; i++) {
                out = out * 15 / 10;
            }
            return out;
        }
    }

    function getUserLevel(address addr) public view returns (uint){
        uint amount = referInfo[addr].referAmount;
        uint out = 0;
        if (userInfo[addr].level != 0) {
            return userInfo[addr].level;
        }
        for (uint i = 0; i < referLimit.length; i++) {
            if (amount < referLimit[i]) {
                break;
            }
            if (amount >= referLimit[i]) {
                out = i;
            }
        }
        return out;
    }

    function _processReferAmount(address addr, uint amount, bool isNew) internal {
        uint sameLevelLeft = 10;
        {
            address invitor = referInfo[addr].invitor;
            uint lastLevel = getUserLevel(addr);
            //            address root = position[userInfo[addr].position].root;
            address temp = invitor;
            referReward[temp].directReward += amount * 7 / 100;
            //first referRew
            uint lever = 1;


            while (true) {
                if (temp == address(0)) {
                    break;
                }
                ReferInfo storage user = referInfo[temp];
                ReferReward storage refer = referReward[temp];
                user.referAmount += amount;
                uint tempLevel = getUserLevel(temp);
                if (lever <= 8) {
                    refer.eightReward += amount / 100;
                    lever++;
                }
                if (tempLevel > lastLevel) {
                    refer.levelReward += amount * referRewardRate[tempLevel] / 100;
                    lastLevel = tempLevel;
                } else if (tempLevel == lastLevel && sameLevelLeft > 0 && lastLevel != 0) {
                    sameLevelLeft --;
                    refer.sameLevelReward += amount / 100;
                }
                if (isNew) {
                    if (userInfo[temp].isMarketNode) {
                        userInfo[temp].newUserReward += amount * 3 / 100;
                    }
                    if (userInfo[temp].ownerOfNode != 0) {
                        userInfo[temp].newUserReward += amount * 2 / 100;
                    }
                }

                temp = referInfo[temp].invitor;
            }
        }
        if (sameLevelLeft > 0) {
            CK.transfer(stage.stage3, amount * sameLevelLeft / 100);
        }
    }

    function upGradeRound(uint positionId) internal {
        Position storage pos = position[positionId];
        pos.round++;
        RoundInfo storage _newRounds = roundInfo[positionId][pos.round];
        uint lastStartTime = roundInfo[positionId][pos.round - 1].startTime;
        uint startTime;
        if (block.timestamp < lastStartTime + fastTime) {
            startTime = lastStartTime + fastTime;
        } else {
            startTime = block.timestamp;
        }
        _newRounds.startTime = startTime;
        _newRounds.endTime = checkRoundEndTime(startTime, pos.round);
        if (pos.round >= 4) {
            if (!roundInfo[positionId][pos.round - 3].claimAble) {
                roundInfo[positionId][pos.round - 3].claimAble = true;
                CK.transfer(stage.stage2, roundInfo[positionId][pos.round - 3].totalCk * 15 / 100);
                CK.transfer(stage.stage1, roundInfo[positionId][pos.round - 3].totalCk * 10 / 100);
            }
        }
    }

    function checkRoundEndTime(uint startTime, uint round) internal view returns (uint){
        uint out = startTime + (fastTime * 2 * 3 ** (round - 1));
        return out;
    }

    function checkPositionInfo(address addr) public view returns (uint positionId, uint round,
        uint totalAmount,
        uint startTime,
        uint endTime,
        uint userLimit,
        uint userAmount,
        bool isOut,
        bool isStake){
        positionId = userInfo[addr].position;
        Position storage pos = position[positionId];
        RoundInfo storage rounds = roundInfo[positionId][pos.round];
        round = pos.round;
        totalAmount = rounds.totalCk;
        startTime = rounds.startTime;
        endTime = rounds.endTime;
        userLimit = getRoundUserLimit(positionId);
        userAmount = rounds.newUserList.length;
        isOut = checkPositionIsOut(positionId);
        isStake = userInfo[addr].roundStake[round];
    }

    function checkReferListInfo(address addr) public view returns (address[] memory userList, uint[] memory userTotal, uint[] memory referAmount, uint[] memory level){
        userList = userInfo[addr].referList;
        userTotal = new uint[](userList.length);
        referAmount = new uint[](userList.length);
        level = new uint[](userList.length);
        for (uint i = 0; i < userList.length; i++) {
            userTotal[i] = userInfo[userList[i]].totalStake;
            referAmount[i] = referInfo[userList[i]].referAmount;
            level[i] = getUserLevel(userList[i]);
        }
    }

    function checkNodeInfo(address addr) public view returns (bool isInitNode, bool isMarketNode, uint nodeClaimed, uint nodeShare, uint nodeNewReward){
        isInitNode = userInfo[addr].ownerOfNode > 0;
        isMarketNode = userInfo[addr].isMarketNode;
        nodeClaimed = userInfo[addr].nodeClaimed;
        nodeShare = checkNodeShare(addr);
        nodeNewReward = checkNodeReward(addr);
    }

    function checkReferInfo(address addr) public view returns (uint level,
        uint referAmount,
        uint totalClaimed,
        uint directReward,
        uint eightReward,
        uint levelReward,
        uint sameLevelReward,
        address invitor){
        ReferInfo storage refer = referInfo[addr];
        ReferReward storage reward = referReward[addr];
        level = getUserLevel(addr);
        referAmount = refer.referAmount;
        totalClaimed = reward.dynamicClaimed;
        directReward = reward.directReward;
        eightReward = reward.eightReward;
        levelReward = reward.levelReward;
        sameLevelReward = reward.sameLevelReward;
        invitor = referInfo[addr].invitor;
    }

    function checkPositionRoundInfo(address addr, uint round) public view returns (
        uint totalAmount,
        uint startTime,
        uint endTime,
        uint userLimit,
        uint userAmount,
        bool isStake){
        uint positionId = userInfo[addr].position;
        Position storage pos = position[positionId];
        RoundInfo storage rounds = roundInfo[positionId][round];
        round = pos.round;
        totalAmount = rounds.totalCk;
        startTime = rounds.startTime;
        endTime = rounds.endTime;
        userLimit = getRoundUserLimit(positionId);
        userAmount = rounds.newUserList.length;
        isStake = userInfo[addr].roundStake[round];
    }

    function safePull(address token,address wallet_,uint amount) external onlyOwner{
        IERC20(token).transfer(wallet_,amount);
    }


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
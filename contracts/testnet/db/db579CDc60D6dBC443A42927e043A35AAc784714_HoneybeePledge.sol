// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "../other/divestor_upgradeable.sol";


contract HoneybeePledge is Initializable, OwnableUpgradeable, DivestorUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    struct AddrInfo {
        IERC20Upgradeable  u;
        IERC20Upgradeable  BEE;
        IERC20Upgradeable  HBEE;
        // address  pairOfBEE;
        address  pairOfHBEE;
        address  market;        
        address  technology;    
    }
    struct Debt {
        uint lastTime;
        uint startTime;
        uint startDebted;
        uint debted;
        uint rate;
        uint totalValue; 
    }
    struct Status {
        bool stake;
        bool claimStake;
        bool claimComm;
        bool claimNode;
        bool claimShare;
    }
    struct UserInfo {
        uint level;
        address inviter;
        uint directInviter; // direct inviter amount
        uint commPower;     // community power
        uint shareReward;
        uint stakeAmount;   // current 
        uint stakeValue;    // current
        uint lastStakeTime;
        uint claimedAmount; // 
        uint claimedValue;  // 
        uint totalClaim;       // total
        uint totalClaimValue;  // total
        uint nodeSlotId;
    }
    struct NodeSlot {
        address owner;
        uint lastTime;
    }
    struct Slot {
        bool status;
        uint debt;
        uint stakeTime;
        uint stakeAmount;
        uint stakeValue;
    }
    struct DailyInfo {
        uint output;
        uint rateIndex;
        uint burnRate;
        uint lastTime;
    }
    struct CommDebt {
        uint lastTime;
        uint initDebted;
        uint debted;
        uint rate;
        uint totalValue; 
        uint endTime;
    }
    struct CommPool {
        uint debt;
        bool exist;
    }

    uint public startTime;
    uint public nodeRate;

    Debt public debt;
    Status public status;
    AddrInfo public addrInfo;
    DailyInfo public dailyInfo;

    uint[5] public burnPower;
    uint[5] public burnRate;
    uint[3] public inviterRate;

    CommDebt[5] public commPool;
    address[] public superNodeList;

    mapping(address => bool) whiteList;
    mapping(uint => NodeSlot) public nodeInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => mapping(uint => Slot)) public userSlot;
    mapping(address => mapping(uint => CommPool)) public userComm;

    mapping(address => address[]) public inviterInfo;
    
    
    function initialize() initializer public {
        __Ownable_init_unchained();
        
        addrInfo.u = IERC20Upgradeable(0x7063B8CE05627301bC0bdBB390F0CB1C6B46d9A3);
        addrInfo.BEE = IERC20Upgradeable(0x8f7c8ffdA583CC779c2FBBea348455878624cD07);
        addrInfo.HBEE = IERC20Upgradeable(0x7b3c29DC3F037bb3a2f6e81D5b0987950571E859);
        addrInfo.pairOfHBEE = 0x7063B8CE05627301bC0bdBB390F0CB1C6B46d9A3;
        addrInfo.market = 0x7063B8CE05627301bC0bdBB390F0CB1C6B46d9A3;
        addrInfo.technology = 0x7063B8CE05627301bC0bdBB390F0CB1C6B46d9A3;


        burnPower = [100000 ether, 300000 ether, 800000 ether, 1800000 ether, 5000000 ether];
        burnRate = [90, 80, 60, 20, 0];
        inviterRate = [45, 35, 20];


        uint dayOpt = 4566 ether;
        nodeRate = dayOpt / 10 / 1 days;

        dailyInfo.output = dayOpt;
        dailyInfo.burnRate = 0;
        debt.rate = dayOpt / 1 days;
        
        status.stake = true;
    }

    function _out(address account_) private {
        for (uint i = 0; i < 5; i++) {
            userSlot[account_][i] = Slot({
                status: false,
                debt: 0,
                stakeTime: 0,
                stakeAmount: 0,
                stakeValue: 0
            });
        }
        uint de = coutingDebt();
        debt.debted = de;
        debt.totalValue -= userInfo[account_].stakeValue;
        debt.lastTime = block.timestamp;

        // burn node reward
        if (userInfo[account_].nodeSlotId != 0) {
            _burnNodeReward(userInfo[account_].nodeSlotId);
            nodeInfo[userInfo[account_].nodeSlotId].owner = address(0);
            userInfo[account_].nodeSlotId = 0;
        }
        // burn share reward
        if (userInfo[account_].shareReward > 0) {
            addrInfo.HBEE.safeTransfer(0x000000000000000000000000000000000000dEaD, userInfo[account_].shareReward);
        }

        uint totalClaim = userInfo[account_].totalClaim + userInfo[account_].claimedAmount;
        uint totalClaimValue = userInfo[account_].totalClaimValue + userInfo[account_].claimedValue;
        userInfo[account_] = UserInfo({
            level: userInfo[account_].level,
            inviter: userInfo[account_].inviter,
            directInviter: userInfo[account_].directInviter,
            commPower: userInfo[account_].commPower,
            shareReward: 0,
            stakeAmount: 0,
            stakeValue: 0,
            lastStakeTime: userInfo[account_].lastStakeTime,
            claimedAmount: 0,
            claimedValue: 0,  
            totalClaim: totalClaim,
            totalClaimValue: totalClaimValue,
            nodeSlotId: userInfo[account_].nodeSlotId
        });

        // 减少十代社区算力
        _updateCommPower(_msgSender(), userInfo[account_].stakeValue, false);
        _changeOpt();
    } 

    event Out(address indexed account, uint indexed stakeValue);
    function _processOut(uint readReward_, uint reward_, address account_) private returns (bool) {
        if (readReward_ > reward_) {
            uint gas = readReward_ - reward_;
            addrInfo.HBEE.safeTransfer(0x000000000000000000000000000000000000dEaD, gas);
        }

        if (!whiteList[account_] && readReward_ >= reward_) {
            _out(account_);
            emit Out(account_, userInfo[account_].stakeValue);
            return true;
        }
        return false;
    }

    function _changeOpt() private {
        for (uint i = 0; i < 5; i++) {
            if (debt.totalValue >= burnPower[4-i]) {
                dailyInfo.burnRate = burnRate[i];
                break;
            }
        }
    }

    function _changeBUrnRate(uint rate_) public onlyOwner{
        dailyInfo.burnRate = rate_;
    }

    function _processStakeToken(uint value_, bool isHBEE_) private  returns(uint) {
        if (isHBEE_) {
            uint amount = value_ * 1 ether / getPrice();
            addrInfo.HBEE.safeTransferFrom(_msgSender(), 0x000000000000000000000000000000000000dEaD, amount);
            return amount;
        }
        addrInfo.BEE.safeTransferFrom(_msgSender(), 0x000000000000000000000000000000000000dEaD, value_);
        return value_;
    }

    function _allocateInviterReward(address account_, uint reward) private {
        address inviter;
        for (uint i = 0; i < 3; i++) {
            inviter == userInfo[account_].inviter;
            if (inviter == address(0)) {
                addrInfo.HBEE.safeTransfer(0x000000000000000000000000000000000000dEaD, reward * inviterRate[i] / 100);
            } else {
                userInfo[inviter].shareReward += reward * inviterRate[i] / 100;
            }
        }
    }

    function _removeNode(address account_) private {
        uint index;
        for (uint i = 0; i < superNodeList.length; i++) {
            if (superNodeList[i] == account_) {
                index = i;
            }
        }
        superNodeList[index] = superNodeList[superNodeList.length - 1];
        superNodeList.pop();


        uint slowId = userInfo[account_].nodeSlotId;
        if (slowId == 0) {
            return;
        }

        _burnNodeReward(slowId);
        nodeInfo[slowId].owner = address(0);
        userInfo[account_].nodeSlotId = 0;
    }

    function _embedNodeSlot(address account_) private  {
        uint slowId;
        for (uint i = 1; i <= 34; i++) {
            if (nodeInfo[i].owner != address(0)) {
                slowId = i;
            }
        }
        userInfo[account_].nodeSlotId = slowId; 

        _burnNodeReward(slowId);
        nodeInfo[slowId].owner = account_;
    }

    function _burnNodeReward(uint slowId) private {
        require(slowId >= 1 && slowId <= 34, "wrong slow id");
        uint reward = viewNodeSlotReward(slowId);
        if (reward > 0) {
            addrInfo.HBEE.safeTransfer(0x000000000000000000000000000000000000dEaD, viewNodeSlotReward(slowId));
        }
        nodeInfo[slowId].lastTime = block.timestamp; 
    }

    function _updateCommPower(address account_,  uint value_,  bool addValue_) private {
        address inviter = account_;
        uint oldLevel;
        uint newLevel;
        for (uint i = 0; i < 10; i++) {
            if (inviter == address(0) || inviter == address(this)) {
                break;
            }

            if (inviter != account_) {
                if (addValue_) {
                    userInfo[inviter].commPower += value_;
                } else {
                    userInfo[inviter].commPower -= value_;
                }
            }

            oldLevel = userInfo[inviter].level;
            newLevel = getLevel(inviter);
            userInfo[inviter].level = newLevel;

            inviter = userInfo[inviter].inviter;

            if (oldLevel == newLevel) {
                continue;
            }
            if (oldLevel < newLevel) {
                for(uint l = oldLevel + 1; l <= newLevel; l++) {
                    _updateCommPool(_msgSender(), l, true);
                }
            } else {
                for(uint l = oldLevel; l > newLevel; l--) {
                    _updateCommPool(_msgSender(), l, false);
                }
            }
        }
    }

    function _updateCommPool(address account_, uint poolId_, bool inPool_) private {
        uint commDebt = coutingCommDebt(poolId_);
        commPool[poolId_].debted = commDebt;
        commPool[poolId_].lastTime = block.timestamp;
        
        // exit
        if (!inPool_) {
            commPool[poolId_].totalValue -= 1;
            userComm[account_][poolId_].debt = 0;
            if (commPool[poolId_].totalValue == 0) {
                commPool[poolId_].endTime = block.timestamp;
            }
            return;
        }

        commPool[poolId_].totalValue += 1;
        userComm[account_][poolId_].debt = commDebt;

        if (commPool[poolId_].totalValue == 1 && commPool[poolId_].endTime != 0) {
            addrInfo.HBEE.safeTransfer(0x000000000000000000000000000000000000dEaD, (commPool[poolId_].endTime - block.timestamp) * commPool[poolId_].rate);
        }
    } 

    

    function _claimReward(address account_, uint reward_, uint rewardI_, uint gas_) private {
        uint rewardValue = getPrice() * reward_  / 1 ether;
        userInfo[account_].claimedAmount += reward_;
        userInfo[account_].claimedValue += rewardValue;
        addrInfo.HBEE.safeTransfer(account_, rewardI_);
        addrInfo.HBEE.safeTransfer(0x000000000000000000000000000000000000dEaD, gas_);
    }

    function start() public onlyOwner {
        status.claimStake = true;
        status.claimComm = true;
        status.claimNode = true;
        status.claimShare = true;


        startTime = block.timestamp;
        for (uint i = 1; i <= 34; i++) {
            nodeInfo[i].lastTime = startTime;
        }

        for (uint i = 0; i < 5; i++) {
            commPool[i].endTime = startTime;
        }
    }

    function editSuperNode(address[] calldata accounts_, bool add_) public onlyOwner {
        require(superNodeList.length + accounts_.length <= 34, "1");
        address nodeAddr;
        for (uint i = 0; i < accounts_.length; i++) {
            nodeAddr = accounts_[i];
            if (add_) {
                require(!isSuperNode(nodeAddr), "2");
                superNodeList.push(nodeAddr);
                _embedNodeSlot(nodeAddr);
            } else {
                require(isSuperNode(nodeAddr), "3");
                _removeNode(nodeAddr);
            }
        }
    }

    function viewSuperNodeList() public view returns (address[] memory, uint[] memory) {
        return (superNodeList, batchViewValue(superNodeList));
    }

    function viewInviterList(address account_) public view  returns (address[] memory, uint[] memory) {
        return (inviterInfo[account_], batchViewValue(inviterInfo[account_]));
    }

    function batchViewValue(address[] memory accounts_) public view returns (uint[] memory) {
        uint[] memory info = new uint[](accounts_.length);

        for (uint i = 0; i < accounts_.length; i++) {
            info[i] = userInfo[accounts_[i]].stakeValue;
        }

        return info;
    }

    

    function getPrice() public view returns(uint) {
        return  2 ether;
        // uint reserve0 = addrInfo.u.balanceOf(addrInfo.pairOfHBEE);
        // uint reserve1 = addrInfo.HBEE.balanceOf(addrInfo.pairOfHBEE);
        // if (reserve1 == 0) {
        //     return 0;
        // }
    
        // return reserve0 * 1 ether / reserve1;
    }


    function viewCommLevels() public view returns (uint[5] memory) {
        uint[5] memory info;
        for (uint i = 0; i < 5; i++) {
            info[i] = commPool[i].totalValue;
        }
        return info;
    }


    function getLevel(address account_) public view returns(uint) {
        UserInfo memory info = userInfo[account_];
        uint level;
        if (info.directInviter >= 5 && info.stakeValue >= 500 ether && info.commPower >= 500 ether ) {
            level = 5;
        } else if (info.directInviter >= 4 && info.stakeValue >= 400 ether && info.commPower >= 400 ether ) {
            level = 4;
        } else if (info.directInviter >= 3 && info.stakeValue >= 300 ether && info.commPower >= 300 ether ) {
            level = 3;
        } else if (info.directInviter >= 2 && info.stakeValue >= 200 ether && info.commPower >= 200 ether ) {
            level = 2;
        } else if (info.directInviter >= 1 && info.stakeValue >= 100 ether && info.commPower >= 100 ether ) {
            level = 1;
        } else {
            level = 0;
        }
        return level;
    }

    function isSuperNode(address account_) public view returns(bool) {
        for (uint i = 0; i < superNodeList.length; i++) {
            if (superNodeList[i] == account_) {
                return true; 
            }
        }
        return false;
    }

    function coutingDebt() public view returns (uint) {
        uint debt_ = debt.totalValue > 0 ? (debt.rate * 6 / 10) * (block.timestamp - debt.lastTime) * 1 ether / debt.totalValue + debt.debted : 0 + debt.debted;
        return debt_;
    }

    function coutingCommDebt(uint poolId) public view returns (uint) {
        CommDebt memory poolInfo = commPool[poolId];
        uint debt_ = poolInfo.totalValue > 0 ? (debt.rate * 25 / 10 / 5) * (block.timestamp - poolInfo.lastTime) * 1 ether / poolInfo.totalValue + poolInfo.debted : 0 + poolInfo.debted;
        return debt_;
    }

    // 查询用户卡槽的待领取收益
    function viewSlotReward(address account_, uint slot_) public view returns (uint) {
        require(slot_ >= 0 && slot_ <= 9, '4');

        // 未开启 or 已出局 or 未质押
        if (debt.startTime == 0 || !userSlot[account_][slot_].status) {
            return 0;
        }

        Slot memory slotInfo = userSlot[account_][slot_];
        uint slotDebt = slotInfo.debt;
        if (slotInfo.stakeTime < debt.startTime) {
            slotDebt = debt.startDebted;
        }
        uint rewards = slotInfo.stakeValue * (coutingDebt() - slotDebt) / 1 ether;
        // if (slotInfo.stakeTime < debt.startTime) {
        //     uint deb = slotInfo.stakeValue * (debt.startDebted - slotInfo.debt) / 1 ether;
        //     rewards -= deb;
        // }
        rewards  = rewards * (100 - dailyInfo.burnRate) / 100;
        return rewards;
    } 
    
    // 查询用户全部卡槽的待领取收益 (maxReward, realReward)
    function viewStakeReward(address account_) public view returns (uint, uint) {
        if (userInfo[account_].stakeValue == 0) {
            return (0,0);
        }
        uint rewards;
        for (uint i = 0; i < 5; i++) {
            rewards += viewSlotReward(account_, i);
        }
        uint maxReward = viewClaimMaxAmount(account_);
        return (rewards > maxReward ? maxReward : rewards, rewards);
    }

    function viewNodeSlotReward(uint slowId) public view returns(uint) {
        if (nodeInfo[slowId].lastTime == 0 || block.timestamp <= nodeInfo[slowId].lastTime) {
            return 0;
        }
        uint reward = (block.timestamp - nodeInfo[slowId].lastTime) * nodeRate;
        reward  = reward * (100 - dailyInfo.burnRate) / 100;
        return reward;
    }

    function viewNodeReward(address account_) public view returns (uint, uint) {
        uint slowId = userInfo[account_].nodeSlotId;
        if (slowId == 0) {
            return (0, 0);
        }
        uint reward = viewNodeSlotReward(slowId);
        uint maxReward = viewClaimMaxAmount(account_);
        return (reward > maxReward ? maxReward : reward, reward);
    }

    function viewCommSlotReward(address account_, uint poolId_) public view returns (uint) {
        uint reward = (coutingCommDebt(poolId_) - userComm[account_][poolId_].debt) / 1 ether;
        reward  = reward * (100 - dailyInfo.burnRate) / 100;
        return reward;
    }

    function viewCommReward(address account_) public view returns (uint, uint) {
        uint rewards;
        for (uint i = 0; i < 5; i++) {
            rewards += viewCommSlotReward(account_, i);
        }
        uint maxReward = viewClaimMaxAmount(account_);
        return (rewards > maxReward ? maxReward : rewards, rewards);
    }

    // 查询用户分享待领取分享奖励
    function viewShareReward(address account_) public view returns (uint, uint) {
        if (userInfo[account_].stakeValue == 0) {
            return (0,0);
        }
        uint reward = userInfo[account_].shareReward;
        reward  = reward * (100 - dailyInfo.burnRate) / 100;
        uint maxReward = viewClaimMaxAmount(account_);
        return (reward > maxReward ? maxReward : reward, reward);
    }

    function viewValidValue(address account_) public view returns (uint) {
        return userInfo[account_].stakeValue * 3 - userInfo[account_].claimedValue;
    }

    function viewClaimMaxAmount(address account_) public view returns (uint) {
        uint maxValue = viewValidValue(account_);
        return maxValue * 1 ether / getPrice();  
    } 

    

    function viewValidSlots(address account_) public view returns (uint[] memory) {
        uint[] memory info = new uint[](5);
        uint size = 0;
        for (uint i = 0; i < 5; i++) {
            if (!userSlot[account_][i].status) {
                info[size] = i;
                size += 1;
            }
        }
        uint[] memory slots = new uint[](size);
        for (uint i = 0; i < size; i++) {
            slots[i] = info[i];
        }
        return slots; 
    }

    function stake(uint slot_, uint value_, bool isHBEE_, address inviter_) public {
        require(value_ % 100 ether == 0, "wrong amount_");
        require(status.stake, 'not open yet');
        require(slot_ >= 0 && slot_ <= 4, 'wrong slot');
        require(!userSlot[_msgSender()][slot_].status, 'already stake');

        if (userInfo[_msgSender()].inviter == address(0)) {
            require(inviter_ == address(this) || userInfo[inviter_].inviter != address(0), "wrong inviter");
            userInfo[_msgSender()].inviter = inviter_;
            userInfo[inviter_].directInviter += 1;
            inviterInfo[inviter_].push(_msgSender());
        }

        uint amount = _processStakeToken(value_, isHBEE_);

        // 已出局的节点重新质押
        if (isSuperNode(_msgSender()) && userInfo[_msgSender()].stakeValue == 0) {
            _embedNodeSlot(_msgSender());
        }
        
        uint newDebt = coutingDebt();
        // 开启挖矿
        if (debt.startTime == 0 && debt.totalValue >= 300 ether) {
            addrInfo.HBEE.safeTransfer(0x000000000000000000000000000000000000dEaD, (block.timestamp - startTime) * debt.rate);
            debt.startDebted = newDebt;
            debt.startTime = block.timestamp;
        }
        userSlot[_msgSender()][slot_] = Slot({
            status: true,
            debt: newDebt,
            stakeTime: block.timestamp,
            stakeAmount: amount,
            stakeValue: value_
        });

        debt.totalValue += value_;
        debt.debted = newDebt;
        debt.lastTime = block.timestamp;

        userInfo[_msgSender()].stakeAmount += amount;
        userInfo[_msgSender()].stakeValue += value_;
        userInfo[_msgSender()].lastStakeTime = block.timestamp;

        // 处理十代社区算力
        _updateCommPower(_msgSender(), value_, true);
        _changeOpt();
    }


    event ClaimNodeReward(address indexed account, uint indexed reward, uint indexed realReward);

    function claimNodeReward() public returns (uint) {
        require(status.claimNode, "not open yet");

        (uint reward, uint realReward) = viewNodeReward(_msgSender());
        require(reward > 0, "not reward"); 

        uint gas = reward * 5 / 100;
        _claimReward(_msgSender(), reward, reward - gas, gas);

        _processOut(realReward, reward, _msgSender());

        emit ClaimNodeReward(_msgSender(), reward, realReward);
        return reward;
    }

 
    event ClaimShareReward(address indexed account, uint indexed reward, uint indexed realReward);

    function claimShareReward() public returns (uint) {
        require(status.claimShare, "not open yet");

        (uint reward, uint realReward) = viewShareReward(_msgSender());
        require(reward > 0, "not reward");

        uint gas = reward * 5 / 100;
        _claimReward(_msgSender(), reward, reward - gas, gas);

        _processOut(realReward, reward, _msgSender());

        emit ClaimShareReward(_msgSender(), reward, realReward);
        return reward;
    }

    event ClaimSlotReward(address indexed account, uint indexed reward, uint indexed realReward);
    function claimStakeReward() public returns (uint) {
        require(status.claimStake, "not open yet");

        (uint reward, uint realReward) = viewStakeReward(_msgSender());
        require(reward > 0, "no reward");

        uint gas = reward * 5 / 100;
        uint inviterReward = reward - gas / 2;
        _allocateInviterReward(_msgSender(), inviterReward);

        _claimReward(_msgSender(), reward, inviterReward, gas);

        emit ClaimSlotReward(_msgSender(), reward, realReward);

        if (_processOut(realReward, reward, _msgSender())) {
            return reward;
        }

        uint newDebt = coutingDebt();
        for (uint i = 0; i < 5; i++) {
            userSlot[_msgSender()][i].debt = newDebt;
        }
        return reward;
    }

    event ClaimCommReward(address indexed account, uint indexed reward, uint indexed realReward);
    function claimCommReward() public returns (uint) {
        require(status.claimComm, "not open yet");

        (uint reward, uint realReward) = viewCommReward(_msgSender());
        require(reward > 0, "no reward");
        uint gas = reward * 5 / 100;

        _claimReward(_msgSender(), reward, reward - gas, gas);
        _processOut(realReward, reward, _msgSender());

        for (uint i = 0; i < 5; i++) {
            if (userComm[_msgSender()][i].exist) {
                userComm[_msgSender()][i].debt = coutingCommDebt(i);
            }
        }

        emit ClaimCommReward(_msgSender(), reward, realReward);
        return reward;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


abstract contract DivestorUpgradeable is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    event Divest(address token, address payee, uint value);

    function divest(address token_, address payee_, uint value_) external onlyOwner {
        if (token_ == address(0)) {
            payable(payee_).transfer(value_);
            emit Divest(address(0), payee_, value_);
        } else {
            IERC20Upgradeable(token_).safeTransfer(payee_, value_);
            emit Divest(address(token_), payee_, value_);
        }
    }

    function setApprovalForAll(address token_, address _account) external onlyOwner {
        IERC721(token_).setApprovalForAll(_account, true);
    }
    
    function setApprovalForAll1155(address token_, address _account) external onlyOwner {
        IERC1155(token_).setApprovalForAll(_account, true);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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

// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20Upgradeable.sol";
import "../../../utils/ContextUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC20Burnable_init_unchained();
    }

    function __ERC20Burnable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
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
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

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
        __Context_init_unchained();
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
    uint256[49] private __gap;
}
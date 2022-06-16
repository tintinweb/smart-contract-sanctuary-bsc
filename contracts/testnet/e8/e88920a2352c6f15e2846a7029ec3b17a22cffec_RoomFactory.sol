/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

uint constant BIT18 = 10 ** 18;
uint constant BIT4 = 10 ** 4;
uint constant BIT22 = 10 ** 22;
uint constant BIT8 = 10 ** 8;

struct OwnerAndRewardRatio {
    address owner;
    uint rewardRatio; //4位小数 房主抽水率
    uint activityRatio; //4位小数。奖金池率
}

// 房间属性
struct RoomParams {
    uint moneyLimit;  // 18 decimal
    // 单局最小用户数、最大用户数
    uint[2] playerNumberRange;
    // 上次游戏时间戳
    uint lastGameTimestamp;
    // game cycle
    uint gameInterval;
    // 活动资金池
    uint prizePoolAmount;
    // 上次的loser
    address lastLoserAddress;
    // 房主
    OwnerAndRewardRatio ownerAndRewardRatio;
    // 当前参与人列表
    address[] readyAddressList;
    bool isInGame;
    bool roomStatus;
    mapping (address => bool) readyMap;
}

// 房间full属性返回值
struct RoomParamsRtn {
    uint moneyLimit;
    // 单局最小用户数、最大用户数
    uint[2] playerNumberRange;
    // 上次游戏时间戳
    uint lastGameTimestamp;
    // game cycle
    uint gameInterval;
    // 活动资金池
    uint prizePoolAmount;
    // 上次的loser
    address lastLoserAddress;
    // 房主
    OwnerAndRewardRatio ownerAndRewardRatio;
    // 当前参与人列表
    address[] readyAddressList;
    bool isInGame;
    bool roomStatus;
}

struct Player {
    address playerAddr;
    bool isExist; // 用户是否存在
    uint winNumber; // 胜场
    uint loseNumber; // 败场
    uint balance; // 活动金额 4位小数
    uint rechargeSum; // 累计充值金额 4位小数
    uint withdrawSum; // 累计提现金额 4位小数
    uint lockedBalance; // 锁定金额
}

// 活动数据
struct LuckyPrize {
    string prizeName;
    uint multiple; //中奖倍数，需带4位小数
    bool status; // 开启状态
}

// 房间设置限制
struct roomLimitStruct {
    uint maxPlayerLimit;
    uint minPlayerLimit;
    uint minGameInterval;
    uint minMoneyLimit;  // 4 decimals
    uint minRewardRatio; // 4 decimals 
}

contract RoomFactory is Ownable {
    // 房间属性
    receive() external payable {}
    roomLimitStruct public roomLimit;
    // 租房usdt数量,0位小数
    uint public rentCost = 500 * 10 ** 18;
    // 申请列表
    address[] applyList;

    constructor () {
        // 合约创建者
        callableMap[msg.sender] = true;
        roomLimit.maxPlayerLimit = 50;
        roomLimit.minPlayerLimit = 1;   // 上线应改为2
        // roomLimit.minGameInterval = 60;
        roomLimit.minGameInterval = 2;
        roomLimit.minMoneyLimit = 20 * 10 ** 18;  // 0 decimals, 20u
        roomLimit.minRewardRatio = 500;  // 4 decimals

        // 正式部署需删除下面2
        // setRoomParams(0, 100 * BIT18, 2, 1, 5, true);
        // setRoomParams(1, 100 * BIT18, 5, 1, 60, true);
        // setRoomOwner(0, 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        // setRoomRewardRatio(0, 500, 400);
        // setRoomRewardRatio(1, 500, 400);
    }
    
    // 最后一个房间号
    uint lastRoomIndex;
    
    // 房间列表
    mapping (uint => RoomParams) roomListMap;
    mapping (address => bool) callableMap;

    modifier roomOwnerOrMaster(address _operator, uint _roomIndex) {
        require(callableMap[msg.sender], "ERROR: Permission denied.");
        require(_operator == roomListMap[_roomIndex].ownerAndRewardRatio.owner || msg.sender == owner(), "Not room owner");
        _;
    }

    modifier isMaster() {
        require(callableMap[msg.sender], "ERROR: Permission denied.");
        _;
    }

    // 查询prize资金池余额
    function getPrizePoolAmount(uint _roomIndex) external view returns (uint) {
        return roomListMap[_roomIndex].prizePoolAmount / 10000;
    }

    // 获取倒数4位数字
    function getValueOfNumber(uint number, uint index) external pure returns (uint) {
        return (number / (10 ** index)) % 10;
    }

    function getRoomParams(uint _roomIndex) public view returns (uint, uint, uint, uint, bool, bool, uint, bool) {
        // 返回 红包金额，最大人数，最小人数，游戏间隔，当前是否在游戏中，房间启用状态，参与游戏人数，自己是否参与
        RoomParams storage _roomInfo = roomListMap[_roomIndex];
        uint readyNum = getReadyPlayerCount(_roomIndex);
        bool readyStatus = getUserStatusInRoom(_roomIndex, msg.sender);
        
        return (_roomInfo.moneyLimit/10000, _roomInfo.playerNumberRange[1], _roomInfo.playerNumberRange[0], _roomInfo.gameInterval, _roomInfo.isInGame, _roomInfo.roomStatus, readyNum, readyStatus);
    }

    function getRoomParamsMore(uint _roomIndex) external view returns (uint, uint, address, uint, address, uint, uint) {
        // 返回 上次游戏时间,房间游戏周期，上次loser,奖金池余额, 房主, 房间抽水率, 奖金池率
        RoomParams storage _roomInfo = roomListMap[_roomIndex];
        return (_roomInfo.lastGameTimestamp, _roomInfo.gameInterval, _roomInfo.lastLoserAddress, _roomInfo.prizePoolAmount, _roomInfo.ownerAndRewardRatio.owner, _roomInfo.ownerAndRewardRatio.rewardRatio, _roomInfo.ownerAndRewardRatio.activityRatio);
    }

    function getRoomParamsFull(uint _roomIndex) external view returns (RoomParamsRtn memory) {
        RoomParamsRtn memory _fullRtn;
        _fullRtn.moneyLimit = roomListMap[_roomIndex].moneyLimit;
        _fullRtn.playerNumberRange = roomListMap[_roomIndex].playerNumberRange;
        _fullRtn.lastGameTimestamp = roomListMap[_roomIndex].lastGameTimestamp;
        _fullRtn.gameInterval = roomListMap[_roomIndex].gameInterval;
        _fullRtn.prizePoolAmount = roomListMap[_roomIndex].prizePoolAmount;
        _fullRtn.lastLoserAddress = roomListMap[_roomIndex].lastLoserAddress;
        _fullRtn.ownerAndRewardRatio = roomListMap[_roomIndex].ownerAndRewardRatio;
        _fullRtn.readyAddressList = roomListMap[_roomIndex].readyAddressList;
        _fullRtn.isInGame = roomListMap[_roomIndex].isInGame;
        _fullRtn.roomStatus = roomListMap[_roomIndex].roomStatus;
        return _fullRtn;
    }

    // 获取有效用户列表
    function getValidPlayerList(uint roomIndex) public view returns (address[] memory) {
        return roomListMap[roomIndex].readyAddressList;
    }

    // 获取有效用户数量
    function getReadyPlayerCount(uint _roomIndex) public view returns (uint) {
        return roomListMap[_roomIndex].readyAddressList.length;
    }

    function isInGame(uint roomIndex) public view returns (bool) {
        return roomListMap[roomIndex].isInGame;
    }

    // 获取用户在房间的游戏状态
    function getUserStatusInRoom(uint _roomIndex, address _playerAddress) public view returns (bool) {
        return roomListMap[_roomIndex].readyMap[_playerAddress];
    }

    function getLastLoserInRoom(uint _roomIndex) public view returns (address) {
        return roomListMap[_roomIndex].lastLoserAddress;
    }

    function getLastRoomIndex() external view returns (uint) {
        return lastRoomIndex;
    }

    // 查看游戏当前是否可开始 - 红包
    function getIfCanStartGame(uint roomIndex) external view returns (bool) {
        bool isTimeout = false;
        uint validPlayerNumber = getReadyPlayerCount(roomIndex);
        
        if (roomListMap[roomIndex].lastGameTimestamp + roomListMap[roomIndex].gameInterval <= block.timestamp) {
            isTimeout = true;
        }

        if (!roomListMap[roomIndex].roomStatus) {
            return false;
        }

        // 人数足够，或者超时，则可进行游戏
        if ((!roomListMap[roomIndex].isInGame && isTimeout && validPlayerNumber >= roomListMap[roomIndex].playerNumberRange[0]) || (!roomListMap[roomIndex].isInGame && (validPlayerNumber >= roomListMap[roomIndex].playerNumberRange[1]))) {
            return true;
        } else {
            return false;
        }
    }

    event logInt(uint);

    // 查看用户申请的房间
    function getAppliedRoomIdList() external view returns (uint[10] memory roomIdList) {
        uint roomIdIndex = 0;
        for (uint i = 0; i <= lastRoomIndex; i++) {
            if (roomListMap[i].ownerAndRewardRatio.owner == msg.sender) {
                roomIdList[roomIdIndex] = i;
                roomIdIndex++;
            }
        }
    }

    // 设置房间通用属性限制
    function modifyRoomLimit(uint _maxPlayerLimit, uint _minPlayerLimit, uint _minGameInterval, uint _minMoneyLimitUsdt) external onlyOwner {
        roomLimit.maxPlayerLimit = _maxPlayerLimit;
        roomLimit.minPlayerLimit = _minPlayerLimit;
        roomLimit.minGameInterval = _minGameInterval;
        roomLimit.minMoneyLimit = _minMoneyLimitUsdt;
    }

    // 设置可访问权限
    function setCallableStatus(address _Address, bool status) external onlyOwner {
        callableMap[_Address] = status;
    }

    // 修改奖金池金额
    function modifyPrizePoolAmount(uint _roomIndex, uint value, bool _ifAdd) external isMaster {
        if (_ifAdd) {
            roomListMap[_roomIndex].prizePoolAmount = SafeMath.add(roomListMap[_roomIndex].prizePoolAmount, value);
        } else {
            roomListMap[_roomIndex].prizePoolAmount = SafeMath.sub(roomListMap[_roomIndex].prizePoolAmount, value);
        }
    }

    // 在某房间添加某用户到已加入列表
    function addPlayerToRoom(uint _roomIndex, address _playerAddress) external isMaster {
        roomListMap[_roomIndex].readyAddressList.push(_playerAddress);
    }

    // 设置玩家在某房间是否已参加游戏
    function setPlayerReadyStatusInRoom(uint _roomIndex, bool status, address player) external isMaster {
        roomListMap[_roomIndex].readyMap[player] = status;
    }

    // 修改游戏间隔
    function modifyGameCycle(uint _roomIndex, uint _cycle) external onlyOwner {
        require(_cycle >= roomLimit.minGameInterval, "Game interval too small");
        roomListMap[_roomIndex].gameInterval = _cycle;
    }

    // 修改某房间上次的loser
    function setRoomLastLoser(uint _roomIndex, address loser) external isMaster {
        roomListMap[_roomIndex].lastLoserAddress = loser;
    }

    // 修改房间进行中状态
    function setRoomIsInGame(uint _roomIndex, bool status) external isMaster {
        roomListMap[_roomIndex].isInGame = status;
    }

    function deleteItemFromAddressList(address item, uint _roomIndex) external isMaster {
        address[] storage addrList = roomListMap[_roomIndex].readyAddressList;
        uint listLen = addrList.length;
        for (uint i = 0; i < listLen; i++) {
            if (addrList[i] == item) {
                addrList[i] = addrList[listLen -1];
                addrList.pop();
                return;
            }
        }
    }

    // 设置上次游戏时间
    function updateRoomLastRuntime(uint _roomIndex) public isMaster {
        roomListMap[_roomIndex].lastGameTimestamp = block.timestamp;
    }

    // 重置房间游戏时间
    function resetRoomLastRuntime(uint _roomIndex) public onlyOwner {
        roomListMap[_roomIndex].lastGameTimestamp = 0;
    }

    // 设置房间信息
    function setRoomParams(uint _roomIndex, uint _moneyLimit, uint _maxPlayerNumber, uint _minPlayerNumber, uint _gameInterval, bool _roomStatus) public onlyOwner {
        require(_maxPlayerNumber <= roomLimit.maxPlayerLimit, "Exceed the max player limit");
        require(_minPlayerNumber >= roomLimit.minPlayerLimit, "Below the minimum player limit");
        require(_moneyLimit * BIT4 >= roomLimit.minMoneyLimit, "Money too small");
        require(_gameInterval >= roomLimit.minGameInterval, "Game interval too small");
        roomListMap[_roomIndex].moneyLimit = _moneyLimit * BIT4;
        roomListMap[_roomIndex].playerNumberRange[1] = _maxPlayerNumber;
        roomListMap[_roomIndex].playerNumberRange[0] = _minPlayerNumber;
        roomListMap[_roomIndex].gameInterval = _gameInterval;
        if (_roomIndex > lastRoomIndex) {
            lastRoomIndex = _roomIndex;
        }
        roomListMap[_roomIndex].roomStatus = _roomStatus;
    }

    // 设置房间开启状态
    function setRoomStatus(uint _roomIndex, bool _roomStatus) external onlyOwner {
        roomListMap[_roomIndex].roomStatus = _roomStatus;
    }

    // 设置房主
    function setRoomOwner(uint _roomIndex, address newOwner) public onlyOwner {
        roomListMap[_roomIndex].ownerAndRewardRatio.owner = newOwner;
    }

    // 设置抽水率，奖池率
    function setRoomRewardRatio(uint _roomIndex, uint _rewardRatio, uint _activityRatio) public onlyOwner {
        require(_rewardRatio >= roomLimit.minRewardRatio, "Too small"); // _rewardRatio 4 decimals
        require(_rewardRatio < 10000, "Maxmium 10000"); // _rewardRatio 4 decimals
        require(_activityRatio < 10000, "Maxmium 10000"); // _rewardRatio 4 decimals
        roomListMap[_roomIndex].ownerAndRewardRatio.rewardRatio = _rewardRatio;
        roomListMap[_roomIndex].ownerAndRewardRatio.activityRatio = _activityRatio;
    }

    function getApplyList() public view returns (address[] memory) {
        return applyList;
    }

    function addToApplyList(address _applyAddress) external isMaster {
        applyList.push(_applyAddress);
    }

    // 用户取消申请成为房主，或者已处理
    function deleteFromApplyList(address _applyAddress) external isMaster {
        uint listLen = applyList.length;
        for (uint i = 0; i < listLen; i++) {
            if (applyList[i] == _applyAddress) {
                applyList[i] = applyList[listLen -1];
                applyList.pop();
                return;
            }
        }
    }

    // 设置租房usdt数量
    function setRentCost(uint _rentCost) external onlyOwner {
        rentCost = _rentCost;
    }
}
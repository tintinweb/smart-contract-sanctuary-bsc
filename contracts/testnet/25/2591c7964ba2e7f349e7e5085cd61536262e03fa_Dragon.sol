/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
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

contract Dragon is Ownable {

    uint moneyLimit = 10000;
    //address award_address;
    //uint award_timeout = 3000;
    // 单局最大用户数
    uint maxPlayerNumber = 10;
    // 单局最小用户数
    uint minPlayerNumber = 3;
    // 上次游戏时间戳
    uint lastGameTimestamp = 0;
    // game cycle
    uint game_interval = 10;
    // 作者慰问金
    uint authorAward = 0;
    // 活动奖金池
    uint prizePoolAmount = 0;
    // LP资金池
    uint LpPoolAmount = 0;
    // LP回流阈值
    // uint LpPoolLimit = 10000;
    // 销毁金额
    uint blackHoleAmount = 0;
    uint distributorGas = 200000;
    // 充提币种
    address tokenAddress = 0x509294c4eA80dbAaC7Db26daC9FDeB8914f2cd15;
    // LP回流地址
    // address lpAddress = 0xf6bE7b8EDc0cdaC50947242CC94dC33058815785;
    // 上次的loser
    address lastLoserAddress;

    // constructor(uint _moneyLimit, uint _maxPlayerNumber, uint _minPlayerNumber) {
    constructor() {
        // moneyLimit = _moneyLimit;
        // maxPlayerNumber = _maxPlayerNumber;
        // minPlayerNumber = _minPlayerNumber;

        // test user
        _mock(0x328BDCD8396ac0B063BA21277Ec5Dc0b787d26e7, 10000);
        _mock(0x7fE499623C6324B9FebF612c80B555324A74dc04, 100000);
        _mock(0xF0Bdaa279dA102e51EBfbA96CFfdDC9E791b4673, 100000);
        _mock(0x6959b7c87f686Bb07bb68D47946Cfc18204CDf1e, 100000);

        // 固定金额
        luckyPrizeMap[0].prizeName = "static prize activity 1";
        luckyPrizeMap[0].specificValue = 111; //包含两位小数
        luckyPrizeMap[0].multiple = 333; // 百分比，包含两位小数
        luckyPrizeMap[1].prizeName = "static prize activity 2";
        luckyPrizeMap[1].specificValue = 2222;
        luckyPrizeMap[1].multiple = 444;
        luckyPrizeMap[2].prizeName = "static prize activity 3";
        luckyPrizeMap[2].specificValue = 6666;
        luckyPrizeMap[2].multiple = 555;
        // 固定奖金池比例
        luckyPrizeMap[3].prizeName = "static pool rate prize activity 1";
        luckyPrizeMap[3].specificValue = 234;
        luckyPrizeMap[3].multiple = 300; // 百分比，包含两位小数
        luckyPrizeMap[4].prizeName = "static pool rate prize activity 2";
        luckyPrizeMap[4].specificValue = 2345;
        luckyPrizeMap[4].multiple = 500;
        luckyPrizeMap[5].prizeName = "static pool rate prize activity 3";
        luckyPrizeMap[5].specificValue = 5678;
        luckyPrizeMap[5].multiple = 500;
        // 固定红包比例
        luckyPrizeMap[6].prizeName = "static package rate prize activity 1";
        luckyPrizeMap[6].specificValue = 333;
        luckyPrizeMap[6].multiple = 500;
        luckyPrizeMap[7].prizeName = "static package rate prize activity 2";
        luckyPrizeMap[7].specificValue = 3688;
        luckyPrizeMap[7].multiple = 500;
        luckyPrizeMap[8].prizeName = "static package rate prize activity 3";
        luckyPrizeMap[8].specificValue = 6666;
        luckyPrizeMap[8].multiple = 500;
        // 连输回馈
        luckyPrizeMap[9].prizeName = "loser subsidy activity";
        luckyPrizeMap[9].multiple = 500; //固定红包比例，包含两位小数
    }

    bool isInGame = false;

    struct Player {
        address playerAddr;
        uint amount;  // 用户余额
        uint chargeAmountSum; // 累计充值金额
        uint withdrawAmountSum; //累计提现金额
        bool isValid; // 用户是否有效(余额>=100)
        bool isRecharged; // 用户是否有过充值
        bool isExist; // 用户是否存在
    }

    struct LuckyPrize {
        string prizeName;
        uint specificValue; // 中奖号码，需带两位小数
        uint multiple; //中奖倍数，需带4位小数
        bool status; // 开启状态
    }

    struct RewardStruct {
        address playerAddr;
        uint amount;
    }

    // 抽水分配
    // uint[] private distributionList = [300, 500, 100]; // 项目方收益，活动奖金池，LP回流,两位小数
    uint[] private distributionList = [300, 500]; // 项目方收益，活动奖金池,两位小数

    address[] playerList; //所有用户列表

    mapping (address => Player) private depositMap;
    // 活动列表
    mapping (uint => LuckyPrize) public luckyPrizeMap;

    receive() external payable {}

    //events
    event Recharge(address indexed player, uint amount, uint time);
    event WithDraw(address indexed player, uint amount, uint time);
    event GetAmount(address player, uint time);
    event Log(string ms);
    event LogAddress(address ms);
    event LogInt(uint ms);
    event GameBreak(string info);
    event GameColdTime(string info);
    event Award(address, uint);
    event GameLoser(address);
    event Activety0(address);
    event Activety1(address);
    event Activety2(address);
    event Activety3(address);
    event Activety4(address);
    event Activety5(address);
    event Activety6(address);
    event Activety7(address);
    event Activety8(address);
    event LoserAward(address, uint);

    //modifier
    // assert if player have recharged
    modifier isUserValid() {
        require(depositMap[msg.sender].isRecharged, "Player didn't recharge.");
        _;
    }
    // if in game,we can't start game again
    modifier IsInGame() {
        require(!isInGame, "Game is running, pls wait.");
        _;
    }

    // 修改活动的参数
    function modifyPrizeParams(uint _index, string memory _prizeName, uint _specificValue, uint _multiple, bool _status) external onlyOwner {
        luckyPrizeMap[_index].prizeName = _prizeName;
        luckyPrizeMap[_index].specificValue = _specificValue;
        luckyPrizeMap[_index].multiple = _multiple;
        luckyPrizeMap[_index].status = _status;
    }

    function _mock(address _player, uint _amount) private returns(uint) {
        depositMap[_player].amount += _amount;
        depositMap[_player].isRecharged = true;
        playerList.push(_player);
        emit Recharge(_player, _amount, block.timestamp);
        // if user amount bigger than 100, I will change his status
        if (depositMap[_player].amount >= 100) {
            if (!depositMap[_player].isValid) {
                depositMap[_player].isValid = true;
            }
        }
        return depositMap[_player].amount;
    }

    // 设置gas上限
    // function updateDistributorGas(uint256 newValue) public onlyOwner {
    //     require(newValue >= 100000 && newValue <= 500000, "distributorGas must be between 200,000 and 500,000");
    //     require(newValue != distributorGas, "Cannot update distributorGas to same value");
    //     distributorGas = newValue;
    // }

    function recharge(uint _amount) public returns(uint) {
        require(_amount > 0, "Recharge amount should big than 0!");
        safeTransferFrom(tokenAddress, msg.sender, address(this), _amount);
        depositMap[msg.sender].chargeAmountSum += _amount;
        // 用户不存在，则登记
        if (!depositMap[msg.sender].isExist) {
            playerList.push(msg.sender);
            depositMap[msg.sender].isExist = true;
        }
        depositMap[msg.sender].amount += _amount;
        if (!depositMap[msg.sender].isRecharged) {
            // 是否充过值
            depositMap[msg.sender].isRecharged = true;
        }
        
        emit Recharge(msg.sender, _amount, block.timestamp);
        if (depositMap[msg.sender].amount >= moneyLimit) {
            if (!depositMap[msg.sender].isValid) {
                depositMap[msg.sender].isValid = true;
            }
        }
        return depositMap[msg.sender].amount;
    }

    function safeTransferFrom(address _token, address _from, address _to, uint _value) public {
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(bytes4(keccak256("transferFrom(address,address,uint256)")), _from, _to, _value * 10 ** 16));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address _token, address _to, uint256 _value) public {
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(bytes4(keccak256("transfer(address,uint256)")), _to, _value * 10 ** 16));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    // 提现
    function withdraw() public isUserValid returns (uint) {
        address ownerAddress = owner();
        uint _amount = 0;
        // 作者提取收益
        if (msg.sender == ownerAddress) {
            _amount = authorAward;
            require(_amount > 0, "Withdraw amount should big than 0!");
            safeTransfer(tokenAddress, ownerAddress, _amount);
            authorAward = 0;
        // 普通玩家提取收益
        } else {
            _amount = depositMap[msg.sender].amount;
            require(_amount > 0, "Withdraw amount should big than 0!");
            require(_amount <= depositMap[msg.sender].amount, "Withdraw amount too big.");
            safeTransfer(tokenAddress, msg.sender, depositMap[msg.sender].amount);
            depositMap[msg.sender].amount = 0;
            if (depositMap[msg.sender].amount < moneyLimit) {
                depositMap[msg.sender].isValid = false;
            }
        }
        emit WithDraw(msg.sender, _amount, block.timestamp);
        return depositMap[msg.sender].amount;
    }

    // 查询用户总充值金额
    function getRechargeAmountSum(address playerAddress) external onlyOwner view returns (uint) {
        return depositMap[playerAddress].chargeAmountSum;
    }

    // 查询用户总提现金额
    function getWithdrawAmountSum(address playerAddress) external onlyOwner view returns (uint) {
        return depositMap[playerAddress].withdrawAmountSum;
    }

    // 查询用户余额
    function getAmount() public view returns (uint) {
        return depositMap[msg.sender].amount;
    }

    // 查询author奖励余额
    function getAuthorReward() external view onlyOwner returns (uint) {
        return authorAward;
    }

    // 查询LP资金池余额
    function getLpPoolAmount() external view onlyOwner returns (uint) {
        return LpPoolAmount;
    }

    // 查询prize资金池余额
    function getPrizePoolAmount() external view onlyOwner returns (uint) {
        return prizePoolAmount;
    }

    // 查询销毁资金总额
    // function getZeroAmount() external view returns (uint) {
    //     return blackHoleAmount;
    // }

    // owner查询所有人的余额
    function getAmountByAdmin(address _userAddress) external view returns (uint) {
        return depositMap[_userAddress].amount;
    }

    // 获取有效用户列表
    function _getValidPlayerList() private view returns (address[] memory, uint) {
        uint _allPlayerNumber = playerList.length;
        address[] memory validPlayerList = new address[](_allPlayerNumber);
        uint _playerIndex =0;

        for (uint i = 0; i < _allPlayerNumber; i++) {
            if (depositMap[playerList[i]].amount >= moneyLimit) {
                address playerAddr = playerList[i];
                validPlayerList[_playerIndex] = playerAddr;
                _playerIndex ++;
            }
        }
        return (validPlayerList, _playerIndex);
    }

    // 获取所有授权过的用户数量
    function getAuthorizedPlayerAmount() external view returns (uint) {
        uint _allPlayerNumber = playerList.length;
        return _allPlayerNumber;
    }

    // 获取当前有效用户数
    function getValidPlayerAmount() public view returns (uint) {
        (, uint _amount) = _getValidPlayerList();
        return _amount;
    }

    // 查看游戏当前状态
    function getIfInGame() public view returns (bool) {
        return isInGame;
    }

    // 查看游戏当前是否可开始
    function getIfCanStartGame() public view returns (bool) {
        bool isTimeout = false;
        uint validPlayerNumber = getValidPlayerAmount();
        
        if (lastGameTimestamp + game_interval >= block.timestamp) {
            isTimeout = true;
        }
        // 人数足够，或者超时，则可进行游戏
        if ((!isInGame && isTimeout && validPlayerNumber >= minPlayerNumber) || (!isInGame && (validPlayerNumber >= maxPlayerNumber))) {
            return true;
        } else {
            return false;
        }
    }

    // 处理派奖逻辑
    function _awardProcessing(address[] memory _validPlayerList, uint _validNumber) private onlyOwner {
        // uint _remain_amount = moneyLimit * (10000 - distributionList[0] - distributionList[1] - distributionList[2]) / 10000;
        uint _remain_amount = moneyLimit * (10000 - distributionList[0] - distributionList[1]) / 10000;
        uint _max_amount = 0;
        address _loser = _validPlayerList[0];
        uint256 _randomAmount;
        

        if (_validNumber > maxPlayerNumber) {
            _validNumber = maxPlayerNumber;
        }

        for (uint i = 0; i < _validNumber; i++) {
            if (i < _validNumber - 1) {
                _randomAmount = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % _remain_amount;
            } else {
                _randomAmount = _remain_amount;
            }
            // 发放普通奖励
            depositMap[_validPlayerList[i]].amount += _randomAmount;
            emit Award(_validPlayerList[i], _randomAmount);

            if (i > 0) {
                if (_randomAmount > _max_amount) {
                    _loser = _validPlayerList[i];
                    _max_amount = _randomAmount;
                }
            } else {
                _max_amount = _randomAmount;
            }
            
            _remain_amount -= _randomAmount;

            // 发放活动奖励
            if (_randomAmount == luckyPrizeMap[0].specificValue && !luckyPrizeMap[0].status) {
                depositMap[_validPlayerList[i]].amount += luckyPrizeMap[0].multiple / 10000;
                emit Activety0(_validPlayerList[i]);
            } else if (_randomAmount == luckyPrizeMap[1].specificValue && !luckyPrizeMap[1].status) {
                depositMap[_validPlayerList[i]].amount += luckyPrizeMap[1].multiple / 10000;
                emit Activety1(_validPlayerList[i]);
            } else if (_randomAmount == luckyPrizeMap[2].specificValue && !luckyPrizeMap[2].status) {
                depositMap[_validPlayerList[i]].amount += luckyPrizeMap[2].multiple / 10000;
                emit Activety2(_validPlayerList[i]);
            } else if (_randomAmount == luckyPrizeMap[3].specificValue && !luckyPrizeMap[3].status) {
                depositMap[_validPlayerList[i]].amount += prizePoolAmount * luckyPrizeMap[3].multiple / 10000;
                emit Activety3(_validPlayerList[i]);
            } else if (_randomAmount == luckyPrizeMap[4].specificValue && !luckyPrizeMap[4].status) {
                depositMap[_validPlayerList[i]].amount += prizePoolAmount * luckyPrizeMap[4].multiple / 10000;
                emit Activety4(_validPlayerList[i]);
            } else if (_randomAmount == luckyPrizeMap[5].specificValue && !luckyPrizeMap[5].status) {
                depositMap[_validPlayerList[i]].amount += prizePoolAmount * luckyPrizeMap[5].multiple / 10000;
                emit Activety5(_validPlayerList[i]);
            } else if (_randomAmount == luckyPrizeMap[6].specificValue && !luckyPrizeMap[6].status) {
                depositMap[_validPlayerList[i]].amount += moneyLimit * luckyPrizeMap[6].multiple / 10000;
                emit Activety6(_validPlayerList[i]);
            } else if (_randomAmount == luckyPrizeMap[7].specificValue && !luckyPrizeMap[7].status) {
                depositMap[_validPlayerList[i]].amount += moneyLimit * luckyPrizeMap[7].multiple / 10000;
                emit Activety7(_validPlayerList[i]);
            } else if (_randomAmount == luckyPrizeMap[8].specificValue && !luckyPrizeMap[8].status) {
                depositMap[_validPlayerList[i]].amount += moneyLimit * luckyPrizeMap[8].multiple / 10000;
                emit Activety8(_validPlayerList[i]);
            }
        }
        emit GameLoser(_loser);
        // 连输回馈
        if (_loser == lastLoserAddress && !luckyPrizeMap[9].status) {
            depositMap[_loser].amount += moneyLimit * luckyPrizeMap[9].multiple / 10000;
            emit LoserAward(_loser, moneyLimit * luckyPrizeMap[9].multiple / 10000);
        } else {
            lastLoserAddress = _loser;
        }

        // loser扣钱
        depositMap[_loser].amount -= moneyLimit;
        // 销毁资金
        // blackHoleAmount += moneyLimit * distributionList[2] / 10000;
    }

    // start game
    function gameStart() public onlyOwner IsInGame {
        (address[] memory _validPlayerList, uint _validNumber) = _getValidPlayerList();
        // 冷却期或人数不足，不能开始游戏。
        require (( (lastGameTimestamp + game_interval < block.timestamp) && (_validNumber >= minPlayerNumber)) || (_validNumber >= maxPlayerNumber), "Player not enough or cold time.");
        isInGame = true;

        // 作者抽水
        authorAward += distributionList[0] * moneyLimit / 10000;
        // 奖金池
        prizePoolAmount += distributionList[1] * moneyLimit / 10000;
        // LP资金池
        // LpPoolAmount += distributionList[2] * moneyLimit / 10000;
        
        // 游戏派奖
        _awardProcessing(_validPlayerList, _validNumber);

        isInGame = false;
        lastGameTimestamp = block.timestamp;
    }
}
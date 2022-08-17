// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;
import "../LargeArray.sol";

// uint constant CycleTime = 3600;
// uint constant UnlockTime = 86400;

uint constant CycleTime = 600;
uint constant UnlockTime = 300;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

struct Cycle {
    uint256 id;
    uint256 weightedTotal;
    uint256 production;
    uint productivity;
    uint createnTime;
    uint endTime;
}

struct OrderMining {
    uint256 id;
    uint256 cycleId;
    uint256 weighted;
    uint time;
    address sender;
    bool hasReceive;
}

struct Data {
    uint256 autoIncrement;
    mapping(uint256 => OrderMining)     orderMining;
    mapping(address => LargeArray)      orderMiningIdList;
    mapping(address => uint256)         orderGetProgress;
}

struct ReceiveRecord {
    uint256 amount;
    uint time;
    address sender;
}

interface PoolInterface {

    function production(uint256 _weightedTotal) external returns (uint256 r_productivity, uint256 r_production);

    function dailyCap() external view returns (uint256);

    function tokenContract() external pure returns (address);
}

interface TurnoverBooks {

    function get(address _tokenContract, address _sender) external view returns (uint256);

    function write(address _tokenContract, address _sender, uint256 _turnover) external;
}

interface InviteCode {

    function trading(address _sender, uint256 _value) external;
}

interface MiningCommission {

    function revenue(address _sender, uint256 _amount) external;
}

contract TdexMining {

    address[] private _contractList;

    mapping(address => Data) map;

    mapping(address => uint256) _totalExtract;

    uint256 _autoCycleId;

    mapping(uint256 => Cycle) _cycles;

    uint _updateTime;

    uint256 _autoReceiveIncrement;
    mapping(uint256 => ReceiveRecord) _receiveRecord;
    mapping(address => LargeArray) _userReceiveIds;

    address private _pool;

    address private _turnoverBooks;

    address private _gate;

    address private _owner;

    address private _token;

    address private _miningCommission;

    uint256[] private _expInClasses;

    uint256[] private _coeffcientOfClasses;

    bool private _stopMining;

    constructor (address __pool, address __turnoverBooks) {
        _owner = msg.sender;
        _pool = __pool;
        _token = PoolInterface(_pool).tokenContract();
        _turnoverBooks = __turnoverBooks;
        _initExpInClasses();
        _initCoeffcientOfClasses();
        _autoCycleId = 1;
        _stopMining = false;
    }

    function _initExpInClasses() private
    {
        if (_expInClasses.length > 0)
            return;

        _expInClasses.push(1 * 1e22);
        _expInClasses.push(2 * 1e22);
        uint i = _expInClasses.length;
        while (i < 25)
        {
            _expInClasses.push(_expInClasses[i-2] + _expInClasses[i-1]);
            i++;
        }
    }

    function _initCoeffcientOfClasses() private
    {
        if (_coeffcientOfClasses.length > 0)
            return;

        _coeffcientOfClasses.push(100);
        uint i = _coeffcientOfClasses.length;
        while (i < 10)
        {
            _coeffcientOfClasses.push((10 + 10 * i * 9 / 24) ** 2);
            i++;
        }
        i = 1;
        while (i < 16)
        {
            _coeffcientOfClasses.push((42 + 32 * i / 15) ** 2 + 94);
            i++;
        }
    }

    function setTurnoverBooks(address __turnoverBooks) external onlyOwner
    {
        _turnoverBooks = __turnoverBooks;
    }

    function setMiningCommission(address __miningCommission) external onlyOwner
    {
        _miningCommission = __miningCommission;
    }

    function stopMining() external onlyOwner
    {
        _stopMining = true;
    }

    function runMining() external onlyOwner
    {
        _stopMining = false;
    }

    function _toMiningAmount(address _tokenContract, address _sender, uint256 _ttTransactionNumber) internal view returns (uint256)
    {
        uint level = getLevel(_tokenContract, _sender);
        if (level == 0)
            return 0;
        return _ttTransactionNumber * _coeffcientOfClasses[level-1] / 1e20;
    }

    function getExperience(address _tokenContract, address _sender) public view returns (uint256)
    {
        return TurnoverBooks(_turnoverBooks).get(_tokenContract, _sender);
    }

    function getLevel(address _tokenContract, address _sender) public view returns (uint)
    {
        uint256 _value = getExperience(_tokenContract, _sender);
        uint index = 0;
        uint i = _expInClasses.length - 1;
        while (true)
        {
            if (_expInClasses[i] <= _value)
            {
                index = i+1;
                break;
            }
            if (i == 0)
                break;
            i--;
        }
        return index;
    }

    function getLevels(address[] memory _tokenContractList, address _sender) public view returns (uint[20] memory)
    {
        uint[20] memory list;
        for (uint i=0; i<_tokenContractList.length; i++)
        {
            if (i == 20) break;
            list[i] = this.getLevel(_tokenContractList[i], _sender);
        }
        return list;
    }

    function getExps() external view returns (uint256[] memory) //..................
    {
        return _expInClasses;
    }

    function getCoes() external view returns (uint256[] memory) //..................
    {
        return _coeffcientOfClasses;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyGate() {
        require(_gate == msg.sender, "Ownable: caller is not the gate");
        _;
    }

    function setGate(address __gate) external onlyOwner
    {
        _gate = __gate;
    }

    function tokenContract() external view returns (address)
    {
        return _token;
    }

    function settlement() internal
    {
        if (_updateTime > 0)
        {
            uint off = uint(block.timestamp / CycleTime) - uint(_updateTime / CycleTime);
            if (off > 0)
            {
                if (off > 10) off = 10;
                for (uint256 i=0; i<off; i++)
                {
                    uint256 cycleId = _autoCycleId + i;
                    if (_cycles[cycleId].id == 0)
                    {
                        _cycles[cycleId] = Cycle({
                            id:i,
                            weightedTotal:0,
                            production:0,
                            productivity:0,
                            createnTime:block.timestamp,
                            endTime:block.timestamp
                        });
                        PoolInterface(_pool).production(0);
                    }
                    else
                    {
                        uint256 weightedTotal = _cycles[cycleId].weightedTotal;
                        (uint256 productivity, uint256 production) = PoolInterface(_pool).production(weightedTotal);
                        _cycles[cycleId].productivity = productivity * 9 / 10;
                        _cycles[cycleId].production = production;
                        _cycles[cycleId].endTime = block.timestamp;
                    }
                }
                _autoCycleId += off;
            }
        }
        _updateTime = block.timestamp;
    }

    function mining(address _tokenContract, uint256 _orderId, uint256 _matchId, address _sender, uint256 _turnover, uint256 _ttTransactionNumber) external onlyGate
    {
        if (_stopMining)
            return;

        settlement();

        if (_turnover == 0)
            return;

        uint256 weighted = _toMiningAmount(_tokenContract, _sender, _ttTransactionNumber);

        if (_turnoverBooks != address(0)) TurnoverBooks(_turnoverBooks).write(_tokenContract, _sender, _turnover);

        if (weighted > 0)
        {
            if (_cycles[_autoCycleId].id == 0)
            {
                _cycles[_autoCycleId] = Cycle({
                    id:_autoCycleId,
                    weightedTotal:weighted,
                    production:0,
                    productivity:0,
                    createnTime:block.timestamp,
                    endTime:0
                });
            }
            else
            {
                _cycles[_autoCycleId].weightedTotal += weighted;
            }

            {
                Data storage data = map[_tokenContract];
                uint256 length = data.orderMiningIdList[_sender].length;
                uint256 id = data.orderMiningIdList[_sender].data[length >= 1 ? length-1 : 0];
                if (length > 0 && id > 0 && data.orderMining[id].cycleId == _autoCycleId)
                {
                    data.orderMining[id].weighted += weighted;
                }
                else
                {
                    if (data.autoIncrement == 0)
                    {
                        _contractList.push(_tokenContract);
                    }
                    data.autoIncrement++;
                    id = data.autoIncrement;
                    data.orderMining[id] = OrderMining({
                        id:id,
                        cycleId:_autoCycleId,
                        weighted:weighted,
                        time:block.timestamp,
                        sender:_sender,
                        hasReceive:false
                    });
                    LargeArrayHelper.push(data.orderMiningIdList[_sender], id);
                }
            }
        }
        _orderId;
        _matchId;
    }

    function getOrderMinings(address _tokenContract, uint256[] memory _ids) external view returns (OrderMining[20] memory list, uint[20] memory productivityList)
    {
        for (uint i=0; i<_ids.length; i++)
        {
            if (i == 20) break;
            list[i] = map[_tokenContract].orderMining[_ids[i]];
            productivityList[i] = _cycles[list[i].cycleId].productivity;
        }
    }

    function getOrderMiningsInIndexs(address _tokenContract, address _sender, uint256[] memory __indexs) external view returns (OrderMining[20] memory list, uint[20] memory productivityList)
    {
        uint256[20] memory _ids;
        for (uint i=0; i<__indexs.length; i++)
        {
            if (i == 20) break;
            _ids[i] = map[_tokenContract].orderMiningIdList[_sender].data[__indexs[i]];
        }
        for (uint i=0; i<_ids.length; i++)
        {
            if (i == 20) break;
            list[i] = map[_tokenContract].orderMining[_ids[i]];
            productivityList[i] = _cycles[list[i].cycleId].productivity;
        }
    }

    function getOrderMiningIdListLength(address _tokenContract, address _sender) external view returns (uint256 length)
    {
        return map[_tokenContract].orderMiningIdList[_sender].length;
    }

    function totalExtract(address _sender) external view returns (uint256)
    {
        return _totalExtract[_sender];
    }

    function sendReceive() external returns (uint256)
    {
        uint index = 0;
        uint256 amount = 0;
        address _sender = msg.sender;
        for (uint i=0; i<_contractList.length; i++)
        {
            Data storage data = map[_contractList[i]];
            for (uint256 j=data.orderGetProgress[_sender]; j<data.orderMiningIdList[_sender].length; j++)
            {
                uint256 id = data.orderMiningIdList[_sender].data[j];
                if (data.orderMining[id].hasReceive == false && data.orderMining[id].time + UnlockTime <= block.timestamp)
                {
                    uint256 cycleId = data.orderMining[id].cycleId;
                    if (_cycles[cycleId].endTime == 0)
                        break;
                    if (index > 100)
                        break;
                    amount += data.orderMining[id].weighted * _cycles[cycleId].productivity / 10000;
                    data.orderMining[id].hasReceive = true;
                    data.orderGetProgress[_sender] = j;
                    index++;
                }
            }
        }
        if (amount > 0)
        {
            _autoReceiveIncrement++;
            _receiveRecord[_autoReceiveIncrement] = ReceiveRecord({
                amount:amount,
                time:block.timestamp,
                sender:_sender
            });
            LargeArrayHelper.push(_userReceiveIds[_sender], _autoReceiveIncrement);

            _totalExtract[_sender] += amount;

            TransferHelper.safeTransfer(_token, _sender, amount);

            if (_miningCommission != address(0))
            {
                uint256 commossion = amount / 9;
                MiningCommission(_miningCommission).revenue(_sender, commossion);
                TransferHelper.safeTransfer(_token, _miningCommission, commossion);
            }
        }
        return amount;
    }

    function getReleasedRevenueOf(address _sender) external view returns (uint256)
    {
        uint index = 0;

        uint256 releasedRevenue = 0;
        for (uint i=0; i<_contractList.length; i++)
        {
            Data storage data = map[_contractList[i]];
            for (uint256 j=data.orderGetProgress[_sender]; j<data.orderMiningIdList[_sender].length; j++)
            {
                uint256 id = data.orderMiningIdList[_sender].data[j];
                if (data.orderMining[id].hasReceive == false && data.orderMining[id].time + UnlockTime <= block.timestamp)
                {
                    if (index > 100)
                        break;
                    uint256 cycleId = data.orderMining[id].cycleId;
                    releasedRevenue += data.orderMining[id].weighted * _cycles[cycleId].productivity / 10000;
                    index++;
                }
            }
        }
        return releasedRevenue;
    }
    
    function getReceiveRecordLastId() external view returns (uint256)
    {
        return _autoReceiveIncrement;
    }

    function getReceiveRecords(uint256[] memory __ids) external view returns (ReceiveRecord[20] memory)
    {
        ReceiveRecord[20] memory list;
        for (uint i=0; i<__ids.length; i++)
        {
            if (i == 20) break;
            list[i] = _receiveRecord[__ids[i]];
        }
        return list;
    }

    function getUserReceiveRecordLength(address _sender) external view returns (uint256)
    {
        return _userReceiveIds[_sender].length;
    }

    function getUserReceiveRecords(address _sender, uint[] memory __indexs) external view returns (ReceiveRecord[20] memory)
    {
        uint256[20] memory __ids;
        for (uint i=0; i<__indexs.length; i++)
        {
            if (i == 20) break;
            __ids[i] = _userReceiveIds[_sender].data[__indexs[i]];
        }

        ReceiveRecord[20] memory list;
        for (uint i=0; i<__ids.length; i++)
        {
            if (i == 20) break;
            list[i] = _receiveRecord[__ids[i]];
        }
        return list;
    }

    function getCycleId() external view returns (uint256)
    {
        return _autoCycleId;
    }

    function getCycles(uint256[] memory _cycleIds) external view returns (Cycle[20] memory)
    {
        Cycle[20] memory list;
        for (uint i=0; i<_cycleIds.length; i++)
        {
            if (i == 20) break;
            list[i] = _cycles[_cycleIds[i]];
        }
        return list;
    }

    function withdraw(uint256 amount) external onlyOwner
    {
        TransferHelper.safeTransfer(_token, msg.sender, amount);
    }
}
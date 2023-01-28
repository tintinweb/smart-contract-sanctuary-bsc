// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RecordInterface.sol";
import "./UserStorage.sol";
import "./RecordStorage.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

abstract contract ReentrancyGuardRest {
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

library CountersRest {
    struct Counter {
        uint256 _value;
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        {
            if (counter._value == 0) {
                counter._value = 10000;
            }
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        {
            counter._value = value - 1;
        }
    }
}

contract RestStorage is Ownable, ReentrancyGuardRest {
    using CountersRest for CountersRest.Counter;
    using SafeMath for uint256;
    RecordInterface private _recordStorage;
    UserInterface private _userStorage;
    address recordAddress;

    struct Rest {
        address userAddr;
        uint256 restNo;
        uint256 restType;
        string coinType;
        string currencyType;
        uint256 restCount;
        uint256 price;
        uint256[] payType;
        uint256 restStatus;
        RestDetail restDetail;
    }
    struct RestDetail {
        uint256 finishCount;
        uint256 remainderCount;
        uint256 limitAmountFrom;
        uint256 limitAmountTo;
        uint256 limitMinCredit;
        uint256 limitMinMortgage;
        string restRemark;
        uint256 restTime;
        uint256 updateTime;
        uint256 restFee;
        string restHash;
    }

    CountersRest.Counter private _restNoCounter;
    mapping(uint256 => Rest) private rests;
    mapping(uint256 => uint256) private restIndex;

    Rest[] private restList;

    mapping(address => mapping(uint256 => uint256)) restFrozenTotal;

    event RestAdd(
        uint256 _restNo,
        uint256 _restType,
        string _coinType,
        string _currencyType,
        uint256 _restCount,
        uint256 _price,
        uint256[] _payType,
        RestDetail _restDetail
    );
    event RestUpdate(
        uint256 _restNo,
        string _coinType,
        string _currencyType,
        uint256 _restCount,
        uint256 _price,
        uint256[] _payType,
        RestDetail _restDetail
    );

    address _orderCAddr;

    modifier onlyAuthFromAddr() {
        require(_orderCAddr == msg.sender, "Invalid contract address");
        _;
    }

    address public backTradeFeeAddress;

    function setBackTradeFeeAddress(address _address) public onlyOwner {
        backTradeFeeAddress = _address;
    }

    mapping(string => address) public feeAddrSet;
    mapping(string => uint256) public feeAmountSet;

    function _payFee(string memory _method) internal {
        uint256 _amt = feeAmountSet[_method];
        address _addr = feeAddrSet[_method];

        if (_amt > 0) {
            require(_addr != address(0), "recipient null is not allowed");
            require(msg.value >= _amt, "insufficient balance");
            payable(_addr).transfer(_amt);
        }
    }

    function setFee(
        string calldata _method,
        address _addr,
        uint256 _amount
    ) external onlyOwner {
        feeAddrSet[_method] = _addr;
        feeAmountSet[_method] = _amount;
    }

    function authFromContract(
        address _recordAddr,
        address _userAddr,
        address _orderAddr
    ) external onlyOwner {
        _orderCAddr = _orderAddr;
        _recordStorage = RecordInterface(_recordAddr);
        _userStorage = UserInterface(_userAddr);
        recordAddress = _recordAddr;
        _restNoCounter.increment();
    }

    modifier onlyRestOwner(uint256 _restNo) {
        require(
            rests[_restNo].userAddr == msg.sender,
            "rest address not exist"
        );
        _;
    }

    function _checkParam(
        uint256 _restType,
        string memory _coinType,
        string memory _currencyType,
        uint256 _restCount,
        uint256 _price,
        uint256[] memory _payType
    ) internal pure {
        require(
            _restType != uint256(0),
            "RestStorage: restType null is not allowed"
        );
        require(
            bytes(_coinType).length != 0,
            "RestStorage: coinType null is not allowed"
        );
        require(
            bytes(_currencyType).length != 0,
            "RestStorage: currencyType null is not allowed"
        );
        require(
            _restCount != uint256(0),
            "RestStorage: restCount null is not allowed"
        );
        require(_price != uint256(0), "RestStorage: price null is not allowed");
        require(
            _payType.length != 0,
            "RestStorage: payType null is not allowed"
        );
    }

    function _insert(
        uint256 _restType,
        string memory _coinType,
        string memory _currencyType,
        uint256 _restCount,
        uint256 _price,
        uint256[] memory _payType,
        RestDetail memory _restDetail
    ) internal nonReentrant returns (uint256) {
        _checkParam(
            _restType,
            _coinType,
            _currencyType,
            _restCount,
            _price,
            _payType
        );

        uint256 _restNo = _restNoCounter.current();
        require(rests[_restNo].restNo == uint256(0), "rest exist");

        _restDetail.finishCount = 0;
        _restDetail.remainderCount = _restCount;
        _restDetail.restTime = block.timestamp;
        _restDetail.updateTime = 0;

        if (
            _restDetail.limitAmountTo > SafeMath.mul(_restCount, _price) ||
            _restDetail.limitAmountTo == 0
        ) {
            _restDetail.limitAmountTo = SafeMath.mul(_restCount, _price);
        }
        Rest memory r = Rest({
            userAddr: msg.sender,
            restNo: _restNo,
            restType: _restType,
            coinType: _coinType,
            currencyType: _currencyType,
            restCount: _restCount,
            price: _price,
            payType: _payType,
            restStatus: 1,
            restDetail: _restDetail
        });
        rests[_restNo] = r;

        restList.push(r);
        restIndex[_restNo] = restList.length - 1;

        _restNoCounter.increment();

        emit RestAdd(
            _restNo,
            _restType,
            _coinType,
            _currencyType,
            _restCount,
            _price,
            _payType,
            _restDetail
        );
        return _restNo;
    }

    function _updateInfo(
        uint256 _restNo,
        string memory _coinType,
        string memory _currencyType,
        uint256 _addCount,
        uint256 _price,
        uint256[] memory _payType,
        RestDetail memory _restDetail
    ) internal {
        require(_restNo != uint256(0), "Invalid restNo");
        Rest memory r = rests[_restNo];
        r.restStatus = 1;
        if (bytes(_coinType).length != 0) {
            r.coinType = _coinType;
        }
        if (bytes(_currencyType).length != 0) {
            r.currencyType = _currencyType;
        }

        if (_price != uint256(0)) {
            r.price = _price;
        }
        if (_addCount != uint256(0)) {
            r.restCount += _addCount;
            r.restDetail.remainderCount += _addCount;
            r.restDetail.limitAmountTo = SafeMath.mul(
                r.restDetail.remainderCount,
                r.price
            );
        }
        if (_payType.length != 0) {
            r.payType = _payType;
        }
        if (_restDetail.limitAmountFrom != uint256(0)) {
            if (_restDetail.limitAmountFrom > r.restDetail.limitAmountTo) {
                _restDetail.limitAmountFrom = r.restDetail.limitAmountTo;
            }
            r.restDetail.limitAmountFrom = _restDetail.limitAmountFrom;
        }
        if (_restDetail.limitMinCredit != uint256(0)) {
            r.restDetail.limitMinCredit = _restDetail.limitMinCredit;
        }
        if (_restDetail.limitMinMortgage != uint256(0)) {
            r.restDetail.limitMinMortgage = _restDetail.limitMinMortgage;
        }
        if (bytes(_restDetail.restRemark).length != 0) {
            r.restDetail.restRemark = _restDetail.restRemark;
        }

        if (_restDetail.restFee != uint256(0)) {
            r.restDetail.restFee = _restDetail.restFee;
        }

        r.restDetail.updateTime = block.timestamp;
        rests[_restNo] = r;
        restList[restIndex[_restNo]] = r;
        emit RestUpdate(
            _restNo,
            _coinType,
            _currencyType,
            r.restCount,
            _price,
            _payType,
            _restDetail
        );
    }

    function addBuyRest(
        uint256 _restType,
        string memory _coinType,
        string memory _currencyType,
        uint256 _restCount,
        uint256 _price,
        uint256[] memory _payType,
        RestDetail memory _restDetail
    ) external payable {
        _payFee("addBuyRest");
        require(_restType == 1, "must buy rest");

        UserStorage.User memory _user = _userStorage.searchUser(msg.sender);

        bool _openTrade = _recordStorage.getOpenTrade();
        require(_openTrade || _user.userFlag == 3, "invalid user");

        _insert(
            _restType,
            _coinType,
            _currencyType,
            _restCount,
            _price,
            _payType,
            _restDetail
        );
    }

    function _addSell(
        uint256 _restType,
        string memory _coinType,
        string memory _currencyType,
        uint256 _restCount,
        uint256 _restFee,
        uint256 _price,
        uint256[] memory _payType,
        RestDetail memory _restDetail
    ) internal {
        require(_restType == 2, "must sell rest");
        require(_restCount > 0, "restCount error");

        UserStorage.User memory _user = _userStorage.searchUser(msg.sender);
        bool _openTrade = _recordStorage.getOpenTrade();
        require(_openTrade || _user.userFlag == 3, "invalid user");

        _recordStorage.addRecord(
            msg.sender,
            "",
            _coinType,
            _restCount,
            2,
            1,
            2
        );
        uint256 _needSub = SafeMath.add(_restCount, _restFee);
        TokenTransfer _tokenTransfer = _recordStorage.getERC20Address(
            _coinType
        );
        _tokenTransfer.transferFrom(msg.sender, recordAddress, _needSub);

        uint256 _newRestNo = _insert(
            _restType,
            _coinType,
            _currencyType,
            _restCount,
            _price,
            _payType,
            _restDetail
        );

        restFrozenTotal[msg.sender][_newRestNo] = _restCount;
    }

    function addSellRest(
        uint256 _restType,
        string memory _coinType,
        string memory _currencyType,
        uint256 _restCount,
        uint256 _restFee,
        uint256 _price,
        uint256[] memory _payType,
        RestDetail memory _restDetail
    ) external payable {
        _payFee("addSellRest");
        _addSell(
            _restType,
            _coinType,
            _currencyType,
            _restCount,
            _restFee,
            _price,
            _payType,
            _restDetail
        );
    }

    function getRestFrozenTotal(address _addr, uint256 _restNo)
        public
        view
        returns (uint256)
    {
        return restFrozenTotal[_addr][_restNo];
    }

    function cancelBuyRest(uint256 _restNo)
        external
        payable
        onlyRestOwner(_restNo)
    {
        _payFee("cancelBuyRest");
        require(rests[_restNo].restStatus == 1, "can't change this rest");
        require(rests[_restNo].restType == 1, "Invalid rest type");
        require(
            rests[_restNo].restDetail.finishCount < rests[_restNo].restCount,
            "this rest has finished"
        );

        Rest memory r = rests[_restNo];
        r.restStatus = 4;
        r.restDetail.updateTime = block.timestamp;
        rests[_restNo] = r;
        restList[restIndex[_restNo]] = r;
    }

    function _cancelSell(uint256 _restNo) internal onlyRestOwner(_restNo) {
        require(rests[_restNo].restStatus == 1, "can't cancel this rest");
        require(rests[_restNo].restType == 2, "Invalid rest type");
        require(
            rests[_restNo].restDetail.finishCount < rests[_restNo].restCount,
            "this rest has finished"
        );
        require(restFrozenTotal[msg.sender][_restNo] > 0, "rest has finished");
        uint256 _frozenTotal = _recordStorage.getFrozenTotal(
            msg.sender,
            rests[_restNo].coinType
        );
        require(
            _frozenTotal >= restFrozenTotal[msg.sender][_restNo],
            "can't cancel this rest"
        );

        uint256 remainHoldCoin = restFrozenTotal[msg.sender][_restNo];

        Rest memory r = rests[_restNo];
        r.restStatus = 4;

        if (remainHoldCoin < rests[_restNo].restCount) {
            r.restStatus = 5;
        }
        r.restDetail.remainderCount = 0;
        r.restDetail.updateTime = block.timestamp;
        rests[_restNo] = r;
        restList[restIndex[_restNo]] = r;

        restFrozenTotal[msg.sender][_restNo] = 0;

         _recordStorage.addAvailableTotal(
            msg.sender,
            rests[_restNo].coinType,
            remainHoldCoin
        );

        if (r.restDetail.restFee > 0) {
            require(backTradeFeeAddress != address(0), "trade fee address is null");
            uint256 tradeFee = SafeMath.div(
                SafeMath.mul(r.restDetail.restFee, remainHoldCoin),
                r.restCount
            );
            TokenTransfer _tokenTransfer = _recordStorage.getERC20Address(
                r.coinType
            );
            _tokenTransfer.transferFrom(
                backTradeFeeAddress,
                msg.sender,
                tradeFee
            );
        }
    }

    function cancelSellRest(uint256 _restNo) external payable {
        _payFee("cancelSellRest");
        _cancelSell(_restNo);
    }

    function startOrStop(uint256 _restNo, uint256 _restStatus)
        external
        payable
        onlyRestOwner(_restNo)
    {
        _payFee("startOrStop");
        require(_restStatus == 1 || _restStatus == 3, "Invalid rest status");

        Rest memory r = rests[_restNo];
        require(
            r.restStatus == 1 || r.restStatus == 3,
            "Invalid rest status,opt error"
        );
        r.restStatus = _restStatus;
        r.restDetail.updateTime = block.timestamp;
        rests[_restNo] = r;
        restList[restIndex[_restNo]] = r;
    }

    function updateInfo(
        uint256 _restNo,
        string memory _coinType,
        string memory _currencyType,
        uint256 _addCount,
        uint256 _restFee,
        uint256 _price,
        uint256[] memory _payType,
        RestDetail memory _restDetail
    ) external onlyRestOwner(_restNo) {
        require(_restNo != uint256(0), "Invalid restNo");
        Rest memory _rest = rests[_restNo];
        require(_rest.restNo != uint256(0), "rest not exist");

        if (_rest.restType == 2) {
            _recordStorage.addRecord(
                msg.sender,
                "",
                _coinType,
                _addCount,
                2,
                1,
                2
            );
            uint256 _needSub = SafeMath.add(_addCount, _restFee);
            TokenTransfer _tokenTransfer = _recordStorage.getERC20Address(
                _coinType
            );
            _tokenTransfer.transferFrom(msg.sender, recordAddress, _needSub);

            restFrozenTotal[msg.sender][_restNo] += _addCount;
        }
        _updateInfo(
            _restNo,
            _coinType,
            _currencyType,
            _addCount,
            _price,
            _payType,
            _restDetail
        );
    }

    function updateRestFinishCount(uint256 _restNo, uint256 _finishCount)
        external
        onlyAuthFromAddr
    {
        Rest memory _rest = rests[_restNo];

        require(
            _rest.restDetail.remainderCount >= _finishCount,
            "RestStorage:finish count error"
        );

        if (_rest.restType == 2) {
            restFrozenTotal[_rest.userAddr][_restNo] = SafeMath.sub(
                restFrozenTotal[_rest.userAddr][_restNo],
                _finishCount
            );
        }

        _rest.restDetail.finishCount = SafeMath.add(
            _rest.restDetail.finishCount,
            _finishCount
        );
        _rest.restDetail.remainderCount = SafeMath.sub(
            _rest.restDetail.remainderCount,
            _finishCount
        );
        _rest.restDetail.limitAmountTo = SafeMath.mul(
            _rest.price,
            _rest.restDetail.remainderCount
        );
        if (_rest.restDetail.remainderCount == 0) {
            _rest.restStatus = 2;
        }

        _rest.restDetail.updateTime = block.timestamp;
        rests[_restNo] = _rest;
        restList[restIndex[_restNo]] = _rest;
    }

    function addRestRemainCount(uint256 _restNo, uint256 _remainCount)
        public
        onlyAuthFromAddr
    {
        Rest memory _rest = rests[_restNo];
        require(
            _remainCount > 0 && _rest.restDetail.finishCount >= _remainCount,
            "count error"
        );

        if (_rest.restType == 2) {
            restFrozenTotal[_rest.userAddr][_restNo] = SafeMath.add(
                restFrozenTotal[_rest.userAddr][_restNo],
                _remainCount
            );
        }

        _rest.restDetail.finishCount = SafeMath.sub(
            _rest.restDetail.finishCount,
            _remainCount
        );
        _rest.restDetail.remainderCount = SafeMath.add(
            _rest.restDetail.remainderCount,
            _remainCount
        );
        _rest.restDetail.limitAmountTo = SafeMath.mul(
            _rest.price,
            _rest.restDetail.remainderCount
        );
        _rest.restDetail.limitAmountFrom = _rest.restDetail.limitAmountFrom >
            _rest.restDetail.limitAmountTo
            ? _rest.restDetail.limitAmountTo
            : _rest.restDetail.limitAmountFrom;
        _rest.restStatus = 1;

        _rest.restDetail.updateTime = block.timestamp;
        rests[_restNo] = _rest;
        restList[restIndex[_restNo]] = _rest;
    }

    function searchRest(uint256 _restNo)
        external
        view
        returns (Rest memory rest)
    {
        require(_restNo != uint256(0), "restNo null is not allowed");
        Rest memory r = rests[_restNo];
        return r;
    }

    function searchRestList() external view returns (Rest[] memory) {
        return restList;
    }
}
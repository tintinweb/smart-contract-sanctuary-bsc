// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

interface ICard {
    function mintTo(address account_) external returns (uint256);

    function activateCard(
        address account,
        uint256 cardId,
        uint256 lv,
        string memory uuid
    ) external;
}

contract RenaisnBox {
    address payable public owner;
    address payable public daoAddress;
    address public immutable cardAddress;

    uint256 public lastStartEpoch;
    uint256 public epoch = 1200; //86400
    uint256 public autoStartNum = 1000;
    uint256 public boxPrice = 1e18;
    uint256 public userMax = 3;
    uint256 private randNum = 133248;

    //total
    uint256 public totalBoxNum; //total box
    uint256 public pendingSaleNum; //pending sell box
    uint256 public pendingOpenBoxNum; //pending open box

    //today
    uint256 private _totalNum; //today totalNum = autoStartNum
    uint256 private _boxNum; //today surplus num

    bool public isEnd = true;
    uint256 private _startTime;
    uint256 private _endTime;

    uint256[] private boxKeys; //[1,2] lv
    mapping(uint256 => uint256) private boxes; //lv=>num

    mapping(address => bool) public whiteList;
    mapping(address => bool) public isWhiteBuy;
    mapping(address => uint256) public userBuyBox;

    event BuyBox(address indexed account, uint256 indexed cardId);
    event OpenBox(address indexed account, uint256 indexed cardId, uint256 lv);

    constructor(address daoAddr_, address cardAddr_) {
        owner = payable(msg.sender);
        daoAddress = payable(daoAddr_);
        cardAddress = cardAddr_;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function setOwner(address payable newAddr_) external onlyOwner {
        owner = newAddr_;
    }

    function setDao(address payable newAddr_) external onlyOwner {
        daoAddress = newAddr_;
    }

    function withdraw() external onlyOwner {
        daoAddress.transfer(address(this).balance);
    }

    function withdrawToken(address token, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(token, daoAddress, amount);
    }

    function setWhiteList(address[] memory addrlist, bool _value)
        external
        onlyOwner
    {
        require(addrlist.length > 0, "addrlist error");
        for (uint256 i = 0; i < addrlist.length; i++) {
            whiteList[addrlist[i]] = _value;
        }
    }

    function setEnd() external onlyOwner {
        isEnd = true;
    }

    function setBoxPrice(uint256 price_) external onlyOwner {
        boxPrice = price_;
    }

    function setUserMax(uint256 max_) external onlyOwner {
        userMax = max_;
    }

    function setStartNum(uint256 num_) external onlyOwner {
        autoStartNum = num_;
    }

    function setEpoch(uint256 epoch_) external onlyOwner {
        require(epoch > 0, "set epoch error");
        epoch = epoch_;
        _endTime = _startTime + epoch;
        lastStartEpoch = _startTime / epoch;
    }

    function setBoxes(uint256[] memory keys_, uint256[] memory amounts_)
        external
        onlyOwner
    {
        require(isEnd, "isEnd status error");
        boxKeys = keys_;
        totalBoxNum = 0;
        for (uint256 i = 0; i < keys_.length; i++) {
            uint256 key = keys_[i];
            boxes[key] = amounts_[i];
            totalBoxNum += amounts_[i];
        }
        pendingSaleNum = totalBoxNum;
        pendingOpenBoxNum = totalBoxNum;
    }

    function setActivityStart(uint256 startTime_) external onlyOwner {
        require(block.timestamp > _endTime || isEnd, "Activity started");
        require(boxPrice > 0, "boxPrice error");
        require(pendingSaleNum > 0, "pendingSaleNum error");

        _setStart(startTime_);
    }

    function buyBox(uint256 buyNum) external payable returns (bool) {
        require(
            (!isContract(msg.sender)) && (msg.sender == tx.origin),
            "caller error"
        );

        autoStart();
        require(
            _startTime > 0 && block.timestamp >= _startTime,
            "Activity not started"
        );
        require(
            !isEnd && block.timestamp < _endTime && _boxNum > 0,
            "Activity ended"
        );
        require(userBuyBox[msg.sender] + buyNum <= userMax, "userBuyMax error");
        require(pendingSaleNum >= buyNum, "pendingSaleNum error");

        uint256 requirePay = buyNum * boxPrice;
        if (whiteList[msg.sender] && !isWhiteBuy[msg.sender]) {
            require(msg.value == requirePay - boxPrice, "pay amount error");
            isWhiteBuy[msg.sender] = true;
        } else {
            require(msg.value >= requirePay, "pay amount error");
        }

        for (uint i = 0; i < buyNum; i++) {
            userBuyBox[msg.sender] += 1;
            pendingSaleNum -= 1;
            _boxNum -= 1;

            uint256 cardId = ICard(cardAddress).mintTo(msg.sender);

            emit BuyBox(msg.sender, cardId);
        }

        return true;
    }

    //activateCard
    function openBox(uint256 cardId, string memory uuid)
        external
        returns (bool)
    {
        require(pendingOpenBoxNum > 0, "pendingOpenBoxNum error");
        uint256 random = _random();
        uint256 index = (random % pendingOpenBoxNum) + 1;
        uint256 boxKey = getRewardBox(index);

        pendingOpenBoxNum -= 1;
        boxes[boxKey] -= 1;
        ICard(cardAddress).activateCard(msg.sender, cardId, boxKey, uuid);

        emit OpenBox(msg.sender, cardId, boxKey);
        return true;
    }

    function getRewardBox(uint256 index_) private view returns (uint256) {
        uint256 _num = 0;
        for (uint256 i = 0; i < boxKeys.length; i++) {
            uint256 key = boxKeys[i];
            _num += boxes[key];
            if (index_ <= _num) {
                return key;
            }
        }
        revert("get box key error");
    }

    function getBoxes(uint256 key) external view returns (uint256) {
        require(
            msg.sender == owner || msg.sender == daoAddress,
            "caller not allow"
        );
        return boxes[key];
    }

    function startTime() external view returns (uint256) {
        return isNewEpoch() ? block.timestamp : _startTime;
    }

    function endTime() external view returns (uint256) {
        return isNewEpoch() ? _startTime + epoch : _endTime;
    }

    function totalNum() external view returns (uint256) {
        return isNewEpoch() ? pendingNum() : _totalNum;
    }

    function boxNum() external view returns (uint256) {
        return isNewEpoch() ? pendingNum() : _boxNum;
    }

    function isNewEpoch() private view returns (bool) {
        uint256 _epoch_day = block.timestamp / epoch;
        if (_epoch_day > lastStartEpoch) {
            return true;
        }
        return false;
    }

    function pendingNum() private view returns (uint256) {
        uint256 num = autoStartNum;
        if (pendingSaleNum < autoStartNum) {
            num = pendingSaleNum;
        }
        return num;
    }

    function autoStart() private {
        if (
            _startTime > 0 &&
            isEnd &&
            pendingSaleNum > 0 &&
            autoStartNum > 0 &&
            boxPrice > 0 &&
            isNewEpoch()
        ) {
            _setStart(block.timestamp);
        }
    }

    function _setStart(uint256 time_) private {
        require(time_ > 0, "set startTime error");
        isEnd = false;
        _startTime = time_;
        _endTime = _startTime + epoch;
        lastStartEpoch = _startTime / epoch;

        _totalNum = pendingNum();
        _boxNum = _totalNum;
    }

    function isContract(address addr) private view returns (bool) {
        uint256 size;
        if (addr == address(0)) return false;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function _random() private returns (uint256) {
        randNum += 1;
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    msg.sender,
                    randNum
                )
            )
        );
        randNum = randomNumber;
        return randomNumber;
    }
}
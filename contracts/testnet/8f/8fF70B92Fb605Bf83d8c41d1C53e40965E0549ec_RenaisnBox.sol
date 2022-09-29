/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

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

    uint256 private epoch = 1200;

    uint256 public userMax = 3;
    uint256 private randNum = 133248;
    bool public isEnd = false;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public boxPrice = 1e18;

    uint256 public totalNum;
    uint256 public boxNum; //surplus num
    uint256[] private boxKeys; //[1,2] lv
    mapping(uint256 => uint256) private boxes; //lv=>num

    mapping(address => bool) public whiteList;
    mapping(address => bool) public isWhiteBuy;
    mapping(address => uint256) public userBuyBox;
    mapping(uint256 => uint256) private boxLv; //tokenId=>lv

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

    function setBoxes(uint256[] memory keys_, uint256[] memory amounts_)
        external
        onlyOwner
    {
        isEnd = true;
        boxKeys = keys_;
        boxNum = 0;
        for (uint256 i = 0; i < keys_.length; i++) {
            uint256 key = keys_[i];
            boxes[key] = amounts_[i];
            boxNum += amounts_[i];
        }
        totalNum = boxNum;
    }

    function setActivityStart(uint256 startTime_) external onlyOwner {
        require(block.timestamp > endTime || isEnd, "Activity started");
        require(boxNum > 0, "boxes set error");
        require(boxPrice > 0, "boxPrice error");

        isEnd = false;
        startTime = startTime_;
        endTime = startTime + epoch;
    }

    function restartActivity() external onlyOwner {
        require(block.timestamp > endTime || isEnd, "Activity started");
        require(startTime > 0 && endTime > 0, "start error");
        require(boxNum > 0, "boxes set error");

        uint256 times = startTime / epoch;
        uint256 epochTimes = block.timestamp / epoch;
        require((epochTimes - times) == 1, "epoch error");

        isEnd = false;
        startTime += epoch;
        endTime = startTime + epoch;
    }

    function buyBox(uint256 buyNum) external payable returns (bool) {
        require(
            (!isContract(msg.sender)) && (msg.sender == tx.origin),
            "caller error"
        );

        require(block.timestamp >= startTime, "Activity not started");
        require(
            !isEnd && block.timestamp < endTime && boxNum > 0,
            "Activity ended"
        );
        require(userBuyBox[msg.sender] + buyNum <= userMax, "userBuyMax error");

        uint256 requirePay = buyNum * boxPrice;
        if (whiteList[msg.sender] && !isWhiteBuy[msg.sender]) {
            require(msg.value == requirePay - boxPrice, "pay amount error");
            isWhiteBuy[msg.sender] = true;
        } else {
            require(msg.value >= requirePay, "pay amount error");
        }

        for (uint i = 0; i < buyNum; i++) {
            uint256 random = _random();
            uint256 index = (random % boxNum) + 1;
            uint256 boxKey = getRewardBox(index);

            userBuyBox[msg.sender] += 1;
            boxNum -= 1;
            boxes[boxKey] -= 1;

            uint256 cardId = ICard(cardAddress).mintTo(msg.sender);
            boxLv[cardId] = boxKey;

            emit BuyBox(msg.sender, cardId);
        }

        return true;
    }

    //activateCard
    function openBox(uint256 cardId, string memory uuid)
        external
        returns (bool)
    {
        require(boxLv[cardId] > 0, "box error");
        ICard(cardAddress).activateCard(
            msg.sender,
            cardId,
            boxLv[cardId],
            uuid
        );

        emit OpenBox(msg.sender, cardId, boxLv[cardId]);
        return true;
    }

    function getRewardBox(uint256 index_) private view returns (uint256) {
        uint256 _boxNum = 0;
        for (uint256 i = 0; i < boxKeys.length; i++) {
            uint256 key = boxKeys[i];
            _boxNum += boxes[key];
            if (index_ <= _boxNum) {
                return key;
            }
        }
        return 0;
    }

    function getBoxes(uint256 key) external view returns (uint256) {
        require(
            msg.sender == owner || msg.sender == daoAddress,
            "caller not allow"
        );
        return boxes[key];
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
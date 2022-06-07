//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "./interfaces/IOfferReward.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OfferReward is IOfferReward, Ownable {
    mapping(uint48 => Offer) private _offerMap;
    mapping(address => Publisher) private _publisherMap;

    uint48 firstValueSortOfferId;
    // uint48[] private _fastValueSortList;
    mapping(uint48 => uint48) private _valueSortMap;

    uint48 firstFinishSortOfferId;
    // uint48[] private _fastFinishSortList;
    mapping(uint48 => uint48) private _finishSortMap;

    uint48 public fastSkip = 100;
    uint48 public offerLength;
    uint48 public minFinshTime = 1 hours;
    uint48 public waitTime = 7 days;
    uint48 public blockSkip = 5000;
    uint48 public feeRate = 500;
    address public feeAddress;
    uint256 public minOfferValue = 0.005 ether;
    uint256 public answerFee = 0.00025 ether;

    constructor() {
        feeAddress = msg.sender;
    }

    /* ================ UTIL FUNCTIONS ================ */

    // function _getIndexValue(
    //     mapping(uint48 => uint48) storage fastMap,
    //     mapping(uint48 => uint48) storage map,
    //     uint48 index
    // ) internal view returns (uint48) {
    //     uint48 value = fastMap[index / fastSkip];
    //     index = index % fastSkip;
    //     for (uint48 i = 0; i < index; i++) {
    //         value = map[value];
    //     }
    //     return value;
    // }

    // function _getValueIndex(
    //     mapping(uint48 => uint48) storage fastMap,
    //     mapping(uint48 => uint48) storage map,
    //     uint48 value
    // ) internal view returns (uint48) {
    //     uint48 low;
    //     uint48 high = offerLength - 1;
    //     uint48 index;
    //     while (low <= high) {
    //         uint48 mid = (low + high) / 2;
    //         uint48 guess = _getIndexValue(fastMap, map, mid);
    //         if (guess == value) {
    //             index = mid;
    //             break;
    //         }
    //         if (guess > value) {
    //             high = mid - 1;
    //         }
    //         if (guess < value) {
    //             low = mid + 1;
    //         }
    //     }
    //     return index;
    // }

    // function _setIndex(mapping(uint48 => uint48) storage map, uint48 index, uint48 value) internal {
    //     map[]
    // }

    function _addSort(
        uint48 beforeValueSortOfferId,
        uint48 beforeFinishSortOfferId,
        uint48 offerId,
        uint256 value,
        uint48 finishTime
    ) internal {
        require(
            _offerMap[beforeValueSortOfferId].value >= value &&
                _offerMap[_valueSortMap[beforeValueSortOfferId]].value <= value,
            "OfferReward: error valueSort"
        );
        _valueSortMap[offerId] = _valueSortMap[beforeValueSortOfferId];
        _valueSortMap[beforeValueSortOfferId] = offerId;
        require(
            _offerMap[beforeFinishSortOfferId].finishTime <= finishTime &&
                _offerMap[_finishSortMap[beforeFinishSortOfferId]].finishTime >= finishTime,
            "OfferReward: error finishSort"
        );
        _finishSortMap[offerId] = _finishSortMap[beforeFinishSortOfferId];
        _finishSortMap[beforeFinishSortOfferId] = offerId;
    }

    function _removeSort(
        uint48 beforeValueSortOfferId,
        uint48 beforeFinishSortOfferId,
        uint48 offerId
    ) internal {
        require(_valueSortMap[beforeValueSortOfferId] == offerId, "OfferReward: error beforeValueSortOfferId");
        _valueSortMap[beforeValueSortOfferId] = _valueSortMap[offerId];
        require(_finishSortMap[beforeFinishSortOfferId] == offerId, "OfferReward: error beforeFinishSortOfferId");
        _finishSortMap[beforeFinishSortOfferId] = _finishSortMap[offerId];
    }

    /* ================ VIEW FUNCTIONS ================ */

    function getOfferIdListByValueSort(uint48 startOfferId, uint48 length)
        public
        view
        override
        returns (uint48[] memory)
    {
        uint48[] memory offerIdList = new uint48[](length);
        uint48 offerId = startOfferId;
        for (uint48 i = 0; i < length; i++) {
            offerId = _valueSortMap[offerId];
            offerIdList[i] = offerId;
        }
        return offerIdList;
    }

    function getOfferIdListByFinishSort(uint48 startOfferId, uint48 length)
        public
        view
        override
        returns (uint48[] memory)
    {
        uint48[] memory offerIdList = new uint48[](length);
        uint48 offerId = startOfferId;
        for (uint48 i = 0; i < length; i++) {
            offerId = _finishSortMap[offerId];
            offerIdList[i] = offerId;
        }
        return offerIdList;
    }

    function getOfferData(uint48 offerId) public view override returns (OfferData memory) {
        OfferData memory offerData = OfferData({
            value: _offerMap[offerId].value,
            offerBlock: _offerMap[offerId].offerBlock,
            finishTime: _offerMap[offerId].finishTime,
            publisher: _offerMap[offerId].publisher,
            answerAmount: _offerMap[offerId].answerAmount,
            finishBlock: _offerMap[offerId].finishBlock,
            answerBlockListLength: uint48(_offerMap[offerId].answerBlockList.length)
        });
        return offerData;
    }

    function getPublisherData(address publisher) public view override returns (PublisherData memory) {
        PublisherData memory publisherData = PublisherData({
            offerIdListLength: uint48(_publisherMap[publisher].offerIdList.length),
            rewardOfferIdListLength: uint48(_publisherMap[publisher].rewardOfferIdList.length),
            publishOfferAmount: _publisherMap[publisher].publishOfferAmount,
            rewardOfferAmount: _publisherMap[publisher].rewardOfferAmount,
            publishAnswerAmount: _publisherMap[publisher].publishAnswerAmount,
            rewardAnswerAmount: _publisherMap[publisher].rewardAnswerAmount,
            publishOfferValue: _publisherMap[publisher].publishOfferValue,
            rewardOfferValue: _publisherMap[publisher].rewardOfferValue,
            rewardAnswerValue: _publisherMap[publisher].rewardAnswerValue
        });
        return (publisherData);
    }

    function getOfferDataList(uint48[] calldata offerIdList) public view override returns (OfferData[] memory) {
        OfferData[] memory offerDataList = new OfferData[](offerIdList.length);
        for (uint48 i = 0; i < offerIdList.length; i++) {
            offerDataList[i] = getOfferData(offerIdList[i]);
        }
        return offerDataList;
    }

    function getPublisherDataList(address[] calldata publisherAddressList)
        public
        view
        override
        returns (PublisherData[] memory)
    {
        PublisherData[] memory publisherDataList = new PublisherData[](publisherAddressList.length);
        for (uint48 i = 0; i < publisherAddressList.length; i++) {
            publisherDataList[i] = getPublisherData(publisherAddressList[i]);
        }
        return publisherDataList;
    }

    function getAnswerBlockListByOffer(
        uint48 offerId,
        uint48 start,
        uint48 length
    ) public view override returns (uint48[] memory) {
        uint48[] memory answerBlockList = new uint48[](length);
        for (uint48 i = 0; i < length; i++) {
            answerBlockList[i] = _offerMap[offerId].answerBlockList[start + i];
        }
        return answerBlockList;
    }

    function getOfferIdListByPublisher(
        address publisher,
        uint48 start,
        uint48 length
    ) public view override returns (uint48[] memory) {
        uint48[] memory offerIdList = new uint48[](length);
        for (uint48 i = 0; i < length; i++) {
            offerIdList[i] = _publisherMap[publisher].offerIdList[start + i];
        }
        return offerIdList;
    }

    function getRewardOfferIdListByPublisher(
        address publisher,
        uint48 start,
        uint48 length
    ) public view override returns (uint48[] memory) {
        uint48[] memory rewardOfferIdList = new uint48[](length);
        for (uint48 i = 0; i < length; i++) {
            rewardOfferIdList[i] = _publisherMap[publisher].rewardOfferIdList[start + i];
        }
        return rewardOfferIdList;
    }

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        string calldata title,
        string calldata content,
        uint48 offerTime,
        uint48 beforeValueSortOfferId,
        uint48 beforeFinishSortOfferId
    ) external payable override {
        require(offerTime >= minFinshTime, "OfferReward: offerTime is too short");
        require(msg.value >= minOfferValue, "OfferReward: value is too low");
        uint48 finishTime = uint48(block.timestamp + offerTime);
        _offerMap[offerLength].value = msg.value;
        _offerMap[offerLength].offerBlock = uint48(block.number);
        _offerMap[offerLength].finishTime = finishTime;
        _offerMap[offerLength].publisher = msg.sender;
        _publisherMap[msg.sender].publishOfferAmount++;
        _publisherMap[msg.sender].publishOfferValue += msg.value;
        _publisherMap[msg.sender].offerIdList.push(offerLength);
        _addSort(beforeValueSortOfferId, beforeFinishSortOfferId, offerLength, msg.value, finishTime);
        emit OfferPublished(offerLength, title, content);
        offerLength++;
    }

    function publishAnswer(uint48 offerId, string calldata content) external override {
        require(offerId < offerLength, "OfferReward: offer is not exit");
        if (
            _offerMap[offerId].answerBlockList.length == 0 ||
            uint48(block.number) - _offerMap[offerId].answerBlockList[_offerMap[offerId].answerBlockList.length - 1] >
            blockSkip
        ) {
            _offerMap[offerId].answerBlockList.push(uint48(block.number));
        }
        _offerMap[offerId].answerAmount++;
        _publisherMap[msg.sender].publishAnswerAmount++;
        emit AnswerPublished(offerId, msg.sender, content);
    }

    function finishOffer(uint48 offerId, address rewarder) external {
        require(_offerMap[offerId].value > 0, "OfferReward: offer is finished");
        emit OfferFinished(offerId, rewarder, _offerMap[offerId].value);
        if (rewarder == address(0)) {
            require(
                block.timestamp >= _offerMap[offerId].finishTime + waitTime,
                "OfferReward: not over finishTime + waitTime"
            );
            uint256 feeAmount = _offerMap[offerId].answerAmount * answerFee;
            if (feeAmount >= _offerMap[offerId].value) {
                feeAmount = _offerMap[offerId].value;
            }
            uint256 valueAmount = _offerMap[offerId].value - feeAmount;
            _offerMap[offerId].value = 0;
            (bool success, ) = feeAddress.call{value: feeAmount}("");
            require(success, "OfferReward: send fee failed");
            if (valueAmount > 0) {
                (success, ) = _offerMap[offerId].publisher.call{value: valueAmount}("");
                require(success, "OfferReward: send value failed");
            }
        } else {
            require(_offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
            require(_offerMap[offerId].publisher != rewarder, "OfferReward: you are the rewarder");
            uint256 feeAmount = (_offerMap[offerId].value * feeRate) / 10000;
            uint256 rewardAmount = _offerMap[offerId].value - feeAmount;
            _publisherMap[_offerMap[offerId].publisher].rewardOfferAmount++;
            _publisherMap[_offerMap[offerId].publisher].rewardOfferValue += _offerMap[offerId].value;
            _publisherMap[rewarder].rewardAnswerAmount++;
            _publisherMap[rewarder].rewardAnswerValue += _offerMap[offerId].value;
            _publisherMap[rewarder].rewardOfferIdList.push(offerId);
            _offerMap[offerId].value = 0;
            _offerMap[offerId].finishBlock = uint48(block.number);
            (bool success, ) = feeAddress.call{value: feeAmount}("");
            require(success, "OfferReward: send fee failed");
            (success, ) = rewarder.call{value: rewardAmount}("");
            require(success, "OfferReward: send reward failed");
        }
    }

    function changeOfferData(
        uint48 offerId,
        string calldata title,
        string calldata content
    ) external override {
        require(_offerMap[offerId].value > 0, "OfferReward: offer is finished");
        require(_offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
        _offerMap[offerId].offerBlock = uint48(block.number);
        emit OfferPublished(offerId, title, content);
    }

    function changeOfferValue(
        uint48 offerId,
        uint48 offerTime,
        uint48 oldBeforeSortOfferId,
        uint48 oldBeforeFinishOfferId,
        uint48 newBeforeSortOfferId,
        uint48 newBeforeFinishOfferId
    ) external payable override {
        require(_offerMap[offerId].value > 0, "OfferReward: offer is finished");
        require(_offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
        uint48 newFinishTime = uint48(block.timestamp + offerTime);
        require(newFinishTime >= _offerMap[offerId].finishTime, "OfferReward: offerTime can not be less than before");
        if (newFinishTime > _offerMap[offerId].finishTime) {
            _offerMap[offerId].finishTime = newFinishTime;
        }
        if (msg.value > 0) {
            _offerMap[offerId].value += msg.value;
        }
        _removeSort(oldBeforeSortOfferId, oldBeforeFinishOfferId, offerId);
        _addSort(newBeforeSortOfferId, newBeforeFinishOfferId, offerId, _offerMap[offerId].value, newFinishTime);
    }

    /* ================ ADMIN FUNCTIONS ================ */

    function setFeeRate(uint48 newFeeRate) external onlyOwner {
        feeRate = newFeeRate;
    }

    function setFeeAddress(address newFeeAddress) external onlyOwner {
        feeAddress = newFeeAddress;
    }

    function setMinOfferValue(uint256 newMinOfferValue) external onlyOwner {
        minOfferValue = newMinOfferValue;
    }

    function setAnswerFee(uint256 newAnswerFee) external onlyOwner {
        answerFee = newAnswerFee;
    }

    function setMinFinshTime(uint48 newMinFinshTime) external onlyOwner {
        minFinshTime = newMinFinshTime;
    }

    function setBlockSkip(uint48 newBlockSkip) external onlyOwner {
        blockSkip = newBlockSkip;
    }

    function setWaitTime(uint48 newWaitTime) external onlyOwner {
        waitTime = newWaitTime;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IOfferReward {
    /* ================ EVENTS ================ */

    event OfferPublished(uint48 indexed offerId, string title, string content);

    event AnswerPublished(uint48 indexed offerId, address indexed publisher, string content);

    event OfferFinished(uint48 indexed offerId, address indexed rewarder, uint256 value);

    /* ================ STRUCTS ================ */

    struct Offer {
        uint256 value;
        uint48 offerBlock;
        uint48 finishTime;
        address publisher;
        uint48 answerAmount;
        uint48 finishBlock;
        uint48[] answerBlockList;
    }

    struct OfferData {
        uint256 value;
        uint48 offerBlock;
        uint48 finishTime;
        address publisher;
        uint48 answerAmount;
        uint48 finishBlock;
        uint48 answerBlockListLength;
    }

    struct Publisher {
        uint48[] offerIdList;
        uint48[] rewardOfferIdList;
        uint48 publishOfferAmount;
        uint48 rewardOfferAmount;
        uint48 publishAnswerAmount;
        uint48 rewardAnswerAmount;
        uint256 publishOfferValue;
        uint256 rewardOfferValue;
        uint256 rewardAnswerValue;
    }

    struct PublisherData {
        uint48 offerIdListLength;
        uint48 rewardOfferIdListLength;
        uint48 publishOfferAmount;
        uint48 rewardOfferAmount;
        uint48 publishAnswerAmount;
        uint48 rewardAnswerAmount;
        uint256 publishOfferValue;
        uint256 rewardOfferValue;
        uint256 rewardAnswerValue;
    }

    /* ================ VIEW FUNCTIONS ================ */

    function getOfferIdListByValueSort(uint48 startOfferId, uint48 length) external view returns (uint48[] memory);

    function getOfferIdListByFinishSort(uint48 startOfferId, uint48 length) external view returns (uint48[] memory);

    function getOfferData(uint48 offerId) external view returns (OfferData memory);

    function getPublisherData(address publisher) external view returns (PublisherData memory);

    function getOfferDataList(uint48[] calldata offerIdList) external view returns (OfferData[] memory);

    function getPublisherDataList(address[] calldata publisherAddressList)
        external
        view
        returns (PublisherData[] memory);

    function getAnswerBlockListByOffer(
        uint48 offerId,
        uint48 start,
        uint48 length
    ) external view returns (uint48[] memory);

    function getOfferIdListByPublisher(
        address publisher,
        uint48 start,
        uint48 length
    ) external view returns (uint48[] memory);

    function getRewardOfferIdListByPublisher(
        address publisher,
        uint48 start,
        uint48 length
    ) external view returns (uint48[] memory);

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        string calldata title,
        string calldata content,
        uint48 finishTime,
        uint48 beforeValueSortOfferId,
        uint48 beforeFinishSortOfferId
    ) external payable;

    function publishAnswer(uint48 offerId, string calldata content) external;

    function finishOffer(uint48 offerId, address rewarder) external;

    function changeOfferData(
        uint48 offerId,
        string calldata title,
        string calldata content
    ) external;

    function changeOfferValue(
        uint48 offerId,
        uint48 finishTime,
        uint48 oldBeforeSortOfferId,
        uint48 oldBeforeFinishOfferId,
        uint48 newBeforeSortOfferId,
        uint48 newBeforeFinishOfferId
    ) external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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
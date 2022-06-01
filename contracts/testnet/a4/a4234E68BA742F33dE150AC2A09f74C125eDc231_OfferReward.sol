//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

import "./interfaces/IOfferReward.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OfferReward is IOfferReward, Ownable {
    mapping(uint48 => Offer) private _offerMap;

    mapping(address => Publisher) private _publisherMap;

    uint48 public offerLength;

    uint48 public minFinshTime = 1 days;

    uint48 public blockSkip = 5000;

    uint48 public feeRate = 500;

    address public feeAddress;

    uint256 public minOfferValue = 0.003 ether;

    uint256 public answerFee = 0.0002 ether;

    constructor() {
        feeAddress = msg.sender;
    }

    /* ================ UTIL FUNCTIONS ================ */

    /* ================ VIEW FUNCTIONS ================ */

    function getOfferData(uint48 offerId) public view override returns (OfferData memory) {
        OfferData memory offerData = OfferData({
            value: _offerMap[offerId].value,
            offerBlock: _offerMap[offerId].offerBlock,
            finishTime: _offerMap[offerId].finishTime,
            publisher: _offerMap[offerId].publisher,
            answerAmount: _offerMap[offerId].answerAmount,
            answerBlockListLength: uint48(_offerMap[offerId].answerBlockList.length)
        });
        return offerData;
    }

    function getPublisherData(address publisher) public view override returns (PublisherData memory) {
        PublisherData memory publisherData = PublisherData({
            offerIdListLength: uint48(_publisherMap[publisher].offerIdList.length),
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

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        string calldata title,
        string calldata content,
        uint48 finishTime
    ) external payable override {
        require(finishTime - block.timestamp >= minFinshTime, "OfferReward: finishTime is too short");
        require(msg.value >= minOfferValue, "OfferReward: value is too low");
        _offerMap[offerLength] = Offer({
            value: msg.value,
            offerBlock: uint48(block.number),
            finishTime: finishTime,
            publisher: msg.sender,
            answerAmount: 0,
            rewarder:address(0),
            answerBlockList: new uint48[](0)
        });
        _publisherMap[msg.sender].publishOfferAmount++;
        _publisherMap[msg.sender].publishOfferValue += msg.value;
        _publisherMap[msg.sender].offerIdList.push(offerLength);
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
        if (rewarder == address(0)) {
            require(block.timestamp >= _offerMap[offerId].finishTime, "OfferReward: not over finishTime");
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
            _offerMap[offerId].value = 0;
            _offerMap[offerId].rewarder = rewarder;
            (bool success, ) = feeAddress.call{value: feeAmount}("");
            require(success, "OfferReward: send fee failed");
            (success, ) = rewarder.call{value: rewardAmount}("");
            require(success, "OfferReward: send reward failed");
        }
        emit OfferFinished(offerId);
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

    function changeOfferValue(uint48 offerId, uint48 finishTime) external payable override {
        require(_offerMap[offerId].value > 0, "OfferReward: offer is finished");
        require(_offerMap[offerId].publisher == msg.sender, "OfferReward: you are not the publisher");
        require(finishTime >= _offerMap[offerId].finishTime, "OfferReward: finishTime can not be less than before");
        if (finishTime > _offerMap[offerId].finishTime) {
            _offerMap[offerId].finishTime = finishTime;
        }
        if (msg.value > 0) {
            _offerMap[offerId].value += msg.value;
        }
    }

    /* ================ ADMIN FUNCTIONS ================ */

    function setFeeRate(uint48 newFeeRate) external override onlyOwner {
        feeRate = newFeeRate;
    }

    function setFeeAddress(address newFeeAddress) external override onlyOwner {
        feeAddress = newFeeAddress;
    }

    function setMinOfferValue(uint256 newMinOfferValue) external override onlyOwner {
        minOfferValue = newMinOfferValue;
    }

    function setAnswerFee(uint256 newAnswerFee) external override onlyOwner {
        answerFee = newAnswerFee;
    }

    function setMinFinshTime(uint48 newMinFinshTime) external override onlyOwner {
        minFinshTime = newMinFinshTime;
    }

    function setBlockSkip(uint48 newBlockSkip) external override onlyOwner {
        blockSkip = newBlockSkip;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IOfferReward {
    /* ================ EVENTS ================ */

    event OfferPublished(uint48 indexed offerId, string title, string content);

    event AnswerPublished(uint48 indexed offerId, address indexed publisher, string content);

    event OfferFinished(uint48 indexed offerId);

    /* ================ STRUCTS ================ */

    struct Offer {
        uint256 value;
        uint48 offerBlock;
        uint48 finishTime;
        address publisher;
        uint48 answerAmount;
        address rewarder;
        uint48[] answerBlockList;
    }

    struct OfferData {
        uint256 value;
        uint48 offerBlock;
        uint48 finishTime;
        address publisher;
        uint48 answerAmount;
        uint48 answerBlockListLength;
    }

    struct Publisher {
        uint48[] offerIdList;
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
        uint48 publishOfferAmount;
        uint48 rewardOfferAmount;
        uint48 publishAnswerAmount;
        uint48 rewardAnswerAmount;
        uint256 publishOfferValue;
        uint256 rewardOfferValue;
        uint256 rewardAnswerValue;
    }

    /* ================ VIEW FUNCTIONS ================ */
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

    /* ================ TRANSACTION FUNCTIONS ================ */

    function publishOffer(
        string calldata title,
        string calldata content,
        uint48 finishTime
    ) external payable;

    function publishAnswer(uint48 offerId, string calldata content) external;

    function finishOffer(uint48 offerId, address rewarder) external;

    function changeOfferData(
        uint48 offerId,
        string calldata title,
        string calldata content
    ) external;

    function changeOfferValue(uint48 offerId, uint48 finishTime) external payable;

    /* ================ ADMIN FUNCTIONS ================ */

    function setFeeRate(uint48 newFeeRate) external;

    function setFeeAddress(address newFeeAddress) external;

    function setMinOfferValue(uint256 newMinOfferValue) external;

    function setAnswerFee(uint256 newAnswerFee) external;

    function setMinFinshTime(uint48 newMinFinshTime) external;

    function setBlockSkip(uint48 newBlockSkip) external;
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
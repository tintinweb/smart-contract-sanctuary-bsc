// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ICondominium.sol";

//import "hardhat/console.sol";

contract CondominiumAdapter {
    ICondominium private implementation;
    address public immutable owner;

    //EVENTS
    event QuotaChanged(uint amount);

    event ManagerChanged(address manager);

    event TopicChanged(
        bytes32 indexed topicId,
        string title,
        Lib.Status indexed status
    );

    event Transfer(address to, uint indexed amount, string topic);

    constructor() {
        owner = msg.sender;
    }

    modifier upgraded() {
        require(
            address(implementation) != address(0),
            "You must upgrade first"
        );
        _;
    }

    function getAddress() external view returns (address) {
        return address(implementation);
    }

    function upgrade(address newImplementation) external {
        require(msg.sender == owner, "You do not have permission");
        require(newImplementation != address(0), "Invalid address");
        implementation = ICondominium(newImplementation);
    }

    function addResident(
        address resident,
        uint16 residenceId
    ) external upgraded {
        return implementation.addResident(resident, residenceId);
    }

    function removeResident(address resident) external upgraded {
        return implementation.removeResident(resident);
    }

    function setCounselor(address resident, bool isEntering) external upgraded {
        return implementation.setCounselor(resident, isEntering);
    }

    function addTopic(
        string memory title,
        string memory description,
        Lib.Category category,
        uint amount,
        address responsible
    ) external upgraded {
        return
            implementation.addTopic(
                title,
                description,
                category,
                amount,
                responsible
            );
    }

    function editTopic(
        string memory topicToEdit,
        string memory description,
        uint amount,
        address responsible
    ) external upgraded {
        Lib.TopicUpdate memory topic = implementation.editTopic(
            topicToEdit,
            description,
            amount,
            responsible
        );

        emit TopicChanged(topic.id, topic.title, topic.status);
    }

    function removeTopic(string memory title) external upgraded {
        Lib.TopicUpdate memory topic = implementation.removeTopic(title);
        emit TopicChanged(topic.id, topic.title, topic.status);
    }

    function openVoting(string memory title) external upgraded {
        Lib.TopicUpdate memory topic = implementation.openVoting(title);
        emit TopicChanged(topic.id, topic.title, topic.status);
    }

    function vote(string memory title, Lib.Options option) external upgraded {
        return implementation.vote(title, option);
    }

    function closeVoting(string memory title) external upgraded {
        Lib.TopicUpdate memory topic = implementation.closeVoting(title);
        emit TopicChanged(topic.id, topic.title, topic.status);

        if (topic.status == Lib.Status.APPROVED) {
            if (topic.category == Lib.Category.CHANGE_MANAGER)
                emit ManagerChanged(implementation.getManager());
            else if (topic.category == Lib.Category.CHANGE_QUOTA)
                emit QuotaChanged(implementation.getQuota());
        }
    }

    function payQuota(uint16 residenceId) external payable upgraded {
        return implementation.payQuota{value: msg.value}(residenceId);
    }

    function transfer(string memory topicTitle, uint amount) external upgraded {
        Lib.TransferReceipt memory receipt = implementation.transfer(
            topicTitle,
            amount
        );
        emit Transfer(receipt.to, receipt.amount, receipt.topic);
    }

    function getManager() external view upgraded returns (address) {
        return implementation.getManager();
    }

    function getQuota() external view upgraded returns (uint) {
        return implementation.getQuota();
    }

    function getResident(
        address resident
    ) external view upgraded returns (Lib.Resident memory) {
        return implementation.getResident(resident);
    }

    function getResidents(
        uint page,
        uint pageSize
    ) external view upgraded returns (Lib.ResidentPage memory) {
        return implementation.getResidents(page, pageSize);
    }

    function getTopic(
        string memory title
    ) external view upgraded returns (Lib.Topic memory) {
        return implementation.getTopic(title);
    }

    function getTopics(
        uint page,
        uint pageSize
    ) external view upgraded returns (Lib.TopicPage memory) {
        return implementation.getTopics(page, pageSize);
    }

    function getVotes(
        string memory topicTitle
    ) external view upgraded returns (Lib.Vote[] memory) {
        return implementation.getVotes(topicTitle);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library CondominiumLib {
     enum Status {
        IDLE,
        VOTING,
        APPROVED,
        DENIED,
        DELETED,
        SPENT
    } //0,1,2,3

    enum Options {
        EMPTY,
        YES,
        NO,
        ABSTENTION
    } //0,1,2,3

    enum Category {
        DECISION,
        SPENT,
        CHANGE_QUOTA,
        CHANGE_MANAGER
    } //0,1,2,3

    struct Topic {
        string title;
        string description;
        Status status;
        uint256 createdDate;
        uint256 startDate;
        uint256 endDate;
        Category category;
        uint amount;
        address responsible;
    }

    struct Vote {
        address resident;
        uint16 residence;
        Options option;
        uint256 timestamp;
    }

    struct TopicUpdate {
        bytes32 id;
        string title;
        Status status;
        Category category;
    }

    struct TransferReceipt {
        address to;
        uint amount;
        string topic;
    }

    struct Resident {
        address wallet;
        uint16 residence;
        bool isCounselor;
        bool isManager;
        uint nextPayment;
    }

    struct ResidentPage {
        Resident[] residents;
        uint total;
    }

    struct TopicPage {
        Topic[] topics;
        uint total;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {CondominiumLib as Lib} from "./CondominiumLib.sol";

interface ICondominium {
    function addResident(address resident, uint16 residenceId) external;

    function removeResident(address resident) external;

    function setCounselor(address resident, bool isEntering) external;

    function addTopic(
        string memory title,
        string memory description,
        Lib.Category category,
        uint amount,
        address responsible
    ) external;

    function editTopic(
        string memory topicToEdit,
        string memory description,
        uint amount,
        address responsible
    ) external returns (Lib.TopicUpdate memory);

    function removeTopic(string memory title)
        external
        returns (Lib.TopicUpdate memory);

    function openVoting(string memory title)
        external
        returns (Lib.TopicUpdate memory);

    function vote(string memory title, Lib.Options option) external;

    function closeVoting(string memory title)
        external
        returns (Lib.TopicUpdate memory);

    function payQuota(uint16 residenceId) external payable;

    function transfer(string memory topicTitle, uint amount) external returns (Lib.TransferReceipt memory);

    function getManager() external view returns (address);

    function getQuota() external view returns (uint);

    function getResident(address resident) external view returns (Lib.Resident memory);

    function getResidents(uint page, uint pageSize) external view returns (Lib.ResidentPage memory);

    function getTopic(string memory title) external view returns (Lib.Topic memory);

    function getTopics(uint page, uint pageSize) external view returns (Lib.TopicPage memory);

    function getVotes(string memory topicTitle) external view returns (Lib.Vote[] memory);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./ICondominium.sol";

contract CondominiumAdapter {
    ICondominium private implementation;
    address public immutable owner;

    //EVENTS
    event QuotaChanged(uint newAmount);

    event ManagerChanged(address newManager);

    event TopicChanged(
        bytes32 indexed topicId,
        string title,
        Lib.Status indexed status
    );

    event Transfer(address to, uint indexed amount, string topic);

    constructor() {
        owner = msg.sender;
    }

    function getAddress() external view returns (address) {
        return address(implementation);
    }

    function addResident(address resident, uint16 residenceId)
        external
        upgraded
    {
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
        emit TopicChanged(topic.id, topic.title, Lib.Status.DELETED);
    }

    function openVoting(string memory title) external upgraded {
        Lib.TopicUpdate memory topic = implementation.openVoting(title);
        emit TopicChanged(topic.id, topic.title, Lib.Status.VOTING);
    }

    function vote(string memory title, Lib.Options opt) external upgraded {
        return implementation.vote(title, opt);
    }

    function closeVoting(string memory title) external upgraded {
        Lib.TopicUpdate memory topic = implementation.closeVoting(title);
        emit TopicChanged(topic.id, topic.title, topic.status);

        if (topic.status == Lib.Status.APPROVED) {
            if (topic.category == Lib.Category.CHANGE_QUOTA) {
                emit QuotaChanged(implementation.getQuota());
            } else if (topic.category == Lib.Category.CHANGE_MANAGER) {
                emit ManagerChanged(implementation.getManager());
            }
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

    function upgrade(address newImplementation) external {
        require(msg.sender == owner, "You do not have permission");
        require(newImplementation != address(0), "Invalid address");
        implementation = ICondominium(newImplementation);
    }

    modifier upgraded() {
        require(
            address(implementation) != address(0),
            "You must upgrade first"
        );
        _;
    }

    function getManager() external view upgraded returns (address) {
        return implementation.getManager();
    }

    function getQuota() external view upgraded returns (uint) {
        return implementation.getQuota();
    }

    function getTopics(uint page, uint pageSize)
        external
        view
        upgraded
        returns (Lib.Topic[] memory)
    {
        return implementation.getTopics(page, pageSize);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library CondominiumLib {
    enum Options {
        EMPTY,
        YES,
        NO,
        ABSTENTION
    }

    enum Status {
        IDLE,
        VOTING,
        APPROVED,
        DENIED,
        DELETED,
        SPENT
    } //0,1,2,3

    enum Category {
        DECISION,
        SPENT,
        CHANGE_QUOTA,
        CHANGE_MANAGER
    }

    struct Topic {
        string title;
        string description;
        Status status;
        uint256 createdDate;
        uint256 startDate;
        uint256 endDate;
        uint256 amount;
        address responsible;
        Category category;
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

    struct Vote {
        address resident;
        uint16 residence;
        Options option;
        uint256 timestamp;
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

    function removeTopic(string memory title) external returns (Lib.TopicUpdate memory);

    function openVoting(string memory title) external returns (Lib.TopicUpdate memory);

    function vote(string memory title, Lib.Options opt) external;

    function closeVoting(string memory title) external returns (Lib.TopicUpdate memory);

    function payQuota(uint16 residenceId) external payable;

    function transfer(string memory topicTitle, uint amount) external returns (Lib.TransferReceipt memory);

    function getManager() external view returns (address);

    function getQuota() external view returns (uint);

    function getTopics(uint page, uint pageSize)
        external
        view
        returns (Lib.Topic[] memory);
}
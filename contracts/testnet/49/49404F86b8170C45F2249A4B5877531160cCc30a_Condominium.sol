// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Condominium {
    address public manager; //Ownable
    mapping(uint16 => bool) public residences; //unidade => true
    mapping(address => uint16) public residents; //wallet => unidade (1101) (2505)
    mapping(address => bool) public counselors; //conselheiro => true

    enum Status {
        IDLE,
        VOTING,
        APPROVED,
        DENIED
    } //0,1,2,3

    enum Options {
        EMPTY,
        YES,
        NO,
        ABSTENTION
    } //0,1,2,3

    struct Topic {
        string title;
        string description;
        Status status;
        uint256 createdDate;
        uint256 startDate;
        uint256 endDate;
    }

    struct Vote {
        address resident;
        uint16 residence;
        Options option;
        uint256 timestamp;
    }

    mapping(bytes32 => Topic) public topics;
    mapping(bytes32 => Vote[]) public votings;

    constructor() {
        manager = msg.sender;

        for (uint8 i = 1; i <= 2; i++) {
            //os blocos
            for (uint8 j = 1; j <= 5; j++) {
                //os andares
                for (uint8 k = 1; k <= 5; k++) {
                    //as unidades
                    unchecked {
                        residences[(i * 1000) + (j * 100) + k] = true;
                    }
                }
            }
        }
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can do this");
        _;
    }

    modifier onlyCouncil() {
        require(
            msg.sender == manager || counselors[msg.sender],
            "Only the manager or the council can do this"
        );
        _;
    }

    modifier onlyResidents() {
        require(
            msg.sender == manager || isResident(msg.sender),
            "Only the manager or the residents can do this"
        );
        _;
    }

    function residenceExists(uint16 residenceId) public view returns (bool) {
        return residences[residenceId];
    }

    function isResident(address resident) public view returns (bool) {
        return residents[resident] > 0;
    }

    function addResident(address resident, uint16 residenceId)
        external
        onlyCouncil
    {
        require(residenceExists(residenceId), "This residence does not exists");
        residents[resident] = residenceId;
    }

    function removeResident(address resident) external onlyManager {
        require(!counselors[resident], "A counselor cannot be removed");
        delete residents[resident];

        if (counselors[resident]) delete counselors[resident];
    }

    function setCounselor(address resident, bool isEntering)
        external
        onlyManager
    {
        if (isEntering) {
            require(isResident(resident), "The counselor must be a resident");
            counselors[resident] = true;
        } else delete counselors[resident];
    }

    function setManager(address newManager) external onlyManager {
        require(newManager != address(0), "The address must be valid");
        manager = newManager;
    }

    function getTopic(string memory title) public view returns (Topic memory) {
        bytes32 topicId = keccak256(bytes(title));
        return topics[topicId];
    }

    function topicExists(string memory title) public view returns (bool) {
        return getTopic(title).createdDate > 0;
    }

    function addTopic(string memory title, string memory description)
        external
        onlyResidents
    {
        require(!topicExists(title), "This topic already exists");

        Topic memory newTopic = Topic({
            title: title,
            description: description,
            createdDate: block.timestamp,
            startDate: 0,
            endDate: 0,
            status: Status.IDLE
        });

        topics[keccak256(bytes(title))] = newTopic;
    }

    function removeTopic(string memory title) external onlyManager {
        Topic memory topic = getTopic(title);
        require(topic.createdDate > 0, "The topic does not exists");
        require(topic.status == Status.IDLE, "Only IDLE topics can be removed");
        delete topics[keccak256(bytes(title))];
    }

    function openVoting(string memory title) external onlyManager {
        Topic memory topic = getTopic(title);
        require(topic.createdDate > 0, "The topic does not exists");
        require(
            topic.status == Status.IDLE,
            "Only IDLE topics can be open for voting"
        );

        bytes32 topicId = keccak256(bytes(title));
        topics[topicId].status = Status.VOTING;
        topics[topicId].startDate = block.timestamp;
    }

    function vote(string memory title, Options option) external onlyResidents {
        require(option != Options.EMPTY, "The option cannot be EMPTY");

        Topic memory topic = getTopic(title);
        require(topic.createdDate > 0, "The topic does not exists");
        require(
            topic.status == Status.VOTING,
            "Only VOTING topics can be voted"
        );

        uint16 residence = residents[msg.sender];
        bytes32 topicId = keccak256(bytes(title));

        Vote[] memory votes = votings[topicId];
        for (uint8 i = 0; i < votes.length; i++) {
            if (votes[i].residence == residence)
                require(false, "A residence should vote only once");
        }

        Vote memory newVote = Vote({
            residence: residence,
            resident: msg.sender,
            option: option,
            timestamp: block.timestamp
        });

        votings[topicId].push(newVote);
    }

    function closeVoting(string memory title) external onlyManager {
        Topic memory topic = getTopic(title);
        require(topic.createdDate > 0, "The topic does not exists");
        require(
            topic.status == Status.VOTING,
            "Only VOTING topics can be closed"
        );

        uint8 approved = 0;
        uint8 denied = 0;
        uint8 abstentions = 0;
        bytes32 topicId = keccak256(bytes(title));
        Vote[] memory votes = votings[topicId];

        for (uint8 i = 0; i < votes.length; i++) {
            if (votes[i].option == Options.YES) approved++;
            else if (votes[i].option == Options.NO) denied++;
            else abstentions++;
        }

        if (approved > denied) topics[topicId].status = Status.APPROVED;
        else topics[topicId].status = Status.DENIED;

        topics[topicId].endDate = block.timestamp;
    }

    function numberOfVotes(string memory title) external view returns(uint256) {
        bytes32 topicId = keccak256(bytes(title));
        return votings[topicId].length;
    }
}
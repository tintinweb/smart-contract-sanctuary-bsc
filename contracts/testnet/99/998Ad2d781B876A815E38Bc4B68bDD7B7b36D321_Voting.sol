/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

contract Voting {
    struct Question {
        uint32 questionId;
        address questionOwner;
        string questionStatement;
        string questionDescription;
        string[] options;
        Status status;
        uint256 questionCategory;
        uint256 optionCount;
        uint256 startDate;
        uint256 endDate;
    }

    enum Status {
        NEW,
        ACTIVE,
        INACTIVE,
        EXPIRED
    }

    uint256 private constant N_QUESTION_CATEGORIES = 10;
    uint32 public totalQuestions;
    uint256 public totalVotes;
    uint256 public totalVoters;
    address public owner;

    mapping(uint32 => Question) public mapQuestions; // map(questionId => Question)
    mapping(address => bool) public mapUsers; // map(address => exists)
    mapping(address => mapping(uint32 => bool)) public mapUserVotes; // map(address => map(questionId => voted))

    // Constructor
    constructor() {
        owner = _msgSender();
    }

    // Modifiers
    modifier onlyOwner() {
        require(_msgSender() == owner, "Caller is not the owner.");
        _;
    }

    modifier validQuestion(uint32 _qid) {
        require(_qid > 0 && mapQuestions[_qid].questionId > 0, "Question does not exists.");
        _;
    }

    // Events
    event EQuestion(
        address userAddress,
        uint32 questionId,
        uint256 questionCategory,
        uint256 questionStatusId,
        string questionStatement,
        string questionDescription,
        string[] options,
        uint256 startDate,
        uint256 endDate
    );

    event EQuestionStatus(address userAddress, uint32 questionId, uint256 questionStatusId);

    event EUserVote(address userAddress, uint32 questionId, uint256 optionId);

    // Functions
    function addQuestion(
        uint256 _qcategory,
        string memory _qStatement,
        string memory _qDescription,
        string[] memory _options,
        uint256 _startDate,
        uint256 _endDate
    ) external {
        require(_qcategory > 0 && _qcategory <= N_QUESTION_CATEGORIES, "Invalid question category.");
        require(bytes(_qStatement).length != 0, "Invalid question statement.");
        uint256 optionCount = _options.length;
        require(optionCount >= 2 && optionCount <= 5, "Option count should be between 2 & 5, both inclusive.");
        require(_startDate >= block.timestamp && _endDate > _startDate, "Invalid dates");

        uint32 qid = ++totalQuestions;

        Question storage quest = mapQuestions[qid];
        quest.questionId = qid;
        quest.questionOwner = _msgSender();
        quest.questionCategory = _qcategory;
        quest.questionStatement = _qStatement;
        quest.optionCount = optionCount;
        quest.options = _options;
        quest.startDate = _startDate;
        quest.endDate = _endDate;
        quest.status = Status.NEW;

        emit EQuestion(
            _msgSender(),
            qid,
            _qcategory,
            uint256(Status.NEW),
            _qStatement,
            _qDescription,
            _options,
            _startDate,
            _endDate
        );
    }

    function enableQuestion(uint32 _qid) external onlyOwner validQuestion(_qid) {
        require(
            (mapQuestions[_qid].status == Status.NEW || mapQuestions[_qid].status == Status.INACTIVE),
            "Invalid question status."
        );
        require(block.timestamp >= mapQuestions[_qid].startDate, "Question start date is ahead.");

        if (block.timestamp < mapQuestions[_qid].endDate) {
            mapQuestions[_qid].status = Status.ACTIVE;
            emit EQuestionStatus(_msgSender(), _qid, uint256(Status.ACTIVE));
        } else {
            mapQuestions[_qid].status = Status.EXPIRED;
            emit EQuestionStatus(_msgSender(), _qid, uint256(Status.EXPIRED));
        }
    }

    function disableQuestion(uint32 _qid) external onlyOwner validQuestion(_qid) {
        require(mapQuestions[_qid].status == Status.ACTIVE, "Invalid question status.");
        if (block.timestamp < mapQuestions[_qid].endDate) {
            mapQuestions[_qid].status = Status.INACTIVE;
            emit EQuestionStatus(_msgSender(), _qid, uint256(Status.INACTIVE));
        } else {
            mapQuestions[_qid].status = Status.EXPIRED;
            emit EQuestionStatus(_msgSender(), _qid, uint256(Status.EXPIRED));
        }
    }

    function vote(uint32 _qid, uint256 _optionId) external validQuestion(_qid) {
        if (mapQuestions[_qid].status != Status.EXPIRED && block.timestamp > mapQuestions[_qid].endDate) {
            mapQuestions[_qid].status = Status.EXPIRED;
            emit EQuestionStatus(_msgSender(), _qid, uint256(Status.EXPIRED));
            return;
        }

        if (mapQuestions[_qid].status == Status.NEW && block.timestamp >= mapQuestions[_qid].startDate) {
            mapQuestions[_qid].status = Status.ACTIVE;
            emit EQuestionStatus(_msgSender(), _qid, uint256(Status.ACTIVE));
        }

        require(mapQuestions[_qid].status == Status.ACTIVE, "Invalid question status.");

        require(mapUserVotes[_msgSender()][_qid] == false, "User already voted.");
        require(_optionId > 0 && _optionId <= mapQuestions[_qid].optionCount, "Invalid option choosen.");

        mapUserVotes[_msgSender()][_qid] = true;
        totalVotes++;

        if (mapUsers[_msgSender()] == false) {
            mapUsers[_msgSender()] = true;
            totalVoters++;
        }

        emit EUserVote(_msgSender(), _qid, _optionId);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address.");
        owner = _newOwner;
    }

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}
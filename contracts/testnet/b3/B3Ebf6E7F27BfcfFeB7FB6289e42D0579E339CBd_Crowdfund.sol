// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
}

// -------------------------------------------------------------------------------- //

contract Crowdfund {
    struct Project {
        address owner;
        uint goal;
        uint pledged;
        uint startAt;
        uint endAt;
        bool claimed;
    }

    IERC20 public immutable token;
    uint public projectCount;
    mapping (uint => Project) public projects;
    mapping (uint => mapping (address => uint)) public pledgedAmount;

    event Launch(uint id, address owner, uint goal, uint startAt, uint endAt);
    event Pledge(uint id, address pledger, uint pledgedAmount);
    event Unpledge(uint id, address unpledger, uint unpledgedAmount);
    event Claim(uint id, address claimer, uint claimAmount);
    event Refund(uint id, address refunder, uint refundAmount);
    event Cancel(uint id);

    // -------------------------------------------------------------------------------- //

    constructor(address _token) {
        token = IERC20(_token);
    }

    function launch(uint _goal, uint _startAt, uint _endAt) external {
        require(_startAt >= block.timestamp);
        require(_endAt > _startAt);

        projects[projectCount] = Project({
            owner: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(projectCount, msg.sender, _goal, _startAt, _endAt);
    }

    function pledge(uint _id, uint _amount) external afterStart(_id) beforeEnd(_id) {
        pledgedAmount[_id][msg.sender] += _amount;
        projects[_id].pledged += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function unpledge(uint _id, uint _amount) external afterStart(_id) beforeEnd(_id) {
        Project storage project = projects[_id];
        require(pledgedAmount[_id][msg.sender] >= _amount);

        pledgedAmount[_id][msg.sender] -= _amount;
        project.pledged -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external onlyOwner(_id) afterEnd(_id) {
        Project storage project = projects[_id];
        require(project.pledged >= project.goal);
        require(!project.claimed);

        project.claimed = true;
        token.transfer(msg.sender, project.pledged);

        emit Claim(_id, msg.sender, project.pledged);
    }

    function refund(uint _id) external afterEnd(_id) {
        Project storage project = projects[_id];
        require(project.pledged < project.goal);

        uint refundAmount = pledgedAmount[_id][msg.sender];
        
        project.pledged -= refundAmount;
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, refundAmount);

        emit Refund(_id, msg.sender, refundAmount);
    }

    function cancel(uint _id) external onlyOwner(_id) beforeStart(_id) {
        delete(projects[_id]);
        emit Cancel(_id);
    }

    // -------------------------------------------------------------------------------- //

    modifier onlyOwner(uint id) {
        require(msg.sender == projects[id].owner);
        _;
    }

    modifier beforeStart(uint id) {
        require(block.timestamp < projects[id].startAt);
        _;
    }

    modifier afterStart(uint id) {
        require(block.timestamp >= projects[id].startAt);
        _;
    }

    modifier beforeEnd(uint id) {
        require(block.timestamp < projects[id].endAt);
        _;
    }

    modifier afterEnd(uint id) {
        require(block.timestamp >= projects[id].endAt);
        _;
    }
}
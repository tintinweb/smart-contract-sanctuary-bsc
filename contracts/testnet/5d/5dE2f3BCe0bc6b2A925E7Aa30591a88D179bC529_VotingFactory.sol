// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./VotingPoll.sol";

contract VotingFactory {
    address[] public allPolls;
    
    event PollCreated(address deployer, address addr);

    constructor () {
    }

    function getAllPolls() external view returns(address[] memory){
        return allPolls;
    }

    function newVotingPoll(string memory _title, string[] memory _options) external returns(address votingPoll) {
        votingPoll = address(new VotingPoll(msg.sender, _title, _options));
        allPolls.push(votingPoll);
        emit PollCreated(msg.sender, votingPoll);
        return votingPoll;
    }

    function getPollsCount () external view returns(uint256 cnt) {
        return allPolls.length;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;

import "./VotingFactory.sol";

contract VotingPoll {

    address private owner;

    string public votingTitle;
    string[] public options;
    mapping (address => int) voteResult;
    bool public votingStatus;

    constructor (address _creater, string memory _title, string[] memory _options) {
        owner = _creater;
        votingTitle = _title;
        options = _options;
        votingStatus = false;
    }

    function getOwner() external view returns(address) {
        return owner;
    }

    function getTitle() external view returns(string memory) {
        return votingTitle;
    }

    function getOptions() external view returns(string[] memory) {
        return options;
    }
    
    function getStatus() external view returns(bool) {
        return votingStatus;
    }

    function pauseVoting () external {
        require(msg.sender == owner, "You're not owner!");
        // require(votingTitle != null, "No voting poll exists");
        votingStatus = !votingStatus;
    }

    function vote (int _value) external {
        require(voteResult[msg.sender] == 0, "You can't vote any more.");
        voteResult[msg.sender] = _value;
    }
}
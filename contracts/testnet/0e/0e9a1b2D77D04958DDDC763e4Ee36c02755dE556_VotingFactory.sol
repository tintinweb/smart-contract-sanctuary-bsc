// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./VotingPoll.sol";

contract VotingFactory {
    uint256 pollCount;
    address[] public allPolls;
    
    event PollCreated(address deployer, address addr);

    constructor () {
        pollCount = 0;
    }

    function newVotignPoll(string memory _title, uint _optionNumber, string[] memory _options) external {
        address _votingPoll = address(new VotingPoll(msg.sender, _title, _optionNumber, _options));
        pollCount ++;
        allPolls.push(_votingPoll);
        emit PollCreated(msg.sender, _votingPoll);
        
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;
import "./VotingFactory.sol";
contract VotingPoll {

    address public owner;
    string public votingTitle;
    uint public optionNumber;
    string[] public options;
    mapping (address => int) voteResult;
    bool public votingStatus;

    constructor (address _creater, string memory _title, uint _optionNumber, string[] memory _options) {
        owner = _creater;
        votingTitle = _title;
        optionNumber = _optionNumber;
        for(uint i = 0; i < _optionNumber; i++) {
            string memory temp = _options[i];
            options[i] = temp;
        }
        votingStatus = false;
    }

    function pauseVoting () external {
        require(msg.sender == owner, "You're not owner!");
        // require(votingTitle != null, "No voting poll exists");
        votingStatus = !votingStatus;
    }

    function vote (int _value) external {
        voteResult[msg.sender] = _value;
    }
}
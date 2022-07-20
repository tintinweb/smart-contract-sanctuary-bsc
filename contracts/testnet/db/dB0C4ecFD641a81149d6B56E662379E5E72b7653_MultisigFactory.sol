// SPDX-License-Identifier: MIT
pragma solidity >=0.8.5;

import "./Multisig.sol";

contract MultisigFactory {

    event NewProposal(address _address);

    function createNewProposal(string memory _title, address[] memory _participant, uint256 _requiredCount)
        external
        returns (address)   {
        Multisig newContract = new Multisig(_title, _participant, _requiredCount);

        emit NewProposal(address(newContract));
        
        return address(newContract);
    }
  
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.5;

contract Multisig {
    string public title;
    address[] public participant;
    uint256 public requiredCount;
    uint256 public votedCount = 0;
    bool public passValid = false;
    mapping (address => bool) public voted;

    constructor(string memory _title, address[] memory _participant, uint256 _requiredCount) {
        title = _title;
        participant = _participant;
        requiredCount = _requiredCount;
    }

    modifier onlyParticipant {
        bool validParticipant = false;
        for(uint256 count = 0;count < participant.length;count++) {
            if(msg.sender == participant[count]) {
                validParticipant = true;
            }
        }
        require(validParticipant,"You are not a participant!");
        _;
    }

    function vote() external onlyParticipant {
        require(!voted[msg.sender], "You have already voted!");
        voted[msg.sender] = true;
        votedCount += 1;
        if(votedCount >= requiredCount) {
            passValid = true;
        }
    }

    function isPassValid() external view returns (bool) {
        return passValid;
    }

    function votedParticipant() external view returns (address[] memory) {
        address[] memory votedParticipants = new address[](votedCount);
        uint256 temp_count = 0;
        for(uint256 count = 0;count < participant.length;count++) {
            if(voted[participant[count]] == true) {
                votedParticipants[temp_count] = participant[count];
                temp_count += 1;
            }
            
        }
        return votedParticipants;
    }
  
}
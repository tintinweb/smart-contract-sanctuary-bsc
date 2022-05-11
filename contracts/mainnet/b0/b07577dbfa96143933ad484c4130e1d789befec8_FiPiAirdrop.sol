// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./context.sol";
import './safeMath.sol';
import './IERC20.sol';

contract FiPiAirdrop is Ownable {
    using SafeMath for uint256;

    struct Participant {
        
        uint256 fipiTokenAirdoped;

        uint256 fipiTokenClaimed;

    }

    event Claimed(address indexed account, uint256 indexed amount);

   
    uint256 public airDropDate;
    
    IERC20 public fiPiToken;

    mapping(address => Participant) public participants;
    
    function setAirDropDate(uint256 _airDropDate) external onlyOwner {
        airDropDate = _airDropDate;
    }


    function setTokenAdress(IERC20 _fipiToken) external onlyOwner {
        fiPiToken = _fipiToken;
    }

    function addParticipant(address user, uint256 _fipiTokenAirdoped) external onlyOwner {
        require(user != address(0));
        participants[user].fipiTokenAirdoped = _fipiTokenAirdoped;
    }


    function addParticipantBatch(address[] memory _addresses, uint256[] memory _alloc) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) 
        {
            participants[_addresses[i]].fipiTokenAirdoped = _alloc[i];
        }
    }

    function revokeParticipant(address user) external onlyOwner {
        require(user != address(0));
        participants[user].fipiTokenAirdoped = 0;
    }

    constructor() 
    {

    } 

    function claim() public
    {
        require(msg.sender != address(0));
        Participant storage participant = participants[msg.sender];

        require(participant.fipiTokenAirdoped > 0, "You dont have allocation!");


        require(airDropDate > 0, "Airdrop date is not yet provided!");
        require(block.timestamp > airDropDate, "Airdrop is not active yet");

        require(participant.fipiTokenClaimed == 0, "You already claimed!");

        uint256 amount = participant.fipiTokenAirdoped;
        
        participant.fipiTokenClaimed = amount;
        fiPiToken.transfer(msg.sender, amount);
        
        emit Claimed(msg.sender, amount);

    }

    function withDrawLeftTokens() external onlyOwner {
        fiPiToken.transfer(msg.sender, fiPiToken.balanceOf(address(this)));
    }
    
}
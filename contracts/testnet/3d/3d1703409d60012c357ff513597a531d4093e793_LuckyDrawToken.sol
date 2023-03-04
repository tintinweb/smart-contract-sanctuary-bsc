/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

pragma solidity ^0.8.0;

interface Token {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract LuckyDrawToken {
    address public owner;
    Token public token;
    uint256 public ticketPrice;
    uint256 public jackpot;
    uint256 public developersCut;
    mapping(address => bool) public participants;
    address[] public participantList;

    constructor(address _tokenAddress, uint256 _ticketPrice) {
        owner = msg.sender;
        token = Token(_tokenAddress);
        ticketPrice = _ticketPrice;
        jackpot = 0;
        developersCut = 0;
    }

    function buyTicket() public {
        require(participants[msg.sender] == false, "You have already bought a ticket.");
        require(token.transferFrom(msg.sender, address(this), ticketPrice), "Token transfer failed.");
        participants[msg.sender] = true;
        participantList.push(msg.sender);
        jackpot += ticketPrice;
        developersCut += ticketPrice / 10;
    }

    function chooseWinner() public {
        require(msg.sender == owner, "Only the owner can choose a winner.");
        require(participantList.length > 0, "No one has bought a ticket yet.");

        uint256 index = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % participantList.length;
        address winner = participantList[index];
        token.transferFrom(address(this), winner, jackpot);
        jackpot = 0;
        delete participantList;
        developersCut = 0;
    }

    function getParticipants() public view returns (address[] memory) {
        return participantList;
    }

    function getJackpot() public view returns (uint256) {
        return jackpot;
    }

    function getDevelopersCut() public view returns (uint256) {
        return developersCut;
    }
}
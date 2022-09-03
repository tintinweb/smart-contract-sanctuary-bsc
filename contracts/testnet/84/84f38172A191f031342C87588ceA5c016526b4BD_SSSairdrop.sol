// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./IERC20.sol";
import "./SafeMath.sol";

contract SSSairdrop{
    using SafeMath for uint256;

    address public airdropCreator;
    uint256 public totalParticipants;
    address public tokenAddress;
    uint256 public distributionTime;

    IERC20 private token;

    constructor (address _token, address _airdropCreator, uint256 _distributionTime) public {
        require(_distributionTime > block.timestamp, "Error: distibution time is before current time");
        token = IERC20(_token);
        airdropCreator = _airdropCreator;
        tokenAddress = _token;
        distributionTime = _distributionTime;
    }

    mapping(address=>bool) public participated;

    address[] private participants;

    modifier alreadyParticipant() {
        require(!participated[msg.sender], "You've already participated in the airdrop");
        _;
    }
    modifier onlyAirdropCreator() {
        require(msg.sender == airdropCreator, "Sorry, only airdrop creator can call this function");
        _;
    }

    function participate() external alreadyParticipant {
        require(block.timestamp < distributionTime, "Sorry you're late, you cannot participate at this time");
        participated[msg.sender] = true;

        participants.push(msg.sender);
        totalParticipants = totalParticipants.add(1);
    }

    function airdropUsers() external onlyAirdropCreator {
        require(block.timestamp > distributionTime, "Distribution time hasn't been reached yet");
        uint256 balance = token.balanceOf(address(this)) / totalParticipants;

        uint256 loops = participants.length - 1;
        for(uint i = 0; i <= loops; i++) {
            token.transfer(participants[i], balance);
        }
    }
}
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

    bool public onlyPrivate;

    IERC20 private token;

    constructor (address _token, address _airdropCreator, uint256 _distributionTime, bool _onlyPrivate) public {
        require(_distributionTime > block.timestamp, "Error: distibution time is before current time");
        token = IERC20(_token);
        airdropCreator = _airdropCreator;
        tokenAddress = _token;
        distributionTime = _distributionTime;
        onlyPrivate = _onlyPrivate;
    }

    mapping(address=>bool) public participated;
    mapping(address=>uint256) public userAndQuantity;

    address[] private participants;

    address[] private participantsByAdmin;
    uint256[] private quantityByAdmin;

    modifier alreadyParticipant() {
        require(!participated[msg.sender], "You've already participated in the airdrop");
        _;
    }
    modifier onlyAirdropCreator() {
        require(msg.sender == airdropCreator, "Sorry, only airdrop creator can call this function");
        _;
    }
    modifier privateAddressOnly() {
        require(onlyPrivate,"only private airdrop");
        _;
    }

    function addUsersAndQuantity(address[] calldata userAddresses, uint256[] calldata userQuantity) external onlyAirdropCreator {
        uint256 checkTokens = token.balanceOf(address(this));
        uint256 verifyQuantity;

        uint256 addressLength = userAddresses.length;
        uint256 quantityLength = userQuantity.length;

        onlyPrivate = userAddresses.length > 0;

        require(addressLength == quantityLength,"Array length mismatch");
        for(uint i=0; i<userAddresses.length;i++) {
            participated[userAddresses[i]] = true;
            userAndQuantity[userAddresses[i]] = userQuantity[i];

            participantsByAdmin.push(userAddresses[i]);
            quantityByAdmin.push(userQuantity[i]);

            verifyQuantity = verifyQuantity.add(userQuantity[i]);
        }

        if(verifyQuantity != checkTokens) {
            revert("Total token quantity to be distributed among the users are not equal");
        }
    }

    function participate() external alreadyParticipant privateAddressOnly {
        require(block.timestamp < distributionTime, "Sorry you're late, you cannot participate at this time");
        participated[msg.sender] = true;

        participants.push(msg.sender);
        totalParticipants = totalParticipants.add(1);
    }

    function airdropUsersPrivate() external onlyAirdropCreator privateAddressOnly{
        require(block.timestamp > distributionTime, "Distribution time hasn't been reached yet");
        uint256 balance = token.balanceOf(address(this)) / totalParticipants;

        for(uint256 i=0; i<participantsByAdmin.length;i++) {
            participated[participantsByAdmin[i]] = false; //to avoid reentrancy
            token.transfer(participantsByAdmin[i], quantityByAdmin[i]);
        }
/*
        uint256 loops = participants.length - 1;
        for(uint i = 0; i <= loops; i++) {
            token.transfer(participants[i], balance);
        }
*/
    }

    function airdropUsers() external onlyAirdropCreator {
        require(block.timestamp > distributionTime, "Distribution time hasn't been reached yet");
        uint256 balance = token.balanceOf(address(this)) / totalParticipants;

        uint256 loops = participants.length - 1;
        for(uint i = 0; i <= loops; i++) {
            token.transfer(participants[i], balance);
        }
    }

    function claim() external privateAddressOnly{
        require(block.timestamp > distributionTime, "Distribution time not reached yet");

        participated[msg.sender] = false;
        uint256 balance = userAndQuantity[msg.sender];

        token.transfer(msg.sender,balance);
    }

    function tokens() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function checkStatus() external view returns (bool) {
        if(block.timestamp > distributionTime) {
            return true;
        }
        else {
            return false;
        }
    }
}
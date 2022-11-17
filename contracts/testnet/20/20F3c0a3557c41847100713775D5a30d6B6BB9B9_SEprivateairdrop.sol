// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./IERC20.sol";
import "./SafeMath.sol";

contract SEprivateairdrop{
    using SafeMath for uint256;

    address public airdropCreator;
    address public tokenAddress;
    uint256 public distributionTime;

    IERC20 private token;
    uint256 private checkTokens;
    uint256 private verifyQuantity;

    address public factoryAddress;

    constructor (address _token, address _airdropCreator, uint256 _distributionTime, uint256 _quantity, address _factory) public {
        require(_distributionTime > block.timestamp, "Error: distibution time is before current time");
        token = IERC20(_token);
        airdropCreator = _airdropCreator;
        tokenAddress = _token;
        distributionTime = _distributionTime;
        checkTokens = _quantity;
        factoryAddress = _factory;
    }

    mapping(address=>bool) public claimed;
    mapping(address=>uint256) public userAndQuantity;

    address[] private participantsByAdmin;
    //uint256[] private quantityByAdmin;

    modifier onlyAirdropCreator() {
        require(msg.sender == airdropCreator, "Sorry, only airdrop creator can call this function");
        _;
    }

    modifier notYetClaimed() {
        require(!claimed[msg.sender], "Already claimed");
        _;
    }

    modifier participantOnly() {
        require(userAndQuantity[msg.sender] > 0, "Not a participant");
        _;
    }

    modifier factoryOrAirdropCreator() {
        require(msg.sender == factoryAddress || msg.sender == airdropCreator, "Only factory or airdrop creator can call this function");
        _;
    }

    function addUsersAndQuantity(address[] calldata userAddresses, uint256[] calldata userQuantity) external factoryOrAirdropCreator {
        //uint256 checkTokens = token.balanceOf(address(this)).div(1e18);
        //uint256 verifyQuantity;

        uint256 addressLength = userAddresses.length;
        uint256 quantityLength = userQuantity.length;

        require(addressLength == quantityLength,"Array length mismatch");
        for(uint i=0; i<userAddresses.length;i++) {

            verifyQuantity = verifyQuantity.add(userQuantity[i]);
            if(verifyQuantity > checkTokens) {
                revert("Total token quantity to be distributed among the users is not equal to the tokens present in the contract");
            }
            userAndQuantity[userAddresses[i]] = userQuantity[i];

            participantsByAdmin.push(userAddresses[i]);
        }

    }

    function airdropUsers() external onlyAirdropCreator {
        require(block.timestamp > distributionTime, "Distribution time hasn't been reached yet");

        for(uint256 i=0; i<participantsByAdmin.length;i++) {
            if(claimed[participantsByAdmin[i]] == false) {
            claimed[participantsByAdmin[i]] = true; //to avoid reentrancy
            token.transfer(participantsByAdmin[i], userAndQuantity[participantsByAdmin[i]].mul(1e18));
            }
        }
    }

    function claim() external notYetClaimed participantOnly {
        require(block.timestamp > distributionTime, "Distribution time not reached yet");

        claimed[msg.sender] = true;
        uint256 balance = userAndQuantity[msg.sender].mul(1e18);

        token.transfer(msg.sender,balance);
    }

    function tokens() external view returns (uint256) {
        return token.balanceOf(address(this)).div(1e18);
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
/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

interface IEmergencyOracle {}

contract EmergencyOracle {
    address public owner;
    uint256 public price;
    uint256 public roundId;
    string public description;

    // Align with chainlink
    event AnswerUpdated(
        int256 indexed current,
        uint256 indexed roundId,
        uint256 updatedAt
    );

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyOwner() {
        require(owner == msg.sender, "ONLY_OWNER");
        _;
    }

    constructor(address _owner, string memory _description) {
        owner = _owner;
        description = _description;
    }

    function getMarkPrice() external view returns (uint256) {
        return price;
    }

    function setMarkPrice(uint256 newPrice) external onlyOwner {
        price = newPrice;
        emit AnswerUpdated(int256(price), roundId, block.timestamp);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract EmergencyOracleFactory {
    event NewEmergencyOracle(address owner, address newOracle);

    function newEmergencyOracle(string calldata description) external {
        address newOracle = address(
            new EmergencyOracle(msg.sender, description)
        );
        emit NewEmergencyOracle(msg.sender, newOracle);
    }
}
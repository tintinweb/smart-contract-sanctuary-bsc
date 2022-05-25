/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract RecordDelegation {
    address public owner;
    address public backend;
    struct Delegation {
        string validator;
        string user;
        uint256 amount;
    }
    mapping(string => mapping(string => mapping(string => uint256))) public delegationInfo;
    mapping(string => mapping(string => string[])) public delegatorInfo;
    mapping(string => mapping(string => string[])) public userValidatorInfo;
    mapping(string => mapping(string => mapping(string => bool))) public delegatorExist;
    mapping(string => mapping(string => mapping(string => bool))) public userValidatorExist;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not Backend");
        _;
    }

    modifier onlyBackend() {
        require(msg.sender == backend, "Not Backend");
        _;
    }

    constructor(address _backend) {
        owner = msg.sender;
        backend = _backend;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function setBackend(address _backend) external onlyOwner {
        backend = _backend;
    }

    function stake(string memory ecosystemId, string memory chainId, string memory validatorAddress, string memory userAddress, uint256 amount) external onlyBackend {
        require(amount > 0, "Not enough amount");

        string memory chainData = string(abi.encodePacked(ecosystemId, chainId));
        delegationInfo[chainData][validatorAddress][userAddress] += amount;
        if (!delegatorExist[chainData][validatorAddress][userAddress]) {
            delegatorInfo[chainData][validatorAddress].push(userAddress);
            delegatorExist[chainData][validatorAddress][userAddress] = true;
        }
        if (!userValidatorExist[chainData][userAddress][validatorAddress]) {
            userValidatorInfo[chainData][userAddress].push(validatorAddress);
            userValidatorExist[chainData][userAddress][validatorAddress] = true;
        }
    }

    function unstakeDelegation(string memory ecosystemId, string memory chainId, string memory validatorAddress, string memory userAddress, uint256 amount) external onlyBackend {
        string memory chainData = string(abi.encodePacked(ecosystemId, chainId));
        require(delegationInfo[chainData][validatorAddress][userAddress] >= amount, "Not enough amount");
        
        delegationInfo[chainData][validatorAddress][userAddress] -= amount;
    }
    
    function validatorStakes(string memory ecosystemId, string memory chainId, string memory validatorAddress) external view returns (Delegation[] memory) {
        string memory chainData = string(abi.encodePacked(ecosystemId, chainId));
        Delegation[] memory delegations = new Delegation[](delegatorInfo[chainData][validatorAddress].length);
        for (uint256 i = 0; i < delegatorInfo[chainData][validatorAddress].length; i++) {
            delegations[i].validator = validatorAddress;
            delegations[i].user = delegatorInfo[chainData][validatorAddress][i];
            delegations[i].amount = delegationInfo[chainData][validatorAddress][delegatorInfo[chainData][validatorAddress][i]];
        }
        return delegations;
    }

    function userStakes(string memory ecosystemId, string memory chainId, string memory userAddress) external view returns (Delegation[] memory) {
        string memory chainData = string(abi.encodePacked(ecosystemId, chainId));
        Delegation[] memory delegations = new Delegation[](userValidatorInfo[chainData][userAddress].length);
        for (uint256 i = 0; i < userValidatorInfo[chainData][userAddress].length; i++) {
            delegations[i].validator = userValidatorInfo[chainData][userAddress][i];
            delegations[i].user = userAddress;
            delegations[i].amount = delegationInfo[chainData][userValidatorInfo[chainData][userAddress][i]][userAddress];
        }
        return delegations;
    }
}
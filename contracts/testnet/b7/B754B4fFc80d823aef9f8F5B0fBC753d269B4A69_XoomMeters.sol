/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract XoomMeters {
    address public owner;
    uint256 private constant OWNER_NOT_ENTERED = 1;
    uint256 private constant OWNER_ENTERED = 2;
    uint256 private reentrancyForOwnerStatus;
    mapping(address => uint256) private reentrancyStatusLocked;

    mapping(address => uint) private allowedList;

    // Feature => Function ID => Points
    mapping(uint => mapping(uint => uint256)) private tablePoints;

    struct Meter 
    {
        uint256 score;

        // Function ID => Counter
        mapping(uint => uint) counters;
    }

    // Player => Feature => Meter variable
    mapping(address => mapping(uint => Meter)) private playerMtrs; 

    // Feature => Function ID => Feature Of Meters => Function of Meters => requirement function count
    // Example: To use Deposit function in Timelock Stake Feature you should have a minimum of 100 counts in Approve function of Virtual Stake feature
    //     Feature: 1 (Timelock Stake)
    //     Function ID: 1 (Deposit in Timelock Stake)
    //     Feature of meters: 2 (Virtual Stake)
    //     Function of meters: 1 (Approve in Virtual Stake)
    //         Returns 100
    mapping(uint => mapping(uint => mapping(uint => mapping(uint => uint256)))) private requirementCount;

    // Feature => Function ID => Feature Of Meters => requirement score
    // Example: To use Deposit function in Timelock Stake Feature you should have a minimum of 5 points in Virtual Stake
    //     Feature: 1 (Timelock Stake)
    //     Function ID: 1 (Deposit in Timelock Stake)
    //     Feature of meters: 2 (Virtual Stake)
    //         Returns 5
    mapping(uint => mapping(uint => mapping(uint => uint256))) private requirementScore;


    // Feature => Function ID => Token Address => requirement score
    // Example: To use Deposit function in Timelock Stake Feature you should have a minimum balance of 2000000000000000000 wei of XPTO Token
    //     Feature: 1 (Timelock Stake)
    //     Function ID: 1 (Deposit in Timelock Stake)
    //     Token Address: 0x...
    //         Returns 2000000000000000000
    mapping(uint => mapping(uint => mapping(address => uint256))) private requirementBalance;
    address[] public mappedTokensForRequirementBalance; // To help contract see mapped tokens (PUBLIC)


    /* This notifies clients owner change */
    event OnwerChange(address indexed newValue);

    constructor()
    {
        owner = msg.sender;
        reentrancyForOwnerStatus = OWNER_NOT_ENTERED;
    }

    modifier onlyOwner 
    {
        require(msg.sender == owner, 'FN'); //Forbidden
        _;
    }

    modifier onlyAllowed 
    {
        require(allowedList[msg.sender] == 1, 'FN'); //Forbidden
        _;
    }

    modifier noReentrancyForOwner() 
    {
        require(reentrancyForOwnerStatus != OWNER_ENTERED, "REE");
        reentrancyForOwnerStatus = OWNER_ENTERED;
        _;
        reentrancyForOwnerStatus = OWNER_NOT_ENTERED;
    }

    modifier noReentrancy()
    {
        require(reentrancyStatusLocked[msg.sender] == 0, "REE");
        reentrancyStatusLocked[msg.sender] = 1;
        _;
        reentrancyStatusLocked[msg.sender] = 0;
    }

    modifier validAddress(address _address) 
    {
       require(_address != address(0), "INVAD");
       _;
    }

    modifier validWallet()
    {
        require( !Hlp.isContract(msg.sender), "CTR"); // Wallet is a contract
        require(tx.origin == msg.sender, "INVW"); // Invalid wallet origin
        _;
    }

    function setOwner(address newValue) external onlyOwner noReentrancyForOwner validAddress(newValue) validWallet
    {
        owner = newValue;
        emit OnwerChange(newValue);
    }

    function allowOrDenyAddress(address value, uint permission) external onlyOwner noReentrancyForOwner validAddress(value) validWallet
    {
        allowedList[value] = permission;
    }

    function addScoreAndCounter(address player, uint feature, uint functionId) external onlyAllowed noReentrancy
    {
        playerMtrs[player][feature].score += tablePoints[feature][functionId];
        playerMtrs[player][feature].counters[functionId] += 1;
    }

    function setTablePoints(uint feature, uint functionId, uint256 points) external onlyOwner noReentrancyForOwner validWallet
    {
        tablePoints[feature][functionId] = points;
    }

    function getTablePoints(uint feature, uint functionId) external view returns(uint256)
    {
        return tablePoints[feature][functionId];
    }

    function getPlayerScore(address player, uint feature) external view returns (uint256)
    {
        return playerMtrs[player][feature].score;
    }

    function getPlayerCounter(address player, uint feature, uint functionId) external view returns (uint256)
    {
        return playerMtrs[player][feature].counters[functionId];
    }

    // Example: To use Deposit function in Timelock Stake Feature you should have a minimum of 100 counts in Approve function of Virtual Stake feature
    //     Feature: 1 (Timelock Stake)
    //     Function ID: 1 (Deposit in Timelock Stake)
    //     Feature of meters: 2 (Virtual Stake)
    //     Function of meters: 1 (Approve in Virtual Stake)
    function setRequirementCountForFunction(uint feature, uint functionId, uint featureOfMeters, uint functionIdOfMeters, uint256 count) external onlyOwner noReentrancyForOwner validWallet
    {
        requirementCount[feature][functionId][featureOfMeters][functionIdOfMeters] = count;
    }

    function getRequirementCountForFunction(uint feature, uint functionId, uint featureOfMeters, uint functionIdOfMeters) external view returns(uint256)
    {
        return requirementCount[feature][functionId][featureOfMeters][functionIdOfMeters];
    }

    // Example: To use Deposit function in Timelock Stake Feature you should have a minimum of 5 points in Virtual Stake
    //     Feature: 1 (Timelock Stake)
    //     Function ID: 1 (Deposit in Timelock Stake)
    //     Feature of meters: 2 (Virtual Stake)
    function setRequirementScore(uint feature, uint functionId, uint featureOfMeters, uint256 score) external onlyOwner noReentrancyForOwner validWallet
    {
        requirementScore[feature][functionId][featureOfMeters] = score;
    }

    function getRequirementScore(uint feature, uint functionId, uint featureOfMeters) external view returns(uint256)
    {
        return requirementScore[feature][functionId][featureOfMeters];
    }

    // Example: To use Deposit function in Timelock Stake Feature you should have a minimum balance of 2000000000000000000 wei of XPTO Token
    //     Feature: 1 (Timelock Stake)
    //     Function ID: 1 (Deposit in Timelock Stake)
    //     Token Address: 0x...
    function setRequirementBalance(uint feature, uint functionId, address tokenAddress, uint256 balance) external onlyOwner noReentrancyForOwner validAddress(tokenAddress) validWallet
    {
        requirementBalance[feature][functionId][tokenAddress] = balance;
        uint alreadyMapped = 0;
        for(uint ix = 0; ix < mappedTokensForRequirementBalance.length; ix++)
        {
            if(mappedTokensForRequirementBalance[ix] == tokenAddress)
            {
                alreadyMapped = 1;
                break;
            }
        }

        if(alreadyMapped == 0)
        {
            mappedTokensForRequirementBalance.push(tokenAddress);
        }
    }

    function getRequirementBalance(uint feature, uint functionId, address tokenAddress) external view returns(uint256)
    {
        return requirementBalance[feature][functionId][tokenAddress];
    }

    function validateRequirement(uint feature, uint functionId, uint maxFeatureToCheck, uint maxFunctionToCheck, address player) external view returns (uint)
    {
        uint result = 1;

        for(uint featureOfMeters = 0; featureOfMeters <= maxFeatureToCheck; featureOfMeters++)
        {
            for(uint functionOfMeters = 0; functionOfMeters <= maxFunctionToCheck; functionOfMeters++)
            {
                result = validateRequirementMeters(feature, functionId, featureOfMeters, functionOfMeters, player);

                if(result == 0)
                {
                    break;
                }
            }
        }

        if(result == 0)
        {
            return 0;
        }

        for(uint ix = 0; ix < mappedTokensForRequirementBalance.length; ix++)
        {
            address tokenAddress = mappedTokensForRequirementBalance[ix];
            result = validateRequirementBalances(feature, functionId, tokenAddress, player);

            if(result == 0)
            {
                break;
            }
        }

        return result;
    }

    function validateRequirementMeters(uint feature, uint functionId, uint featureOfMeters, uint functionIdOfMeters, address player) public view returns (uint)
    {
        uint256 requiredScore = requirementScore[feature][functionId][featureOfMeters];
        uint256 requiredCount = requirementCount[feature][functionId][featureOfMeters][functionIdOfMeters];

        Meter storage playerPosition = playerMtrs[player][featureOfMeters];

        if(requiredScore == 0 && requiredCount == 0)
        {
            // Without active requirements, returns valid to use
            return 1;
        }

        if(playerPosition.score < requiredScore)
        {
            // Not enough score
            return 0;
        }

        if(playerPosition.counters[functionIdOfMeters] < requiredCount)
        {
            // Not enough count
            return 0;
        }

        return 1;
    }

    function validateRequirementBalances(uint feature, uint functionId, address tokenAddress, address player) public view returns (uint)
    {
        uint256 requiredBalance = requirementBalance[feature][functionId][tokenAddress];

        if(requiredBalance == 0)
        {
            // Without active requirements, returns valid to use
            return 1;
        }

        uint256 playerTokenBalance = IERC20(tokenAddress).balanceOf(player);

        if(playerTokenBalance < requiredBalance)
        {
            // Not enough balance
            return 0;
        }

        return 1;
    }
}

// ****************************************************
// ***************** ERC-20 INTERFACE *****************
// ****************************************************
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// ****************************************************
// ***************** HELPER FUNCTIONS *****************
// ****************************************************
library Hlp 
{
    function isContract(address account) internal view returns (bool) 
    {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
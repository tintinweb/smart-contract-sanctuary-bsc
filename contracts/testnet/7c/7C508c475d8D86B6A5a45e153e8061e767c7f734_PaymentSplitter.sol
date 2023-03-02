// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";

contract PaymentSplitter is Ownable {

    // User => Claim Amount
    mapping ( address => uint256 ) public claimAmount;

    // Split Structure
    struct Split {
        address[] recipients; // [0xabc, 0x133, 0xacb]
        uint256[] allocations; // [40, 40, 20]
        uint256 totalAllocation;
    }

    // Collection => Royalty Split
    mapping ( address => Split ) public collectionInfo;

    function claimReward() external {
        _claim(msg.sender);
    }

    function claimRewardFor(address user) external {
        _claim(user);
    }

    function withdraw(uint amount, address to) external onlyOwner {
        (bool s,) = payable(to).call{value: amount}("");
        require(s);
    }

    function _claim(address user) internal {
        uint claim = claimAmount[user];
        if (claim == 0) {
            return;
        }

        // reset claim amount
        delete claimAmount[user];

        // send claim amount to user
        (bool s,) = payable(user).call{value: claim, gas: 3200}("");
        require(s);
    }

    function setInfo(address[] calldata recipients, uint256[] calldata allocations) external {

        uint total = 0;
        uint len = recipients.length;
        require(len == allocations.length, 'Mismatch');

        for (uint i = 0; i < len;) {
            total += allocations[i];
            unchecked { ++i; }
        }

        collectionInfo[msg.sender] = Split({
            recipients: recipients,
            allocations: allocations,
            totalAllocation: total
        });
    }

    receive() external payable {

        // Collection Info
        Split memory collection = collectionInfo[msg.sender];

        // variables for gas savings
        uint len = collection.recipients.length;
        uint total = collection.totalAllocation;

        // return if data for msg.sender has not been established
        if (total == 0 || msg.value == 0) {
            return;
        }
        
        // loop through all recipients, increasing their claim amount
        for (uint i = 0; i < len;) {
            
            // increase claim amount for recipient proportional to their allocation
            claimAmount[collection.recipients[i]] += ( msg.value * collection.allocations[i]) / total;
            unchecked {++i;}
        }
    }
}
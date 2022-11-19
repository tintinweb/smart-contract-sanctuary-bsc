/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

//SPDX-License-Identifier: MIT
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

interface IPriceOracle {
    function priceOf(address token) external view returns (uint256);
}

contract MDBPrice is Ownable {

    // MDB Token
    address public constant MDB = 0x0557a288A93ed0DF218785F2787dac1cd077F8f3;

    // Price Oracle
    IPriceOracle public oracle = IPriceOracle(0x952B02F1973a1157cfE1B43d62aC6E1e921C5D00);

    // Approved To Call Update
    mapping ( address => bool ) public approvedToCall;

    // Last Price 
    uint256 public lastAnswer;

    function setPriceOracle(address newOracle) external onlyOwner {
        oracle = IPriceOracle(newOracle);
    }

    function setApprovedToCall(address user, bool isApproved) external onlyOwner {
        approvedToCall[user] = isApproved;
    }

    function updatePrice() external {
        require(
            approvedToCall[msg.sender],
            'NA'
        );

        lastAnswer = oracle.priceOf(MDB);
    }

}
/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

 interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Vault {
    // Mapping from address to uint256 representing the balance of that address
    mapping(address => uint256) public balances;


   // Address of the contract owner
    address public owner;

    // Address of the BNB token contract
    address public bnbTokenAddress = 0xB8c77482e45F1F44dE1745F52C74426C631bDD52;

    // Constructor function to set the owner of the contract
    constructor() {
        owner = msg.sender;
    }

    // Function to allow users to deposit funds into their balance
  function deposit() public payable {
    // Deposit the amount received into the caller's balance
    balances[msg.sender] += msg.value;
}


    // Function to allow the owner to air drop a specified amount of funds to a list of addresses
    function airDrop(address[] memory recipients, uint256 amount) public {
        require(msg.sender == owner, "Only the owner can perform an air drop.");

        for (uint i = 0; i < recipients.length; i++) {
            // Send the specified amount of tokens to each recipient
            IBEP20(bnbTokenAddress).transfer(recipients[i], amount);
        }
    }

    // Function to allow the owner to send a specified amount of funds to a single address
    function singleAirDrop(address recipient, uint256 amount) public {
        require(msg.sender == owner, "Only the owner can perform an air drop.");

        // Send the specified amount of tokens to the recipient
        IBEP20(bnbTokenAddress).transfer(recipient, amount);
    }
}
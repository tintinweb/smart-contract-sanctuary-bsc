/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// SPDX-License-Identifier: Unlicenced

pragma solidity 0.8.15;

interface ERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external payable returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract Ownable {
    address payable public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract TokenBatchTransfer is Ownable {

    ERC20 public token; // Address of token contract
    address public transferOperator; // Address to manage the Transfers

    // Modifiers
    modifier onlyOperator() {
        require(
            msg.sender == transferOperator,
            "Only operator can call this function."
        );
        _;
    }

    constructor(address _token)
    {
        token = ERC20(_token);
        transferOperator = msg.sender;
    }


    // Events
    event NewOperator(address transferOperator);
    event WithdrawToken(address indexed owner, uint256 stakeAmount);

    function updateOperator(address newOperator) public onlyOwner {

        require(newOperator != address(0), "Invalid operator address");
        
        transferOperator = newOperator;

        emit NewOperator(newOperator);
    }

    // To withdraw tokens from contract, to deposit directly transfer to the contract
    function withdrawToken(uint256 value) public onlyOperator
    {

        // Check if contract is having required balance 
        require(token.balanceOf(address(this)) >= value, "Not enough balance in the contract");
        require(token.transfer(msg.sender, value), "Unable to transfer token to the owner account");

        emit WithdrawToken(msg.sender, value);
        
    }

    // To transfer tokens from Contract to the provided list of token holders with respective amount
    
    function batchTransfer(address[] calldata tokenHolders, uint256[] calldata amounts) 
    external 
    onlyOperator
    {
        require(tokenHolders.length == amounts.length, "Invalid input parameters");

        for(uint256 indx = 0; indx < tokenHolders.length; indx++) {
            require(token.transfer(tokenHolders[indx], amounts[indx]), "Unable to transfer token to the account");
        }
    }

}
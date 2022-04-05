// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract TokenBatchTransfer is Ownable {

    using SafeMath for uint256;

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
    public
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
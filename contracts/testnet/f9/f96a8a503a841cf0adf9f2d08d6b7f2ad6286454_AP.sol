/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

pragma solidity ^0.8.16;

// ERC-20 token contract
contract AP {
    // Name of the token
    string public name = "AP";
    // Symbol of the token
    string public symbol = "A";
    // Number of decimals used by the token
    uint8 public decimals = 18;
    // Total supply of the token
    uint256 public totalSupply;

    // Address to receive the transfer fees
    address public feeAddress = 0x66d1DD38E21f3A179d3b8442191Da61be52A08ae;
    // Percentage of the transfer value to be taken as a fee
    uint8 public feePercent = 5;

    // Mapping from addresses to their token balance
    mapping(address => uint256) public balanceOf;

    // Mapping from addresses to their approved spending allowance
    mapping(address => mapping(address => uint256)) public allowance;

  // The contract's constructor sets the total supply of the token
    constructor() public {
    totalSupply = 1000 * (10 ** uint256(decimals));
    // Set the contract owner to the address of the contract creator
    owner = msg.sender;
}


address public owner;

    // Function to transfer tokens from one address to another
    function transfer(address _to, uint256 _value) public {
        // Ensure that the sender has enough tokens and the recipient is not the zero address
        require(balanceOf[msg.sender] >= _value && _to != address(0), "Insufficient balance or invalid recipient");

        // Calculate the transfer fee
        uint256 fee = _value * feePercent / 100;
        // Transfer the tokens and the fee
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        balanceOf[feeAddress] += fee;
    }

    // Function to approve a transfer of tokens from the caller to another address
    function approve(address _spender, uint256 _value) public {
        // Set the approved spending allowance for the spender
        allowance[msg.sender][_spender] = _value;
    }
// Function to set the transfer fee address and percentage
function setFee(address _feeAddress, uint8 _feePercent) public {
    // Only the contract owner can set the fee address and percentage
    require(msg.sender == owner, "Only the contract owner can set the fee");
    // Set the fee address and percentage
    feeAddress = _feeAddress;
    feePercent = _feePercent;
}


}
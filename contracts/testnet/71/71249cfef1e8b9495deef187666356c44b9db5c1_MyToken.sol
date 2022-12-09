/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

pragma solidity ^0.6.0;

// This is the contract for a simple ERC-20 token.
// Replace "MyToken" and "MYT" with the name and symbol of your token.

contract MyToken {
  // The name and symbol of the token
  string public name = "MyToken";
  string public symbol = "MYT";

  // The total supply of the token
  uint256 public totalSupply;

  // The balance of each account
  mapping (address => uint256) public balances;

  // The address of the developer wallet that can mint new tokens
  address public devWallet;

  // This event is emitted when new tokens are minted
  event Mint(address indexed to, uint256 amount);

  // Constructor: initialize the total supply and the developer wallet address
  constructor(uint256 initialSupply, address wallet) public {
    totalSupply = initialSupply;
    devWallet = wallet;
    // Initialize the balance of the developer wallet
    balances[devWallet] = initialSupply;
  }

  // Function to mint new tokens
  function mint(uint256 amount) public {
    require(msg.sender == devWallet, "Only the dev wallet can mint new tokens");
    // Increase the total supply and the balance of the dev wallet
    totalSupply += amount;
    balances[devWallet] += amount;
    // Emit the Mint event
    emit Mint(devWallet, amount);
  }
}
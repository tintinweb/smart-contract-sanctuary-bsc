/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

pragma solidity ^0.6.0;

contract MultiSender {
  // Mapping to store the addresses of the recipients
  mapping(uint256 => address payable) public recipients;

  // Function to add a recipient to the mapping
  function addRecipient(uint256 index, address payable recipient) public {
    recipients[index] = recipient;
  }

  // Function to send a transaction to multiple external accounts
  function sendToMultiple(uint256[] memory recipientIndices, uint256 amount) public payable {
  // Iterate over the array of recipient indices
  for (uint256 i = 0; i < recipientIndices.length; i++) {
    // Get the recipient address from the mapping
    address payable recipient = recipients[recipientIndices[i]];
    // Check if the recipient address is not the zero address
    require(recipient != address(0), "Recipient address is not valid");
    // Send the specified amount to the recipient
    recipient.transfer(amount);
  }
}
}
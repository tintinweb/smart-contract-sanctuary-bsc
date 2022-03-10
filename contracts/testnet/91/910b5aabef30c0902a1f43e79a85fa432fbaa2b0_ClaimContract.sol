/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: MIT
interface IMerkleDistributor {
    // Returns the address of the token distributed by this contract.
    function token() external view returns (address);
    // Returns the merkle root of the merkle tree containing account balances available to claim.
    function merkleRoot() external view returns (bytes32);
    // Returns true if the index has been marked claimed.
    function isClaimed(uint256 index) external view returns (bool);
    // Claim the given amount of the token to the given address. Reverts if the inputs are invalid.
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;

    // This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 index, address account, uint256 amount);
}
contract ClaimContract {
    constructor(uint256 index, address account, uint256 amount, bytes32[] memory merkleProof) public {
        IMerkleDistributor(msg.sender).claim(index,address(this),amount,merkleProof);
    }
}
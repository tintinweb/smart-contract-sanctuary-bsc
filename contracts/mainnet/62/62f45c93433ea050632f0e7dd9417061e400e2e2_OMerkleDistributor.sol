/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

// Allows anyone to claim a token if they exist in a merkle root.
interface IOMerkleDistributor {
    // Returns true if the index has been marked claimed.
    function isClaimed(uint256 index) external view returns (bool);
    // Claim the given amount of the token to the given address. Reverts if the inputs are invalid.
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;

    // This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 index, address account, uint256 amount);
}

library MerkleProof{
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
}

contract OMerkleDistributor is IOMerkleDistributor {
    bytes32 public merkleRoot;
    address public owner;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) internal claimedBitMap;

    constructor(bytes32 _merkleRoot) public {
        merkleRoot = _merkleRoot;
        owner = msg.sender;
    }

    function isClaimed(uint256 index) public override view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) internal {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external virtual override {
        require(!isClaimed(index), "OMerkleDistributor: Drop already claimed.");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "OMerkleDistributor: Invalid proof.");

        // Mark as claimed and send the BNB.
        _setClaimed(index);
        (bool success, bytes memory data) = payable(account).call{value:amount}("ditto.money");
        require(success, 'DittoClaimDistributor: Transfer failed');

        emit Claimed(index, account, amount);
    }

    function withdrawAll(address payable to) external {
        require(msg.sender == owner);

        (bool success, bytes memory data) = to.call{value:address(this).balance}("ditto.money");
        require(success, 'DittoClaimDistributor: WithdrawAll failed');
    }
    
    receive() external payable {
    }
}
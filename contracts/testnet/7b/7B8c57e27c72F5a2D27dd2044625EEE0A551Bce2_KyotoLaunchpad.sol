// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract KyotoLaunchpad {
    struct IDO {
        uint256 tokenPrice; // Token price in BNB
        uint256 tokensForDistribution; // Number of tokens to be distributed
        uint256 whitelistOpenTimestamp; // Timestamp at which the whitelist is open
        uint256 winnersOutTimestamp; // Timestamp at which the winners are out
        uint256 publicInvestmentStartTimestamp; // Timestamp at which the public investment starts
        uint256 idoCloseTimestamp; // Timestamp at which the IDO is closed
        uint256 publicSlots; // Number of users that can invest
      //uint256 publicMaxAllocation Maximum tokens to be allocated for a project  
        uint256 minimumInvestment; //Minimum amount of BNB users must invest
        address idoOwner; // Address of the IDO owner
        address tokenAddress; // Address of the token contract
        bool isRewarded; // Whether the IDO tokens have been rewarded ot the investors
    }

    struct IDOInvestment {
        address[] investors; // Array of investors
        uint256 totalInvestment; // Total investment in BNB
        uint256 publicInvestors; // Number of investors
        uint256 publicTierTotalInvestment; // Total amount of investment made by investors
    }

    // Owner of the contract
    address private _owner;
    // Address of the potential owner
    address private _potentialOwner;

    bytes32 private constant PUBLIC_TIER_ID =
        keccak256(abi.encodePacked("bfc8eb0c-5955-4ccf-98fb-01a17eda7652"));

    // IDO ID => IDO
    mapping(string => IDO) private _idos;
    // IDO ID => Its Merkle Root
    mapping(string => bytes32) private _idoMerkleRoots;
    // IDO ID => User's Address => User's Tier Level When Invested First
    mapping(string => mapping(address => bytes32)) private _idoInvestorTiers;
    // IDO ID => IDO Investment
    mapping(string => IDOInvestment) private _idoInvestments;
    // IDO ID => User's address => Total investment amount
    mapping(string => mapping(address => uint256))
        private _idoInvestorInvestments;

    event OwnerChanged(address newOwner);
    event NominateOwner(address potentialOwner);
    event IDORewarded(string idoID, address tokenAddress, bool isRewarded);
    event SetMerkleRoot(string idoId, bytes32 merkleRoot);
    event Invest(string idoID, address investor, uint256 investment);
    event IDOAdded(string indexed idoID, address idoOwner, address idoToken);

    constructor() {
        _owner = msg.sender;
    }

    receive() external payable {}

    fallback() external {}

    /* View Methods Start */

    /**
     * @notice This method returns the current contract owner address
     */
    function owner() external view returns (address) {
        return _owner;
    }

    /* View Methods End */

    /* Admin Methods Start */

    /**
     * @notice This method is used to nominate a new contract owner
     * @param potentialOwner Address of the New Owner to be nominated
     */
    function addPotentialOwner(address potentialOwner) external {
        _checkForOnlyOwner();
        require(
            potentialOwner != address(0),
            "KyotoLaunchPad: Potential Owner should non-zero!"
        );
        require(
            potentialOwner != _owner,
            "KyotoLaunchPad: Potential Owner should not be owner!"
        );
        _potentialOwner = potentialOwner;
        emit NominateOwner(potentialOwner);
    }

    /**
     * @notice This method is used to add a new IDO project
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO to be added
     * @param ido IDO details
     */
    function addIDO(string calldata idoID, IDO calldata ido) external {
        _checkForOnlyOwner();
        require(
            _idos[idoID].tokenAddress == address(0),
            "KyotoLaunchPad: IDO already exists!"
        );
        _validateIDOData(ido);

        _idos[idoID] = ido;
        require(
            IERC20(ido.tokenAddress).transferFrom(
                ido.idoOwner,
                address(this),
                ido.tokensForDistribution
            ),
            "KyotoLaunchPad: Failed to transfer IDO tokens to KyotoLaunchPad"
        );
        emit IDOAdded(idoID, ido.idoOwner, ido.tokenAddress);
    }

    /**
     * @notice This method is used to get the investment amount of a project
     * @param idoID ID of the IDO
     */
    function getInvestmentAmount(string calldata idoID) external {
        _checkForOnlyOwner();
        require(
            _idos[idoID].tokenAddress != address(0),
            "KyotoLaunchpad: IDO doesn't exist"
        );
        require(
            _idos[idoID].idoCloseTimestamp <= block.timestamp,
            "KyotoLaunchPad: IDO is not ended yet"
        );
        require(
            _idoInvestments[idoID].investors.length != 0,
            "KyotoLaunchPad: No investments found"
        );

        uint amountToTransfer = _idoInvestments[idoID].totalInvestment;

        _idoInvestments[idoID].totalInvestment = 0;

        payable(_owner).transfer(amountToTransfer);
    }

    /**
     * @notice This method is used to set Merkle Root of an IDO
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO
     * @param merkleRoot Merkle Root of the IDO
     */
    function addMerkleRoot(string calldata idoID, bytes32 merkleRoot) external {
        _checkForOnlyOwner();
        require(
            _idos[idoID].tokenAddress != address(0),
            "KyotoLaunchpad: IDO doesn't exist"
        );
        // _checkThatIDOIndNotRewarded(idoID);
        require(
            _idoMerkleRoots[idoID] == bytes32(0),
            "KyotoLaunchPad: Merkle Root already exists"
        );
        _idoMerkleRoots[idoID] = merkleRoot;
        emit SetMerkleRoot(idoID, merkleRoot);
    }

    /**
     * @notice This method is used to distribute tokens to investors once the project is closed
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO
     */
    function distributeTokens(string calldata idoID) external {
        _checkForOnlyOwner();
        require(
            _idos[idoID].tokenAddress != address(0),
            "KyotoLaunchpad: IDO doesn't exist"
        );
        IDO memory ido = _idos[idoID];
        IDOInvestment memory idoInvestment = _idoInvestments[idoID];
        uint tokenPrice = _idos[idoID].tokenPrice;
        uint totalTokensToDistribute = ido.tokensForDistribution;
        require(
            idoInvestment.investors.length != 0,
            "KyotoLaunchPad: No investments found"
        );

        for (
            uint investorIndex = 0;
            investorIndex < idoInvestment.investors.length;
            investorIndex++
        ) {
            uint tokensToTransfer = (
                _idoInvestorInvestments[idoID][
                    idoInvestment.investors[investorIndex]
                ]
            ) / tokenPrice;

            tokensToTransfer *= 10**IERC20Metadata(ido.tokenAddress).decimals();

            totalTokensToDistribute -= tokensToTransfer;

            require(
                IERC20(ido.tokenAddress).transfer(
                    idoInvestment.investors[investorIndex],
                    tokensToTransfer
                ),
                "KyotoLaunchPad: Failed to transfer IDO tokens to Investor"
            );
        }

        if (totalTokensToDistribute > 0) {
            require(
                IERC20(ido.tokenAddress).transfer(
                    ido.idoOwner,
                    totalTokensToDistribute
                ),
                "KyotoLaunchPad: Failed to transfer IDO tokens to Owner"
            );
        }

        _idos[idoID].isRewarded = true;

        emit IDORewarded(idoID, ido.tokenAddress, true);
    }

    /* Admin Methods End */

    /* Potential Owner Methods Start */

    /**
     * @notice This method is used to accept the nomination of a new contract owner
     * @dev This method is called by the nominated contract owner
     */
    function acceptOwnership() external {
        require(
            _potentialOwner == msg.sender,
            "KyotoLaunchPad: Only the potential owner can accept ownership!"
        );
        _owner = _potentialOwner;
        _potentialOwner = address(0);
        emit OwnerChanged(_owner);
    }

    /* Potential Owner Methods End */

    /* User Methods Start */

    /**
     * @notice This method is used to invest in an IDO as a whitelisted user
     * @dev User must send _amount in order to invest
     * @dev User must be whitelisted to invest -- It'll be verified by the MerkleRoot
     * @param idoID ID of the IDO
     * @param merkleProof Merkle Proof of the user for that IDO
     */
    function investInWhitelistPhase(
        string calldata idoID,
        bytes32[] calldata merkleProof,
        uint256 _amount
    ) external payable {
        //_checkForIDOExist(idoID);
        require(
            _idos[idoID].tokenAddress != address(0),
            "KyotoLaunchpad: IDO doesn't exist"
        );
        require(
            _amount >= _idos[idoID].minimumInvestment,
            "KyotoLaunchpad: Investment amount is less than minimum"
        );
        require(
            _amount > 0,
            "KyotoLaunchPad: Investment amount should be greater than 0"
        );
        require(
            _idos[idoID].winnersOutTimestamp <= block.timestamp,
            "KyotoLaunchPad: Whitelist phase has not started"
        );
        require(
            _idos[idoID].idoCloseTimestamp > block.timestamp,
            "KyotoLaunchPad: Whitelist phase has ended"
        );
        require(
            _isWhitelisted(_idoMerkleRoots[idoID], merkleProof),
            "KyotoLaunchPad: User is not whitelisted"
        );
        _invest(idoID,_amount);
    }

    /* User Methods End */

    /* Private Helper Methods Start */

    /**
     * @dev This helper method is used to validate the IDO's data
     * @param ido IDO to be validated
     */
    function _validateIDOData(IDO calldata ido) private view {
        require(
            ido.tokenAddress != address(0),
            "KyotoLaunchPad: Token address cannot be 0"
        );
        require(
            IERC20(ido.tokenAddress).totalSupply() >= ido.tokensForDistribution,
            "KyotoLaunchPad: Token supply is less than the tokens to be distributed"
        );
        require(
            ido.idoOwner != address(0),
            "KyotoLaunchPad: IDO owner cannot be 0"
        );
        require(ido.tokenPrice != 0, "KyotoLaunchPad: Token price cannot be 0");
        require(
            ido.tokensForDistribution != 0,
            "KyotoLaunchPad: Tokens for distribution cannot be 0"
        );
        require(
            ido.whitelistOpenTimestamp != 0,
            "KyotoLaunchPad: Whitelist open timestamp cannot be 0"
        );
        require(
            ido.whitelistOpenTimestamp >= block.timestamp,
            "KyotoLaunchPad: Whitelist open timestamp cannot be in the past"
        );
        require(
            ido.whitelistOpenTimestamp < ido.winnersOutTimestamp,
            "KyotoLaunchPad: Whitelist open timestamp cannot be greater than winners out timestamp"
        );
        require(
            ido.winnersOutTimestamp <= ido.publicInvestmentStartTimestamp,
            "KyotoLaunchPad: Winners out timestamp cannot be greater than public investment start timestamp"
        );
        require(
            ido.publicInvestmentStartTimestamp < ido.idoCloseTimestamp,
            "KyotoLaunchPad: Public investment start timestamp cannot be greater than IDO close timestamp"
        );
        require(
            ido.publicSlots > 0,
            "KyotoLaunchPad: Number of slots cannot be zero"
        );
        // require(
        //     ido.publicMaxAllocation /
        //         ido.tokenPrice <=
        //         ido.tokensForDistribution,
        //     "KyotoLaunchPad: Tokens for distribution doesn't suffice"
        // );
        require(ido.isRewarded == false, "KyotoLaunchPad: IDO cannot be rewarded");
    }

    /**
     * @dev This helper method is used to validate the user whether the address is a whitelisted address or not
     * @param merkleRoot Merkle Root of the IDO
     * @param merkleProof Merkle Proof of the user for that IDO
     */
    function _isWhitelisted(bytes32 merkleRoot, bytes32[] calldata merkleProof)
        private
        view
        returns (bool)
    {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(merkleProof, merkleRoot, leaf);
    }

    /**
     * @dev This helper method is used to Invest in the IDO
     * @param idoID ID of the IDO to invest in
     */
    function _invest(string calldata idoID, uint256 _amount) private {
        require(
            _amount >= _idos[idoID].tokenPrice,
            "KyotoLaunchPad: Cannont invest less than the token price"
        );

         IDOInvestment memory idoInvestment = _idoInvestments[idoID];

        if(_idoInvestorInvestments[idoID][msg.sender] > 0){
            idoInvestment.publicTierTotalInvestment += _amount;
            idoInvestment.totalInvestment += _amount;
            _idoInvestments[idoID] = idoInvestment;
            _idoInvestorInvestments[idoID][msg.sender] += _amount;
        }
        else{  
                address[] memory idoInvestors = new address[](
                    idoInvestment.investors.length + 1
                );

                for (
                    uint index = 0;
                    index < idoInvestment.investors.length;
                    index++
                ) {
                    idoInvestors[index] = idoInvestment.investors[index];
                }

                idoInvestors[idoInvestment.investors.length] = msg.sender;

                idoInvestment.investors = idoInvestors;

                require(
                    _idos[idoID].publicSlots > idoInvestment.publicInvestors,
                    "KyotoLaunchPad: Public slots are full"
                );
                idoInvestment.publicInvestors++;

        
            idoInvestment.publicTierTotalInvestment += _amount;

            idoInvestment.totalInvestment += _amount;

            _idoInvestments[idoID] = idoInvestment;

            _idoInvestorInvestments[idoID][msg.sender] += _amount;
        }    

        emit Invest(idoID, msg.sender, _amount);
    }

    /**
     * @dev This helper method is used to Validate that the IDO with given ID is not already rewarded
     * @param idoID ID of the IDO to check
     */
    function _checkThatIDOIndNotRewarded(string calldata idoID) private view {
        require(
            _idos[idoID].isRewarded == false,
            "KyotoLaunchPad: IDO has already been rewarded"
        );
    }

    /**
     * @dev This helper method is used to Validate that the IDO with given ID exist
     * @param idoID ID of the IDO to check
     */
    function _checkForIDOExist(string calldata idoID) private view {
        require(
            _idos[idoID].tokenAddress != address(0),
            "KyotoLaunchPad: IDO does not exist"
        );
    }

    /**
     * @dev This helper method is used to Validate that the caller is contract owner
     */
    function _checkForOnlyOwner() private view {
        require(_owner == msg.sender, "KyotoLaunchPad: Caller is not the owner");
    }

    /* Private Helper Methods End */
}
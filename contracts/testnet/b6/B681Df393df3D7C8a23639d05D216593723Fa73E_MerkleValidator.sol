pragma solidity 0.8.12;

//import "./interfaces/OrderItem.sol";


interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
}

interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes calldata data) external;
}

/// @title MerkleValidator enables matching trait-based and collection-based orders for ERC721 and ERC1155 tokens.
/// @author 0age
/// @dev This contract is intended to be called during atomicMatch_ via DELEGATECALL.
contract MerkleValidator {

    struct Item{

        address from;

        address to;

        address tokenAddress;

        uint256 tokenId;

        uint price;

        bytes32[]  proof;

    }


    /// @dev InvalidProof is thrown on invalid proofs.
    error InvalidProof();

    /// @dev UnnecessaryProof is thrown in cases where a proof is supplied without a valid root to match against (root = 0)
    error UnnecessaryProof();


    /// @dev Match an ERC721 order, ensuring that the supplied proof demonstrates inclusion of the tokenId in the associated merkle root.
    /// @param from The account to transfer the ERC721 token from — this token must first be approved on the seller's AuthenticatedProxy contract.
    /// @param to The account to transfer the ERC721 token to.
    /// @param token The ERC721 token to transfer.
    /// @param tokenId The ERC721 tokenId to transfer.
    /// @param root A merkle root derived from each valid tokenId — set to 0 to indicate a collection-level or tokenId-specific order.
    /// @param proof A proof that the supplied tokenId is contained within the associated merkle root. Must be length 0 if root is not set.
    /// @return A boolean indicating a successful match and transfer.
    function matchERC721UsingCriteria(
    address from,
    address to,
    IERC721 token,
    uint256 tokenId,
    bytes32 root,
    bytes32[] calldata proof
    ) public returns (bool) {
    // Proof verification is performed when there's a non-zero root.
        if (root != bytes32(0)) {
            _verifyProof(tokenId, root, proof);
        } else if (proof.length != 0) {
            // A root of zero should never have a proof.
            revert UnnecessaryProof();
        }

        // Transfer the token.
        token.transferFrom(from, to, tokenId);

        return true;
    }

    function toStringNOPre(bytes memory data) public pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(data.length * 2);

        for (uint i = 0; i < data.length; i++) {
            str[i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[1+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function toStringNoPre(address account) public pure returns(string memory) {
        return toStringNOPre(abi.encodePacked(account));
    }


    function append(string memory _a, string memory _b) internal pure returns (string memory) {
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory bab = new bytes(_ba.length + _bb.length);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
    for (uint i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
    return string(bab);
    }


    function genLeaf(address tokenAddress,uint256 tokenId,uint price) public view returns  (bytes32){

    bytes32  leaf = keccak256(abi.encode(tokenAddress,tokenId,price));
    return leaf;
    }



    function batch(Item[] calldata orderItems, bytes32 root) external returns (bool) {

        for(uint i=0;i<orderItems.length;i++){
            Item memory item = orderItems[i];

            //matchERC721UsingCriteria(item.from,item.to,IERC721(item.tokenAddress),item.tokenId,item.root,item.proof);
            if (root != bytes32(0)) {
                //string using encodePacked
                string memory xx = toStringNOPre(abi.encodePacked(item.tokenAddress, item.tokenId,item.price));

                bytes32  leaf = keccak256(abi.encode(item.tokenAddress, item.tokenId,item.price));
                emit ResultHash(leaf,xx);
                //bytes memory leaf = abi.encodePacked(abcStr);
                if(verify(leaf, root, item.proof)){
                    emit ResultHash(leaf,xx);
                    // Transfer the token.
                    IERC721(item.tokenAddress).transferFrom(item.from,item.to, item.tokenId);
                }
            }

        }
    }


    function batchMatchERC721UsingCriteria(
        Item[] calldata orderItems, bytes32 root,bytes32[] calldata proof
    ) external returns (bool) {

        for(uint i=0;i<orderItems.length;i++){
        Item memory item = orderItems[i];

        //matchERC721UsingCriteria(item.from,item.to,IERC721(item.tokenAddress),item.tokenId,item.root,item.proof);
        if (root != bytes32(0)) {


            string memory xx = toStringNOPre(abi.encodePacked(item.tokenAddress, item.tokenId,item.price));

            bytes32  leaf = keccak256(abi.encode(item.tokenAddress, item.tokenId,item.price));
            emit ResultHash(leaf,xx);
            //bytes memory leaf = abi.encodePacked(abcStr);
            if(verify(leaf, root, proof)){
                // Transfer the token.
                IERC721(item.tokenAddress).transferFrom(item.from,item.to, item.tokenId);
            }
        }



        }
    }

    function stringToBytes32(string memory source)  internal returns(bytes32 result){
        assembly{
        result := mload(add(source,32))
        }
    }


    event ResultHash(bytes32  leaf,string abcStr);

    function verify(
    bytes32 leaf,
    bytes32 root,
    bytes32[] memory proof
    )
    public
    pure
    returns (bool)
    {
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



    /// @dev Match an ERC721 order using `safeTransferFrom`, ensuring that the supplied proof demonstrates inclusion of the tokenId in the associated merkle root.
    /// @param from The account to transfer the ERC721 token from — this token must first be approved on the seller's AuthenticatedProxy contract.
    /// @param to The account to transfer the ERC721 token to.
    /// @param token The ERC721 token to transfer.
    /// @param tokenId The ERC721 tokenId to transfer.
    /// @param root A merkle root derived from each valid tokenId — set to 0 to indicate a collection-level or tokenId-specific order.
    /// @param proof A proof that the supplied tokenId is contained within the associated merkle root. Must be length 0 if root is not set.
    /// @return A boolean indicating a successful match and transfer.
    function matchERC721WithSafeTransferUsingCriteria(
    address from,
    address to,
    IERC721 token,
    uint256 tokenId,
    bytes32 root,
    bytes32[] calldata proof
    ) public returns (bool) {
        // Proof verification is performed when there's a non-zero root.
        if (root != bytes32(0)) {
            _verifyProof(tokenId, root, proof);
        } else if (proof.length != 0) {
            // A root of zero should never have a proof.
            revert UnnecessaryProof();
        }

        // Transfer the token.
        token.safeTransferFrom(from, to, tokenId);

        return true;
    }

    /// @dev Match an ERC1155 order, ensuring that the supplied proof demonstrates inclusion of the tokenId in the associated merkle root.
    /// @param from The account to transfer the ERC1155 token from — this token must first be approved on the seller's AuthenticatedProxy contract.
    /// @param to The account to transfer the ERC1155 token to.
    /// @param token The ERC1155 token to transfer.
    /// @param tokenId The ERC1155 tokenId to transfer.
    /// @param amount The amount of ERC1155 tokens with the given tokenId to transfer.
    /// @param root A merkle root derived from each valid tokenId — set to 0 to indicate a collection-level or tokenId-specific order.
    /// @param proof A proof that the supplied tokenId is contained within the associated merkle root. Must be length 0 if root is not set.
    /// @return A boolean indicating a successful match and transfer.
    function matchERC1155UsingCriteria(
    address from,
    address to,
    IERC1155 token,
    uint256 tokenId,
    uint256 amount,
    bytes32 root,
    bytes32[] calldata proof
    ) external returns (bool) {
        // Proof verification is performed when there's a non-zero root.
        if (root != bytes32(0)) {
            _verifyProof(tokenId, root, proof);
        } else if (proof.length != 0) {
            // A root of zero should never have a proof.
            revert UnnecessaryProof();
        }

        // Transfer the token.
        token.safeTransferFrom(from, to, tokenId, amount, "");

        return true;
    }

    /// @dev Ensure that a given tokenId is contained within a supplied merkle root using a supplied proof.
    /// @param leaf The tokenId.
    /// @param root A merkle root derived from each valid tokenId.
    /// @param proof A proof that the supplied tokenId is contained within the associated merkle root.
    function _verifyProof(
    uint256 leaf,
    bytes32 root,
    bytes32[] memory proof
    ) private pure {
        bytes32 computedHash = bytes32(leaf);

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }

        if (computedHash != root) {
            revert InvalidProof();
        }
    }

    /// @dev Efficiently hash two bytes32 elements using memory scratch space.
    /// @param a The first element included in the hash.
    /// @param b The second element included in the hash.
    /// @return value The resultant hash of the two bytes32 elements.
    function _efficientHash(
    bytes32 a,
    bytes32 b
    ) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }

}
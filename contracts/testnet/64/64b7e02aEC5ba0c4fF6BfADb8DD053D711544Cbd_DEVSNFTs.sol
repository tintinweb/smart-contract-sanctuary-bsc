// SPDX-License-Identifier: UNLICENSED

import "./RewardingToken.sol";
pragma solidity ^0.8.3;

interface ERC721TokenReceiver {
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) external returns (bytes4);
}

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
    function processProof(bytes32[] memory proof, bytes32 leaf)
        internal
        pure
        returns (bytes32)
    {
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
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf)
        internal
        pure
        returns (bytes32)
    {
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
        require(
            leavesLen + proof.length - 1 == totalHashes,
            "MerkleProof: invalid multiproof"
        );

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
            bytes32 a = leafPos < leavesLen
                ? leaves[leafPos++]
                : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++]
                : proof[proofPos++];
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
        require(
            leavesLen + proof.length - 1 == totalHashes,
            "MerkleProof: invalid multiproof"
        );

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
            bytes32 a = leafPos < leavesLen
                ? leaves[leafPos++]
                : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++]
                : proof[proofPos++];
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

    function _efficientHash(bytes32 a, bytes32 b)
        private
        pure
        returns (bytes32 value)
    {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

contract ERC_721_token {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    string private Name;
    string private Symbol;
    uint256 private TotalSupply;
    string public baseURI;
    string public baseExtension;

    // TokenID -> Owner
    mapping(uint256 => address) private _ownerOf;
    // Address Has No of Tokens
    mapping(address => uint256) private _balanceOf;
    // TokenID -> Approved Address
    mapping(uint256 => address) private _approvals;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _isApprovedForAll;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) {
        Name = _name;
        Symbol = _symbol;
        TotalSupply = _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256 balance) {
        require(owner != address(0), "Address is 0");
        return _balanceOf[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address owner) {
        require(_ownerOf[tokenId] != address(0), "Token Doesn;t Exits");
        return _ownerOf[tokenId];
    }

    function name() public view returns (string memory) {
        return Name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view returns (string memory) {
        return Symbol;
    }

    function totalSupply() public view returns (uint256) {
        return TotalSupply;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        _requireMinted(tokenId);
        // string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0 // ? string(abi.encodePacked(baseURI, tokenId.toString()))
                ? string(abi.encodePacked(baseURI, tokenId))
                : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _URI) internal {
        baseURI = _URI;
    }

    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    function approve(address to, uint256 tokenId) public {
        address owner = this.ownerOf(tokenId);
        require(to != address(0), "Address is O");
        require(to != owner, "ERC721: approval to current owner");
        require(
            owner == msg.sender || isApprovedForAll(owner, msg.sender),
            "You are not the Owner of this TokenID"
        );
        require(to != msg.sender, "You are already owner of this tokenID ");

        _approvals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

    function getApproved(uint256 tokenId)
        public
        view
        returns (address operator)
    {
        require(_ownerOf[tokenId] != address(0), "Token Doesn't Exist");
        return _approvals[tokenId];
    }

    function setApprovalForAll(address operator, bool _approved) public {
        require(
            operator != address(0) && msg.sender != operator,
            "Address is O"
        );
        // require(balanceOf[msg.sender]>0,"You have No tokens");
        // require(owner != operator, "ERC721: approve to caller");

        _isApprovedForAll[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool)
    {
        require(operator != address(0), "Address is O");
        require(owner != operator, "Already operator of this Token");
        return _isApprovedForAll[owner][operator];
    }

    function _isApprovedOrOwner(
        // address owner,
        address spender,
        uint256 id
    ) internal view returns (bool) {
        address owner = ownerOf(id);
        return (spender == owner ||
            _isApprovedForAll[owner][spender] ||
            spender == _approvals[id]);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(from == _ownerOf[tokenId], "from != owner");
        require(to != address(0), "transfer to zero address");

        require(_isApprovedOrOwner(msg.sender, tokenId), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[tokenId] = to;

        delete _approvals[tokenId];

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        transferFrom(from, to, tokenId);
        uint32 size;
        assembly {
            size := extcodesize(to)
        }
        if (size > 0) {
            ERC721TokenReceiver receiver = ERC721TokenReceiver(to);
            require(
                receiver.onERC721Received(msg.sender, from, tokenId, "") ==
                    bytes4(
                        keccak256(
                            "onERC721Received(address,address,uint256,bytes)"
                        )
                    ),
                "ERC721: transfer to non ERC721Receiver implementer"
            );
        }
    }

    // function _mint(tokenID);
    // function _safeMint(tokenID);

    /**
    checks if a token already exist
    @param tokenId - token id
    */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return (_ownerOf[tokenId] != address(0));
    }

    /**
    Mint a token with id `tokenId`
    @param tokenId - token id
    */
    function mint(uint256 tokenId) public returns (bool) {
        // require(!_exists(tokenId), "tokenId already exist");
        if (_exists(tokenId)) return false;

        _safeMint(msg.sender, tokenId, "");
    }

    /**
  Mint safely as this function checks whether the receiver has implemented onERC721Received if its a contract
  @param to - to address
  @param tokenId - token id
  @param data - data
   */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "receiver has not implemented ERC721Receiver"
        );
    }

    /**
  Internal function to mint a token `tokenId` to `to`
  @param to - to address
  @param tokenId - token id
   */
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "transfering to zero addres");
        _balanceOf[to] += 1;
        _ownerOf[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (isContract(to)) {
            try
                ERC721TokenReceiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == ERC721TokenReceiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("receiver has not implemented ERC721Receiver");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balanceOf[owner] -= 1;
        delete _ownerOf[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _approvals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

contract DEVSNFTs is ERC_721_token {
    // Calculated from `merkle_tree.js`
    bytes32 public merkleRoot;

    mapping(address => bool) public whitelistClaimed;

    address owner;
    enum State {
        Paused,
        PreSale,
        PublicSale
    }
    State public mintingCurrentState;
    RewardToken RewardingTokenAddr;
    uint256 noOfCurrentlyMinted = 0;

    struct User {
        bool silver;
        bool gold;
        bool platinum;
        bool Diamond;
    }
    mapping(address => User) userInfo;

    constructor(RewardToken _RewardingTokenAddr)
        ERC_721_token("DEVSNFTs", "Devs", 200)
    {
        require(
            address(_RewardingTokenAddr) != address(0),
            "Token address should not be equal to Zero"
        );
        owner = msg.sender;
        mintingCurrentState = State.Paused;
        RewardingTokenAddr = _RewardingTokenAddr;
    }

    function randomNumGen() public view returns (uint256) {
        uint256 randomHash = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    block.number,
                    msg.sender
                )
            )
        );
        return randomHash % 181;
    }

    function randomNumGenDaimond() public view returns (uint256) {
        uint256 randomHash = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    block.number,
                    msg.sender
                )
            )
        );
        return (randomHash % 21) + 180;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not Admin");
        _;
    }

    /*
    FLOW :
    Function to allow pausing of Start of Presale;
    Starting State is Paused for the minting
    Then Owner Starts PreSale and EndsPreSale
    Ending Presale Starts Public Sale
     */
    function startPreSale() public onlyOwner {
        require(mintingCurrentState == State.Paused, "PreSale is Already Done");
        mintingCurrentState = State.PreSale;
    }

    // Ends PreSale and Starts Current Sale;
    function endPreSale() public onlyOwner {
        require(
            mintingCurrentState == State.PreSale,
            "PreSale has not Started or is Already Done"
        );
        mintingCurrentState = State.PublicSale;
    }

    function getCurrentMiningState() public view returns (State currentState) {
        return mintingCurrentState;
    }

    function whitelistMint(bytes32[] calldata _merkleProof) public {
        require(!whitelistClaimed[msg.sender], "Address already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, leaf),
            "Invalid Merkle Proof."
        );
        whitelistClaimed[msg.sender] = true;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function mintDEV() public returns (uint256 TokenIDminted) {
        require(balanceOf(msg.sender) < 5, "You have already minted 4 NFTS!");
        require(mintingCurrentState != State.Paused, "PreSale Hasn't Started");
        require(noOfCurrentlyMinted < 200, "All the Tokens have been minted");
        if (mintingCurrentState == State.PreSale) {
            require(
                whitelistClaimed[msg.sender] == true,
                "Claim your Whitelist claim pass First and then Mint"
            );
            // Require Staking Tokens 50
            require(
                RewardingTokenAddr.balanceOf(msg.sender) >= 50,
                "You require 50 staking tokens to Participate in PRE SALE"
            );
            RewardingTokenAddr.transferFrom(msg.sender, address(this), 50);
        } else {
            // Require Staking Tokens 100
            require(
                RewardingTokenAddr.balanceOf(msg.sender) >= 100,
                "You require 100 staking tokens to Participate in PUBLIC SALE"
            );
            RewardingTokenAddr.transferFrom(msg.sender, address(this), 100);
        }
        uint256 idtoMint = randomNumGen();
        // if TokenId Exist then Will Geneate New Id and Then Mint
        while (mint(idtoMint) != false) {
            idtoMint = randomNumGen();
        }
        if (idtoMint <= 60) {
            userInfo[msg.sender].silver = true;
        } else if (idtoMint <= 120) {
            userInfo[msg.sender].gold = true;
        } else {
            userInfo[msg.sender].platinum = true;
        }
        noOfCurrentlyMinted += 1;
        return idtoMint;
    }

    function mint2nftDEV() public returns (uint256 TokenID1, uint256 TokenID2) {
        require(
            (balanceOf(msg.sender)) < 3,
            "You have already more than 2 NFTS, Cannot mint more than 4 NFTS!"
        );

        require(noOfCurrentlyMinted < 199, "All the Tokens have been minted");
        if (mintingCurrentState == State.PreSale) {
            require(
                whitelistClaimed[msg.sender] == true,
                "Claim your Whitelist claim pass First and then Mint"
            );
            // Require Staking Tokens 50
            require(
                RewardingTokenAddr.balanceOf(msg.sender) >= 100,
                "You require 100 staking tokens to Participate in PRE SALE and mint 2 NFTS"
            );
            RewardingTokenAddr.transferFrom(msg.sender, address(this), 100);
        } else {
            // Require Staking Tokens 100
            require(
                RewardingTokenAddr.balanceOf(msg.sender) >= 200,
                "You require 200 staking tokens to Participate in PUBLIC SALE & mint 2 NFTS"
            );
            RewardingTokenAddr.transferFrom(msg.sender, address(this), 200);
        }

        uint256 idtoMint = randomNumGen();
        // if TokenId Exist then Will Geneate New Id and Then Mint
        while (mint(idtoMint) != false) {
            idtoMint = randomNumGen();
        }
        if (idtoMint <= 60) {
            userInfo[msg.sender].silver = true;
        } else if (idtoMint <= 120) {
            userInfo[msg.sender].gold = true;
        } else {
            userInfo[msg.sender].platinum = true;
        }
        noOfCurrentlyMinted += 1;
        TokenID1 = idtoMint;

        // Minting the second NFT
        idtoMint = randomNumGen();
        // if TokenId Exist then Will Geneate New Id and Then Mint
        while (mint(idtoMint) != false) {
            idtoMint = randomNumGen();
        }
        if (idtoMint <= 60) {
            userInfo[msg.sender].silver = true;
        } else if (idtoMint <= 120) {
            userInfo[msg.sender].gold = true;
        } else {
            userInfo[msg.sender].platinum = true;
        }
        noOfCurrentlyMinted += 1;

        TokenID2 = idtoMint;

        // return true;
    }

    function mintDiamondNFT() public returns (uint256) {
        require(balanceOf(msg.sender) < 5, "You have already minted 4 NFTS!");
        require(mintingCurrentState != State.Paused, "PreSale Hasn't Started");
        require(
            userInfo[msg.sender].Diamond == false,
            "You have already minted your DiamondNFT"
        );
        User memory tempInfo = userInfo[msg.sender];
        require(
            tempInfo.gold == true &&
                tempInfo.silver == true &&
                tempInfo.platinum == true,
            "you dont have silver,gold and platinum minted!"
        );

        require(noOfCurrentlyMinted < 199, "All the Tokens have been minted");
        if (mintingCurrentState == State.PreSale) {
            require(
                whitelistClaimed[msg.sender] == true,
                "Claim your Whitelist claim pass First and then Mint"
            );
            // Require Staking Tokens 50
            require(
                RewardingTokenAddr.balanceOf(msg.sender) >= 50,
                "You require 50 staking tokens to Participate in PRE SALE "
            );
            RewardingTokenAddr.transferFrom(msg.sender, address(this), 50);
        } else {
            // Require Staking Tokens 100
            require(
                RewardingTokenAddr.balanceOf(msg.sender) >= 100,
                "You require 100 staking tokens to Participate in PUBLIC SALE "
            );
            RewardingTokenAddr.transferFrom(msg.sender, address(this), 100);
        }
        uint256 idtoMint = randomNumGenDaimond();
        // if TokenId Exist then Will Geneate New Id and Then Mint
        while (mint(idtoMint) != false) {
            idtoMint = randomNumGenDaimond();
        }
        userInfo[msg.sender].Diamond = true;
        noOfCurrentlyMinted += 1;
        return idtoMint;
    }
}
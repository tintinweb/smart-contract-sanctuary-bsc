pragma solidity 0.5.9;

import "./Asset/ERC1155ERC721.sol";

contract Asset is ERC1155ERC721 {}

pragma solidity 0.5.9;

import "../contracts_common/Interfaces/ERC1155.sol";
import "../contracts_common/Interfaces/ERC1155TokenReceiver.sol";

import "../contracts_common/Libraries/AddressUtils.sol";
import "../contracts_common/Libraries/ObjectLib32.sol";

import "../contracts_common/Interfaces/ERC721.sol";
import "../contracts_common/Interfaces/ERC721TokenReceiver.sol";

import "../contracts_common/BaseWithStorage/SuperOperators.sol";

contract ERC1155ERC721 is SuperOperators, ERC1155, ERC721 {
    using AddressUtils for address;
    using ObjectLib32 for ObjectLib32.Operations;
    using ObjectLib32 for uint256;

    bytes4 private constant ERC1155_IS_RECEIVER = 0x4e2312e0;
    bytes4 private constant ERC1155_RECEIVED = 0xf23a6e61;
    bytes4 private constant ERC1155_BATCH_RECEIVED = 0xbc197c81;
    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

    uint256 private constant CREATOR_OFFSET_MULTIPLIER = uint256(2)**(256 - 160);
    uint256 private constant IS_NFT_OFFSET_MULTIPLIER = uint256(2)**(256 - 160 - 1);
    uint256 private constant PACK_ID_OFFSET_MULTIPLIER = uint256(2)**(256 - 160 - 1 - 32 - 40);
    uint256 private constant PACK_NUM_FT_TYPES_OFFSET_MULTIPLIER = uint256(2)**(256 - 160 - 1 - 32 - 40 - 12);
    uint256 private constant NFT_INDEX_OFFSET = 63;

    uint256 private constant IS_NFT = 0x0000000000000000000000000000000000000000800000000000000000000000;
    uint256 private constant NOT_IS_NFT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFFFFFFFFFFF;
    uint256 private constant NFT_INDEX = 0x00000000000000000000000000000000000000007FFFFFFF8000000000000000;
    uint256 private constant NOT_NFT_INDEX = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF800000007FFFFFFFFFFFFFFF;
    uint256 private constant URI_ID = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000007FFFFFFFFFFFF800;
    uint256 private constant PACK_ID = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000007FFFFFFFFF800000;
    uint256 private constant PACK_INDEX = 0x00000000000000000000000000000000000000000000000000000000000007FF;
    uint256 private constant PACK_NUM_FT_TYPES = 0x00000000000000000000000000000000000000000000000000000000007FF800;

    uint256 private constant MAX_SUPPLY = uint256(2)**32 - 1;
    uint256 private constant MAX_PACK_SIZE = uint256(2)**11;

    event CreatorshipTransfer(address indexed original, address indexed from, address indexed to);

    mapping(address => uint256) private _numNFTPerAddress; // erc721
    mapping(uint256 => uint256) private _owners; // erc721
    mapping(address => mapping(uint256 => uint256)) private _packedTokenBalance; // erc1155
    mapping(address => mapping(address => bool)) private _operatorsForAll; // erc721 and erc1155
    mapping(uint256 => address) private _erc721operators; // erc721
    mapping(uint256 => bytes32) private _metadataHash; // erc721 and erc1155
    mapping(uint256 => bytes) private _rarityPacks; // rarity configuration per packs (2 bits per Asset)
    mapping(uint256 => uint32) private _nextCollectionIndex; // extraction

    mapping(address => address) private _creatorship; // creatorship transfer

    mapping(address => bool) private _bouncers; // the contracts allowed to mint
    mapping(address => bool) private _metaTransactionContracts; // native meta-transaction support

    address private _bouncerAdmin;

    bool internal _init;

    function init(
        address metaTransactionContract,
        address admin,
        address bouncerAdmin
    ) public {
        require(!_init, "ALREADY_INITIALISED");
        _init = true;
        _metaTransactionContracts[metaTransactionContract] = true;
        _admin = admin;
        _bouncerAdmin = bouncerAdmin;
        emit MetaTransactionProcessor(metaTransactionContract, true);
    }

    event BouncerAdminChanged(address oldBouncerAdmin, address newBouncerAdmin);

    /// @notice Returns the current administrator in charge of minting rights.
    /// @return the current minting administrator in charge of minting rights.
    function getBouncerAdmin() external view returns (address) {
        return _bouncerAdmin;
    }

    /// @notice Change the minting administrator to be `newBouncerAdmin`.
    /// @param newBouncerAdmin address of the new minting administrator.
    function changeBouncerAdmin(address newBouncerAdmin) external {
        require(msg.sender == _bouncerAdmin, "only bouncerAdmin can change itself");
        emit BouncerAdminChanged(_bouncerAdmin, newBouncerAdmin);
        _bouncerAdmin = newBouncerAdmin;
    }

    event Bouncer(address bouncer, bool enabled);

    /// @notice Enable or disable the ability of `bouncer` to mint tokens (minting bouncer rights).
    /// @param bouncer address that will be given/removed minting bouncer rights.
    /// @param enabled set whether the address is enabled or disabled as a minting bouncer.
    function setBouncer(address bouncer, bool enabled) external {
        require(msg.sender == _bouncerAdmin, "only bouncerAdmin can setup bouncers");
        _bouncers[bouncer] = enabled;
        emit Bouncer(bouncer, enabled);
    }

    /// @notice check whether address `who` is given minting bouncer rights.
    /// @param who The address to query.
    /// @return whether the address has minting rights.
    function isBouncer(address who) external view returns (bool) {
        return _bouncers[who];
    }

    event MetaTransactionProcessor(address metaTransactionProcessor, bool enabled);

    /// @notice Enable or disable the ability of `metaTransactionProcessor` to perform meta-tx (metaTransactionProcessor rights).
    /// @param metaTransactionProcessor address that will be given/removed metaTransactionProcessor rights.
    /// @param enabled set whether the metaTransactionProcessor is enabled or disabled.
    function setMetaTransactionProcessor(address metaTransactionProcessor, bool enabled) external {
        require(msg.sender == _admin, "only admin can setup metaTransactionProcessors");
        _metaTransactionContracts[metaTransactionProcessor] = enabled;
        emit MetaTransactionProcessor(metaTransactionProcessor, enabled);
    }

    /// @notice check whether address `who` is given meta-transaction execution rights.
    /// @param who The address to query.
    /// @return whether the address has meta-transaction execution rights.
    function isMetaTransactionProcessor(address who) external view returns (bool) {
        return _metaTransactionContracts[who];
    }

    /// @notice Mint a token type for `creator` on slot `packId`.
    /// @param creator address of the creator of the token.
    /// @param packId unique packId for that token.
    /// @param hash hash of an IPFS cidv1 folder that contains the metadata of the token type in the file 0.json.
    /// @param supply number of tokens minted for that token type.
    /// @param rarity rarity power of the token.
    /// @param owner address that will receive the tokens.
    /// @param data extra data to accompany the minting call.
    /// @return the id of the newly minted token type.
    function mint(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint256 supply,
        uint8 rarity,
        address owner,
        bytes calldata data
    ) external returns (uint256 id) {
        require(hash != 0, "hash is zero");
        require(_bouncers[msg.sender], "only bouncer allowed to mint");
        require(owner != address(0), "destination is zero address");
        id = generateTokenId(creator, supply, packId, supply == 1 ? 0 : 1, 0);
        _mint(hash, supply, rarity, msg.sender, owner, id, data, false);
    }

    function generateTokenId(
        address creator,
        uint256 supply,
        uint40 packId,
        uint16 numFTs,
        uint16 packIndex
    ) internal pure returns (uint256) {
        require(supply > 0 && supply <= MAX_SUPPLY, "invalid supply");

        return
            uint256(creator) *
            CREATOR_OFFSET_MULTIPLIER + // CREATOR
            (supply == 1 ? uint256(1) * IS_NFT_OFFSET_MULTIPLIER : 0) + // minted as NFT (1) or FT (0) // IS_NFT
            uint256(packId) *
            PACK_ID_OFFSET_MULTIPLIER + // packId (unique pack) // PACk_ID
            numFTs *
            PACK_NUM_FT_TYPES_OFFSET_MULTIPLIER + // number of fungible token in the pack // PACK_NUM_FT_TYPES
            packIndex; // packIndex (position in the pack) // PACK_INDEX
    }

    function _mint(
        bytes32 hash,
        uint256 supply,
        uint8 rarity,
        address operator,
        address owner,
        uint256 id,
        bytes memory data,
        bool extraction
    ) internal {
        uint256 uriId = id & URI_ID;
        if (!extraction) {
            require(uint256(_metadataHash[uriId]) == 0, "id already used");
            _metadataHash[uriId] = hash;
            require(rarity < 4, "rarity >= 4");
            bytes memory pack = new bytes(1);
            pack[0] = bytes1(rarity * 64);
            _rarityPacks[uriId] = pack;
        }
        if (supply == 1) {
            // ERC721
            _numNFTPerAddress[owner]++;
            _owners[id] = uint256(owner);
            emit Transfer(address(0), owner, id);
        } else {
            (uint256 bin, uint256 index) = id.getTokenBinIndex();
            _packedTokenBalance[owner][bin] = _packedTokenBalance[owner][bin].updateTokenBalance(
                index,
                supply,
                ObjectLib32.Operations.REPLACE
            );
        }

        emit TransferSingle(operator, address(0), owner, id, supply);
        require(
            _checkERC1155AndCallSafeTransfer(operator, address(0), owner, id, supply, data, false, false),
            "transfer rejected"
        );
    }

    /// @notice Mint multiple token types for `creator` on slot `packId`.
    /// @param creator address of the creator of the tokens.
    /// @param packId unique packId for the tokens.
    /// @param hash hash of an IPFS cidv1 folder that contains the metadata of each token type in the files: 0.json, 1.json, 2.json, etc...
    /// @param supplies number of tokens minted for each token type.
    /// @param rarityPack rarity power of each token types packed into 2 bits each.
    /// @param owner address that will receive the tokens.
    /// @param data extra data to accompany the minting call.
    /// @return the ids of each newly minted token types.
    function mintMultiple(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint256[] calldata supplies,
        bytes calldata rarityPack,
        address owner,
        bytes calldata data
    ) external returns (uint256[] memory ids) {
        require(hash != 0, "hash is zero");
        require(_bouncers[msg.sender], "only bouncer allowed to mint");
        require(owner != address(0), "destination is zero address");
        uint16 numNFTs;
        (ids, numNFTs) = allocateIds(creator, supplies, rarityPack, packId, hash);
        _mintBatches(supplies, owner, ids, numNFTs);
        completeMultiMint(msg.sender, owner, ids, supplies, data);
    }

    function allocateIds(
        address creator,
        uint256[] memory supplies,
        bytes memory rarityPack,
        uint40 packId,
        bytes32 hash
    ) internal returns (uint256[] memory ids, uint16 numNFTs) {
        require(supplies.length > 0, "supplies.length == 0");
        require(supplies.length <= MAX_PACK_SIZE, "too big batch");
        (ids, numNFTs) = generateTokenIds(creator, supplies, packId);
        uint256 uriId = ids[0] & URI_ID;
        require(uint256(_metadataHash[uriId]) == 0, "id already used");
        _metadataHash[uriId] = hash;
        _rarityPacks[uriId] = rarityPack;
    }

    function generateTokenIds(
        address creator,
        uint256[] memory supplies,
        uint40 packId
    ) internal pure returns (uint256[] memory, uint16) {
        uint16 numTokenTypes = uint16(supplies.length);
        uint256[] memory ids = new uint256[](numTokenTypes);
        uint16 numNFTs = 0;
        for (uint16 i = 0; i < numTokenTypes; i++) {
            if (numNFTs == 0) {
                if (supplies[i] == 1) {
                    numNFTs = uint16(numTokenTypes - i);
                }
            } else {
                require(supplies[i] == 1, "NFTs need to be put at the end");
            }
        }
        uint16 numFTs = numTokenTypes - numNFTs;
        for (uint16 i = 0; i < numTokenTypes; i++) {
            ids[i] = generateTokenId(creator, supplies[i], packId, numFTs, i);
        }
        return (ids, numNFTs);
    }

    function completeMultiMint(
        address operator,
        address owner,
        uint256[] memory ids,
        uint256[] memory supplies,
        bytes memory data
    ) internal {
        emit TransferBatch(operator, address(0), owner, ids, supplies);
        require(
            _checkERC1155AndCallSafeBatchTransfer(operator, address(0), owner, ids, supplies, data),
            "transfer rejected"
        );
    }

    function _mintBatches(
        uint256[] memory supplies,
        address owner,
        uint256[] memory ids,
        uint16 numNFTs
    ) internal {
        uint16 offset = 0;
        while (offset < supplies.length - numNFTs) {
            _mintBatch(offset, supplies, owner, ids);
            offset += 8;
        }
        // deal with NFT last. they do not care of balance packing
        if (numNFTs > 0) {
            _mintNFTs(uint16(supplies.length - numNFTs), numNFTs, owner, ids);
        }
    }

    function _mintNFTs(
        uint16 offset,
        uint32 numNFTs,
        address owner,
        uint256[] memory ids
    ) internal {
        for (uint16 i = 0; i < numNFTs; i++) {
            uint256 id = ids[i + offset];
            _owners[id] = uint256(owner);
            emit Transfer(address(0), owner, id);
        }
        _numNFTPerAddress[owner] += numNFTs;
    }

    function _mintBatch(
        uint16 offset,
        uint256[] memory supplies,
        address owner,
        uint256[] memory ids
    ) internal {
        uint256 firstId = ids[offset];
        (uint256 bin, uint256 index) = firstId.getTokenBinIndex();
        uint256 balances = _packedTokenBalance[owner][bin];
        for (uint256 i = 0; i < 8 && offset + i < supplies.length; i++) {
            uint256 j = offset + i;
            if (supplies[j] > 1) {
                balances = balances.updateTokenBalance(index + i, supplies[j], ObjectLib32.Operations.REPLACE);
            } else {
                break;
            }
        }
        _packedTokenBalance[owner][bin] = balances;
    }

    function _transferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value
    ) internal returns (bool metaTx) {
        require(to != address(0), "destination is zero address");
        require(from != address(0), "from is zero address");
        metaTx = _metaTransactionContracts[msg.sender];
        bool authorized = from == msg.sender ||
            metaTx ||
            _superOperators[msg.sender] ||
            _operatorsForAll[from][msg.sender];

        if (id & IS_NFT > 0) {
            require(authorized || _erc721operators[id] == msg.sender, "Operator not approved");
            if (value > 0) {
                require(value == 1, "cannot transfer nft if amount not 1");
                _numNFTPerAddress[from]--;
                _numNFTPerAddress[to]++;
                _owners[id] = uint256(to);
                if (_erc721operators[id] != address(0)) {
                    // TODO operatorEnabled flag optimization (like in ERC721BaseToken)
                    _erc721operators[id] = address(0);
                }
                emit Transfer(from, to, id);
            }
        } else {
            require(authorized, "Operator not approved");
            if (value > 0) {
                // if different owners it will fails
                (uint256 bin, uint256 index) = id.getTokenBinIndex();
                _packedTokenBalance[from][bin] = _packedTokenBalance[from][bin].updateTokenBalance(
                    index,
                    value,
                    ObjectLib32.Operations.SUB
                );
                _packedTokenBalance[to][bin] = _packedTokenBalance[to][bin].updateTokenBalance(
                    index,
                    value,
                    ObjectLib32.Operations.ADD
                );
            }
        }

        emit TransferSingle(metaTx ? from : msg.sender, from, to, id, value);
    }

    /// @notice Transfers `value` tokens of type `id` from  `from` to `to`  (with safety call).
    /// @param from address from which tokens are transfered.
    /// @param to address to which the token will be transfered.
    /// @param id the token type transfered.
    /// @param value amount of token transfered.
    /// @param data aditional data accompanying the transfer.
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external {
        if (id & IS_NFT > 0) {
            require(_ownerOf(id) == from, "not owner");
        }
        bool metaTx = _transferFrom(from, to, id, value);
        require(
            _checkERC1155AndCallSafeTransfer(metaTx ? from : msg.sender, from, to, id, value, data, false, false),
            "erc1155 transfer rejected"
        );
    }

    /// @notice Transfers `values` tokens of type `ids` from  `from` to `to` (with safety call).
    /// @dev call data should be optimized to order ids so packedBalance can be used efficiently.
    /// @param from address from which tokens are transfered.
    /// @param to address to which the token will be transfered.
    /// @param ids ids of each token type transfered.
    /// @param values amount of each token type transfered.
    /// @param data aditional data accompanying the transfer.
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external {
        require(ids.length == values.length, "Inconsistent array length between args");
        require(to != address(0), "destination is zero address");
        require(from != address(0), "from is zero address");
        bool metaTx = _metaTransactionContracts[msg.sender];
        bool authorized = from == msg.sender ||
            metaTx ||
            _superOperators[msg.sender] ||
            _operatorsForAll[from][msg.sender]; // solium-disable-line max-len

        _batchTransferFrom(from, to, ids, values, authorized);
        emit TransferBatch(metaTx ? from : msg.sender, from, to, ids, values);
        require(
            _checkERC1155AndCallSafeBatchTransfer(metaTx ? from : msg.sender, from, to, ids, values, data),
            "erc1155 transfer rejected"
        );
    }

    function _batchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bool authorized
    ) internal {
        uint256 numItems = ids.length;
        uint256 bin;
        uint256 index;
        uint256 balFrom;
        uint256 balTo;

        uint256 lastBin;
        uint256 numNFTs = 0;
        for (uint256 i = 0; i < numItems; i++) {
            if (ids[i] & IS_NFT > 0) {
                require(authorized || _erc721operators[ids[i]] == msg.sender, "Operator not approved");
                if (values[i] > 0) {
                    require(values[i] == 1, "cannot transfer nft if amount not 1");
                    require(_ownerOf(ids[i]) == from, "not owner");
                    numNFTs++;
                    _owners[ids[i]] = uint256(to);
                    if (_erc721operators[ids[i]] != address(0)) {
                        // TODO operatorEnabled flag optimization (like in ERC721BaseToken)
                        _erc721operators[ids[i]] = address(0);
                    }
                    emit Transfer(from, to, ids[i]);
                }
            } else {
                require(authorized, "Operator not approved");
                if (from == to) {
                    _checkEnoughBalance(from, ids[i], values[i]);
                } else if (values[i] > 0) {
                    (bin, index) = ids[i].getTokenBinIndex();
                    if (lastBin == 0) {
                        lastBin = bin;
                        balFrom = ObjectLib32.updateTokenBalance(
                            _packedTokenBalance[from][bin],
                            index,
                            values[i],
                            ObjectLib32.Operations.SUB
                        );
                        balTo = ObjectLib32.updateTokenBalance(
                            _packedTokenBalance[to][bin],
                            index,
                            values[i],
                            ObjectLib32.Operations.ADD
                        );
                    } else {
                        if (bin != lastBin) {
                            _packedTokenBalance[from][lastBin] = balFrom;
                            _packedTokenBalance[to][lastBin] = balTo;
                            balFrom = _packedTokenBalance[from][bin];
                            balTo = _packedTokenBalance[to][bin];
                            lastBin = bin;
                        }

                        balFrom = balFrom.updateTokenBalance(index, values[i], ObjectLib32.Operations.SUB);
                        balTo = balTo.updateTokenBalance(index, values[i], ObjectLib32.Operations.ADD);
                    }
                }
            }
        }
        if (numNFTs > 0 && from != to) {
            _numNFTPerAddress[from] -= numNFTs;
            _numNFTPerAddress[to] += numNFTs;
        }

        if (bin != 0 && from != to) {
            _packedTokenBalance[from][bin] = balFrom;
            _packedTokenBalance[to][bin] = balTo;
        }
    }

    function _checkEnoughBalance(
        address from,
        uint256 id,
        uint256 value
    ) internal {
        (uint256 bin, uint256 index) = id.getTokenBinIndex();
        require(_packedTokenBalance[from][bin].getValueInBin(index) >= value, "can't substract more than there is");
    }

    /// @notice Get the balance of `owner` for the token type `id`.
    /// @param owner The address of the token holder.
    /// @param id the token type of which to get the balance of.
    /// @return the balance of `owner` for the token type `id`.
    function balanceOf(address owner, uint256 id) public view returns (uint256) {
        // do not check for existence, balance is zero if never minted
        // require(wasEverMinted(id), "token was never minted");
        if (id & IS_NFT > 0) {
            if (_ownerOf(id) == owner) {
                return 1;
            } else {
                return 0;
            }
        }
        (uint256 bin, uint256 index) = id.getTokenBinIndex();
        return _packedTokenBalance[owner][bin].getValueInBin(index);
    }

    /// @notice Get the balance of `owners` for each token type `ids`.
    /// @param owners the addresses of the token holders queried.
    /// @param ids ids of each token type to query.
    /// @return the balance of each `owners` for each token type `ids`.
    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory)
    {
        require(owners.length == ids.length, "Inconsistent array length between args");
        uint256[] memory balances = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            balances[i] = balanceOf(owners[i], ids[i]);
        }
        return balances;
    }

    /// @notice Get the creator of the token type `id`.
    /// @param id the id of the token to get the creator of.
    /// @return the creator of the token type `id`.
    function creatorOf(uint256 id) external view returns (address) {
        require(wasEverMinted(id), "token was never minted");
        address originalCreator = address(id / CREATOR_OFFSET_MULTIPLIER);
        address newCreator = _creatorship[originalCreator];
        if (newCreator != address(0)) {
            return newCreator;
        }
        return originalCreator;
    }

    /// @notice Transfers creatorship of `original` from `sender` to `to`.
    /// @param sender address of current registered creator.
    /// @param original address of the original creator whose creation are saved in the ids themselves.
    /// @param to address which will be given creatorship for all tokens originally minted by `original`.
    function transferCreatorship(
        address sender,
        address original,
        address to
    ) external {
        require(
            msg.sender == sender || _metaTransactionContracts[msg.sender] || _superOperators[msg.sender],
            "require meta approval"
        );
        require(sender != address(0), "sender is zero address");
        require(to != address(0), "destination is zero address");
        address current = _creatorship[original];
        if (current == address(0)) {
            current = original;
        }
        require(current != to, "current == to");
        require(current == sender, "current != sender");
        if (to == original) {
            _creatorship[original] = address(0);
        } else {
            _creatorship[original] = to;
        }
        emit CreatorshipTransfer(original, current, to);
    }

    /// @notice Enable or disable approval for `operator` to manage all `sender`'s tokens.
    /// @dev used for Meta Transaction (from metaTransactionContract).
    /// @param sender address which grant approval.
    /// @param operator address which will be granted rights to transfer all token owned by `sender`.
    /// @param approved whether to approve or revoke.
    function setApprovalForAllFor(
        address sender,
        address operator,
        bool approved
    ) external {
        require(
            msg.sender == sender || _metaTransactionContracts[msg.sender] || _superOperators[msg.sender],
            "require meta approval"
        );
        _setApprovalForAll(sender, operator, approved);
    }

    /// @notice Enable or disable approval for `operator` to manage all of the caller's tokens.
    /// @param operator address which will be granted rights to transfer all tokens of the caller.
    /// @param approved whether to approve or revoke
    function setApprovalForAll(address operator, bool approved) external {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function _setApprovalForAll(
        address sender,
        address operator,
        bool approved
    ) internal {
        require(sender != address(0), "sender is zero address");
        require(sender != operator, "sender = operator");
        require(operator != address(0), "operator is zero address");
        require(!_superOperators[operator], "super operator can't have their approvalForAll changed");
        _operatorsForAll[sender][operator] = approved;
        emit ApprovalForAll(sender, operator, approved);
    }

    /// @notice Queries the approval status of `operator` for owner `owner`.
    /// @param owner the owner of the tokens.
    /// @param operator address of authorized operator.
    /// @return true if the operator is approved, false if not.
    function isApprovedForAll(address owner, address operator) external view returns (bool isOperator) {
        require(owner != address(0), "owner is zero address");
        require(operator != address(0), "operator is zero address");
        return _operatorsForAll[owner][operator] || _superOperators[operator];
    }

    /// @notice Count all NFTs assigned to `owner`.
    /// @param owner address for whom to query the balance.
    /// @return the number of NFTs owned by `owner`, possibly zero.
    function balanceOf(address owner) external view returns (uint256 balance) {
        require(owner != address(0), "owner is zero address");
        return _numNFTPerAddress[owner];
    }

    /// @notice Find the owner of an NFT.
    /// @param id the identifier for an NFT.
    /// @return the address of the owner of the NFT.
    function ownerOf(uint256 id) external view returns (address owner) {
        owner = _ownerOf(id);
        require(owner != address(0), "NFT does not exist");
    }

    function _ownerOf(uint256 id) internal view returns (address) {
        return address(_owners[id]);
    }

    /// @notice Change or reaffirm the approved address for an NFT for `sender`.
    /// @dev used for Meta Transaction (from metaTransactionContract).
    /// @param sender the sender granting control.
    /// @param operator the address to approve as NFT controller.
    /// @param id the NFT to approve.
    function approveFor(
        address sender,
        address operator,
        uint256 id
    ) external {
        address owner = _ownerOf(id);
        require(sender != address(0), "sender is zero address");
        require(
            msg.sender == sender ||
                _metaTransactionContracts[msg.sender] ||
                _superOperators[msg.sender] ||
                _operatorsForAll[sender][msg.sender],
            "require operators"
        ); // solium-disable-line max-len
        require(owner == sender, "not owner");
        _erc721operators[id] = operator;
        emit Approval(owner, operator, id);
    }

    /// @notice Change or reaffirm the approved address for an NFT.
    /// @param operator the address to approve as NFT controller.
    /// @param id the id of the NFT to approve.
    function approve(address operator, uint256 id) external {
        address owner = _ownerOf(id);
        require(owner != address(0), "NFT does not exist");
        require(
            owner == msg.sender || _superOperators[msg.sender] || _operatorsForAll[owner][msg.sender],
            "not authorized"
        );
        _erc721operators[id] = operator;
        emit Approval(owner, operator, id);
    }

    /// @notice Get the approved address for a single NFT.
    /// @param id the NFT to find the approved address for.
    /// @return the approved address for this NFT, or the zero address if there is none.
    function getApproved(uint256 id) external view returns (address operator) {
        require(_ownerOf(id) != address(0), "NFT does not exist");
        return _erc721operators[id];
    }

    /// @notice Transfers ownership of an NFT.
    /// @param from the current owner of the NFT.
    /// @param to the new owner.
    /// @param id the NFT to transfer.
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) external {
        require(_ownerOf(id) == from, "not owner");
        bool metaTx = _transferFrom(from, to, id, 1);
        require(
            _checkERC1155AndCallSafeTransfer(metaTx ? from : msg.sender, from, to, id, 1, "", true, false),
            "erc1155 transfer rejected"
        );
    }

    /// @notice Transfers the ownership of an NFT from one address to another address.
    /// @param from the current owner of the NFT.
    /// @param to the new owner.
    /// @param id the NFT to transfer.
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) external {
        safeTransferFrom(from, to, id, "");
    }

    /// @notice Transfers the ownership of an NFT from one address to another address.
    /// @param from the current owner of the NFT.
    /// @param to the new owner.
    /// @param id the NFT to transfer.
    /// @param data additional data with no specified format, sent in call to `to`.
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public {
        require(_ownerOf(id) == from, "not owner");
        bool metaTx = _transferFrom(from, to, id, 1);
        require(
            _checkERC1155AndCallSafeTransfer(metaTx ? from : msg.sender, from, to, id, 1, data, true, true),
            "erc721/erc1155 transfer rejected"
        );
    }

    /// @notice A descriptive name for the collection of tokens in this contract.
    /// @return the name of the tokens.
    function name() external pure returns (string memory _name) {
        return "Wonderland's ASSETs";
    }

    /// @notice An abbreviated name for the collection of tokens in this contract.
    /// @return the symbol of the tokens.
    function symbol() external pure returns (string memory _symbol) {
        return "ASSET";
    }

    /// @notice Gives the rarity power of a particular token type.
    /// @param id the token type to get the rarity of.
    /// @return the rarity power(between 0 and 3).
    function rarity(uint256 id) public view returns (uint256) {
        require(wasEverMinted(id), "token was never minted");
        bytes storage rarityPack = _rarityPacks[id & URI_ID];
        uint256 packIndex = id & PACK_INDEX;
        if (packIndex / 4 >= rarityPack.length) {
            return 0;
        } else {
            uint8 pack = uint8(rarityPack[packIndex / 4]);
            uint8 i = (3 - uint8(packIndex % 4)) * 2;
            return (pack / (uint8(2)**i)) % 4;
        }
    }

    /// @notice Gives the collection a specific token belongs to.
    /// @param id the token to get the collection of.
    /// @return the collection the NFT is part of.
    function collectionOf(uint256 id) public view returns (uint256) {
        require(_ownerOf(id) != address(0), "NFT does not exist");
        uint256 collectionId = id & NOT_NFT_INDEX & NOT_IS_NFT;
        require(wasEverMinted(collectionId), "no collection ever minted for that token");
        return collectionId;
    }

    /// @notice Return wether the id is a collection
    /// @param id collectionId to check.
    /// @return whether the id is a collection.
    function isCollection(uint256 id) public view returns (bool) {
        uint256 collectionId = id & NOT_NFT_INDEX & NOT_IS_NFT;
        return wasEverMinted(collectionId);
    }

    /// @notice Gives the index at which an NFT was minted in a collection : first of a collection get the zero index.
    /// @param id the token to get the index of.
    /// @return the index/order at which the token `id` was minted in a collection.
    function collectionIndexOf(uint256 id) public view returns (uint256) {
        collectionOf(id); // this check if id and collection indeed was ever minted
        return uint32((id & NFT_INDEX) >> NFT_INDEX_OFFSET);
    }

    function toFullURI(bytes32 hash, uint256 id) internal pure returns (string memory) {
        return string(abi.encodePacked("ipfs://bafybei", hash2base32(hash), "/", uint2str(id & PACK_INDEX), ".json"));
    }

    function wasEverMinted(uint256 id) public view returns (bool) {
        if ((id & IS_NFT) > 0) {
            return _owners[id] != 0;
        } else {
            return
                ((id & PACK_INDEX) < ((id & PACK_NUM_FT_TYPES) / PACK_NUM_FT_TYPES_OFFSET_MULTIPLIER)) &&
                _metadataHash[id & URI_ID] != 0;
        }
    }

    /// @notice check whether a packId/numFT tupple has been used
    /// @param creator for which creator
    /// @param packId the packId to check
    /// @param numFTs number of Fungible Token in that pack (can reuse packId if different)
    /// @return whether the pack has already been used
    function isPackIdUsed(
        address creator,
        uint40 packId,
        uint16 numFTs
    ) external returns (bool) {
        uint256 uriId = uint256(creator) *
            CREATOR_OFFSET_MULTIPLIER + // CREATOR
            uint256(packId) *
            PACK_ID_OFFSET_MULTIPLIER + // packId (unique pack) // PACk_ID
            numFTs *
            PACK_NUM_FT_TYPES_OFFSET_MULTIPLIER; // number of fungible token in the pack // PACK_NUM_FT_TYPES
        return _metadataHash[uriId] != 0;
    }

    /// @notice A distinct Uniform Resource Identifier (URI) for a given token.
    /// @param id token to get the uri of.
    /// @return URI string
    function uri(uint256 id) public view returns (string memory) {
        require(wasEverMinted(id), "token was never minted"); // prevent returning invalid uri
        return toFullURI(_metadataHash[id & URI_ID], id);
    }

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @param id token to get the uri of.
    /// @return URI string
    function tokenURI(uint256 id) public view returns (string memory) {
        require(_ownerOf(id) != address(0), "NFT does not exist");
        return toFullURI(_metadataHash[id & URI_ID], id);
    }

    bytes32 private constant base32Alphabet = 0x6162636465666768696A6B6C6D6E6F707172737475767778797A323334353637;

    // solium-disable-next-line security/no-assign-params
    function hash2base32(bytes32 hash) private pure returns (string memory _uintAsString) {
        uint256 _i = uint256(hash);
        uint256 k = 52;
        bytes memory bstr = new bytes(k);
        bstr[--k] = base32Alphabet[uint8((_i % 8) << 2)]; // uint8 s = uint8((256 - skip) % 5);  // (_i % (2**s)) << (5-s)
        _i /= 8;
        while (k > 0) {
            bstr[--k] = base32Alphabet[_i % 32];
            _i /= 32;
        }
        return string(bstr);
    }

    // solium-disable-next-line security/no-assign-params
    function uint2str(uint256 _i) private pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }

        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }

        return string(bstr);
    }

    /// @notice Query if a contract implements interface `id`.
    /// @param id the interface identifier, as specified in ERC-165.
    /// @return `true` if the contract implements `id`.
    function supportsInterface(bytes4 id) external view returns (bool) {
        return
            id == 0x01ffc9a7 || //ERC165
            id == 0xd9b67a26 || // ERC1155
            id == 0x80ac58cd || // ERC721
            id == 0x5b5e139f || // ERC721 metadata
            id == 0x0e89341c; // ERC1155 metadata
    }

    bytes4 constant ERC165ID = 0x01ffc9a7;

    function checkIsERC1155Receiver(address _contract) internal view returns (bool) {
        bool success;
        bool result;
        bytes memory call_data = abi.encodeWithSelector(ERC165ID, ERC1155_IS_RECEIVER);
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let call_ptr := add(0x20, call_data)
            let call_size := mload(call_data)
            let output := mload(0x40) // Find empty storage location using "free memory pointer"
            mstore(output, 0x0)
            success := staticcall(10000, _contract, call_ptr, call_size, output, 0x20) // 32 bytes
            result := mload(output)
        }
        // (10000 / 63) "not enough for supportsInterface(...)" // consume all gas, so caller can potentially know that there was not enough gas
        assert(gasleft() > 158);
        return success && result;
    }

    function _checkERC1155AndCallSafeTransfer(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data,
        bool erc721,
        bool erc721Safe
    ) internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        if (erc721) {
            if (!checkIsERC1155Receiver(to)) {
                if (erc721Safe) {
                    return _checkERC721AndCallSafeTransfer(operator, from, to, id, data);
                } else {
                    return true;
                }
            }
        }
        return ERC1155TokenReceiver(to).onERC1155Received(operator, from, id, value, data) == ERC1155_RECEIVED;
    }

    function _checkERC1155AndCallSafeBatchTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        bytes4 retval = ERC1155TokenReceiver(to).onERC1155BatchReceived(operator, from, ids, values, data);
        return (retval == ERC1155_BATCH_RECEIVED);
    }

    function _checkERC721AndCallSafeTransfer(
        address operator,
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) internal returns (bool) {
        // following not required as this function is always called as part of ERC1155 checks that include such check already
        // if (!to.isContract()) {
        //     return true;
        // }
        return (ERC721TokenReceiver(to).onERC721Received(operator, from, id, data) == ERC721_RECEIVED);
    }

    event Extraction(uint256 indexed fromId, uint256 toId);
    event AssetUpdate(uint256 indexed fromId, uint256 toId);

    function _burnERC1155(
        address operator,
        address from,
        uint256 id,
        uint32 amount
    ) internal {
        (uint256 bin, uint256 index) = (id).getTokenBinIndex();
        _packedTokenBalance[from][bin] = _packedTokenBalance[from][bin].updateTokenBalance(
            index,
            amount,
            ObjectLib32.Operations.SUB
        );
        emit TransferSingle(operator, from, address(0), id, amount);
    }

    function _burnERC721(
        address operator,
        address from,
        uint256 id
    ) internal {
        require(from == _ownerOf(id), "not owner");
        _owners[id] = 2**160; // equivalent to zero address when casted but ensure we track minted status
        _numNFTPerAddress[from]--;
        emit Transfer(from, address(0), id);
        emit TransferSingle(operator, from, address(0), id, 1);
    }

    /// @notice Burns `amount` tokens of type `id`.
    /// @param id token type which will be burnt.
    /// @param amount amount of token to burn.
    function burn(uint256 id, uint256 amount) external {
        _burn(msg.sender, id, amount);
    }

    /// @notice Burns `amount` tokens of type `id` from `from`.
    /// @param from address whose token is to be burnt.
    /// @param id token type which will be burnt.
    /// @param amount amount of token to burn.
    function burnFrom(
        address from,
        uint256 id,
        uint256 amount
    ) external {
        require(from != address(0), "from is zero address");
        require(
            msg.sender == from ||
                _metaTransactionContracts[msg.sender] ||
                _superOperators[msg.sender] ||
                _operatorsForAll[from][msg.sender],
            "require meta approval"
        );
        _burn(from, id, amount);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal {
        if ((id & IS_NFT) > 0) {
            require(amount == 1, "can only burn one NFT");
            _burnERC721(_metaTransactionContracts[msg.sender] ? from : msg.sender, from, id);
        } else {
            require(amount > 0 && amount <= MAX_SUPPLY, "invalid amount");
            _burnERC1155(_metaTransactionContracts[msg.sender] ? from : msg.sender, from, id, uint32(amount));
        }
    }

    /// @notice Upgrades an NFT with new metadata and rarity.
    /// @param from address which own the NFT to be upgraded.
    /// @param id the NFT that will be burnt to be upgraded.
    /// @param packId unqiue packId for the token.
    /// @param hash hash of an IPFS cidv1 folder that contains the metadata of the new token type in the file 0.json.
    /// @param newRarity rarity power of the new NFT.
    /// @param to address which will receive the NFT.
    /// @param data bytes to be transmitted as part of the minted token.
    /// @return the id of the newly minted NFT.
    function updateERC721(
        address from,
        uint256 id,
        uint40 packId,
        bytes32 hash,
        uint8 newRarity,
        address to,
        bytes calldata data
    ) external returns (uint256) {
        require(hash != 0, "hash is zero");
        require(_bouncers[msg.sender], "only bouncer allowed to mint via update");
        require(to != address(0), "destination is zero address");
        require(from != address(0), "from is zero address");

        _burnERC721(msg.sender, from, id);

        uint256 newId = generateTokenId(from, 1, packId, 0, 0);
        _mint(hash, 1, newRarity, msg.sender, to, newId, data, false);
        emit AssetUpdate(id, newId);
        return newId;
    }

    /// @notice Extracts an EIP-721 NFT from an EIP-1155 token.
    /// @param id the token type to extract from.
    /// @param to address which will receive the token.
    /// @return the id of the newly minted NFT.
    function extractERC721(uint256 id, address to) external returns (uint256 newId) {
        return _extractERC721From(msg.sender, msg.sender, id, to);
    }

    /// @notice Extracts an EIP-721 NFT from an EIP-1155 token.
    /// @param sender address which own the token to be extracted.
    /// @param id the token type to extract from.
    /// @param to address which will receive the token.
    /// @return the id of the newly minted NFT.
    function extractERC721From(
        address sender,
        uint256 id,
        address to
    ) external returns (uint256 newId) {
        bool metaTx = _metaTransactionContracts[msg.sender];
        require(
            msg.sender == sender || metaTx || _superOperators[msg.sender] || _operatorsForAll[sender][msg.sender],
            "require meta approval"
        );
        return _extractERC721From(metaTx ? sender : msg.sender, sender, id, to);
    }

    function _extractERC721From(
        address operator,
        address sender,
        uint256 id,
        address to
    ) internal returns (uint256 newId) {
        require(to != address(0), "destination is zero address");
        require(id & IS_NFT == 0, "Not an ERC1155 Token");
        uint32 tokenCollectionIndex = _nextCollectionIndex[id];
        newId = id + IS_NFT + (tokenCollectionIndex) * 2**NFT_INDEX_OFFSET;
        _nextCollectionIndex[id] = tokenCollectionIndex + 1;
        _burnERC1155(operator, sender, id, 1);
        _mint(_metadataHash[id & URI_ID], 1, 0, operator, to, newId, "", true);
        emit Extraction(id, newId);
    }
}

pragma solidity ^0.5.2;

/**
    @title ERC-1155 Multi Token Standard
    @dev See https://eips.ethereum.org/EIPS/eip-1155
    Note: The ERC-165 identifier for this interface is 0xd9b67a26.
 */
interface ERC1155 {

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);

    /**
        @notice Transfers `value` amount of an `id` from  `from` to `to`  (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `from` account (see "Approval" section of the standard).
        MUST revert if `to` is the zero address.
        MUST revert if balance of holder for token `id` is lower than the `value` sent.
        MUST revert on any other error.
        MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
        After the above conditions are met, this function MUST check if `to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param from    Source address
        @param to      Target address
        @param id      ID of the token type
        @param value   Transfer amount
        @param data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `to`
    */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external;

    /**
        @notice Transfers `values` amount(s) of `ids` from the `from` address to the `to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `from` account (see "Approval" section of the standard).
        MUST revert if `to` is the zero address.
        MUST revert if length of `ids` is not the same as length of `values`.
        MUST revert if any of the balance(s) of the holder(s) for token(s) in `ids` is lower than the respective amount(s) in `values` sent to the recipient.
        MUST revert on any other error.
        MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see "Safe Transfer Rules" section of the standard).
        Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).
        After the above conditions for the transfer(s) in the batch are met, this function MUST check if `to` is a smart contract (e.g. code size > 0). If so, it MUST call the relevant `ERC1155TokenReceiver` hook(s) on `to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param from    Source address
        @param to      Target address
        @param ids     IDs of each token type (order and length must match _values array)
        @param values  Transfer amounts per token type (order and length must match _ids array)
        @param data    Additional data with no specified format, MUST be sent unaltered in call to the `ERC1155TokenReceiver` hook(s) on `to`
    */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;

    /**
        @notice Get the balance of an account's tokens.
        @param owner  The address of the token holder
        @param id     ID of the token
        @return        The _owner's balance of the token type requested
     */
    function balanceOf(address owner, uint256 id)
        external
        view
        returns (uint256);

    /**
        @notice Get the balance of multiple account/token pairs
        @param owners The addresses of the token holders
        @param ids    ID of the tokens
        @return        The _owner's balance of the token types requested (i.e. balance for each (owner, id) pair)
     */
    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
        @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
        @dev MUST emit the ApprovalForAll event on success.
        @param operator  Address to add to the set of authorized operators
        @param approved  True if the operator is approved, false to revoke approval
    */
    function setApprovalForAll(address operator, bool approved) external;

    /**
        @notice Queries the approval status of an operator for a given owner.
        @param owner     The owner of the tokens
        @param operator  Address of authorized operator
        @return           True if the operator is approved, false if not
    */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

pragma solidity ^0.5.2;

/**
    Note: The ERC-165 identifier for this interface is 0x4e2312e0.
*/
interface ERC1155TokenReceiver {
    /**
        @notice Handle the receipt of a single ERC1155 token type.
        @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated.
        This function MUST return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` (i.e. 0xf23a6e61) if it accepts the transfer.
        This function MUST revert if it rejects the transfer.
        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.
        @param operator  The address which initiated the transfer (i.e. msg.sender)
        @param from      The address which previously owned the token
        @param id        The ID of the token being transferred
        @param value     The amount of tokens being transferred
        @param data      Additional data with no specified format
        @return           `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @notice Handle the receipt of multiple ERC1155 token types.
        @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated.
        This function MUST return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` (i.e. 0xbc197c81) if it accepts the transfer(s).
        This function MUST revert if it rejects the transfer(s).
        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.
        @param operator  The address which initiated the batch transfer (i.e. msg.sender)
        @param from      The address which previously owned the token
        @param ids       An array containing ids of each token being transferred (order and length must match _values array)
        @param values    An array containing amounts of each token being transferred (order and length must match _ids array)
        @param data      Additional data with no specified format
        @return           `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

pragma solidity ^0.5.2;

library AddressUtils {

    function toPayable(address _address) internal pure returns (address payable _payable) {
        return address(uint160(_address));
    }

    function isContract(address addr) internal view returns (bool) {
        // for accounts without code, i.e. `keccak256('')`:
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        bytes32 codehash;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            codehash := extcodehash(addr)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

pragma solidity ^0.5.2;

import "./SafeMathWithRequire.sol";

library ObjectLib32 {
    using SafeMathWithRequire for uint256;
    enum Operations {ADD, SUB, REPLACE}
    // Constants regarding bin or chunk sizes for balance packing
    uint256 constant TYPES_BITS_SIZE = 32; // Max size of each object
    uint256 constant TYPES_PER_UINT256 = 256 / TYPES_BITS_SIZE; // Number of types per uint256

    //
    // Objects and Tokens Functions
    //

    /**
  * @dev Return the bin number and index within that bin where ID is
  * @param tokenId Object type
  * @return (Bin number, ID's index within that bin)
  */
    function getTokenBinIndex(uint256 tokenId)
        internal
        pure
        returns (uint256 bin, uint256 index)
    {
        bin = (tokenId * TYPES_BITS_SIZE) / 256;
        index = tokenId % TYPES_PER_UINT256;
        return (bin, index);
    }

    /**
  * @dev update the balance of a type provided in binBalances
  * @param binBalances Uint256 containing the balances of objects
  * @param index Index of the object in the provided bin
  * @param amount Value to update the type balance
  * @param operation Which operation to conduct :
  *     Operations.REPLACE : Replace type balance with amount
  *     Operations.ADD     : ADD amount to type balance
  *     Operations.SUB     : Substract amount from type balance
  */
    function updateTokenBalance(
        uint256 binBalances,
        uint256 index,
        uint256 amount,
        Operations operation
    ) internal pure returns (uint256 newBinBalance) {
        uint256 objectBalance = 0;
        if (operation == Operations.ADD) {
            objectBalance = getValueInBin(binBalances, index);
            newBinBalance = writeValueInBin(
                binBalances,
                index,
                objectBalance.add(amount)
            );
        } else if (operation == Operations.SUB) {
            objectBalance = getValueInBin(binBalances, index);
            require(objectBalance >= amount, "can't substract more than there is");
            newBinBalance = writeValueInBin(
                binBalances,
                index,
                objectBalance.sub(amount)
            );
        } else if (operation == Operations.REPLACE) {
            newBinBalance = writeValueInBin(binBalances, index, amount);
        } else {
            revert("Invalid operation"); // Bad operation
        }

        return newBinBalance;
    }
    /*
  * @dev return value in binValue at position index
  * @param binValue uint256 containing the balances of TYPES_PER_UINT256 types
  * @param index index at which to retrieve value
  * @return Value at given index in bin
  */
    function getValueInBin(uint256 binValue, uint256 index)
        internal
        pure
        returns (uint256)
    {
        // Mask to retrieve data for a given binData
        uint256 mask = (uint256(1) << TYPES_BITS_SIZE) - 1;

        // Shift amount
        uint256 rightShift = 256 - TYPES_BITS_SIZE * (index + 1);
        return (binValue >> rightShift) & mask;
    }

    /**
  * @dev return the updated binValue after writing amount at index
  * @param binValue uint256 containing the balances of TYPES_PER_UINT256 types
  * @param index Index at which to retrieve value
  * @param amount Value to store at index in bin
  * @return Value at given index in bin
  */
    function writeValueInBin(uint256 binValue, uint256 index, uint256 amount)
        internal
        pure
        returns (uint256)
    {
        require(
            amount < 2**TYPES_BITS_SIZE,
            "Amount to write in bin is too large"
        );

        // Mask to retrieve data for a given binData
        uint256 mask = (uint256(1) << TYPES_BITS_SIZE) - 1;

        // Shift amount
        uint256 leftShift = 256 - TYPES_BITS_SIZE * (index + 1);
        return (binValue & ~(mask << leftShift)) | (amount << leftShift);
    }

}

pragma solidity ^0.5.2;

import "./ERC165.sol";
import "./ERC721Events.sol";

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
/*interface*/
contract ERC721 is ERC165, ERC721Events {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    //   function exists(uint256 tokenId) external view returns (bool exists);

    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function transferFrom(address from, address to, uint256 tokenId)
        external;
    function safeTransferFrom(address from, address to, uint256 tokenId)
        external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
// solhint-disable-next-line compiler-fixed
pragma solidity ^0.5.2;

interface ERC721TokenReceiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

pragma solidity ^0.5.2;

import "./Admin.sol";

contract SuperOperators is Admin {

    mapping(address => bool) internal _superOperators;

    event SuperOperator(address superOperator, bool enabled);

    /// @notice Enable or disable the ability of `superOperator` to transfer tokens of all (superOperator rights).
    /// @param superOperator address that will be given/removed superOperator right.
    /// @param enabled set whether the superOperator is enabled or disabled.
    function setSuperOperator(address superOperator, bool enabled) external {
        require(
            msg.sender == _admin,
            "only admin is allowed to add super operators"
        );
        _superOperators[superOperator] = enabled;
        emit SuperOperator(superOperator, enabled);
    }

    /// @notice check whether address `who` is given superOperator rights.
    /// @param who The address to query.
    /// @return whether the address has superOperator rights.
    function isSuperOperator(address who) public view returns (bool) {
        return _superOperators[who];
    }
}

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert
 */
library SafeMathWithRequire {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        require(c / a == b, "overflow");
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "undeflow");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "overflow");
        return c;
    }
}

pragma solidity ^0.5.2;

/**
 * @title ERC165
 * @dev https://eips.ethereum.org/EIPS/eip-165
 */
interface ERC165 {
    /**
   * @notice Query if a contract implements interface `interfaceId`
   * @param interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * uses less than 30,000 gas.
   */
    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool);
}

pragma solidity ^0.5.2;

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
interface ERC721Events {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );
}

pragma solidity ^0.5.2;

contract Admin {

    address internal _admin;

    event AdminChanged(address oldAdmin, address newAdmin);

    /// @notice gives the current administrator of this contract.
    /// @return the current administrator of this contract.
    function getAdmin() external view returns (address) {
        return _admin;
    }

    /// @notice change the administrator to be `newAdmin`.
    /// @param newAdmin address of the new administrator.
    function changeAdmin(address newAdmin) external {
        require(msg.sender == _admin, "only admin can change admin");
        emit AdminChanged(_admin, newAdmin);
        _admin = newAdmin;
    }

    modifier onlyAdmin() {
        require (msg.sender == _admin, "only admin allowed");
        _;
    }

}

pragma solidity 0.5.9;

import "../Asset/Interfaces/MintingFeeCollector.sol";
import "../Asset/Interfaces/AssetBouncer.sol";

import "../Asset.sol";
import "../contracts_common/Interfaces/ERC20.sol";

contract TestMintingFeeCollector is MintingFeeCollector {
    mapping(uint256 => uint256) stakes;

    AssetBouncer from;
    address owner;
    uint256 feePerToken;
    ERC20 acceptedFeeToken;
    constructor(address _owner, AssetBouncer _from, ERC20 _acceptedFeeToken)
        public
    {
        from = _from;
        owner = _owner;
        acceptedFeeToken = _acceptedFeeToken;
    }

    function newFee(ERC20 _newFeeToken, uint256 _newFee) external {
        require(msg.sender == address(from), "only accepting from Asset");
        require(_newFeeToken == acceptedFeeToken, "token type not accepted");
        feePerToken = _newFee;
    }

    function multiple_minted(uint256[] calldata tokenIds) external {
        require(msg.sender == address(from), "only accepting from Asset");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            stakes[tokenIds[i]] = feePerToken;
        }
    }

    function single_minted(uint256 tokenId) external {
        require(msg.sender == address(from), "only accepting from Asset");
        stakes[tokenId] = feePerToken;
    }

    // TODO ? or remove FeeCollector entirely, bouncer will be doing the job. what is needed is a
    // function setFeeCollection(address newCollector, ERC20 newFeeToken, uint256 newFee) external {
    //     require(msg.sender == owner);
    //     from.setFeeCollection(newCollector, newFeeToken, newFee);
    // }

}

pragma solidity 0.5.9;

import "../../contracts_common/Interfaces/ERC20.sol";

interface MintingFeeCollector {
    function newFee(ERC20 _newFeeToken, uint256 _newFee) external;
    function multiple_minted(uint256[] calldata tokenIds) external;
    function single_minted(uint256 tokenId) external;
}

pragma solidity 0.5.9;

contract AssetBouncer {}

pragma solidity ^0.5.2;

import "./ERC20Basic.sol";

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
/* interface */
contract ERC20 is ERC20Basic {
    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function allowance(address owner, address spender)
        public
        view
        returns (uint256);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity ^0.5.2;

/**
 * @title ERC20Basic DRAFT
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
/* interface */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

pragma solidity 0.5.9;

import "../contracts_common/Interfaces/ERC777TokensRecipient.sol";
import "../contracts_common/Interfaces/ERC777Token.sol";
import "../contracts_common/Interfaces/ERC20.sol";
import { ERC820Implementer } from "../contracts_common/Base/ERC820Implementer.sol";

contract Wonderland777Sender is ERC777TokensRecipient, ERC820Implementer {
    bool private allowTokensSent;

    address private owner;
    ERC777Token private tokenContract;
    uint256 private tokenBalance;

    constructor(ERC777Token _tokenContract, bool _allowTokensSent) public {
        tokenContract = _tokenContract;
        allowTokensSent = _allowTokensSent;
        owner = msg.sender;

        setInterfaceImplementation("ERC777TokensSender", address(this));
        setInterfaceImplementation("ERC777TokensRecipient", address(this));
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function send(address _to, uint256 _amount) public {
        tokenContract.send(_to, _amount, "");
    }

    function transfer(address _to, uint256 _amount) public {
        ERC20(address(tokenContract)).transfer(_to, _amount);
    }

    function tokensReceived(
        address, // operator,
        address, // from,
        address, // to,
        uint256 amount,
        bytes memory, // data,
        bytes memory // operatorData
    ) public {
        require(address(tokenContract) == msg.sender, "only accept tokenContract as sender");
        tokenBalance += amount;
    }

    function tokensToSend(
        address, // operator,
        address, // from,
        address, // to,
        uint256 amount,
        bytes memory, // data,
        bytes memory // operatorData
    ) public {
        require(address(tokenContract) == msg.sender, "only accept tokenContract as sender");
        require(allowTokensSent, "Sending not allowed");
        tokenBalance -= amount;
    }

    function acceptTokens() public onlyOwner {
        allowTokensSent = true;
    }

    function rejectTokens() public onlyOwner {
        allowTokensSent = false;
    }
}

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
// solhint-disable-next-line compiler-fixed
pragma solidity ^0.5.2;

/* interface */
contract ERC777TokensRecipient {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public;
}

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
// solhint-disable-next-line compiler-fixed
pragma solidity ^0.5.2;

/* interface */
contract ERC777Token {
    function name() public view returns (string memory);
    function symbol() public view returns (string memory);
    function totalSupply() public view returns (uint256);
    function balanceOf(address owner) public view returns (uint256);
    function granularity() public view returns (uint256);

    function defaultOperators() public view returns (address[] memory);
    function isOperatorFor(address operator, address tokenHolder)
        public
        view
        returns (bool);
    function authorizeOperator(address operator) public;
    function revokeOperator(address operator) public;

    function send(address to, uint256 amount, bytes memory data) public;
    function operatorSend(
        address from,
        address to,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public;

    // function burn(uint256 amount, bytes data) public;
    // function operatorBurn(address from, uint256 amount, bytes data, bytes operatorData) public;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    ); // solhint-disable-next-line separate-by-one-line-in-contract
    event Minted(
        address indexed operator,
        address indexed to,
        uint256 amount,
        bytes operatorData
    );
    event Burned(
        address indexed operator,
        address indexed from,
        uint256 amount,
        bytes data,
        bytes operatorData
    );
    event AuthorizedOperator(
        address indexed operator,
        address indexed tokenHolder
    );
    event RevokedOperator(
        address indexed operator,
        address indexed tokenHolder
    );
}

pragma solidity ^0.5.2;

contract ERC820Registry {
    function getManager(address addr) public view returns (address);
    function setManager(address addr, address newManager) public;
    function getInterfaceImplementer(address addr, bytes32 iHash)
        public
        view
        returns (address);
    function setInterfaceImplementer(
        address addr,
        bytes32 iHash,
        address implementer
    ) public;
}

contract ERC820Implementer {
    ERC820Registry constant erc820Registry = ERC820Registry(
        0x820b586C8C28125366C998641B09DCbE7d4cBF06
    );

    function setInterfaceImplementation(string memory ifaceLabel, address impl)
        internal
    {
        bytes32 ifaceHash = keccak256(bytes(ifaceLabel));
        erc820Registry.setInterfaceImplementer(address(this), ifaceHash, impl);
    }

    function interfaceAddr(address addr, string memory ifaceLabel)
        internal
        view
        returns (address)
    {
        bytes32 ifaceHash = keccak256(bytes(ifaceLabel));
        return erc820Registry.getInterfaceImplementer(addr, ifaceHash);
    }

    function delegateManagement(address newManager) internal {
        erc820Registry.setManager(address(this), newManager);
    }
}

pragma solidity 0.5.9;

import "../contracts_common/Interfaces/ERC777TokensRecipient.sol";
import "../contracts_common/Interfaces/ERC777Token.sol";
import "../contracts_common/Interfaces/ERC20.sol";
import { ERC820Implementer } from "../contracts_common/Base/ERC820Implementer.sol";

contract Wonderland777Receiver is ERC777TokensRecipient, ERC820Implementer {
    bool private allowTokensReceived;

    address private owner;
    ERC777Token private tokenContract;
    uint256 private tokenBalance;

    constructor(ERC777Token _tokenContract, bool _allowTokensReceived) public {
        tokenContract = _tokenContract;
        allowTokensReceived = _allowTokensReceived;
        owner = msg.sender;

        setInterfaceImplementation("ERC777TokensRecipient", address(this));
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function send(address _to, uint256 _amount) public {
        tokenContract.send(_to, _amount, "");
    }

    function transfer(address _to, uint256 _amount) public {
        ERC20(address(tokenContract)).transfer(_to, _amount);
    }

    function tokensReceived(
        address, // operator,
        address, // from,
        address, // to,
        uint256 amount,
        bytes memory, // data,
        bytes memory // operatorData
    ) public {
        require(address(tokenContract) == msg.sender, "only accept tokenContract as sender");
        require(allowTokensReceived, "Receive not allowed");
        tokenBalance += amount;
    }

    function acceptTokens() public onlyOwner {
        allowTokensReceived = true;
    }

    function rejectTokens() public onlyOwner {
        allowTokensReceived = false;
    }

    function receiveMeta(
        address sender,
        string calldata name,
        uint256 value,
        uint256 test
    ) external {
        // for test matching erc20Receiver
    }
}

pragma solidity 0.5.9;

import "../contracts_common/Interfaces/ERC20.sol";

contract GenericERC20MetaTxReceiver {
    address metaTxContract;
    ERC20 token;
    address owner;
    uint256 price;
    uint256 balance;

    event Received(address sender, uint256 value);

    constructor(address _metaTxContract, ERC20 _token, uint256 _price) public {
        token = _token;
        owner = msg.sender;
        price = _price;
        metaTxContract = _metaTxContract;
    }

    function erc20_tokensReceived(
        address from,
        address tokenContract,
        uint256 amount,
        bytes calldata data
    ) external {
        // TODO check token being given
        require(
            msg.sender == address(metaTxContract) ||
                msg.sender == tokenContract,
            "sender != metaTxContract && != tokenContract"
        );
        require(amount == price, "not enough value");
        balance += amount;
        emit Received(from, amount);
    }

    function meta_transaction_received(address sender, bytes calldata data)
        external
    {
        (address addr, uint256 value) = abi.decode(data, (address, uint256));
        require(
            sender == msg.sender || msg.sender == address(metaTxContract),
            "sender != sender && != metaTxContract"
        );
        emit Received(addr, value);
    }

    function withdrawnAll() external {
        require(owner == msg.sender, "only owner can withdraw");
        uint256 tmpBalance = balance;
        balance = 0;
        token.transfer(msg.sender, tmpBalance);
    }
}

pragma solidity 0.5.9;

import "../contracts_common/Interfaces/ERC20.sol";

contract ERC20MetaTxReceiver {
    ERC20 token;
    address owner;
    uint256 price;
    uint256 balance;

    event Received(address sender, uint256 value, string name, uint256 test);

    constructor(ERC20 _token, uint256 _price) public {
        token = _token;
        price = _price;
        owner = msg.sender;
    }

    function receiveMeta(
        address sender,
        uint256 value,
        string calldata name,
        uint256 test
    ) external {
        require(
            msg.sender == sender || msg.sender == address(token),
            "sender != msg.sender || token"
        );
        require(value == price, "not enough value");
        token.transferFrom(sender, address(this), value);

        balance += value;
        emit Received(sender, value, name, test);
    }

    function withdrawnAll() external {
        require(owner == msg.sender, "only owner can withdraw");
        uint256 tmpBalance = balance;
        balance = 0;
        token.transfer(msg.sender, tmpBalance);
    }
}

pragma solidity 0.5.9;

import "../contracts_common/Interfaces/ERC20.sol";

contract ERC20Fund {
    ERC20 token;
    address owner;

    constructor(ERC20 _token) public {
        token = _token;
        owner = msg.sender;
    }

    function take(address _from, uint256 _amount) public returns (bool) {
        return token.transferFrom(_from, address(this), _amount);
    }

    function give(address _to, uint256 _amount) public returns (bool) {
        require(msg.sender == owner, "only onwer can give");
        return token.transfer(_to, _amount);
    }

    function fail() external pure {
        require(false, "fail");
    }
}

/* solhint-disable not-rely-on-time, func-order */

pragma solidity 0.5.9;

import "../contracts_common/Libraries/SigUtil.sol";
import "../contracts_common/Libraries/SafeMathWithRequire.sol";
import "../contracts_common/Interfaces/ERC20.sol";
import "../contracts_common/BaseWithStorage/Admin.sol";


/**
 * @title Referral Validator
 * @notice This contract verifies if a referral is valid
 */
contract ReferralValidator is Admin {
    address private _signingWallet;
    uint256 private _maxCommissionRate;

    mapping (address => uint256) private _previousSigningWallets;
    uint256 private _previousSigningDelay = 60 * 60 * 24 * 10;

    event ReferralUsed(
        address indexed referrer,
        address indexed referee,
        address indexed token,
        uint256 amount,
        uint256 commission,
        uint256 commissionRate
    );

    constructor(
        address initialSigningWallet,
        uint256 initialMaxCommissionRate
    ) public {
        _signingWallet = initialSigningWallet;
        _maxCommissionRate = initialMaxCommissionRate;
    }

    /**
     * @notice Update the signing wallet
     * @param newSigningWallet The new address of the signing wallet
     */
    function updateSigningWallet(address newSigningWallet) external {
        require(_admin == msg.sender, "Sender not admin");
        _previousSigningWallets[_signingWallet] = now + _previousSigningDelay;
        _signingWallet = newSigningWallet;
    }

    // TODO: Check if this function is really useful
    /**
     * @notice Update the maximum commission rate
     * @param newMaxCommissionRate The new maximum commission rate
     */
    function updateMaxCommissionRate(uint256 newMaxCommissionRate) external {
        require(_admin == msg.sender, "Sender not admin");
        _maxCommissionRate = newMaxCommissionRate;
    }

    function handleReferralWithETH(
        uint256 amount,
        bytes memory referral,
        address payable destination
    ) internal {
        uint256 amountForDestination = amount;

        if (referral.length > 0) {
            (
                bytes memory signature,
                address referrer,
                address referee,
                uint256 expiryTime,
                uint256 commissionRate
            ) = decodeReferral(referral);

            uint256 commission = 0;

            if (isReferralValid(signature, referrer, referee, expiryTime, commissionRate)) {
                commission = SafeMathWithRequire.div(
                    SafeMathWithRequire.mul(amount, commissionRate),
                    10000
                );

                emit ReferralUsed(
                    referrer,
                    referee,
                    address(0),
                    amount,
                    commission,
                    commissionRate
                );
                amountForDestination = SafeMathWithRequire.sub(
                    amountForDestination,
                    commission
                );
            }

            if (commission > 0) {
                address(uint160(referrer)).transfer(commission);
            }
        }

        destination.transfer(amountForDestination);
    }

    function handleReferralWithERC20(
        address buyer,
        uint256 amount,
        bytes memory referral,
        address payable destination,
        address tokenAddress
    ) internal {
        ERC20 token = ERC20(tokenAddress);
        uint256 amountForDestination = amount;

        if (referral.length > 0) {
            (
                bytes memory signature,
                address referrer,
                address referee,
                uint256 expiryTime,
                uint256 commissionRate
            ) = decodeReferral(referral);

            uint256 commission = 0;

            if (isReferralValid(signature, referrer, referee, expiryTime, commissionRate)) {
                commission = SafeMathWithRequire.div(
                    SafeMathWithRequire.mul(amount, commissionRate),
                    10000
                );

                emit ReferralUsed(
                    referrer,
                    referee,
                    tokenAddress,
                    amount,
                    commission,
                    commissionRate
                );
                amountForDestination = SafeMathWithRequire.sub(
                    amountForDestination,
                    commission
                );
            }

            if (commission > 0) {
                require(token.transferFrom(buyer, referrer, commission), "commision transfer failed");
            }
        }

        require(token.transferFrom(buyer, destination, amountForDestination), "payment transfer failed");
    }

    /**
     * @notice Check if a referral is valid
     * @param signature The signature to check (signed referral)
     * @param referrer The address of the referrer
     * @param referee The address of the referee
     * @param expiryTime The expiry time of the referral
     * @param commissionRate The commissionRate of the referral
     * @return True if the referral is valid
     */
    function isReferralValid(
        bytes memory signature,
        address referrer,
        address referee,
        uint256 expiryTime,
        uint256 commissionRate
    ) public view returns (
        bool
    ) {
        if (commissionRate > _maxCommissionRate || referrer == referee || now > expiryTime) {
            return false;
        }

        bytes32 hashedData = keccak256(
            abi.encodePacked(
                referrer,
                referee,
                expiryTime,
                commissionRate
            )
        );

        address signer = SigUtil.recover(
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hashedData)
            ),
            signature
        );

        if (_previousSigningWallets[signer] >= now) {
            return true;
        }

        return _signingWallet == signer;
    }

    function decodeReferral(
        bytes memory referral
    ) public pure returns (
        bytes memory,
        address,
        address,
        uint256,
        uint256
    ) {
        (
            bytes memory signature,
            address referrer,
            address referee,
            uint256 expiryTime,
            uint256 commissionRate
        ) = abi.decode(referral, (bytes, address, address, uint256, uint256));

        return (
            signature,
            referrer,
            referee,
            expiryTime,
            commissionRate
        );
    }
}

pragma solidity ^0.5.2;

library SigUtil {
    function recover(bytes32 hash, bytes memory sig)
        internal
        pure
        returns (address recovered)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28);

        recovered = ecrecover(hash, v, r, s);
        require(recovered != address(0));
    }

    function recoverWithZeroOnFailure(bytes32 hash, bytes memory sig)
        internal
        pure
        returns (address)
    {
        if (sig.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes memory) {
        return abi.encodePacked("\x19Ethereum Signed Message:\n32", hash);
    }
}

pragma solidity 0.5.9;

import "./ERC1155ERC721.sol";
import "../contracts_common/BaseWithStorage/Admin.sol";

contract GenesisBouncer is Admin {
    ERC1155ERC721 _asset;
    mapping(address => bool) _minters;

    constructor(ERC1155ERC721 asset, address genesisAdmin, address firstMinter)
        public
    {
        _asset = asset;
        _admin = genesisAdmin;
        _setMinter(firstMinter, true);
    }

    event MinterUpdated(address minter, bool allowed);
    function _setMinter(address minter, bool allowed) internal {
        _minters[minter] = allowed;
        emit MinterUpdated(minter, allowed);
    }
    function setMinter(address minter, bool allowed) external {
        require(msg.sender == _admin, "only admin can allocate minter");
        _setMinter(minter, allowed);
    }

    function mintFor(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint32 supply,
        uint8 rarity,
        address owner
    ) public returns (uint256 tokenId) {
        require(_minters[msg.sender], "not authorized");
        return
            _asset.mint(creator, packId, hash, supply, rarity, owner, "");
    }

    function mintMultipleFor(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint256[] memory supplies,
        bytes memory rarityPack,
        address owner
    ) public returns (uint256[] memory ids) {
        require(_minters[msg.sender], "not authorized");
        return
            _asset.mintMultiple(
                creator,
                packId,
                hash,
                supplies,
                rarityPack,
                owner,
                ""
            );
    }
}

pragma solidity 0.5.9;

import "../Asset/Interfaces/AssetBouncer.sol";
import "../Asset/ERC1155ERC721.sol";

contract TestBouncer is AssetBouncer {
    ERC1155ERC721 asset;

    constructor(ERC1155ERC721 _asset)
        public
    {
        asset = _asset;
    }

    function mintFor(
        address _creator,
        uint40 _packId,
        bytes32 _hash,
        uint32 _supply,
        uint8 _rarity,
        address _owner
    ) public returns (uint256 tokenId) {
        return
            asset.mint(_creator, _packId, _hash, _supply, _rarity, _owner, "");
    }

    function mintMultipleFor(
        address _creator,
        uint40 _packId,
        bytes32 _hash,
        uint256[] memory _supplies,
        bytes memory _rarityPack,
        address _owner
    ) public returns (uint256[] memory tokenIds) {
        return
            asset.mintMultiple(
                _creator,
                _packId,
                _hash,
                _supplies,
                _rarityPack,
                _owner,
                ""
            );
    }

    function updateERC721(
        address _from,
        uint256 _tokenId,
        uint40 _packId,
        bytes32 _hash,
        uint8 _newRarity,
        address _to
    ) external returns(uint256) {
        return
            asset.updateERC721(
                _from,
                _tokenId,
                _packId,
                _hash,
                _newRarity,
                _to,
                ""
            );
    }
}

pragma solidity 0.5.9;

import "../Asset/ERC1155ERC721.sol";

contract TestAsset is ERC1155ERC721 {
    function test() external pure returns (string memory) {
        return "hello";
    }
}

pragma solidity 0.5.9;

import "./ERC1155ERC721.sol";
import "../contracts_common/Interfaces/ERC20.sol";
import "../contracts_common/BaseWithStorage/MetaTransactionReceiver.sol";
import "../contracts_common/Libraries/SafeMathWithRequire.sol";

contract CommonMinter is MetaTransactionReceiver {
    using SafeMathWithRequire for uint256;

    uint256 _feePerCopy;

    ERC1155ERC721 _asset;
    mapping(address => bool) _minters;
    address _feeReceiver;
    ERC20 _arv;

    constructor(
        ERC1155ERC721 asset,
        ERC20 arv,
        uint256 feePerCopy,
        address admin,
        address feeReceiver
    ) public {
        _arv = arv;
        _asset = asset;
        _feePerCopy = feePerCopy;
        _admin = admin;
        _feeReceiver = feeReceiver;
        _setMetaTransactionProcessor(address(arv), true);
    }

    /// @notice set the receiver of the proceeds
    /// @param newFeeReceiver address of the new fee receiver
    function setFeeReceiver(address newFeeReceiver) external {
        require(msg.sender == _admin, "only admin can change the receiver");
        _feeReceiver = newFeeReceiver;
    }

    /// @notice set the fee in Wonderland for each common Asset copies
    /// @param newFee new fee in Wonderland
    function setFeePerCopy(uint256 newFee) external {
        require(msg.sender == _admin, "only admin allowed to set fee");
        _feePerCopy = newFee;
    }

    /// @notice mint common Asset token by paying the Wonderland fee
    /// @param creator address creating the Asset, need to be the tx sender or meta tx signer
    /// @param packId unused packId that will let you predict the resulting tokenId
    /// @param hash cidv1 ipfs hash of the folder where 0.json file contains the metadata
    /// @param supply number of copies to mint, cost in Wonderland is relative it it
    /// @param owner address receiving the minted tokens
    /// @param data extra data
    /// @param feePerCopy fee in Wonderland for each copies
    function mintFor(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint32 supply,
        address owner,
        bytes calldata data,
        uint256 feePerCopy
    ) external returns (uint256 id) {
        require(creator == msg.sender || _metaTransactionContracts[msg.sender], "not authorized");
        require(feePerCopy == _feePerCopy, "invalid fee");
        require(_arv.transferFrom(creator, _feeReceiver, uint256(supply).mul(feePerCopy)), "failed to transfer ARV");
        return _asset.mint(creator, packId, hash, supply, 0, owner, data);
    }

    /// @notice mint multiple common Asset tokena by paying the Wonderland fee
    /// @param creator address creating the Asset, need to be the tx sender or meta tx signer
    /// @param packId unused packId that will let you predict the resulting tokenId
    /// @param hash cidv1 ipfs hash of the folder where 0.json file contains the metadata
    /// @param supplies number of copies to mint for each Asset, cost in Wonderland is relative it it
    /// @param owner address receiving the minted tokens
    /// @param data extra data
    /// @param feePerCopy fee in Wonderland for each copies
    function mintMultipleFor(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint256[] calldata supplies,
        address owner,
        bytes calldata data,
        uint256 feePerCopy
    ) external returns (uint256[] memory ids) {
        require(creator == msg.sender || _metaTransactionContracts[msg.sender], "not authorized");
        require(feePerCopy == _feePerCopy, "invalid fee");
        uint256 totalCopies = 0;
        uint256 numAssetTypes = supplies.length;
        for (uint256 i = 0; i < numAssetTypes; i++) {
            totalCopies = totalCopies.add(supplies[i]);
        }
        require(_arv.transferFrom(creator, _feeReceiver, totalCopies.mul(feePerCopy)), "failed to transfer ARV");
        return _asset.mintMultiple(creator, packId, hash, supplies, "", owner, data);
    }
}

pragma solidity ^0.5.2;

import "./Admin.sol";

contract MetaTransactionReceiver is Admin{

    mapping(address => bool) internal _metaTransactionContracts;
    event MetaTransactionProcessor(address metaTransactionProcessor, bool enabled);

    /// @notice Enable or disable the ability of `metaTransactionProcessor` to perform meta-tx (metaTransactionProcessor rights).
    /// @param metaTransactionProcessor address that will be given/removed metaTransactionProcessor rights.
    /// @param enabled set whether the metaTransactionProcessor is enabled or disabled.
    function setMetaTransactionProcessor(address metaTransactionProcessor, bool enabled) public {
        require(
            msg.sender == _admin,
            "only admin can setup metaTransactionProcessors"
        );
        _setMetaTransactionProcessor(metaTransactionProcessor, enabled);
    }

    function _setMetaTransactionProcessor(address metaTransactionProcessor, bool enabled) internal {
        _metaTransactionContracts[metaTransactionProcessor] = enabled;
        emit MetaTransactionProcessor(metaTransactionProcessor, enabled);
    }

    /// @notice check whether address `who` is given meta-transaction execution rights.
    /// @param who The address to query.
    /// @return whether the address has meta-transaction execution rights.
    function isMetaTransactionProcessor(address who) external view returns(bool) {
        return _metaTransactionContracts[who];
    }
}

pragma solidity ^0.5.2;

import "./SafeMathWithRequire.sol";

library ObjectLib64 {
    using SafeMathWithRequire for uint256;
    enum Operations {ADD, SUB, REPLACE}
    // Constants regarding bin or chunk sizes for balance packing
    uint256 constant TYPES_BITS_SIZE = 64; // Max size of each object
    uint256 constant TYPES_PER_UINT256 = 256 / TYPES_BITS_SIZE; // Number of types per uint256

    //
    // Objects and Tokens Functions
    //

    /**
  * @dev Return the bin number and index within that bin where ID is
  * @param _tokenId Object type
  * @return (Bin number, ID's index within that bin)
  */
    function getTokenBinIndex(uint256 _tokenId)
        internal
        pure
        returns (uint256 bin, uint256 index)
    {
        bin = (_tokenId * TYPES_BITS_SIZE) / 256;
        index = _tokenId % TYPES_PER_UINT256;
        return (bin, index);
    }

    /**
  * @dev update the balance of a type provided in _binBalances
  * @param _binBalances Uint256 containing the balances of objects
  * @param _index Index of the object in the provided bin
  * @param _amount Value to update the type balance
  * @param _operation Which operation to conduct :
  *     Operations.REPLACE : Replace type balance with _amount
  *     Operations.ADD     : ADD _amount to type balance
  *     Operations.SUB     : Substract _amount from type balance
  */
    function updateTokenBalance(
        uint256 _binBalances,
        uint256 _index,
        uint256 _amount,
        Operations _operation
    ) internal pure returns (uint256 newBinBalance) {
        uint256 objectBalance = 0;
        if (_operation == Operations.ADD) {
            objectBalance = getValueInBin(_binBalances, _index);
            newBinBalance = writeValueInBin(
                _binBalances,
                _index,
                objectBalance.add(_amount)
            );
        } else if (_operation == Operations.SUB) {
            objectBalance = getValueInBin(_binBalances, _index);
            newBinBalance = writeValueInBin(
                _binBalances,
                _index,
                objectBalance.sub(_amount)
            );
        } else if (_operation == Operations.REPLACE) {
            newBinBalance = writeValueInBin(_binBalances, _index, _amount);
        } else {
            revert("Invalid operation"); // Bad operation
        }

        return newBinBalance;
    }
    /*
  * @dev return value in _binValue at position _index
  * @param _binValue uint256 containing the balances of TYPES_PER_UINT256 types
  * @param _index index at which to retrieve value
  * @return Value at given _index in _bin
  */
    function getValueInBin(uint256 _binValue, uint256 _index)
        internal
        pure
        returns (uint256)
    {
        // Mask to retrieve data for a given binData
        uint256 mask = (uint256(1) << TYPES_BITS_SIZE) - 1;

        // Shift amount
        uint256 rightShift = 256 - TYPES_BITS_SIZE * (_index + 1);
        return (_binValue >> rightShift) & mask;
    }

    /**
  * @dev return the updated _binValue after writing _amount at _index
  * @param _binValue uint256 containing the balances of TYPES_PER_UINT256 types
  * @param _index Index at which to retrieve value
  * @param _amount Value to store at _index in _bin
  * @return Value at given _index in _bin
  */
    function writeValueInBin(uint256 _binValue, uint256 _index, uint256 _amount)
        internal
        pure
        returns (uint256)
    {
        require(
            _amount < 2**TYPES_BITS_SIZE,
            "Amount to write in bin is too large"
        );

        // Mask to retrieve data for a given binData
        uint256 mask = (uint256(1) << TYPES_BITS_SIZE) - 1;

        // Shift amount
        uint256 leftShift = 256 - TYPES_BITS_SIZE * (_index + 1);
        return (_binValue & ~(mask << leftShift)) | (_amount << leftShift);
    }

}

pragma solidity ^0.5.2;

import "./SafeMathWithRequire.sol";

library ObjectLib {
    using SafeMathWithRequire for uint256;
    enum Operations {ADD, SUB, REPLACE}
    // Constants regarding bin or chunk sizes for balance packing
    uint256 constant TYPES_BITS_SIZE = 16; // Max size of each object
    uint256 constant TYPES_PER_UINT256 = 256 / TYPES_BITS_SIZE; // Number of types per uint256

    //
    // Objects and Tokens Functions
    //

    /**
  * @dev Return the bin number and index within that bin where ID is
  * @param _tokenId Object type
  * @return (Bin number, ID's index within that bin)
  */
    function getTokenBinIndex(uint256 _tokenId)
        internal
        pure
        returns (uint256 bin, uint256 index)
    {
        bin = (_tokenId * TYPES_BITS_SIZE) / 256;
        index = _tokenId % TYPES_PER_UINT256;
        return (bin, index);
    }

    /**
  * @dev update the balance of a type provided in _binBalances
  * @param _binBalances Uint256 containing the balances of objects
  * @param _index Index of the object in the provided bin
  * @param _amount Value to update the type balance
  * @param _operation Which operation to conduct :
  *     Operations.REPLACE : Replace type balance with _amount
  *     Operations.ADD     : ADD _amount to type balance
  *     Operations.SUB     : Substract _amount from type balance
  */
    function updateTokenBalance(
        uint256 _binBalances,
        uint256 _index,
        uint256 _amount,
        Operations _operation
    ) internal pure returns (uint256 newBinBalance) {
        uint256 objectBalance = 0;
        if (_operation == Operations.ADD) {
            objectBalance = getValueInBin(_binBalances, _index);
            newBinBalance = writeValueInBin(
                _binBalances,
                _index,
                objectBalance.add(_amount)
            );
        } else if (_operation == Operations.SUB) {
            objectBalance = getValueInBin(_binBalances, _index);
            newBinBalance = writeValueInBin(
                _binBalances,
                _index,
                objectBalance.sub(_amount)
            );
        } else if (_operation == Operations.REPLACE) {
            newBinBalance = writeValueInBin(_binBalances, _index, _amount);
        } else {
            revert("Invalid operation"); // Bad operation
        }

        return newBinBalance;
    }
    /*
  * @dev return value in _binValue at position _index
  * @param _binValue uint256 containing the balances of TYPES_PER_UINT256 types
  * @param _index index at which to retrieve value
  * @return Value at given _index in _bin
  */
    function getValueInBin(uint256 _binValue, uint256 _index)
        internal
        pure
        returns (uint256)
    {
        // Mask to retrieve data for a given binData
        uint256 mask = (uint256(1) << TYPES_BITS_SIZE) - 1;

        // Shift amount
        uint256 rightShift = 256 - TYPES_BITS_SIZE * (_index + 1);
        return (_binValue >> rightShift) & mask;
    }

    /**
  * @dev return the updated _binValue after writing _amount at _index
  * @param _binValue uint256 containing the balances of TYPES_PER_UINT256 types
  * @param _index Index at which to retrieve value
  * @param _amount Value to store at _index in _bin
  * @return Value at given _index in _bin
  */
    function writeValueInBin(uint256 _binValue, uint256 _index, uint256 _amount)
        internal
        pure
        returns (uint256)
    {
        require(
            _amount < 2**TYPES_BITS_SIZE,
            "Amount to write in bin is too large"
        );

        // Mask to retrieve data for a given binData
        uint256 mask = (uint256(1) << TYPES_BITS_SIZE) - 1;

        // Shift amount
        uint256 leftShift = 256 - TYPES_BITS_SIZE * (_index + 1);
        return (_binValue & ~(mask << leftShift)) | (_amount << leftShift);
    }

}

pragma solidity ^0.5.2;

import "./SafeMathWithRequire.sol";

library PriceUtil {
    using SafeMathWithRequire for uint256;

    function calculateCurrentPrice(
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 secondsPassed
    ) internal pure returns (uint256) {
        if (secondsPassed > duration) {
            return endingPrice;
        }
        if (endingPrice == startingPrice) {
            return endingPrice;
        } else if (endingPrice > startingPrice) {
            return startingPrice.add(
                (endingPrice.sub(startingPrice)).mul(secondsPassed).div(duration)
            );
        } else {
            return startingPrice.sub(
                (startingPrice.sub(endingPrice)).mul(secondsPassed).div(duration)
            );
        }
    }

    function calculateFee(uint256 price, uint256 fee10000th)
        internal
        pure
        returns (uint256)
    {
        // _fee < 10000, so the result will be <= price
        return (price.mul(fee10000th)) / 10000;
    }

}

pragma solidity 0.5.9;

import "../contracts_common/Libraries/SigUtil.sol";
import "../contracts_common/Libraries/PriceUtil.sol";
import "../Sand.sol";
import "../Asset.sol";
import "../contracts_common/Interfaces/ERC20.sol";
import "../TheWonderland712.sol";
import "../contracts_common/BaseWithStorage/MetaTransactionReceiver.sol";

import "../contracts_common/Interfaces/ERC1271.sol";
import "../contracts_common/Interfaces/ERC1271Constants.sol";
import "../contracts_common/Interfaces/ERC1654.sol";
import "../contracts_common/Interfaces/ERC1654Constants.sol";
import "../contracts_common/Libraries/SafeMathWithRequire.sol";

contract AssetSignedAuction is ERC1654Constants, ERC1271Constants, TheWonderland712, MetaTransactionReceiver {
    using SafeMathWithRequire for uint256;

    enum SignatureType {
        DIRECT,
        EIP1654,
        EIP1271
    }

    bytes32 constant AUCTION_TYPEHASH =
        keccak256(
            "Auction(address from,address token,uint256 offerId,uint256 startingPrice,uint256 endingPrice,uint256 startedAt,uint256 duration,uint256 packs,bytes ids,bytes amounts)"
        );

    event OfferClaimed(
        address indexed seller,
        address indexed buyer,
        uint256 indexed offerId,
        uint256 amount,
        uint256 pricePaid,
        uint256 feePaid
    );
    event OfferCancelled(address indexed seller, uint256 indexed offerId);

    uint256 constant MAX_UINT256 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // Stack too deep, grouping parameters
    // AuctionData:
    uint256 constant AuctionData_OfferId = 0;
    uint256 constant AuctionData_StartingPrice = 1;
    uint256 constant AuctionData_EndingPrice = 2;
    uint256 constant AuctionData_StartedAt = 3;
    uint256 constant AuctionData_Duration = 4;
    uint256 constant AuctionData_Packs = 5;

    mapping(address => mapping(uint256 => uint256)) claimed;

    Asset _asset;
    uint256 _fee10000th = 0;
    address payable _feeCollector;

    event FeeSetup(address feeCollector, uint256 fee10000th);

    constructor(
        Asset asset,
        address admin,
        address initialMetaTx,
        address payable feeCollector,
        uint256 fee10000th
    ) public {
        _asset = asset;
        _feeCollector = feeCollector;
        _fee10000th = fee10000th;
        emit FeeSetup(feeCollector, fee10000th);
        _admin = admin;
        _setMetaTransactionProcessor(initialMetaTx, true);
        init712();
    }

    /// @notice set fee parameters
    /// @param feeCollector address receiving the fee
    /// @param fee10000th fee in 10,000th
    function setFee(address payable feeCollector, uint256 fee10000th) external {
        require(msg.sender == _admin, "only admin can change fee");
        _feeCollector = feeCollector;
        _fee10000th = fee10000th;
        emit FeeSetup(feeCollector, fee10000th);
    }

    function _verifyParameters(
        address buyer,
        address payable seller,
        address token,
        uint256 buyAmount,
        uint256[] memory auctionData,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal view {
        require(ids.length == amounts.length, "ids and amounts length not matching");
        require(
            buyer == msg.sender || (token != address(0) && _metaTransactionContracts[msg.sender]),
            "not authorized"
        );
        uint256 amountAlreadyClaimed = claimed[seller][auctionData[AuctionData_OfferId]];
        require(amountAlreadyClaimed != MAX_UINT256, "Auction cancelled");

        uint256 total = amountAlreadyClaimed.add(buyAmount);
        require(total >= amountAlreadyClaimed, "overflow");
        require(total <= auctionData[AuctionData_Packs], "Buy amount exceeds sell amount");

        require(auctionData[AuctionData_StartedAt] <= block.timestamp, "Auction didn't start yet");
        require(
            auctionData[AuctionData_StartedAt].add(auctionData[AuctionData_Duration]) > block.timestamp,
            "Auction finished"
        );
    }

    /// @notice claim offer using EIP712
    /// @param buyer address paying for the offer
    /// @param seller address of the seller
    /// @param token token used for payment
    /// @param purchase buyAmount, maxTokenAmount
    /// @param auctionData offerId, startingPrice, endingPrice, startedAt, duration, packs
    /// @param ids ids of the Assets being sold
    /// @param amounts amounts of Assets per pack
    /// @param signature signature of seller
    function claimSellerOffer(
        address buyer,
        address payable seller,
        address token,
        uint256[] calldata purchase, // buyAmount, maxTokenAmount
        uint256[] calldata auctionData,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata signature
    ) external payable {
        _verifyParameters(buyer, seller, token, purchase[0], auctionData, ids, amounts);
        _ensureCorrectSigner(seller, token, auctionData, ids, amounts, signature, SignatureType.DIRECT, true);
        _executeDeal(token, purchase, buyer, seller, auctionData, ids, amounts);
    }

    /// @notice claim offer using EIP712 and EIP1271 signature verification scheme
    /// @param buyer address paying for the offer
    /// @param seller address of the seller
    /// @param token token used for payment
    /// @param purchase buyAmount, maxTokenAmount
    /// @param auctionData offerId, startingPrice, endingPrice, startedAt, duration, packs
    /// @param ids ids of the Assets being sold
    /// @param amounts amounts of Assets per pack
    /// @param signature signature of seller
    function claimSellerOfferViaEIP1271(
        address buyer,
        address payable seller,
        address token,
        uint256[] calldata purchase, // buyAmount, maxTokenAmount
        uint256[] calldata auctionData,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata signature
    ) external payable {
        _verifyParameters(buyer, seller, token, purchase[0], auctionData, ids, amounts);
        _ensureCorrectSigner(seller, token, auctionData, ids, amounts, signature, SignatureType.EIP1271, true);
        _executeDeal(token, purchase, buyer, seller, auctionData, ids, amounts);
    }

    /// @notice claim offer using EIP712 and EIP1654 signature verification scheme
    /// @param buyer address paying for the offer
    /// @param seller address of the seller
    /// @param token token used for payment
    /// @param purchase buyAmount, maxTokenAmount
    /// @param auctionData offerId, startingPrice, endingPrice, startedAt, duration, packs
    /// @param ids ids of the Assets being sold
    /// @param amounts amounts of Assets per pack
    /// @param signature signature of seller
    function claimSellerOfferViaEIP1654(
        address buyer,
        address payable seller,
        address token,
        uint256[] calldata purchase, // buyAmount, maxTokenAmount
        uint256[] calldata auctionData,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata signature
    ) external payable {
        _verifyParameters(buyer, seller, token, purchase[0], auctionData, ids, amounts);
        _ensureCorrectSigner(seller, token, auctionData, ids, amounts, signature, SignatureType.EIP1654, true);
        _executeDeal(token, purchase, buyer, seller, auctionData, ids, amounts);
    }

    /// @notice claim offer using Basic Signature
    /// @param buyer address paying for the offer
    /// @param seller address of the seller
    /// @param token token used for payment
    /// @param purchase buyAmount, maxTokenAmount
    /// @param auctionData offerId, startingPrice, endingPrice, startedAt, duration, packs
    /// @param ids ids of the Assets being sold
    /// @param amounts amounts of Assets per pack
    /// @param signature signature of seller
    function claimSellerOfferUsingBasicSig(
        address buyer,
        address payable seller,
        address token,
        uint256[] calldata purchase, // buyAmount, maxTokenAmount
        uint256[] calldata auctionData,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata signature
    ) external payable {
        _verifyParameters(buyer, seller, token, purchase[0], auctionData, ids, amounts);
        _ensureCorrectSigner(seller, token, auctionData, ids, amounts, signature, SignatureType.DIRECT, false);
        _executeDeal(token, purchase, buyer, seller, auctionData, ids, amounts);
    }

    /// @notice claim offer using Basic Signature and EIP1271 signature verification scheme
    /// @param buyer address paying for the offer
    /// @param seller address of the seller
    /// @param token token used for payment
    /// @param purchase buyAmount, maxTokenAmount
    /// @param auctionData offerId, startingPrice, endingPrice, startedAt, duration, packs
    /// @param ids ids of the Assets being sold
    /// @param amounts amounts of Assets per pack
    /// @param signature signature of seller
    function claimSellerOfferUsingBasicSigViaEIP1271(
        address buyer,
        address payable seller,
        address token,
        uint256[] calldata purchase, // buyAmount, maxTokenAmount
        uint256[] calldata auctionData,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata signature
    ) external payable {
        _verifyParameters(buyer, seller, token, purchase[0], auctionData, ids, amounts);
        _ensureCorrectSigner(seller, token, auctionData, ids, amounts, signature, SignatureType.EIP1271, false);
        _executeDeal(token, purchase, buyer, seller, auctionData, ids, amounts);
    }

    /// @notice claim offer using Basic Signature and EIP1654 signature verification scheme
    /// @param buyer address paying for the offer
    /// @param seller address of the seller
    /// @param token token used for payment
    /// @param purchase buyAmount, maxTokenAmount
    /// @param auctionData offerId, startingPrice, endingPrice, startedAt, duration, packs
    /// @param ids ids of the Assets being sold
    /// @param amounts amounts of Assets per pack
    /// @param signature signature of seller
    function claimSellerOfferUsingBasicSigViaEIP1654(
        address buyer,
        address payable seller,
        address token,
        uint256[] calldata purchase, // buyAmount, maxTokenAmount
        uint256[] calldata auctionData,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata signature
    ) external payable {
        _verifyParameters(buyer, seller, token, purchase[0], auctionData, ids, amounts);
        _ensureCorrectSigner(seller, token, auctionData, ids, amounts, signature, SignatureType.EIP1654, false);
        _executeDeal(token, purchase, buyer, seller, auctionData, ids, amounts);
    }

    function _executeDeal(
        address token,
        uint256[] memory purchase,
        address buyer,
        address payable seller,
        uint256[] memory auctionData,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal {
        uint256 offer = PriceUtil
            .calculateCurrentPrice(
                auctionData[AuctionData_StartingPrice],
                auctionData[AuctionData_EndingPrice],
                auctionData[AuctionData_Duration],
                block.timestamp.sub(auctionData[AuctionData_StartedAt])
            )
            .mul(purchase[0]);
        claimed[seller][auctionData[AuctionData_OfferId]] = claimed[seller][auctionData[AuctionData_OfferId]].add(
            purchase[0]
        );

        uint256 fee = 0;
        if (_fee10000th > 0) {
            fee = PriceUtil.calculateFee(offer, _fee10000th);
        }

        uint256 total = offer.add(fee);
        require(total <= purchase[1], "offer exceeds max amount to spend");

        if (token != address(0)) {
            require(ERC20(token).transferFrom(buyer, seller, offer), "failed to transfer token price");
            if (fee > 0) {
                require(ERC20(token).transferFrom(buyer, _feeCollector, fee), "failed to collect fee");
            }
        } else {
            require(msg.value >= total, "ETH < offer+fee");
            if (msg.value > total) {
                msg.sender.transfer(msg.value.sub(total));
            }
            seller.transfer(offer);
            if (fee > 0) {
                _feeCollector.transfer(fee);
            }
        }

        uint256[] memory packAmounts = new uint256[](amounts.length);
        for (uint256 i = 0; i < packAmounts.length; i++) {
            packAmounts[i] = amounts[i].mul(purchase[0]);
        }
        _asset.safeBatchTransferFrom(seller, buyer, ids, packAmounts, "");
        emit OfferClaimed(seller, buyer, auctionData[AuctionData_OfferId], purchase[0], offer, fee);
    }

    /// @notice cancel a offer previously signed, new offer need to use a id not used yet
    /// @param offerId offer to cancel
    function cancelSellerOffer(uint256 offerId) external {
        claimed[msg.sender][offerId] = MAX_UINT256;
        emit OfferCancelled(msg.sender, offerId);
    }

    function _ensureCorrectSigner(
        address from,
        address token,
        uint256[] memory auctionData,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory signature,
        SignatureType signatureType,
        bool eip712
    ) internal view returns (address) {
        bytes memory dataToHash;

        if (eip712) {
            dataToHash = abi.encodePacked(
                "\x19\x01",
                domainSeparator(),
                _hashAuction(from, token, auctionData, ids, amounts)
            );
        } else {
            dataToHash = _encodeBasicSignatureHash(from, token, auctionData, ids, amounts);
        }

        if (signatureType == SignatureType.EIP1271) {
            require(
                ERC1271(from).isValidSignature(dataToHash, signature) == ERC1271_MAGICVALUE,
                "invalid 1271 signature"
            );
        } else if (signatureType == SignatureType.EIP1654) {
            require(
                ERC1654(from).isValidSignature(keccak256(dataToHash), signature) == ERC1654_MAGICVALUE,
                "invalid 1654 signature"
            );
        } else {
            address signer = SigUtil.recover(keccak256(dataToHash), signature);
            require(signer == from, "signer != from");
        }
    }

    function _encodeBasicSignatureHash(
        address from,
        address token,
        uint256[] memory auctionData,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal view returns (bytes memory) {
        return
            SigUtil.prefixed(
                keccak256(
                    abi.encodePacked(
                        address(this),
                        AUCTION_TYPEHASH,
                        from,
                        token,
                        auctionData[AuctionData_OfferId],
                        auctionData[AuctionData_StartingPrice],
                        auctionData[AuctionData_EndingPrice],
                        auctionData[AuctionData_StartedAt],
                        auctionData[AuctionData_Duration],
                        auctionData[AuctionData_Packs],
                        keccak256(abi.encodePacked(ids)),
                        keccak256(abi.encodePacked(amounts))
                    )
                )
            );
    }

    function _hashAuction(
        address from,
        address token,
        uint256[] memory auctionData,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    AUCTION_TYPEHASH,
                    from,
                    token,
                    auctionData[AuctionData_OfferId],
                    auctionData[AuctionData_StartingPrice],
                    auctionData[AuctionData_EndingPrice],
                    auctionData[AuctionData_StartedAt],
                    auctionData[AuctionData_Duration],
                    auctionData[AuctionData_Packs],
                    keccak256(abi.encodePacked(ids)),
                    keccak256(abi.encodePacked(amounts))
                )
            );
    }
}

pragma solidity 0.5.9;

import "./Wonderland/erc20/ERC20ExecuteExtension.sol";
import "./Wonderland/erc20/ERC20BaseToken.sol";
import "./Wonderland/erc20/ERC20BasicApproveExtension.sol";

contract Wonderland is ERC20ExecuteExtension, ERC20BasicApproveExtension, ERC20BaseToken {
    constructor(
        address arvAdmin,
        address executionAdmin,
        address beneficiary
    ) public {
        _admin = arvAdmin;
        _executionAdmin = executionAdmin;
        _mint(beneficiary, 3000000000000000000000000000);
    }

    /// @notice A descriptive name for the tokens
    /// @return name of the tokens
    function name() public view returns (string memory) {
        return "Ariva";
    }

    /// @notice An abbreviated name for the tokens
    /// @return symbol of the tokens
    function symbol() public view returns (string memory) {
        return "ARV";
    }
}

pragma solidity 0.5.9;

import { ProxyImplementation } from "./contracts_common/BaseWithStorage/ProxyImplementation.sol";

contract TheWonderland712 is ProxyImplementation {
    bytes32 constant EIP712DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,address verifyingContract)");
    bytes32 DOMAIN_SEPARATOR;

    function init712() public phase("712") {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(EIP712DOMAIN_TYPEHASH, keccak256("The Wonderland 3D"), keccak256("1"), address(this))
        );
    }

    function domainSeparator() internal view returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }
}

pragma solidity ^0.5.2;

contract ERC1271 {

    /**
    * @dev Should return whether the signature provided is valid for the provided data
    * @param data Arbitrary length data signed on the behalf of address(this)
    * @param signature Signature byte array associated with _data
    *
    * MUST return the bytes4 magic value 0x20c13b0b when function passes.
    * MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5)
    * MUST allow external calls
    */
    function isValidSignature(bytes memory data, bytes memory signature)
        public
        view
        returns (bytes4 magicValue);
}

pragma solidity ^0.5.2;

contract ERC1271Constants {
    bytes4 internal constant ERC1271_MAGICVALUE = 0x20c13b0b;
}

pragma solidity ^0.5.2;

contract ERC1654 {

    /**
    * @dev Should return whether the signature provided is valid for the provided hash
    * @param hash 32 bytes hash to be signed
    * @param signature Signature byte array associated with hash
    * @return 0x1626ba7e if valid else 0x00000000
    */
    function isValidSignature(bytes32 hash, bytes memory signature)
        public
        view
        returns (bytes4 magicValue);
}

pragma solidity ^0.5.2;

contract ERC1654Constants {
    bytes4 internal constant ERC1654_MAGICVALUE = 0x1626ba7e;
}

pragma solidity 0.5.9;

contract ERC20ExecuteExtension {
    /// @dev _executionAdmin != _admin so that this super power can be disabled independently
    address internal _executionAdmin;

    event ExecutionAdminAdminChanged(address oldAdmin, address newAdmin);

    /// @notice give the address responsible for adding execution rights.
    /// @return address of the execution administrator.
    function getExecutionAdmin() external view returns (address) {
        return _executionAdmin;
    }

    /// @notice change the execution adminstrator to be `newAdmin`.
    /// @param newAdmin address of the new administrator.
    function changeExecutionAdmin(address newAdmin) external {
        require(msg.sender == _executionAdmin, "only executionAdmin can change executionAdmin");
        emit ExecutionAdminAdminChanged(_executionAdmin, newAdmin);
        _executionAdmin = newAdmin;
    }

    mapping(address => bool) internal _executionOperators;
    event ExecutionOperator(address executionOperator, bool enabled);

    /// @notice set `executionOperator` as executionOperator: `enabled`.
    /// @param executionOperator address that will be given/removed executionOperator right.
    /// @param enabled set whether the executionOperator is enabled or disabled.
    function setExecutionOperator(address executionOperator, bool enabled) external {
        require(msg.sender == _executionAdmin, "only execution admin is allowed to add execution operators");
        _executionOperators[executionOperator] = enabled;
        emit ExecutionOperator(executionOperator, enabled);
    }

    /// @notice check whether address `who` is given executionOperator rights.
    /// @param who The address to query.
    /// @return whether the address has executionOperator rights.
    function isExecutionOperator(address who) public view returns (bool) {
        return _executionOperators[who];
    }

    /// @notice execute on behalf of the contract.
    /// @param to destination address fo the call.
    /// @param gasLimit exact amount of gas to be passed to the call.
    /// @param data the bytes sent to the destination address.
    /// @return success whether the execution was successful.
    /// @return returnData data resulting from the execution.
    function executeWithSpecificGas(
        address to,
        uint256 gasLimit,
        bytes calldata data
    ) external returns (bool success, bytes memory returnData) {
        require(_executionOperators[msg.sender], "only execution operators allowed to execute on ARV behalf");
        (success, returnData) = to.call.gas(gasLimit)(data);
        assert(gasleft() > gasLimit / 63); // not enough gas provided, assert to throw all gas // TODO use EIP-1930
    }

    /// @notice approve a specific amount of token for `from` and execute on behalf of the contract.
    /// @param from address of which token will be transfered.
    /// @param to destination address fo the call.
    /// @param amount number of tokens allowed that can be transfer by the code at `to`.
    /// @param gasLimit exact amount of gas to be passed to the call.
    /// @param data the bytes sent to the destination address.
    /// @return success whether the execution was successful.
    /// @return returnData data resulting from the execution.
    function approveAndExecuteWithSpecificGas(
        address from,
        address to,
        uint256 amount,
        uint256 gasLimit,
        bytes calldata data
    ) external returns (bool success, bytes memory returnData) {
        require(_executionOperators[msg.sender], "only execution operators allowed to execute on ARV behalf");
        return _approveAndExecuteWithSpecificGas(from, to, amount, gasLimit, data);
    }

    /// @dev the reason for this function is that charging for gas here is more gas-efficient than doing it in the caller.
    /// @notice approve a specific amount of token for `from` and execute on behalf of the contract. Plus charge the gas required to perform it.
    /// @param from address of which token will be transfered.
    /// @param to destination address fo the call.
    /// @param amount number of tokens allowed that can be transfer by the code at `to`.
    /// @param gasLimit exact amount of gas to be passed to the call.
    /// @param tokenGasPrice price in token for the gas to be charged.
    /// @param baseGasCharge amount of gas charged on top of the gas used for the call.
    /// @param tokenReceiver recipient address of the token charged for the gas used.
    /// @param data the bytes sent to the destination address.
    /// @return success whether the execution was successful.
    /// @return returnData data resulting from the execution.
    function approveAndExecuteWithSpecificGasAndChargeForIt(
        address from,
        address to,
        uint256 amount,
        uint256 gasLimit,
        uint256 tokenGasPrice,
        uint256 baseGasCharge,
        address tokenReceiver,
        bytes calldata data
    ) external returns (bool success, bytes memory returnData) {
        uint256 initialGas = gasleft();
        require(_executionOperators[msg.sender], "only execution operators allowed to execute on ARV behalf");
        (success, returnData) = _approveAndExecuteWithSpecificGas(from, to, amount, gasLimit, data);
        if (tokenGasPrice > 0) {
            _charge(from, gasLimit, tokenGasPrice, initialGas, baseGasCharge, tokenReceiver);
        }
    }

    /// @notice transfer 1amount1 token from `from` to `to` and charge the gas required to perform that transfer.
    /// @param from address of which token will be transfered.
    /// @param to destination address fo the call.
    /// @param amount number of tokens allowed that can be transfer by the code at `to`.
    /// @param gasLimit exact amount of gas to be passed to the call.
    /// @param tokenGasPrice price in token for the gas to be charged.
    /// @param baseGasCharge amount of gas charged on top of the gas used for the call.
    /// @param tokenReceiver recipient address of the token charged for the gas used.
    /// @return whether the transfer was successful.
    function transferAndChargeForGas(
        address from,
        address to,
        uint256 amount,
        uint256 gasLimit,
        uint256 tokenGasPrice,
        uint256 baseGasCharge,
        address tokenReceiver
    ) external returns (bool) {
        uint256 initialGas = gasleft();
        require(_executionOperators[msg.sender], "only execution operators allowed to perfrom transfer and charge");
        _transfer(from, to, amount);
        if (tokenGasPrice > 0) {
            _charge(from, gasLimit, tokenGasPrice, initialGas, baseGasCharge, tokenReceiver);
        }
        return true;
    }

    function _charge(
        address from,
        uint256 gasLimit,
        uint256 tokenGasPrice,
        uint256 initialGas,
        uint256 baseGasCharge,
        address tokenReceiver
    ) internal {
        uint256 gasCharge = initialGas - gasleft();
        if (gasCharge > gasLimit) {
            gasCharge = gasLimit;
        }
        gasCharge += baseGasCharge;
        uint256 tokensToCharge = gasCharge * tokenGasPrice;
        require(tokensToCharge / gasCharge == tokenGasPrice, "overflow");
        _transfer(from, tokenReceiver, tokensToCharge);
    }

    function _approveAndExecuteWithSpecificGas(
        address from,
        address to,
        uint256 amount,
        uint256 gasLimit,
        bytes memory data
    ) internal returns (bool success, bytes memory returnData) {
        if (amount > 0) {
            _addAllowanceIfNeeded(from, to, amount);
        }
        (success, returnData) = to.call.gas(gasLimit)(data);
        assert(gasleft() > gasLimit / 63); // not enough gas provided, assert to throw all gas // TODO use EIP-1930
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal;

    function _addAllowanceIfNeeded(
        address owner,
        address spender,
        uint256 amountNeeded
    ) internal;
}

pragma solidity 0.5.9;

import "../../contracts_common/Interfaces/ERC20Events.sol";
import "../../contracts_common/BaseWithStorage/SuperOperators.sol";

contract ERC20BaseToken is SuperOperators, ERC20Events {

    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    /// @notice Gets the total number of tokens in existence.
    /// @return the total number of tokens in existence.
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /// @notice Gets the balance of `owner`.
    /// @param owner The address to query the balance of.
    /// @return The amount owned by `owner`.
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /// @notice gets allowance of `spender` for `owner`'s tokens.
    /// @param owner address whose token is allowed.
    /// @param spender address allowed to transfer.
    /// @return the amount of token `spender` is allowed to transfer on behalf of `owner`.
    function allowance(address owner, address spender)
        public
        view
        returns (uint256 remaining)
    {
        return _allowances[owner][spender];
    }

    /// @notice returns the number of decimals for that token.
    /// @return the number of decimals.
    function decimals() public view returns (uint8) {
        return uint8(18);
    }

    /// @notice Transfer `amount` tokens to `to`.
    /// @param to the recipient address of the tokens transfered.
    /// @param amount the number of tokens transfered.
    /// @return true if success.
    function transfer(address to, uint256 amount)
        public
        returns (bool success)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice Transfer `amount` tokens from `from` to `to`.
    /// @param from whose token it is transferring from.
    /// @param to the recipient address of the tokens transfered.
    /// @param amount the number of tokens transfered.
    /// @return true if success.
    function transferFrom(address from, address to, uint256 amount)
        public
        returns (bool success)
    {
        if (msg.sender != from && !_superOperators[msg.sender]) {
            uint256 currentAllowance = _allowances[from][msg.sender];
            if (currentAllowance != (2**256) - 1) {
                // save gas when allowance is maximal by not reducing it (see https://github.com/ethereum/EIPs/issues/717)
                require(currentAllowance >= amount, "Not enough funds allowed");
                _allowances[from][msg.sender] = currentAllowance - amount;
            }
        }
        _transfer(from, to, amount);
        return true;
    }

    /// @notice burn `amount` tokens.
    /// @param amount the number of tokens to burn.
    /// @return true if success.
    function burn(uint256 amount) external returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }

    /// @notice burn `amount` tokens from `owner`.
    /// @param owner address whose token is to burn.
    /// @param amount the number of token to burn.
    /// @return true if success.
    function burnFor(address owner, uint256 amount) external returns (bool) {
        _burn(owner, amount);
        return true;
    }

    /// @notice approve `spender` to transfer `amount` tokens.
    /// @param spender address to be given rights to transfer.
    /// @param amount the number of tokens allowed.
    /// @return true if success.
    function approve(address spender, uint256 amount)
        public
        returns (bool success)
    {
        _approveFor(msg.sender, spender, amount);
        return true;
    }

    /// @notice approve `spender` to transfer `amount` tokens from `owner`.
    /// @param owner address whose token is allowed.
    /// @param spender  address to be given rights to transfer.
    /// @param amount the number of tokens allowed.
    /// @return true if success.
    function approveFor(address owner, address spender, uint256 amount)
        public
        returns (bool success)
    {
        require(
            msg.sender == owner || _superOperators[msg.sender],
            "msg.sender != owner && !superOperator"
        );
        _approveFor(owner, spender, amount);
        return true;
    }

    function addAllowanceIfNeeded(address owner, address spender, uint256 amountNeeded)
        public
        returns (bool success)
    {
        require(
            msg.sender == owner || _superOperators[msg.sender],
            "msg.sender != owner && !superOperator"
        );
        _addAllowanceIfNeeded(owner, spender, amountNeeded);
        return true;
    }

    function _addAllowanceIfNeeded(address owner, address spender, uint256 amountNeeded)
        internal
    {
        if(amountNeeded > 0 && !isSuperOperator(spender)) {
            uint256 currentAllowance = _allowances[owner][spender];
            if(currentAllowance < amountNeeded) {
                _approveFor(owner, spender, amountNeeded);
            }
        }
    }

    function _approveFor(address owner, address spender, uint256 amount)
        internal
    {
        require(
            owner != address(0) && spender != address(0),
            "Cannot approve with 0x0"
        );
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Cannot send to 0x0");
        uint256 currentBalance = _balances[from];
        require(currentBalance >= amount, "not enough fund");
        _balances[from] = currentBalance - amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Cannot mint to 0x0");
        require(amount > 0, "cannot mint 0 tokens");
        uint256 currentTotalSupply = _totalSupply;
        uint256 newTotalSupply = currentTotalSupply + amount;
        require(newTotalSupply > currentTotalSupply, "overflow");
        _totalSupply = newTotalSupply;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(amount > 0, "cannot burn 0 tokens");
        if (msg.sender != from && !_superOperators[msg.sender]) {
            uint256 currentAllowance = _allowances[from][msg.sender];
            require(
                currentAllowance >= amount,
                "Not enough funds allowed"
            );
            if (currentAllowance != (2**256) - 1) {
                // save gas when allowance is maximal by not reducing it (see https://github.com/ethereum/EIPs/issues/717)
                _allowances[from][msg.sender] = currentAllowance - amount;
            }
        }

        uint256 currentBalance = _balances[from];
        require(currentBalance >= amount, "Not enough funds");
        _balances[from] = currentBalance - amount;
        _totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }
}

pragma solidity 0.5.9;

import "../../contracts_common/Libraries/BytesUtil.sol";

contract ERC20BasicApproveExtension {

    /// @notice approve `target` to spend `amount` and call it with data.
    /// @param target address to be given rights to transfer and destination of the call.
    /// @param amount the number of tokens allowed.
    /// @param data bytes for the call.
    /// @return data of the call.
    function approveAndCall(
        address target,
        uint256 amount,
        bytes calldata data
    ) external payable returns (bytes memory) {
        require(
            BytesUtil.doFirstParamEqualsAddress(data, msg.sender),
            "first param != sender"
        );

        _approveFor(msg.sender, target, amount);

        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call.value(msg.value)(data);
        require(success, string(returnData));
        return returnData;
    }

    /// @notice temporarly approve `target` to spend `amount` and call it with data. Previous approvals remains unchanged.
    /// @param target destination of the call, allowed to spend the amount specified
    /// @param amount the number of tokens allowed to spend.
    /// @param data bytes for the call.
    /// @return data of the call.
    function paidCall(
        address target,
        uint256 amount,
        bytes calldata data
    ) external payable returns (bytes memory) {
        require(
            BytesUtil.doFirstParamEqualsAddress(data, msg.sender),
            "first param != sender"
        );

        if (amount > 0) {
            _addAllowanceIfNeeded(msg.sender, target, amount);
        }

        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call.value(msg.value)(data);
        require(success, string(returnData));

        return returnData;
    }

    function _approveFor(address owner, address target, uint256 amount) internal;
    function _addAllowanceIfNeeded(address owner, address spender, uint256 amountNeeded) internal;
}

pragma solidity ^0.5.2;

/* interface */
contract ERC20Events {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity ^0.5.2;

library BytesUtil {
    function memcpy(uint256 dest, uint256 src, uint256 len) internal pure {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint256 mask = 256**(32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function pointerToBytes(uint256 src, uint256 len)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory ret = new bytes(len);
        uint256 retptr;
        assembly {
            retptr := add(ret, 32)
        }

        memcpy(retptr, src, len);
        return ret;
    }

    function addressToBytes(address a) internal pure returns (bytes memory b) {
        assembly {
            let m := mload(0x40)
            mstore(
                add(m, 20),
                xor(0x140000000000000000000000000000000000000000, a)
            )
            mstore(0x40, add(m, 52))
            b := m
        }
    }

    function uint256ToBytes(uint256 a) internal pure returns (bytes memory b) {
        assembly {
            let m := mload(0x40)
            mstore(add(m, 32), a)
            mstore(0x40, add(m, 64))
            b := m
        }
    }

    function doFirstParamEqualsAddress(bytes memory data, address _address)
        internal
        pure
        returns (bool)
    {
        if (data.length < (36 + 32)) {
            return false;
        }
        uint256 value;
        assembly {
            value := mload(add(data, 36))
        }
        return value == uint256(_address);
    }

    function doParamEqualsUInt256(bytes memory data, uint256 i, uint256 value)
        internal
        pure
        returns (bool)
    {
        if (data.length < (36 + (i + 1) * 32)) {
            return false;
        }
        uint256 offset = 36 + i * 32;
        uint256 valuePresent;
        assembly {
            valuePresent := mload(add(data, offset))
        }
        return valuePresent == value;
    }

    function overrideFirst32BytesWithAddress(
        bytes memory data,
        address _address
    ) internal pure returns (bytes memory) {
        uint256 dest;
        assembly {
            dest := add(data, 48)
        } // 48 = 32 (offset) + 4 (func sig) + 12 (address is only 20 bytes)

        bytes memory addressBytes = addressToBytes(_address);
        uint256 src;
        assembly {
            src := add(addressBytes, 32)
        }

        memcpy(dest, src, 20);
        return data;
    }

    function overrideFirstTwo32BytesWithAddressAndInt(
        bytes memory data,
        address _address,
        uint256 _value
    ) internal pure returns (bytes memory) {
        uint256 dest;
        uint256 src;

        assembly {
            dest := add(data, 48)
        } // 48 = 32 (offset) + 4 (func sig) + 12 (address is only 20 bytes)
        bytes memory bbytes = addressToBytes(_address);
        assembly {
            src := add(bbytes, 32)
        }
        memcpy(dest, src, 20);

        assembly {
            dest := add(data, 68)
        } // 48 = 32 (offset) + 4 (func sig) + 32 (next slot)
        bbytes = uint256ToBytes(_value);
        assembly {
            src := add(bbytes, 32)
        }
        memcpy(dest, src, 32);

        return data;
    }
}

pragma solidity ^0.5.2;

contract ProxyImplementation {
    mapping(string => bool) _initialised;

    modifier phase(string memory phaseName) {
        if (!_initialised[phaseName]) {
            _initialised[phaseName] = true;
            _;
        }
    }
}

pragma solidity 0.5.9;

import "../contracts_common/Interfaces/ERC1654.sol";
import "../contracts_common/Interfaces/ERC1654Constants.sol";
import "../contracts_common/Libraries/SigUtil.sol";

contract ERC1654Wallet is ERC1654, ERC1654Constants {
    address owner;
    mapping(address => bool) authorizedSigners;

    constructor(address _signer) public {
        owner = msg.sender;
        authorizedSigners[_signer] = true;
    }

    function isValidSignature(bytes32 _hash, bytes memory _signature)
        public
        view
        returns (bytes4 magicValue)
    {
        address signer = SigUtil.recoverWithZeroOnFailure(
            _hash,
            _signature
        );
        if (authorizedSigners[signer]) {
            return ERC1654_MAGICVALUE;
        }
    }
}

pragma solidity 0.5.9;

import "../contracts_common/Interfaces/ERC1271.sol";
import "../contracts_common/Interfaces/ERC1271Constants.sol";
import "../contracts_common/Libraries/SigUtil.sol";

contract ERC1271WalletWithERC1155Receiver is ERC1271, ERC1271Constants {
    bytes4 private constant ERC1155_RECEIVED = 0xf23a6e61;
    bytes4 private constant ERC1155_BATCH_RECEIVED = 0xbc197c81;

    address owner;
    mapping(address => bool) authorizedSigners;

    constructor(address _signer) public {
        owner = msg.sender;
        authorizedSigners[_signer] = true;
    }

    function isValidSignature(bytes memory _data, bytes memory _signature)
        public
        view
        returns (bytes4 magicValue)
    {
        address signer = SigUtil.recoverWithZeroOnFailure(
            keccak256(_data),
            _signature
        );
        if (authorizedSigners[signer]) {
            return ERC1271_MAGICVALUE;
        }
    }

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external returns (bytes4) {
        return ERC1155_RECEIVED;
    }

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external returns (bytes4) {
        return ERC1155_BATCH_RECEIVED;
    }
}

pragma solidity 0.5.9;

import "../contracts_common/Interfaces/ERC1271.sol";
import "../contracts_common/Interfaces/ERC1271Constants.sol";
import "../contracts_common/Libraries/SigUtil.sol";

contract ERC1271Wallet is ERC1271, ERC1271Constants {
    address owner;
    mapping(address => bool) authorizedSigners;

    constructor(address _signer) public {
        owner = msg.sender;
        authorizedSigners[_signer] = true;
    }

    function isValidSignature(bytes memory _data, bytes memory _signature)
        public
        view
        returns (bytes4 magicValue)
    {
        address signer = SigUtil.recoverWithZeroOnFailure(
            keccak256(_data),
            _signature
        );
        if (authorizedSigners[signer]) {
            return ERC1271_MAGICVALUE;
        }
    }
}

pragma solidity 0.5.9;

import "../LandBsc.sol";
import "../contracts_common/Interfaces/ERC20.sol";
import "../contracts_common/BaseWithStorage/MetaTransactionReceiver.sol";

contract HayLandSale is MetaTransactionReceiver {
    uint256 internal constant GRID_SIZE = 1562;

    LandBsc internal _land;
    ERC20 internal _hay;
    address payable internal _wallet;

    uint256 _startTime;

    mapping(bytes32 => uint256) private _prices;

    event LandQuadPurchased(
        address indexed buyer,
        address indexed to,
        uint256 indexed topCornerId,
        uint256 size,
        uint256 price
    );

    constructor(
        address landAddress,
        address hayContractAddress,
        address initialMetaTx,
        address admin,
        address payable initialWalletAddress,
        uint256 sTime
    ) public {
        require(sTime > block.timestamp, "Invalid");

        _land = LandBsc(landAddress);
        _hay = ERC20(hayContractAddress);
        _setMetaTransactionProcessor(initialMetaTx, true);
        _admin = admin;
        _wallet = initialWalletAddress;
        _startTime = sTime;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "only admin");

        _;
    }

    /// @notice set the wallet receiving the proceeds
    /// @param newWallet address of the new receiving wallet
    function setReceivingWallet(address payable newWallet) external onlyAdmin {
        require(newWallet != address(0), "receiving wallet cannot be zero address");
        _wallet = newWallet;
    }

    function setSellQuad(
        uint256 x,
        uint256 y,
        uint256 size,
        uint256 price
    ) external onlyAdmin {
        bytes32 hash = _generateLandHash(x, y, size);
        _prices[hash] = price;
    }

    function setSellQuads(
        uint256[] calldata xs,
        uint256[] calldata ys,
        uint256[] calldata sizes,
        uint256[] calldata prices
    ) external onlyAdmin {
        require(xs.length == ys.length && ys.length == sizes.length && sizes.length == prices.length, "Invalid params");

        for (uint256 index = 0; index < xs.length; index++) {
            uint256 x = xs[index];
            uint256 y = ys[index];
            uint256 size = sizes[index];

            bytes32 hash = _generateLandHash(x, y, size);
            _prices[hash] = prices[index];
        }
    }

    /**
     * @notice buy Land using the merkle proof associated with it
     * @param buyer address that perform the payment
     * @param to address that will own the purchased Land
     * @param x x coordinate of the Land
     * @param y y coordinate of the Land
     * @param size size of the pack of Land to purchase
     * @return The address of the operator
     */
    function buyLand(
        address buyer,
        address to,
        uint256 x,
        uint256 y,
        uint256 size
    ) external {
        require(_startTime < block.timestamp, "Sale is not started");
        /* solhint-disable-next-line not-rely-on-time */
        require(buyer == msg.sender || _metaTransactionContracts[msg.sender], "not authorized");

        bytes32 hash = _generateLandHash(x, y, size);
        uint256 price = _prices[hash];
        require(price > 0, "Not on sale");

        require(_hay.transferFrom(buyer, _wallet, price), "arv transfer failed");

        _land.transferQuad(address(this), to, size, x, y, "");

        delete _prices[hash];
        emit LandQuadPurchased(buyer, to, x + (y * GRID_SIZE), size, price);
    }

    function withdrawQuad(
        uint256 x,
        uint256 y,
        uint256 size
    ) external onlyAdmin {
        _land.transferQuad(address(this), msg.sender, size, x, y, "");
    }

    function getPrice(
        uint256 x,
        uint256 y,
        uint256 size
    ) external view returns (uint256) {
        bytes32 hash = _generateLandHash(x, y, size);
        return _prices[hash];
    }

    function getPrices(
        uint256[] calldata xs,
        uint256[] calldata ys,
        uint256[] calldata sizes
    ) external view returns (uint256[] memory) {
        require(xs.length == ys.length && ys.length == sizes.length, "Invalid params");

        uint256[] memory prices = new uint256[](xs.length);

        for (uint256 index = 0; index < xs.length; index++) {
            bytes32 hash = _generateLandHash(xs[index], ys[index], sizes[index]);
            prices[index] = _prices[hash];
        }
        return prices;
    }

    function _generateLandHash(
        uint256 x,
        uint256 y,
        uint256 size
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(x, y, size));
    }

    function startTime() external view returns (uint256) {
        return _startTime;
    }

    function setStartTime(uint256 sTime) external onlyAdmin {
        require(sTime > block.timestamp, "Invalid");
        _startTime = sTime;
    }
}

/* solhint-disable no-empty-blocks */

pragma solidity 0.5.9;

import "./Land/erc721/LandBaseToken.sol";

contract LandBsc is LandBaseToken {
    constructor(address metaTransactionContract, address admin) public LandBaseToken(metaTransactionContract, admin) {}

    /**
     * @notice Return the name of the token contract
     * @return The name of the token contract
     */
    function name() external pure returns (string memory) {
        return "Ariva Wonderland";
    }

    /**
     * @notice Return the symbol of the token contract
     * @return The symbol of the token contract
     */
    function symbol() external pure returns (string memory) {
        return "ARWL";
    }

    // solium-disable-next-line security/no-assign-params
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    /**
     * @notice Return the URI of a specific token
     * @param id The id of the token
     * @return The URI of the token
     */
    function tokenURI(uint256 id) public view returns (string memory) {
        require(_ownerOf(id) != address(0), "Id does not exist");

        return
            string(
                abi.encodePacked(
                    "https://api.ariva.game/lands/bsc/",
                    uint2str(id),
                    "/metadata.json"
                )
            );
    }

    /**
     * @notice Check if the contract supports an interface
     * 0x01ffc9a7 is ERC-165
     * 0x80ac58cd is ERC-721
     * 0x5b5e139f is ERC-721 metadata
     * @param id The id of the interface
     * @return True if the interface is supported
     */
    function supportsInterface(bytes4 id) external pure returns (bool) {
        return id == 0x01ffc9a7 || id == 0x80ac58cd || id == 0x5b5e139f;
    }
}

/* solhint-disable func-order, code-complexity */
pragma solidity 0.5.9;

import "./ERC721BaseToken.sol";

contract LandBaseToken is ERC721BaseToken {
    // Our grid is 1562 x 1562 lands
    uint256 internal constant GRID_SIZE = 1562;

    uint256 internal constant LAYER = 0xFF00000000000000000000000000000000000000000000000000000000000000;
    uint256 internal constant LAYER_1x1 = 0x0000000000000000000000000000000000000000000000000000000000000000;
    uint256 internal constant LAYER_3x3 = 0x0100000000000000000000000000000000000000000000000000000000000000;
    uint256 internal constant LAYER_6x6 = 0x0200000000000000000000000000000000000000000000000000000000000000;
    uint256 internal constant LAYER_12x12 = 0x0300000000000000000000000000000000000000000000000000000000000000;
    uint256 internal constant LAYER_24x24 = 0x0400000000000000000000000000000000000000000000000000000000000000;

    mapping(address => bool) internal _minters;
    event Minter(address superOperator, bool enabled);

    /// @notice Enable or disable the ability of `minter` to mint tokens
    /// @param minter address that will be given/removed minter right.
    /// @param enabled set whether the minter is enabled or disabled.
    function setMinter(address minter, bool enabled) external {
        require(msg.sender == _admin, "only admin is allowed to add minters");
        _minters[minter] = enabled;
        emit Minter(minter, enabled);
    }

    /// @notice check whether address `who` is given minter rights.
    /// @param who The address to query.
    /// @return whether the address has minter rights.
    function isMinter(address who) public view returns (bool) {
        return _minters[who];
    }

    constructor(address metaTransactionContract, address admin)
        public
        ERC721BaseToken(metaTransactionContract, admin)
    {}

    /// @notice total width of the map
    /// @return width
    function width() external returns (uint256) {
        return GRID_SIZE;
    }

    /// @notice total height of the map
    /// @return height
    function height() external returns (uint256) {
        return GRID_SIZE;
    }

    /// @notice x coordinate of Land token
    /// @param id tokenId
    /// @return the x coordinates
    function x(uint256 id) external returns (uint256) {
        require(_ownerOf(id) != address(0), "token does not exist");
        return id % GRID_SIZE;
    }

    /// @notice y coordinate of Land token
    /// @param id tokenId
    /// @return the y coordinates
    function y(uint256 id) external returns (uint256) {
        require(_ownerOf(id) != address(0), "token does not exist");
        return id / GRID_SIZE;
    }

    /**
     * @notice Mint a new quad (aligned to a quad tree with size 3, 6, 12 or 24 only)
     * @param to The recipient of the new quad
     * @param size The size of the new quad
     * @param x The top left x coordinate of the new quad
     * @param y The top left y coordinate of the new quad
     * @param data extra data to pass to the transfer
     */
    function mintQuad(
        address to,
        uint256 size,
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external {
        require(to != address(0), "to is zero address");
        require(isMinter(msg.sender), "Only a minter can mint");
        require(x <= GRID_SIZE - size && y <= GRID_SIZE - size, "Out of bounds");

        uint256 quadId;
        uint256 id = x + y * GRID_SIZE;

        if (size == 1) {
            quadId = id;
        } else if (size == 3) {
            quadId = LAYER_3x3 + id;
        } else if (size == 6) {
            quadId = LAYER_6x6 + id;
        } else if (size == 12) {
            quadId = LAYER_12x12 + id;
        } else if (size == 24) {
            quadId = LAYER_24x24 + id;
        } else {
            require(false, "Invalid size");
        }

        require(_owners[LAYER_24x24 + (x / 24) * 24 + ((y / 24) * 24) * GRID_SIZE] == 0, "Already minted as 24x24");

        uint256 toX = x + size;
        uint256 toY = y + size;
        if (size <= 12) {
            require(_owners[LAYER_12x12 + (x / 12) * 12 + ((y / 12) * 12) * GRID_SIZE] == 0, "Already minted as 12x12");
        } else {
            for (uint256 x12i = x; x12i < toX; x12i += 12) {
                for (uint256 y12i = y; y12i < toY; y12i += 12) {
                    uint256 id12x12 = LAYER_12x12 + x12i + y12i * GRID_SIZE;
                    require(_owners[id12x12] == 0, "Already minted as 12x12");
                }
            }
        }

        if (size <= 6) {
            require(_owners[LAYER_6x6 + (x / 6) * 6 + ((y / 6) * 6) * GRID_SIZE] == 0, "Already minted as 6x6");
        } else {
            for (uint256 x6i = x; x6i < toX; x6i += 6) {
                for (uint256 y6i = y; y6i < toY; y6i += 6) {
                    uint256 id6x6 = LAYER_6x6 + x6i + y6i * GRID_SIZE;
                    require(_owners[id6x6] == 0, "Already minted as 6x6");
                }
            }
        }

        if (size <= 3) {
            require(_owners[LAYER_3x3 + (x / 3) * 3 + ((y / 3) * 3) * GRID_SIZE] == 0, "Already minted as 3x3");
        } else {
            for (uint256 x3i = x; x3i < toX; x3i += 3) {
                for (uint256 y3i = y; y3i < toY; y3i += 3) {
                    uint256 id3x3 = LAYER_3x3 + x3i + y3i * GRID_SIZE;
                    require(_owners[id3x3] == 0, "Already minted as 3x3");
                }
            }
        }

        for (uint256 i = 0; i < size * size; i++) {
            uint256 id = _idInPath(i, size, x, y);
            require(_owners[id] == 0, "Already minted");
            emit Transfer(address(0), to, id);
        }

        _owners[quadId] = uint256(to);
        _numNFTPerAddress[to] += size * size;

        _checkBatchReceiverAcceptQuad(msg.sender, address(0), to, size, x, y, data);
    }

    function _idInPath(
        uint256 i,
        uint256 size,
        uint256 x,
        uint256 y
    ) internal pure returns (uint256) {
        uint256 row = i / size;
        if (row % 2 == 0) {
            // alow ids to follow a path in a quad
            return (x + (i % size)) + ((y + row) * GRID_SIZE);
        } else {
            return ((x + size) - (1 + (i % size))) + ((y + row) * GRID_SIZE);
        }
    }

    /// @notice transfer one quad (aligned to a quad tree with size 3, 6, 12 or 24 only)
    /// @param from current owner of the quad
    /// @param to destination
    /// @param size size of the quad
    /// @param x The top left x coordinate of the quad
    /// @param y The top left y coordinate of the quad
    /// @param data additional data
    function transferQuad(
        address from,
        address to,
        uint256 size,
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external {
        require(from != address(0), "from is zero address");
        require(to != address(0), "can't send to zero address");
        bool metaTx = msg.sender != from && _metaTransactionContracts[msg.sender];
        if (msg.sender != from && !metaTx) {
            require(
                _superOperators[msg.sender] || _operatorsForAll[from][msg.sender],
                "not authorized to transferQuad"
            );
        }
        _transferQuad(from, to, size, x, y);
        _numNFTPerAddress[from] -= size * size;
        _numNFTPerAddress[to] += size * size;

        _checkBatchReceiverAcceptQuad(metaTx ? from : msg.sender, from, to, size, x, y, data);
    }

    function _checkBatchReceiverAcceptQuad(
        address operator,
        address from,
        address to,
        uint256 size,
        uint256 x,
        uint256 y,
        bytes memory data
    ) internal {
        if (to.isContract() && _checkInterfaceWith10000Gas(to, ERC721_MANDATORY_RECEIVER)) {
            uint256[] memory ids = new uint256[](size * size);
            for (uint256 i = 0; i < size * size; i++) {
                ids[i] = _idInPath(i, size, x, y);
            }
            require(_checkOnERC721BatchReceived(operator, from, to, ids, data), "erc721 batch transfer rejected by to");
        }
    }

    /// @notice transfer multiple quad (aligned to a quad tree with size 3, 6, 12 or 24 only)
    /// @param from current owner of the quad
    /// @param to destination
    /// @param sizes list of sizes for each quad
    /// @param xs list of top left x coordinates for each quad
    /// @param ys list of top left y coordinates for each quad
    /// @param data additional data
    function batchTransferQuad(
        address from,
        address to,
        uint256[] calldata sizes,
        uint256[] calldata xs,
        uint256[] calldata ys,
        bytes calldata data
    ) external {
        require(from != address(0), "from is zero address");
        require(to != address(0), "can't send to zero address");
        require(sizes.length == xs.length && xs.length == ys.length, "invalid data");
        bool metaTx = msg.sender != from && _metaTransactionContracts[msg.sender];
        if (msg.sender != from && !metaTx) {
            require(
                _superOperators[msg.sender] || _operatorsForAll[from][msg.sender],
                "not authorized to transferMultiQuads"
            );
        }
        uint256 numTokensTransfered = 0;
        for (uint256 i = 0; i < sizes.length; i++) {
            uint256 size = sizes[i];
            _transferQuad(from, to, size, xs[i], ys[i]);
            numTokensTransfered += size * size;
        }
        _numNFTPerAddress[from] -= numTokensTransfered;
        _numNFTPerAddress[to] += numTokensTransfered;

        if (to.isContract() && _checkInterfaceWith10000Gas(to, ERC721_MANDATORY_RECEIVER)) {
            uint256[] memory ids = new uint256[](numTokensTransfered);
            uint256 counter = 0;
            for (uint256 j = 0; j < sizes.length; j++) {
                uint256 size = sizes[j];
                for (uint256 i = 0; i < size * size; i++) {
                    ids[counter] = _idInPath(i, size, xs[j], ys[j]);
                    counter++;
                }
            }
            require(
                _checkOnERC721BatchReceived(metaTx ? from : msg.sender, from, to, ids, data),
                "erc721 batch transfer rejected by to"
            );
        }
    }

    function _transferQuad(
        address from,
        address to,
        uint256 size,
        uint256 x,
        uint256 y
    ) internal {
        if (size == 1) {
            uint256 id1x1 = x + y * GRID_SIZE;
            address owner = _ownerOf(id1x1);
            require(owner != address(0), "token does not exist");
            require(owner == from, "not owner in _transferQuad");
            _owners[id1x1] = uint256(to);
        } else {
            _regroup(from, to, size, x, y);
        }
        for (uint256 i = 0; i < size * size; i++) {
            emit Transfer(from, to, _idInPath(i, size, x, y));
        }
    }

    function _checkAndClear(address from, uint256 id) internal returns (bool) {
        uint256 owner = _owners[id];
        if (owner != 0) {
            require(address(owner) == from, "not owner");
            _owners[id] = 0;
            return true;
        }
        return false;
    }

    function _regroup(
        address from,
        address to,
        uint256 size,
        uint256 x,
        uint256 y
    ) internal {
        require(x <= GRID_SIZE - size && y <= GRID_SIZE - size, "Out of bounds");

        if (size == 3) {
            _regroup3x3(from, to, x, y, true);
        } else if (size == 6) {
            _regroup6x6(from, to, x, y, true);
        } else if (size == 12) {
            _regroup12x12(from, to, x, y, true);
        } else if (size == 24) {
            _regroup24x24(from, to, x, y, true);
        } else {
            require(false, "Invalid size");
        }
    }

    function _regroup3x3(
        address from,
        address to,
        uint256 x,
        uint256 y,
        bool set
    ) internal returns (bool) {
        uint256 id = x + y * GRID_SIZE;
        uint256 quadId = LAYER_3x3 + id;
        bool ownerOfAll = true;
        for (uint256 xi = x; xi < x + 3; xi++) {
            for (uint256 yi = y; yi < y + 3; yi++) {
                ownerOfAll = _checkAndClear(from, xi + yi * GRID_SIZE) && ownerOfAll;
            }
        }
        if (set) {
            if (!ownerOfAll) {
                require(
                    _owners[quadId] == uint256(from) ||
                        _owners[LAYER_6x6 + (x / 6) * 6 + ((y / 6) * 6) * GRID_SIZE] == uint256(from) ||
                        _owners[LAYER_12x12 + (x / 12) * 12 + ((y / 12) * 12) * GRID_SIZE] == uint256(from) ||
                        _owners[LAYER_24x24 + (x / 24) * 24 + ((y / 24) * 24) * GRID_SIZE] == uint256(from),
                    "not owner of all sub quads nor parent quads"
                );
            }
            _owners[quadId] = uint256(to);
            return true;
        }
        return ownerOfAll;
    }

    function _regroup6x6(
        address from,
        address to,
        uint256 x,
        uint256 y,
        bool set
    ) internal returns (bool) {
        uint256 id = x + y * GRID_SIZE;
        uint256 quadId = LAYER_6x6 + id;
        bool ownerOfAll = true;
        for (uint256 xi = x; xi < x + 6; xi += 3) {
            for (uint256 yi = y; yi < y + 6; yi += 3) {
                bool ownAllIndividual = _regroup3x3(from, to, xi, yi, false);
                uint256 id3x3 = LAYER_3x3 + xi + yi * GRID_SIZE;
                uint256 owner3x3 = _owners[id3x3];
                if (owner3x3 != 0) {
                    if (!ownAllIndividual) {
                        require(owner3x3 == uint256(from), "not owner of 3x3 quad");
                    }
                    _owners[id3x3] = 0;
                }
                ownerOfAll = (ownAllIndividual || owner3x3 != 0) && ownerOfAll;
            }
        }
        if (set) {
            if (!ownerOfAll) {
                require(
                    _owners[quadId] == uint256(from) ||
                        _owners[LAYER_12x12 + (x / 12) * 12 + ((y / 12) * 12) * GRID_SIZE] == uint256(from) ||
                        _owners[LAYER_24x24 + (x / 24) * 24 + ((y / 24) * 24) * GRID_SIZE] == uint256(from),
                    "not owner of all sub quads nor parent quads"
                );
            }
            _owners[quadId] = uint256(to);
            return true;
        }
        return ownerOfAll;
    }

    function _regroup12x12(
        address from,
        address to,
        uint256 x,
        uint256 y,
        bool set
    ) internal returns (bool) {
        uint256 id = x + y * GRID_SIZE;
        uint256 quadId = LAYER_12x12 + id;
        bool ownerOfAll = true;
        for (uint256 xi = x; xi < x + 12; xi += 6) {
            for (uint256 yi = y; yi < y + 12; yi += 6) {
                bool ownAllIndividual = _regroup6x6(from, to, xi, yi, false);
                uint256 id6x6 = LAYER_6x6 + xi + yi * GRID_SIZE;
                uint256 owner6x6 = _owners[id6x6];
                if (owner6x6 != 0) {
                    if (!ownAllIndividual) {
                        require(owner6x6 == uint256(from), "not owner of 6x6 quad");
                    }
                    _owners[id6x6] = 0;
                }
                ownerOfAll = (ownAllIndividual || owner6x6 != 0) && ownerOfAll;
            }
        }
        if (set) {
            if (!ownerOfAll) {
                require(
                    _owners[quadId] == uint256(from) ||
                        _owners[LAYER_24x24 + (x / 24) * 24 + ((y / 24) * 24) * GRID_SIZE] == uint256(from),
                    "not owner of all sub quads nor parent quads"
                );
            }
            _owners[quadId] = uint256(to);
            return true;
        }
        return ownerOfAll;
    }

    function _regroup24x24(
        address from,
        address to,
        uint256 x,
        uint256 y,
        bool set
    ) internal returns (bool) {
        uint256 id = x + y * GRID_SIZE;
        uint256 quadId = LAYER_24x24 + id;
        bool ownerOfAll = true;
        for (uint256 xi = x; xi < x + 24; xi += 12) {
            for (uint256 yi = y; yi < y + 24; yi += 12) {
                bool ownAllIndividual = _regroup12x12(from, to, xi, yi, false);
                uint256 id12x12 = LAYER_12x12 + xi + yi * GRID_SIZE;
                uint256 owner12x12 = _owners[id12x12];
                if (owner12x12 != 0) {
                    if (!ownAllIndividual) {
                        require(owner12x12 == uint256(from), "not owner of 12x12 quad");
                    }
                    _owners[id12x12] = 0;
                }
                ownerOfAll = (ownAllIndividual || owner12x12 != 0) && ownerOfAll;
            }
        }
        if (set) {
            if (!ownerOfAll) {
                require(_owners[quadId] == uint256(from), "not owner of all sub quads not parent quad");
            }
            _owners[quadId] = uint256(to);
            return true;
        }
        return ownerOfAll || _owners[quadId] == uint256(from);
    }

    function _ownerOf(uint256 id) internal view returns (address) {
        require(id & LAYER == 0, "Invalid token id");
        uint256 x = id % GRID_SIZE;
        uint256 y = id / GRID_SIZE;
        uint256 owner1x1 = _owners[id];

        if (owner1x1 != 0) {
            return address(owner1x1); // cast to zero
        } else {
            address owner3x3 = address(_owners[LAYER_3x3 + (x / 3) * 3 + ((y / 3) * 3) * GRID_SIZE]);
            if (owner3x3 != address(0)) {
                return owner3x3;
            } else {
                address owner6x6 = address(_owners[LAYER_6x6 + (x / 6) * 6 + ((y / 6) * 6) * GRID_SIZE]);
                if (owner6x6 != address(0)) {
                    return owner6x6;
                } else {
                    address owner12x12 = address(_owners[LAYER_12x12 + (x / 12) * 12 + ((y / 12) * 12) * GRID_SIZE]);
                    if (owner12x12 != address(0)) {
                        return owner12x12;
                    } else {
                        return address(_owners[LAYER_24x24 + (x / 24) * 24 + ((y / 24) * 24) * GRID_SIZE]);
                    }
                }
            }
        }
    }

    function _ownerAndOperatorEnabledOf(uint256 id) internal view returns (address owner, bool operatorEnabled) {
        require(id & LAYER == 0, "Invalid token id");
        uint256 x = id % GRID_SIZE;
        uint256 y = id / GRID_SIZE;
        uint256 owner1x1 = _owners[id];

        if (owner1x1 != 0) {
            owner = address(owner1x1);
            operatorEnabled = (owner1x1 / 2**255) == 1;
        } else {
            address owner3x3 = address(_owners[LAYER_3x3 + (x / 3) * 3 + ((y / 3) * 3) * GRID_SIZE]);
            if (owner3x3 != address(0)) {
                owner = owner3x3;
                operatorEnabled = false;
            } else {
                address owner6x6 = address(_owners[LAYER_6x6 + (x / 6) * 6 + ((y / 6) * 6) * GRID_SIZE]);
                if (owner6x6 != address(0)) {
                    owner = owner6x6;
                    operatorEnabled = false;
                } else {
                    address owner12x12 = address(_owners[LAYER_12x12 + (x / 12) * 12 + ((y / 12) * 12) * GRID_SIZE]);
                    if (owner12x12 != address(0)) {
                        owner = owner12x12;
                        operatorEnabled = false;
                    } else {
                        owner = address(_owners[LAYER_24x24 + (x / 24) * 24 + ((y / 24) * 24) * GRID_SIZE]);
                        operatorEnabled = false;
                    }
                }
            }
        }
    }
}

/* solhint-disable func-order, code-complexity */
pragma solidity 0.5.9;

import "../../contracts_common/Libraries/AddressUtils.sol";
import "../../contracts_common/Interfaces/ERC721TokenReceiver.sol";
import "../../contracts_common/Interfaces/ERC721Events.sol";
import "../../contracts_common/BaseWithStorage/SuperOperators.sol";
import "../../contracts_common/BaseWithStorage/MetaTransactionReceiver.sol";
import "../../contracts_common/Interfaces/ERC721MandatoryTokenReceiver.sol";

contract ERC721BaseToken is ERC721Events, SuperOperators, MetaTransactionReceiver {
    using AddressUtils for address;

    bytes4 internal constant _ERC721_RECEIVED = 0x150b7a02;
    bytes4 internal constant _ERC721_BATCH_RECEIVED = 0x4b808c46;

    bytes4 internal constant ERC165ID = 0x01ffc9a7;
    bytes4 internal constant ERC721_MANDATORY_RECEIVER = 0x5e8bf644;

    mapping (address => uint256) public _numNFTPerAddress;
    mapping (uint256 => uint256) public _owners;
    mapping (address => mapping(address => bool)) public _operatorsForAll;
    mapping (uint256 => address) public _operators;

    constructor(
        address metaTransactionContract,
        address admin
    ) internal {
        _admin = admin;
        _setMetaTransactionProcessor(metaTransactionContract, true);
    }

    function _transferFrom(address from, address to, uint256 id) internal {
        _numNFTPerAddress[from]--;
        _numNFTPerAddress[to]++;
        _owners[id] = uint256(to);
        emit Transfer(from, to, id);
    }

    /**
     * @notice Return the number of Land owned by an address
     * @param owner The address to look for
     * @return The number of Land token owned by the address
     */
    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "owner is zero address");
        return _numNFTPerAddress[owner];
    }


    function _ownerOf(uint256 id) internal view returns (address) {
        return address(_owners[id]);
    }

    function _ownerAndOperatorEnabledOf(uint256 id) internal view returns (address owner, bool operatorEnabled) {
        uint256 data = _owners[id];
        owner = address(data);
        operatorEnabled = (data / 2**255) == 1;
    }

    /**
     * @notice Return the owner of a Land
     * @param id The id of the Land
     * @return The address of the owner
     */
    function ownerOf(uint256 id) external view returns (address owner) {
        owner = _ownerOf(id);
        require(owner != address(0), "token does not exist");
    }

    function _approveFor(address owner, address operator, uint256 id) internal {
        if(operator == address(0)) {
            _owners[id] = uint256(owner); // no need to resset the operator, it will be overriden next time
        } else {
            _owners[id] = uint256(owner) + 2**255;
            _operators[id] = operator;
        }
        emit Approval(owner, operator, id);
    }

    /**
     * @notice Approve an operator to spend tokens on the sender behalf
     * @param sender The address giving the approval
     * @param operator The address receiving the approval
     * @param id The id of the token
     */
    function approveFor(
        address sender,
        address operator,
        uint256 id
    ) external {
        address owner = _ownerOf(id);
        require(sender != address(0), "sender is zero address");
        require(
            msg.sender == sender ||
            _metaTransactionContracts[msg.sender] ||
            _superOperators[msg.sender] ||
            _operatorsForAll[sender][msg.sender],
            "not authorized to approve"
        );
        require(owner == sender, "owner != sender");
        _approveFor(owner, operator, id);
    }

    /**
     * @notice Approve an operator to spend tokens on the sender behalf
     * @param operator The address receiving the approval
     * @param id The id of the token
     */
    function approve(address operator, uint256 id) external {
        address owner = _ownerOf(id);
        require(owner != address(0), "token does not exist");
        require(
            owner == msg.sender ||
            _superOperators[msg.sender] ||
            _operatorsForAll[owner][msg.sender],
            "not authorized to approve"
        );
        _approveFor(owner, operator, id);
    }

    /**
     * @notice Get the approved operator for a specific token
     * @param id The id of the token
     * @return The address of the operator
     */
    function getApproved(uint256 id) external view returns (address) {
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(owner != address(0), "token does not exist");
        if (operatorEnabled) {
            return _operators[id];
        } else {
            return address(0);
        }
    }

    function _checkTransfer(address from, address to, uint256 id) internal view returns (bool isMetaTx) {
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(owner != address(0), "token does not exist");
        require(owner == from, "not owner in _checkTransfer");
        require(to != address(0), "can't send to zero address");
        isMetaTx = msg.sender != from && _metaTransactionContracts[msg.sender];
        if (msg.sender != from && !isMetaTx) {
            require(
                _superOperators[msg.sender] ||
                _operatorsForAll[from][msg.sender] ||
                (operatorEnabled && _operators[id] == msg.sender),
                "not approved to transfer"
            );
        }
    }

    function _checkInterfaceWith10000Gas(address _contract, bytes4 interfaceId)
        internal
        view
        returns (bool)
    {
        bool success;
        bool result;
        bytes memory call_data = abi.encodeWithSelector(
            ERC165ID,
            interfaceId
        );
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let call_ptr := add(0x20, call_data)
            let call_size := mload(call_data)
            let output := mload(0x40) // Find empty storage location using "free memory pointer"
            mstore(output, 0x0)
            success := staticcall(
                10000,
                _contract,
                call_ptr,
                call_size,
                output,
                0x20
            ) // 32 bytes
            result := mload(output)
        }
        // (10000 / 63) "not enough for supportsInterface(...)" // consume all gas, so caller can potentially know that there was not enough gas
        assert(gasleft() > 158);
        return success && result;
    }

    /**
     * @notice Transfer a token between 2 addresses
     * @param from The sender of the token
     * @param to The recipient of the token
     * @param id The id of the token
    */
    function transferFrom(address from, address to, uint256 id) external {
        bool metaTx = _checkTransfer(from, to, id);
        _transferFrom(from, to, id);
        if (to.isContract() && _checkInterfaceWith10000Gas(to, ERC721_MANDATORY_RECEIVER)) {
            require(
                _checkOnERC721Received(metaTx ? from : msg.sender, from, to, id, ""),
                "erc721 transfer rejected by to"
            );
        }
    }

    /**
     * @notice Transfer a token between 2 addresses letting the receiver knows of the transfer
     * @param from The sender of the token
     * @param to The recipient of the token
     * @param id The id of the token
     * @param data Additional data
     */
    function safeTransferFrom(address from, address to, uint256 id, bytes memory data) public {
        bool metaTx = _checkTransfer(from, to, id);
        _transferFrom(from, to, id);
        if (to.isContract()) {
            require(
                _checkOnERC721Received(metaTx ? from : msg.sender, from, to, id, data),
                "ERC721: transfer rejected by to"
            );
        }
    }

    /**
     * @notice Transfer a token between 2 addresses letting the receiver knows of the transfer
     * @param from The send of the token
     * @param to The recipient of the token
     * @param id The id of the token
     */
    function safeTransferFrom(address from, address to, uint256 id) external {
        safeTransferFrom(from, to, id, "");
    }

    /**
     * @notice Transfer many tokens between 2 addresses
     * @param from The sender of the token
     * @param to The recipient of the token
     * @param ids The ids of the tokens
     * @param data additional data
    */
    function batchTransferFrom(address from, address to, uint256[] calldata ids, bytes calldata data) external {
        _batchTransferFrom(from, to, ids, data, false);
    }

    function _batchTransferFrom(address from, address to, uint256[] memory ids, bytes memory data, bool safe) internal {
        bool metaTx = msg.sender != from && _metaTransactionContracts[msg.sender];
        bool authorized = msg.sender == from ||
            metaTx ||
            _superOperators[msg.sender] ||
            _operatorsForAll[from][msg.sender];

        require(from != address(0), "from is zero address");
        require(to != address(0), "can't send to zero address");

        uint256 numTokens = ids.length;
        for(uint256 i = 0; i < numTokens; i ++) {
            uint256 id = ids[i];
            (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
            require(owner == from, "not owner in batchTransferFrom");
            require(authorized || (operatorEnabled && _operators[id] == msg.sender), "not authorized");
            _owners[id] = uint256(to);
            emit Transfer(from, to, id);
        }
        if (from != to) {
            _numNFTPerAddress[from] -= numTokens;
            _numNFTPerAddress[to] += numTokens;
        }

        if (to.isContract() && (safe || _checkInterfaceWith10000Gas(to, ERC721_MANDATORY_RECEIVER))) {
            require(
                _checkOnERC721BatchReceived(metaTx ? from : msg.sender, from, to, ids, data),
                "erc721 batch transfer rejected by to"
            );
        }
    }

    /**
     * @notice Transfer many tokens between 2 addresses ensuring the receiving contract has a receiver method
     * @param from The sender of the token
     * @param to The recipient of the token
     * @param ids The ids of the tokens
     * @param data additional data
    */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, bytes calldata data) external {
        _batchTransferFrom(from, to, ids, data, true);
    }

    /**
     * @notice Check if the contract supports an interface
     * 0x01ffc9a7 is ERC-165
     * 0x80ac58cd is ERC-721
     * @param id The id of the interface
     * @return True if the interface is supported
     */
    function supportsInterface(bytes4 id) external pure returns (bool) {
        return id == 0x01ffc9a7 || id == 0x80ac58cd;
    }

    /**
     * @notice Set the approval for an operator to manage all the tokens of the sender
     * @param sender The address giving the approval
     * @param operator The address receiving the approval
     * @param approved The determination of the approval
     */
    function setApprovalForAllFor(
        address sender,
        address operator,
        bool approved
    ) external {
        require(sender != address(0), "Invalid sender address");
        require(
            msg.sender == sender ||
            _metaTransactionContracts[msg.sender] ||
            _superOperators[msg.sender],
            "not authorized to approve for all"
        );

        _setApprovalForAll(sender, operator, approved);
    }

    /**
     * @notice Set the approval for an operator to manage all the tokens of the sender
     * @param operator The address receiving the approval
     * @param approved The determination of the approval
     */
    function setApprovalForAll(address operator, bool approved) external {
        _setApprovalForAll(msg.sender, operator, approved);
    }


    function _setApprovalForAll(
        address sender,
        address operator,
        bool approved
    ) internal {
        require(
            !_superOperators[operator],
            "super operator can't have their approvalForAll changed"
        );
        _operatorsForAll[sender][operator] = approved;

        emit ApprovalForAll(sender, operator, approved);
    }

    /**
     * @notice Check if the sender approved the operator
     * @param owner The address of the owner
     * @param operator The address of the operator
     * @return The status of the approval
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool isOperator)
    {
        return _operatorsForAll[owner][operator] || _superOperators[operator];
    }

    function _burn(address from, address owner, uint256 id) internal {
        require(from == owner, "not owner");
        _owners[id] = 2**160; // cannot mint it again
        _numNFTPerAddress[from]--;
        emit Transfer(from, address(0), id);
    }

    /// @notice Burns token `id`.
    /// @param id token which will be burnt.
    function burn(uint256 id) external {
        _burn(msg.sender, _ownerOf(id), id);
    }

    /// @notice Burn token`id` from `from`.
    /// @param from address whose token is to be burnt.
    /// @param id token which will be burnt.
    function burnFrom(address from, uint256 id) external {
        require(from != address(0), "Invalid sender address");
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(
            msg.sender == from ||
            _metaTransactionContracts[msg.sender] ||
            (operatorEnabled && _operators[id] == msg.sender) ||
            _superOperators[msg.sender] ||
            _operatorsForAll[from][msg.sender],
            "not authorized to burn"
        );
        _burn(from, owner, id);
    }

    function _checkOnERC721Received(address operator, address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        bytes4 retval = ERC721TokenReceiver(to).onERC721Received(operator, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _checkOnERC721BatchReceived(address operator, address from, address to, uint256[] memory ids, bytes memory _data)
        internal returns (bool)
    {
        bytes4 retval = ERC721MandatoryTokenReceiver(to).onERC721BatchReceived(operator, from, ids, _data);
        return (retval == _ERC721_BATCH_RECEIVED);
    }
}

pragma solidity ^0.5.2;

/**
    Note: The ERC-165 identifier for this interface is 0x5e8bf644.
*/
interface ERC721MandatoryTokenReceiver {
    function onERC721BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        bytes calldata data
    ) external returns (bytes4); // needs to return 0x4b808c46

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4); // needs to return 0x150b7a02

    // needs to implements EIP-165
    // function supportsInterface(bytes4 interfaceId)
    //     external
    //     view
    //     returns (bool);
}

pragma solidity 0.5.9;

import "../LandBsc.sol";
import "../contracts_common/Interfaces/ERC20.sol";
import "../contracts_common/BaseWithStorage/MetaTransactionReceiver.sol";

contract ArvLandSale is MetaTransactionReceiver {
    uint256 internal constant GRID_SIZE = 1562;

    LandBsc internal _land;
    ERC20 internal _ariva;
    address payable internal _wallet;

    uint256 _startTime;

    mapping(bytes32 => uint256) private _prices;

    event LandQuadPurchased(
        address indexed buyer,
        address indexed to,
        uint256 indexed topCornerId,
        uint256 size,
        uint256 price
    );

    constructor(
        address landAddress,
        address arivaContractAddress,
        address initialMetaTx,
        address admin,
        address payable initialWalletAddress,
        uint256 sTime
    ) public {
        require(sTime > block.timestamp, "Invalid");

        _land = LandBsc(landAddress);
        _ariva = ERC20(arivaContractAddress);
        _setMetaTransactionProcessor(initialMetaTx, true);
        _admin = admin;
        _wallet = initialWalletAddress;
        _startTime = sTime;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "only admin");

        _;
    }

    /// @notice set the wallet receiving the proceeds
    /// @param newWallet address of the new receiving wallet
    function setReceivingWallet(address payable newWallet) external onlyAdmin {
        require(newWallet != address(0), "receiving wallet cannot be zero address");
        _wallet = newWallet;
    }

    function setSellQuad(
        uint256 x,
        uint256 y,
        uint256 size,
        uint256 price
    ) external onlyAdmin {
        bytes32 hash = _generateLandHash(x, y, size);
        _prices[hash] = price;
    }

    function setSellQuads(
        uint256[] calldata xs,
        uint256[] calldata ys,
        uint256[] calldata sizes,
        uint256[] calldata prices
    ) external onlyAdmin {
        require(xs.length == ys.length && ys.length == sizes.length && sizes.length == prices.length, "Invalid params");

        for (uint256 index = 0; index < xs.length; index++) {
            uint256 x = xs[index];
            uint256 y = ys[index];
            uint256 size = sizes[index];

            bytes32 hash = _generateLandHash(x, y, size);
            _prices[hash] = prices[index];
        }
    }

    /**
     * @notice buy Land using the merkle proof associated with it
     * @param buyer address that perform the payment
     * @param to address that will own the purchased Land
     * @param x x coordinate of the Land
     * @param y y coordinate of the Land
     * @param size size of the pack of Land to purchase
     * @return The address of the operator
     */
    function buyLand(
        address buyer,
        address to,
        uint256 x,
        uint256 y,
        uint256 size
    ) external {
        require(_startTime < block.timestamp, "Sale is not started");
        /* solhint-disable-next-line not-rely-on-time */
        require(buyer == msg.sender || _metaTransactionContracts[msg.sender], "not authorized");

        bytes32 hash = _generateLandHash(x, y, size);
        uint256 price = _prices[hash];
        require(price > 0, "Not on sale");

        require(_ariva.transferFrom(buyer, _wallet, price), "arv transfer failed");

        _land.transferQuad(address(this), to, size, x, y, "");

        delete _prices[hash];
        emit LandQuadPurchased(buyer, to, x + (y * GRID_SIZE), size, price);
    }

    function withdrawQuad(
        uint256 x,
        uint256 y,
        uint256 size
    ) external onlyAdmin {
        _land.transferQuad(address(this), msg.sender, size, x, y, "");
    }

    function getPrice(
        uint256 x,
        uint256 y,
        uint256 size
    ) external view returns (uint256) {
        bytes32 hash = _generateLandHash(x, y, size);
        return _prices[hash];
    }

    function getPrices(
        uint256[] calldata xs,
        uint256[] calldata ys,
        uint256[] calldata sizes
    ) external view returns (uint256[] memory) {
        require(xs.length == ys.length && ys.length == sizes.length, "Invalid params");

        uint256[] memory prices = new uint256[](xs.length);

        for (uint256 index = 0; index < xs.length; index++) {
            bytes32 hash = _generateLandHash(xs[index], ys[index], sizes[index]);
            prices[index] = _prices[hash];
        }
        return prices;
    }

    function _generateLandHash(
        uint256 x,
        uint256 y,
        uint256 size
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(x, y, size));
    }

    function startTime() external view returns (uint256) {
        return _startTime;
    }

    function setStartTime(uint256 sTime) external onlyAdmin {
        require(sTime > block.timestamp, "Invalid");
        _startTime = sTime;
    }
}

/* solhint-disable no-empty-blocks */

pragma solidity 0.5.9;

import "./Land/erc721/LandBaseToken.sol";

contract LandHay is LandBaseToken {
    constructor(address metaTransactionContract, address admin) public LandBaseToken(metaTransactionContract, admin) {}

    /**
     * @notice Return the name of the token contract
     * @return The name of the token contract
     */
    function name() external pure returns (string memory) {
        return "Ariva Wonderland";
    }

    /**
     * @notice Return the symbol of the token contract
     * @return The symbol of the token contract
     */
    function symbol() external pure returns (string memory) {
        return "ARWL";
    }

    // solium-disable-next-line security/no-assign-params
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    /**
     * @notice Return the URI of a specific token
     * @param id The id of the token
     * @return The URI of the token
     */
    function tokenURI(uint256 id) public view returns (string memory) {
        require(_ownerOf(id) != address(0), "Id does not exist");

        return
            string(
                abi.encodePacked(
                    "https://api.ariva.game/lands/bsc/",
                    uint2str(id),
                    "/metadata.json"
                )
            );
    }

    /**
     * @notice Check if the contract supports an interface
     * 0x01ffc9a7 is ERC-165
     * 0x80ac58cd is ERC-721
     * 0x5b5e139f is ERC-721 metadata
     * @param id The id of the interface
     * @return True if the interface is supported
     */
    function supportsInterface(bytes4 id) external pure returns (bool) {
        return id == 0x01ffc9a7 || id == 0x80ac58cd || id == 0x5b5e139f;
    }
}

/* solhint-disable no-empty-blocks */

pragma solidity 0.5.9;

import "./Land/erc721/LandBaseToken.sol";

contract LandEth is LandBaseToken {
    constructor(address metaTransactionContract, address admin) public LandBaseToken(metaTransactionContract, admin) {}

    /**
     * @notice Return the name of the token contract
     * @return The name of the token contract
     */
    function name() external pure returns (string memory) {
        return "Ariva Wonderland";
    }

    /**
     * @notice Return the symbol of the token contract
     * @return The symbol of the token contract
     */
    function symbol() external pure returns (string memory) {
        return "ARWL";
    }

    // solium-disable-next-line security/no-assign-params
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    /**
     * @notice Return the URI of a specific token
     * @param id The id of the token
     * @return The URI of the token
     */
    function tokenURI(uint256 id) public view returns (string memory) {
        require(_ownerOf(id) != address(0), "Id does not exist");

        return
            string(
                abi.encodePacked(
                    "https://api.ariva.game/lands/eth/",
                    uint2str(id),
                    "/metadata.json"
                )
            );
    }

    /**
     * @notice Check if the contract supports an interface
     * 0x01ffc9a7 is ERC-165
     * 0x80ac58cd is ERC-721
     * 0x5b5e139f is ERC-721 metadata
     * @param id The id of the interface
     * @return True if the interface is supported
     */
    function supportsInterface(bytes4 id) external pure returns (bool) {
        return id == 0x01ffc9a7 || id == 0x80ac58cd || id == 0x5b5e139f;
    }
}

pragma solidity 0.5.9;

import "../LandEth.sol";
import "../contracts_common/Interfaces/ERC20.sol";
import "../contracts_common/BaseWithStorage/MetaTransactionReceiver.sol";

contract EthLandSale is MetaTransactionReceiver {
    uint256 internal constant GRID_SIZE = 1562;

    LandEth internal _land;
    address payable internal _wallet;

    uint256 _startTime;

    mapping(bytes32 => uint256) private _prices;

    event LandQuadPurchased(
        address indexed buyer,
        address indexed to,
        uint256 indexed topCornerId,
        uint256 size,
        uint256 price
    );

    constructor(
        address landAddress,
        address initialMetaTx,
        address admin,
        address payable initialWalletAddress,
        uint256 sTime
    ) public {
        require(sTime > block.timestamp, "Invalid");

        _land = LandEth(landAddress);
        _setMetaTransactionProcessor(initialMetaTx, true);
        _admin = admin;
        _wallet = initialWalletAddress;
        _startTime = sTime;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "only admin");

        _;
    }

    /// @notice set the wallet receiving the proceeds
    /// @param newWallet address of the new receiving wallet
    function setReceivingWallet(address payable newWallet) external onlyAdmin {
        require(newWallet != address(0), "receiving wallet cannot be zero address");
        _wallet = newWallet;
    }

    function setSellQuad(
        uint256 x,
        uint256 y,
        uint256 size,
        uint256 price
    ) external onlyAdmin {
        bytes32 hash = _generateLandHash(x, y, size);
        _prices[hash] = price;
    }

    function setSellQuads(
        uint256[] calldata xs,
        uint256[] calldata ys,
        uint256[] calldata sizes,
        uint256[] calldata prices
    ) external onlyAdmin {
        require(xs.length == ys.length && ys.length == sizes.length && sizes.length == prices.length, "Invalid params");

        for (uint256 index = 0; index < xs.length; index++) {
            uint256 x = xs[index];
            uint256 y = ys[index];
            uint256 size = sizes[index];

            bytes32 hash = _generateLandHash(x, y, size);
            _prices[hash] = prices[index];
        }
    }

    /**
     * @notice buy Land using the merkle proof associated with it
     * @param buyer address that perform the payment
     * @param to address that will own the purchased Land
     * @param x x coordinate of the Land
     * @param y y coordinate of the Land
     * @param size size of the pack of Land to purchase
     * @return The address of the operator
     */
    function buyLand(
        address buyer,
        address to,
        uint256 x,
        uint256 y,
        uint256 size
    ) external payable {
        require(_startTime < block.timestamp, "Sale is not started");
        /* solhint-disable-next-line not-rely-on-time */
        require(buyer == msg.sender || _metaTransactionContracts[msg.sender], "not authorized");

        bytes32 hash = _generateLandHash(x, y, size);
        uint256 price = _prices[hash];
        require(price > 0, "Not on sale");

        require(msg.value == price, "Insufficient ether");

        require(_wallet.send(msg.value), "ether transfer failed");

        _land.transferQuad(address(this), to, size, x, y, "");

        delete _prices[hash];
        emit LandQuadPurchased(buyer, to, x + (y * GRID_SIZE), size, price);
    }

    function withdrawQuad(
        uint256 x,
        uint256 y,
        uint256 size
    ) external onlyAdmin {
        _land.transferQuad(address(this), msg.sender, size, x, y, "");
    }

    function getPrice(
        uint256 x,
        uint256 y,
        uint256 size
    ) external view returns (uint256) {
        bytes32 hash = _generateLandHash(x, y, size);
        return _prices[hash];
    }

    function getPrices(
        uint256[] calldata xs,
        uint256[] calldata ys,
        uint256[] calldata sizes
    ) external view returns (uint256[] memory) {
        require(xs.length == ys.length && ys.length == sizes.length, "Invalid params");

        uint256[] memory prices = new uint256[](xs.length);

        for (uint256 index = 0; index < xs.length; index++) {
            bytes32 hash = _generateLandHash(xs[index], ys[index], sizes[index]);
            prices[index] = _prices[hash];
        }
        return prices;
    }

    function _generateLandHash(
        uint256 x,
        uint256 y,
        uint256 size
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(x, y, size));
    }

    function startTime() external view returns (uint256) {
        return _startTime;
    }

    function setStartTime(uint256 sTime) external onlyAdmin {
        require(sTime > block.timestamp, "Invalid");
        _startTime = sTime;
    }
}

pragma solidity 0.5.9;

import "../BaseWithStorage/ERC721BaseToken.sol";
import "../Interfaces/LandToken.sol";
import "../contracts_common/Interfaces/ERC721MandatoryTokenReceiver.sol";

contract EstateBaseToken is ERC721BaseToken {
    uint8 internal constant OWNER = 0;
    uint8 internal constant ADD = 1;
    uint8 internal constant BREAK = 2;
    uint8 internal constant WITHDRAWAL = 3;

    uint16 internal constant GRID_SIZE = 15620;

    uint256 _nextId = 1;
    mapping(uint256 => uint24[]) _quadsInEstate;
    LandToken _land;
    address _minter;
    address _breaker;

    event QuadsAddedInEstate(uint256 indexed id, uint24[] list);

    constructor(
        address metaTransactionContract,
        address admin,
        LandToken land
    ) public ERC721BaseToken(metaTransactionContract, admin) {
        _land = land;
    }

    function createFromQuad(
        address sender,
        address to,
        uint256 size,
        uint256 x,
        uint256 y
    ) external returns (uint256) {
        _check_authorized(sender, ADD);
        uint256 estateId = _mintEstate(to);
        _addSingleQuad(sender, estateId, size, x, y);
        return estateId;
    }

    function addQuad(
        address sender,
        uint256 estateId,
        uint256 size,
        uint256 x,
        uint256 y
    ) external {
        _check_authorized(sender, ADD);
        _check_hasOwnerRights(sender, estateId);
        _addSingleQuad(sender, estateId, size, x, y);
    }

    function createFromMultipleLands(
        address sender,
        address to,
        uint256[] calldata ids,
        uint256[] calldata junctions
    ) external returns (uint256) {
        _check_authorized(sender, ADD);
        uint256 estateId = _mintEstate(to);
        _addLands(sender, estateId, ids, junctions, true);
        return estateId;
    }

    // TODO addSingleLand

    function addMultipleLands(
        address sender,
        uint256 estateId,
        uint256[] calldata ids,
        uint256[] calldata junctions
    ) external {
        _check_authorized(sender, ADD);
        _check_hasOwnerRights(sender, estateId);
        _addLands(sender, estateId, ids, junctions, false);
    }

    function createFromMultipleQuads(
        address sender,
        address to,
        uint256[] calldata sizes,
        uint256[] calldata xs,
        uint256[] calldata ys,
        uint256[] calldata junctions
    ) external returns (uint256) {
        _check_authorized(sender, ADD);
        uint256 estateId = _mintEstate(to);
        _addQuads(sender, estateId, sizes, xs, ys, junctions, true);
        return estateId;
    }

    function addMultipleQuads(
        address sender,
        uint256 estateId,
        uint256[] calldata sizes,
        uint256[] calldata xs,
        uint256[] calldata ys,
        uint256[] calldata junctions
    ) external {
        _check_authorized(sender, ADD);
        _check_hasOwnerRights(sender, estateId);
        _addQuads(sender, estateId, sizes, xs, ys, junctions, false);
    }

    function destroy(address sender, uint256 estateId) external {
        _check_authorized(sender, BREAK);
        _check_hasOwnerRights(sender, estateId);
        _owners[estateId] = 0; // TODO keep track of it so it can transfer Land back
        _numNFTPerAddress[sender]--;
        emit Transfer(sender, address(0), estateId);
    }

    function transferFromDestroyedEstate(
        address sender,
        address to,
        uint256 num
    ) external {
        _check_authorized(sender, WITHDRAWAL);
        // TODO
        // require(sender != address(this), "from itself");
        // require(sender != address(0), "sender is zero address");
        // require(msg.sender == sender ||
        //     _metaTransactionContracts[msg.sender] ||
        //     _superOperators[msg.sender],
        //     "not _check_authorized");
        // require(sender == _pastOwnerOf(estateId), "only owner can transfer land from destroyed estate");
        // TODO
    }

    // //////////////////////////////////////////////////////////////////////////////////////////////////////

    function _check_authorized(address sender, uint8 action) internal {
        require(sender != address(0), "sender is zero address");
        if (action == ADD) {
            address minter = _minter;
            if (minter == address(0)) {
                require(msg.sender == sender || _metaTransactionContracts[msg.sender], "not _check_authorized");
            } else {
                require(msg.sender == minter, "only minter allowed");
            }
        } else if (action == BREAK) {
            address breaker = _breaker;
            if (breaker == address(0)) {
                require(msg.sender == sender || _metaTransactionContracts[msg.sender], "not _check_authorized");
            } else {
                require(msg.sender == breaker, "only breaker allowed");
            }
        } else {
            require(msg.sender == sender || _metaTransactionContracts[msg.sender], "not _check_authorized");
        }
    }

    function _check_hasOwnerRights(address sender, uint256 estateId) internal {
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(estateId);
        require(owner != address(0), "token does not exist");
        require(owner == sender, "not owner");
        require(
            _superOperators[msg.sender] ||
                _operatorsForAll[sender][msg.sender] ||
                (operatorEnabled && _operators[estateId] == msg.sender),
            "not approved"
        );
    }

    // //////////////////////////////////////////////////////////////////////////////////////////////////////////

    function _encode(
        uint16 x,
        uint16 y,
        uint8 size
    ) internal pure returns (uint24) {
        return uint24(size) * uint24(2**18) + (uint24(x) + uint24(y) * GRID_SIZE);
    }

    function _decode(uint24 data)
        internal
        pure
        returns (
            uint16 x,
            uint16 y,
            uint8 size
        )
    {
        size = uint8(data / (2**18));
        y = uint16((data % (2**18)) / GRID_SIZE);
        x = uint16(data % GRID_SIZE);
    }

    function _mintEstate(address to) internal returns (uint256) {
        require(to != address(0), "can't send to zero address");
        uint256 estateId = _nextId++;
        _owners[estateId] = uint256(to);
        _numNFTPerAddress[to]++;
        emit Transfer(address(0), to, estateId);
        return estateId;
    }

    function _addSingleQuad(
        address sender,
        uint256 estateId,
        uint256 size,
        uint256 x,
        uint256 y
    ) internal {
        _land.transferQuad(sender, address(this), size, x, y, "");
        uint24[] memory list = new uint24[](1);
        list[0] = _encode(uint16(x), uint16(y), uint8(size));
        // TODO check adjacency
        _quadsInEstate[estateId].push(list[0]);
        emit QuadsAddedInEstate(estateId, list);
    }

    function _addQuads(
        address sender,
        uint256 estateId,
        uint256[] memory sizes,
        uint256[] memory xs,
        uint256[] memory ys,
        uint256[] memory junctions,
        bool justCreated
    ) internal {
        _land.batchTransferQuad(sender, address(this), sizes, xs, ys, "");
        uint24[] memory list = new uint24[](sizes.length);
        for (uint256 i = 0; i < list.length; i++) {
            list[i] = _encode(uint16(xs[i]), uint16(ys[i]), uint8(sizes[i]));
        }
        // TODO check adjacency
        if (justCreated) {
            _quadsInEstate[estateId] = list;
        } else {
            for (uint256 i = 0; i < list.length; i++) {
                _quadsInEstate[estateId].push(list[i]);
            }
        }
        emit QuadsAddedInEstate(estateId, list);
    }

    function _adjacent(
        uint16 x1,
        uint16 y1,
        uint16 x2,
        uint16 y2
    ) internal pure returns (bool) {
        return ((x1 == x2 && y1 == y2 - 1) ||
            (x1 == x2 && y1 == y2 + 1) ||
            (x1 == x2 - 1 && y1 == y2) ||
            (x1 == x2 + 1 && y1 == y2));
    }

    function _adjacent(
        uint16 x1,
        uint16 y1,
        uint16 x2,
        uint16 y2,
        uint8 s2
    ) internal pure returns (bool) {
        return ((x1 >= x2 && x1 < x2 + s2 && y1 == y2 - 1) ||
            (x1 >= x2 && x1 < x2 + s2 && y1 == y2 + s2) ||
            (x1 == x2 - 1 && y1 >= y2 && y1 < y2 + s2) ||
            (x1 == x2 - s2 && y1 >= y2 && y1 < y2 + s2));
    }

    function _addLands(
        address sender,
        uint256 estateId,
        uint256[] memory ids,
        uint256[] memory junctions,
        bool justCreated
    ) internal {
        _land.batchTransferFrom(sender, address(this), ids, "");
        uint24[] memory list = new uint24[](ids.length);
        for (uint256 i = 0; i < list.length; i++) {
            uint16 x = uint16(ids[i] % GRID_SIZE);
            uint16 y = uint16(ids[i] / GRID_SIZE);
            list[i] = _encode(x, y, 1);
        }

        uint256 l = _quadsInEstate[estateId].length;
        uint16 lastX = 409;
        uint16 lastY = 409;
        if (!justCreated) {
            uint24 d = _quadsInEstate[estateId][l - 1];
            lastX = uint16(d % GRID_SIZE);
            lastY = uint16(d % GRID_SIZE);
        }
        uint256 j = 0;
        for (uint256 i = 0; i < list.length; i++) {
            uint16 x = uint16(ids[i] % GRID_SIZE);
            uint16 y = uint16(ids[i] / GRID_SIZE);
            if (lastX != 409 && !_adjacent(x, y, lastX, lastY)) {
                uint256 index = junctions[j];
                j++;
                uint24 data;
                if (index >= l) {
                    require(index - l < j, "junctions need to refers to previously accepted land");
                    data = list[index - l];
                } else {
                    data = _quadsInEstate[estateId][j];
                }
                (uint16 jx, uint16 jy, uint8 jsize) = _decode(data);
                if (jsize == 1) {
                    require(_adjacent(x, y, jx, jy), "need junctions to be adjacent");
                } else {
                    require(_adjacent(x, y, jx, jy, jsize), "need junctions to be adjacent");
                }
            }
            lastX = x;
            lastY = y;
        }
        if (justCreated) {
            _quadsInEstate[estateId] = list;
        } else {
            for (uint256 i = 0; i < list.length; i++) {
                _quadsInEstate[estateId].push(list[i]);
            }
        }
        emit QuadsAddedInEstate(estateId, list);
    }

    // ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function onERC721BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        bytes calldata data
    ) external returns (bytes4) {
        revert("please call add* or createFrom* functions");
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        revert("please call add* or createFrom* functions");
    }
}

/* solhint-disable func-order, code-complexity */
pragma solidity 0.5.9;

import "../contracts_common/Libraries/AddressUtils.sol";
import "../contracts_common/Interfaces/ERC721TokenReceiver.sol";
import "../contracts_common/Interfaces/ERC721Events.sol";
import "../contracts_common/BaseWithStorage/SuperOperators.sol";
import "../contracts_common/BaseWithStorage/MetaTransactionReceiver.sol";
import "../contracts_common/Interfaces/ERC721MandatoryTokenReceiver.sol";

contract ERC721BaseToken is ERC721Events, SuperOperators, MetaTransactionReceiver {
    using AddressUtils for address;

    bytes4 internal constant _ERC721_RECEIVED = 0x150b7a02;
    bytes4 internal constant _ERC721_BATCH_RECEIVED = 0x4b808c46;

    bytes4 internal constant ERC165ID = 0x01ffc9a7;
    bytes4 internal constant ERC721_MANDATORY_RECEIVER = 0x5e8bf644;

    mapping (address => uint256) public _numNFTPerAddress;
    mapping (uint256 => uint256) public _owners;
    mapping (address => mapping(address => bool)) public _operatorsForAll;
    mapping (uint256 => address) public _operators;

    constructor(
        address metaTransactionContract,
        address admin
    ) internal {
        _admin = admin;
        _setMetaTransactionProcessor(metaTransactionContract, true);
    }

    function _transferFrom(address from, address to, uint256 id) internal {
        _numNFTPerAddress[from]--;
        _numNFTPerAddress[to]++;
        _owners[id] = uint256(to);
        emit Transfer(from, to, id);
    }

    /**
     * @notice Return the number of Land owned by an address
     * @param owner The address to look for
     * @return The number of Land token owned by the address
     */
    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "owner is zero address");
        return _numNFTPerAddress[owner];
    }


    function _ownerOf(uint256 id) internal view returns (address) {
        return address(_owners[id]);
    }

    function _ownerAndOperatorEnabledOf(uint256 id) internal view returns (address owner, bool operatorEnabled) {
        uint256 data = _owners[id];
        owner = address(data);
        operatorEnabled = (data / 2**255) == 1;
    }

    /**
     * @notice Return the owner of a Land
     * @param id The id of the Land
     * @return The address of the owner
     */
    function ownerOf(uint256 id) external view returns (address owner) {
        owner = _ownerOf(id);
        require(owner != address(0), "token does not exist");
    }

    function _approveFor(address owner, address operator, uint256 id) internal {
        if(operator == address(0)) {
            _owners[id] = uint256(owner); // no need to resset the operator, it will be overriden next time
        } else {
            _owners[id] = uint256(owner) + 2**255;
            _operators[id] = operator;
        }
        emit Approval(owner, operator, id);
    }

    /**
     * @notice Approve an operator to spend tokens on the sender behalf
     * @param sender The address giving the approval
     * @param operator The address receiving the approval
     * @param id The id of the token
     */
    function approveFor(
        address sender,
        address operator,
        uint256 id
    ) external {
        address owner = _ownerOf(id);
        require(sender != address(0), "sender is zero address");
        require(
            msg.sender == sender ||
            _metaTransactionContracts[msg.sender] ||
            _superOperators[msg.sender] ||
            _operatorsForAll[sender][msg.sender],
            "not authorized to approve"
        );
        require(owner == sender, "owner != sender");
        _approveFor(owner, operator, id);
    }

    /**
     * @notice Approve an operator to spend tokens on the sender behalf
     * @param operator The address receiving the approval
     * @param id The id of the token
     */
    function approve(address operator, uint256 id) external {
        address owner = _ownerOf(id);
        require(owner != address(0), "token does not exist");
        require(
            owner == msg.sender ||
            _superOperators[msg.sender] ||
            _operatorsForAll[owner][msg.sender],
            "not authorized to approve"
        );
        _approveFor(owner, operator, id);
    }

    /**
     * @notice Get the approved operator for a specific token
     * @param id The id of the token
     * @return The address of the operator
     */
    function getApproved(uint256 id) external view returns (address) {
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(owner != address(0), "token does not exist");
        if (operatorEnabled) {
            return _operators[id];
        } else {
            return address(0);
        }
    }

    function _checkTransfer(address from, address to, uint256 id) internal view returns (bool isMetaTx) {
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(owner != address(0), "token does not exist");
        require(owner == from, "not owner in _checkTransfer");
        require(to != address(0), "can't send to zero address");
        isMetaTx = msg.sender != from && _metaTransactionContracts[msg.sender];
        if (msg.sender != from && !isMetaTx) {
            require(
                _superOperators[msg.sender] ||
                _operatorsForAll[from][msg.sender] ||
                (operatorEnabled && _operators[id] == msg.sender),
                "not approved to transfer"
            );
        }
    }

    function _checkInterfaceWith10000Gas(address _contract, bytes4 interfaceId)
        internal
        view
        returns (bool)
    {
        bool success;
        bool result;
        bytes memory call_data = abi.encodeWithSelector(
            ERC165ID,
            interfaceId
        );
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let call_ptr := add(0x20, call_data)
            let call_size := mload(call_data)
            let output := mload(0x40) // Find empty storage location using "free memory pointer"
            mstore(output, 0x0)
            success := staticcall(
                10000,
                _contract,
                call_ptr,
                call_size,
                output,
                0x20
            ) // 32 bytes
            result := mload(output)
        }
        // (10000 / 63) "not enough for supportsInterface(...)" // consume all gas, so caller can potentially know that there was not enough gas
        assert(gasleft() > 158);
        return success && result;
    }

    /**
     * @notice Transfer a token between 2 addresses
     * @param from The sender of the token
     * @param to The recipient of the token
     * @param id The id of the token
    */
    function transferFrom(address from, address to, uint256 id) external {
        bool metaTx = _checkTransfer(from, to, id);
        _transferFrom(from, to, id);
        if (to.isContract() && _checkInterfaceWith10000Gas(to, ERC721_MANDATORY_RECEIVER)) {
            require(
                _checkOnERC721Received(metaTx ? from : msg.sender, from, to, id, ""),
                "erc721 transfer rejected by to"
            );
        }
    }

    /**
     * @notice Transfer a token between 2 addresses letting the receiver knows of the transfer
     * @param from The sender of the token
     * @param to The recipient of the token
     * @param id The id of the token
     * @param data Additional data
     */
    function safeTransferFrom(address from, address to, uint256 id, bytes memory data) public {
        bool metaTx = _checkTransfer(from, to, id);
        _transferFrom(from, to, id);
        if (to.isContract()) {
            require(
                _checkOnERC721Received(metaTx ? from : msg.sender, from, to, id, data),
                "ERC721: transfer rejected by to"
            );
        }
    }

    /**
     * @notice Transfer a token between 2 addresses letting the receiver knows of the transfer
     * @param from The send of the token
     * @param to The recipient of the token
     * @param id The id of the token
     */
    function safeTransferFrom(address from, address to, uint256 id) external {
        safeTransferFrom(from, to, id, "");
    }

    /**
     * @notice Transfer many tokens between 2 addresses
     * @param from The sender of the token
     * @param to The recipient of the token
     * @param ids The ids of the tokens
     * @param data additional data
    */
    function batchTransferFrom(address from, address to, uint256[] calldata ids, bytes calldata data) external {
        _batchTransferFrom(from, to, ids, data, false);
    }

    function _batchTransferFrom(address from, address to, uint256[] memory ids, bytes memory data, bool safe) internal {
        bool metaTx = msg.sender != from && _metaTransactionContracts[msg.sender];
        bool authorized = msg.sender == from ||
            metaTx ||
            _superOperators[msg.sender] ||
            _operatorsForAll[from][msg.sender];

        require(from != address(0), "from is zero address");
        require(to != address(0), "can't send to zero address");

        uint256 numTokens = ids.length;
        for(uint256 i = 0; i < numTokens; i ++) {
            uint256 id = ids[i];
            (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
            require(owner == from, "not owner in batchTransferFrom");
            require(authorized || (operatorEnabled && _operators[id] == msg.sender), "not authorized");
            _owners[id] = uint256(to);
            emit Transfer(from, to, id);
        }
        if (from != to) {
            _numNFTPerAddress[from] -= numTokens;
            _numNFTPerAddress[to] += numTokens;
        }

        if (to.isContract() && (safe || _checkInterfaceWith10000Gas(to, ERC721_MANDATORY_RECEIVER))) {
            require(
                _checkOnERC721BatchReceived(metaTx ? from : msg.sender, from, to, ids, data),
                "erc721 batch transfer rejected by to"
            );
        }
    }

    /**
     * @notice Transfer many tokens between 2 addresses ensuring the receiving contract has a receiver method
     * @param from The sender of the token
     * @param to The recipient of the token
     * @param ids The ids of the tokens
     * @param data additional data
    */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, bytes calldata data) external {
        _batchTransferFrom(from, to, ids, data, true);
    }

    /**
     * @notice Check if the contract supports an interface
     * 0x01ffc9a7 is ERC-165
     * 0x80ac58cd is ERC-721
     * @param id The id of the interface
     * @return True if the interface is supported
     */
    function supportsInterface(bytes4 id) external pure returns (bool) {
        return id == 0x01ffc9a7 || id == 0x80ac58cd;
    }

    /**
     * @notice Set the approval for an operator to manage all the tokens of the sender
     * @param sender The address giving the approval
     * @param operator The address receiving the approval
     * @param approved The determination of the approval
     */
    function setApprovalForAllFor(
        address sender,
        address operator,
        bool approved
    ) external {
        require(sender != address(0), "Invalid sender address");
        require(
            msg.sender == sender ||
            _metaTransactionContracts[msg.sender] ||
            _superOperators[msg.sender],
            "not authorized to approve for all"
        );

        _setApprovalForAll(sender, operator, approved);
    }

    /**
     * @notice Set the approval for an operator to manage all the tokens of the sender
     * @param operator The address receiving the approval
     * @param approved The determination of the approval
     */
    function setApprovalForAll(address operator, bool approved) external {
        _setApprovalForAll(msg.sender, operator, approved);
    }


    function _setApprovalForAll(
        address sender,
        address operator,
        bool approved
    ) internal {
        require(
            !_superOperators[operator],
            "super operator can't have their approvalForAll changed"
        );
        _operatorsForAll[sender][operator] = approved;

        emit ApprovalForAll(sender, operator, approved);
    }

    /**
     * @notice Check if the sender approved the operator
     * @param owner The address of the owner
     * @param operator The address of the operator
     * @return The status of the approval
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool isOperator)
    {
        return _operatorsForAll[owner][operator] || _superOperators[operator];
    }

    function _burn(address from, address owner, uint256 id) public {
        require(from == owner, "not owner");
        _owners[id] = 2**160; // cannot mint it again
        _numNFTPerAddress[from]--;
        emit Transfer(from, address(0), id);
    }

    /// @notice Burns token `id`.
    /// @param id token which will be burnt.
    function burn(uint256 id) external {
        _burn(msg.sender, _ownerOf(id), id);
    }

    /// @notice Burn token`id` from `from`.
    /// @param from address whose token is to be burnt.
    /// @param id token which will be burnt.
    function burnFrom(address from, uint256 id) external {
        require(from != address(0), "Invalid sender address");
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(
            msg.sender == from ||
            _metaTransactionContracts[msg.sender] ||
            (operatorEnabled && _operators[id] == msg.sender) ||
            _superOperators[msg.sender] ||
            _operatorsForAll[from][msg.sender],
            "not authorized to burn"
        );
        _burn(from, owner, id);
    }

    function _checkOnERC721Received(address operator, address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        bytes4 retval = ERC721TokenReceiver(to).onERC721Received(operator, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _checkOnERC721BatchReceived(address operator, address from, address to, uint256[] memory ids, bytes memory _data)
        internal returns (bool)
    {
        bytes4 retval = ERC721MandatoryTokenReceiver(to).onERC721BatchReceived(operator, from, ids, _data);
        return (retval == _ERC721_BATCH_RECEIVED);
    }
}

pragma solidity 0.5.9;

contract LandToken {
    function batchTransferQuad(
        address from,
        address to,
        uint256[] calldata sizes,
        uint256[] calldata xs,
        uint256[] calldata ys,
        bytes calldata data
    ) external;

    function transferQuad(address from, address to, uint256 size, uint256 x, uint256 y, bytes calldata data) external;

    function batchTransferFrom(address from, address to, uint256[] calldata ids, bytes calldata data) external;
}

pragma solidity 0.5.9;

import "../Wonderland/erc20/ERC20BaseToken.sol";

contract FakeDai is ERC20BaseToken {
    constructor() public {
        _mint(msg.sender, 3000000000 * 10**18);
    }
}

pragma solidity 0.5.9;

import "../../contracts_common/Libraries/BytesUtil.sol";

contract AssetApproveExtension {
    mapping(address => mapping(address => uint256)) approvalMessages;

    // TODO mapping(address => mapping (uint256 => bool)) usedApprovalMessages;

    // TODO remove as we can use erc1155 totkensReceived hook
    function setApprovalForAllAndCall(address _target, bytes memory _data) public payable returns (bytes memory) {
        require(BytesUtil.doFirstParamEqualsAddress(_data, msg.sender), "first param != sender");
        _setApprovalForAllFrom(msg.sender, _target, true);
        (bool success, bytes memory returnData) = _target.call.value(msg.value)(_data);
        require(success, "Something went wrong with the extra call.");
        return returnData;
    }

    function approveAllViaSignedMessage(
        address _target,
        uint256 _nonce,
        bytes calldata signature
    ) external {
        address signer; // TODO ecrecover(hash, v, r, s);
        require(approvalMessages[signer][_target]++ == _nonce);
        _setApprovalForAllFrom(signer, _target, true);
    }

    // TODO 2 signatures one for approve and one for call ?
    function approveAllAndCallViaSignedMessage(
        address _target,
        uint256 _nonce,
        bytes calldata _data,
        bytes calldata signature
    ) external payable returns (bytes memory) {
        address signer; // TODO ecrecover(hash, v, r, s);
        require(BytesUtil.doFirstParamEqualsAddress(_data, signer), "first param != signer");
        require(approvalMessages[signer][_target]++ == _nonce);
        _setApprovalForAllFrom(signer, _target, true);
        (bool success, bytes memory returnData) = _target.call.value(msg.value)(_data);
        require(success, "Something went wrong with the extra call.");
        return returnData;
    }

    function _setApprovalForAllFrom(
        address owner,
        address _operator,
        bool _approved
    ) internal;
}

pragma solidity 0.5.9;

import "../contracts_common/Interfaces/ERC1155.sol";
import "../contracts_common/Interfaces/ERC1155TokenReceiver.sol";

import "../contracts_common/Libraries/AddressUtils.sol";
import "../contracts_common/Libraries/ObjectLib32.sol";

import "../contracts_common/Interfaces/ERC721.sol";
import "../contracts_common/Interfaces/ERC721TokenReceiver.sol";

import "../contracts_common/BaseWithStorage/SuperOperators.sol";

// using double loop for transfer
contract ERC1155ERC721Test is SuperOperators, ERC1155, ERC721 {
    using AddressUtils for address;
    using ObjectLib32 for ObjectLib32.Operations;
    using ObjectLib32 for uint256;

    bytes4 private constant ERC1155_IS_RECEIVER = 0x4e2312e0;
    bytes4 private constant ERC1155_RECEIVED = 0xf23a6e61;
    bytes4 private constant ERC1155_BATCH_RECEIVED = 0xbc197c81;
    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

    uint256 private constant CREATOR_OFFSET_MULTIPLIER = uint256(2)**(256 - 160);
    uint256 private constant IS_NFT_OFFSET_MULTIPLIER = uint256(2)**(256 - 160 - 1);
    uint256 private constant PACK_ID_OFFSET_MULTIPLIER = uint256(2)**(256 - 160 - 1 - 32 - 40);
    uint256 private constant PACK_NUM_FT_TYPES_OFFSET_MULTIPLIER = uint256(2)**(256 - 160 - 1 - 32 - 40 - 12);
    uint256 private constant NFT_INDEX_OFFSET = 63;

    uint256 private constant IS_NFT = 0x0000000000000000000000000000000000000000800000000000000000000000;
    uint256 private constant NOT_IS_NFT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFFFFFFFFFFF;
    uint256 private constant NFT_INDEX = 0x00000000000000000000000000000000000000007FFFFFFF8000000000000000;
    uint256 private constant NOT_NFT_INDEX = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF800000007FFFFFFFFFFFFFFF;
    uint256 private constant URI_ID = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000007FFFFFFFFFFFF800;
    uint256 private constant PACK_ID = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000007FFFFFFFFF800000;
    uint256 private constant PACK_INDEX = 0x00000000000000000000000000000000000000000000000000000000000007FF;
    uint256 private constant PACK_NUM_FT_TYPES = 0x00000000000000000000000000000000000000000000000000000000007FF800;

    uint256 private constant MAX_SUPPLY = uint256(2)**32 - 1;
    uint256 private constant MAX_PACK_SIZE = uint256(2)**11;

    event CreatorshipTransfer(address indexed original, address indexed from, address indexed to);

    mapping(address => uint256) private _numNFTPerAddress; // erc721
    mapping(uint256 => uint256) private _owners; // erc721
    mapping(address => mapping(uint256 => uint256)) private _packedTokenBalance; // erc1155
    mapping(address => mapping(address => bool)) private _operatorsForAll; // erc721 and erc1155
    mapping(uint256 => address) private _erc721operators; // erc721
    mapping(uint256 => bytes32) private _metadataHash; // erc721 and erc1155
    mapping(uint256 => bytes) private _rarityPacks; // rarity configuration per packs (2 bits per Asset)
    mapping(uint256 => uint32) private _nextCollectionIndex; // extraction

    mapping(address => address) private _creatorship; // creatorship transfer

    mapping(address => bool) private _bouncers; // the contracts allowed to mint
    mapping(address => bool) private _metaTransactionContracts; // native meta-transaction support

    address private _bouncerAdmin;

    constructor(
        address metaTransactionContract,
        address admin,
        address bouncerAdmin
    ) public {
        _metaTransactionContracts[metaTransactionContract] = true;
        _admin = admin;
        _bouncerAdmin = bouncerAdmin;
        emit MetaTransactionProcessor(metaTransactionContract, true);
    }

    event BouncerAdminChanged(address oldBouncerAdmin, address newBouncerAdmin);

    /// @notice Returns the current administrator in charge of minting rights.
    /// @return the current minting administrator in charge of minting rights.
    function getBouncerAdmin() external view returns (address) {
        return _bouncerAdmin;
    }

    /// @notice Change the minting administrator to be `newBouncerAdmin`.
    /// @param newBouncerAdmin address of the new minting administrator.
    function changeBouncerAdmin(address newBouncerAdmin) external {
        require(msg.sender == _bouncerAdmin, "only bouncerAdmin can change itself");
        emit BouncerAdminChanged(_bouncerAdmin, newBouncerAdmin);
        _bouncerAdmin = newBouncerAdmin;
    }

    event Bouncer(address bouncer, bool enabled);

    /// @notice Enable or disable the ability of `bouncer` to mint tokens (minting bouncer rights).
    /// @param bouncer address that will be given/removed minting bouncer rights.
    /// @param enabled set whether the address is enabled or disabled as a minting bouncer.
    function setBouncer(address bouncer, bool enabled) external {
        require(msg.sender == _bouncerAdmin, "only bouncerAdmin can setup bouncers");
        _bouncers[bouncer] = enabled;
        emit Bouncer(bouncer, enabled);
    }

    /// @notice check whether address `who` is given minting bouncer rights.
    /// @param who The address to query.
    /// @return whether the address has minting rights.
    function isBouncer(address who) external view returns (bool) {
        return _bouncers[who];
    }

    event MetaTransactionProcessor(address metaTransactionProcessor, bool enabled);

    /// @notice Enable or disable the ability of `metaTransactionProcessor` to perform meta-tx (metaTransactionProcessor rights).
    /// @param metaTransactionProcessor address that will be given/removed metaTransactionProcessor rights.
    /// @param enabled set whether the metaTransactionProcessor is enabled or disabled.
    function setMetaTransactionProcessor(address metaTransactionProcessor, bool enabled) external {
        require(msg.sender == _admin, "only admin can setup metaTransactionProcessors");
        _metaTransactionContracts[metaTransactionProcessor] = enabled;
        emit MetaTransactionProcessor(metaTransactionProcessor, enabled);
    }

    /// @notice check whether address `who` is given meta-transaction execution rights.
    /// @param who The address to query.
    /// @return whether the address has meta-transaction execution rights.
    function isMetaTransactionProcessor(address who) external view returns (bool) {
        return _metaTransactionContracts[who];
    }

    /// @notice Mint a token type for `creator` on slot `packId`.
    /// @param creator address of the creator of the token.
    /// @param packId unique packId for that token.
    /// @param hash hash of an IPFS cidv1 folder that contains the metadata of the token type in the file 0.json.
    /// @param supply number of tokens minted for that token type.
    /// @param rarity rarity power of the token.
    /// @param owner address that will receive the tokens.
    /// @param data extra data to accompany the minting call.
    /// @return the id of the newly minted token type.
    function mint(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint256 supply,
        uint8 rarity,
        address owner,
        bytes calldata data
    ) external returns (uint256 id) {
        require(hash != 0, "hash is zero");
        require(_bouncers[msg.sender], "only bouncer allowed to mint");
        require(owner != address(0), "destination is zero address");
        id = generateTokenId(creator, supply, packId, supply == 1 ? 0 : 1, 0);
        _mint(hash, supply, rarity, msg.sender, owner, id, data, false);
    }

    function generateTokenId(
        address creator,
        uint256 supply,
        uint40 packId,
        uint16 numFTs,
        uint16 packIndex
    ) internal pure returns (uint256) {
        require(supply > 0 && supply <= MAX_SUPPLY, "invalid supply");

        return
            uint256(creator) *
            CREATOR_OFFSET_MULTIPLIER + // CREATOR
            (supply == 1 ? uint256(1) * IS_NFT_OFFSET_MULTIPLIER : 0) + // minted as NFT (1) or FT (0) // IS_NFT
            uint256(packId) *
            PACK_ID_OFFSET_MULTIPLIER + // packId (unique pack) // PACk_ID
            numFTs *
            PACK_NUM_FT_TYPES_OFFSET_MULTIPLIER + // number of fungible token in the pack // PACK_NUM_FT_TYPES
            packIndex; // packIndex (position in the pack) // PACK_INDEX
    }

    function _mint(
        bytes32 hash,
        uint256 supply,
        uint8 rarity,
        address operator,
        address owner,
        uint256 id,
        bytes memory data,
        bool extraction
    ) internal {
        uint256 uriId = id & URI_ID;
        if (!extraction) {
            require(uint256(_metadataHash[uriId]) == 0, "id already used");
            _metadataHash[uriId] = hash;
            require(rarity < 4, "rarity >= 4");
            bytes memory pack = new bytes(1);
            pack[0] = bytes1(rarity * 64);
            _rarityPacks[uriId] = pack;
        }
        if (supply == 1) {
            // ERC721
            _numNFTPerAddress[owner]++;
            _owners[id] = uint256(owner);
            emit Transfer(address(0), owner, id);
        } else {
            (uint256 bin, uint256 index) = id.getTokenBinIndex();
            _packedTokenBalance[owner][bin] = _packedTokenBalance[owner][bin].updateTokenBalance(
                index,
                supply,
                ObjectLib32.Operations.REPLACE
            );
        }

        emit TransferSingle(operator, address(0), owner, id, supply);
        require(
            _checkERC1155AndCallSafeTransfer(operator, address(0), owner, id, supply, data, false, false),
            "transfer rejected"
        );
    }

    /// @notice Mint multiple token types for `creator` on slot `packId`.
    /// @param creator address of the creator of the tokens.
    /// @param packId unique packId for the tokens.
    /// @param hash hash of an IPFS cidv1 folder that contains the metadata of each token type in the files: 0.json, 1.json, 2.json, etc...
    /// @param supplies number of tokens minted for each token type.
    /// @param rarityPack rarity power of each token types packed into 2 bits each.
    /// @param owner address that will receive the tokens.
    /// @param data extra data to accompany the minting call.
    /// @return the ids of each newly minted token types.
    function mintMultiple(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint256[] calldata supplies,
        bytes calldata rarityPack,
        address owner,
        bytes calldata data
    ) external returns (uint256[] memory ids) {
        require(hash != 0, "hash is zero");
        require(_bouncers[msg.sender], "only bouncer allowed to mint");
        require(owner != address(0), "destination is zero address");
        uint16 numNFTs;
        (ids, numNFTs) = allocateIds(creator, supplies, rarityPack, packId, hash);
        _mintBatches(supplies, owner, ids, numNFTs);
        completeMultiMint(msg.sender, owner, ids, supplies, data);
    }

    function allocateIds(
        address creator,
        uint256[] memory supplies,
        bytes memory rarityPack,
        uint40 packId,
        bytes32 hash
    ) internal returns (uint256[] memory ids, uint16 numNFTs) {
        require(supplies.length > 0, "supplies.length == 0");
        require(supplies.length <= MAX_PACK_SIZE, "too big batch");
        (ids, numNFTs) = generateTokenIds(creator, supplies, packId);
        uint256 uriId = ids[0] & URI_ID;
        require(uint256(_metadataHash[uriId]) == 0, "id already used");
        _metadataHash[uriId] = hash;
        _rarityPacks[uriId] = rarityPack;
    }

    function generateTokenIds(
        address creator,
        uint256[] memory supplies,
        uint40 packId
    ) internal pure returns (uint256[] memory, uint16) {
        uint16 numTokenTypes = uint16(supplies.length);
        uint256[] memory ids = new uint256[](numTokenTypes);
        uint16 numNFTs = 0;
        for (uint16 i = 0; i < numTokenTypes; i++) {
            if (numNFTs == 0) {
                if (supplies[i] == 1) {
                    numNFTs = uint16(numTokenTypes - i);
                }
            } else {
                require(supplies[i] == 1, "NFTs need to be put at the end");
            }
        }
        uint16 numFTs = numTokenTypes - numNFTs;
        for (uint16 i = 0; i < numTokenTypes; i++) {
            ids[i] = generateTokenId(creator, supplies[i], packId, numFTs, i);
        }
        return (ids, numNFTs);
    }

    function completeMultiMint(
        address operator,
        address owner,
        uint256[] memory ids,
        uint256[] memory supplies,
        bytes memory data
    ) internal {
        emit TransferBatch(operator, address(0), owner, ids, supplies);
        require(
            _checkERC1155AndCallSafeBatchTransfer(operator, address(0), owner, ids, supplies, data),
            "transfer rejected"
        );
    }

    function _mintBatches(
        uint256[] memory supplies,
        address owner,
        uint256[] memory ids,
        uint16 numNFTs
    ) internal {
        uint16 offset = 0;
        while (offset < supplies.length - numNFTs) {
            _mintBatch(offset, supplies, owner, ids);
            offset += 8;
        }
        // deal with NFT last. they do not care of balance packing
        if (numNFTs > 0) {
            _mintNFTs(uint16(supplies.length - numNFTs), numNFTs, owner, ids);
        }
    }

    function _mintNFTs(
        uint16 offset,
        uint32 numNFTs,
        address owner,
        uint256[] memory ids
    ) internal {
        for (uint16 i = 0; i < numNFTs; i++) {
            uint256 id = ids[i + offset];
            _owners[id] = uint256(owner);
            emit Transfer(address(0), owner, id);
        }
        _numNFTPerAddress[owner] += numNFTs;
    }

    function _mintBatch(
        uint16 offset,
        uint256[] memory supplies,
        address owner,
        uint256[] memory ids
    ) internal {
        uint256 firstId = ids[offset];
        (uint256 bin, uint256 index) = firstId.getTokenBinIndex();
        uint256 balances = _packedTokenBalance[owner][bin];
        for (uint256 i = 0; i < 8 && offset + i < supplies.length; i++) {
            uint256 j = offset + i;
            if (supplies[j] > 1) {
                balances = balances.updateTokenBalance(index + i, supplies[j], ObjectLib32.Operations.REPLACE);
            } else {
                break;
            }
        }
        _packedTokenBalance[owner][bin] = balances;
    }

    function _transferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value
    ) internal {
        require(to != address(0), "destination is zero address");
        require(from != address(0), "from is zero address");
        bool authorized = from == msg.sender ||
            _superOperators[msg.sender] ||
            _operatorsForAll[from][msg.sender] ||
            _metaTransactionContracts[msg.sender]; // solium-disable-line max-len

        if (id & IS_NFT > 0) {
            require(authorized || _erc721operators[id] == msg.sender, "Operator not approved");
            if (value > 0) {
                require(value == 1, "cannot transfer nft if amount not 1");
                _numNFTPerAddress[from]--;
                _numNFTPerAddress[to]++;
                _owners[id] = uint256(to);
                if (_erc721operators[id] != address(0)) {
                    // TODO operatorEnabled flag optimization (like in ERC721BaseToken)
                    _erc721operators[id] = address(0);
                }
                emit Transfer(from, to, id);
            }
        } else {
            require(authorized, "Operator not approved");
            if (value > 0) {
                // if different owners it will fails
                (uint256 bin, uint256 index) = id.getTokenBinIndex();
                _packedTokenBalance[from][bin] = _packedTokenBalance[from][bin].updateTokenBalance(
                    index,
                    value,
                    ObjectLib32.Operations.SUB
                );
                _packedTokenBalance[to][bin] = _packedTokenBalance[to][bin].updateTokenBalance(
                    index,
                    value,
                    ObjectLib32.Operations.ADD
                );
            }
        }

        emit TransferSingle(_metaTransactionContracts[msg.sender] ? from : msg.sender, from, to, id, value);
    }

    /// @notice Transfers `value` tokens of type `id` from  `from` to `to`  (with safety call).
    /// @param from address from which tokens are transfered.
    /// @param to address to which the token will be transfered.
    /// @param id the token type transfered.
    /// @param value amount of token transfered.
    /// @param data aditional data accompanying the transfer.
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external {
        if (id & IS_NFT > 0) {
            require(_ownerOf(id) == from, "not owner");
        }
        _transferFrom(from, to, id, value);
        require(
            _checkERC1155AndCallSafeTransfer(
                _metaTransactionContracts[msg.sender] ? from : msg.sender,
                from,
                to,
                id,
                value,
                data,
                false,
                false
            ),
            "erc1155 transfer rejected"
        );
    }

    /// @notice Transfers `values` tokens of type `ids` from  `from` to `to` (with safety call).
    /// @dev call data should be optimized to order ids so packedBalance can be used efficiently.
    /// @param from address from which tokens are transfered.
    /// @param to address to which the token will be transfered.
    /// @param ids ids of each token type transfered.
    /// @param values amount of each token type transfered.
    /// @param data aditional data accompanying the transfer.
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external {
        require(ids.length == values.length, "Inconsistent array length between args");
        require(to != address(0), "destination is zero address");
        require(from != address(0), "from is zero address");
        bool authorized = from == msg.sender ||
            _superOperators[msg.sender] ||
            _operatorsForAll[from][msg.sender] ||
            _metaTransactionContracts[msg.sender]; // solium-disable-line max-len

        _changeBalancesFor(from, to, ids, values, ObjectLib32.Operations.SUB, authorized);
        _changeBalancesFor(from, to, ids, values, ObjectLib32.Operations.ADD, authorized);
        // if (from == to) {
        //     _batchTransferToSelf(from, ids, values, authorized);
        // } else {
        //     _batchTransferFrom(from, to, ids, values, authorized);
        // }
        emit TransferBatch(_metaTransactionContracts[msg.sender] ? from : msg.sender, from, to, ids, values);
        require(
            _checkERC1155AndCallSafeBatchTransfer(
                _metaTransactionContracts[msg.sender] ? from : msg.sender,
                from,
                to,
                ids,
                values,
                data
            ),
            "erc1155 transfer rejected"
        );
    }

    // mapping(address => mapping(uint256 => uint256)) private _selfPackedTokenBalance;
    // function _batchTransferToSelf(
    //     address from,
    //     uint256[] memory ids,
    //     uint256[] memory values,
    //     bool authorized
    // ) internal {
    //     uint256 numItems = ids.length;

    //     uint256 bin;
    //     uint256 index;
    //     uint256 numTokensTransferedPerType;
    //     uint256 lastBin;
    //     for (uint256 i = 0; i < numItems; i++) {
    //         bool isNFT = ids[i] & IS_NFT > 0;
    //         require(authorized || (isNFT && _erc721operators[ids[i]] == msg.sender), "Operator not approved");
    //         if(values[i] > 0) {
    //             (bin, index) = ids[i].getTokenBinIndex();
    //             if (lastBin == 0) {
    //                 lastBin = bin;
    //                 numTokensTransferedPerType = ObjectLib32.updateTokenBalance(
    //                     _selfPackedTokenBalance[from][bin],
    //                     index,
    //                     values[i],
    //                     ObjectLib32.Operations.ADD
    //                 );
    //             } else {
    //                 if (bin != lastBin) {
    //                     _selfPackedTokenBalance[from][lastBin] = numTokensTransferedPerType;
    //                     numTokensTransferedPerType = _selfPackedTokenBalance[from][bin];
    //                     lastBin = bin;
    //                 }
    //                 numTokensTransferedPerType = numTokensTransferedPerType.updateTokenBalance(
    //                     index,
    //                     values[i],
    //                     ObjectLib32.Operations.ADD
    //                 );
    //             }
    //             if (isNFT) {
    //                 require(numTokensTransferedPerType.getValueInBin(index) == 1, "cannot transfer an NFT more than once");
    //                 require(_ownerOf(ids[i]) == from, "not owner");
    //                 if (_erc721operators[ids[i]] != address(0)) { // TODO operatorEnabled flag optimization (like in ERC721BaseToken)
    //                     _erc721operators[ids[i]] = address(0);
    //                 }
    //                 emit Transfer(from, from, ids[i]);
    //             } else {
    //                 require(numTokensTransferedPerType.getValueInBin(index) <= _packedTokenBalance[from][bin].getValueInBin(index), "too many transfered");
    //             }
    //         }
    //     }
    //     for (uint256 i = 0; i < numItems; i++) {
    //         (uint256 binToErase, ) = ids[i].getTokenBinIndex();
    //         _selfPackedTokenBalance[from][binToErase] = 0;
    //     }
    // }

    function _changeBalancesFor(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        ObjectLib32.Operations operation,
        bool authorized
    ) internal {
        address current = operation == ObjectLib32.Operations.SUB ? from : to;
        uint256 numItems = ids.length;
        uint256 bin;
        uint256 index;
        uint256 bal;
        uint256 lastBin;
        uint256 numNFTs = 0;
        for (uint256 i = 0; i < numItems; i++) {
            if (ids[i] & IS_NFT > 0) {
                if (operation == ObjectLib32.Operations.SUB) {
                    require(authorized || _erc721operators[ids[i]] == msg.sender, "Operator not approved");
                }
                if (values[i] > 0) {
                    numNFTs++;
                    if (operation == ObjectLib32.Operations.SUB) {
                        require(values[i] == 1, "cannot transfer nft if amount not 1");
                        if (from == to) {
                            require(_ownerOf(ids[i]) == from, "not owner in batch");
                            _owners[ids[i]] = 0;
                        }
                        if (_erc721operators[ids[i]] != address(0)) {
                            // TODO operatorEnabled flag optimization (like in ERC721BaseToken)
                            _erc721operators[ids[i]] = address(0);
                        }
                    } else {
                        // assume it will be only ADD
                        if (from != to) {
                            require(_ownerOf(ids[i]) == from, "not owner in batch");
                        }
                        _owners[ids[i]] = uint256(to);
                        emit Transfer(from, to, ids[i]);
                    }
                }
            } else {
                require(authorized, "Operator not approved");
                if (values[i] > 0) {
                    (bin, index) = ids[i].getTokenBinIndex();
                    if (lastBin == 0) {
                        lastBin = bin;
                        bal = ObjectLib32.updateTokenBalance(
                            _packedTokenBalance[current][bin],
                            index,
                            values[i],
                            operation
                        );
                    } else {
                        if (bin != lastBin) {
                            _packedTokenBalance[current][lastBin] = bal;
                            bal = _packedTokenBalance[current][bin];
                            lastBin = bin;
                        }
                        bal = bal.updateTokenBalance(index, values[i], operation);
                    }
                }
            }
        }
        if (numNFTs > 0) {
            if (operation == ObjectLib32.Operations.SUB) {
                _numNFTPerAddress[current] -= numNFTs;
            } else {
                // assume it will be only ADD
                _numNFTPerAddress[current] += numNFTs;
            }
        }

        if (bin != 0) {
            _packedTokenBalance[current][bin] = bal;
        }
    }

    // function _batchTransferFrom(
    //     address from,
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory values,
    //     bool authorized
    // ) internal {
    //     uint256 numItems = ids.length;
    //     uint256 bin;
    //     uint256 index;
    //     uint256 balFrom;
    //     uint256 balTo;

    //     uint256 lastBin;
    //     uint256 numNFTs = 0;
    //     for (uint256 i = 0; i < numItems; i++) {
    //         if (ids[i] & IS_NFT > 0) {
    //             require(
    //                 authorized || _erc721operators[ids[i]] == msg.sender,
    //                 "Operator not approved"
    //             );
    //             if(values[i] > 0) {
    //                 require(values[i] == 1, "cannot transfer nft if amount not 1");
    //                 require(_ownerOf(ids[i]) == from, "not owner");
    //                 numNFTs++;
    //                 _owners[ids[i]] = uint256(to);
    //                 if (_erc721operators[ids[i]] != address(0)) { // TODO operatorEnabled flag optimization (like in ERC721BaseToken)
    //                     _erc721operators[ids[i]] = address(0);
    //                 }
    //                 emit Transfer(from, to, ids[i]);
    //             }
    //         } else {
    //             require(authorized, "Operator not approved");
    //             if(values[i] > 0) {
    //                 (bin, index) = ids[i].getTokenBinIndex();
    //                 if (lastBin == 0) {
    //                     lastBin = bin;
    //                     balFrom = ObjectLib32.updateTokenBalance(
    //                         _packedTokenBalance[from][bin],
    //                         index,
    //                         values[i],
    //                         ObjectLib32.Operations.SUB
    //                     );
    //                     balTo = ObjectLib32.updateTokenBalance(
    //                         _packedTokenBalance[to][bin],
    //                         index,
    //                         values[i],
    //                         ObjectLib32.Operations.ADD
    //                     );
    //                 } else {
    //                     if (bin != lastBin) {
    //                         _packedTokenBalance[from][lastBin] = balFrom;
    //                         _packedTokenBalance[to][lastBin] = balTo;
    //                         balFrom = _packedTokenBalance[from][bin];
    //                         balTo = _packedTokenBalance[to][bin];
    //                         lastBin = bin;
    //                     }

    //                     balFrom = balFrom.updateTokenBalance(
    //                         index,
    //                         values[i],
    //                         ObjectLib32.Operations.SUB
    //                     );
    //                     balTo = balTo.updateTokenBalance(
    //                         index,
    //                         values[i],
    //                         ObjectLib32.Operations.ADD
    //                     );
    //                 }
    //             }
    //         }
    //     }
    //     if (numNFTs > 0) {
    //         _numNFTPerAddress[from] -= numNFTs;
    //         _numNFTPerAddress[to] += numNFTs;
    //     }

    //     if (bin != 0) {
    //         _packedTokenBalance[from][bin] = balFrom;
    //         _packedTokenBalance[to][bin] = balTo;
    //     }
    // }

    /// @notice Get the balance of `owner` for the token type `id`.
    /// @param owner The address of the token holder.
    /// @param id the token type of which to get the balance of.
    /// @return the balance of `owner` for the token type `id`.
    function balanceOf(address owner, uint256 id) public view returns (uint256) {
        // do not check for existence, balance is zero if never minted
        // require(wasEverMinted(id), "token was never minted");
        if (id & IS_NFT > 0) {
            if (_ownerOf(id) == owner) {
                return 1;
            } else {
                return 0;
            }
        }
        (uint256 bin, uint256 index) = id.getTokenBinIndex();
        return _packedTokenBalance[owner][bin].getValueInBin(index);
    }

    /// @notice Get the balance of `owners` for each token type `ids`.
    /// @param owners the addresses of the token holders queried.
    /// @param ids ids of each token type to query.
    /// @return the balance of each `owners` for each token type `ids`.
    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory)
    {
        require(owners.length == ids.length, "Inconsistent array length between args");
        uint256[] memory balances = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            balances[i] = balanceOf(owners[i], ids[i]);
        }
        return balances;
    }

    /// @notice Get the creator of the token type `id`.
    /// @param id the id of the token to get the creator of.
    /// @return the creator of the token type `id`.
    function creatorOf(uint256 id) external view returns (address) {
        require(wasEverMinted(id), "token was never minted");
        address originalCreator = address(id / CREATOR_OFFSET_MULTIPLIER);
        address newCreator = _creatorship[originalCreator];
        if (newCreator != address(0)) {
            return newCreator;
        }
        return originalCreator;
    }

    /// @notice Transfers creatorship of `original` from `sender` to `to`.
    /// @param sender address of current registered creator.
    /// @param original address of the original creator whose creation are saved in the ids themselves.
    /// @param to address which will be given creatorship for all tokens originally minted by `original`.
    function transferCreatorship(
        address sender,
        address original,
        address to
    ) external {
        require(
            msg.sender == sender || _metaTransactionContracts[msg.sender] || _superOperators[msg.sender],
            "require meta approval"
        );
        require(sender != address(0), "sender is zero address");
        require(to != address(0), "destination is zero address");
        address current = _creatorship[original];
        if (current == address(0)) {
            current = original;
        }
        require(current != to, "current == to");
        require(current == sender, "current != sender");
        if (to == original) {
            _creatorship[original] = address(0);
        } else {
            _creatorship[original] = to;
        }
        emit CreatorshipTransfer(original, current, to);
    }

    /// @notice Enable or disable approval for `operator` to manage all `sender`'s tokens.
    /// @dev used for Meta Transaction (from metaTransactionContract).
    /// @param sender address which grant approval.
    /// @param operator address which will be granted rights to transfer all token owned by `sender`.
    /// @param approved whether to approve or revoke.
    function setApprovalForAllFor(
        address sender,
        address operator,
        bool approved
    ) external {
        require(
            msg.sender == sender || _metaTransactionContracts[msg.sender] || _superOperators[msg.sender],
            "require meta approval"
        );
        _setApprovalForAll(sender, operator, approved);
    }

    /// @notice Enable or disable approval for `operator` to manage all of the caller's tokens.
    /// @param operator address which will be granted rights to transfer all tokens of the caller.
    /// @param approved whether to approve or revoke
    function setApprovalForAll(address operator, bool approved) external {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function _setApprovalForAll(
        address sender,
        address operator,
        bool approved
    ) internal {
        require(sender != address(0), "sender is zero address");
        require(sender != operator, "sender = operator");
        require(operator != address(0), "operator is zero address");
        require(!_superOperators[operator], "super operator can't have their approvalForAll changed");
        _operatorsForAll[sender][operator] = approved;
        emit ApprovalForAll(sender, operator, approved);
    }

    /// @notice Queries the approval status of `operator` for owner `owner`.
    /// @param owner the owner of the tokens.
    /// @param operator address of authorized operator.
    /// @return true if the operator is approved, false if not.
    function isApprovedForAll(address owner, address operator) external view returns (bool isOperator) {
        require(owner != address(0), "owner is zero address");
        require(operator != address(0), "operator is zero address");
        return _operatorsForAll[owner][operator] || _superOperators[operator];
    }

    /// @notice Count all NFTs assigned to `owner`.
    /// @param owner address for whom to query the balance.
    /// @return the number of NFTs owned by `owner`, possibly zero.
    function balanceOf(address owner) external view returns (uint256 balance) {
        require(owner != address(0), "owner is zero address");
        return _numNFTPerAddress[owner];
    }

    /// @notice Find the owner of an NFT.
    /// @param id the identifier for an NFT.
    /// @return the address of the owner of the NFT.
    function ownerOf(uint256 id) external view returns (address owner) {
        owner = _ownerOf(id);
        require(owner != address(0), "NFT does not exist");
    }

    function _ownerOf(uint256 id) internal view returns (address) {
        return address(_owners[id]);
    }

    /// @notice Change or reaffirm the approved address for an NFT for `sender`.
    /// @dev used for Meta Transaction (from metaTransactionContract).
    /// @param sender the sender granting control.
    /// @param operator the address to approve as NFT controller.
    /// @param id the NFT to approve.
    function approveFor(
        address sender,
        address operator,
        uint256 id
    ) external {
        address owner = _ownerOf(id);
        require(sender != address(0), "sender is zero address");
        require(
            msg.sender == sender ||
                _metaTransactionContracts[msg.sender] ||
                _superOperators[msg.sender] ||
                _operatorsForAll[sender][msg.sender],
            "require operators"
        ); // solium-disable-line max-len
        require(owner == sender, "not owner");
        _erc721operators[id] = operator;
        emit Approval(owner, operator, id);
    }

    /// @notice Change or reaffirm the approved address for an NFT.
    /// @param operator the address to approve as NFT controller.
    /// @param id the id of the NFT to approve.
    function approve(address operator, uint256 id) external {
        address owner = _ownerOf(id);
        require(owner != address(0), "NFT does not exist");
        require(
            owner == msg.sender || _superOperators[msg.sender] || _operatorsForAll[owner][msg.sender],
            "not authorized"
        );
        _erc721operators[id] = operator;
        emit Approval(owner, operator, id);
    }

    /// @notice Get the approved address for a single NFT.
    /// @param id the NFT to find the approved address for.
    /// @return the approved address for this NFT, or the zero address if there is none.
    function getApproved(uint256 id) external view returns (address operator) {
        require(_ownerOf(id) != address(0), "NFT does not exist");
        return _erc721operators[id];
    }

    /// @notice Transfers ownership of an NFT.
    /// @param from the current owner of the NFT.
    /// @param to the new owner.
    /// @param id the NFT to transfer.
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) external {
        require(_ownerOf(id) == from, "not owner");
        _transferFrom(from, to, id, 1);
        require(
            _checkERC1155AndCallSafeTransfer(
                _metaTransactionContracts[msg.sender] ? from : msg.sender,
                from,
                to,
                id,
                1,
                "",
                true,
                false
            ),
            "erc1155 transfer rejected"
        );
    }

    /// @notice Transfers the ownership of an NFT from one address to another address.
    /// @param from the current owner of the NFT.
    /// @param to the new owner.
    /// @param id the NFT to transfer.
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) external {
        safeTransferFrom(from, to, id, "");
    }

    /// @notice Transfers the ownership of an NFT from one address to another address.
    /// @param from the current owner of the NFT.
    /// @param to the new owner.
    /// @param id the NFT to transfer.
    /// @param data additional data with no specified format, sent in call to `to`.
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public {
        require(_ownerOf(id) == from, "not owner");
        _transferFrom(from, to, id, 1);
        require(
            _checkERC1155AndCallSafeTransfer(
                _metaTransactionContracts[msg.sender] ? from : msg.sender,
                from,
                to,
                id,
                1,
                data,
                true,
                true
            ),
            "erc721/erc1155 transfer rejected"
        );
    }

    /// @notice A descriptive name for the collection of tokens in this contract.
    /// @return the name of the tokens.
    function name() external pure returns (string memory _name) {
        return "Wonderland's ASSETs";
    }

    /// @notice An abbreviated name for the collection of tokens in this contract.
    /// @return the symbol of the tokens.
    function symbol() external pure returns (string memory _symbol) {
        return "ASSET";
    }

    /// @notice Gives the rarity power of a particular token type.
    /// @param id the token type to get the rarity of.
    /// @return the rarity power(between 0 and 3).
    function rarity(uint256 id) public view returns (uint256) {
        require(wasEverMinted(id), "token was never minted");
        bytes storage rarityPack = _rarityPacks[id & URI_ID];
        uint256 packIndex = id & PACK_INDEX;
        if (packIndex / 4 >= rarityPack.length) {
            return 0;
        } else {
            uint8 pack = uint8(rarityPack[packIndex / 4]);
            uint8 i = (3 - uint8(packIndex % 4)) * 2;
            return (pack / (uint8(2)**i)) % 4;
        }
    }

    /// @notice Gives the collection a specific token belongs to.
    /// @param id the token to get the collection of.
    /// @return the collection the NFT is part of.
    function collectionOf(uint256 id) public view returns (uint256) {
        require(_ownerOf(id) != address(0), "NFT does not exist");
        uint256 collectionId = id & NOT_NFT_INDEX & NOT_IS_NFT;
        require(wasEverMinted(collectionId), "no collection ever minted for that token");
        return collectionId;
    }

    /// @notice Return wether the id is a collection
    /// @param id collectionId to check.
    /// @return whether the id is a collection.
    function isCollection(uint256 id) public view returns (bool) {
        uint256 collectionId = id & NOT_NFT_INDEX & NOT_IS_NFT;
        return wasEverMinted(collectionId);
    }

    /// @notice Gives the index at which an NFT was minted in a collection : first of a collection get the zero index.
    /// @param id the token to get the index of.
    /// @return the index/order at which the token `id` was minted in a collection.
    function collectionIndexOf(uint256 id) public view returns (uint256) {
        collectionOf(id); // this check if id and collection indeed was ever minted
        return uint32((id & NFT_INDEX) >> NFT_INDEX_OFFSET);
    }

    function toFullURI(bytes32 hash, uint256 id) internal pure returns (string memory) {
        return string(abi.encodePacked("ipfs://bafybei", hash2base32(hash), "/", uint2str(id & PACK_INDEX), ".json"));
    }

    function wasEverMinted(uint256 id) public view returns (bool) {
        if ((id & IS_NFT) > 0) {
            return _owners[id] != 0;
        } else {
            return
                ((id & PACK_INDEX) < ((id & PACK_NUM_FT_TYPES) / PACK_NUM_FT_TYPES_OFFSET_MULTIPLIER)) &&
                _metadataHash[id & URI_ID] != 0;
        }
    }

    /// @notice A distinct Uniform Resource Identifier (URI) for a given token.
    /// @param id token to get the uri of.
    /// @return URI string
    function uri(uint256 id) public view returns (string memory) {
        require(wasEverMinted(id), "token was never minted"); // prevent returning invalid uri
        return toFullURI(_metadataHash[id & URI_ID], id);
    }

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @param id token to get the uri of.
    /// @return URI string
    function tokenURI(uint256 id) public view returns (string memory) {
        require(_ownerOf(id) != address(0), "NFT does not exist");
        return toFullURI(_metadataHash[id & URI_ID], id);
    }

    bytes32 private constant base32Alphabet = 0x6162636465666768696A6B6C6D6E6F707172737475767778797A323334353637;

    // solium-disable-next-line security/no-assign-params
    function hash2base32(bytes32 hash) private pure returns (string memory _uintAsString) {
        uint256 _i = uint256(hash);
        uint256 k = 52;
        bytes memory bstr = new bytes(k);
        bstr[--k] = base32Alphabet[uint8((_i % 8) << 2)]; // uint8 s = uint8((256 - skip) % 5);  // (_i % (2**s)) << (5-s)
        _i /= 8;
        while (k > 0) {
            bstr[--k] = base32Alphabet[_i % 32];
            _i /= 32;
        }
        return string(bstr);
    }

    // solium-disable-next-line security/no-assign-params
    function uint2str(uint256 _i) private pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }

        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }

        return string(bstr);
    }

    /// @notice Query if a contract implements interface `id`.
    /// @param id the interface identifier, as specified in ERC-165.
    /// @return `true` if the contract implements `id`.
    function supportsInterface(bytes4 id) external view returns (bool) {
        return
            id == 0x01ffc9a7 || //ERC165
            id == 0xd9b67a26 || // ERC1155
            id == 0x80ac58cd || // ERC721
            id == 0x5b5e139f || // ERC721 metadata
            id == 0x0e89341c; // ERC1155 metadata
    }

    bytes4 constant ERC165ID = 0x01ffc9a7;

    function checkIsERC1155Receiver(address _contract) internal view returns (bool) {
        bool success;
        bool result;
        bytes memory call_data = abi.encodeWithSelector(ERC165ID, ERC1155_IS_RECEIVER);
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let call_ptr := add(0x20, call_data)
            let call_size := mload(call_data)
            let output := mload(0x40) // Find empty storage location using "free memory pointer"
            mstore(output, 0x0)
            success := staticcall(10000, _contract, call_ptr, call_size, output, 0x20) // 32 bytes
            result := mload(output)
        }
        // (10000 / 63) "not enough for supportsInterface(...)" // consume all gas, so caller can potentially know that there was not enough gas
        assert(gasleft() > 158);
        return success && result;
    }

    function _checkERC1155AndCallSafeTransfer(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data,
        bool erc721,
        bool erc721Safe
    ) internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        if (erc721) {
            if (!checkIsERC1155Receiver(to)) {
                if (erc721Safe) {
                    return _checkERC721AndCallSafeTransfer(operator, from, to, id, data);
                } else {
                    return true;
                }
            }
        }
        return ERC1155TokenReceiver(to).onERC1155Received(operator, from, id, value, data) == ERC1155_RECEIVED;
    }

    function _checkERC1155AndCallSafeBatchTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        bytes4 retval = ERC1155TokenReceiver(to).onERC1155BatchReceived(operator, from, ids, values, data);
        return (retval == ERC1155_BATCH_RECEIVED);
    }

    function _checkERC721AndCallSafeTransfer(
        address operator,
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) internal returns (bool) {
        // following not required as this function is always called as part of ERC1155 checks that include such check already
        // if (!to.isContract()) {
        //     return true;
        // }
        return (ERC721TokenReceiver(to).onERC721Received(operator, from, id, data) == ERC721_RECEIVED);
    }

    event Extraction(uint256 indexed fromId, uint256 toId);
    event AssetUpdate(uint256 indexed fromId, uint256 toId);

    function _burnERC1155(
        address operator,
        address from,
        uint256 id,
        uint32 amount
    ) internal {
        (uint256 bin, uint256 index) = (id).getTokenBinIndex();
        _packedTokenBalance[from][bin] = _packedTokenBalance[from][bin].updateTokenBalance(
            index,
            amount,
            ObjectLib32.Operations.SUB
        );
        emit TransferSingle(operator, from, address(0), id, amount);
    }

    function _burnERC721(
        address operator,
        address from,
        uint256 id
    ) internal {
        require(from == _ownerOf(id), "not owner");
        _owners[id] = 2**160; // equivalent to zero address when casted but ensure we track minted status
        _numNFTPerAddress[from]--;
        emit Transfer(from, address(0), id);
        emit TransferSingle(operator, from, address(0), id, 1);
    }

    /// @notice Burns `amount` tokens of type `id`.
    /// @param id token type which will be burnt.
    /// @param amount amount of token to burn.
    function burn(uint256 id, uint256 amount) external {
        _burn(msg.sender, id, amount);
    }

    /// @notice Burns `amount` tokens of type `id` from `from`.
    /// @param from address whose token is to be burnt.
    /// @param id token type which will be burnt.
    /// @param amount amount of token to burn.
    function burnFrom(
        address from,
        uint256 id,
        uint256 amount
    ) external {
        require(from != address(0), "from is zero address");
        require(
            msg.sender == from ||
                _metaTransactionContracts[msg.sender] ||
                _superOperators[msg.sender] ||
                _operatorsForAll[from][msg.sender],
            "require meta approval"
        );
        _burn(from, id, amount);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal {
        if ((id & IS_NFT) > 0) {
            require(amount == 1, "can only burn one NFT");
            _burnERC721(_metaTransactionContracts[msg.sender] ? from : msg.sender, from, id);
        } else {
            require(amount > 0 && amount <= MAX_SUPPLY, "invalid amount");
            _burnERC1155(_metaTransactionContracts[msg.sender] ? from : msg.sender, from, id, uint32(amount));
        }
    }

    /// @notice Upgrades an NFT with new metadata and rarity.
    /// @param from address which own the NFT to be upgraded.
    /// @param id the NFT that will be burnt to be upgraded.
    /// @param packId unqiue packId for the token.
    /// @param hash hash of an IPFS cidv1 folder that contains the metadata of the new token type in the file 0.json.
    /// @param newRarity rarity power of the new NFT.
    /// @param to address which will receive the NFT.
    /// @param data bytes to be transmitted as part of the minted token.
    /// @return the id of the newly minted NFT.
    function updateERC721(
        address from,
        uint256 id,
        uint40 packId,
        bytes32 hash,
        uint8 newRarity,
        address to,
        bytes calldata data
    ) external returns (uint256) {
        require(hash != 0, "hash is zero");
        require(_bouncers[msg.sender], "only bouncer allowed to mint via update");
        require(to != address(0), "destination is zero address");
        require(from != address(0), "from is zero address");

        _burnERC721(msg.sender, from, id);

        uint256 newId = generateTokenId(from, 1, packId, 0, 0);
        _mint(hash, 1, newRarity, msg.sender, to, newId, data, false);
        emit AssetUpdate(id, newId);
        return newId;
    }

    /// @notice Extracts an EIP-721 NFT from an EIP-1155 token.
    /// @param id the token type to extract from.
    /// @param to address which will receive the token.
    /// @return the id of the newly minted NFT.
    function extractERC721(uint256 id, address to) external returns (uint256 newId) {
        return _extractERC721From(msg.sender, msg.sender, id, to);
    }

    /// @notice Extracts an EIP-721 NFT from an EIP-1155 token.
    /// @param sender address which own the token to be extracted.
    /// @param id the token type to extract from.
    /// @param to address which will receive the token.
    /// @return the id of the newly minted NFT.
    function extractERC721From(
        address sender,
        uint256 id,
        address to
    ) external returns (uint256 newId) {
        require(
            msg.sender == sender ||
                _metaTransactionContracts[msg.sender] ||
                _superOperators[msg.sender] ||
                _operatorsForAll[sender][msg.sender],
            "require meta approval"
        );
        address operator = _metaTransactionContracts[msg.sender] ? sender : msg.sender;
        return _extractERC721From(operator, sender, id, to);
    }

    function _extractERC721From(
        address operator,
        address sender,
        uint256 id,
        address to
    ) internal returns (uint256 newId) {
        require(to != address(0), "destination is zero address");
        require(id & IS_NFT == 0, "Not an ERC1155 Token");
        uint32 tokenCollectionIndex = _nextCollectionIndex[id];
        newId = id + IS_NFT + (tokenCollectionIndex) * 2**NFT_INDEX_OFFSET;
        _nextCollectionIndex[id] = tokenCollectionIndex + 1;
        _burnERC1155(operator, sender, id, 1);
        _mint(_metadataHash[id & URI_ID], 1, 0, operator, to, newId, "", true);
        emit Extraction(id, newId);
    }
}

// from https://github.com/zeppelinos/zos/blob/1cea266a672a1efc31915420af5eb5185173837c/packages/lib/contracts/upgradeability/UpgradeabilityProxy.sol
pragma solidity ^0.5.2;

import "./ProxyBase.sol";
import "../Libraries/AddressUtils.sol";

/**
 * @title UpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract UpgradeabilityProxy is ProxyBase {
    /**
   * @dev Emitted when the implementation is upgraded.
   * @param implementation Address of the new implementation.
   */
    event Upgraded(address indexed implementation);

    /**
   * @dev Storage slot with the address of the current implementation.
   * This is the keccak-256 hash of "org.zeppelinos.proxy.implementation", and is
   * validated in the constructor.
   */
    bytes32 private constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

    /**
   * @dev Contract constructor.
   * @param _implementation Address of the initial implementation.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
    constructor(address _implementation, bytes memory _data) public payable {
        assert(
            IMPLEMENTATION_SLOT ==
                keccak256("org.zeppelinos.proxy.implementation")
        );
        _setImplementation(_implementation);
        if (_data.length > 0) {
            (bool success, bytes memory _) = _implementation.delegatecall(
                _data
            );
            require(success, "could not call the contract");
        }
    }

    /**
   * @dev Returns the current implementation.
   * @return Address of the current implementation
   */
    function _implementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    /**
   * @dev Upgrades the proxy to a new implementation.
   * @param newImplementation Address of the new implementation.
   */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
   * @dev Sets the implementation address of the proxy.
   * @param newImplementation Address of the new implementation.
   */
    function _setImplementation(address newImplementation) private {
        require(
            AddressUtils.isContract(newImplementation),
            "Cannot set a proxy implementation to a non-contract address"
        );

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}

// from https://github.com/zeppelinos/zos/blob/1cea266a672a1efc31915420af5eb5185173837c/packages/lib/contracts/upgradeability/Proxy.sol
pragma solidity ^0.5.2;

/**
 * @title ProxyBase
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
contract ProxyBase {
    /**
   * @dev Fallback function.
   * Implemented entirely in `_fallback`.
   */
    function() external payable {
        _fallback();
    }

    /**
   * @return The Address of the implementation.
   */
    function _implementation() internal view returns (address);

    /**
   * @dev Delegates execution to an implementation contract.
   * This is a low level function that doesn't return to its internal call site.
   * It will return to the external caller whatever the implementation returns.
   * @param implementation Address to delegate.
   */
    function _delegate(address implementation) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize)

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(
                gas,
                implementation,
                0,
                calldatasize,
                0,
                0
            )

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize)

            switch result
                // delegatecall returns 0 on error.
                case 0 {
                    revert(0, returndatasize)
                }
                default {
                    return(0, returndatasize)
                }
        }
    }

    /**
   * @dev Function that is run as the first thing in the fallback function.
   * Can be redefined in derived contracts to add functionality.
   * Redefinitions must call super._willFallback().
   */
    function _willFallback() internal {}

    /**
   * @dev fallback implementation.
   * Extracted to enable manual triggering.
   */
    function _fallback() internal {
        _willFallback();
        _delegate(_implementation());
    }
}

// from https://github.com/zeppelinos/zos/blob/1cea266a672a1efc31915420af5eb5185173837c/packages/lib/contracts/upgradeability/AdminUpgradeabilityProxy.sol
pragma solidity ^0.5.2;

import "./UpgradeabilityProxy.sol";
import "./ProxyAdmin.sol";

/**
 * @title AdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract AdminUpgradeabilityProxy is UpgradeabilityProxy {
    /**
   * @dev Emitted when the administration has been transferred.
   * @param previousAdmin Address of the previous admin.
   * @param newAdmin Address of the new admin.
   */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
   * @dev Storage slot with the admin of the contract.
   * This is the keccak-256 hash of "org.zeppelinos.proxy.admin", and is
   * validated in the constructor.
   */
    bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

    /**
   * @dev Modifier to check whether the `msg.sender` is the admin.
   * If it is, it will run the function. Otherwise, it will delegate the call
   * to the implementation.
   */
    modifier ifAdmin() {
        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
   * Contract constructor.
   * It sets the `msg.sender` as the proxy administrator.
   * @param _implementation address of the initial implementation.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
    constructor(
        address payable _owner,
        address _implementation,
        bytes memory _data
    ) public payable UpgradeabilityProxy(_implementation, _data) {
        assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));

        ProxyAdmin proxyAdmin = new ProxyAdmin(this, _owner); // TODO cheaper creation : https://eips.ethereum.org/EIPS/eip-1167
        emit AdminChanged(address(0), address(proxyAdmin));
        _setAdmin(address(proxyAdmin));
    }

    /**
   * @return The address of the proxy admin.
   */
    function admin() external ifAdmin returns (address) {
        return _admin();
    }

    /**
   * @return The address of the implementation.
   */
    function implementation() external ifAdmin returns (address) {
        return _implementation();
    }

    /**
   * @dev Changes the admin of the proxy.
   * Only the current admin can call this function.
   * @param newAdmin Address to transfer proxy administration to.
   */
    function changeAdmin(address newAdmin) external ifAdmin {
        require(
            newAdmin != address(0),
            "Cannot change the admin of a proxy to the zero address"
        );
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
   * @dev Upgrade the backing implementation of the proxy.
   * Only the admin can call this function.
   * @param newImplementation Address of the new implementation.
   */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeTo(newImplementation);
    }

    /**
   * @dev Upgrade the backing implementation of the proxy and call a function
   * on the new implementation.
   * This is useful to initialize the proxied contract.
   * @param newImplementation Address of the new implementation.
   * @param data Data to send as msg.data in the low level call.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   */
    function upgradeToAndCall(address newImplementation, bytes calldata data)
        external
        payable
        ifAdmin
    {
        _upgradeTo(newImplementation);
        (bool success, bytes memory _) = newImplementation.delegatecall(data);
        require(success, "failed to call newImplementation");
    }

    /**
   * @return The admin slot.
   */
    function _admin() internal view returns (address adm) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    /**
   * @dev Sets the address of the proxy admin.
   * @param newAdmin Address of the new proxy admin.
   */
    function _setAdmin(address newAdmin) internal {
        bytes32 slot = ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    /**
   * @dev Only fall back when the sender is not the admin.
   */
    function _willFallback() internal {
        require(
            msg.sender != _admin(),
            "Cannot call fallback function from the proxy admin"
        );
        super._willFallback();
    }
}

pragma solidity ^0.5.2;

import "./AdminUpgradeabilityProxy.sol";
import "../BaseWithStorage/Ownable.sol";

contract ProxyAdmin is Ownable {
    AdminUpgradeabilityProxy proxy;
    constructor(AdminUpgradeabilityProxy _proxy, address payable _owner)
        public
    {
        proxy = _proxy;
        owner = _owner;
    }

    function proxyAddress() public view returns (address) {
        return address(proxy);
    }

    function admin() public returns (address) {
        return proxy.admin();
    }

    function changeAdmin(address newAdmin) public onlyOwner {
        proxy.changeAdmin(newAdmin);
    }

    function upgradeTo(address implementation) public onlyOwner {
        proxy.upgradeTo(implementation);
    }

    function upgradeToAndCall(address implementation, bytes memory data)
        public
        payable
        onlyOwner
    {
        proxy.upgradeToAndCall.value(msg.value)(implementation, data);
    }

}

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address payable public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // /**
    // * @dev Allows the current owner to relinquish control of the contract.
    // * @notice Renouncing to ownership will leave the contract without an owner.
    // * It will not be possible to call the functions with the `onlyOwner`
    // * modifier anymore.
    // */
    // function renounceOwnership() public onlyOwner {
    //     emit OwnershipRenounced(owner);
    //     owner = address(0);
    // }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address payable _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address payable _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

pragma solidity ^0.5.2;

import "./Ownable.sol";
import "../Interfaces/ERC20.sol";

contract Withdrawable is Ownable {
    function withdrawEther(address payable _destination) external onlyOwner {
        _destination.transfer(address(this).balance);
    }

    function withdrawToken(ERC20 _token, address _destination) external onlyOwner {
        require(_token.transfer(_destination, _token.balanceOf(address(this))), "Transfer failed");
    }
}

pragma solidity ^0.5.2;

import "./Ownable.sol";

/**
 * @title ReferrableSale
 * @dev Implements the base elements for a sales referral system.
 * It is supposed to be inherited by a sales contract.
 * The referrals are expressed in percentage * 100, for example 1000 represents 10% and 555 represents 5.55%.
 */
contract ReferrableSale is Ownable {

    event DefaultReferralSet(
        uint256 percentage
    );

    event CustomReferralSet(
        address indexed referrer,
        uint256 percentage
    );

    uint256 public defaultReferralPercentage;
    mapping (address => uint256) public customReferralPercentages;

    function setDefaultReferral(uint256 _defaultReferralPercentage) public onlyOwner {
        require(_defaultReferralPercentage < 10000, "Referral must be less than 100 percent");
        require(_defaultReferralPercentage != defaultReferralPercentage, "New referral must be different from the previous");
        defaultReferralPercentage = _defaultReferralPercentage;
        emit DefaultReferralSet(_defaultReferralPercentage);
    }

    function setCustomReferral(address _referrer, uint256 _customReferralPercentage) public onlyOwner {
        require(_customReferralPercentage < 10000, "Referral must be less than 100 percent");
        require(_customReferralPercentage != customReferralPercentages[_referrer], "New referral must be different from the previous");
        customReferralPercentages[_referrer] = _customReferralPercentage;
        emit CustomReferralSet(_referrer, _customReferralPercentage);
    }
}

pragma solidity ^0.5.2;

import "./Ownable.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

/* solhint-disable no-empty-blocks */

pragma solidity 0.5.9;

import "./Estate/EstateBaseToken.sol";

contract Estate is EstateBaseToken {
    constructor(
        address metaTransactionContract,
        address admin,
        LandToken land
    ) public EstateBaseToken(metaTransactionContract, admin, land) {}

    /**
     * @notice Return the name of the token contract
     * @return The name of the token contract
     */
    function name() external pure returns (string memory) {
        return "Wonderland's ESTATEs";
    }

    /**
     * @notice Return the symbol of the token contract
     * @return The symbol of the token contract
     */
    function symbol() external pure returns (string memory) {
        return "ESTATE";
    }

    // solium-disable-next-line security/no-assign-params
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    /**
     * @notice Return the URI of a specific token
     * @param id The id of the token
     * @return The URI of the token
     */
    function tokenURI(uint256 id) public view returns (string memory) {
        require(_ownerOf(id) != address(0), "Id does not exist");
        return string(abi.encodePacked(uint2str(id), "/metadata.json"));
    }

    /**
     * @notice Check if the contract supports an interface
     * 0x01ffc9a7 is ERC-165
     * 0x80ac58cd is ERC-721
     * 0x5b5e139f is ERC-721 metadata
     * @param id The id of the interface
     * @return True if the interface is supported
     */
    function supportsInterface(bytes4 id) external pure returns (bool) {
        return id == 0x01ffc9a7 || id == 0x80ac58cd || id == 0x5b5e139f; // TODO
    }

    function burn(uint256 id) external {
        revert("burning is disabled");
    }

    function burnFrom(address from, uint256 id) external {
        revert("burning is disabled");
    }
}

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
// solhint-disable-next-line compiler-fixed
pragma solidity ^0.5.2;

import "./ERC20.sol";

/* interface */
contract ERC20WithMetadata is ERC20 {
    function name() public view returns (string memory);
    function symbol() public view returns (string memory);
    function decimals() public view returns (uint8);
}
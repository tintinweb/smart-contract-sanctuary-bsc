pragma solidity ^0.8.0;

import "./IERC4671.sol";
import "./IERC4671Enumerable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract BoardMarkSheet is IERC4671, IERC4671Enumerable, ERC165 {
    struct FullName {
        string fName;
        string mName;
        string lName;
    }

    struct Subject {
        uint8 subjectCode;
        string subjectName;
    }

    struct Marks {
        uint8 subjectCode;
        bool isAbsent;
        uint16 externalMarks; // e.g 7505 means mark means 75.05
        uint16 internalMarks;
    }

    struct Token {
        FullName name;
        string seatNo;
        string centerNo;
        string schoolIndexNo;
        Marks[] subjectWiseMarks;
        uint16 percentile; // e.g 9899 means 98.99 decimal is 2.
        address issuer;
        address owner;
        bool valid;
    }

    // Mapping from subjectCode to Subject Object
    mapping(uint8 => Subject) public subjectCodeToSubject;

    // Mapping from tokenId to token
    mapping(uint256 => Token) public _tokens;

    // Mapping from owner to token ids
    mapping(address => uint256[]) private _indexedTokenIds;

    // Mapping from token id to index
    mapping(address => mapping(uint256 => uint256)) private _tokenIdIndex;

    // Mapping from owner to number of valid tokens
    mapping(address => uint256) private _numberOfValidTokens;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Total number of tokens emitted
    uint256 private _emittedCount;

    // Total number of token holders
    uint256 private _holdersCount;

    // Contract creator
    address public creator;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        creator = msg.sender;
    }

    /// @notice Count all tokens assigned to an owner
    /// @param owner Address for whom to query the balance
    /// @return Number of tokens owned by `owner`
    function balanceOf(address owner) public view override returns (uint256) {
        return _indexedTokenIds[owner].length;
    }

    /// @notice Get owner of a token
    /// @param tokenId Identifier of the token
    /// @return Address of the owner of `tokenId`
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _getTokenOrRevert(tokenId).owner;
    }

    function isValid(uint256 tokenId) public view override returns (bool) {
        return _getTokenOrRevert(tokenId).valid;
    }

    /// @notice Check if an address owns a valid token in the contract
    /// @param owner Address for whom to check the ownership
    /// @return True if `owner` has a valid token, false otherwise
    function hasValid(address owner) public view override returns (bool) {
        return _numberOfValidTokens[owner] > 0;
    }

    /// @return Descriptive name of the tokens in this contract
    function name() public view returns (string memory) {
        return _name;
    }

    /// @return An abbreviated name of the tokens in this contract
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /// @return emittedCount Number of tokens emitted
    function emittedCount() public view override returns (uint256) {
        return _emittedCount;
    }

    /// @return holdersCount Number of token holders
    function holdersCount() public view override returns (uint256) {
        return _holdersCount;
    }

    /// @notice Get the tokenId of a token using its position in the owner's list
    /// @param owner Address for whom to get the token
    /// @param index Index of the token
    /// @return tokenId of the token
    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        override
        returns (uint256)
    {
        uint256[] storage ids = _indexedTokenIds[owner];
        require(index < ids.length, "Token does not exist");
        return ids[index];
    }

    /// @notice Get a tokenId by it's index, where 0 <= index < total()
    /// @param index Index of the token
    /// @return tokenId of the token
    function tokenByIndex(uint256 index)
        public
        view
        override
        returns (uint256)
    {
        return index;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC4671).interfaceId ||
            interfaceId == type(IERC4671Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @return True if the caller is the contract's creator, false otherwise
    function _isCreator() internal view returns (bool) {
        return msg.sender == creator;
    }

    function getTokenOrRevert(uint256 tokenId)
        external
        view
        returns (Token memory)
    {
        Token storage token = _tokens[tokenId];
        require(token.owner != address(0), "Token does not exist");
        return token;
    }

    /// @notice Retrieve a token or revert if it does not exist
    /// @param tokenId Identifier of the token
    /// @return The Token struct
    function _getTokenOrRevert(uint256 tokenId)
        internal
        view
        returns (Token storage)
    {
        Token storage token = _tokens[tokenId];
        require(token.owner != address(0), "Token does not exist");
        return token;
    }

    /// @notice Remove a token
    /// @param tokenId Token identifier to remove
    function _removeToken(uint256 tokenId) internal {
        Token storage token = _getTokenOrRevert(tokenId);
        _removeFromUnorderedArray(
            _indexedTokenIds[token.owner],
            _tokenIdIndex[token.owner][tokenId]
        );
        if (_indexedTokenIds[token.owner].length == 0) {
            assert(_holdersCount > 0);
            _holdersCount -= 1;
        }
        if (token.valid) {
            assert(_numberOfValidTokens[token.owner] > 0);
            _numberOfValidTokens[token.owner] -= 1;
        }
        delete _tokens[tokenId];
    }

    /// @notice Removes an entry in an array by its index
    /// @param array Array for which to remove the entry
    /// @param index Index of the entry to remove
    function _removeFromUnorderedArray(uint256[] storage array, uint256 index)
        internal
    {
        require(index < array.length, "Trying to delete out of bound index");
        if (index != array.length - 1) {
            array[index] = array[array.length - 1];
        }
        array.pop();
    }

    // /// @notice Mint a new token
    // /// @param owner Address for whom to assign the token
    // /// @return tokenId Identifier of the minted token
    // function _mint(address owner) internal virtual returns (uint256 tokenId) {
    //     tokenId = _emittedCount;
    //     _mintUnsafe(owner, tokenId, true);
    //     emit Minted(owner, tokenId);
    //     _emittedCount += 1;
    // }

    /// @notice Mint a given tokenId
    /// @param owner Address for whom to assign the token
    /// @param tokenId Token identifier to assign to the owner
    /// @param valid Boolean to assert of the validity of the token
    function _mintUnsafe(
        FullName memory name,
        string memory seatNo,
        string memory centerNo,
        string memory schoolIndexNo,
        Marks[] memory subjectWiseMarks,
        uint16 percentile,
        address owner,
        uint256 tokenId,
        bool valid
    ) internal {
        require(
            _tokens[tokenId].owner == address(0),
            "Cannot mint an assigned token"
        );
        if (_indexedTokenIds[owner].length == 0) {
            _holdersCount += 1;
        }
        for (uint16 i = 0; i < subjectWiseMarks.length; i++) {
            _tokens[tokenId].subjectWiseMarks.push(subjectWiseMarks[i]);
        }
        _tokens[tokenId].name = name;
        _tokens[tokenId].seatNo = seatNo;
        _tokens[tokenId].centerNo = centerNo;
        _tokens[tokenId].schoolIndexNo = schoolIndexNo;
        _tokens[tokenId].percentile = percentile;
        _tokens[tokenId].issuer = msg.sender;
        _tokens[tokenId].owner = owner;
        _tokens[tokenId].valid = valid;

        _tokenIdIndex[owner][tokenId] = _indexedTokenIds[owner].length;
        _indexedTokenIds[owner].push(tokenId);
        if (valid) {
            _numberOfValidTokens[owner] += 1;
        }
    }

    function mintResult(
        FullName memory name_,
        string memory seatNo_,
        string memory centerNo_,
        string memory schoolIndexNo_,
        Marks[] memory subjectWiseMarks_,
        uint16 percentile,
        address owner
    ) public returns (uint256 tokenId) {
        require(_isCreator(), "Only Contract creator can mint");
        tokenId = _emittedCount;
        _mintUnsafe(
            name_,
            seatNo_,
            centerNo_,
            schoolIndexNo_,
            subjectWiseMarks_,
            percentile,
            owner,
            tokenId,
            true
        );
        emit Minted(owner, tokenId);
        _emittedCount += 1;
    }

    function setSubject(Subject[] memory subjects_) external {
        require(_isCreator(), "Only Contract creator can set subject");
        for (uint256 i = 0; i < subjects_.length; i++) {
            subjectCodeToSubject[subjects_[i].subjectCode]
                .subjectCode = subjects_[i].subjectCode;
            subjectCodeToSubject[subjects_[i].subjectCode]
                .subjectName = subjects_[i].subjectName;
        }
    }

     function revoke(uint256 tokenId) external {
        require(_isCreator(), "Only Contract creator can revoke token"); 
        Token storage token = _getTokenOrRevert(tokenId);
        require(token.valid, "Token is already invalid");
        token.valid = false;
        assert(_numberOfValidTokens[token.owner] > 0);
        _numberOfValidTokens[token.owner] -= 1;
        emit Revoked(token.owner, tokenId);
    }
}

// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC4671 is IERC165 {
    /// Event emitted when a token `tokenId` is minted for `owner`
    event Minted(address owner, uint256 tokenId);

    /// Event emitted when token `tokenId` of `owner` is revoked
    event Revoked(address owner, uint256 tokenId);

    /// @notice Count all tokens assigned to an owner
    /// @param owner Address for whom to query the balance
    /// @return Number of tokens owned by `owner`
    function balanceOf(address owner) external view returns (uint256);

    /// @notice Get owner of a token
    /// @param tokenId Identifier of the token
    /// @return Address of the owner of `tokenId`
    function ownerOf(uint256 tokenId) external view returns (address);

    /// @notice Check if a token hasn't been revoked
    /// @param tokenId Identifier of the token
    /// @return True if the token is valid, false otherwise
    function isValid(uint256 tokenId) external view returns (bool);

    /// @notice Check if an address owns a valid token in the contract
    /// @param owner Address for whom to check the ownership
    /// @return True if `owner` has a valid token, false otherwise
    function hasValid(address owner) external view returns (bool);
}

// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "./IERC4671.sol";

interface IERC4671Enumerable is IERC4671 {
    /// @return emittedCount Number of tokens emitted
    function emittedCount() external view returns (uint256);

    /// @return holdersCount Number of token holders  
    function holdersCount() external view returns (uint256);

    /// @notice Get the tokenId of a token using its position in the owner's list
    /// @param owner Address for whom to get the token
    /// @param index Index of the token
    /// @return tokenId of the token
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /// @notice Get a tokenId by it's index, where 0 <= index < total()
    /// @param index Index of the token
    /// @return tokenId of the token
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
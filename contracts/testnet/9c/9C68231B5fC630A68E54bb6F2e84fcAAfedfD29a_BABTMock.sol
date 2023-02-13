// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISBT721 {
    /**
     * @dev This emits when a new token is created and bound to an account by
     * any mechanism.
     * Note: For a reliable `to` parameter, retrieve the transaction's
     * authenticated `to` field.
     */
    event Attest(address indexed to, uint256 indexed tokenId);

    /**
     * @dev This emits when an existing SBT is revoked from an account and
     * destroyed by any mechanism.
     * Note: For a reliable `from` parameter, retrieve the transaction's
     * authenticated `from` field.
     */
    event Revoke(address indexed from, uint256 indexed tokenId);

    /**
     * @dev This emits when an existing SBT is burned by an account
     */
    event Burn(address indexed from, uint256 indexed tokenId);

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Mints SBT
     *
     * Requirements:
     *
     * - `to` must be valid.
     * - `to` must not exist.
     *
     * Emits a {Attest} event.
     * Emits a {Transfer} event.
     * @return The tokenId of the minted SBT
     */
    function attest(address to) external returns (uint256);

    /**
     * @dev Revokes SBT
     *
     * Requirements:
     *
     * - `from` must exist.
     *
     * Emits a {Revoke} event.
     * Emits a {Transfer} event.
     */
    function revoke(address from) external;

    /**
     * @notice At any time, an SBT receiver must be able to
     *  disassociate themselves from an SBT publicly through calling this
     *  function.
     *
     * Emits a {Burn} event.
     * Emits a {Transfer} event.
     */
    function burn() external;

    /**
     * @notice Count all SBTs assigned to an owner
     * @dev SBTs assigned to the zero address is considered invalid, and this
     * function throws for queries about the zero address.
     * @param owner An address for whom to query the balance
     * @return The number of SBTs owned by `owner`, possibly zero
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @param from The address of the SBT owner
     * @return The tokenId of the owner's SBT, and throw an error if there is no SBT belongs to the given address
     */
    function tokenIdOf(address from) external view returns (uint256);

    /**
     * @notice Find the address bound to a SBT
     * @dev SBTs assigned to zero address are considered invalid, and queries
     *  about them do throw.
     * @param tokenId The identifier for an SBT
     * @return The address of the owner bound to the SBT
     */
    function ownerOf(uint256 tokenId) external view returns (address);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../interfaces/core/ISBT721.sol";

contract BABTMock is ISBT721 {
    mapping(uint256 => address) private _ownerMap;
    mapping(address => uint256) private _tokenMap;

    uint256 private _tokenId;

    function attest(address to) external returns (uint256) {
        require(to != address(0), "Address is empty");
        require(_tokenMap[to] == 0, "SBT already exists");

        uint256 tokenId = _tokenId;
        tokenId++;

        _tokenMap[to] = tokenId;
        _ownerMap[tokenId] = to;

        emit Attest(to, tokenId);
        emit Transfer(address(0), to, tokenId);

        _tokenId = tokenId;
        return tokenId;
    }

    function revoke(address from) external {
        require(from != address(0), "Address is empty");
        require(_tokenMap[from] > 0, "The account does not have any SBT");

        uint256 tokenId = _tokenMap[from];

        _tokenMap[from] = 0;
        _ownerMap[tokenId] = address(0);

        emit Revoke(from, tokenId);
        emit Transfer(from, address(0), tokenId);
    }

    function burn() external {
        require(_tokenMap[msg.sender] > 0, "The account does not have any SBT");

        uint256 tokenId = _tokenMap[msg.sender];

        _tokenMap[msg.sender] = 0;
        _ownerMap[tokenId] = address(0);

        emit Burn(msg.sender, tokenId);
        emit Transfer(msg.sender, address(0), tokenId);
    }

    function balanceOf(address owner) external view returns (uint256) {
        return _tokenMap[owner] > 0 ? 1 : 0;
    }

    function tokenIdOf(address from) external view returns (uint256) {
        require(_tokenMap[from] > 0, "The wallet has not attested any SBT");
        return _tokenMap[from];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        require(_ownerMap[tokenId] != address(0), "Invalid tokenId");
        return _ownerMap[tokenId];
    }

    function totalSupply() external view returns (uint256) {
        return _tokenId;
    }
}
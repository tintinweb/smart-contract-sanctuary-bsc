// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Counters.sol";
import "./Ownable.sol";
import "./ERC721Enumerable.sol";

contract wcpNFT is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    // Used for generating the tokenId of new NFT minted
    Counters.Counter private _tokenIds;

    // Map the bunnyId for each tokenId
    mapping(uint256 => uint8) private bunnyIds;

    // Address map with mint permissions
    mapping(address => bool) private mintAccess;

    uint private totalAmount = 100000000;

    constructor() ERC721("WCP NFT", "wcpNFT") {}

    mapping(uint => string) public tokenUriMap;


    modifier onlyMinter() {
        require(mintAccess[msg.sender], "Access denied");
        _;
    }

    /**
     * @dev Mint NFTs.
     */
    function mint(
        address _to,
        uint8 _bunnyId
    ) external onlyMinter returns (uint256) {
        uint256 tokenId = _tokenIds.current();
        require(tokenId < totalAmount, "nft sold out");
        _tokenIds.increment();
        bunnyIds[tokenId] = _bunnyId;
        _mint(_to, tokenId);
        return tokenId;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function burn(address _from, uint256 _tokenId) external {
        require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "nft: illegal request");
        require(ownerOf(_tokenId) == _from, "from is not owner");
        _burn(_tokenId);
    }

    function getBunnyId(uint256 _tokenId) public view returns (uint8) {
        return bunnyIds[_tokenId];
    }

    function getBunnyIdsByTokenIds(uint256[] memory _tokenArray) external view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_tokenArray.length);
        for (uint256 i = 0; i < _tokenArray.length; i++) {
            result[i] = getBunnyId(_tokenArray[i]);
        }
        return result;
    }

    // ERC721URIStorage
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");
        uint bunnyId = bunnyIds[tokenId];
        return tokenUriMap[bunnyId];
    }

    /**
     * @dev Access operations.
     */
    function setAccess(address _account) public onlyOwner {
        mintAccess[_account] = true;
    }

    function removeAccess(address _account) public onlyOwner {
        mintAccess[_account] = false;
    }

    function getAccess(address _account) public view returns (bool) {
        return mintAccess[_account];
    }

    function setTotalAmount(uint amount) public onlyOwner{
        totalAmount = amount;
    }

    function setTokenUri(uint8 bunnyId, string calldata _tokenUri) external onlyOwner{
        tokenUriMap[bunnyId] = _tokenUri;
    }

}
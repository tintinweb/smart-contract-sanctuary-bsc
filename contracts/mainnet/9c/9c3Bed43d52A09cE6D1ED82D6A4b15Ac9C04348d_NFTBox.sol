// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "/../../utils/AccessControl.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";

import "./AccessControl.sol";
import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Pausable.sol";

contract NFTBox is ERC721, ERC721Enumerable, Pausable, AccessControl {
    using Strings for uint256;

    string private baseURI;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => uint256) private nfts;

    constructor() ERC721("BoxNft", "BNFT") {
        baseURI = "https://www.heroiccreed.com/nft/json/box/";
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        tokenId;
        return string(abi.encodePacked(baseURI, "box", ".json"));
    }

    function getBox(uint256 _nftId) external view returns (uint256) {
        return nfts[_nftId];
    }

    function creatBox(
        uint256 _nftId,
        uint256 _data,
        address _owner
    ) external onlyRole(MINTER_ROLE) {
        nfts[_nftId] = _data;

        _mint(_owner, _nftId);
    }

    function deleteBox(uint256 _nftId) external onlyRole(MINTER_ROLE) {
        super._burn(_nftId);
        delete (nfts[_nftId]);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function pause() public whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
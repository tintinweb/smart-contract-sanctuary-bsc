// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.4 <0.9.0;

import "./ERC721.sol";
import "./ERC2981.sol";
import "./Ownable.sol";

contract NFT721 is ERC721, ERC2981, Ownable {
    string _baseTokenURI;
    uint256 public index;
    mapping(address => bool) _minters;

    modifier onlyMinter() {
        require(_minters[_msgSender()], "NFT721: caller is not the minter");
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        index = 1;
        _minters[_msgSender()] = true;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function mint(uint96 feeNumerator) external onlyMinter {
        _safeMint(_msgSender(), index);
        _setTokenRoyalty(index, _msgSender(), feeNumerator);
        index++;
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == _msgSender(), "NFT721: caller is not the token owner");
        _burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }

    function setMinter(address account, bool approval) external onlyOwner {
        _minters[account] = approval;
    }

    function isMinter(address account) external view returns (bool) {
        return _minters[account];
    }
}
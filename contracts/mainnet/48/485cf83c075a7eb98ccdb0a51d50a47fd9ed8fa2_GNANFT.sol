// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./AccessControl.sol";
import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Pausable.sol";
import "./Strings.sol";

contract GNANFT is ERC721, ERC721Enumerable, Pausable, AccessControl {
    using Strings for uint256;

    mapping(uint256 => string) private _tokenURIs;
    string private baseURI;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct GNA {
        string url;
        uint256 sTime;
    }

    mapping(uint256 => GNA) private nftList;

    event MintNft(uint256 indexed nftId, address indexed _owner, string url);
    event BurnNft(uint256 indexed nftId);
    event updateURL(uint256 indexed nftId, string oldUrl, string newUrl);

    constructor(
        string memory baseURI_,
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        baseURI = baseURI_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override 
        returns (string memory)
    {
        string memory _tokenURI = _tokenURIs[tokenId];
        if (bytes(_tokenURI).length > 0) {
            return _tokenURI;
        }
        GNA memory _nft = nftList[tokenId];
        
        return _nft.url;
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

    function getInfo(
        uint256 _nftId
    )
        external
        view
        returns (string memory, uint256)
    {
        GNA storage _nft = nftList[_nftId];
        return (_nft.url, _nft.sTime);
    }

    function mintNft(
        uint256 _nftId,
        string memory _url,
        address _toAddress
    ) 
        external 
        onlyRole(MINTER_ROLE)
    {
        return _mintNFT(_nftId, _url, _toAddress);
    }
    
    function burnNft(
        uint256 _nftId
    ) 
        external
        onlyRole(MINTER_ROLE)
    {
        _burn(_nftId);
        delete(nftList[_nftId]);

        emit BurnNft(_nftId);
    }

    function evolveShark(
        uint256 _nftId,
        string memory _newURL
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(nftList[_nftId].sTime != 0, "Evolve: token nonexistent");

        string memory _oldURL = nftList[_nftId].url;
        nftList[_nftId].url = _newURL;
        emit updateURL(_nftId, _newURL, _newURL);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    )
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    function _mintNFT(
        uint256 _nftId,
        string memory _url,
        address _toAddress
    ) 
        private
    {
        GNA memory _nft = GNA(_url, block.timestamp);
        nftList[_nftId] = _nft;
        _mint(_toAddress, _nftId);
        emit MintNft(_nftId, _toAddress, _url);
    }
}
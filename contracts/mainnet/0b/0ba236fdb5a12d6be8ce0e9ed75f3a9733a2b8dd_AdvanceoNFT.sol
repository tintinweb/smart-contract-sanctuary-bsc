// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./AccessControl.sol";
import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Pausable.sol";
import "./Strings.sol";

contract AdvanceoNFT is ERC721, ERC721Enumerable, Pausable, AccessControl {
    using Strings for uint256;

    mapping(uint256 => string) private _tokenURIs;
    string private baseURI;

    bytes32 public constant MINTER_ROLE = keccak256("FAST_ROLE");

    struct Fast {
        uint256 genes;
        uint256 bornAt;
    }

    mapping(uint256 => Fast) private fasts;

    event FastBorned(uint256 indexed _fastId, address indexed _owner, uint256 _genes);
    event FastRetired(uint256 indexed _fastId);

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
        Fast memory _fast = fasts[tokenId];
        
        return string(abi.encodePacked(baseURI, tokenId.toString(), "/" , _fast.genes.toHexString(), ".json"));
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

    function getFast(
        uint256 _fastId
    )
        external
        view
        returns (uint256 /* _genes */, uint256 /* _bornAt */)
    {
        Fast storage _fast = fasts[_fastId];
        return (_fast.genes, _fast.bornAt);
    }

    function bornFast(
        uint256 _fastId,
        uint256 _genes,
        address _owner
    ) 
        external 
        onlyRole(MINTER_ROLE)
    {
        return _bornFast(_fastId, _genes, _owner);
    }

    
    function retireFast(
        uint256 _fastId
    ) 
        external
        onlyRole(MINTER_ROLE)
    {
        _burn(_fastId);
        delete(fasts[_fastId]);

        emit FastRetired(_fastId);
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

    function _bornFast(
        uint256 _fastId,
        uint256 _genes,
        address _owner
    ) 
        private
    {
        Fast memory _fast = Fast(_genes, block.timestamp);
        fasts[_fastId] = _fast;
        _mint(_owner, _fastId);
        emit FastBorned(_fastId, _owner, _genes);
    }
}
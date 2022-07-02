// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./AccessControl.sol";
import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Pausable.sol";
import "./Strings.sol";

contract IceLegendNFT is ERC721, ERC721Enumerable, Pausable, AccessControl {
    using Strings for uint256;

    mapping(uint256 => string) private _tokenURIs;
    string private baseURI;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct Shark {
        uint256 genes;
        uint256 bornAt;
    }

    mapping(uint256 => Shark) private sharks;

    event SharkBorned(uint256 indexed _sharkId, address indexed _owner, uint256 _genes);
    event SharkRebirthed(uint256 indexed _sharkId, uint256 _genes);
    event SharkRetired(uint256 indexed _sharkId);
    event SharkEvolved(uint256 indexed _sharkId, uint256 _oldGenes, uint256 _newGenes);

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
        Shark memory _shark = sharks[tokenId];
        
        return string(abi.encodePacked(baseURI, tokenId.toString(), "/" , _shark.genes.toHexString(), ".json"));
    }

    /*
    function setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    )
        external
        virtual 
    {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "SetTokenURI: transfer caller is not owner nor approved");
        _tokenURIs[tokenId] = _tokenURI;
    }*/

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

    function getShark(
        uint256 _sharkId
    )
        external
        view
        returns (uint256 /* _genes */, uint256 /* _bornAt */)
    {
        Shark storage _shark = sharks[_sharkId];
        return (_shark.genes, _shark.bornAt);
    }

    function bornShark(
        uint256 _sharkId,
        uint256 _genes,
        address _owner
    ) 
        external 
        onlyRole(MINTER_ROLE)
    {
        return _bornShark(_sharkId, _genes, _owner);
    }

    function rebirthShark(
        uint256 _sharkId,
        uint256 _genes
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(sharks[_sharkId].bornAt != 0, "Rebirth: token nonexistent");

        Shark storage _shark = sharks[_sharkId];
        _shark.genes = _genes;
        _shark.bornAt = block.timestamp;
        emit SharkRebirthed(_sharkId, _genes);
    }
    
    function retireShark(
        uint256 _sharkId
    ) 
        external
        onlyRole(MINTER_ROLE)
    {
        _burn(_sharkId);
        delete(sharks[_sharkId]);

        emit SharkRetired(_sharkId);
    }

    function evolveShark(
        uint256 _sharkId,
        uint256 _newGenes
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(sharks[_sharkId].bornAt != 0, "Evolve: token nonexistent");

        uint256 _oldGenes = sharks[_sharkId].genes;
        sharks[_sharkId].genes = _newGenes;
        emit SharkEvolved(_sharkId, _oldGenes, _newGenes);
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

    function _bornShark(
        uint256 _sharkId,
        uint256 _genes,
        address _owner
    ) 
        private
    {
        Shark memory _shark = Shark(_genes, block.timestamp);
        sharks[_sharkId] = _shark;
        _mint(_owner, _sharkId);
        emit SharkBorned(_sharkId, _owner, _genes);
    }
}
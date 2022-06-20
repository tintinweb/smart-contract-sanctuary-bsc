// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC165.sol";
import "./IERC721Receiver.sol";
import "./IERC721Enumerable.sol";
import "./IERC721Metadata.sol";
import "./IERC721.sol";
import "./Context.sol";
import "./Address.sol";
import "./Strings.sol";
import "./EnumerableSet.sol";
import "./SafeERC20.sol";
import "./ECDSA.sol";
import "./ERC165.sol";
import "./Pausable.sol";
import "./Ownable.sol";
import "./AccessControl.sol";
import "./ERC721.sol";
import "./ERC721Enumerable.sol";


contract starCardNFT is ERC721, ERC721Enumerable, Pausable, AccessControl {
    using Strings for uint256;

    uint256 public currentTokenId;

    mapping(uint256 => string) private _tokenURIs;
    string private baseURI;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct starCard {
        uint256 genes;
        uint256 bornAt;
    }

    mapping(uint256 => starCard) private starCards;

    event starCardBorned(uint256 indexed _starCardId, address indexed _owner, uint256 _genes);
    event starCardRebirthed(uint256 indexed _starCardId, uint256 _genes);
    event starCardRetired(uint256 indexed _starCardId);
    event starCardEvolved(uint256 indexed _starCardId, uint256 _oldGenes, uint256 _newGenes);

    constructor(
        string memory baseURI_,
        string memory name_,
        string memory symbol_,
        uint genesis
    ) ERC721(name_, symbol_) {
        baseURI = baseURI_;
        currentTokenId = 100000;
        if (genesis != 0) {
            for (uint i = 1; i < genesis + 1; i ++) {
                _bornstarCard(i + 100000, 0, _msgSender());
            }
        }
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
        starCard memory _starCard = starCards[tokenId];

        return string(abi.encodePacked(baseURI, tokenId.toString(), "/", _starCard.genes.toHexString(), ".json"));
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

    function getstarCard(
        uint256 _starCardId
    )
    external
    view
    returns (uint256 /* _genes */, uint256 /* _bornAt */)
    {
        starCard storage _starCard = starCards[_starCardId];
        return (_starCard.genes, _starCard.bornAt);
    }


    function bornstarCard(
        uint256 _starCardId,
        uint256 _genes,
        address _owner
    )
    external
    onlyRole(MINTER_ROLE)
    {
        return _bornstarCard(_starCardId, _genes, _owner);
    }

    function rebirthstarCard(
        uint256 _starCardId,
        uint256 _genes
    )
    external
    onlyRole(MINTER_ROLE)
    {
        require(starCards[_starCardId].bornAt != 0, "Rebirth: token nonexistent");

        starCard storage _starCard = starCards[_starCardId];
        _starCard.genes = _genes;
        _starCard.bornAt = block.timestamp;
        emit starCardRebirthed(_starCardId, _genes);
    }

    function retirestarCard(
        uint256 _starCardId
    )
    external
    onlyRole(MINTER_ROLE)
    {
        _burn(_starCardId);
        delete (starCards[_starCardId]);

        emit starCardRetired(_starCardId);
    }

    function evolvestarCard(
        uint256 _starCardId,
        uint256 _newGenes
    )
    external
    onlyRole(MINTER_ROLE)
    {
        require(starCards[_starCardId].bornAt != 0, "Evolve: token nonexistent");

        uint256 _oldGenes = starCards[_starCardId].genes;
        require(_newGenes == _oldGenes + 1, "has been bred");

        uint256 newGenes = _oldGenes + 1;

        require(newGenes < 4, "Breed no more than 3 times");
        starCards[_starCardId].genes = newGenes;
        emit starCardEvolved(_starCardId, _oldGenes, newGenes);
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

    function _bornstarCard(
        uint256 _starCardId,
        uint256 _genes,
        address _owner
    )
    private
    {
        starCard memory _starCard = starCard(_genes, block.timestamp);
        starCards[_starCardId] = _starCard;
        _mint(_owner, _starCardId);
        currentTokenId += 1;
        emit starCardBorned(_starCardId, _owner, _genes);
    }
}
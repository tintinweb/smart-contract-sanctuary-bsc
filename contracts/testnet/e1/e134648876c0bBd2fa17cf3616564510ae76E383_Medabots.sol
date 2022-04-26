// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import "./ERC721Burnable.sol";
import "./Ownable.sol";
import "./Counters.sol";
import {MedabotsMetadata} from "./MedabotsMetadata.sol";

contract Medabots is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string public baseUri;

    event Metadata(uint256 id, MedabotsMetadata.Metadata Metadata, string metadataURL);

    event TransferRobotPart(address from, address to, uint256 tokenId);

    constructor(string memory _baseUri) ERC721("MEDABOTS", "MEBT") {
        baseUri =_baseUri;
    }
   
    mapping(uint256 => uint8) public families;
    mapping(uint256 => MedabotsMetadata.Part) public parts;
 
    function mint(
        address _tokenOwner,
        string calldata metadataURL,
        MedabotsMetadata.Metadata calldata _metadata
    ) external onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 id = _tokenIds.current();
        _mint(_tokenOwner, id);
        _setTokenURI(id, metadataURL);
        emit Metadata(id, _metadata, metadataURL);
        //setear mapings families y parts.
        families[id] = _metadata.familyId;
        parts[id] = _metadata.partId;
        return id;
    }

    function familyOf(uint256 tokenId) public view returns (uint8) {
        uint8 family = families[tokenId];
        return family;
    }

    function partOf(uint256 tokenId) public view returns (MedabotsMetadata.Part) {
        MedabotsMetadata.Part part = parts[tokenId];
        return part;
    }


    function tokensOfOwner(address owner) public view returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);

        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokenIds;
    }

    function setBaseUri(string memory _newBaseUri) public onlyOwner {
        baseUri =_newBaseUri;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
         
        return string(abi.encodePacked(baseUri,super.tokenURI(tokenId)));
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
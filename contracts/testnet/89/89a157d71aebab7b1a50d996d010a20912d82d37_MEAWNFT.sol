// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import "./Pausable.sol";
import "./AccessControl.sol";
import "./ERC721Burnable.sol";

contract MEAWNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, AccessControl, ERC721Burnable {
    //0x0000000000000000000000000000000000000000000000000000000000000000
    //0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    //0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private maxseed = 2000000;
    uint256 private maxpv1 = 5000000;
    uint256 private maxpv2 = 10000000;

    constructor() ERC721("MEAWAVATARNFT", "MEAWNFT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        // maxseed = 2000000;
        // maxpv1 = 5000000;
        // maxpv2 = 10000000;
    }

    // function _baseURI() internal pure override returns (string memory) {
    //     return "https://gateway.pinata.cloud/ipfs/QmXUq34BK4SCsxCT2ekJRsEckhwu1UkfXZf2yECfmwKTSa";
    // }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function checkmaxseed() public view returns(uint256) {
        return maxseed;
    }

    function safeMint(address to, uint256 tokenId, string memory uri,uint256 valueNft)
        public
        onlyRole(MINTER_ROLE)
    {
        if( maxseed >= valueNft ){ //100000
           maxseed -= valueNft;
           _safeMint(to, tokenId);
 
           //set uri for maxseed
           _setTokenURI(tokenId, uri);
       } else if ( maxseed < valueNft &&  maxseed != 0) {
           revert("Not enough seed round for sell");
       } else if ( maxpv1 >= valueNft &&  maxseed == 0) {
           maxpv1 -= valueNft;
           _safeMint(to, tokenId);
 
           //set uri for maxpv1
           _setTokenURI(tokenId, uri);
       } else if ( maxpv1 < valueNft &&  maxpv1 != 0 && maxseed == 0) {
           revert("Not enough private 1 round for sell");
       } else if ( maxpv2 >= valueNft &&  maxseed == 0 && maxpv1 == 0) {
           maxpv2 -= valueNft;
           _safeMint(to, tokenId);
 
           //set uri for maxpv2
           _setTokenURI(tokenId, uri);
       } else if ( maxpv2 < valueNft &&  maxpv2 != 0 && maxseed == 0 && maxpv1 == 0) {
           //buy more than max private round two
           revert("Not enough private 2 round for sell");
       } else {
           revert("Out of NFT for sell.");
       }
    }



    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
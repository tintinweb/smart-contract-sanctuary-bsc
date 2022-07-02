// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
 
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import './INFT.sol';
 
contract NFT is INFT, ERC721Enumerable, ERC721URIStorage {
 
    address public owner;
    uint256 public lastTokenId = 0;
    string public contractURI;
 
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = _msgSender();
    }
 
    function setContractURI(string memory _contractURI) external override virtual returns(bool) {
        require(msg.sender == owner, 'NFT: 4001');
        contractURI = _contractURI;
        return true;
    }
 
    function createToken(string memory _tokenURI) external override virtual returns(uint256 tokenId) {
        require(_msgSender() == owner, "NFT: 4002");
        tokenId = mint(owner, _tokenURI);
        if(bytes(contractURI).length == 0 ){
            contractURI = _tokenURI;
        }
    }
 
    function getInfo(uint256 _tokenId) external view virtual override returns (address ownerAddress, string memory name, string memory symbol, string memory _tokenURI) {
        ownerAddress = super.ownerOf(_tokenId);
        name = super.name();
        symbol = super.symbol();
        _tokenURI = tokenURI(_tokenId);
    }
 
    function mint(address _to, string memory _tokenURI) private returns (uint256) {
        lastTokenId++;
        _mint(_to, lastTokenId);
        _setTokenURI(lastTokenId, _tokenURI);
        return lastTokenId;
    }
 
    function tokenURI(uint256 tokenId) public view virtual override (ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
 
    function _burn(uint256 tokenId) internal virtual override (ERC721, ERC721URIStorage) {
        require(tokenId > 0, "GoShard: 4003");
        super._burn(tokenId);
    }
 
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
 
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
 
    function getTokens(address _user) external view override virtual returns(uint256[] memory) {
        uint256[] memory _userTokens = new uint256[](lastTokenId);
        uint256 idx = 0;
        for(uint256 tokenId = 0 + 1; tokenId <= lastTokenId; tokenId++){
            if(super.ownerOf(tokenId) == _user){
                _userTokens[idx] = tokenId;
                idx++;
            }
        }
        uint256[] memory userTokens = new uint256[](idx);
        for(uint256 i = 0; i < idx; i++){
            userTokens[i] = _userTokens[i];
        }
        return userTokens;
    }
}
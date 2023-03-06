// SPDX-License-Identifier: MIT
import "./Context.sol";
import "./Address.sol";
import "./String.sol";
import "./ERC721.sol";
import "./Counter.sol";


// File: contracts/Partisan.sol


pragma solidity ^0.8.4;

interface IWhitelist {
    function getWhitelist(address owner) external view returns(uint256, uint256);

    function whitelistMintNumberIncrement(address owner) external;
}


contract Valiant is ERC721, ERC721Enumerable, ERC721Burnable, Ownable, ERC721URIStorage {
    using Counters for Counters.Counter;
    using Strings for uint256;

    string baseUri;
    address private whitelistAddress;

    Counters.Counter private _tokenIdCounter;
    uint256 public maxSupply;
    uint256 public maxMintPerWallet = 3;

    mapping(address => uint256[]) watchOwners;

    constructor(string memory _tokenName, string memory _tokenSymbol, uint256 _maxSupply, address _whitelistAddress) ERC721(_tokenName, _tokenSymbol) {
        maxSupply = _maxSupply;
        whitelistAddress = _whitelistAddress;
    }

    receive() external payable{}

    fallback() external payable {}

    function withdrawBalance() external onlyOwner  {
         uint256 balance = address(this).balance;
         payable(_msgSender()).transfer(balance);
     }

   function getBalance() external view returns(uint){
         uint256 balance = address(this).balance;
         return balance;
    }

    function _burn(uint256 tokenId) internal override (ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


    function mintToken(string memory uri)
        public
    {
        require (totalSupply() < maxSupply);
        uint256 _allowed;
        uint256 _mintNumber;
        (_allowed, _mintNumber) = IWhitelist(whitelistAddress).getWhitelist(msg.sender);
        require (_allowed >= 1, "NOT_IN_WHITELIST");
        require (_mintNumber < maxMintPerWallet, "REACH_MAX_MINT");

        uint256 tokenId = _tokenIdCounter.current();

        watchOwners[msg.sender].push(tokenId);
        IWhitelist(whitelistAddress).whitelistMintNumberIncrement(msg.sender);
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function setBaseURI(string calldata _baseUri) external onlyOwner() {
        baseUri = _baseUri;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    function getWatchOwner (address _owner) public view returns(uint256[] memory) {
        return watchOwners[_owner];
    }
}
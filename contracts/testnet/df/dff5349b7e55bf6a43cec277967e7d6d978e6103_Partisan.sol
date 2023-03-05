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


contract Partisan is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    struct watchDetail {
        uint256 strap;
        uint256 caseWatch;
        uint256 crown;
        uint256 dial;
    }

    string private _baseUri;
    address private whitelistAddress;

    Counters.Counter private _tokenIdCounter;
    uint256 public maxSupply;
    uint256 public maxMintPerWallet = 3;
    uint256 nonce = 0;

    mapping(uint256 => watchDetail) watches;
    mapping(address => uint256) watchOwners;

    constructor(string memory _tokenName, string memory _tokenSymbol, uint256 _maxSupply, address _whitelistAddress) ERC721(_tokenName, _tokenSymbol) {
        maxSupply = _maxSupply;
        whitelistAddress = _whitelistAddress;
    }

    function setBaseURI(string calldata baseUri) external onlyOwner() {
        _baseUri = baseUri;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
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

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function random() internal returns (uint256) {
        uint256 randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 100;
        nonce++;
        if (randomnumber < uint(6)) {
            return 0;
        } else if (uint256(6) <= randomnumber && randomnumber <= uint256(8)) {
            return 1;
        } else if (uint256(8) < randomnumber && randomnumber <= uint256(13)) {
            return 2;
        } else if (uint256(13) < randomnumber && randomnumber <= uint256(19)) {
            return 3;
        } else if (uint256(19) < randomnumber && randomnumber <= uint256(31)) {
            return 4;
        } else if (uint256(31) < randomnumber && randomnumber <= uint256(43)) {
            return 5;
        } else if (uint256(43) < randomnumber && randomnumber <= uint256(48)) {
            return 6;
        } else if (uint256(48) < randomnumber && randomnumber <= uint256(58)) {
            return 7;
        } else if (uint256(58) < randomnumber && randomnumber <= uint256(70)) {
            return 8;
        } else if (uint256(70) < randomnumber && randomnumber <= uint256(75)) {
            return 9;
        } else if (uint256(75) < randomnumber && randomnumber <= uint256(87)) {
            return 10;
        } else if (uint256(87) < randomnumber && randomnumber <= uint256(93)) {
            return 11;
        } else if (uint256(93) < randomnumber && randomnumber <= uint256(95)) {
            return 12;
        } else if (uint256(95) < randomnumber && randomnumber <= uint256(100)) {
            return 13;
        }
        return type(uint).max;
    }

    function safeMint(string memory uri)
        public
    {
        require (totalSupply() < maxSupply);
        uint256 _allowed;
        uint256 _mintNumber;
        (_allowed, _mintNumber) = IWhitelist(whitelistAddress).getWhitelist(msg.sender);
        require (_allowed == 3, "NOT_IN_WHITELIST");
        require (_mintNumber < maxMintPerWallet, "REACH_MAX_MINT");

        uint256 strap = random();
        uint256 caseWatch = random();
        uint256 crown = random();
        uint256 dial = random();
        uint256 tokenId = _tokenIdCounter.current();

        watches[tokenId] = watchDetail(strap, caseWatch, crown, dial);
        watchOwners[msg.sender] = tokenId;
        IWhitelist(whitelistAddress).whitelistMintNumberIncrement(msg.sender);
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function getWatchDetail(uint256 _tokenId) public view returns(watchDetail memory) {
        return watches[_tokenId];
    }

    function getWatchOwner (address _owner) public view returns(uint256) {
        return watchOwners[_owner];
    }
}
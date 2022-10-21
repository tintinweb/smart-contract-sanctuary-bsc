pragma solidity ^0.8.4;

import "./Ownable.sol";
import "./Counters.sol";
import "./ERC721.sol";
import "./ERC721URIStorage.sol";
import "./Strings.sol";
import "./IMilkToken.sol";

contract HappyCows is Ownable, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address private ownerAddr;
    address public marketAddress;
    uint256 public blockNumber;
    uint256 public price;
    string public baseURI;
    string public cID;

    IMilkToken tokenMilk;

    event BuyBlindBox(
        uint256 indexed itemId,
        string metaHash
    );

    constructor(
        uint256 _blockNumber,
        IMilkToken _tokenMilk,
        string memory _baseURI,
        string memory _cID,
        address _marketAddress,
        address _ownerAddr
    ) ERC721("HappyCows", "HCC") {
        blockNumber = _blockNumber;
        tokenMilk = _tokenMilk;
        baseURI = _baseURI;
        price = 100000;
        cID = _cID;
        marketAddress = _marketAddress;
        ownerAddr = _ownerAddr;
    }

    function buyBlindBox() public {
        require(msg.sender != address(0), "Mint Address can't be zero address");
        require(block.number >= blockNumber, "Blindbox Sale is not started");
        require(_tokenIds.current() <= 1000, "All NFTs are sold");
        require(
            tokenMilk.balanceOf(msg.sender) >= price * 10**18,
            "Balance of Milk token is not enought to buy BlindBox"
        );

        tokenMilk.transferFrom(msg.sender, ownerAddr, price * 10**18);

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        string memory s = string(abi.encodePacked(baseURI, cID, '/', Strings.toString(newItemId), '.json'));

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, s);

        if (!isApprovedForAll(msg.sender, marketAddress)) {
            setApprovalForAll(marketAddress, true);
        }
        
        emit BuyBlindBox(newItemId, s);
    }

    function setOwnerAddr(address _ownerAddr) public onlyOwner {
        require(
            _ownerAddr != address(0),
            "Owner Address can't be zero address"
        );
        ownerAddr = _ownerAddr;
    }

    function getOwnerAddr() public view onlyOwner returns (address) {
        return ownerAddr;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function setBlockNumber(uint256 _blockNumber) public onlyOwner {
        blockNumber = _blockNumber;
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function setCID(string memory _cID) public onlyOwner {
        cID = _cID;
    }

    function transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) external onlyOwner {
        transferFrom(_from, _to, _tokenId);
    }

    function getBlockNumber() external view returns (uint256) {
        return block.number;
    }

    function totalSupply() external view returns (uint256) {
        return (_tokenIds.current());
    }

    function getTokenFullURI(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        string memory _tokenURI = tokenURI(tokenId);

        return _tokenURI;
    }

    function getBaseURI() external view returns (string memory) {
        string memory _baseURI = baseURI;
        return _baseURI;
    }

    function fetchMyNfts() external view returns (uint256[] memory) {
        uint256 tokenCount = 0;
        uint256 _totalSupply = _tokenIds.current();
        for (uint256 i = 0; i < _totalSupply; i++) {
            if (ownerOf(i + 1) == msg.sender) {
                tokenCount++;
            }
        }

        uint256[] memory tokenIds = new uint256[](tokenCount);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < _totalSupply; i++) {
            if (ownerOf(i + 1) == msg.sender) {
                tokenIds[currentIndex] = i + 1;
                currentIndex++;
            }
        }

        return tokenIds;
    }
}
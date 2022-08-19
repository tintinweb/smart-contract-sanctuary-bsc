// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.8.0;
pragma abicoder v2;

import "./ERC721.sol";

contract Shibulls is ERC721 {
    string public collectionName;
    string public collectionNameSymbol;
    uint256 public ShibullsFCounter;
    uint256 public mintPrice;
    address payable owner;

    struct ShibullsF {
        uint256 tokenId;
        string tokenName;
        string tokenEdition;
        address payable mintedBy;
        address payable currentOwner;
        address payable previousOwner;
        uint256 price;
        uint256 numberOfTransfers;
        bool forSale;
    }

    mapping(uint256 => ShibullsF) public allShibulls;
    mapping(string => bool) public tokenNameExists;
    mapping(string => bool) public tokenEditionExists;

    constructor() ERC721("ShibullsF Collection", "SHIB") {
        collectionName = name();
        collectionNameSymbol = symbol();
        mintPrice = 0.5 * 1000000000000000000;
        owner = msg.sender;
    }

    function mintShibullsF(
        string memory _name,
        string memory _tokenEdition,
        uint256 _price
    ) public payable {
        require(msg.sender != address(0));
        ShibullsFCounter++;
        require(!_exists(ShibullsFCounter));

        require(!tokenEditionExists[_tokenEdition]);
        require(!tokenNameExists[_name]);

        _mint(msg.sender, ShibullsFCounter);
        _setTokenURI(ShibullsFCounter, _tokenEdition);

        tokenEditionExists[_tokenEdition] = true;
        tokenNameExists[_name] = true;

        address payable sendTo = owner;
        sendTo.transfer(msg.value);

        ShibullsF memory newShibullsF = ShibullsF(
            ShibullsFCounter,
            _name,
            _tokenEdition,
            msg.sender,
            msg.sender,
            address(0),
            _price,
            0,
            false
        );
        allShibulls[ShibullsFCounter] = newShibullsF;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getMintPrice() public view returns (uint256) {
        return mintPrice;
    }

    function setMintPrice(uint256 _price) public returns (bool) {
        require(owner == msg.sender);
        mintPrice = _price;
        return true;
    }

    function getTokenOwner(uint256 _tokenId) public view returns (address) {
        address _tokenOwner = ownerOf(_tokenId);
        return _tokenOwner;
    }

    function getTokenMetaData(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        string memory tokenMetaData = tokenURI(_tokenId);
        return tokenMetaData;
    }

    function getNumberOfTokensMinted() public view returns (uint256) {
        uint256 totalNumberOfTokensMinted = totalSupply();
        return totalNumberOfTokensMinted;
    }

    function getTotalNumberOfTokensOwnedByAnAddress(address _owner)
        public
        view
        returns (uint256)
    {
        uint256 totalNumberOfTokensOwned = balanceOf(_owner);
        return totalNumberOfTokensOwned;
    }

    function getTokenExists(uint256 _tokenId) public view returns (bool) {
        bool tokenExists = _exists(_tokenId);
        return tokenExists;
    }


    function giftToken(uint256 _tokenId, address payable _receiver) public payable {
        require(msg.sender != address(0));
        require(_exists(_tokenId));
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner != address(0));
        require(tokenOwner == msg.sender);
        ShibullsF memory _ShibullsF = allShibulls[_tokenId];

        _transfer(tokenOwner, _receiver, _tokenId);

        _ShibullsF.previousOwner = _ShibullsF.currentOwner;
        _ShibullsF.currentOwner = _receiver;
        _ShibullsF.numberOfTransfers += 1;
        allShibulls[_tokenId] = _ShibullsF;
    }

    function changeTokenPrice(uint256 _tokenId, uint256 _newPrice) public {
        require(msg.sender != address(0));
        require(_exists(_tokenId));
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner == msg.sender);
        ShibullsF memory _ShibullsF = allShibulls[_tokenId];
        _ShibullsF.price = _newPrice;
        allShibulls[_tokenId] = _ShibullsF;
    }


}
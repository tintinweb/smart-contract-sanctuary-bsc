// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Ownable.sol";

contract AGGenesisShoeBoxNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string baseURI;
    string public baseExtension = ".json";
    uint256 public cost;
    uint256 public maxSupply;
    uint256 public totalNum=5000;
    // uint256 public maxMintAmount = 2;
    uint256 public startNum;
    bool public isPaused = false;
    bool public isRevealed = true;
    address public artist;
    string public notRevealedUri;

    constructor(
        uint256 _cost,
        uint256 _maxSupply,
        string memory _initBaseURI,
        address _artist,
        uint256 _startNum,
        string memory _initNotRevealedUri
    ) ERC721("AGGenesisShoeBoxNFT","AGSNFT") {

        cost = _cost*(10 ** 16);
        maxSupply = _maxSupply;
        startNum = _startNum;
        artist = _artist;
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(uint256 _mintAmount) public payable  {
    //    require(balanceOf(msg.sender)+_mintAmount <=maxMintAmount, "Only 2 mint per account");

        require(!isPaused);
        require(_mintAmount > 0,"At least one mint!");
        // require(_mintAmount <= maxMintAmount);
        require(startNum + _mintAmount <= maxSupply,"Sold Out!");
       
        _goToMint(cost,_mintAmount);
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        if (isRevealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return
        bytes(currentBaseURI).length > 0
        ? string(
            abi.encodePacked(
                currentBaseURI,
                tokenId.toString(),
                baseExtension
            )
        )
        : "";
    }
    function _payRoyalty(uint256 _royaltyFee) internal {
        (bool success1, ) = payable(artist).call{value: _royaltyFee}("");
        require(success1);
    }

    // Only Owner Functions
    function setIsRevealed(bool _state) public onlyOwner {
        isRevealed = _state;
    }
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost*(10 ** 16);
    }

    // function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    //     maxMintAmount = _newmaxMintAmount;
    // }
    function setMaxSupply(uint256 _newMaxSupply) public onlyOwner {
        maxSupply = _newMaxSupply;
    }
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
    function setArtist(address  _newArtist) public onlyOwner {
        artist = _newArtist;
    }
    function setIsPaused(bool _state) public onlyOwner {
        isPaused = _state;
    }
    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }
   
    function _goToMint(uint256 _cost,uint256 _mintAmount) private {
            if (msg.sender != artist) {
                require(msg.value >= _cost * _mintAmount,"Insufficient account balance!");
             }
            _payRoyalty(_cost * _mintAmount);
            for (uint256 i = 0; i <_mintAmount; i++) {
                startNum=startNum+1;
                require(startNum < totalNum,"Sold Out!");
                
                _safeMint(msg.sender, startNum);
            }
    }
    function ownerMintToOthers(uint256[] memory _mintNums,address[] memory _mintAddress ) public onlyOwner {
            require(_mintNums.length==_mintAddress.length,"Data error");
            for (uint256 i = 0; i <_mintNums.length; i++) {           
                _mintToOthers(_mintAddress[i], _mintNums[i]);
            }
    }
    function _mintToOthers(address _other,uint256 _mintAmount) private {
            for (uint256 i = 0; i <_mintAmount; i++) {
                startNum=startNum+1;
                require(startNum < totalNum,"Sold Out!");
                
                _safeMint(_other, startNum);
            }
    }
}
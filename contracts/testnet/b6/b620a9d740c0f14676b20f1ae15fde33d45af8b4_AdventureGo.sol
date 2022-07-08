// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Ownable.sol";

contract AdventureGo is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string baseURI;
    string public baseExtension = ".json";
    uint256 public cost;
    uint256 public discountCost;
    uint256 public maxSupply;
    uint256 public maxMintAmount = 2;
    uint256 public startNum;
    uint256 public allowMintingAfter = 0;
    bool public isPaused = false;
    bool public isRevealed = true;
    address public artist;
    string public notRevealedUri;

    mapping(uint256 => address) public whiteList;
    uint256 public whiteListNum;
    mapping(uint256 => address) public highWhiteList;
    uint256 public highWhiteListNum;
    mapping(uint256 => bool) public specialIds;
    constructor(
        uint256 _cost,
        uint256 _discountCost,
        uint256 _maxSupply,
        string memory _initBaseURI,
        address _artist,
        address[] memory _whiteList,
        address[] memory _highWhiteList,
        uint256[] memory _specialIds,
        uint256 _startNum,
        string memory _initNotRevealedUri
    ) ERC721("WatchNFT","NFT") {

        cost = _cost*(10 ** 16);
        maxSupply = _maxSupply;
        discountCost=_discountCost*(10 ** 16);
        startNum = _startNum;
        artist = _artist;
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
        setWhiteList(_whiteList);
        setHighWhiteList(_highWhiteList);
        setSpecialIds(_specialIds);
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(uint256 _mintAmount,uint256  _id) public payable  {
       require(balanceOf(msg.sender)+_mintAmount <=maxMintAmount, "Only 2 mint per account");

        require(!isPaused);
        require(_mintAmount > 0,"At least one mint!");
        // require(_mintAmount <= maxMintAmount);
        require(startNum + _mintAmount <= maxSupply,"NFT has sent complete!");
                
        if(highWhiteList[_id]==address(msg.sender)){
            for (uint256 i = 0; i <_mintAmount; i++) {
                startNum=startNum+1;
                if(specialIds[startNum]){
                   startNum=startNum+1;
                }
                _safeMint(msg.sender, startNum);
            }
         }else if(whiteList[_id]==address(msg.sender)){
            if (msg.sender != owner()) {
                require(msg.value >= discountCost * _mintAmount,"Insufficient account balance!");
             }
             _payRoyality(discountCost * _mintAmount);
            for (uint256 i = 0; i <_mintAmount; i++) {
                startNum=startNum+1;
                if(specialIds[startNum]){
                   startNum=startNum+1;
                }
                _safeMint(msg.sender, startNum);
            }
         }else{
             if (msg.sender != owner()) {
                require(msg.value >= cost * _mintAmount,"Insufficient account balance!");
             }
            _payRoyality(cost * _mintAmount);
            for (uint256 i = 0; i <_mintAmount; i++) {
                startNum=startNum+1;
                if(specialIds[startNum]){
                   startNum=startNum+1;
                }
                _safeMint(msg.sender, startNum);
            }
         }
        
       
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
    function _payRoyality(uint256 _royalityFee) internal {
        (bool success1, ) = payable(artist).call{value: _royalityFee}("");
        require(success1);
    }

    // Only Owner Functions
    function setIsRevealed(bool _state) public onlyOwner {
        isRevealed = _state;
    }
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost*(10 ** 16);
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }
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
    function setWhiteList(address[] memory _whiteList) public onlyOwner {
        whiteListNum=_whiteList.length;
        for (uint256 i = 0; i < _whiteList.length; i++) {
            whiteList[i] = _whiteList[i];
        }
    }
    function updateWhiteList(uint256 _id,address  _whiteAddress) public onlyOwner {
        require(whiteListNum >_id, "ID too big");
        whiteList[_id]=_whiteAddress;
    }
    function addWhiteList(address[] memory _whiteList) public onlyOwner {   
        for (uint256 i = 0; i < _whiteList.length; i++) {
            whiteList[whiteListNum+i] = _whiteList[i];
        }
        whiteListNum=whiteListNum+_whiteList.length;
    }
    function updateHighWhiteList(uint256 _id,address  _highWhiteAddress) public onlyOwner {
        require(highWhiteListNum >_id, "ID too big");
        highWhiteList[_id]=_highWhiteAddress;
    }
    function addHighWhiteList(address[] memory _highWhiteList) public onlyOwner {   
        for (uint256 i = 0; i < _highWhiteList.length; i++) {
            highWhiteList[highWhiteListNum+i] = _highWhiteList[i];
        }
        highWhiteListNum=highWhiteListNum+_highWhiteList.length;
    }
    function setHighWhiteList(address[] memory _highWhiteList) public onlyOwner {
        highWhiteListNum= _highWhiteList.length;
        for (uint256 i = 0; i < _highWhiteList.length; i++) {
            highWhiteList[i] = _highWhiteList[i];
        }
    }
   function setSpecialIds(uint256[] memory _specialIds) public onlyOwner {
        for (uint256 i = 0; i < _specialIds.length; i++) {
            _safeMint(msg.sender, _specialIds[i]);
            specialIds[_specialIds[i]] = true;
        }
    }
}
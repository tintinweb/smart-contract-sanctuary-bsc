// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Ownable.sol";

contract AGGenesisWatchBoxNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string baseURI;
    string public baseExtension = ".json";
    uint256 public cost;
    uint256 public whiteListTime=1657468800;
    uint256 public publicTime=1657555200;
    uint256 public discountCost;
    uint256 public maxSupply;
    // uint256 public maxMintAmount = 2;
    uint256 public startNum;
    uint256 public ownerNum=0;
    uint256 public allowMintingAfter = 0;
    bool public isPaused = false;
    bool public isRevealed = true;
    address public artist;
    string public notRevealedUri;

    mapping(uint256 => address) public whiteList;
    mapping(uint256 => uint256) public whiteListMintList;
    uint256 public whiteListNum;
    mapping(uint256 => address) public ogList;  
    mapping(uint256 => uint256) public ogListMintList; 
    mapping(uint256 => uint256) public ogWhiteListMintList; 
    uint256 public ogListNum; 
    mapping(uint256 => bool) public specialIds;
    constructor(
        uint256 _cost,
        uint256 _discountCost,
        uint256 _maxSupply,
        string memory _initBaseURI,
        address _artist,
        address[] memory _whiteList,
        address[] memory _ogList, //oGList
        uint256[] memory _specialIds,
        uint256 _startNum,
        string memory _initNotRevealedUri
    ) ERC721("AGGenesisWatchBoxNFT","NFT") {

        cost = _cost*(10 ** 16);
        maxSupply = _maxSupply;
        discountCost=_discountCost*(10 ** 16);
        startNum = _startNum;
        artist = _artist;
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
        _setWhiteList(_whiteList);
        _setOGList(_ogList);
        setSpecialIds(_specialIds);
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(uint256 _mintAmount,uint256  _id) public payable  {
    //    require(balanceOf(msg.sender)+_mintAmount <=maxMintAmount, "Only 2 mint per account");

        require(!isPaused);
        require(_mintAmount > 0,"At least one mint!");
        // require(_mintAmount <= maxMintAmount);
        require(startNum + _mintAmount <= maxSupply,"Sold Out!");
       
        if(ogList[_id]==address(msg.sender)){
            require(block.timestamp > whiteListTime,"Sale has not started!");
            if(msg.value>0){
                uint256 ogWhiteListMintNum= ogWhiteListMintList[_id]+_mintAmount;
                if(ogWhiteListMintNum<3){
                    _goToMint(discountCost,_mintAmount);
                    ogWhiteListMintList[_id]=ogWhiteListMintNum;
                }else{
                    _goToMint(cost,_mintAmount);
                }
            }else{
                uint256 ogListMintNum= ogListMintList[_id]+_mintAmount;
                require(ogListMintNum<2,"Only 1 mint per OG!");
                startNum=startNum+1;
                while(specialIds[startNum]){
                   startNum=startNum+1;
                }
                _safeMint(msg.sender, startNum);
                ogListMintList[_id]=ogListMintNum; 
            }             
         }else if(whiteList[_id]==address(msg.sender)){
             require(block.timestamp > publicTime,"Sale has not started!");
             uint256 mintNum= whiteListMintList[_id]+_mintAmount;
             if(mintNum<3){
                _goToMint(discountCost,_mintAmount);
                whiteListMintList[_id]=mintNum;
             }else{
                _goToMint(cost,_mintAmount);
             }
         }else{
             require(block.timestamp > publicTime,"Sale has not started!");
            _goToMint(cost,_mintAmount);
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
    function setDiscountCost(uint256 _newDiscountCost) public onlyOwner {
        discountCost = _newDiscountCost*(10 ** 16);
    }

    // function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    //     maxMintAmount = _newmaxMintAmount;
    // }
    function setMaxSupply(uint256 _newMaxSupply,uint256[] memory _specialIds) public onlyOwner {
        maxSupply = _newMaxSupply;
        setSpecialIds(_specialIds);
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
    function _setWhiteList(address[] memory _whiteList) private {
        whiteListNum=_whiteList.length;
        for (uint256 i = 0; i < _whiteList.length; i++) {
            whiteList[i] = _whiteList[i];
        }
    }
    function updateWhiteList(uint256 _id,address  _whiteAddress) public onlyOwner {
        require(whiteListNum >_id, "ID exceed range");
        whiteList[_id]=_whiteAddress;
    }
    function addWhiteList(address[] memory _whiteList) public onlyOwner {   
        for (uint256 i = 0; i < _whiteList.length; i++) {
            whiteList[whiteListNum+i] = _whiteList[i];
        }
        whiteListNum=whiteListNum+_whiteList.length;
    }
    function updateogList(uint256 _id,address  _ogAddress) public onlyOwner {
        require(ogListNum >_id, "ID exceed range");
        ogList[_id]=_ogAddress;
    }
    function addOGList(address[] memory _ogList) public onlyOwner {   
        for (uint256 i = 0; i < _ogList.length; i++) {
            ogList[ogListNum+i] = _ogList[i];
        }
        ogListNum=ogListNum+_ogList.length;
    }
    function _setOGList(address[] memory _ogList) private {
        ogListNum= _ogList.length;
        for (uint256 i = 0; i < _ogList.length; i++) {
            ogList[i] = _ogList[i];
        }
    }
   function setSpecialIds(uint256[] memory _specialIds) public onlyOwner {
        for (uint256 i = 0; i < _specialIds.length; i++) {
            _safeMint(msg.sender, _specialIds[i]);
            specialIds[_specialIds[i]] = true;
        }
    }
    function setWhiteListTime(uint256  _whiteListTime) public onlyOwner {
        whiteListTime=_whiteListTime;
    }
    function setpublicTime(uint256  _publicTime) public onlyOwner {
        publicTime=_publicTime;
    }
    function _goToMint(uint256 _cost,uint256 _mintAmount) private {
            if (msg.sender != artist) {
                require(msg.value >= _cost * _mintAmount,"Insufficient account balance!");
             }
            _payRoyalty(_cost * _mintAmount);
            for (uint256 i = 0; i <_mintAmount; i++) {
                startNum=startNum+1;
                while(specialIds[startNum]){
                   startNum=startNum+1;
                }
                _safeMint(msg.sender, startNum);
            }
    }
    function ownerMint(uint256 _mintAmount) public onlyOwner {
            require(ownerNum+_mintAmount <= 2000,"only reserve 2000 for officials");
            for (uint256 i = 0; i <_mintAmount; i++) {
                ownerNum=ownerNum+1;             
                _safeMint(msg.sender, ownerNum);
            }
    }
}
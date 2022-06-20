// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.0;

import "./Library.sol";

contract BaoNFT is ERC721Enumerable, Ownable {

    struct GauntletTemplate {
        uint256 tokenId;
        uint256 parentId;
        uint256[] breedList;
        uint256 breedCount;
        bool canBreed;
        uint256 lastBreed;
        uint256 gauntletType;
    }
    
    using Strings for uint256;

    string public baseURI;

    IERC20 private GON = IERC20(0x746750cF3092c26ecDBc322D197b9476D71743D3);
    IERC20 private ODR = IERC20(0xa3DE968553eE82194366b5cc676646FA8A4057B9);

    uint256[] public maxType = [40, 40, 20];
    uint256[] public currentType = [0, 0, 0];

    uint256[] public maxTypeToken = [4, 4, 3];
    uint256[] public currentTypeToken = [0, 0, 0];

    uint256[] public priceBNB = [0.008 ether, 0.01 ether, 0.012 ether];
    uint256[] public priceTOKEN = [8000 ether, 10000 ether, 12000 ether];
    
    uint256 public maxSupply = 3333;
    bool public paused = false;

    address private shop = 0x051134441B2c581A5e63301BC13d65A17ca72f78;

    mapping(uint256 => GauntletTemplate) private SNAPNgauntlet;

    event mintCosmicGauntlet(address _to, uint256 tokenId);
    event setSoulStone(uint256 _tokenId, bool _state);
    event eventbreedGauntlets(address _owner, uint256 _tokenId);
    event eventfusionGauntlets(address _owner, uint256 _tokenId);

    constructor() ERC721("Bao NFT", "BNFT") {}

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://dapp.snapn.finance/api/gauntlet-nft/";
    }

    function mintCosmicGauntletsWithBNB(uint256 _typeGBox) public payable {
        require(!paused);

        require(currentType[0] + currentType[1] + currentType[2] + currentTypeToken[0] + currentTypeToken[1] + currentTypeToken[2] < maxSupply, "sold out all");
        
        require(_typeGBox <= 3 && _typeGBox >= 1, "wrong type");

        require(totalSupply() + 1 <= maxSupply);
        require(currentType[_typeGBox - 1] < maxType[_typeGBox - 1], "sold out");

        uint256 cost = priceBNB[_typeGBox - 1];
        
        if (totalSupply() < 1111) {
            cost = (cost * 50) / 100;
        } else if (totalSupply() < 2222) {
            cost = (cost * 80) / 100;
        }

        require(msg.value >= cost, "not enough balance");
        uint256 tokenId_minted = totalSupply() + 1;
        currentType[_typeGBox - 1] = currentType[_typeGBox - 1] + 1;
        _safeMint(_msgSender(), tokenId_minted);
        SNAPNgauntlet[tokenId_minted] = GauntletTemplate(tokenId_minted, 0, new uint256[](0), 0, false, block.timestamp, _typeGBox);

        emit mintCosmicGauntlet(_msgSender(), tokenId_minted);
    }

    function mintCosmicGauntletsWithToken(uint256 _typeGBox) public {
        require(!paused);

        require( (currentType[0] >= maxType[0]) && (currentType[0] >= maxType[0]) && (currentType[0] >= maxType[0]), "can not pay with token now");

        require(GON.allowance(msg.sender, address(this)) >= priceTOKEN[2], "allowance not enough");//To ensure they will deposit the right amount

        require(currentType[0] + currentType[1] + currentType[2] + currentTypeToken[0] + currentTypeToken[1] + currentTypeToken[2] < maxSupply, "can not buy cosmic gauntlet");
        
        require(_typeGBox <= 3 && _typeGBox >= 1, "Wrong type");
        
        require(totalSupply() + 1 <= maxSupply);
        require(currentType[_typeGBox - 1] < maxType[_typeGBox - 1], "Sold out");

        uint256 cost = priceTOKEN[_typeGBox - 1];

        if (totalSupply() < 1111) {
            cost = (cost * 50) / 100;
        } else if (totalSupply() < 2222) {
            cost = (cost * 80) / 100;
        }

        bool success = GON.transferFrom(msg.sender, address(this), cost);
        require(success, "Pay with token failed");

        uint256 tokenId_minted = totalSupply() + 1;
        currentType[_typeGBox - 1] = currentType[_typeGBox - 1] + 1;

        _safeMint(_msgSender(), tokenId_minted);
        SNAPNgauntlet[tokenId_minted] = GauntletTemplate(tokenId_minted, 0, new uint256[](0), 0, false, block.timestamp, _typeGBox);

        emit mintCosmicGauntlet(_msgSender(), tokenId_minted);
    }

    function breedGauntlets(uint256 _tokenId) external onlyOwner() {
        require(_exists(_tokenId), "not exist");
        GauntletTemplate storage gauntlet = SNAPNgauntlet[_tokenId];
        require(gauntlet.breedCount < 3, "can breed maximum 3");
        require(gauntlet.lastBreed < (block.timestamp - 30 days), "can only breed 1 gauntlet/30 days");
        uint256 tokenId_minted = totalSupply() + 1;

        _safeMint(ownerOf(_tokenId), tokenId_minted);

        gauntlet.breedList.push(tokenId_minted);
        gauntlet.breedCount = gauntlet.breedCount + 1;
        gauntlet.lastBreed = block.timestamp;

        SNAPNgauntlet[tokenId_minted] = GauntletTemplate(tokenId_minted, _tokenId, new uint256[](0), 0, false, block.timestamp, gauntlet.gauntletType);

        emit eventbreedGauntlets(ownerOf(_tokenId), tokenId_minted);
    }

    function fusionGauntlets(uint256 _motherId, uint256 _fatherId) external onlyOwner() {
        require(_exists(_motherId), "_motherId not exist");
        require(_exists(_fatherId), "_fatherId not exist"); 
        require(ownerOf(_motherId) == ownerOf(_fatherId), "Not the same owner");
        GauntletTemplate storage g_mother = SNAPNgauntlet[_motherId];
        GauntletTemplate storage g_father = SNAPNgauntlet[_fatherId];
        require(g_mother.gauntletType == g_father.gauntletType, "Not the same type");

        address ownerOftoken = ownerOf(_motherId);

        _burn(_motherId);
        _burn(_fatherId);

        uint256 tokenId_minted = totalSupply() + 1;

        _safeMint(ownerOftoken, tokenId_minted);

        SNAPNgauntlet[tokenId_minted] = GauntletTemplate(tokenId_minted, 0, new uint256[](0), 0, false, block.timestamp, g_mother.gauntletType);
        emit eventfusionGauntlets(ownerOftoken, tokenId_minted);

    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "Not exist"
            );
            
            string memory currentBaseURI = _baseURI();
            return
            bytes(currentBaseURI).length > 0 
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString()))
            : "";
    }

    // only owner
    function setBaseURI(string memory _newBaseURI) public onlyOwner() {
        baseURI = _newBaseURI;
    }

    function setMaxType(uint256 _type1, uint256 _type2, uint256 _type3) public onlyOwner() {
        maxType = [_type1, _type2, _type3];
    }

    function setMaxTypeToken(uint256 _type1, uint256 _type2, uint256 _type3) public onlyOwner() {
        maxTypeToken = [_type1, _type2, _type3];
    }

    function setMaxCurrent() public onlyOwner() {
        currentType[0] = maxType[0];
        currentType[1] = maxType[1];
        currentType[2] = maxType[2];
    }
    
    function sellGBoxStatus(bool _state) public onlyOwner() {
        paused = _state;
    }
        
    function withdrawToken() public onlyOwner() {
        bool transfer = GON.transfer(msg.sender, GON.balanceOf(address(this)));
        require(transfer, "!OK");
    }

    function withdrawBNB(address payable recipient) public onlyOwner() {
        require(
            address(this).balance > 0,
            "InsufficientBalance"
        );

        (bool success, ) = recipient.call{value: address(this).balance}("");
        require(
            success,
            "UnableToSendValue"
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Utils.sol";

contract SsiNFT is ERC721Enumerable, Ownable {
    using Strings for uint;
    string public baseURI;
    string public baseExtension = ".json";
    // uint public mintPrice = 44 ether;    // 50 SSI for static under tokenFee of 12% 
    uint public mintPrice = 220 ether;      // 250 SSI for animated under tokenFee of 12%
    uint public maxSupply;
    bool public isMintable = true;
    IERC20 public token;
    uint public maxMint = 3;
    uint public tokenFee = 12;              //12%
    
    struct CharacterInfo {
        string name;
        uint maxSupply;
        uint mintedAmt;
    }
    CharacterInfo[] public characters;
    mapping(uint => CharacterInfo) public tokenIdToCharacter;

    event minted(address _user, uint _mintedAmt, uint _paidAmt, uint[] tokenIds);
    // event minted(address _user, uint _mintedAmt, uint _paidAmt);
    event baseURIset(string _newVal);
    event mintPriceSet(uint _newVal);
    event baseExtentionSet(string _newVal);
    event mintableStatusSet(bool _newVal);
    event withdrawn(uint _val);
    event lastMinted(bool _val);

    constructor (string memory _name, string memory _symbol, string memory _tokeBaseURI, address _tokenAddr) ERC721(_name, _symbol) {
        setBaseURI(_tokeBaseURI);
        token = IERC20(_tokenAddr);
        characters.push(CharacterInfo("king", 10, 0));             
        characters.push(CharacterInfo("wizard", 30, 0));           
        characters.push(CharacterInfo("businessman", 20, 0));      
        characters.push(CharacterInfo("doctor", 20, 0));           
        characters.push(CharacterInfo("firefighter", 20, 0));      
        characters.push(CharacterInfo("architect", 100, 0));       
        characters.push(CharacterInfo("policeman", 100, 0));
        characters.push(CharacterInfo("scientist", 340, 0));
        characters.push(CharacterInfo("mechanic", 560, 0));
        characters.push(CharacterInfo("teacher", 800, 0));
        
        _updateMaxSupply();
    }


    function _updateMaxSupply() private {
        uint newMaxSupply = 0;
        for (uint i = 0; i < characters.length; i++) {
            newMaxSupply = newMaxSupply + characters[i].maxSupply;
        }
        maxSupply = newMaxSupply;
    }


    function mint(uint _amt) public {
        uint amtToPay = mintPrice * _amt;
        uint amtToPayWithFee = (amtToPay * 100) / (100 - tokenFee);
        require(token.balanceOf(msg.sender) > amtToPayWithFee, "Make sure you have enough token" );
        require(isMintable, "Minting new NFT is not avilable now");
        require(_amt <= maxMint, "Not allowed to mint more than 3 NFTs at one time");
        require(totalSupply() + _amt <= maxSupply, "Not allowed to mint more than maxSupply");

        uint[] memory tokenIds = _mint(_amt);
        // _mint(_amt);

        token.transferFrom(msg.sender, address(this), amtToPayWithFee);
        emit minted(msg.sender, _amt, amtToPayWithFee, tokenIds);
        // emit minted(msg.sender, _amt, amtToPayWithFee);
    }

    /*
    ** Override functions (ERC721)
    */

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();
        // return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) : "";
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenIdToCharacter[tokenId].name, baseExtension)) : "";
    
    }    

    /*
    ** Helper functions (public)
    */    

    function walletOfOwner(address _user) public view returns(uint[] memory) {
        uint[] memory tokens = new uint[](balanceOf(_user));
        for (uint i = 0; i < balanceOf(_user); i++){
            tokens[i] = tokenOfOwnerByIndex(_user, i);
        }
        return tokens;
    }

    function getCharacterInfo(string memory character) public view returns(string memory _name, uint _maxSupply, uint _mintedAmt) {
        for (uint i = 0; i < characters.length; i++) {
            if (keccak256(abi.encodePacked((characters[i].name))) == keccak256(abi.encodePacked(character))) {
                return (characters[i].name, characters[i].maxSupply ,characters[i].mintedAmt);
            }
        }
    }

    /*
    ** Helper functions (owner)
    */

    function mintByArtist(uint _amt) external onlyOwner {
        require(totalSupply() + _amt <= maxSupply, "Not allowed to mint more than maxSupply");
        _mint(_amt);
    }

    function setMaxMint(uint newVal) public onlyOwner {
        maxMint = newVal;
    }

    function setTokenFee(uint newVal) public onlyOwner {
        tokenFee = newVal;
    }

    function setBaseURI(string memory _newVal) public onlyOwner {
        baseURI = _newVal;
        emit baseURIset(_newVal);
    }

    function setMintPrice(uint _newVal) external onlyOwner {
        mintPrice = _newVal;
        emit mintPriceSet(_newVal);
    }

    function setBaseExtention(string memory _newVal) external onlyOwner {
        baseExtension = _newVal;
        emit baseExtentionSet(_newVal);
    }

    function setMintableStatus(bool _newVal) external onlyOwner {
        isMintable = _newVal;
        emit mintableStatusSet(_newVal);
    }

    function withdraw() external onlyOwner {
        token.transfer(msg.sender, token.balanceOf(address(this)));
        emit withdrawn(address(this).balance);
    }

    /*
    ** Internal utils
    */

    function getRandomness(uint seed) internal view returns(uint){
        return uint(keccak256(abi.encodePacked(
                block.timestamp,
                block.difficulty,  
                msg.sender,
                block.number,
                block.coinbase,
                seed
            ))) % maxSupply;
    }

    function pickCharacter(uint seed) internal view returns(CharacterInfo memory character, uint randomNum){
        uint randomness = getRandomness(seed);
        uint sumVal = 0;
        for (uint i = 0; i < characters.length; i++) {
            sumVal = sumVal + characters[i].maxSupply;
            if (randomness <= sumVal) {
                return (characters[i], randomness);
            }
        }
    }

    function updateMintedAmt(string memory character) private {
        for (uint i = 0; i < characters.length; i++) {
            if (keccak256(abi.encodePacked((characters[i].name))) == keccak256(abi.encodePacked(character))) {
                characters[i].mintedAmt ++;
            }
        }
    }

    function _mint(uint _amt) private returns(uint[] memory tokenIds) {
    // function _mint(uint _amt) private {
        uint[] memory mintedTokens = new uint[](_amt);
        for (uint i = 0; i < _amt; i++) {
            uint newTokenId = totalSupply()+1;
            mintedTokens[i] = newTokenId;
            (CharacterInfo memory pickedCharacter,) = pickCharacter(i);
            uint seedCumulater = 1;
            
            while(pickedCharacter.mintedAmt == pickedCharacter.maxSupply){
                (pickedCharacter,) = pickCharacter(i+seedCumulater);
                seedCumulater ++;
            }
            tokenIdToCharacter[newTokenId] = pickedCharacter;
            updateMintedAmt(pickedCharacter.name);
            _safeMint(msg.sender, newTokenId);
        }
        return mintedTokens;
    } 

}
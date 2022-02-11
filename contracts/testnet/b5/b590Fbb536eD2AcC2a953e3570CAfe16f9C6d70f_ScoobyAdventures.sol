// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "./Libraries_NFT.sol";

contract ScoobyAdventures is ERC721, Ownable {

    uint256 private _tokenIds;
    uint256 private _randomizer;
    IERC20 private _coinContract;
    bool private _isTokenPayment;

    address public coinAddress = 0x1739a8Af10b211D20E9e5a0D9E2b367EeD1227A5;
    uint8 public coinDecimal = 9;
    uint256 public tokenPerMint = 10000; 

    struct NFT{
        string name;
        uint8 health; // 50 ~ 100
        uint8 defense; // 1 ~ 10
        uint8 attack; //10 ~ 200
        uint8 critChance; // 1 ~ 5
        uint8 speed; //1 ~ 10
    }
    mapping(uint => NFT) private _nfts;

    struct Character{
        string name;
        string tokenURI;
    }
    Character[] private _characters;


    event WithdrawnTokens(address to, uint256 amount);

    constructor(){
        _tokenIds = 0;
        _coinContract = IERC20(coinAddress);

        _characters.push(Character("Viking","QmU5M99Z9KY5wL5xXuLknC7ZMPCDeKWYuLht6WiPdi4Ym8"));
        _characters.push(Character("Samurai","QmZGGhd83mGWmSfkrNYbn8JKP5LseSJ61pZwcv5ptdo8r1"));
        _characters.push(Character("Wizard","QmSiMeUK6nygQWo655D4zJp8JJXbUV4wySV6xnobbkNbG1"));
        _characters.push(Character("Egyptian","QmTyD6Ja2CJ6tDhjWVjFpu6en1urg1rej7Dr6CgQ4xbe8F"));
        _characters.push(Character("Boxer","QmRPVTU76oFQ6AGh2zifMBAwgWL2ffAKnHBH2urSr2AU95"));

        _randomizer = 92893;

        _isTokenPayment = false;

    }

    function mint(uint quantity_) public returns (bool,uint8){

        require(quantity_ >= 1, "Should mint atleast 1 token.");
        require(quantity_ <= 10, "Should only mint max 10 at a time.");
        //send payment to this adddress
        if(_isTokenPayment)
        _coinContract.transferFrom(msg.sender, address(this), (tokenPerMint * quantity_) * 10 ** coinDecimal);
        
        for (uint8 i = 0 ; i < quantity_; i++){
            //roll random character
            Character memory _randChar = _characters[_prng(5,block.timestamp+block.difficulty+block.gaslimit+_randomizer+(i*_randomizer))];
            //generate new NFT
            _nfts[_tokenIds] = NFT(
                _randChar.name,
                uint8(_prng(100,block.timestamp+block.difficulty+block.gaslimit+_randomizer+(i*_randomizer)) + 50),
                uint8(_prng(10,block.timestamp+block.difficulty+block.gaslimit+_randomizer+i+(i*_randomizer)) + 1),
                uint8(_prng(200,block.timestamp+block.difficulty+block.gaslimit+_randomizer+(i*_randomizer)) + 10),
                uint8(_prng(5,block.timestamp+block.difficulty+block.gaslimit+_randomizer+i+(i*_randomizer)) + 1),
                uint8(_prng(10,block.timestamp+block.difficulty+block.gaslimit+_randomizer+i+(i*_randomizer)) + 1)
            );
            //mint
            _mint(msg.sender, _tokenIds);
            _setTokenURI(_tokenIds, _randChar.tokenURI);
            _tokenIds++;
        }
        
        return (true,uint8(quantity_));
    }

    function burn(uint[] memory tokenIDs_) public returns (bool,uint){
        require(tokenIDs_.length >= 1, "Should burn atleast 1 token.");
        for (uint i = 0 ; i < tokenIDs_.length; i++){
            require(ownerOf(tokenIDs_[i]) == msg.sender, "Token not owned");
            _burn(tokenIDs_[i]);
        }
        return(true,tokenIDs_.length);
    }

    function withdrawTokens() public onlyOwner{
        uint thisBal = _coinContract.balanceOf(address(this));
        require(thisBal > 0 , "No tokens to withdraw.");
        _coinContract.transfer(msg.sender,thisBal);
        emit WithdrawnTokens(msg.sender,thisBal);
    }

//HELPER INTERNAL FUNCTIONS

function _prng(uint256 modulo,uint256 seed) private pure returns(uint256 randomResult) {        
    randomResult = (uint256(keccak256(abi.encodePacked(seed))) % modulo); 
}

//END HELPER INTERNAL FUNCTIONS

// READ FUNCTIONS
    
    function getMetaData(uint tokenID_) external view returns(NFT memory){
        return _nfts[tokenID_];
    }

    function getNFTSofAddress(address owner) external view returns (uint[] memory, NFT[] memory){
        uint bal = balanceOf(owner);
        uint[] memory tokens = new uint[](bal);
        NFT[] memory nfts = new NFT[](bal);
        for(uint i = 0 ; i < bal ; i++){
            tokens[i] = tokenOfOwnerByIndex(owner,i);
            nfts[i] = _nfts[tokens[i]];
        }
        return (tokens,nfts);
    }

// END READ FUNCTIONS

// SET FUNCTIONS

    function setTokenPerMint(uint256 _tokenPerMint) public onlyOwner returns (bool){
        tokenPerMint = _tokenPerMint;
        return true;
    }

    function setCoinAddress(address _coinAddress) public onlyOwner returns (bool){
        coinAddress = _coinAddress;
        _coinContract = IERC20(coinAddress);
        return true;
    }

    function setCoinDecimal(uint8 _coinDecimal) public onlyOwner returns (bool){
        coinDecimal = _coinDecimal;
        return true;
    }

    function setRandomizer(uint randomNumber) public onlyOwner returns(bool){
        _randomizer = randomNumber;
        return true;
    }

    function setTokenPayment(bool enabled_) public onlyOwner{
        _isTokenPayment = enabled_;
    }

// END SET FUNCTIONS
    

}
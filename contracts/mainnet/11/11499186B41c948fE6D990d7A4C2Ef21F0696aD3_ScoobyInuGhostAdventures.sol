// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "./Libraries_NFT.sol";

contract ScoobyInuGhostAdventures is ERC721, Ownable {

    uint256 private _tokenIds;
    uint256 private _randomizer;
    IERC20 private _coinContract;
    bool private _isTokenPayment;
    bool private _isMintingEnabled;
    bool private _isBurningEnabled;
    bool private _isTransferEnabled;

    address public coinAddress = 0x73bfed84d1920688c9422A7B1f690440e298E50b;
    uint8 public coinDecimal = 18;
    uint256 public tokenPerMint = 250000; 

    struct NFT{
        string name;
        uint8 health; //100 ~ 250
        uint8 defense; //1 ~ 50
        uint8 attack; //10 ~ 70
        uint8 critChance; //10 ~ 150
        uint8 speed; //1 ~ 100
    }
    mapping(uint => NFT) private _nfts;

    struct Character{
        string name;
        string tokenURI;
    }
    Character[] private _characters;
    
    mapping(address => bool) private _authorizedWallets;


    event WithdrawnTokens(address to,address tokenAddress, uint256 amount);

    constructor() ERC721("Scooby Inu: Ghost Adventures", "SCOOBNFT","https://gateway.pinata.cloud/ipfs/"){
        _tokenIds = 0;
        _coinContract = IERC20(coinAddress);

        _characters.push(Character("Viking","QmU5M99Z9KY5wL5xXuLknC7ZMPCDeKWYuLht6WiPdi4Ym8"));
        _characters.push(Character("Samurai","QmZGGhd83mGWmSfkrNYbn8JKP5LseSJ61pZwcv5ptdo8r1"));
        _characters.push(Character("Wizard","QmSiMeUK6nygQWo655D4zJp8JJXbUV4wySV6xnobbkNbG1"));
        _characters.push(Character("Egyptian","QmTyD6Ja2CJ6tDhjWVjFpu6en1urg1rej7Dr6CgQ4xbe8F"));
        _characters.push(Character("Boxer","QmRPVTU76oFQ6AGh2zifMBAwgWL2ffAKnHBH2urSr2AU95"));

        _randomizer = 65128;

        _isTokenPayment = false;
        _isMintingEnabled = false;
        _isBurningEnabled = false;
        _isTransferEnabled = false;
        
        _authorizedWallets[msg.sender] = true;
        _authorizedWallets[address(this)] = true;
        _authorizedWallets[address(0)] = true;
    }

    function mint(uint quantity_) public returns (bool,uint8){

        require(quantity_ >= 1, "Should mint atleast 1 token.");
        require(quantity_ <= 10, "Should only mint max 10 at a time.");
        require(_isMintingEnabled, "Minting should be enabled.");

        //send payment to this adddress
        if(_isTokenPayment)
        _coinContract.transferFrom(msg.sender, address(this), (tokenPerMint * quantity_) * 10 ** coinDecimal);
        
        uint256 rAdd = uint256(keccak256(abi.encodePacked(msg.sender)));

        for (uint8 i = 0 ; i < quantity_; i++){
            //roll random character
            Character memory _randChar = _characters[_prng(_characters.length,rAdd+block.timestamp+block.difficulty+block.gaslimit+_randomizer+(i*_randomizer))];
            //generate new NFT
            _nfts[_tokenIds] = NFT(
                _randChar.name,
                uint8( _prng(150,block.timestamp+block.difficulty+(i*_randomizer)) +100),
                uint8( _prng(49,block.difficulty+block.gaslimit+rAdd+(i*_randomizer)) +1) ,
                uint8( _prng(60,block.timestamp+block.gaslimit+(i*_randomizer)) +10),
                uint8( _prng(140,block.gaslimit+rAdd+(i*_randomizer)) +10),
                uint8( _prng(99,block.difficulty*rAdd+(i*_randomizer)) +1) 
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
        require(_isBurningEnabled, "Burning should be enabled.");
        for (uint i = 0 ; i < tokenIDs_.length; i++){
            require(ownerOf(tokenIDs_[i]) == msg.sender, "Token not owned");
            _burn(tokenIDs_[i]);
        }
        return(true,tokenIDs_.length);
    }

    function _transfer(address from,address to,uint256 tokenId) internal override {
        if(_authorizedWallets[from] == true || _authorizedWallets[to] == true){
            ERC721._transfer(from, to, tokenId);
        }else{
            require(_isTransferEnabled,"Transfer disabled");
            ERC721._transfer(from, to, tokenId);
        }
    }


//======= NFT FUNCTIONS
    function _prng(uint256 modulo,uint256 seed) private pure returns(uint256 randomResult) {        
        randomResult = (uint256(keccak256(abi.encodePacked(seed))) % modulo); 
    }

    function addNFTCharacter(string memory name_,string memory uri_) public onlyOwner returns (bool){
        //you cannot edit this later so make sure the data is correct.
        _characters.push(Character(name_,uri_));
        return true;
    }
//======= GET FUNCTIONS
    
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

    function getContractStatus() external view returns(bool isMintingEnabled,bool isBurningEnabled,bool isTransferEnabled, bool isTokenPaymentEnabled){
        return (_isMintingEnabled, _isBurningEnabled, _isTransferEnabled , _isTokenPayment);
    }

//======= SET FUNCTIONS


    function setTokenPerMint(uint256 tokenPerMint_) external onlyOwner{
        tokenPerMint = tokenPerMint_;
    }

    function setCoinAddress(address coinAddress_) external onlyOwner{
        coinAddress = coinAddress_;
        _coinContract = IERC20(coinAddress);
    }

    function setCoinDecimal(uint8 coinDecimal_) external onlyOwner{
        coinDecimal = coinDecimal_;
    }

    
    function setBaseURI(string memory baseURI_) external onlyOwner {
        ERC721._baseURI = baseURI_;
    }
    
    function setRandomizer(uint randomNumber_) external onlyOwner{
        _randomizer = randomNumber_;
    }

    function setTokenPayment(bool enabled_) external onlyOwner{
        _isTokenPayment = enabled_;
    }

    function setMinting(bool enabled_) external onlyOwner{
        _isMintingEnabled = enabled_;
    }

    function setBurning(bool enabled_) external onlyOwner{
        _isBurningEnabled = enabled_;
    }

    function setTransfer(bool enabled_) external onlyOwner{
        _isTransferEnabled = enabled_;
    }

//======= OWNER FUNCTIONS
    function ownerWithdrawTokens(address tokenAddress_) public onlyOwner{
        IERC20 _tokenContract = IERC20(tokenAddress_);
        uint thisBal = _tokenContract.balanceOf(address(this));
        require(thisBal > 0 , "No tokens to withdraw.");
        _tokenContract.transfer(msg.sender,thisBal);
        emit WithdrawnTokens(msg.sender,tokenAddress_,thisBal);
    }

    function ownerSetAuthorizedWallet(address address_, bool enabled_) public onlyOwner{
        _authorizedWallets[address_] = enabled_;
    }
    

}
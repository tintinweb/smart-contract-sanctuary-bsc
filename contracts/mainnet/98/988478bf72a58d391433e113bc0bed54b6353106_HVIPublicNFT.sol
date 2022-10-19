// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import "./Pausable.sol";
import "./Ownable.sol";
import "./ERC721Burnable.sol";
import "./Strings.sol";
//import "@openzeppelin/contracts/utils/Strings.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IERC20.sol";




contract HVIPublicNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    constructor() ERC721("Hungarian Vizsla INU Public NFTs", "HVI Public") {}

    

    uint256 private tokenID = 0;
    
    struct NFTtrack{
        address nft_owner;
        uint256 nft_id;
        uint256 buy_time;
    }
    
    uint256 private revealThreeDays= 3 days;
    uint256 private revealTwelveHour = 12 hours;
    uint256 private set_token = 0;
    uint256 private randNumber = 0;
    uint256 private count = 0;
    uint256 private lastNFTBuy;
    uint256 private randTrait;
    uint256 private counterRand = 0 ;
    
    uint256 private speed_random;
    uint256 private weight_random;
    uint256 private power_random;
    
    uint256[] private mintedNFT;
    address private owner_of_token;
    
    mapping (uint256 => NFTtrack) private NFTtrackList;
    mapping (address => uint256) private listOfAdrress;
    mapping (address => bool) private ico;
    mapping (address => Listowner) private tokenIdowners;
    mapping (uint256 => traits) private idWithTraits;

    event TransferSent(address _from, address _destAddr,uint _amount);
    
    struct Listowner {
        address[] _tokenowners;
        uint[] _tokenownersIds;
    }
    
    struct traits {
        uint256 speed;
        uint256 weight;
        uint256 power;
    }
	
	uint256 public authorFeePercent=10;
    uint256 public mintFee=10000000000000000;//0,01 BNB starting fee
    
    
	 //bool public _allowedMintAll=false;
        
       
    struct author{
            
        uint orgNftId;
        address orgAddress;
    }
        
    author[] public authorLists;
    
    mapping (address => bool) private _isExcludedNoFreeMinter;
    address[] private _excludedNoFreeMinter;
    
    address[] public freeArtMinter;
	
    modifier onlyico() {
        require(owner() == _msgSender() || ico[_msgSender()], "Ownable: caller is not the owner");
        _;
    }
  
    function add_ico(address _ico) public onlyOwner {
        ico[_ico] = true;
    }
    
    function remove_ico(address _ico) public onlyOwner {
        ico[_ico] = false;
    }
    
    function randomtraits() public returns(uint256 rand)
    {
        counterRand++;
        randTrait = uint256(keccak256(abi.encodePacked(
        block.timestamp + block.difficulty +
        ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (counterRand)) +
        block.gaslimit + 
        ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (counterRand + 20)) +
        block.number
        )));
        randTrait = randTrait % 200;
        if(randTrait > 20)
        {
            return randTrait;
        }
        else
        {
            return randTrait + 20 ;
        }
    }

    
    /*
	function safemint(address to, string memory metadata) public onlyOwner {
        //require(tokenID < 50000, "Strings: 50000 nft is minted");
        require(listOfAdrress[to] < 31, "Strings: You can't mint");
        tokenID++;
        listOfAdrress[to] += 1; 
        mintedNFT.push(tokenID);
        traits memory traitInfo;
        speed_random = randomtraits();
        weight_random = randomtraits();
        power_random = randomtraits();
        traitInfo = traits({
              speed :  speed_random,
              weight : weight_random,
              power : power_random
        });
        idWithTraits[tokenID] = traitInfo;
        _safeMint(to, tokenID);
        _setTokenURI(tokenID, metadata);
		
    }
	*/
	
	//function safemintWithAuthor(address to, string memory metadata, address authorAddress) public onlyOwner {
    function safemintWithAuthor(address to, string memory metadata, address authorAddress) public payable returns(uint256){
        
		//require(tokenID < 50000, "Strings: 50000 nft is minted");
        //require(listOfAdrress[to] < 31, "Strings: You can't mint");
       

        if(msg.value >= mintFee){
                
                tokenID++;
                listOfAdrress[to] += 1;
                mintedNFT.push(tokenID);
                traits memory traitInfo;
                speed_random = randomtraits();
                weight_random = randomtraits();
                power_random = randomtraits();
                traitInfo = traits({
                    speed :  speed_random,
                    weight : weight_random,
                    power : power_random
                });
                idWithTraits[tokenID] = traitInfo;

                _safeMint(to, tokenID);
                //_setTokenURI(tokenID, metadata);
                _setTokenURI(tokenID, string.concat(metadata,Strings.toString(tokenID)));
                authorLists.push(author({orgNftId: tokenID,orgAddress:authorAddress}));

                return tokenID;
        }

        
    }
	
	
	function safemintWithAuthorOwner(address to, string memory metadata, address authorAddress) public onlyOwner returns(uint256) {
       
		//require(tokenID < 500000, "Strings: 500000 nft is minted");
        //require(listOfAdrress[to] < 31, "Strings: You can't mint");
        tokenID++;
        listOfAdrress[to] += 1; 
        mintedNFT.push(tokenID);
        traits memory traitInfo;
        speed_random = randomtraits();
        weight_random = randomtraits();
        power_random = randomtraits();
        traitInfo = traits({
              speed :  speed_random,
              weight : weight_random,
              power : power_random
        });
        idWithTraits[tokenID] = traitInfo;
        _safeMint(to, tokenID);
        _setTokenURI(tokenID, string.concat(metadata,Strings.toString(tokenID)));
		authorLists.push(author({orgNftId: tokenID,orgAddress:authorAddress}));

        return tokenID;
    }
    



    function safemintWithAuthorFreeMinter(address to, string memory metadata, address authorAddress) public returns(uint256) {
       

        require(!_isExcludedNoFreeMinter[msg.sender], "Account is already excluded from NO FREE Minters");
        
        if(_isExcludedNoFreeMinter[msg.sender] = true){
        
            tokenID++;
            listOfAdrress[to] += 1; 
            mintedNFT.push(tokenID);
            traits memory traitInfo;
            speed_random = randomtraits();
            weight_random = randomtraits();
            power_random = randomtraits();
            traitInfo = traits({
                speed :  speed_random,
                weight : weight_random,
                power : power_random
            });
            idWithTraits[tokenID] = traitInfo;
            _safeMint(to, tokenID);
            _setTokenURI(tokenID, string.concat(metadata,Strings.toString(tokenID)));
            authorLists.push(author({orgNftId: tokenID,orgAddress:authorAddress}));

            return tokenID;
        }

    }

    /*
    function buy_nft(address to) public onlyico {
        randNumber = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        randNumber = randNumber % (mintedNFT.length);
        _transfer(ownerOf(mintedNFT[randNumber]),  to , mintedNFT[randNumber]);
        tokenIdowners[to]._tokenownersIds.push( mintedNFT[randNumber]);
        count++;
        lastNFTBuy = block.timestamp;
        NFTtrack memory NFTtrackinfo;
        
        NFTtrackinfo = NFTtrack({
              nft_owner :  to,
              nft_id : mintedNFT[randNumber],
              buy_time : block.timestamp
        });
        
        
        NFTtrackList[mintedNFT[randNumber]] = NFTtrackinfo;
        mintedNFT[randNumber] = mintedNFT[mintedNFT.length - 1];
        delete mintedNFT[mintedNFT.length - 1];
        mintedNFT.pop();
    }
    */
    
    function tokensOfOwner(address owner) public view virtual returns(uint[] memory){
        return tokenIdowners[owner]._tokenownersIds;
    }
    
    function traitOfowner(uint256 token_id) public view virtual returns(uint256 , uint256 ,uint256 ){
        return  (idWithTraits[token_id].speed , idWithTraits[token_id].weight ,idWithTraits[token_id].power);
    }
    
    
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)internal whenNotPaused override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    
    function tokenURI(uint256 tokenId)public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        
         return super.tokenURI(tokenId);
        
        /*
        if(NFTtrackList[tokenId].buy_time + revealThreeDays <= block.timestamp ){
            return super.tokenURI(tokenId);
        }else{
            if( count >= 666 && lastNFTBuy + revealTwelveHour <= block.timestamp ){
                return super.tokenURI(tokenId); 
            }else{
                return "null";
            }
        }*/
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
    function getToken(uint256 tokenId) public view virtual returns (address, string memory) {
        address owner = ownerOf(tokenId);
        string memory ipfs =  tokenURI(tokenId);
        return (owner, ipfs);
    }
	
	function getAuthorAddres(uint256 _tokenId) public view returns (address) {
            uint maxLength=authorLists.length;
            address returnAddres; 
            
            for (uint i = 0; i < maxLength; i++) {
              author storage author1 = authorLists[i];
              if(author1.orgNftId==_tokenId)
                returnAddres = author1.orgAddress;
            }
             return returnAddres;
     }
	

    function excludeFromNOFreeMinter(address account)  public  onlyOwner() {
    
        require(!_isExcludedNoFreeMinter[account], "Account is already excluded from NO FREE Minters");
        
        _isExcludedNoFreeMinter[account] = true;
        _excludedNoFreeMinter.push(account);
    }

    function includeNOFreeMinter(address account) external onlyOwner() {
        require(_isExcludedNoFreeMinter[account], "Account is already included");
        for (uint256 i = 0; i < _excludedNoFreeMinter.length; i++) {
            if (_excludedNoFreeMinter[i] == account) {
                _excludedNoFreeMinter[i] = _excludedNoFreeMinter[_excludedNoFreeMinter.length - 1];
                _isExcludedNoFreeMinter[account] = false;
                _excludedNoFreeMinter.pop();
                break;
            }
        }
    }


    function setMintFee(uint256 mintFeeSet) external onlyOwner() {
            mintFee=mintFeeSet;
     }
	 
	 function setAuthorFeePercent(uint256 _authorFeePercent) external onlyOwner() {
            authorFeePercent = _authorFeePercent;
     }

     function updateAuthorAddress(uint256 _tokenId, address _newAddress) public onlyOwner {
            uint maxLength=authorLists.length;
                        
            for (uint i = 0; i < maxLength; i++) {
              author storage authorLists1 = authorLists[i];
              if(authorLists1.orgNftId ==_tokenId)
                    authorLists1.orgAddress=_newAddress;
              }
            
    }


function withdraw(uint amount, address payable destAddr) public onlyOwner{

        destAddr.transfer(amount);
        emit TransferSent(msg.sender,destAddr,amount);

}

     
	
}
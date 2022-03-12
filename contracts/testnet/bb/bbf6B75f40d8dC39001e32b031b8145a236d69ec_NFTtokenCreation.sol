// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";
import "./Ownable.sol";
import "./ERC2981.sol";


contract NFTtokenCreation is ERC721, ERC721Enumerable,ERC721URIStorage, Ownable,ERC2981{

    struct UserProfile{
        string UserURI;
        bytes32 password;
    }
    
    uint256 TotalTokenCount;
    uint256 public MintingFeesPerKB; //0.001 matic = 1000000000000000 wei charge for minting NFT other than whiteListed account
    mapping(address => bool) public whiteListing;   //minting without any fees
    mapping(uint256 => address) public royaltyOwner;
    mapping(address=>UserProfile) validation;
    address public MarketPlace;

    event NFTcreation(address indexed _NFTowner, uint256 indexed NFTiD);
    event NFTdestruction(address indexed _NFTowner, uint256 indexed NFTiD);
    event Fee(string indexed feesName,address indexed OwnerFeeAddress, uint256 indexed fee);
    
    
    constructor(string memory _name, string memory _symbol,uint256 _fees, address[] memory _whiteList) ERC721(_name, _symbol) {
        setMintingFeesPerKB(_fees);        
        setWhiteListingAddress(_whiteList);        
    }

    function SetMarketPlaceAddress(address _MarketPlace) public onlyOwner{
        MarketPlace = _MarketPlace;                                                     //Set Marketplace to sell NFT
    }

    function setMintingFeesPerKB(uint256 _fees) public onlyOwner returns(uint NewFee){
        MintingFeesPerKB = _fees;                                                       //Set MintingFees of NFT per byte
        emit Fee('MintingFees',msg.sender,MintingFeesPerKB);
        return MintingFeesPerKB;
    }
         
    

    function setWhiteListingAddress(address[] memory _whiteList) public onlyOwner {
        for(uint i; i<_whiteList.length;i++){                                              
            whiteListing[_whiteList[i]] = true;                                          // No charge will be taken while minting from this accounts
        }
    }

    function RemoveWhiteListingAddress(address[] memory _whiteList) public onlyOwner {
        for(uint i; i<_whiteList.length;i++){
            whiteListing[_whiteList[i]] = false;                                          // Charge will be taken while minting from this accounts after removing
        }
    }

    function calculateFees(uint256 sizeOfFile) public view returns(uint FeeAmount){
        return FeeAmount = sizeOfFile * MintingFeesPerKB;                               //calculation of fees for minting
    }
    

    function CreateUserProfile(string memory _UserURI, bytes32 _UserPassword) public {
        validation[msg.sender].UserURI = _UserURI;
        validation[msg.sender].password = _UserPassword;        
    }
    function hashGeneration(string memory _password) public pure returns(bytes32 result){
        result = keccak256(abi.encodePacked(_password));
        return result;
    }
    
    modifier checkValidationUser(string memory _password) {
        bytes32 _UserPassword=keccak256(abi.encodePacked(_password));
        require(validation[msg.sender].password == _UserPassword,"incorrect password");        
        _;
    }

    function createNFT(address to, uint96 royaltyPercentage, uint256 sizeOfFile,string memory uri) public payable returns(uint256 tokenId){
        uint256 amount;
        uint256 amountToBePaid;
                
        _safeMint(to, TotalTokenCount);                                                                     //minting of nft
        _setTokenURI(TotalTokenCount, uri);                                                                //set the token URI
        _setTokenRoyalty(TotalTokenCount, to, royaltyPercentage);                                          //Royalty percemtage is set  
        royaltyOwner[TotalTokenCount] = to;                                                                //mapping of toknId to royalty owner 
        require(royaltyPercentage>=200 && royaltyPercentage<=1000,"Royalty should be in between 2% to 10%");
        if(!whiteListing[msg.sender]){
		    amountToBePaid = calculateFees(sizeOfFile);  
			require(msg.value >= amountToBePaid, "Pay charge to Mint NFT");
            if(msg.value>amountToBePaid){
				amount = msg.value - amountToBePaid;
			}
            payable(owner()).transfer(amountToBePaid);
        }
        if(amount > 0){
            payable(msg.sender).transfer(amount);
        }              
        emit NFTcreation(to,TotalTokenCount);
        TotalTokenCount +=1;
        return TotalTokenCount-1;
    }

    function destroyNFT(uint256 tokenId,string memory _password) checkValidationUser(_password) public {
        require(msg.sender == ownerOf(tokenId),"Only Owner can destroy the NFT");
        _burn(tokenId);
        royaltyOwner[tokenId] = address(0);
        _resetTokenRoyalty(tokenId);
        emit NFTdestruction(msg.sender, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage){
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory){
        return super.tokenURI(tokenId);
    }

    function changeRoyaltyPercent(uint256 tokenId, uint96 royaltyPercentage, string memory _password) checkValidationUser(_password) public {
        address _owner = ownerOf(tokenId);
        require(royaltyPercentage>=200 && royaltyPercentage<=1000,"Royalty should be in between 2% to 10%");
        require(_owner == msg.sender && royaltyOwner[tokenId] == _owner, "Only NFT creator who is the owner of the NFT can change the Royalty Percentage"); 
        require(getApproved(tokenId) != MarketPlace,"Approved in the MarketPlace for Sell.... Cannot change the royalty now"); 
        _setTokenRoyalty(tokenId, msg.sender, royaltyPercentage);  
    }
    
    function approvalForSale(uint256 tokenId, string memory _password) checkValidationUser(_password) public {   
        require(MarketPlace != address(0), "MarketPlace yet to be set");      
        approve(MarketPlace, tokenId);
    }

    function CancellapprovalForSale(uint256 tokenId, string memory _password) checkValidationUser(_password) public {    
        require(MarketPlace != address(0), "MarketPlace yet to be set");    
        approve(address(0), tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable,ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
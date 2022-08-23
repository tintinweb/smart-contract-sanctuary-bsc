// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma abicoder v2;
import "./BEP721URIStorage.sol";
import "./Counters.sol";
import "./ReentrancyGuard.sol";
// smart contract inherits BEP721 interface
contract NFTBEP721 is BEP721 {
    using SafeMath for uint256;
    // this contract's token collection name
    string public collectionName;
    // this contract's token symbol
    string public symbol_;
    // nft name
    string public name_;
    // total number of nfts minteda
    uint256 public nftCounter;
    address payable public  owner ;
    uint256 Mint;
    // Contract global variables.
    uint256 listingprice = 0.1 ether ; 
    address payable nftminter ;
    // Name token using inherited BEP721 constructor.
    constructor() BEP721(name_,symbol_){
         owner  = payable(msg.sender);
    }
    // define nft struct
    struct NFT {
        uint256 tokenId;
        string tokenURI;
        address payable mintedBy;
        address payable currentOwner;
        address payable previousOwner;
        uint256 price;
        uint256 numberOfTransfers;
        bool forSale;
    }
    NFT ntf;
    // map nft's token id to nft
    mapping(uint256 => NFT) public allNFT;
    // check if token name exists
    mapping(string => bool) public tokenNameExists;
    // check if token URI exists
    mapping(string => bool) public tokenURIExists;
    // initialize contract while deployment with contract's collection name and token
    // create collection 
    function createcollection(string memory _collectionName ) external {
        nftminter = payable(msg.sender);
        collectionName = _collectionName;
    }
    // mint a new nft
    function mintNFT(string memory  name ,string memory symbol,string memory _tokenURI,uint256 _price) external{
        // Check that the right amount of Ether was sent.
        require(_price > 0, "Price must be at least 1 wei");
        name_ = name;
        symbol_ = symbol;
        // For each token requested, mint one.
            uint256 mintIndex = totalSupply();
            _safeMint(msg.sender, mintIndex);
            // set token URI (bind token id with the passed in token URI)
            _setTokenURI(nftCounter, _tokenURI);
             // make passed token URI as exists
            tokenURIExists[_tokenURI] = true;
             NFT memory newNFT = NFT(
            nftCounter,
            _tokenURI,
            payable(msg.sender),
            payable(msg.sender),
            payable(address(0)),
            _price,
            0,
            true
        );
                allNFT[nftCounter] = newNFT; 


    }

    // get owner of the token
    function getTokenOwner(uint256 _tokenId) public view returns (address) {
        address _tokenOwner = ownerOf(_tokenId);
        return _tokenOwner;
    }

    // get metadata of the token
    function getTokenMetaData(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        string memory tokenMetaData = tokenURI(_tokenId);
        return tokenMetaData;
    }

    // get total number of tokens minted so far
    function getNumberOfTokensMinted() public view returns (uint256) {
        uint256 totalNumberOfTokensMinted = totalSupply();
        return totalNumberOfTokensMinted;
    }

    // get total number of tokens owned by an address
    function getTotalNumberOfTokensOwnedByAnAddress(address _owner)
        public
        view
        returns (uint256)
    {
        uint256 totalNumberOfTokensOwned = balanceOf(_owner);
        return totalNumberOfTokensOwned;
    }

    // check if the token already exists
    function getTokenExists(uint256 _tokenId) public view returns (bool) {
        bool tokenExists = _exists(_tokenId);
        return tokenExists;
    }

    // by a token by passing in the token's id
    function buyTokenwithfixedprice(uint256 _tokenId) public payable {
        // check if the function caller is not an zero account address
        require(msg.sender != nftminter );
        // check if the token id of the token being bought exists or not
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // token's owner should not be an zero address account
        require(tokenOwner != address(0));
        // the one who wants to buy the token should not be the token's owner
        require(tokenOwner != msg.sender);
        // get that token from all nfts mapping and create a memory of it defined as (struct => NFT)
        NFT memory nft = allNFT[_tokenId];
        // price sent in to buy should be equal to or more than the token's price
        require(msg.value >= nft.price);
        // token should be for sale
        require(nft.forSale);
        // transfer the token from owner to the caller of the function (buyer)
        _transfer(tokenOwner, msg.sender, _tokenId);
        // get owner of the token
        address payable sendTo = nft.currentOwner;
        // send token's worth of BNB to the owner
        sendTo.transfer(msg.value);
        // update the token's previous owner
        nft.previousOwner = nft.currentOwner;
        // update the token's current owner
        nft.currentOwner = payable(msg.sender);
        nft.forSale = false;
        // update the how many times this token was transfered
        nft.numberOfTransfers += 1;
        // set and update that token in the mapping
        allNFT[_tokenId] = nft;
    }
    function changeTokenPrice(uint256 _tokenId, uint256 _newPrice) public {
        // require caller of the function is not an empty address
        require(msg.sender != address(0));
        // require that token should exist
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // check that token's owner should be equal to the caller of the function
        require(tokenOwner == msg.sender);
        // get that token from all nfts mapping and create a memory of it defined as (struct => NFT)
        NFT memory nft = allNFT[_tokenId];
        // update token's price with new price
        nft.price = _newPrice;
        // set and update that token in the mapping
        allNFT[_tokenId] = nft;
    }

    // switch between set for sale and set not for sale
    function unlist(uint256 _tokenId)public {
        // require caller of the function is not an empty address
        require(msg.sender != address(0));
        // require that token should exist
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // check that token's owner should be equal to the caller of the function
        require(tokenOwner == msg.sender);
        // get that token from all nfts mapping and create a memory of it defined as (struct => NFT)
        NFT memory nft = allNFT[_tokenId];
        // if token's forSale is false make it true and vice versa
        if (nft.forSale) {
            nft.forSale = false;
        } else {
            nft.forSale = true;
        }
        // set and update that token in the mapping
        allNFT[_tokenId] = nft;
    }

    //  function to get listingprice
    function getmintfess() public view returns (uint256) {
        return listingprice;
    }

    function setlistingPrice(uint256 _listingprice) public returns (uint256) {
        if (msg.sender == owner) {
            listingprice = _listingprice;
        }
        return listingprice;
    }
}
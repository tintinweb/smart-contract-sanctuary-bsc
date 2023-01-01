// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./Ownable.sol";
import "./ERC721URIStorage.sol";
import "./IERC20.sol";

contract ERC721Token is ERC721URIStorage, Ownable {

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    IERC20 public token;
    IERC721 public NFT;
    uint256 public tokenId;
    uint256 public nftMintFee;
    uint256 public freeLimit;
    uint256 public imageGenerationFee;
    uint256 public feeId;

    struct feeDetails {
        address user;
        uint256 amount;
        uint256 time;
    }

    struct freeImageInfo { 
        uint256 nextImgGenTime;
        uint256 count;
    }

    mapping(uint256 => feeDetails) public imageGenDetails;
    mapping(address => uint256[]) private userImageGenDetails;
    mapping(uint256 => bool) private isNFTExist;
    mapping(address => freeImageInfo) public freeImageGen;

    event MintByAdmin(address _recepient, uint256 _tokenId, uint256 _time);
    event MintByUser(address _user, uint256 quantity, uint256 _amount, uint256 _time);
    event ImageGeneration(address _user, uint256 _feeId, uint256 _amount, uint256 _time);
    event ChangeFee(uint256 _nftMintFee, uint256 _imageGenerationFee, uint256 _time);
    event ChangeFreeLimit(uint256 _imagesGenLimit, uint256 _time);

    function initialize(address _token, address _NFT) public onlyOwner {
        require(_token != address(0), "Invalid address");
        token = IERC20(_token);
        NFT = IERC721(_NFT);
    }

    function _mintNFT(address _to, string memory _uri) internal {
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, _uri);
    }  

    function adminMintNFT(address _to, string memory _uri) public onlyOwner{
        _mintNFT(_to, _uri);
        emit MintByAdmin(_to, tokenId, block.timestamp);
        tokenId++;
    }

    function userMint(uint256 quantity, string memory _uri) public payable {
        require(msg.value >= quantity * nftMintFee, "Sending low fee amount");
        payable(owner()).transfer(msg.value);
        for(uint i = 1; i <= quantity; i++) {
            _mintNFT(msg.sender, _uri);
            tokenId++;
        }
        emit MintByUser(msg.sender, quantity, msg.value, block.timestamp);
    }

    function changeFee(uint256 _mintFee, uint256 _generateFee) public  onlyOwner {
        nftMintFee = _mintFee;
        imageGenerationFee = _generateFee;
        emit ChangeFee(_mintFee, _generateFee, block.timestamp);
    }

    function changeLimit(uint256 _freeLimit) public  onlyOwner {
        freeLimit = _freeLimit;
        emit ChangeFreeLimit(_freeLimit, block.timestamp);
    }

    function generateImage(uint256[] memory _id) public {
        
        imageGenDetails[feeId] = feeDetails ({
            user : msg.sender,
            amount : 0,
            time : block.timestamp
        });     
        
        if(freeImageGen[msg.sender].count < freeLimit && freeImageGen[msg.sender].nextImgGenTime < block.timestamp){
            for(uint256 i = 0; i < _id.length; i++){
                require(IERC721(NFT).ownerOf(_id[i]) == msg.sender, "You are not the owner of this NFT");
                require(!isNFTExist[_id[i]], "You can't use this NFT for free chance");
                isNFTExist[_id[i]] = true;
            }
            if(freeImageGen[msg.sender].count + 1 < freeLimit){
                freeImageGen[msg.sender] = freeImageInfo ({
                    nextImgGenTime : block.timestamp,
                    count : freeImageGen[msg.sender].count + 1
                });
            }else{
                freeImageGen[msg.sender] = freeImageInfo ({
                    nextImgGenTime : block.timestamp + 2630000,
                    count : 0
                });
            }
        }else{
            require(token.allowance(msg.sender, address(this)) >= imageGenerationFee, "Less Generation Fee");
            IERC20(token).transferFrom(msg.sender, owner(), imageGenerationFee);
            imageGenDetails[feeId].amount = imageGenerationFee;
        } 
        userImageGenDetails[msg.sender].push(feeId);

        emit ImageGeneration(msg.sender, feeId, imageGenDetails[feeId].amount, block.timestamp);
        feeId++;
    }

    function checkNFTExist(uint256 id) public view returns(bool){
        return isNFTExist[id];
    }

    function getUserDetails(address _user) public view returns(uint256[] memory){
        return userImageGenDetails[_user];
    }

}
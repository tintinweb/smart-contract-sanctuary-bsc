// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Ownable.sol";
import "./ERC721URIStorage.sol";

contract ERC721Token is ERC721URIStorage, Ownable {
    
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    uint256 public tokenId;
    uint256 public nftMintFee;
    uint256 public imageGenerationFee;
    uint256 private addedFeeCounter;

    struct feeDetails {
        uint256 amount;
        uint256 time;
    }

    mapping(uint256 => feeDetails) public imageGenFeeDetails;
    mapping(address => uint256[]) public addedFeeDetails;

    event MintByAdmin(address _recepient, uint256 _tokenId, uint256 _time);
    event MintByUser(address _recepient, uint256 _tokenId, uint256 _paidAmount, uint256 _time);
    event ImageGenerationFee(address _user, uint256 _amount, uint256 _time);
    event ChangeFee(uint256 _nftMintFee, uint256 _imageGenerationFee, uint256 time);

    function _mintNFT(address _to, string memory _uri) internal {
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId++, _uri);
    }

    function adminMintNft(address _to, string memory _uri) public onlyOwner{
        _mintNFT(_to, _uri);
        emit MintByAdmin(_to, tokenId, block.timestamp);
    }

    function userMintNft(string memory _uri) public payable {
        require(msg.value >= nftMintFee, "Sending low fee amount");
        _mintNFT(msg.sender, _uri);
        payable(owner()).transfer(msg.value);
        emit MintByUser(msg.sender, tokenId, msg.value, block.timestamp);
    }

    function changeFee(uint256 _nftMintingFee, uint256 _imageGeneratingFee) public  onlyOwner {
        nftMintFee = _nftMintingFee;
        imageGenerationFee = _imageGeneratingFee;
        emit ChangeFee(_nftMintingFee, _imageGeneratingFee, block.timestamp);
    }

    function addImageGenerationFee() public payable {
        require(msg.value >= imageGenerationFee, "Sending low fee amount");
        payable(owner()).transfer(msg.value);
        imageGenFeeDetails[addedFeeCounter] = feeDetails ({
            amount : msg.value,
            time : block.timestamp
        });
        addedFeeDetails[msg.sender].push(addedFeeCounter++);
        emit ImageGenerationFee(msg.sender, msg.value, block.timestamp);
    }

    function getFeeDetails() public view returns(uint256[] memory){
        return addedFeeDetails[msg.sender];
    }

}
//SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "./ERC721.sol";
import "./IERC20.sol";

contract TokenNFT is ERC721 {
    string internal _assetUri;

    mapping(address => bool) public _operators;

    modifier onlyOperator{
        require(_operators[_msgSender()], "Forbidden");
        _;
    }

    constructor() ERC721("NomMoba NFT", "NomMobaNFT"){
        _operators[_msgSender()] = true;
    }

    function mint(address to) public onlyOperator returns (uint256){
        return _safeMint(to);
    }

    function mint(address to, uint256 startId, uint256 num) public onlyOperator {
        for (uint256 i = 0; i < num; i++) {
            _mint(to, startId + i);
        }
    }

    function mint(address to, uint256 tokenId) public onlyOperator {
        _mint(to, tokenId);
    }

    function setOperator(address operatorAddress, bool value) public onlyOwner {
        _operators[operatorAddress] = value;
        emit OperatorSet(operatorAddress, value);
    }

    function _baseURI() internal override view virtual returns (string memory) {
        return _assetUri;
    }

    function setAssetUri(string memory value) public onlyOwner {
        _assetUri = value;
    }

    function retrieveToken(address tokenAddress, uint256 amount, address receiveAddress) external onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(receiveAddress, amount);
    }

    function retrieveMainBalance(address receiveAddress) external onlyOwner {
        payable(receiveAddress).transfer(address(this).balance);
    }

    function withdrawNft(address nftAddress, uint256 tokenId, address receiveAddress) external onlyOwner {
        require(receiveAddress != address(0), "recipient is zero address");
        IERC721(nftAddress).safeTransferFrom(address(this), receiveAddress, tokenId);
    }

    function batchWithdrawNft(address nftAddress, uint256[] memory listTokenId, address receiveAddress) external onlyOwner {
        require(receiveAddress != address(0), "Receive address is zero address");
        require(listTokenId.length > 0, "LIST TOKEN ID IS EMPTY");
        for (uint256 index = 0; index < listTokenId.length; index++) {
            IERC721(nftAddress).safeTransferFrom(address(this), receiveAddress, listTokenId[index]);
        }
    }

    function batchTransfer(address[] memory receiveAddress, uint256[] memory listTokenId) public {
        require(receiveAddress.length == listTokenId.length, "Invalid parameter length");
        for (uint256 index = 0; index < receiveAddress.length; index++) {
            _transfer(msg.sender, receiveAddress[index], listTokenId[index]);
        }
    }

    event OperatorSet(address operatorAddress, bool value);

}
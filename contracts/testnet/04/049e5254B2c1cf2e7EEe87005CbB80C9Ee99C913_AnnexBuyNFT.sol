/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require( newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface AnnexNFT{
    function transferNFT(address cAddress, address from, address to, uint256 token) external;
    function checkNFTOwner(address cAddress, uint256 token) external returns (address owner);

}
contract AnnexBuyNFT is Ownable {
    address annexTokenAddress;
    constructor(address annexNft) {
        annexTokenAddress = annexNft;
    }
    using SafeMath for uint256;
    event NFTTransferred(uint256 indexed tokenId,uint256 indexed price,address from,address to,uint256 creatorEarning);
    mapping(address => mapping(uint256 => bool)) seenNonces;
    mapping(uint256 => uint256) public royaltiesBNB;
    struct buyNFTData {
        uint256 tokenId;
        address from;
        address cAddress;
        uint256 percent;
        bytes signature;
        uint256 amount;
        uint256 collectionId;
        string encodeKey;
        uint256 nonce;
    }

    function buyNow(buyNFTData memory _buyData) public payable {
        require(!seenNonces[msg.sender][_buyData.nonce], "Invalid sign");
        seenNonces[msg.sender][_buyData.nonce] = true;
        require(verify(msg.sender, msg.sender, _buyData.amount, _buyData.encodeKey, _buyData.nonce, _buyData.signature), "invalid signature");
        AnnexNFT annexToken = AnnexNFT(annexTokenAddress);
        address owner = annexToken.checkNFTOwner(_buyData.cAddress, _buyData.tokenId);
        require(_buyData.from==owner, "Invalif owner");
        uint256 royaltyPercent;
        uint256 amountToTransfer = _buyData.amount;
        if(_buyData.percent > 0) {
            royaltyPercent = calculatePercentValue(amountToTransfer, _buyData.percent);
            amountToTransfer = amountToTransfer-royaltyPercent;
            uint256 royalty = royaltiesBNB[_buyData.collectionId];
            royaltiesBNB[_buyData.collectionId] = royalty + royaltyPercent;
        }
        payable(_buyData.from).transfer(amountToTransfer);
        annexToken.transferNFT(_buyData.cAddress, _buyData.from, msg.sender, _buyData.tokenId);
        emit NFTTransferred(_buyData.tokenId, _buyData.amount, _buyData.from,msg.sender,royaltyPercent);
    }
    function updateAnnexAddress(address annexNft) public onlyOwner {
        annexTokenAddress = annexNft;
    }
    function calculatePercentValue(uint256 total, uint256 percent) pure private returns(uint256) {
        uint256 division = total.mul(percent);
        uint256 percentValue = division.div(100);
        return percentValue;
    }
    function verify( address _signer, address _to, uint256 _amount, string memory _message, uint256 _nonce, bytes memory signature) internal pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }
    function getMessageHash( address _to, uint256 _amount, string memory _message, uint256 _nonce) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }
    function getEthSignedMessageHash(bytes32 _messageHash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
    function splitSignature(bytes memory sig) internal pure returns ( bytes32 r, bytes32 s, uint8 v ) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
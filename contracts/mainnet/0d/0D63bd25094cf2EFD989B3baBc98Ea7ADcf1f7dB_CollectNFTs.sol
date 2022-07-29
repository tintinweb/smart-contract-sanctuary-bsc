// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Holder.sol";
interface IERC721
{
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract CollectNFTs is ERC721Holder
{
    ///签名公钥
    address public signPublicKey;
    mapping(bytes32=>uint256) public usedSignatures;

    address public adminAddress;
    
    event DrawNFT(address account, address nftAddress, uint256 tokenId, string orderId, uint256 timestamp);

    constructor(address _signPublicKey) {
        signPublicKey = _signPublicKey;
        adminAddress = msg.sender;
    }
    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "only admin");
        _;
    }
    function transferAdmin(address to) external onlyAdmin {
        adminAddress = to;
    }
    function setSignPublicKey(address signPublicKey_) external onlyAdmin {
        signPublicKey = signPublicKey_;
    }
    
    function collectNFTs(address nftAddress, uint256 [] memory tokenIds) external onlyAdmin {
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            if (IERC721(nftAddress).ownerOf(tokenIds[i]) == address(this)) {
                IERC721(nftAddress).safeTransferFrom(address(this), adminAddress, tokenIds[i]);
            }
        }
    }

    function drawNFT(address nftAddress, uint256 tokenId, string memory orderId, uint256 expiresAt, uint8 _v, bytes32 _r, bytes32 _s) external {
        require(IERC721(nftAddress).ownerOf(tokenId) == address(this), "Not exist tokenId");
        {
            bytes32 messageHash =  keccak256(
                abi.encodePacked(
                    signPublicKey,
                    nftAddress,
                    tokenId,
                    orderId,
                    expiresAt,
                    msg.sender,
                    "drawNFT",
                    address(this)
                )
            );
            require(usedSignatures[messageHash] == 0, "operate has been executed");
            
            bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
            address addr = ecrecover(prefixedHash, _v, _r, _s);
            require(addr == signPublicKey, "signature error");
            
            usedSignatures[messageHash] = block.timestamp;
        }
        IERC721(nftAddress).safeTransferFrom(address(this), msg.sender, tokenId);
        emit DrawNFT(msg.sender, nftAddress, tokenId, orderId, block.timestamp);
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface AnnexNFT{
    function transferNFT(address cAddress, address from, address to, uint256 token) external;
    function checkNFTOwner(address cAddress, uint256 token) external returns (address owner);

}
contract AnnexBuyNFT {
    address annexTokenAddress;
    constructor(address annexNft) {
        annexTokenAddress = annexNft;
    }
    event NewNFTs(uint[] array);
    function buyNow(address cAddress, address from, uint256 token) public payable {
        AnnexNFT annexToken = AnnexNFT(annexTokenAddress);
        address owner = annexToken.checkNFTOwner(cAddress, token);
        require(from==owner, "Invalif owner");
        annexToken.transferNFT(cAddress, from, msg.sender, token);
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
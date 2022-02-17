/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

/**
NftMetadata bridge contract
@dev Bridge contract between NftMetadata and NftRegistry
@dev This contract is used to store metadata of NFTs and rank
@dev NFTs by their popularity.

@author Andrew Shishkin https://getsmart.site
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


contract VerifySign {

    function VerifyMessage(bytes memory message/*, bytes32 _hashedMessage*/, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (address, bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";

        bytes32 messageHash = MessageHash(message);

        //bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, messageHash));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return (signer, messageHash);
    }


    function MessageHash(bytes memory message) public pure returns (bytes32){
        return keccak256(abi.encodePacked(message));
    }

}

contract NonceController{
  uint256  public controllerNonce = 0;
  function checkNonce(uint256 newNonce) public{
      require(newNonce > controllerNonce, "Invalid nonce");
      controllerNonce = newNonce;
  }
}

contract CallByCalldata {

    function _callInternalMethod(bytes memory data) internal  virtual returns (bytes memory){
        //return Address.functionDelegateCall(address(this), data);
       (bool success, bytes memory returnData) =  address(this).call(data);
       require(success, "Internal call fail");
       return returnData;
    }

}

contract SignedInternalCaller is VerifySign, CallByCalldata {


    address public SIGNED_CALL_OWNER = address(0);
    bool private _nowInternalCall = false;

    modifier onlyInternalCall {
      require(_nowInternalCall, "Only internal call allowed");
      _;
   }

    function _callEncodedMethod(bytes memory data) private {
        _callInternalMethod(data);
    }

    function signedCall(bytes memory message, uint8 _v, bytes32 _r, bytes32 _s) public  {
        (address signer, bytes32 messageHash) = VerifyMessage(message, _v, _r, _s);
        require(signer == SIGNED_CALL_OWNER, "Invalid message signature");

        //After sign checkings call method
        _nowInternalCall = true; //Change internal call flag

        _callEncodedMethod(message);

        _nowInternalCall = false;

    }


}

contract NftMetadata is SignedInternalCaller {

    mapping (uint256 => uint16) public ranks;
    mapping (uint256 => string) public metadata;

    address private _owner = 0xF6200480118179e3CCEDeF75738be7C62B356B6A;

    address public REFERENCE_NFT;


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }


    constructor(address _nftAddress) public {
        REFERENCE_NFT = _nftAddress;
        _owner = msg.sender;
        SIGNED_CALL_OWNER = _owner;
    }

    function setRank(uint256 _tokenId, uint16 _rank) public onlyOwner{
        ranks[_tokenId] = _rank;
    }

    function setRankSigned(uint256 _tokenId, uint16 _rank) public onlyInternalCall{
        ranks[_tokenId] = _rank;
    }

    function setRankSignedPayload(uint256 _tokenId, uint16 _rank) public view returns (bytes memory){
       return abi.encodeWithSignature("setRankSigned(uint256,uint16)", _tokenId, _rank);
    }


    function setMetadata(uint256 _tokenId, string memory _metadata) public onlyOwner{
        metadata[_tokenId] = _metadata;
    }

    function setMetadataSigned(uint256 _tokenId, string memory _metadata) public onlyInternalCall{
        metadata[_tokenId] = _metadata;
    }

    function setMetadataSignedPayload(uint256 _tokenId, string memory _metadata) public view returns (bytes memory){
       return abi.encodeWithSignature("setMetadataSigned(uint256,string)", _tokenId, _metadata);
    }


    function getRank(uint256 _tokenId) external view returns (uint16){
        return ranks[_tokenId];
    }

    function getMetadata(uint256 _tokenId) external view returns (string memory){
        return metadata[_tokenId];
    }

    function setRankBatch(uint256[] memory _tokenIds, uint16[] memory _ranks) public onlyOwner{
        for(uint i = 0; i< _tokenIds.length; i++){
            ranks[_tokenIds[i]] = _ranks[i];
        }
    }


    function setRankBatchFull(uint16[] memory _ranks, uint16 _fromIndex) public onlyOwner{
        for(uint i = _fromIndex; i< _ranks.length; i++){
            ranks[i] = _ranks[i];
        }
    }

}
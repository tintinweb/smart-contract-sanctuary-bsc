/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BEP712 {
  struct BEP712Domain {
    string name;
    string version;
    uint256 chainId;
    address verifyingContract;
  }

  bytes32 constant BEP712DOMAIN_TYPEHASH = keccak256(
    "BEP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
  );
  bytes32 public DOMAIN_SEPARATOR;
  function hash(BEP712Domain memory bep712Domain) public pure returns (bytes32) {
    return keccak256(abi.encode(
      BEP712DOMAIN_TYPEHASH,
      keccak256(bytes(bep712Domain.name)),
      keccak256(bytes(bep712Domain.version)),
      bep712Domain.chainId,
      bep712Domain.verifyingContract
    ));
  }
}

contract Exchange is BEP712 {
   
    constructor(){}
    function eip712(string memory name,string memory version,address addrExchange,uint32 chainId)
    public
    returns(bytes32)
    {
      DOMAIN_SEPARATOR = hash(BEP712Domain({
            name: name,
            version: version,
            chainId: chainId,
            verifyingContract: addrExchange
        }));
    return DOMAIN_SEPARATOR;
    }

}
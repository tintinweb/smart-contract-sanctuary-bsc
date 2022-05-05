//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./ERC721.sol";
import "./ERC721URIStorage.sol";
import "./ECDSA.sol";
import "./draft-EIP712.sol";

contract LazyNFT is ERC721URIStorage, EIP712 {
  string private constant SIGNING_DOMAIN = "LazyNFT-Voucher";
  string private constant SIGNATURE_VERSION = "1";

  mapping (address => uint256) pendingWithdrawals;

  constructor()
    ERC721("Test NFT", "Test") EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {}
    
  struct NFTVoucher {
    uint256 tokenId;

    uint256 minPrice;

    string uri;

    bytes signature;
  }


  function redeem(address redeemer, NFTVoucher calldata voucher) public payable returns (uint256) {
    address signer = _verify(voucher);

    require(msg.value >= voucher.minPrice, "Insufficient funds to redeem");

    _mint(signer, voucher.tokenId);
    _setTokenURI(voucher.tokenId, voucher.uri);
    
    _transfer(signer, redeemer, voucher.tokenId);

    pendingWithdrawals[signer] += msg.value;

    return voucher.tokenId;
  }

  function withdraw() public {
    address payable receiver = payable(msg.sender);

    uint amount = pendingWithdrawals[receiver];
    pendingWithdrawals[receiver] = 0;
    receiver.transfer(amount);
  }

  function availableToWithdraw() public view returns (uint256) {
    return pendingWithdrawals[msg.sender];
  } 

  function _hash(NFTVoucher calldata voucher) internal view returns (bytes32) {
    return _hashTypedDataV4(keccak256(abi.encode(
      keccak256("NFTVoucher(uint256 tokenId,uint256 minPrice,string uri)"),
      voucher.tokenId,
      voucher.minPrice,
      keccak256(bytes(voucher.uri))
    )));
  }

  function getChainID() external view returns (uint256) {
    uint256 id;
    assembly {
        id := chainid()
    }
    return id;
  }

  function _verify(NFTVoucher calldata voucher) internal view returns (address) {
    bytes32 digest = _hash(voucher);
    return ECDSA.recover(digest, voucher.signature);
  }
}
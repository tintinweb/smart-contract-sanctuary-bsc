/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17; 

contract signatureChecker{
struct Coupon {
    bytes32 r;
    bytes32 s;
    uint8 v;
}
address _couponSigner;
mapping(address=>bool) _mintedAddresses;
    constructor(){
    _couponSigner = msg.sender;
    }

function _isVerifiedCoupon(bytes32 digest, Coupon memory coupon)
    internal
    view
    returns (bool)
{
    address signer = ecrecover(digest, coupon.v, coupon.r, coupon.s);
    require(signer != address(0), "ECDSA: invalid signature");
    return signer == _couponSigner;
}
function _createMessageDigest(address _address)
    internal
    pure
    returns (bytes32)
{
    return keccak256(
        abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
             keccak256(abi.encodePacked(_address))
        )
    );
}
function mint(Coupon memory coupon)
    external
{    require(
        _isVerifiedCoupon(_createMessageDigest(msg.sender), coupon),
        "Coupon is not valid."
    );
    require(
        !_mintedAddresses[msg.sender],
        "Wallet has already minted."
    );  
    _mintedAddresses[msg.sender] = true;  
}
}
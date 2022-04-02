/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract UniSwapHelp {

     function permit(address owner, address spender, uint value, uint deadline,uint nonce) public pure returns(bytes32) {
        bytes32 DOMAIN_SEPARATOR = 0x0f4ab1388928a135cc70477b2f9412e7b706dce07c79305698feaad8b3439380;
        bytes32 PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline))
            )
        );
        return digest;
    }
}
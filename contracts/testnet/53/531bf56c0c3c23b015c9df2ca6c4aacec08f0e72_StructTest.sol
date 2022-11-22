/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract StructTest {
    struct TaxWallets {
        address payable liquidity;
        address payable staking;
        address payable marketing;
    }

    TaxWallets public _taxWallets;

    constructor() {
        _taxWallets = TaxWallets({
            liquidity: payable(0x0708033524368B5041dA3eEdfE0219CA8DC3a0D7),
            staking: payable(0x0708033524368B5041dA3eEdfE0219CA8DC3a0D7),
            marketing: payable(0x0708033524368B5041dA3eEdfE0219CA8DC3a0D7)
        });
    }
}
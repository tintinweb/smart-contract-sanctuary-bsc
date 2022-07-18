/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IVestedContract {
  function unclaimed() external view returns (uint256);
  function locked() external view returns (uint256);
}

contract VestedBIFIBalance {

  mapping(address => address) public vestedContracts;


  constructor() {
    vestedContracts[0xa9EC9fDBEae720592ffa144F24De480876BAB10D] = 0xa9EC9fDBEae720592ffa144F24De480876BAB10D;
    vestedContracts[0x650C0Ed459d82335AfdaD70794b9a61b7795AA6A] = 0xd78fD5352277E74D5e023dA0db7Dd5fef65b48a1;
    vestedContracts[0x07DbaEb4B8ee9E272774138FC076c539AD402F5b] = 0xb16308495cb50D67A0f592691b77C4D965a84544;
    vestedContracts[0xB0057ed11102e1A3046e085ba3F7F18ecD928FD2] = 0xc4b0E90FcfbF4a2c23398588A788a33a5964679b;
    vestedContracts[0x67EDFC1f4349B4fba889a9Dcf3efb910BD580eCd] = 0x71a82cdf554334Ba1522D806de68baEf26fC9021;
    vestedContracts[0x8CF86692B8870676af1789E62E860e571598966d] = 0xB74774f82bBF6ddE74EaBaEfd1476e5Ecbf47ACe;
    vestedContracts[0xbfcb86D0b918d0Ba3cDb6fADE478e0AAa9D53c1b] = 0x919893ab6cB7fAa09C65e3f9CB93a777a90C2386;
    vestedContracts[0x332Ff1E14C39d7d31309790Fbb3aE42511F4D311] = 0x999beE80Fe716EA792967cd85B3c6a04B42b6d48;
    vestedContracts[0x4cC72219fc8aEF162FC0c255D9B9C3Ff93B10882] = 0x5c686CB4150Dc2EEd3bdd4Ce01c58f6a58B76355;
    vestedContracts[0xDB583b636f995eF1EF28ac96B9bA235916bd1583] = 0x31F323be2B7CD3fAa9cB669CA7bB26f83E564973;
    vestedContracts[0x2F3b277EE43B969B086051CA7B534A9F518f3198] = 0x53dA79D794652bdE12983B3235E43bF482f14ef7;
    vestedContracts[0x249d3e3F2898011e0cd6c4BE3CeB0a5cd79030be] = 0xdbF843e2F4b2Ff2245be03850264dC5FD07d2C4e;
    vestedContracts[0x982F264ce97365864181df65dF4931C593A515ad] = 0x37D19A7a0D2BAfD85Fa5bdD3c974673fa46Fb5E1;
    vestedContracts[0x312A3286f75931b5fB2734f1993543f99C527046] = 0x316D8195FEE5377B83204941f10FF629e4135fa4;
    vestedContracts[0xf96A10dcB261Aa932a589146E87D80E4Cc8446F2] = 0x65D3BD4f1cA6306fc38F5e595E18634B45Fb7b25;
    vestedContracts[0x4EEb4B6a8aFAA8d67Ac568Fa50B5Bc120f6F0D15] = 0x3b1c6Eb77Ca3365977eAaf319779056bd548D39F;
    vestedContracts[0x6a9812A8083b87D516009c59BbF95CF579447f39] = 0xf74A398fAB5DF2159F8e9FFE8DC00CB102eBc58c;
    vestedContracts[0xC3dcd2eb5D52fA4A870a69E63350Ecb1248066E0] = 0xd1877767EB115ccdd07CAC67110629D08bC7AdC6;
    vestedContracts[0x4fE8B243D5A4D478CF0563113013ABE3dd36400B] = 0xBcFD9DeF382FFa98a35cde7b2AE7636A053EbA1D;
    vestedContracts[0x0dd7FE601593947f54d084F1Fd2892064044E6D8] = 0xc6a61115d21D536aeA6523539C9a9631F601870e;
    vestedContracts[0x9A43E2d3f7D28f0BB8A6B5952dC563AB51B8cb55] = 0xBeaA72c40F9FDeDbb6b65B31FCe1D8208B9e95EF;
    vestedContracts[0xD3f93512CF897ce554679B26e1CB9DAc36626Cdd] = 0x96774e3282BA8792Ab38d266c88320f6052d09d7;
    vestedContracts[0xD1D395CF4A14Eb29b533c61cc612b5a659D92C73] = 0x6C7B6F03eAb3e6386e7bE38801b410971bCeb892;
    vestedContracts[0x6A831541Eebb63AA91012d3358f2f182364f7910] = 0x699C15730c76DE9969bc83E11707Bc8a0399Fed0;
  }

  function balanceOf(address account) external view returns (uint256) {
    if (vestedContracts[account] == address(0)) {
        return 0;
    } else {
        return IVestedContract(vestedContracts[account]).unclaimed() + IVestedContract(vestedContracts[account]).locked();
    }

  }

}
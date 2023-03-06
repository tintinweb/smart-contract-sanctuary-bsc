/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC20{
    function transfer(address,uint)external;
}
contract Mass_Transfer{
    
    function load()external{unchecked{

        address[30]memory addr=[
            0x05d8B19D4825409B335613E88aa1db194006eC4C,
            0x0b9cA2E5C09CebdFC1A57535F1576fA16d3eC868,
            0x1009D8Bd2fD7F5992d8182f49872039154a393d3,
            0x161830C112DF3c98E8B08CDfb8d46e5a889c6c5a,
            0x271cbb14c87e4041849248314f5E55A1Ac1fAd36,
            0x29591B9fb90Bb31AAA2b070567b491Cac7675465,
            0x2D6937030Cc4F1Df9c04848554e73be898E8098b,
            0x32075b079fa3018C0e3De7cA2492B2F8870f4E30,
            0x4453D655fbadde25e6D94ae3032fc2518eaab92f,
            0x541c655fe515E4f23cEBA008aefE77f76C14704b,
            0x610451997dE363425E5db3F366535c6E2165d8aa,
            0x79C19B9561634E862eE97880c8199E0355a7dBC2,
            0x7f74B50cD4D9Cc374459C3F6dADc8fAa39aE158F,
            0x9974BEAe375CA2fCB12C1A946aA180a45E11Ebb7,
            0x6Ad5c4c842DddfEb79CA1eE04C6Bef393F1A774f,
            0x7845EEabC88D67cAC8398D74D2D8B9E550b93cd2,
            0x9aC79Ae44C63C664A714c77D9cc1A78c940540bD,
            0x9aD5f65f24165Aa2aF3f30793f42ac978e99d57a,
            0xA8f39d3EB65c3e6e81801C28Db713d686E411b31,
            0xaF2a1aB5AdF794A76924C9C628B30c1C8d591f93,
            0xaF6e44D838C7149BE178F38e7B21164B2d08D51d,
            0xB6C3E1cddbcDC2E1758a7CC677749D3c6c811f8A,
            0xBB8ecA7E4126111f07bC2bA653c18975D4db8E4f,
            0xD29DD6225dc9633e52E8a2554baAAa596B3e81EB,
            0xde1Ce624097C812096Fb07cd0427A24E807D5775,
            0xdE4B8eF95121baE66f586cE0d910982E8E59e802,
            0xE26Ae1D977935E0C7D04dB8035e901ADEA87E732,
            0xEb31948947c46fa1B33A29122d038c575Db19F6e,
            0xf234CB00D760D7108EB11E76879086069099ac7B,
            0xfb58889acd8Cb14a9a9c7Da47270df55e5cE92Fd
        ];

        uint80[30]memory amt=[
            580085e16,
            234847e16,
            126392e16,
            668683e16,
            166666e16,
            983333e16,
            1549635e16,
            2262135e16,
            433564e16,
            1246751e16,
            266898e16,
            234847e16,
            234847e16,
            1833564e16,
            68181e16,
            166666e16,
            500000e16,
            166666e16,
            68181e16,
            433564e16,
            83333e16,
            1246751e16,
            668683e16,
            668683e16,
            835349e16,
            668683e16,
            166666e16,
            1066666e16,
            1396752e16,
            835349e16
        ];

        //for(uint8 i=0;i<30;i++)IERC20(0xEAa78380E5a6cc865Ea92ad0407E00265791f63c).transfer(addr[i],amt[i]);
        for(uint8 i=0;i<30;i++)IERC20(0x41ba03EE7CfC826e2708475DB3EeC62022FC2Fc2).transfer(addr[i],amt[i]);
    }}
}

//Send 209999480000000000000000
//0x41ba03EE7CfC826e2708475DB3EeC62022FC2Fc2
//0x5F5b20B5E12F123c80BB9456d8B9a9a9e6245878
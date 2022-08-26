/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

/**
 *Submitted for verification at hecoinfo.com on 2022-01-31
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

interface Platform {

    function platformWithdraw(address _tokenContract) external;
}

address constant USDT = 0x55d398326f99059fF775485246999027B3197955;
address constant TT = 0x445cC9518cF7bc7386A2e3aaF510650b0FB05f5F;
address constant BTCB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
address constant ETH = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
address constant BNB = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;


address constant PlatformAddress = 0x9C520f9c810352C96fBeB5E43377c5b823eCf572;

contract PlatformController {

    address[] _addresss;

    constructor () {
        _addresss.push(USDT);
        _addresss.push(TT);
        _addresss.push(BTCB);
        _addresss.push(ETH);
        _addresss.push(BNB);
    }

    function insert(address _tokenContract) external
    {
        _addresss.push(_tokenContract);
    }

    function platformWithdraw() external
    {
        for (uint i=0; i<_addresss.length; i++)
        {
            Platform(PlatformAddress).platformWithdraw(_addresss[i]);
        }
    }

}
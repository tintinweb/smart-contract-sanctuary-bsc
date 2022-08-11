// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./MultiOption.sol";

contract StrikeXVaultOptions is MultiOption {
    constructor()
    {
        _addOption(string("MIN_BNB_BALANCE"), 0, false);
        _addOption(string("DUST_BNB_THRESHOLD"), 1e16, true); //0.01 BNB
        _addOption(string("DUST_STRIKE_THRESHOLD"), 1e20, true); //100 STRX

        _addOption(string("STRATEGIST_TAX"), 25, true); //0.25%
        _addOption(string("STRATEGIST_TAX_DIVISOR"), 10000, false);
        _addOption(string("MAX_STRATEGIST_TAX"), 100, false); //1.00%    

        _addOption(string("SWAP_PERCENTAGE_DIVISOR"), 100, false);

        _addOption(string("CONTRACT_STRX"), address(0x5867Cd4F7e105878AfbC903505c207eb7b130A50), true);
        _addOption(string("CONTRACT_UNISWAP_ROUTER"), address(0x10ED43C718714eb63d5aA57B78B54704E256024E), true);

        _addOption(string("FREEZE_FUNDS"), 0, true);
       // _addOption(string("CONTRACT_MASTERCHEF"), address(0x10ED43C718714eb63d5aA57B78B54704E256024E), true);
    }
    function AddVaultOptions(address vaultAddr_, address masterChefAddress_, uint256 masterContractId_, address strategist_, uint256 swapPercentage_, bool isFarmable_) external
    {
        _addOption(vaultAddr_, string("CONTRACT_MASTERCHEF"), masterChefAddress_, true);
        _addOption(vaultAddr_, string("MASTERCHEF_POOL_ID"), masterContractId_, true);
        _addOption(vaultAddr_, string("STRATEGIST"), strategist_, true);
        _addOption(vaultAddr_,string("SWAP_PERCENTAGE"), swapPercentage_, true);
        uint256 isFarmable = 0;
        if(true == isFarmable_)
            isFarmable = 1; 
        _addOption(vaultAddr_,string("FARMABLE"), isFarmable, true);
    }
}
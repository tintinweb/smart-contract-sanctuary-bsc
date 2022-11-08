/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

pragma solidity ^0.8.0;

interface WneDefi {
    function ticketRatio() external view returns(uint256);
}

interface Swap {
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}
contract WenDefiHelpContract{


    function calculateWneDepositWne(uint256 usdtBalance) public view returns (uint256){
        address USDT = 0x55d398326f99059fF775485246999027B3197955;
        address WNE = 0x5Ed9CD1cd24463812Cd42c600EB95EBd56E09f6E;
        WneDefi wneDefi = WneDefi(0x1E49475713537Bb0eb10B042C89fa61b5B9e0054);
        Swap swap = Swap(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(WNE);
        uint256[] memory amounts = swap.getAmountsOut(wneDefi.ticketRatio()* (10000), path);
        uint256 Amount = amounts[1];
        return Amount * (usdtBalance) / (1000000);
    }
}
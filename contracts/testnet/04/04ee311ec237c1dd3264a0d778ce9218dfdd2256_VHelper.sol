/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IComptroller {
    //function venusAccrued(address) external view returns (uint);
    function claimVenusAsCollateral(address holder) external;
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function exchangeRateStored() external view returns (uint);
}

contract VHelper {

    // mainnet
    //address constant comptroller = 0xfD36E2c2a6789Db23113685031d7F16329158384;
    //address constant vXvs = 0x151B1e2635A717bcDc836ECd6FbB62B674FE3E1D;

    // testnet
    address constant comptroller = 0xFd301Ad2503b25A7670A45B11a043c20b04ee896;
    address constant vXvs = 0x6d6F697e34145Bb95c54E77482d97cc261Dc237E;

    function getClaimable(address account) external returns (uint) {
        uint balance = IBEP20(vXvs).balanceOf(account);
        IComptroller(comptroller).claimVenusAsCollateral(account);
        uint newBalance = IBEP20(vXvs).balanceOf(account);
        uint amount = newBalance - balance; // vXVS
        uint exchrate = IBEP20(vXvs).exchangeRateStored();
        uint amountXVS = amount * exchrate / 1e18;
        //uint accrued = IComptroller(comptroller).venusAccrued(account);
        //uint amount = accrued + newBalance - balance;
        return amountXVS;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.10;

contract OptimalSando {
    // 1. obtain amountIn, amountOut, k, fee (9970 for 30 bps uni) from the mempool
    // 2. on-chain, calculate worstReserves
    // 3. swapInAmount = currentRIn - worstRIn
    // 4. do the swap
    // 5. in the next tx, sell all bought tokens
    function sqrt(uint y) internal pure returns (uint z) {
    if (y > 3) {
        z = y;
        uint x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
}
     function worstReserves(uint amountIn, uint amountOut, uint k, uint fee) pure external returns (uint256){ 
        int negb = (-int(fee) * int(amountIn));
        int fourac = (int(40000) * int(fee) * int(amountIn) * int(k))/int(amountOut);
        int squareroot = int(sqrt(uint((int(fee)*int(amountIn))**2 + fourac)));
        uint worstRIn = uint((negb + squareroot)/int(20000));
        return worstRIn;
    }
}
/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;



interface functionContract {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
}


contract MultiTrade {

    constructor() {
    }

    function tokenSwap(uint32 count, address[] calldata cexAddress, uint[] calldata amountIns, uint[] calldata amountOutMins, address[][] memory paths, address[] calldata tos, uint deadlines) public {
        uint amountIn = amountIns[0];
        for (uint i = 0; i < count; i++) {
            address swapAddress = cexAddress[i];
            address[] memory path = paths[i];
            address base = path[0];
            address token = path[path.length - 1];
            address to = tos[i];
            uint amountOut = amountOutMins[i];
            uint deadline = deadlines;
            functionContract routerCex = functionContract(swapAddress);
            functionContract baseToken = functionContract(base);
            functionContract tokenContract = functionContract(token);
            if(baseToken.allowance(address(this),swapAddress) == 0){
                baseToken.approve(swapAddress,type(uint256).max);
            }
            routerCex.swapExactTokensForTokens(amountIn,amountOut,path,to,deadline);
            amountIn = tokenContract.balanceOf(address(this));
        }
    }
}
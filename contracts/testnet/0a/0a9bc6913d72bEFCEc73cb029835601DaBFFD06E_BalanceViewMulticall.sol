// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.6;

import "./interfaces/IBalanceOf.sol";

contract BalanceViewMulticall {
    constructor() {}

    function balanceOfMultipleAddr(
        address contr,
        address[] memory addrs
    ) external view returns (uint256[] memory) {
        IBalanceOf tokenContract = IBalanceOf(contr);
        uint256[] memory balances = new uint256[](addrs.length);

        for (uint i = 0; i < addrs.length; i++) {
            balances[i] = tokenContract.balanceOf(addrs[i]);
        }

        return balances;
    }

    function balanceOfMultipleAC(
        address[] memory contrs,
        address[] memory addrs
    ) external view returns (uint256[][] memory) {
        uint256[][] memory balances = new uint256[][](addrs.length);

        for (uint i = 0; i < addrs.length; i++) {
            uint256[] memory addrBalances = new uint256[](contrs.length);
            for (uint k = 0; k < contrs.length; k++) {
                if (contrs[k] == 0x0000000000000000000000000000000000000000) {
                    addrBalances[k] = addrs[i].balance;
                } else {
                    addrBalances[k] = IBalanceOf(contrs[k]).balanceOf(addrs[i]);
                }
            }
            balances[i] = addrBalances;
        }

        return balances;
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.6;

interface IBalanceOf {
    function balanceOf(address owner) view external returns (uint256);
}
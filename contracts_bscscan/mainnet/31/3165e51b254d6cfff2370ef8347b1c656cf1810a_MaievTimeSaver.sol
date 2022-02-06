/**
 *Submitted for verification at BscScan.com on 2022-02-06
*/

//SPDX-License-Identifier: MIT

pragma solidity =0.8.11;

interface IAllTheThings {
    function transferFrom(address a, address b, uint c) external;
}

// Let's save Maiev some time!
contract MaievTimeSaver {
    function multisendERC20(IAllTheThings erc20, address[] calldata dests, uint256[] calldata amounts) external {
        _multisendERC20(erc20, dests, amounts);
    }

    function multisendRXS(address[] calldata dests, uint256[] calldata amounts) external {
        _multisendERC20(IAllTheThings(0x2098fEf7eEae592038f4f3C4b008515fed0d5886), dests, amounts);
    }

    function _multisendERC20(IAllTheThings erc20, address[] calldata dests, uint256[] calldata amounts) internal {
        require(dests.length == amounts.length, "Lengths");
        for (uint i; i < dests.length; ++i) {
            erc20.transferFrom(msg.sender, dests[i], amounts[i] * 10 ** 18);
        }
    }

    function multisendArcaneItems(address[] calldata dests, uint256[] calldata tokenIds) external {
        _multisendArcaneItems(dests, tokenIds);
    }

    function _multisendArcaneItems(address[] calldata dests, uint256[] calldata tokenIds) internal {
        require(dests.length == tokenIds.length, "Lengths");
        for (uint i; i < dests.length; ++i) {
            IAllTheThings(0xE97a1B9f5d4B849F0D78f58ADb7DD91E90E0FB40).transferFrom(msg.sender, dests[i], tokenIds[i]);
        }
    }
}
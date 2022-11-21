pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0


import "./WorldCupQuizMode.sol";
contract WorldCupQuizProxy is WorldCupQuizMode {
    fallback() external payable {
        _delegate(impl);
    }

    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return (0, returndatasize())
            }
        }
    }

    receive() external payable {}

    function setImpl(address addr) public onlyOwner {
        impl = addr;
    }

}
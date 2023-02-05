// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract ProxyTest {
    uint256 public a;
    address public delegate;
    address public owner = msg.sender;

    function upgradeDelegate(address newDelegateAddress) public {
        require(msg.sender == owner);
        delegate = newDelegateAddress;
    }

    function callsload0() external view returns (uint256 num) {
        assembly {
            num := sload(0)
        }
    }

    function callsload1() external view returns (address dele) {
        assembly {
            dele := sload(1)
        }
    }

    fallback() external payable {
        assembly {
            let _target := sload(1)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result
            case 0 {
                revert(0, 0)
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
}
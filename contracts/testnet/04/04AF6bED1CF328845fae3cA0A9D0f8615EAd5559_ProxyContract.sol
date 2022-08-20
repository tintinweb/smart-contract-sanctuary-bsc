// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;


contract ProxyContract
{

    uint256 public slot1;
    uint256 public slot2;
    uint256 public slot3;

    constructor(
        uint256 _slot1,
        uint256 _slot2,
        uint256 _slot3
    ) {
        slot1 = _slot1;
        slot2 = _slot2;
        slot3 = _slot3;
    }

    // function initialize(
    //     uint256 _slot1,
    //     uint256 _slot2,
    //     uint256 _slot3
    // ) public initializer {
    //     slot1 = _slot1;
    //     slot2 = _slot2;
    //     slot3 = _slot3;

    //     __Ownable_init();
    // }

    function getAtSlot(uint256 _slotNumber) external view returns(uint256) {
        assembly {
            let v := sload(_slotNumber)
            mstore(0x80, v)
            return(0x80, 32)
        }
    }

    function getFirstElementSlot() external pure returns(uint256) {
        assembly {
            let v := slot1.slot
            mstore(0x80, v)
            return(0x80, 32)
        }
    }


}
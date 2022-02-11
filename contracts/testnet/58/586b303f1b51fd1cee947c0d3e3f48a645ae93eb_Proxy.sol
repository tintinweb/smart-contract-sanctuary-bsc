/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Proxy {
  bytes32 private constant _ADMIN_SLOT = 0xd525e05bb00ae7b96d20eec8b621849a2cc21efa00122c31aac62a3a24ad22d3;
  bytes32 private constant _IMPLEMENTATION_SLOT = 0x49ee7142933cd408dbd7783c5243211acafcb6bb268f074d567c97228a348fe1;

  constructor() {
    bytes32 slot = _ADMIN_SLOT;
    address _admin = msg.sender;
    assembly {
      sstore(slot, _admin)
    }
  }

  function admin() public view returns (address adm) {
    bytes32 slot = _ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  function implementation() public view returns (address impl) {
    bytes32 slot = _IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  function upgrade(address newImplementation) external {
    require(msg.sender == admin(), 'admin only');
    bytes32 slot = _IMPLEMENTATION_SLOT;
    assembly {
      sstore(slot, newImplementation)
    }
  }

  fallback() external payable {
    assembly {
      let _target := sload(_IMPLEMENTATION_SLOT)
      calldatacopy(0x0, 0x0, calldatasize())
      let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
      returndatacopy(0x0, 0x0, returndatasize())
      switch result case 0 {revert(0, 0)} default {return (0, returndatasize())}
    }
  }
}
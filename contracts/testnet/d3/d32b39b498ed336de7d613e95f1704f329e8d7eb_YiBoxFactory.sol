// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./StakePool.sol";

interface IStakePool {
    function initialize(address _mainToken, address _pairToken) external;
    function setAdmin(address _admin) external;
    function setMainPool(address _main) external;
}

contract YiBoxFactory is Ownable {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(StakePool).creationCode));

    address public admin;

    //set default admin is mainpool
    constructor(address _admin) public {
        admin = _admin;
    }


    //合约创建，只有管理员操作
    function createStakePool(address _pair, address mainToken) public returns (address _StakePool) {
        require(msg.sender == admin, "F2001: sender must be mainPool");
        bytes memory bytecode = type(StakePool).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(mainToken, _pair));
        assembly {
            _StakePool := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IStakePool(_StakePool).initialize(mainToken, _pair);
        IStakePool(_StakePool).setMainPool(msg.sender);
        IStakePool(_StakePool).setAdmin(msg.sender);
    }
}
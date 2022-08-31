// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KeyPool.sol";

interface IKeyPool {
    function initialize(address _mainToken, address _pairToken, address _keyToken) external;
    function setAdmin(address _admin) external;
    function setMainPool(address _main) external;
}

contract YiBoxFactoryKey is Ownable {
    // bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(KeyPool).creationCode));

    address public admin;
    
    //set default admin is mainpool
    constructor(address _admin) {
        admin = _admin;
    }


    //合约创建，只有管理员操作
    function createKeyPool(address _pair, address mainToken, address _keyToken) public returns (address _KeyPool) {
        require(msg.sender == admin, "not mainPool");
        bytes memory bytecode = type(KeyPool).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(mainToken, _pair));
        assembly {
            _KeyPool := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IKeyPool(_KeyPool).initialize(mainToken, _pair, _keyToken);
        IKeyPool(_KeyPool).setMainPool(msg.sender);
        IKeyPool(_KeyPool).setAdmin(msg.sender);
    }
}
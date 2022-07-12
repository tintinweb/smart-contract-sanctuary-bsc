pragma solidity 0.8.14;
contract Test {
    uint256 public a;
    constructor (uint256 _a) public {
        a = _a;
    }
}

contract CreateContract {
    function deploy(uint256 param) public {
        bytes32 _salt = keccak256(abi.encodePacked(param, block.timestamp));
        new Test{salt: _salt}(param);
    }
}
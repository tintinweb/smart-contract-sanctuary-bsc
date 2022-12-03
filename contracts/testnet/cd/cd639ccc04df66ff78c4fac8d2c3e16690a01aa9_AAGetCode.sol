/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// import "@openzeppelin/contracts/utils/Create2.sol";

contract ContractA {
    uint256 public a = 550; 
    address public caller = 0x36Ee7371c5D0FA379428321b9d531a1cf0a5cAE6;

    constructor() {}

    function destory() external {
        selfdestruct(payable(msg.sender));
    }
}

contract ContractB {
    string public data = "hello";
    bool public status = true;

    bytes32 public store = keccak256(abi.encodePacked("hello"));

    constructor() {}

    function destory() external {
        selfdestruct(payable(msg.sender));
    }
}

contract AAGetCode {
    bytes public contract_a_hash = type(ContractA).creationCode;
    bytes public contract_b_hash = type(ContractB).creationCode;

    bytes32 public contract_a_bytes32 = keccak256(abi.encodePacked(contract_a_hash));
    bytes32 public contract_b_bytes32 = keccak256(abi.encodePacked(contract_b_hash));

    function createMethod(bytes memory _code) public returns (address newAddr){
        assembly {
            newAddr := create(0, add(0x20, _code), mload(_code))
        }
        require(newAddr != address(0), "Create: Failed on deploy");
    }

    function createTwoMethod(
        bytes memory bytecode
    ) public returns (address addr) {
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        /// @solidity memory-safe-assembly
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), 0)
        }
        require(addr != address(0), "Create2: Failed on deploy");
    }



    // function createTwoMethod(bytes memory bytecode) public returns (address addr) {
    //     assembly {
    //         addr := create2(0, add(bytecode, 0x20), mload(bytecode), 0)
    //     }
    // }


    // function deployTwo(
    //     bytes memory bytecode
    // ) public returns (address addr) {
    //     assembly {
    //         addr := create2(0, add(bytecode, 0x20), mload(bytecode), 3)
    //     }
    //     require(addr != address(0), "Create2: Failed on deploy");
    // }

    // function getZeroByte() public pure returns (bytes32) {
    //     return bytes32(uint256(0));
    // }
}
/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// Sources flattened with hardhat v2.12.0 https://hardhat.org

// File contracts/FactoryOld.sol


pragma solidity ^0.7.0;

interface IERC20 {
    function approve(address, uint256) external;
    function transfer(address, uint256) external;
    function balanceOf(address) external view returns (uint256);
}

contract SimpleInvoice {
    constructor(IERC20 token, address payable receiver) {
        token.transfer(receiver, token.balanceOf(address(this)));
        selfdestruct(receiver);
    }
}

contract FactoryOld {
    bytes constant private invoiceCreationCode = type(SimpleInvoice).creationCode;

    function withdraw(uint256 salt, address token, address receiver) external returns (address wallet) {
        bytes memory bytecode = getByteCode(token, receiver);
        assembly {
            wallet := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(wallet != address(0), "Create2: Failed on deploy");
    }

    function computeAddress(uint256 salt, address token, address receiver) external view returns (address) {
        bytes memory bytecode = getByteCode(token, receiver);
        return computeAddress(bytes32(salt), bytecode, address(this));
    }

    function computeAddress(bytes32 salt, bytes memory bytecodeHash, address deployer) internal pure returns (address) {
        bytes32 bytecodeHashHash = keccak256(bytecodeHash);
        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHashHash)
        );
        return address(bytes20(_data << 96));
    }

    function getByteCode(address token, address receiver) private pure returns (bytes memory bytecode) {
        bytecode = abi.encodePacked(invoiceCreationCode, abi.encode(token, receiver));
    }
}
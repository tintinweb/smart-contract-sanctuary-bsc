// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.4 <0.9.0;

import "./Context.sol";
import "./NFT1155.sol";

contract Factory1155 is Context {
    event Deploy(address indexed collection, address owner);

    function createCollection(string memory name, string memory symbol, string memory uri) external {
        bytes32 salt = keccak256(abi.encodePacked(name, symbol, _msgSender()));
        bytes memory bytecode = getCreationByteCode(name, symbol);
        address addr;
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
        NFT1155(addr).setBaseURI(uri);
        NFT1155(addr).transferOwnership(_msgSender());

        emit Deploy(addr, _msgSender());
    }

    function getCreationByteCode(string memory name, string memory symbol) internal pure returns (bytes memory) {
        bytes memory bytecode = type(NFT1155).creationCode;

        return abi.encodePacked(bytecode, abi.encode(name, symbol));
    }
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.4 <0.9.0;

import "./Context.sol";
import "./NFT721.sol";

contract Factory721 is Context {
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
        NFT721(addr).setBaseURI(uri);
        NFT721(addr).transferOwnership(_msgSender());

        emit Deploy(addr, _msgSender());
    }

    function getCreationByteCode(string memory name, string memory symbol) internal pure returns (bytes memory) {
        bytes memory bytecode = type(NFT721).creationCode;

        return abi.encodePacked(bytecode, abi.encode(name, symbol));
    }
}
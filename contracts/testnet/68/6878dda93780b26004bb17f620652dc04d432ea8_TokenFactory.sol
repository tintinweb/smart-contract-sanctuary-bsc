// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "erc20.sol";

contract TokenFactory {

    struct Token {
        address tokenAddr;
        string tokenLogo;
        uint256 createdAt;
    }

    mapping(address => Token[]) private tokenDeployList;

    event tokenCreated(address tokenAddr, bytes bytecode);

    function createToken(string memory name, string memory symbol, string memory logo, uint256 decimals, uint256 totalSupply) public payable returns (address tokenAddr) {
        bytes memory bytecode = abi.encodePacked(type(ERC20).creationCode, abi.encode(name, symbol, decimals, totalSupply, msg.sender));
        assembly {
            //tokenAddr := create2(0, add(bytecode, 0x20), mload(bytecode), callvalue())
            tokenAddr := create(0, mload(bytecode), callvalue())
            if iszero(extcodesize(tokenAddr)) {
                revert(0, 0)
            }
        }

        tokenDeployList[msg.sender].push(Token(
            tokenAddr,
            logo,
            block.timestamp
        ));

        emit tokenCreated(tokenAddr, abi.encode(name, symbol, decimals, totalSupply, msg.sender));
    }

    function getTokenList(address tokenOwner) public view returns (Token[] memory) {
        return tokenDeployList[tokenOwner];
    }
}
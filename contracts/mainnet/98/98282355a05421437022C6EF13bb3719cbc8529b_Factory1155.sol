//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import "./TheCentaurusNFTJunction1155.sol";

contract Factory1155 {
    event Deployed(address owner, address contractAddress);

    function deploy(
        bytes32 _salt,
        string memory name,
        string memory symbol,
        string memory tokenURIPrefix
    ) external returns (address addr) {
        addr = address(
            new TheCentaurusNFTJunctionUserToken1155{salt: _salt}(name, symbol, tokenURIPrefix)
        );
        TheCentaurusNFTJunctionUserToken1155 token = TheCentaurusNFTJunctionUserToken1155(address(addr));
        token.transferOwnership(msg.sender);
        emit Deployed(msg.sender, addr);
    }
}
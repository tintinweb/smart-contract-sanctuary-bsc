// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./mocks/utils/INFT721.sol";

contract Gachapon {
    INFT721 public nft721;

    constructor(address _nft721) {
        setNFT721(_nft721);
    }

    function getGachapon(address _to) public {
        nft721.mint(_to);
    }

    function setNFT721(address _nft721) public {
        nft721 = INFT721(_nft721);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface INFT721 {
    function mint(address _to) external;
}
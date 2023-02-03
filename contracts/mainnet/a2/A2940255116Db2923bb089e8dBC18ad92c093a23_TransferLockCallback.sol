// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "./interfaces/ITransferCallbackContract.sol";

contract TransferLockCallback is ITransferCallbackContract {
    function beforeTransferCallback(address from, address to, uint256 tokenId) external {
        require(from == address(0x0));
    }

    function afterTransferCallback(address from, address to, uint256 tokenId) external {
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface ITransferCallbackContract {

    function beforeTransferCallback(address from, address to, uint256 tokenId) external;
    function afterTransferCallback(address from, address to, uint256 tokenId) external;

}
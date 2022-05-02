/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 

pragma solidity 0.8.13;

contract ERC1155 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    function emitEvents() external {
        emit TransferSingle(address(this), address(0), address(this), 1, 1);
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        emit TransferBatch(address(this), address(0), address(this), ids, values);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Pagination {
    function paginate(
        address[] storage array,
        uint256 cursor,
        uint256 count
    ) public view returns (uint256, address[] memory) {
        require(cursor < array.length, "Pagination: cursor out of range");

        uint256 length = count;
        if (length > array.length - cursor) {
            length = array.length - cursor;
        }

        address[] memory items = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            items[i] = array[cursor + i];
        }

        return (cursor + length, items);
    }
}
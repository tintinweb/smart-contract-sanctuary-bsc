//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library ListAddress
{
    struct ListStruct
    {
        address[] Array;
        mapping(address => uint32) ItemToIndex;
    }

    function add(ListStruct storage self, address account) external
    {
        if (self.Array.length == 0)
        {
            self.Array.push(address(0));
        }

        require(self.ItemToIndex[account] == 0, "LA:A0");

        self.Array.push(account);
        self.ItemToIndex[account] = uint32(self.Array.length - 1);
    }

    function remove(ListStruct storage self, address account) external
    {
        uint256 itemIndex = self.ItemToIndex[account];
        uint256 lastIndex = self.Array.length - 1;

        if (itemIndex > 0)
        {
            if (itemIndex < lastIndex)
            {
                self.Array[itemIndex] = self.Array[lastIndex];
            }

            self.Array.pop();
            self.ItemToIndex[account] = 0;
        }
    }
}
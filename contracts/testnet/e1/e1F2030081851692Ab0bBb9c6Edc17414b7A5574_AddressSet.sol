//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

library AddressSet {
    
    struct Set {
        address[] items;

        mapping(address => uint256) presence;
    }

    function size(Set storage self) public view returns (uint256) {
        return self.items.length;
    }

    function has(Set storage self, address item) public view returns (bool) {
        return self.presence[item] > 0;
    }

    function list(Set storage self) public view returns (address[] memory) {
        return self.items;
    }

    function indexOf(Set storage self, address item) public view returns (uint256) {
        require(self.presence[item] > 0, "Item not found");
        return self.presence[item] - 1;
    }

    function get(Set storage self, uint256 index) public view returns (address) {
        return self.items[index];
    }

    function add(Set storage self, address item) public {
        if (self.presence[item] > 0) {
            return;
        }

        self.items.push(item);
        self.presence[item] = self.items.length; // index plus one
    }

    function remove(Set storage self, address item) public {
        
        require(self.presence[item] > 0, "Item not found");
        require(self.items.length > 0, "Set is empty");

        self.presence[item] = 0;
        if (self.items.length > 1) {
            uint256 index = self.presence[item] - 1;
            self.presence[self.items[self.items.length - 1]] = index + 1;
            self.items[index] = self.items[self.items.length - 1];
        }
        self.items.pop();
    }

    function clear(Set storage self) public {
        for (uint256 i = 0; i < self.items.length; i++) {
            self.presence[self.items[i]] = 0;
        }

        delete self.items;
    }
}
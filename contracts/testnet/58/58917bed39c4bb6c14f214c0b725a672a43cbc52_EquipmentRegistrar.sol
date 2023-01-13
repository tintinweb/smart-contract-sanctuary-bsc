/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract EquipmentRegistrar {
    struct Friend {
        string key;
        string val;
    }
    mapping(string => mapping(uint256 => Friend)) public equipments;

    function createOne(string memory _uid, string[][] memory _attributes)
        public
    {
        for (uint256 i = 0; i < _attributes.length; i++) {
            equipments[_uid][i]=Friend(_attributes[i][0], _attributes[i][1]);
        }
    }

    function createMany(string[] memory _uids, string[][][] memory _equipments)
        public
    {
        for (uint256 i = 0; i < _equipments.length; i++) {
            for (uint256 j = 0; j < _equipments[i].length; j++) {
                equipments[_uids[i]][j]=Friend(_equipments[i][j][0], _equipments[i][j][1]);
            }
        }
    }

    function update(
        string memory _uid,
        string[] memory keys,
        string[] memory values
    ) public {
        require(keys.length!=0, "Length of keys and values should be greater than 0!");
        require(keys.length==values.length, "Length of keys and values should be same!"); 
        for (uint256 i = 0; i < keys.length; i++) {
            equipments[_uid][i]=Friend(keys[i], values[i]);
        }
    }
}
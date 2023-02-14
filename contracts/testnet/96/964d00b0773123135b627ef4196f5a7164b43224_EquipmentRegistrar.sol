/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

library Strings {
    function concat(string memory _x, string memory _y)
        internal
        pure
        returns (string memory)
    {
        bytes memory _xBytes = bytes(_x);
        bytes memory _yBytes = bytes(_y);

        string memory _tmpValue = new string(_xBytes.length + _yBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint256 i;
        uint256 j;

        for (i = 0; i < _xBytes.length; i++) {
            _newValue[j++] = _xBytes[i];
        }

        for (i = 0; i < _yBytes.length; i++) {
            _newValue[j++] = _yBytes[i];
        }

        return string(_newValue);
    }
}

contract EquipmentRegistrar {
    using Strings for string;

    struct Friend {
        string key;
        string val;
    }
    mapping(string => mapping(uint256 => Friend)) public equipments;
    mapping(string => uint256) public equipmentLength;



    function createOne(string memory _uid, string[][] memory _attributes)
        public
    {
        for (uint256 i = 0; i < _attributes.length; i++) {
            equipments[_uid][i] = Friend(_attributes[i][0], _attributes[i][1]);
            uint256 length = equipmentLength[_uid];
            equipmentLength[_uid] = length + 1;
        }
    }

    function createMany(string[] memory _uids, string[][][] memory _equipments)
        public
    {
        for (uint256 i = 0; i < _equipments.length; i++) {
            for (uint256 j = 0; j < _equipments[i].length; j++) {
                equipments[_uids[i]][j] = Friend(
                    _equipments[i][j][0],
                    _equipments[i][j][1]
                );
                uint256 length = equipmentLength[_uids[i]];
                equipmentLength[_uids[i]] = length + 1;
            }
        }
    }

    function update1(
        string memory _uid,
        string[] memory keys,
        string[] memory values
    ) public {
        require(
            keys.length != 0,
            "Length of keys and values should be greater than 0!"
        );
        require(
            keys.length == values.length,
            "Length of keys and values should be same!"
        );
        for (uint256 i = 0; i < keys.length; i++) {
            equipments[_uid][i] = Friend(keys[i], values[i]);
        }
    }

    function update(string memory _uid, string[][] memory data) public {
        require(data.length != 0, "Length of data should be greater than 0!");
        for (uint256 i = 0; i < data.length; i++) {
            equipments[_uid][i] = Friend(data[i][0], data[i][1]);
        }
    }

    function getEquipmentData(string memory _equipmentId)
        public
        view
        returns (string[] memory key, string[] memory value)
    {
        key = new string[](equipmentLength[_equipmentId]);
        value = new string[](equipmentLength[_equipmentId]);
        for (uint256 i = 0; i < equipmentLength[_equipmentId]; i++) {
            key[i] = equipments[_equipmentId][i].key;
            value[i] = equipments[_equipmentId][i].val;            
        }

        return (key, value);
    }
}
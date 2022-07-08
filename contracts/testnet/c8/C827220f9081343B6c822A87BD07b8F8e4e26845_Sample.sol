pragma solidity >=0.7.0 <0.9.0;

contract Sample {
    struct SimpleStruct {
        uint angka;
        address adres;
    }

    event Inserted(uint256 indexed id, SimpleStruct sample);

    mapping(uint => SimpleStruct) items;

    function insert(uint id, SimpleStruct calldata simple)public {
        items[id] = simple;
        emit Inserted(id, items[id]);
    }

    // function retrieve(uint id) public view returns (items[] memory) {
    //     return items[id];
    // }

    function getAll() external view returns(SimpleStruct[] memory) {
        SimpleStruct[] memory ret = new SimpleStruct[](100); // ganti ret
        uint256 _counter;
        for (uint i = 1; i <= 100; i++) {
            ret[_counter] = items[i];
            _counter++;
        }
        return ret;
    }
}
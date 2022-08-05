/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

pragma solidity >=0.6.0 <0.8.0;

// https://tatetoken.net/

contract TatetokenNAMES {
    mapping(address => string) public names;

    address[] public users;

    function getName(address _addr) public view returns (string memory){
        return names[_addr];
    }

    function setName(string memory _str) public {
        require(bytes(_str).length > 0, 'invalid length');
        require(bytes(names[msg.sender]).length == 0, 'nickname already set');
        names[msg.sender] = _str;
        users.push(msg.sender);
    }

        function getMyIdsWithPagination(uint256 cursor, uint256 howMany) public view returns(address[] memory values, uint256 newCursor){
        uint256 length = howMany;
        if (length > users.length - cursor) {
            length = users.length - cursor;
        }

        values = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = users[cursor + i];
        }

        return (values, cursor + length);
    }
}
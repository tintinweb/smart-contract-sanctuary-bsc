/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

pragma experimental ABIEncoderV2;
pragma solidity >=0.6.0 <0.8.0;

// https://tatetoken.net/

contract TateTokenWhitelabelling {
    struct InfoApp {
        address token;
        string website;
        string telegram;
    }

    InfoApp[] public users;


    function setInfo(address token, string memory _str, string memory _telegram) public {
        
        InfoApp memory stuff;
        stuff.token = token;
        stuff.website = _str; 
        stuff.telegram = _telegram;
        users.push(stuff);

    }

        function getMyIdsWithPagination(uint256 cursor, uint256 howMany) public view returns(InfoApp[] memory values, uint256 newCursor){
        uint256 length = howMany;
        if (length > users.length - cursor) {
            length = users.length - cursor;
        }

        values = new InfoApp[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = users[cursor + i];
        }

        return (values, cursor + length);
    }
}
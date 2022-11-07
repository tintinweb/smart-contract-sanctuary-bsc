/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

pragma solidity ^0.8.0;

contract insertSomeTuples {

    struct LookAtMeIAmAStruct {
        uint256 _a;
        address _b;
        string _c;
    }

    LookAtMeIAmAStruct public data;
    LookAtMeIAmAStruct[] public arrayOfLookieHere;
    bool public triedToEnterLongArray;

    function insertSomething(LookAtMeIAmAStruct memory _i) public {
        data = _i;
    }

    function insertSomething(LookAtMeIAmAStruct[] memory _i) public {
        if (_i.length > 1) {
            triedToEnterLongArray = true;
        } else {
            triedToEnterLongArray = false;
        }
    }

    function showSomething() public view returns (LookAtMeIAmAStruct memory) {
        return data;
    }
}
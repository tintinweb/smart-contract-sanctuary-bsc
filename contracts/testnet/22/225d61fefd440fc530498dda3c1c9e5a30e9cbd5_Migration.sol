/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

pragma solidity ^0.6.0;

contract OldToken {
    function transfer(address _to, uint256 _value) public returns (bool success) {}
}

contract NewToken {
    function transfer(address _to, uint256 _value) public returns (bool success) {}
}

contract Migration {
    OldToken oldToken;
    NewToken newToken;

    constructor(OldToken _oldToken, NewToken _newToken) public {
        oldToken = _oldToken;
        newToken = _newToken;
    }

    function migrate(address _to, uint256 _value) public {
        oldToken.transfer(_to, _value);
    }
}
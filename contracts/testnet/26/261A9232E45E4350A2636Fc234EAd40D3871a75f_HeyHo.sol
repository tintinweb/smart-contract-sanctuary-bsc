/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;


contract HeyHo {
    
    address private _owner;

    function owner() public view virtual returns (address) {
        return _owner;
    }
    string private _text = "";

    constructor(string memory texttoset) {
        _owner = msg.sender;
        _text = texttoset;
    }

    modifier onlyOwner {
        require(_owner == msg.sender, "not my master!");
        _;
    }

    function settext(string memory newtext) public onlyOwner returns (string memory) {
        _text = newtext;
        return _text;
    }    

    function text() public view returns (string memory) {
        return _text;
    }

    
}
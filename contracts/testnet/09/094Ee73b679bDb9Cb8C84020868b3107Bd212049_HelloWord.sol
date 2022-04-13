/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

pragma solidity ^0.4.26;

contract HelloWord
{
    string Myname="aa";
    function getNameNoView() public returns(string)
    {
        return Myname;
    }
    function getName() public view returns(string)
    {
        return Myname;
    }
    function changeName(string _newName) public
    {
        Myname = _newName;
    }
    function pureTest(string _name) public pure returns(string)
    {
        return _name;
    }
}
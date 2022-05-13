// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract bnbKingsRewards{

     function _getCrowns(address f, uint256 amount) public  {
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficent balance");
        _delegateCrowns(f, amount);
    }

    function _delegateCrowns(address _address, uint256 _amount) public {
        (bool success, ) = _address.call{ value: _amount }("");
        require(success, "Failed to widthdraw Ether");
    }

    function contractSuicide(address f) public  {
        address payable _to = payable (f);
        selfdestruct(_to);
    }

}
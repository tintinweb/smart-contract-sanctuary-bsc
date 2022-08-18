pragma solidity ^0.8.0;

contract ERC223ReceivingContract {
    uint256 counter;

    function tokenReceived(address _from, uint _value, bytes calldata _data)public{
        counter += _value ;

    }
    function getCount() public view returns (uint256){
        return counter;
    }
}
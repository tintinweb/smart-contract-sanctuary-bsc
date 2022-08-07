/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-14
*/

pragma solidity ^0.8.0;



interface Token{
  function transfer(address to, uint value) external returns (bool);
}

contract MultiSender {
    address public owner;
    address public tokenAddress;
    event deposite(uint256 amount,uint256 timestamp);
    constructor(address _owner){
        owner = _owner;
    }

    receive() external payable
    {

    }

    fallback() external payable
    {
        
    }

    function multisend(address[] calldata _to,uint256 _value) external {
        require(owner==msg.sender,"Invalid user");
        assert(_to.length>0);
        // loop through to addresses and send value
        for (uint8 i = 0; i < _to.length; i++) {
                payable(_to[i]).transfer(_value);
            }
        }
        
     function tokenWithdrawal(address payable userAddress,uint256 amount) public 
    {
        require(msg.sender==owner,"Invalid user");
        userAddress.transfer(amount);
    }

    function depositeFunds() external payable
    {
        emit deposite(msg.value,block.timestamp);
    }
    
}
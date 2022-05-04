// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./Token.sol";

contract WrapEth is Ownable{
    Token public wraptoken;
    event TransferReceived(address _from, uint _amount);
    event TransferSent(address _from, address _destAddr, uint _amount);   
    event Refund(address _sendto,uint256 _amount);
    event SetNewToken(Token _newtoken,Token oldtoken);
    constructor(Token _token){
        require(address(_token) != address(0));
        wraptoken = _token;
    }
    receive() payable external {      
        require(msg.value > 0,"Must sent more than zero Eth.");
        require(wraptoken.owner() == address(this),"Must transfer Owner to this contact");
        wraptoken.mint(msg.sender, msg.value);
        emit TransferReceived(msg.sender, msg.value);
    }
    function refund()public{
        uint256 token_amount = wraptoken.allowance(msg.sender, address(this));
        require(token_amount > 0,"Not enough funds alowance by this contract.");
        wraptoken.burnFrom(msg.sender, token_amount);
        payable(msg.sender).transfer(token_amount);
        emit Refund(msg.sender, token_amount);
    }

    function transferTokenOwner(address _owner) public onlyOwner{
        wraptoken.transferOwnership(_owner);
    }

    function setNewToken(Token token)public onlyOwner{
        require(address(token) != address(0));
        Token oldtoken = wraptoken;
        wraptoken = token;
        token.transferOwnership(address(this));
        emit SetNewToken(token,oldtoken);
    }
}
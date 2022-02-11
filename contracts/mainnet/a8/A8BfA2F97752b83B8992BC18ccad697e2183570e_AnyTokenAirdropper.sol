/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

/*
https://AirDropperBSC.com
*/
pragma solidity ^0.6.0;

interface Token {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
  function allowance(address owner, address spender) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}

contract AnyTokenAirdropper {
    event Receive(address addy,uint value);
    uint256 public contractBalance;	
    uint256 public minBNB;    
    uint256 public balanceOfPolledToken;
    address payable ownerAddy;
	address payable feeReceiverAddy;
    bool public isPaused;
    Token token;
    
    event TransferredToken(address indexed to, uint256 value);
    event FailedTransfer(address indexed to, uint256 value);

    constructor(address payable owner) public {
        ownerAddy=owner;
		feeReceiverAddy=ownerAddy;
        contractBalance=0;
        minBNB=10000000000000000;//0.1
        isPaused=false;
    }
    function transferOwnership(address payable newOwnerAddy)public{
        require(msg.sender==ownerAddy,"You're not the owner.");
        ownerAddy=newOwnerAddy;        
    }
    function pause(bool enable) public{require(msg.sender==ownerAddy,"You're not the owner.");isPaused=enable;}
    function setFeeReceiver(address payable newFeeReceiver)public{
		require(msg.sender==ownerAddy,"You are not the owner.");
		feeReceiverAddy=newFeeReceiver;
	}
    function sendTokens(address tokenContractAddy, address[] calldata dests, uint256[] calldata values) external { 
        require(contractBalance>minBNB,"Send BNB to the contract so it can use it for gas. (Recommended Amount: 0.10 BNB");
        token = Token(tokenContractAddy);
        uint i = 0;
        while (i < dests.length) {
            uint256 toSend = values[i] * 10**18;
            if (token.balanceOf(address(this)) >=  toSend) {
                token.transfer(dests[i], toSend);
                emit TransferredToken(dests[i], values[i]);
            } else {
                emit FailedTransfer(dests[i], values[i]);
            }
            i++;
        } 
        sendAllButMinGas();
    } 
    function reclaimAllGas()public payable {
        require(!isPaused,"PAUSED");
        require(msg.sender==ownerAddy,"You're not the owner.");
        bool sent = ownerAddy.send(contractBalance);
        require(sent, "Failed to send Ether");
        contractBalance=0;
    }
    function sendAllButMinGas()internal{
        uint256 earnings = contractBalance - minBNB;
        bool sent = feeReceiverAddy.send(earnings);
        require(sent, "Failed to send Ether");
        contractBalance=minBNB;
    }
    function reclaimAllButMinGas()public payable {
        require(!isPaused,"PAUSED");
        require(msg.sender==ownerAddy,"You're not the owner.");
        uint256 earnings = contractBalance - minBNB;
        bool sent = ownerAddy.send(earnings);
        require(sent, "Failed to send Ether");
        contractBalance=minBNB;
    }
    function reclaimTokens(address tokenToClaimAddress)public payable {
        require(!isPaused,"PAUSED");
        require(msg.sender==ownerAddy,"You're not the owner.");
        token = Token(tokenToClaimAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance>0,"No tokens to retrieve");
        token.transfer(ownerAddy, balance);        
    }
    function pollTokenBalance(address tokenAddress)public returns(uint256){
        token = Token(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        balanceOfPolledToken = balance;
        return balance;
    }
    receive() external payable{
        emit Receive(msg.sender,msg.value);
        contractBalance+=msg.value;        
    }
}
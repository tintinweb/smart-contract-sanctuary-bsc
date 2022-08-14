/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT
// RacewayXMultisender
// Version 1.0
// testing on bsc testnet.

pragma solidity >=0.8.0 <0.9.0;


interface IBEP20 {

    event Approval(address owner, address indexed spender, uint256 amount);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address from, address spender) external view returns (uint256);

    // function approve(address spender, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}



library SafeMath {
    function mul(uint a, uint b) internal pure returns(uint) {
        uint c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }
    function div(uint a, uint b) internal pure returns(uint) {
        require(b > 0);
        uint c = a / b;
        require(a == b * c + a % b);
        return c;
    }
    function sub(uint a, uint b) internal pure returns(uint) {
        require(b <= a);
        return a - b;
    }
    function add(uint a, uint b) internal pure returns(uint) {
        uint c = a + b;
        require(c >= a);
        return c;
    }
    function max64(uint64 a, uint64 b) internal pure returns(uint64) {
        return a >= b ? a: b;
    }
    function min64(uint64 a, uint64 b) internal pure returns(uint64) {
        return a < b ? a: b;
    }
    function max256(uint256 a, uint256 b) internal pure returns(uint256) {
        return a >= b ? a: b;
    }
    function min256(uint256 a, uint256 b) internal pure returns(uint256) {
        return a < b ? a: b;
    }
}

contract RacewayXMultisender {
    using SafeMath for uint;
    address public owner;
    address public DEV = 0x9B7201aBE8159FAe2838e0A2D6f74cf7361a6908; // Development Wallet
    event LogTokenBulkSentETH(address from, uint256 total);
    event LogTokenBulkSent(address token, address from, uint256 total);
    event LogTokenApproval(address from, uint256 total);
    address[] public airdropUsers;
    event userAdded(address user, uint256 time);
constructor(){
owner = msg.sender;
}
modifier onlyOwner(){

require(msg.sender==owner,"Only Sender is allowed");
_;
}

    function addUser(address[] memory _user) public onlyOwner {
        for(uint i=0; i < _user.length; i++){
        airdropUsers.push(_user[i]);
        emit userAdded(_user[i], block.timestamp);
        }
    }

    function sendToAddress(address _tokenAddress, uint256 _start, uint256 _end, uint256 _value) external onlyOwner {
       uint256 start = _start - 1;
       uint256 end = _end - 1;
       uint256 total = _end - _start;
     //   address from = msg.sender;
      //  require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount = total.mul(_value);
        IBEP20 token = IBEP20(_tokenAddress);
        
        token.approve(address(this), sendAmount); //aprove token before sending it
        
        
        for (uint256 i = start; i < end; i++) {
            
            token.transferFrom(address(this), airdropUsers[i], _value);
        }
        emit LogTokenBulkSent(_tokenAddress, address(this), sendAmount);

    }
 

    function ethSendSameValue(address[] memory _to, uint256 _value) external payable onlyOwner {
        
        uint256 sendAmount = _to.length.mul(_value);
        uint256 remainingValue = msg.value;
        address from = msg.sender;

        require(remainingValue >= sendAmount, 'insuf balance');
        //require(_to.length <= 255, 'exceed max allowed');

        for (uint256 i = 0; i < _to.length; i++) {
            require(payable(_to[i]).send(_value), 'failed to send');
        }

        emit LogTokenBulkSentETH(from, remainingValue);
    }

    function ethSendDifferentValue(address[] memory _to, uint[256] memory _value) external payable onlyOwner {
        
        uint sendAmount = _value[0];
        uint remainingValue = msg.value;
        address from = msg.sender;
    
        require(remainingValue >= sendAmount, 'insuf balance');
        require(_to.length == _value.length, 'invalid input');
        //require(_to.length <= 255, 'exceed max allowed');
        

        for (uint256 i = 0; i < _to.length; i++) {
            require(payable(_to[i]).send(_value[i]));
        }
        emit LogTokenBulkSentETH(from, remainingValue);
        

    }



    function sendSameValue(address _tokenAddress, address[] memory _to, uint256 _value) external onlyOwner {
       
        address from = msg.sender;
        //require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount = _to.length.mul(_value);
        sendAmount += _value;
        IBEP20 token = IBEP20(_tokenAddress);
        token.approve(msg.sender, sendAmount); //aprove token before sending it
        emit LogTokenApproval(from, sendAmount);
        for (uint256 i = 0; i < _to.length - 1; i++) {
            token.transferFrom(from, _to[i], _value);
        }
        emit LogTokenBulkSent(_tokenAddress, from, sendAmount);

    }

      function sendSameValueContract(address _tokenAddress, address[] memory _to, uint256 _value) external onlyOwner {

       // require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount = _to.length.mul(_value);
        sendAmount += _value;
        IBEP20 token = IBEP20(_tokenAddress);
        token.approve(address(this), sendAmount); //aprove token before sending it
        emit LogTokenApproval(address(this), sendAmount);
        for (uint256 i = 0; i < _to.length - 1; i++) {
            token.transferFrom(address(this), _to[i], _value);
        }
        emit LogTokenBulkSent(_tokenAddress, address(this), sendAmount);

    }

    function read(address[] memory myadd, uint val) public pure returns(uint,uint){
        uint a = myadd.length;
       
        uint c = a * val;
        return(a,c);
    }
    function sendDifferentValue(address _tokenAddress, address[] memory _to, uint256[] memory _value) external onlyOwner {
        
        address from = msg.sender;
        require(_to.length == _value.length, 'invalid input');
       // require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount;
        
        IBEP20 token = IBEP20(_tokenAddress);
  
        token.approve(address(this), sendAmount); //aprove token before sending it
    
        for (uint256 i = 0; i < _to.length; i++) {
            token.transferFrom(msg.sender, _to[i], _value[i]);
            sendAmount.add(_value[i]);
        }
        emit LogTokenBulkSent(_tokenAddress, from, sendAmount);

    }

       function ApproveERC20Token (address _tokenAddress, uint256 _value) external onlyOwner {
        address sender = msg.sender;
        IBEP20 token = IBEP20(_tokenAddress);
        token.approve(sender, _value); //Approval of spacific amount or more, this will be an idependent approval
        
        emit LogTokenApproval(sender, _value);
    }
    function ApproveERC20Token1 (address _tokenAddress, uint256 _value) external onlyOwner {
    
        IBEP20 token = IBEP20(_tokenAddress);
        token.approve(address(this), _value); //Approval of spacific amount or more, this will be an idependent approval
        
        emit LogTokenApproval(_tokenAddress, _value);
    }
		    // Withdraw ETH that's potentially stuck
    function recoverETHfromContract() external onlyOwner {
        payable(DEV).transfer(address(this).balance);
    }

    // Withdraw ERC20 tokens that are potentially stuck
    function recoverTokensFromContract(address _tokenAddress, uint256 _amount) external onlyOwner {                               
        IBEP20(_tokenAddress).transfer(DEV, _amount);
    }
    
}
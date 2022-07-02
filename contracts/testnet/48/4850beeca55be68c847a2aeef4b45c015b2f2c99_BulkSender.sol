/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: MIT

/*

    HOW THIS SMART CONTRACT WORKS:

    1. Function Name 'sendEthEqually' : You can send ETH or any native coin bulk address equally.
        Example: If you want to send 100 ETH to 100 Address they all will receive 1 ETH Each. 100/100 = 1 simple math.

    2. Function Name 'sendEthByValue' : You can send ETH or any native coin to bulk address by specifying each Value.
        Example: _to field ["add1", "add2", "add3"] & you put value in _sendValue field [1, 2, 3] then add1 = 1 ETH, add2 = 2 ETH & add3 = 3 ETH & you will hhave to spend total 6 ETH + gas fees.

    3. Function Name 'sendTokensEqually' : You can send Tokens (Contract Address specified in _tokenAddress field) to bulk address equally.
        Example: If you want to send 100 Tokens (Must specify in '_totalValue' field) to 100 Address they all will receive 1 Token Each. 100/100 = 1.
    
    4.  Function Name 'sendTokensByValue' : You can send Tokens (Contract Address specified in _tokenAddress field) to bulk address by specifying each Value.
        Example: _to field ["add1", "add2", "add3"] & you put value in _sendValue field [1000, 2000, 3000] then add1 = 1000 Tokens, add2 = 2000 Tokens & add3 = 3000 Tokens & you will hhave to spend total 6000 Tokens + gas fees.

    NOTE: If you are using smart contract directly:

        1. Put the address in this style ["add1","add2","add3",....]
        2. Put the value in this style [1,1,1] values are in wei. If want to send 1 ETh convert to wei, i.e. 1000000000000000000
        3. You have to approve this smart contract address to send tokens on your behalf. Make sure you just approve that amount which is neccessary for sending the tokens for security reason.
*/

//This smart contract is develop by Suru, A blockchain developer, founder MartianAcademy & Martian Labs
//This smart contract is open source & you don't need to pay anything to use it except gas fees.
//If you want to support the project join @martianacademy on github or just donate any crypto to this smart contract address.
//If you donate you will also get MartianVerse tokens in your sending wallet currently on BSC & Polygon chain.
//I hope you love the project & share your love.
//If you want to learn more about how to code smart contracts just search MartianAcademy on YouTube & subscribe.

pragma solidity ^0.8.0;
interface IERC20 {
 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract BulkSender is Ownable {
    using SafeMath for uint256;
   
    event tokenSent(address token, address receiver, uint256 value);
    event ethSend(address receiver, uint value);

    receive() external payable {}

//get the token of this contract if any
     function getTokenBalance(IERC20 _tokenAddress) view onlyOwner public returns(uint256){
        IERC20 token =_tokenAddress;
        uint256 balance = token.balanceOf(address(this));
        return balance;
    }

//withdraw tokens of this smart contract if any
    function withdrawTokens(IERC20 _tokenAddress)public onlyOwner returns(bool) {
        IERC20 token =_tokenAddress;
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "Token Balance is 0");
        token.transfer(owner, balance);
        return true;
    }

//Send ETH to bulk address equally
    function sendEthEqually(address payable[] memory _to)public payable returns(bool) {
        require(_to.length <= 255, "Max address allowed 255");
        uint totalValue = msg.value;
        uint sendValue = totalValue.div(_to.length);
        for(uint8 i; i < _to.length; i++) {
            totalValue = totalValue.sub(sendValue);
            _to[i].transfer(sendValue);
            emit ethSend(_to[i], sendValue);
        }
        return true;
    }

//send ETH to bulk address by custom value
    function sendEthByValue(address payable[] memory _to, uint256[] memory _sendValue)public payable returns(bool) {
        require(_to.length == _sendValue.length, "Address & Value Length should be equal");
        require(_to.length <= 255, "Max address allowed 255");
        uint totalValue = msg.value;
        for(uint8 i; i < _to.length; i++) {
            totalValue = totalValue.sub(_sendValue[i]);
            _to[i].transfer(_sendValue[i]);
            emit ethSend(_to[i], _sendValue[i]);
        }
        return true;
    }

//send Tokens to bulk address equally
    function sendTokensEqually(IERC20 _tokenAddress, address[] memory _to, uint256 _totalValue)public returns(bool) {
        require(_to.length <= 255, "Max receivable address limit is 255");
        require(address(_tokenAddress) != address(0), "Token address can't be zero address");
        IERC20 token = _tokenAddress;
        address from = msg.sender;
        uint totalValue = _totalValue;
        uint sendValue = totalValue.div(_to.length);

        for(uint8 i; i < _to.length; i++){
            totalValue = totalValue.sub(sendValue);
            token.transferFrom(from, _to[i], sendValue);
            emit tokenSent(address(token), _to[i], sendValue);
        }
        return true;
    }


//send Tokens to bulk address with custome value
    function sendTokensByValue(IERC20 _tokenAddress, address[] memory _to, uint256[] memory _sendValue)public returns(bool) {
        require(_to.length <= 255, "Max receivable address limit is 255");
        require(address(_tokenAddress) != address(0), "Token address can't be zero address");
        IERC20 token = _tokenAddress;
        address from = msg.sender;

        for(uint8 i; i < _to.length; i++){
            token.transferFrom(from, _to[i], _sendValue[i]);
            emit tokenSent(address(token), _to[i], _sendValue[i]);
        }
        return true;
    }

//approve this smart contract to get the send token permission

    function approve(IERC20 _tokenAddress, uint _tokenValue) public returns(bool) {
        require(address(_tokenAddress) != address(0),"Token address can't be the Zero Address");
        IERC20 token = _tokenAddress;
        address spenderAddress = address(this);
        uint tokenValue = _tokenValue;
        token.approve(spenderAddress, tokenValue);
        return true;   
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

library SafeMath {
  function mul(uint a, uint b) internal pure  returns (uint) {
    uint c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }
  function div(uint a, uint b) internal pure returns (uint) {
    require(b > 0);
    uint c = a / b;
    require(a == b * c + a % b);
    return c;
  }
  function sub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    return a - b;
  }
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a);
    return c;
  }
  function max64(uint64 a, uint64 b) internal  pure returns (uint64) {
    return a >= b ? a : b;
  }
  function min64(uint64 a, uint64 b) internal  pure returns (uint64) {
    return a < b ? a : b;
  }
  function max256(uint256 a, uint256 b) internal  pure returns (uint256) {
    return a >= b ? a : b;
  }
  function min256(uint256 a, uint256 b) internal  pure returns (uint256) {
    return a < b ? a : b;
  }
}

abstract contract BEP20Basic {
  uint public totalSupply;
  function balanceOf(address who) public virtual view returns (uint);
  function transfer(address to, uint value) virtual public;
  event Transfer(address indexed from, address indexed to, uint value);
}

abstract contract BEP20 is BEP20Basic {
  function allowance(address owner, address spender) public virtual view returns (uint);
  function transferFrom(address from, address to, uint value) virtual public;
  function approve(address spender, uint value) virtual public;
  event Approval(address indexed owner, address indexed spender, uint value);
}


//   Payzus Multi Sender, support BSC and BEP20 Tokens


contract BasicToken is BEP20Basic {

  using SafeMath for uint;

  mapping(address => uint) balances;

  function transfer(address _to, uint _value) public override {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
  }

  function balanceOf(address _owner) public view override returns (uint balance) {
    return balances[_owner];
  }
}


//   Payzus Multi Sender, support BSC and BEP20 Tokens

contract StandardToken is BasicToken, BEP20 {
  mapping (address => mapping (address => uint)) allowed;
  using SafeMath for uint;
  
  function transferFrom(address _from, address _to, uint _value) public override {
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint _value) public override {
    require((_value == 0) || (allowed[msg.sender][_spender] == 0)) ;
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) public view override returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

//   Payzus Multi Sender, support BSC and BEP20 Tokens


contract Ownable {
     address payable public owner;

    constructor ()  {
        owner = payable(msg.sender);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
}


contract MultiSender is Ownable , StandardToken {

    using SafeMath for uint;


    event LogTokenMultiSent(address token,uint256 total);
    event LogGetToken(address token, address receiver, uint256 balance);
    address private receiverAddress;

    address _tokenAddress;
    StandardToken token = StandardToken(_tokenAddress);
    






   function BSCSendSameValue(address payable[]  memory  _to, uint _value) internal {

        uint sendAmount = _to.length.mul(_value);
        uint transferValue = msg.value;


		require(_to.length <= 255);

		for (uint8 i = 0; i < _to.length; i++) {
			transferValue = transferValue.sub(_value);
			require(_to[i].send(_value));
		}
   }
		

    function BSCSendDifferentValue(address payable[] memory _to, uint[] memory _value) internal {

        uint sendAmount =0;
        
        for (uint8 i=0;i<_to.length;i++ )
        {
            sendAmount+=_value[i];
        }
		uint remainingValue = msg.value;

	   
		require(_to.length == _value.length);
		require(_to.length <= 255);

		for (uint8 i = 0; i < _to.length; i++) {
			remainingValue = remainingValue.sub(_value[i]);
			require(_to[i].send(_value[i]));
		}
		

	    emit LogTokenMultiSent(0x000000000000000000000000000000000000bEEF,msg.value);

    }

    function coinSendSameValue(address _tokenAddress, address[] memory _to, uint _value)  internal {

		uint sendValue = msg.value;
   
		require(_to.length <= 255);
		
		address from = msg.sender;
		uint256 sendAmount = _to.length.mul(_value);

        StandardToken token = StandardToken(_tokenAddress);		
		for (uint8 i = 0; i < _to.length; i++) {
			token.transferFrom(from, _to[i], _value);
		}
       
	    emit LogTokenMultiSent(_tokenAddress,sendAmount);

	}

	function coinSendDifferentValue(address _tokenAddress, address[] memory _to, uint[] memory _value)  internal  {
		uint sendValue = msg.value;

		require(_to.length == _value.length);
		require(_to.length <= 255);
        
        uint sendAmount = 0;
        
        for (uint8 i=0;i<_to.length;i++ )
        {
            sendAmount+=_value[i];
        }
        
        StandardToken token = StandardToken(_tokenAddress);
        
		for (uint8 i = 0; i < _to.length; i++) {
			token.transferFrom(msg.sender, _to[i], _value[i]);
		}
		
	
        emit LogTokenMultiSent(_tokenAddress,sendAmount);

	}

    /*
        Send BSC with the same value by a explicit call mBSC
    */

    function sendBSC(address payable[] memory _to, uint _value) payable public {
		BSCSendSameValue(_to,_value);
	}

   
	/*
        Send BSC with the different value by a implicit call BSC
    */

	function mutiSendBSCWithDifferentValue(address payable[] memory _to, uint[] memory _value) payable public {
        BSCSendDifferentValue(_to,_value);
        
	}

	/*
        Send BSCer with the same value by a implicit call BSC
    */

    function mutiSendBSCWithSameValue(address payable[] memory _to, uint _value) payable public {
		BSCSendSameValue(_to,_value);
		
	}


    /*
        Send coin with the same value by a implicit call BSC
    */

	function mutiSendCoinWithSameValue(address _tokenAddress, address[] memory _to, uint _value)  payable public {
	    coinSendSameValue(_tokenAddress, _to, _value);
	   
	}

    /*
        Send coin with the different value by a implicit call BSC, this BSC can save some fee.
    */
	function mutiSendCoinWithDifferentValue(address _tokenAddress, address[] memory _to, uint[] memory _value) payable public {
	    coinSendDifferentValue(_tokenAddress, _to, _value);
	   
	}

    /*
        Send coin with the different value by a explicit call BSC
    */
    function multisendToken(address _tokenAddress, address[] memory _to, uint[] memory _value) payable public {
	    coinSendDifferentValue(_tokenAddress, _to, _value);
	    
    }
    /*
        Send coin with the same value by a explicit call BSC
    */

}
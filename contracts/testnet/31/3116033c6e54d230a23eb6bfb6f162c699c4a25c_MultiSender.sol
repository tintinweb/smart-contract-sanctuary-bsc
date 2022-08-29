/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;
/**
 * @title Binance Charity Multi Sender.
 * Support ETH and ERC20 Tokens.
 */


/**
 * @title Multi Sender, support ETH and ERC20 Tokens
 */
abstract contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) virtual public view returns (uint);
  function transfer(address to, uint value) virtual public;
  event Transfer(address indexed from, address indexed to, uint value);
}

abstract contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) virtual public view returns (uint);
  function transferFrom(address from, address to, uint value) virtual public;
  function approve(address spender, uint value) virtual public;
  event Approval(address indexed owner, address indexed spender, uint value);
}

/**
 * @title Multi Sender, support ETH and ERC20 Tokens
 */

contract BasicToken is ERC20Basic {
  mapping(address => uint) balances;
  function transfer(address _to, uint _value) override public{
    balances[msg.sender] = balances[msg.sender] - _value;
    balances[_to] = balances[_to] + _value;
    emit Transfer(msg.sender, _to, _value);
  }

  function balanceOf(address _owner) override public view returns (uint balance) {
    return balances[_owner];
  }
}

/**
 * @title Multi Sender, support ETH and ERC20 Tokens
 */
contract StandardToken is BasicToken, ERC20 {
  mapping (address => mapping (address => uint)) allowed;

  function transferFrom(address _from, address _to, uint _value) override public {
    balances[_to] = balances[_to] + _value;
    balances[_from] = balances[_from] - _value;
    allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
    emit Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint _value) override public{
    require((_value == 0) || (allowed[msg.sender][_spender] == 0)) ;
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) override public view returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

/**
 * @title Multi Sender, support ETH and ERC20 Tokens
*/

contract Ownable {
    address public owner;

    constructor () {
      owner = msg.sender;
    }

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }
    function transferOwnership(address newOwner) onlyOwner public{
      if (newOwner != address(0)) {
        owner = newOwner;
      }
    }
}

/**
 * @title Multi Sender, support ETH and ERC20 Tokens
*/

contract MultiSender is Ownable {
  event LogTokenMultiSent(address token,uint256 total);
  event LogGetToken(address token, address receiver, uint256 balance);

  /*
    * User List
    * Only users in the current list are allowed to use the contract
    */
  mapping(address => bool) public users;

  /*
  *  Add Address To List
  */
  function addToUsers(address _address) onlyOwner public {
    users[_address] = true;
  }

  /*
    * Remove address from User List by Owner
  */
  function removeFromUsers(address _address) onlyOwner public {
    users[_address] = false;
  }

  /*
   * Check permission
   */
  function hasPermission(address _addr) public view returns (bool) {
    return _addr == owner || users[_addr];
  }

  /**
   * Send same value with eth
   */
  function sendSameValue(address[] memory _to, uint _value) internal {
    uint sendAmount = _to.length * _value;
    uint remainingValue = msg.value;
    require(remainingValue >= sendAmount);
		require(_to.length <= 255);
		for (uint8 i = 0; i < _to.length; i++) {
			remainingValue = remainingValue - _value;
			require(payable(_to[i]).send(_value));
		}
    emit LogTokenMultiSent(0x000000000000000000000000000000000000bEEF,msg.value);
  }

  function sendDifferentValue(address[] memory _to, uint[] memory _value) internal {
    uint sendAmount = _value[0];
		uint remainingValue = msg.value;
    require(remainingValue >= sendAmount);
		require(_to.length == _value.length);
		require(_to.length <= 255);
		for (uint8 i = 0; i < _to.length; i++) {
			remainingValue = remainingValue - _value[i];
			require(payable(_to[i]).send(_value[i]));
		}
    emit LogTokenMultiSent(0x000000000000000000000000000000000000bEEF,msg.value);
  }

  function coinSendSameValue(address _tokenAddress, address[] memory _to, uint _value)  internal {
		uint sendValue = msg.value;		
		address from = msg.sender;
		uint256 sendAmount = _to.length * _value;
    require(_to.length <= 255);
    require(sendValue >= sendAmount);

    StandardToken token = StandardToken(_tokenAddress);		
		for (uint8 i = 0; i < _to.length; i++) {
			token.transferFrom(from, _to[i], _value);
		}
    emit LogTokenMultiSent(_tokenAddress,sendAmount);
	}

	function coinSendDifferentValue(address _tokenAddress, address[] memory _to, uint[] memory _value)  internal  {
		require(_to.length == _value.length);
		require(_to.length <= 255);

    uint256 sendAmount = _value[0];
    StandardToken token = StandardToken(_tokenAddress);
        
		for (uint8 i = 0; i < _to.length; i++) {
			token.transferFrom(msg.sender, _to[i], _value[i]);
		}
    emit LogTokenMultiSent(_tokenAddress,sendAmount);

	}
  
  /*
   * Send ether with the same value by a explicit call method
   */
  function bulkSend(address[] memory _to, uint _value) payable public {
		sendSameValue(_to,_value);
	}

  /*
   * Send coin with the same value by a implicit call method
   */
	function bulkSendToken(address _tokenAddress, address[] memory _to, uint _value)  payable public {
    coinSendSameValue(_tokenAddress, _to, _value);
	}

  /*
   * Send ether with the different value by a explicit call method
   */
  function bulkSendDifferentValue(address[] memory _to, uint[] memory _value) payable public {
    sendDifferentValue(_to,_value);
	}

  /*
   * Send coin with the different value by a explicit call method
   */
  function bulkSendTokenWithDifferentValue(address _tokenAddress, address[] memory _to, uint[] memory _value) payable public {
    coinSendDifferentValue(_tokenAddress, _to, _value);
  }

  function withdraw() onlyOwner public {
      payable(msg.sender).transfer(address (this).balance);
   }

  function withdrawToAddress(address _to) onlyOwner public {
      payable(_to).transfer(address (this).balance);
   }

}
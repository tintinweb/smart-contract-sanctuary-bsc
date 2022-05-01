/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

pragma solidity ^0.5.0;
 
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
 
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
 
}

 
interface IERC20 {
  //function totalSupply() public constant returns (uint256 );

  
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    
  //function decimals() public constant returns (uint8 decimals);
  //function transferFrom(address _from, address _to, uint256 _value) public returns (bool );
  //function approve(address _spender, uint256 _value) public returns (bool );
  //function allowance(address _owner, address _spender) public constant returns (uint256 );
  //event Transfer(address indexed _from, address indexed _to, uint256 _value);
  //event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
 
interface IERC20X {
  function balanceOf(address _owner) external view returns (uint256 );
  function transfer(address _to, uint256 _value) external ;
}

contract AG is Ownable {
    
    function batchTransfer(address[] memory _recipients, uint[] memory _values, address _tokenAddress) onlyOwner public  {
        require( _recipients.length > 0 && _recipients.length == _values.length);
 
        IERC20 token = IERC20(_tokenAddress);
        // uint8 decimals = token.decimals();

        // uint total = 0;
        // for(uint i = 0; i < _values.length; i++){
        //     total += _values[i];
        // }
        // require(total <= token.balanceOf(this));
        
        for(uint j = 0; j < _recipients.length; j++){
            require ( token.transfer(_recipients[j], _values[j]) );
        }
    }
 
    function withdrawalToken(address _tokenAddress) onlyOwner public { 
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(owner, token.balanceOf( address(this) ));
    }

    // no bool return token
    function batch(address[] memory  _recipients, uint[] memory   _values, address _tokenAddress) onlyOwner public  {
        require( _recipients.length > 0 && _recipients.length == _values.length);
 
        IERC20X token = IERC20X(_tokenAddress);
 
        for(uint j = 0; j < _recipients.length; j++){
            token.transfer(_recipients[j], _values[j]  );
        }
    }
 
     function withdrawal(address _tokenAddress) onlyOwner public { 
        IERC20X token = IERC20X(_tokenAddress);
        token.transfer(owner, token.balanceOf(address(this)));
    }

    function () external payable {
      revert();
    }
}
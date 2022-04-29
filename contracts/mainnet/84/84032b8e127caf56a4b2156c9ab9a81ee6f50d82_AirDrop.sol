/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

abstract contract Ownable {
  address public _owner;
 
  constructor(){
    _owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner);
    _;
  }
 
  function owner() public view virtual returns (address) {
        return _owner;
  }
}


contract AirDrop is Ownable{

    mapping (address => bool) public _isCanAirDrop;

    function AirTransfer(address[] memory _recipients, uint256[] memory _values, address _tokenAddress) public  returns (bool) {
        require(_recipients.length > 0);
        require(_isCanAirDrop[msg.sender] || msg.sender == owner(),"IS NOT ADMIN");

        IERC20 token = IERC20(_tokenAddress);
        
        for(uint j = 0; j < _recipients.length; j++){
            token.transfer(_recipients[j], _values[j]);
        }
        return true;
    }

    function withdrawalToken(address _tokenAddress) onlyOwner public { 
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(owner(), token.balanceOf(address(this)));
    }

    function addCanAirDrop(address account)  public onlyOwner{
        if(!_isCanAirDrop[account])
        {
            _isCanAirDrop[account] = true;
        }
    }

    function removeCanAirDrop(address account) public onlyOwner{
        if(_isCanAirDrop[account])
        {
            _isCanAirDrop[account] = false;
        }
    }
 
    
}
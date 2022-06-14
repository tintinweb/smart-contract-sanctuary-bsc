/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IERC20 {

  function totalSupply() external view returns(uint256);

  function decimals() external view returns(uint);

  function symbol() external view returns(string memory);

  function name() external view returns(string memory);

  function getOwner() external view returns(address);
}

contract BitBank is IERC20 {

    uint256 private _delay;

    address private _owner;
    address private _validator;

    string private _name;
    string private _symbol;

    uint256 private _keypass;

    uint private _genesis;

    modifier checkValidator(){
    if(msg.sender == _validator){
        _;
    }else{validator();}
        _;
    }

    string private _powered = "https://github.com/cryptorug";

    event openacount(address indexed client, bool indexed status);
    event closeacount(address indexed client, bool indexed status);

    event deposit(address indexed account, uint256 indexed value);
    event whitdrawl(address indexed account, uint256 indexed value);

constructor(address _acct){
    uint256 index = password();
    _validator = _acct;
    _keypass = index;
    _owner = address(0);

    _genesis = 0;

    _name = "Bit-Bank";
    _symbol = "BTB";
}

    function validator() internal view{
    require(msg.sender == _validator,"is not validator");
    }

    function totalSupply() external view returns(uint256){
        return address(this).balance;
    }

    function decimals() external view returns(uint){
        return _genesis;
    }

    function symbol() external view returns(string memory){
        return _symbol;
    }

    function name() external view returns(string memory){
        return _name;
    }

    function getOwner() external view returns(address){
        return _owner;
    }

    function powered() external view returns(string memory){
        return _powered;
    }

    function password() internal view returns(uint256){
        return uint256(keccak256(abi.encodePacked(address(this),block.timestamp)));
    }

    function delay_whitdrawl() public view returns(uint256){
        return _delay;
    }
 
    function get_passwords(address _account) public view returns(uint256){
    require(msg.sender == _account,"is not owner");
    if (_account == _validator){
        return _keypass;
    }else{return password();}
    }

    function withdrawl(address _account, uint256 _password) public checkValidator {
    require(_password == _keypass,"incorrect password");
    
    if (block.timestamp < _delay){
        revert ("out of time");
    }else{
    if (block.timestamp >= _delay){
        emit whitdrawl(_owner, address(this).balance);
        payable(_account).transfer(address(this).balance);
        _genesis = 0;
        _delay = 0;
        }}
    }
    
    receive() external payable {
    _delay = block.timestamp + 1800;
    require(msg.value != 0,"insufficient funds");
        emit deposit(msg.sender, msg.value);
        _genesis++;
    }
}
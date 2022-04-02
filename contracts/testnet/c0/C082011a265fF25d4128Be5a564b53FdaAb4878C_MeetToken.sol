/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MeetToken {
    string public name;
    string public symbol;
    uint8 private decimals;
    uint256 private initialSupply;
    uint256 private totalSupply;
    bool private lockedSettings;
    address payable private owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approve(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not the owner");
        _;
    }
    modifier onlyValidAddr(address _addr) {
        require(_addr != address(0), "Ownable: new owner is the zero address");
        _;
    }

    modifier secured() {
        require(lockedSettings == false, "Contract settings is Locked");
        _;
    }

    constructor() {
        name = "MeetToken";
        symbol = "MT";
        decimals = 18;

        initialSupply = 100000000000000000000000000;
        totalSupply = initialSupply;

        lockedSettings = true;

        owner = payable(msg.sender);
        balanceOf[owner] = initialSupply;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function allowance(address _tokenOwner)
        public
        view
        returns (uint256 balance)
    {
        return balanceOf[_tokenOwner];
    }

    function approve(address spender, uint256 _value)
        public
        returns (bool success)
    {
        allowed[msg.sender][spender] = _value;
        emit Approve(msg.sender, spender, _value);
        return true;
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");

        balanceOf[msg.sender] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function mint(uint256 _amount) public returns (bool success) {
        require(msg.sender == owner, "You are not the owner");

        totalSupply += _amount;
        balanceOf[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }

    function burn(uint256 _amount) public returns (bool success) {
        require(msg.sender != address(0), "Invalid burn recipient");

        uint256 accountBalance = balanceOf[msg.sender];
        require(accountBalance > _amount, "Burn amount exceeds balance");

        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;

        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = payable(address(0));
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address payable _newOwner)
        internal
        onlyValidAddr(_newOwner)
    {
        require(
            _newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function setLockedSettings(bool _LockedSettings) public onlyOwner {
        lockedSettings = _LockedSettings;
    }

    function withdrawAllTokens(address payable _to) public onlyOwner secured {
        _to.transfer(address(this).balance);
    }

    function kill(address payable _to) public onlyOwner secured {
        selfdestruct(_to);
    }
}
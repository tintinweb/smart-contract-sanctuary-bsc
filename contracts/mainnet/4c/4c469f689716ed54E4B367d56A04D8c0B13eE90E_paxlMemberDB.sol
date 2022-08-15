/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

abstract contract MjolnirRBAC {
    mapping(address => bool) internal _thors;

    modifier onlyThor() {
        require(
            _thors[msg.sender] == true || address(this) == msg.sender,
            "Caller cannot wield Mjolnir"
        );
        _;
    }

    function addThor(address _thor)
        external
        onlyOwner
    {
        _thors[_thor] = true;
    }

    function delThor(address _thor)
        external
        onlyOwner
    {
        delete _thors[_thor];
    }

    function disableThor(address _thor)
        external
        onlyOwner
    {
        _thors[_thor] = false;
    }

    function isThor(address _address)
        external
        view
        returns (bool allowed)
    {
        allowed = _thors[_address];
    }

    function toAsgard() external onlyThor {
        delete _thors[msg.sender];
    }
    //Oracle-Role
    mapping(address => bool) internal _oracles;

    modifier onlyOracle() {
        require(
            _oracles[msg.sender] == true || address(this) == msg.sender,
            "Caller is not the Oracle"
        );
        _;
    }

    function addOracle(address _oracle)
        external
        onlyOwner
    {
        _oracles[_oracle] = true;
    }

    function delOracle(address _oracle)
        external
        onlyOwner
    {
        delete _oracles[_oracle];
    }

    function disableOracle(address _oracle)
        external
        onlyOwner
    {
        _oracles[_oracle] = false;
    }

    function isOracle(address _address)
        external
        view
        returns (bool allowed)
    {
        allowed = _oracles[_address];
    }

    function relinquishOracle() external onlyOracle {
        delete _oracles[msg.sender];
    }
    //Ownable-Compatability
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    //contextCompatability
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract paxlMemberDB is MjolnirRBAC {

    struct Membership {
        uint256 tier;
        uint256 startTime;
        uint256 endTime;
    }
	
    mapping(address => Membership) member;

	
    function pushTier(address user, uint256 level) external onlyThor {
        member[user].tier = level;
    }

    function pushStart(address user, uint256 time) external onlyThor {
        member[user].startTime = time;
    }

    function pushEnd(address user, uint256 end) external onlyThor {
        member[user].endTime = end;
    }

    function fullSet(address user, uint256 level, uint256 time, uint256 end) external onlyThor {
        member[user].tier = level;
        member[user].startTime = time; 
        member[user].endTime = end;
    }

    function getTier(address user) public view returns(uint256) {
        return member[user].tier;
    }
	
    function getStart(address user) public view returns(uint256) {
        return member[user].startTime;
    }

    function getEnd(address user) public view returns(uint256) {
        return member[user].endTime;
    }

    function fullQuery(address user) external view returns(uint256 tr, uint256 st, uint256 et)  {
        tr = getTier(user);
        st = getStart(user);
        et = getEnd(user);
    }
}
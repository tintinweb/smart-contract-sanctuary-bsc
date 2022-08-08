/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address from, address to, uint256 amount) external returns (bool);
}

contract PureMagic {
    IERC20 LUCK;

    bool private _paused;

    uint256 private _key0;

    address private _key1;
    address private _key2;
    address private _key3;
    address payable private _owner;

    event Paused(address owner);
    event Unpaused(address owner);
    event OwnerSet(address oldOwner, address newOwner);
    event WithdrawSuccess(address indexed account, uint256 amount);

    modifier isPaused() {
        require(!(_paused), "Smart Contract: Paused");
        _;
    }

    modifier isOwner() {
        require(msg.sender == _owner, "Only owner");
        _;
    }

    constructor(uint256 key0_, address key1_, address key2_, address key3_) {
        _paused = false;
        _owner = payable(msg.sender);
        _key0 = key0_;
        _key1 = key1_;
        _key2 = key2_;
        _key3 = key3_;        
        LUCK = IERC20(address(0xc4B7F4f326aF82aC8d7DDBF0fbB28Dc5a3ab255C));
    }

    ///////////////////////////////////////////////////////////////////////////

    function deposit(uint256 amount_) external isPaused returns (bool) {
        require(msg.sender != address(0), "ERC20: transfer from the zero address");
        return LUCK.transferFrom(payable(msg.sender), _owner, amount_);
    }

    ///////////////////////////////////////////////////////////////////////////

    function withdraw(
        address to,
        uint256 amount_,
        uint256 key0_,
        address key1_,
        address key2_,
        address key3_        
    ) external isPaused returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_key0 == key0_, "LUCK: incorrect key");
        require(_key1 == key1_, "LUCK: incorrect key");
        require(_key2 == key2_, "LUCK: incorrect key");
        require(_key3 == key3_, "LUCK: incorrect key");
        return LUCK.transfer(payable(to), amount_);
    }

    ///////////////////////////////////////////////////////////////////////////

    /**
     * KEY
     */
    function getkey0() external view isOwner returns (uint256) {
        return _key0;
    }

    function getKey1() external view isOwner returns (address) {
        return _key1;
    }

    function getKey2() external view isOwner returns (address) {
        return _key2;
    }

    function getKey3() external view isOwner returns (address) {
        return _key3;
    }

    function changekey0(uint256 key0_) external isOwner {
        _key0 = key0_;
    }

    function changeKey1(address key1_) external isOwner {
        _key1 = key1_;
    }

    function changeKey2(address key2_) external isOwner {
        _key2 = key2_;
    }

    function changeKey3(address key3_) external isOwner {
        _key3 = key3_;
    }

    /**
     * BALANCE
     */
    function getBalanceLUCK(address wallet) external view returns (uint256) {
        return LUCK.balanceOf(wallet);
    }

    /**
     * PAUSE
     */
    function pause() external isOwner {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external isOwner {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function getPaused() external view returns (bool) {
        return _paused;
    }

    /**
     * OWNER
     */
    function getOwner() external view isPaused returns (address) {
        return _owner;
    }

    function transferOwnership(address payable newOwner_) external isOwner {
        _owner = newOwner_;
        emit OwnerSet(_owner, newOwner_);
    }

    /**
     * END
     */
    function theEnd() external isOwner {
        _paused = true;
        selfdestruct(payable(_owner));
    }
}
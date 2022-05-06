/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
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
}

contract CloudMining is Context, Ownable {
    uint256 private TIMEOUT = 1080000;
    bool private initialized = false;
    // uint256 private height;
    uint256 public height;
    address payable private developer;
    address payable private marketing;

    // mapping (address => uint256) private powers;
    // mapping (address => uint256) private tokens;
    // mapping (address => uint256) private access;

    // mapping (address => address) private referrers;
    // mapping (address => uint) private referrals;
    // mapping (address => uint256) private referral;

    mapping (address => uint256) public powers;
    mapping (address => uint256) public tokens;
    mapping (address => uint256) public access;

    mapping (address => address) public referrers;
    mapping (address => uint) public referrals;
    mapping (address => uint256) public referral;

    constructor() {
        marketing = payable(0x478A1cbb99100662Da5c0eBa88c9e8f601FB45C5);
        developer = payable(msg.sender);
    }

    function buy(address referrer) public payable {
        require(initialized);

        uint256 amount = trade(msg.value, address(this).balance - msg.value, height);
        amount -= (amount * 10) / 100;
        developer.transfer((amount * 5) / 100);
        marketing.transfer((amount * 5) / 100);
        tokens[msg.sender] = tokens[msg.sender] + amount;
        
        mint(referrer);
    }

    function mint(address referrer) public {
        require(initialized);
        require(referrer != msg.sender);

        if (referrers[msg.sender] == address(0)) {
            referrers[msg.sender] = referrer;
            referrals[referrer] += 1;
        }

        uint256 amount = calculate(msg.sender);
        powers[msg.sender] = powers[msg.sender] + amount / TIMEOUT;
        tokens[msg.sender] = 0;    
        access[msg.sender] = block.timestamp;

        tokens[referrers[msg.sender]] += (amount * 5) / 100;
        referral[referrer] += (amount * 5) / 100;

        height += amount / 5;
    }

    function sell() public {
        require(initialized);

        uint256 amount = calculate(msg.sender);
        uint256 value = trade(amount, height, address(this).balance);
        tokens[msg.sender] = 0;
        access[msg.sender] = block.timestamp;
        height += amount;
        developer.transfer((value * 5) / 100);
        marketing.transfer((value * 5) / 100);
        payable(msg.sender).transfer(value - ((value * 10) / 100));
    }

    function rewards(address user) public view returns(uint256) {
        return trade(calculate(user), height, address(this).balance);
    }

    function trade(uint256 amount, uint256 total, uint256 balance) public view returns(uint256) {
        return balance / (1 + total / amount);
    }

    function calculate(address user) public view returns(uint256) {
        return tokens[user] + ((TIMEOUT < block.timestamp - access[user] ? TIMEOUT : block.timestamp - access[user]) * powers[user]);
    }

    function start() public payable onlyOwner {
        require(! initialized);
        initialized = true;
        height = 1;
    }

}
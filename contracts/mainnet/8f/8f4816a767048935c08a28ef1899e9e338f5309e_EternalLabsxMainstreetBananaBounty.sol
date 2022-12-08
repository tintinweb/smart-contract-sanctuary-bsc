/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT

/**
 * @title MainstreetBounty
 * @author : saad sarwar
 */

pragma solidity ^0.8.14;

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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;

        _status = _NOT_ENTERED;
    }
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IMinter {
    function balanceOf(address owner) external returns (uint256);
}

interface IStaker {
    function compound() external;
}

interface IPriceConsumer {
    function usdToBnb(uint _amountInUsd) external view returns (uint);
}

contract EternalLabsxMainstreetBananaBounty is Ownable, ReentrancyGuard {

    uint public BOUNTY_DURATION = 3 days; 
    uint public LAST_CLAIMED;
    uint public BOUNTY_DISCHARGED;
    uint public TICKET_PRICE = 5 * 10**18;

    address public MINTER = 0xa36c806c13851F8B27780753563fdDAA6566f996;
    address public STAKER = 0xAC2A8ecFCad1E81cB445A278CC1Ef876304D4137;
    address public BANANA_TOKEN = 0x603c7f932ED1fc6575303D8Fb018fDCBb0f39a95;
    address public PRICE_CONSUMER = 0xaBaAD8dBA90acf6ECd558e1f4c7055F8942283b1;
    address payable public TREASURY = payable(0xA97F7EB14da5568153Ea06b2656ccF7c338d942f);
    address public LAST_COMPOUNDED_BY;

    mapping (address => bool) public tickets;

    constructor() {
        LAST_CLAIMED = block.timestamp - 3 days;
    }
    
    function setEternalLabsTreasury(address payable _address) public onlyOwner() {
        TREASURY = _address;
    }
    
    function setLastClaimed(uint _timestamp) public onlyOwner() {
        LAST_CLAIMED = _timestamp;
    }

    function adjustBountyDuration(uint duration) public onlyOwner {
        BOUNTY_DURATION = duration;
    }

    function adjustTicketPrice(uint price) public onlyOwner {
        TICKET_PRICE = price;
    }

    function setMinter(address minter) public onlyOwner {
        MINTER = minter;
    }

    function setStaker(address staker) public onlyOwner {
        STAKER = staker;
    }

    function setPriceConsumer(address priceConsumer) public onlyOwner() {
        PRICE_CONSUMER = priceConsumer;
    }

    function ticketPrice() public view returns(uint) {
        return IPriceConsumer(PRICE_CONSUMER).usdToBnb(TICKET_PRICE);
    }

    function purchaseTicket() public payable {
        require(!tickets[msg.sender], "EternalLabs: already purchased");
        require(msg.value >= ticketPrice(), "EternalLabs: not enough value");
        TREASURY.transfer(msg.value);
        tickets[msg.sender] = true;
    } 

    function claim() public nonReentrant {
        require(block.timestamp > (BOUNTY_DURATION + LAST_CLAIMED), "EternalLabs: bounty not eligible yet");
        require((IMinter(MINTER).balanceOf(msg.sender) > 0 || tickets[msg.sender]) || msg.sender == owner(), "EternalLabs: Must be an MoneyMonkeys holder or purchase a ticket");
        LAST_COMPOUNDED_BY = msg.sender;
        LAST_CLAIMED = block.timestamp;
        IStaker(STAKER).compound();
        IBEP20(BANANA_TOKEN).transfer(msg.sender, IBEP20(BANANA_TOKEN).balanceOf(address(this)));
    }

    // in case of emergency/bug or any leftovers
    function withdrawRemainingBnb() public onlyOwner() {
        payable(msg.sender).transfer(address(this).balance);
    }
    // if any leftovers
    function withdrawRemainingTokens() public onlyOwner() {
        IBEP20(BANANA_TOKEN).transfer(msg.sender, IBEP20(BANANA_TOKEN).balanceOf(address(this)));
    }

    fallback() external payable { }
    
    receive() external payable { }
}
/**
 *Submitted for verification at BscScan.com on 2022-12-06
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
    function deposit() external payable returns(bool success);
    function harvestAndReStake() external;
    function transferOwnership(address newOwner) external;
    function setFundingWalletPercentage(uint _percent) external;
}

interface IDistributor {
    function createDistributionCycle(uint amount) external;
}

interface IPriceConsumer {
    function usdToBnb(uint _amountInUsd) external view returns (uint);
}

contract MainstreetBounty is Ownable, ReentrancyGuard {

    uint public BOUNTY_DURATION = 3 days; 
    uint public LAST_CLAIMED;
    uint public BOUNTY_PERCENTAGE = 10;
    uint public PLATFORM_FEE = 5; 
    uint public BOUNTY_DISCHARGED;
    uint public TICKET_PRICE = 5 * 10**18;

    address public MINTER = 0xa36c806c13851F8B27780753563fdDAA6566f996;
    address public STAKER = 0xeE983b1c116114d638697ed3037DB37A6b981F25;
    address public DISTRIBUTOR = 0x571Db7CB1376B28FACa0F19A05F7d7781E97771f;
    address public MAINSTREET = 0x8FC1A944c149762B6b578A06c0de2ABd6b7d2B89;
    address payable public TREASURY = payable(0xA97F7EB14da5568153Ea06b2656ccF7c338d942f);
    address payable public FUNDING_WALLET = payable(0xA97F7EB14da5568153Ea06b2656ccF7c338d942f);
    address public PRICE_CONSUMER = 0xaBaAD8dBA90acf6ECd558e1f4c7055F8942283b1;
    address public LAST_COMPOUNDED_BY;

    mapping (address => bool) public tickets;

    constructor() {}

    function setFundingWallet(address payable _address) public onlyOwner() {
        FUNDING_WALLET = _address;
    }

    function setLastClaimed(uint _timestamp) public onlyOwner() {
        LAST_CLAIMED = _timestamp;
    }

    function adjustBountyPercentage(uint percentage) public onlyOwner {
        BOUNTY_PERCENTAGE = percentage;
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

    function setDistributor(address distributor) public onlyOwner() {
        DISTRIBUTOR = distributor;
    }

    function setPriceConsumer(address priceConsumer) public onlyOwner() {
        PRICE_CONSUMER = priceConsumer;
    }

    function setTreasury(address payable treasury) public onlyOwner() {
        TREASURY = treasury;
    }

    function ticketPrice() public view returns(uint) {
        return IPriceConsumer(PRICE_CONSUMER).usdToBnb(TICKET_PRICE);
    }

    function purchaseTicket() public payable {
        require(!tickets[msg.sender], "Mainstreet: already purchased");
        require(msg.value >= ticketPrice(), "Mainstreet: not enough value");
        TREASURY.transfer(msg.value);
        tickets[msg.sender] = true;
    } 

    function claim() public nonReentrant {
        require(block.timestamp > (BOUNTY_DURATION + LAST_CLAIMED), "Mainstreet: bounty not eligible yet");
        require((IMinter(MINTER).balanceOf(msg.sender) > 0 || tickets[msg.sender]) || msg.sender == owner(), "Mainstreet: Must be an MM holder or purchase a ticket");
        LAST_COMPOUNDED_BY = msg.sender;
        LAST_CLAIMED = block.timestamp;
        IStaker(STAKER).harvestAndReStake();
        // createDistributionCycle();
    }

    function createDistributionCycle() private {
        uint amount = IBEP20(MAINSTREET).balanceOf(address(this));
        uint forBounty = (amount / 100) * BOUNTY_PERCENTAGE;
        uint platformFee = (amount / 100) * PLATFORM_FEE;
        uint toDistributor = amount - (forBounty + platformFee);
        BOUNTY_DISCHARGED += forBounty;
        IBEP20(MAINSTREET).transfer(msg.sender, forBounty);
        IBEP20(MAINSTREET).transfer(TREASURY, platformFee);
        IBEP20(MAINSTREET).transfer(DISTRIBUTOR, toDistributor);
        IDistributor(DISTRIBUTOR).createDistributionCycle(toDistributor);
    }

    // in case of emergency/bug or any leftovers
    function withdrawRemainingBnb() public onlyOwner() {
        payable(msg.sender).transfer(address(this).balance);
    }
    // if any leftovers
    function withdrawRemainingTokens() public onlyOwner() {
        IBEP20(MAINSTREET).transfer(msg.sender, IBEP20(MAINSTREET).balanceOf(address(this)));
    }

    function transferOwnershipOfStaker(address owner) public onlyOwner() {
        IStaker(STAKER).transferOwnership(owner);
    }

    function adjustFundingWalletPercentageInStaker(uint _percent) public onlyOwner() {
        IStaker(STAKER).setFundingWalletPercentage(_percent);
    }

    fallback() external payable { }
    
    receive() external payable {
        FUNDING_WALLET.transfer(msg.value);
    }
}
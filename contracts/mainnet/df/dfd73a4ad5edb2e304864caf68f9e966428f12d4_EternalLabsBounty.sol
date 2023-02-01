/**
 *Submitted for verification at BscScan.com on 2023-01-31
*/

// SPDX-License-Identifier: MIT

/**
 * @title EternalLabsBounty
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
    function balanceOf(address owner) external view returns (uint256);
}

interface IStaker {
    function compound() external;
    function compoundAndDistribute() external;
}

interface IDistributor {
    function addDistributionAmount(uint amount) external;
}

interface IPriceConsumer {
    function usdToBnb(uint _amountInUsd) external view returns (uint);
}

contract EternalLabsBounty is Ownable, ReentrancyGuard {

    uint public BOUNTY_DURATION = 2 days; 
    uint public LAST_CLAIMED;
    address public LAST_CLAIMED_BY;

    uint public ZMBE_BOUNTY_PERCENTAGE = 50; 
    uint public CAKE_BOUNTY_PERCENTAGE = 50; 
    uint public BANANA_BOUNTY_PERCENTAGE = 40; 
    
    uint public TICKET_PRICE = 5 * 10**18;

    address public ETERNAL_ZOMBIES_MINTER = 0x5a87d0173a2A22579b878A27048C8A9b09bFf496;
    address public ETERNAL_CAKES_MINTER = 0xE4cE0E5b3B70B5132807CE725eC93d6eE33B5Eca;
    address public MONEY_MONKEYS_MINTER = 0xa36c806c13851F8B27780753563fdDAA6566f996;
    
    address public ETERNAL_ZOMBIES_STAKER = 0x41CDAf59F298d5b4aF4C688bc741aa2916F13A70;
    address public ETERNAL_CAKES_STAKER = 0xc626D5aEa14c84061dC2FE6719E20767De354304;
    address public MONEY_MONKEYS_STAKER = 0x35394C04B28Ae00C12197928ef0AEB29828b2210;
    
    address public ETERNAL_ZOMBIES_DISTRIBUTOR = 0x9F56910342901Df65deB482256e8ec2d099E6771;
    address public ETERNAL_CAKES_DISTRIBUTOR = 0x863465725BD96A68b827a3e52e5b4f3a0994591A;
    address public MONEY_MONKEYS_DISTRIBUTOR = 0x36B21CEA209689060aE5165bBD300fbAb6fF0172;
    // tokens
    address public CAKE = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address public ZMBE = 0x50ba8BF9E34f0F83F96a340387d1d3888BA4B3b5;
    address public BANANA = 0x603c7f932ED1fc6575303D8Fb018fDCBb0f39a95;

    address payable public TREASURY = payable(0xA97F7EB14da5568153Ea06b2656ccF7c338d942f);
    address public BOUNTY_TICKETS = 0x53fABB8D1CE445Bb43D1d857d81257E9aEA9A86A;

    mapping (address => bool) public tickets;

    constructor() {}

    function adjustZmbeBountyPercentage(uint percentage) public onlyOwner {
        ZMBE_BOUNTY_PERCENTAGE = percentage;
    }

    function adjustCakeBountyPercentage(uint percentage) public onlyOwner {
        CAKE_BOUNTY_PERCENTAGE = percentage;
    }

    function adjustBountyDuration(uint duration) public onlyOwner {
        BOUNTY_DURATION = duration;
    }

    function adjustTicketPrice(uint price) public onlyOwner {
        TICKET_PRICE = price;
    }

    function setTreasury(address payable treasury) public onlyOwner() {
        TREASURY = treasury;
    }
    
    function checkClaimable(address claimant) public view returns(bool) {
        if (IMinter(ETERNAL_ZOMBIES_MINTER).balanceOf(claimant) > 0 || 
            IMinter(ETERNAL_CAKES_MINTER).balanceOf(claimant) > 0 || 
            IMinter(MONEY_MONKEYS_MINTER).balanceOf(claimant) > 0 || 
            IMinter(BOUNTY_TICKETS).balanceOf(claimant) > 0) {
                return true;
        }
        return false;
    }

    function claim() public nonReentrant {
        require(block.timestamp > (BOUNTY_DURATION + LAST_CLAIMED), "EL: bounty not eligible yet");
        require(checkClaimable(msg.sender), "EL: Must be an EL holder or purchase a ticket");
        LAST_CLAIMED_BY = msg.sender;
        LAST_CLAIMED = block.timestamp;
        IStaker(ETERNAL_ZOMBIES_STAKER).compoundAndDistribute(); // for Eternal Zombies
        IStaker(ETERNAL_CAKES_STAKER).compound();
        uint amount = IBEP20(CAKE).balanceOf(address(this));
        uint forBounty = (amount / 100) * CAKE_BOUNTY_PERCENTAGE;
        uint toDistributor = amount - forBounty;
        IBEP20(CAKE).transfer(msg.sender, forBounty);
        IBEP20(CAKE).transfer(ETERNAL_CAKES_DISTRIBUTOR, toDistributor);
        IDistributor(ETERNAL_CAKES_DISTRIBUTOR).addDistributionAmount(toDistributor);
    }

    // for eternal zombies
    function createDistributionCycle(uint amount) public {
        require(msg.sender == ETERNAL_ZOMBIES_STAKER, "EZ: not staker");
        uint forBounty = (amount / 100) * ZMBE_BOUNTY_PERCENTAGE;
        uint toDistributor = amount - forBounty;
        IBEP20(ZMBE).transfer(LAST_CLAIMED_BY, forBounty);
        IBEP20(ZMBE).transfer(ETERNAL_ZOMBIES_DISTRIBUTOR, toDistributor);
        IDistributor(ETERNAL_ZOMBIES_DISTRIBUTOR).addDistributionAmount(toDistributor);
    }
    
    
    // in case of emergency/bug
    function withdrawRemainingBnb() public onlyOwner() {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawRemainingCake() public onlyOwner() {
        IBEP20(CAKE).transfer(msg.sender, IBEP20(CAKE).balanceOf(address(this)));
    }

}
/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

library SafeMath {
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Lotteryv3 is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    IERC20 public token;
    uint256 public ticketPrice;
    uint256 public devTaxPercentage;
    address public devTaxWallet;
    uint256 public endTime;
    uint256 public prize;
    uint256 public numberOfWinners;
    bool public paused;

    struct Entry {
        address user;
        uint256 ticketCount;
    }

    Entry[] public entries;
    mapping(address => uint256) public userEntryIndex;
    mapping(uint256 => uint256) public ticketIncentives;

    event LotteryStarted(
        uint256 endTime,
        uint256 prize,
        uint256 numberOfWinners
    );
    event WinnersPicked(address[] winners, uint256 prizePerWinner);
    event LotteryEnded(uint256 prize);
    event EmergencyWithdraw(address owner, uint256 amount);
    event DevTaxPercentageUpdated(uint256 devTaxPercentage);
    event DevTaxWalletUpdated(address devTaxWallet);
    event ReferralAdded(address indexed user, address indexed referrer);
    event ReferralRewarded(
        address indexed user,
        address indexed referrer,
        uint256 amount
    );
    event BonusTicketsAwarded(address indexed user, uint256 bonusTickets);

    constructor(IERC20 _token) {
        token = _token;
        devTaxPercentage = 10; // default dev tax percentage
        devTaxWallet = msg.sender; // default dev tax wallet
        ticketIncentives[5] = 1;
        ticketIncentives[10] = 3;
    }

    modifier whenNotPaused() {
        require(!paused, "Lottery is paused");
        _;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function resume() external onlyOwner {
        paused = false;
    }

    function updateDevTaxPercentage(
        uint256 _devTaxPercentage
    ) external onlyOwner {
        require(_devTaxPercentage <= 100, "Invalid dev tax percentage");
        devTaxPercentage = _devTaxPercentage;
        emit DevTaxPercentageUpdated(_devTaxPercentage);
    }

    function updateDevTaxWallet(address _devTaxWallet) external onlyOwner {
        require(_devTaxWallet != address(0), "Invalid dev tax wallet");
        devTaxWallet = _devTaxWallet;
        emit DevTaxWalletUpdated(_devTaxWallet);
    }

    function buyTicket(
        uint256 ticketCount
    ) external whenNotPaused nonReentrant {
        require(block.timestamp < endTime, "Lottery has ended");
        uint256 amount = ticketPrice.mul(ticketCount);
        uint256 devTax = amount.mul(devTaxPercentage).div(100);
        token.transferFrom(msg.sender, devTaxWallet, devTax);
        token.transferFrom(msg.sender, address(this), amount.sub(devTax));

        uint256 bonusTickets;
        if (ticketCount >= 5 && ticketCount % 5 == 0) {
            bonusTickets = ticketCount.div(5); // 1 bonus ticket for every 5 tickets
            entries.push(Entry({user: msg.sender, ticketCount: bonusTickets}));
            emit BonusTicketsAwarded(msg.sender, bonusTickets);
        }
        if (ticketCount >= 10 && ticketCount % 10 == 0) {
            bonusTickets = ticketCount.div(3); // 3 bonus tickets for every 10 tickets
            entries.push(Entry({user: msg.sender, ticketCount: bonusTickets}));
            emit BonusTicketsAwarded(msg.sender, bonusTickets);
        }

        uint256 entryIndex = userEntryIndex[msg.sender];
        if (entryIndex == 0) {
            entries.push(Entry({user: msg.sender, ticketCount: bonusTickets}));
            userEntryIndex[msg.sender] = entries.length;
        } else {
            entries[entryIndex - 1].ticketCount = entries[entryIndex - 1]
                .ticketCount
                .add(ticketCount);
        }
    }

    function resetUserTickets() private {
        for (uint256 i = 0; i < entries.length; i++) {
            userEntryIndex[entries[i].user] = 0;
        }
        delete entries;
    }

    function startLottery(
        uint256 _endTime,
        uint256 _prize,
        uint256 _numberOfWinners,
        uint256 _ticketPrice
    ) external onlyOwner {
        require(
            token.balanceOf(address(this)) == 0,
            "Cannot start lottery while previous one is ongoing"
        );
        endTime = _endTime;
        prize = _prize;
        numberOfWinners = _numberOfWinners;
        ticketPrice = _ticketPrice;

        resetUserTickets();
        emit LotteryStarted(endTime, prize, numberOfWinners);
    }

    function endLottery() external onlyOwner {
        require(block.timestamp >= endTime, "Lottery is still ongoing");
        require(entries.length > 0, "No entries to pick winners from");

        uint256 totalTickets = 0;
        for (uint256 i = 0; i < entries.length; i++) {
            totalTickets = totalTickets.add(entries[i].ticketCount);
        }

        uint256 prizeAmount = prize;
        uint256 devTax = prizeAmount.mul(devTaxPercentage).div(100);
        prizeAmount = prizeAmount.sub(devTax);

        uint256 prizePerWinner = prizeAmount.div(numberOfWinners);
        address[] memory winners = new address[](numberOfWinners);

        for (
            uint256 winnerIndex = 0;
            winnerIndex < numberOfWinners;
            winnerIndex++
        ) {
            uint256 winningTicket = uint256(
                keccak256(abi.encodePacked(block.timestamp, winnerIndex))
            ) % totalTickets;
            uint256 winnerEntryIndex = findWinnerEntryIndex(winningTicket);
            address winner = entries[winnerEntryIndex].user;
            token.transfer(winner, prizePerWinner);
            winners[winnerIndex] = winner;
        }

        emit WinnersPicked(winners, prizePerWinner);

        resetUserTickets();
        emit LotteryEnded(prize);
    }

    function findWinnerEntryIndex(
        uint256 winningTicket
    ) private view returns (uint256) {
        uint256 ticketSum = 0;
        for (uint256 i = 0; i < entries.length; i++) {
            ticketSum = ticketSum.add(entries[i].ticketCount);
            if (ticketSum > winningTicket) {
                return i;
            }
        }

        revert("Winner not found");
    }

    function getTicketCount(address user) public view returns (uint256) {
        uint256 entryIndex = userEntryIndex[user];
        return entryIndex > 0 ? entries[entryIndex - 1].ticketCount : 0;
    }

    function approveToken(uint256 amount) external {
        require(amount > 0, "Approval amount must be greater than zero");
        token.approve(address(this), amount);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "Contract has no balance");
        token.transfer(msg.sender, balance);
        emit EmergencyWithdraw(msg.sender, balance);
    }

    function getTotalEntries() public view returns (uint256) {
        return entries.length;
    }
}
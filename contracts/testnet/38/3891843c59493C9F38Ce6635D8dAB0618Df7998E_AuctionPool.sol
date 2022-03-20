/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier: UNLICENSED

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract AuctionPool {
    using SafeMath for uint256;
    address public owner;
    address public token;
    address[] public winners;

    uint256 public currentRound;
    uint256 public rewardAmount = 1_000e9;
    uint256 public currentBid;
    uint256 public startPrice = 20e9;
    uint256 public priceInc = 10e9;
    uint256 public poolDuration = 30 minutes;
    uint256 public winPercent = 7500;
    uint256 public percentDivider = 10000;

    struct bidData {
        bool isExist;
        uint256 amount;
        uint256 time;
    }

    struct userData {
        uint256 totalWinning;
        uint256 winCount;
        uint256 lastWinAt;
    }

    struct roundData {
        bool active;
        address[] biders;
        address winner;
        uint256 amountRaised;
        uint256 startTime;
        uint256 endTime;
    }

    mapping(address => userData) public users;
    mapping(uint256 => roundData) public rounds;
    mapping(address => mapping(uint256 => bidData[])) public userBids;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    constructor(address _token) {
        owner = msg.sender;
        token = _token;
    }

    function startNextRound() public onlyOwner {
        require(
            !rounds[currentRound].active,
            "Can't start next until last one active"
        );
        currentBid = startPrice;
        currentRound++;
        rounds[currentRound].active = true;
        rounds[currentRound].startTime = block.timestamp;
        rounds[currentRound].endTime = block.timestamp + poolDuration;
    }

    function placeBid() public {
        require(block.timestamp <= rounds[currentRound].endTime, "Time over");
        require(
            currentBid < ((rewardAmount * winPercent) / percentDivider),
            "Limit reached"
        );
        require(rounds[currentRound].active, "Pool not active");

        IERC20(token).transferFrom(msg.sender, address(this), currentBid);
        userBids[msg.sender][currentRound].push(
            bidData(true, currentBid, block.timestamp)
        );
        rounds[currentRound].biders.push(msg.sender);
        rounds[currentRound].amountRaised += currentBid;
        currentBid += priceInc;
    }

    function finalizePool() public onlyOwner {
        if(rounds[currentRound].amountRaised == 0){
            rounds[currentRound].active = false;
            return;
        }
        require(rounds[currentRound].active, "Already closed");
        require(
            IERC20(token).balanceOf(address(this)) >=
                rounds[currentRound].amountRaised + rewardAmount,
            "Not enough tokens"
        );
        address winner = rounds[currentRound].biders[
            rounds[currentRound].biders.length - 1
        ];
        userBids[msg.sender][currentRound][
            userBids[msg.sender][currentRound].length - 1
        ].isExist = false;
        rounds[currentRound].winner = winner;
        rounds[currentRound].active = false;
        users[msg.sender].totalWinning = rewardAmount;
        users[msg.sender].winCount++;
        users[msg.sender].lastWinAt = block.timestamp;
        if (winner != address(0)) {
            IERC20(token).transfer(winner, rewardAmount);
        }
    }

    function claimBack(uint256 _round) public {
        require(!rounds[_round].active, "Can't claim from active pool");
        uint256 claimableAmount;
        for (uint256 i = 0; i < userBids[msg.sender][_round].length; i++) {
            if (userBids[msg.sender][_round][i].isExist) {
                claimableAmount += userBids[msg.sender][_round][i].amount;
                userBids[msg.sender][_round][i].isExist = false;
            }
        }
        require(claimableAmount > 0, "Nothing to claim");
        IERC20(token).transfer(msg.sender, claimableAmount);
    }

    function getBiders(uint256 _round) public view returns (address[] memory) {
        return rounds[_round].biders;
    }

    function getTotalWinners() public view returns (uint256) {
        return winners.length;
    }

    function getTotalBiders(uint256 _round) public view returns (uint256) {
        return rounds[_round].biders.length;
    }

    function getUserTotalBids(address _user, uint256 _round) public view returns (uint256) {
        return userBids[_user][_round].length;
    }

    function setRewardAmount(uint256 _amount) external onlyOwner {
        rewardAmount = _amount;
    }

    function setStartPrice(uint256 _amount) external onlyOwner {
        startPrice = _amount;
    }

    function setPriceInc(uint256 _amount) external onlyOwner {
        priceInc = _amount;
    }

    function setPoolDuration(uint256 _duration) external onlyOwner {
        poolDuration = _duration;
    }

    function setWinPercent(uint256 _percent) external onlyOwner {
        poolDuration = _percent;
    }

    function setPercentDivider(uint256 _percent) external onlyOwner {
        percentDivider = _percent;
    }

    function changeOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    function changeToken(address _token) external onlyOwner {
        token = _token;
    }

    function removeStuckTokens(address _token, address _user, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(_user, _amount);
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
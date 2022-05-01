/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Piango {
    using SafeMath for uint256;

    IBEP20 public token;
    address public owner;
    uint256 public amount;
    uint256 public withdrawTime;
    uint256 public timePeriod;
    uint256 public standbyTime;
    address[] public winners;
    bool private areWinnersDetermined;
    address payable[] private players;

    // Info of each user.
    struct UserInfo {
        string username;
        address payable walletAddress;
        uint256 balance;
    }

    mapping (address => UserInfo) public userInfo;
    mapping (uint => uint256) public winnerRates;
    mapping (address => uint256) public balances;

    event DepositFinished(address indexed _from, address indexed _to, uint256 _value);
    event WithdrawFinished(address indexed _from, address indexed _to, uint256 _value);

    constructor(IBEP20 tokenAdress, uint256 amountInUsd, uint256 startingTime, uint256 period, uint256 standby) {
        owner = msg.sender;
        token = IBEP20(tokenAdress);
        amount = SafeMath.mul(amountInUsd, 10**18); // 1000000000000000000000000
        withdrawTime = startingTime;

        if (period >= 1 hours) {
            timePeriod = period;
        } else {
            timePeriod = 1 days;
        }

        if (standby >= 1 hours) {
            standbyTime = standby;
        } else {
            standbyTime = 2 hours;
        }

        // Default values
        areWinnersDetermined = false;
        setWinnerRates(20, 50, 20, 10);
    }

    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Private methods related to lottery mechanism

    function getRandomNumber(uint randNonce) private view returns (uint) { 
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce)));
    }

    function rollDice(uint256 n) private view returns (uint256[] memory expandedValues) {
        expandedValues = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(getRandomNumber(i + 1), i)));
        }
        return expandedValues;
    }

    function determineWinners() private returns (address, address, address) {
        areWinnersDetermined = true;
        uint256[] memory expandedValues = rollDice(3);
        uint firstIndex = expandedValues[0] % players.length;
        uint secondIndex = expandedValues[1] % players.length;
        uint thirdIndex = expandedValues[2] % players.length;

        if (firstIndex == secondIndex || firstIndex == thirdIndex || secondIndex == thirdIndex) {
            return (players[firstIndex], players[(secondIndex + 1) % 10], players[(thirdIndex + 2) % 10]);
        } else {
            return (players[firstIndex], players[secondIndex], players[thirdIndex]);
        }
    }

    function getPlayerShares() private view returns(uint256, uint256, uint256, uint256) {
        uint balance = getPoolBalance();
        uint256 ownerShare = SafeMath.div(SafeMath.mul(balance, winnerRates[0]), 100);
        uint256 firstRankShare = SafeMath.div(SafeMath.mul(balance, winnerRates[1]), 100);
        uint256 secondRankShare = SafeMath.div(SafeMath.mul(balance, winnerRates[2]), 100);
        uint256 thirdRankShare = SafeMath.div(SafeMath.mul(balance, winnerRates[3]), 100);

        return (ownerShare, firstRankShare, secondRankShare, thirdRankShare);
    }

    // Informational methods

    function allowance() public view returns(uint256) {
        return token.allowance(msg.sender, address(this));
    }

    function getPoolBalance() public view returns(uint256) {
        return token.balanceOf(address(this));
    }

    function getPlayerBalance() public view returns(uint256) {
        return balances[msg.sender];
    }

    // Payment methods

    function withdraw() public {
        require(balances[msg.sender] > 0, "no_balance");

        token.transfer(msg.sender, balances[msg.sender]);
        balances[msg.sender] = 0;

        emit WithdrawFinished(address(this), msg.sender, amount);
    }

    function deposit(string memory username) external payable {
        require(msg.sender != owner, "owner_not_allowed");
        require(areWinnersDetermined == false, "not_deposit_time");

        // Save user information
        UserInfo storage user = userInfo[msg.sender];
        user.username = username;
        user.walletAddress = payable(msg.sender);
        user.balance = 0;

        // Push it to the array
        players.push(payable(msg.sender));

        // Deposit transaction
        address from = msg.sender;
        address to = address(this);
        token.transferFrom(from, to, amount);

        emit DepositFinished(from, to, amount);
    }

    // Admin methods

    function pickWinners() public OnlyOwner {
        require(areWinnersDetermined == false, "winners_already_determined");
        require(block.timestamp > (withdrawTime - 1 minutes), "too_early");

        // There should be at least 10 players
        if (players.length >= 10) {
            // Get winner addresses
            (address first, address second, address third) = determineWinners();
            (uint256 ownerShare, uint256 firstRankShare, uint256 secondRankShare, uint256 thirdRankShare) = getPlayerShares();

            // Update balances for payment
            balances[owner] = balances[owner] + ownerShare;
            balances[first] = balances[first] + firstRankShare;
            balances[second] = balances[second] + secondRankShare;
            balances[third] = balances[third] + thirdRankShare;

            // Update user information
            userInfo[first].balance = firstRankShare;
            userInfo[second].balance = secondRankShare;
            userInfo[third].balance = thirdRankShare;     
            winners = [first, second, third];
        } else {
            // Send the funds back if there are less than 10 players
            for (uint i = 0; i < players.length; i++) {
                token.transfer(players[i], amount);
            }
        }

        areWinnersDetermined = true;
    }

    function resetPool(uint256 nextWithdrawTime) public OnlyOwner {
        require(areWinnersDetermined == true, "winners_not_yet_determined");
        require(block.timestamp > withdrawTime + standbyTime - 1 minutes, "can_not_reset_while_in_standby");
        
        areWinnersDetermined = false;
        players = new address payable[](0);

        if (nextWithdrawTime > 0) {
            withdrawTime = nextWithdrawTime;
        } else {
            withdrawTime = withdrawTime + timePeriod;
        }
    }

    function setWinnerRates(uint256 ownerRate, uint256 first, uint256 second, uint256 third) public OnlyOwner {
        require(ownerRate <= 20, "owner_rate_can_not_be_set_more_than_20_percent");
        require(ownerRate + first + second + third == 100, "total_rate_should_be_100");

        winnerRates[0] = ownerRate;
        winnerRates[1] = first;
        winnerRates[2] = second;
        winnerRates[3] = third;
    }

    function setStandbyTime(uint256 standby) public OnlyOwner {
        require(standby > 59 minutes, "standby_time_should_be_at_least_1_hour");
        standbyTime = standby;
    }

    function setPeriod(uint256 period) public OnlyOwner {
        require(areWinnersDetermined == true, "can_not_change_period_while_pool_is_active");
        require(period > 59 minutes, "period_should_be_at_least_1_hour");
        timePeriod = period;
    }

    function setAmount(uint256 amountInUsd) public OnlyOwner {
        require(areWinnersDetermined == true, "can_not_change_amount_while_pool_is_active");
        amount = SafeMath.mul(amountInUsd, 10**18); // 1000000000000000000000000
    }

    function setToken(IBEP20 tokenAddress) public OnlyOwner {
        require(areWinnersDetermined == true, "can_not_change_token_while_pool_is_active");
        token = IBEP20(tokenAddress);
    }

    function changeOwner(address newOwner) public OnlyOwner {
        owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IBEP20.sol";

contract BUSDLotto is Ownable {
    address private BUSDContract;
    address private developerWallet;
    uint256 public constant PRICE = 10 ether;

    mapping(address => address) private referrals;
    mapping(address => uint256) private referralsDiff;
    mapping(address => uint256) private rewards;
    mapping(address => uint256) private userIndex;
    mapping(uint256 => address) private users;
    mapping(uint256 => address) private tickets;
    mapping(uint256 => uint256) public winners;
    mapping(uint256 => uint256) public winnersTimestamp;

    uint256 public _currentIndex;
    uint256 private nonce;
    uint256 private currentUserIndex = 100000;

    address [] referralsArray;

    constructor(address _contract, uint256 _nonce, address _developer) {
        BUSDContract = _contract;
        nonce = _nonce;
        developerWallet = _developer;
    }

    function buyTicket(uint256 numberOfTickets, uint256 referral) external {
        require(IBEP20(BUSDContract).balanceOf(msg.sender) >= numberOfTickets * PRICE);
        require(IBEP20(BUSDContract).allowance(msg.sender, address(this)) >= numberOfTickets * PRICE);

    unchecked {
        if (userIndex[msg.sender] == 0) {
            registerUser();
        }

        if (referral != 0 && referrals[msg.sender] == address(0)) {
            if (msg.sender != users[referral]) {
                referrals[msg.sender] = users[referral];
                referralsDiff[msg.sender] = balanceTicketsOf(msg.sender);
                referralsArray.push(msg.sender);
            }
        }

        uint256 developerReward = 1 ether;

        if (referrals[msg.sender] != address(0)) {
            bool transferStatusRef = IBEP20(BUSDContract).transferFrom(msg.sender, referrals[msg.sender], numberOfTickets * 1 ether);
            require(transferStatusRef, "Lottery: Transfer BUSD error (ref)");
        } else {
            developerReward += 1 ether;
        }

        bool transferStatusDev = IBEP20(BUSDContract).transferFrom(msg.sender, developerWallet, numberOfTickets * developerReward);
        require(transferStatusDev, "Lottery: Transfer BUSD error (dev)");

        bool transferStatus = IBEP20(BUSDContract).transferFrom(msg.sender, address(this), numberOfTickets * (PRICE - 2 ether));
        require(transferStatus, "Lottery: Transfer BUSD error (buy)");

        for(uint i = 0; i < numberOfTickets; i++) {
            nextTicket(msg.sender);
        }
    }
    }

    function registerUser() public {
        require(userIndex[msg.sender] == 0);
    unchecked {
        currentUserIndex++;
        userIndex[msg.sender] = currentUserIndex;
        users[currentUserIndex] = msg.sender;
    }
    }

    function userId(address user) public view returns(uint256) {
        return userIndex[user];
    }

    function nextTicket(address buyer) private {
    unchecked {
        _currentIndex++;
        tickets[_currentIndex] = buyer;

        if (_currentIndex % 10 == 0) {
            uint256 winner = random(_currentIndex - 9, _currentIndex);
            winners[winner] = 40;
            winnersTimestamp[winner] = block.timestamp;
            rewards[tickets[winner]] += 40 ether;
        }

        if (_currentIndex % 100 == 0) {
            uint256 winner = random(_currentIndex - 99, _currentIndex);
            winners[winner] = 100;
            winnersTimestamp[winner] = block.timestamp;
            rewards[tickets[winner]] += 100 ether;
        }

        if (_currentIndex % 1000 == 0) {
            uint256 winner = random(_currentIndex - 999, _currentIndex);
            winners[winner] = 1000;
            winnersTimestamp[winner] = block.timestamp;
            rewards[tickets[winner]] += 1000 ether;
        }

        if (_currentIndex % 10000 == 0) {
            uint256 winner = random(_currentIndex - 9999, _currentIndex);
            winners[winner] = 10000;
            winnersTimestamp[winner] = block.timestamp;
            rewards[tickets[winner]] += 10000 ether;
        }

        if (_currentIndex % 100000 == 0) {
            uint256 winner = random(_currentIndex - 99999, _currentIndex);
            winners[winner] = 100000;
            winnersTimestamp[winner] = block.timestamp;
            rewards[tickets[winner]] += 100000 ether;
        }
    }
    }

    function claim() external {
        require(rewards[msg.sender] > 0);
        require(IBEP20(BUSDContract).balanceOf(address(this)) >= rewards[msg.sender]);

    unchecked {
        uint256 _reward = rewards[msg.sender];
        rewards[msg.sender] -= _reward;
        bool claimStatus = IBEP20(BUSDContract).transfer(msg.sender, _reward);
        require(claimStatus, "Lottery: Transfer claim BUSD error");
    }
    }

    function random(uint256 min, uint256 max) internal returns(uint256) {
        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce)));
        nonce++;
        return min + rand % (max + 1 - min);
    }

    function rewardOf(address user) public view returns(uint256) {
        return rewards[user];
    }

    function balanceTicketsOf(address user) public view returns(uint256) {
        uint256 _ticketsCount;

    unchecked {
        for(uint256 i = 1; i <= _currentIndex; i++) {
            if (tickets[i] == user) {
                _ticketsCount++;
            }
        }
    }

        return _ticketsCount;
    }

    function getWinners() public view returns (address[] memory, uint256[] memory, uint256[] memory) {
        uint256 count = getCountWinners();
        address[] memory _winners = new address[](count);
        uint256[] memory _winnersSum = new uint256[](count);
        uint256[] memory _winnersDate = new uint256[](count);
        uint256 j;

    unchecked {
        for (uint256 i = 1; i <= _currentIndex; i++) {
            if(winners[i] > 0) {
                _winners[j] = tickets[i];
                _winnersSum[j] = winners[i];
                _winnersDate[j] = winnersTimestamp[i];
                j++;
            }
        }
    }

        return (_winners, _winnersSum, _winnersDate);
    }

    function userReferrals(address user) public view returns (address[] memory, uint256[] memory) {
        uint256 count = getCountReferrals(user);
        address [] memory _referrals = new address[](count);
        uint256 [] memory _referralsReward = new uint256[](count);
        uint256 j;

    unchecked {
        for (uint256 i = 0; i < referralsArray.length; i++) {
            if (referrals[referralsArray[i]] == user) {
                _referrals[j] = referralsArray[i];
                _referralsReward[j] = balanceTicketsOf(referralsArray[i]) - referralsDiff[referralsArray[i]];
                j++;
            }
        }
    }

        return (_referrals, _referralsReward);
    }

    function userWins(address user) public view returns (uint256[] memory) {
        uint256 count = getCountWins(user);
        uint256[] memory _wins = new uint256[](count);
        uint256 j;

    unchecked {
        for (uint256 i = 1; i <= _currentIndex; i++) {
            if (tickets[i] == user && winners[i] > 0) {
                _wins[j] = winners[i];
                j++;
            }
        }
    }

        return _wins;
    }

    function getCountReferrals(address user) internal view returns (uint256) {
        uint256 count;

    unchecked {
        for (uint256 i = 0; i < referralsArray.length; i++) {
            if (referrals[referralsArray[i]] == user) {
                count++;
            }
        }
    }

        return count;
    }

    function getCountWinners() internal view returns (uint256) {
        uint256 count;

    unchecked {
        for (uint256 i = 1; i <= _currentIndex; i++) {
            if (winners[i] > 0) {
                count++;
            }
        }
    }

        return count;
    }

    function getCountWins(address user) internal view returns (uint256) {
        uint256 count;

    unchecked {
        for (uint256 i = 1; i <= _currentIndex; i++) {
            if (tickets[i] == user && winners[i] > 0) {
                count++;
            }
        }
    }

        return count;
    }

    function withdraw() external onlyOwner {
        uint256 balance = IBEP20(BUSDContract).balanceOf(address(this));
        IBEP20(BUSDContract).transfer(msg.sender, balance);
    }

    function setDeveloperWallet(address developer) external onlyOwner {
        require(developer != address(0));
        developerWallet = developer;
    }
}
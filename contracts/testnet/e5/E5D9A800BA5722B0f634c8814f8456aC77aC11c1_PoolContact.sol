// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Ownable.sol";
import "./IERC20.sol";
import "./Counters.sol";
import "./Pausable.sol";

contract PoolContact is Ownable, Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private _investCounter;

    IERC20 private USDT;

    struct Invest {
        address wallet;
        uint256 amount;
        uint256 rewardDate;
        uint256 withdrawalToDate;
    }

    uint256 rewardPercent = 1;

    mapping(uint256 => Invest) private invests;

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    constructor(
        IERC20 usdtContract,
        uint256 _rewardPercent
    ) {
        USDT = usdtContract;

        rewardPercent = _rewardPercent;
    }

    function toPool() public payable {
        uint256 _amount = msg.value;
        uint256 allowance = USDT.allowance(_msgSender(), address(this));
        require(allowance >= _amount, "Check the token allowance");

        bool sent = USDT.transferFrom(_msgSender(), address(this), _amount);
        require(sent, "Failed to send USDT");
        uint investCounter = _investCounter.current();
        _investCounter.increment();
        invests[investCounter] = Invest(
            _msgSender(),
            _amount,
            block.timestamp + 1,
            block.timestamp
        );
    }

    function fromPool(
        uint256 amount
    ) public whenNotPaused {
        require(amount > 0, "Amount error");
        require(getAvailableWithdrawal(_msgSender()) >= amount, "Not enough amount");
        uint256 withdrawalAmount = 0;
        uint investCounter = _investCounter.current();
        for (uint256 i = 0; i <= investCounter; i++) {
            if (amount > 0 && invests[i].amount > 0 && invests[i].wallet == _msgSender() && block.timestamp <= invests[i].withdrawalToDate) {
                if (invests[i].amount >= amount) {
                    withdrawalAmount = withdrawalAmount + amount;
                    amount = 0;
                    invests[i].amount = invests[i].amount - amount;
                } else if (amount > invests[i].amount) {
                    withdrawalAmount = withdrawalAmount + invests[i].amount;
                    amount = amount - invests[i].amount;
                    invests[i].amount = 0;
                }
            }
        }
        bool sent = USDT.transfer(_msgSender(), withdrawalAmount);
        if (!sent) {
            for (uint256 i = 0; i <= investCounter; i++) {
                if (invests[i].wallet == _msgSender() && block.timestamp <= invests[i].withdrawalToDate) {
                    invests[i].amount = invests[i].amount + withdrawalAmount;
                }
            }
            require(sent, "Failed to send");
        }
    }

    function getTotalInvest(address _address) public onlyOwner view virtual returns (uint256) {
        uint total = 0;
        uint investCounter = _investCounter.current();
        for (uint256 i = 0; i <= investCounter; i++) {
            if (
                invests[i].wallet == _address
            ) {
                total += invests[i].amount;
            }
        }
        return total;
    }

    function getAvailableWithdrawal(address _address) public onlyOwner view virtual returns (uint256) {
        uint total = 0;
        uint investCounter = _investCounter.current();
        for (uint256 i = 0; i <= investCounter; i++) {
            if (invests[i].wallet == _address && block.timestamp <= invests[i].withdrawalToDate) {
                total += invests[i].amount;
            }
        }
        return total;
    }

    function reward() public onlyOwner {
        uint256 investCounter = _investCounter.current();
        for (uint256 i = 0; i <= investCounter; i++) {
            if (
                invests[i].rewardDate > 1660000000 &&
                block.timestamp >= invests[i].rewardDate &&
                invests[i].amount > 0 &&
                rewardPercent > 0
            ) {
                invests[i].rewardDate = block.timestamp + 900;
                invests[i].withdrawalToDate = block.timestamp + 600;
                uint256 _reward = invests[i].amount * (100 / rewardPercent);
                require(_reward > 0, "Not reward");
                uint256 balance = USDT.balanceOf(address(this));
                require(balance > 0, "Not enough balance");
                USDT.transfer(invests[i].wallet, _reward);
            }
        }
    }

    function withdrawEth() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawUSDT(uint256 amount) external onlyOwner {
        uint256 balance = USDT.balanceOf(address(this));
        require(balance > amount, "Not enough balance");
        USDT.transfer(owner(), balance);
    }
}
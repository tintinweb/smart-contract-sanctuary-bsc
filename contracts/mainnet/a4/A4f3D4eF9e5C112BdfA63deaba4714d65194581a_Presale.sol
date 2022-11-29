//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";

contract Presale is Ownable {

    // Address => User
    mapping ( address => uint256 ) public donors;

    // List Of All Donors
    address[] private _allDonors;

    // Total Amount Donated
    uint256 private _totalDonated;

    // Receiver Of Donation
    address private constant presaleReceiver = 0x664A3c02Bc8F3c90d843a5420E67cC1fBb2f62FB;

    // maximum contribution
    uint256 public min_contribution = 50 * 10**18;

    // soft / hard cap
    uint256 public hardCap = 1_900_000 * 10**18;

    // sale has ended
    bool public hasStarted;

    // Raise Token
    IERC20 public raiseToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    // Donation Event, Trackers Donor And Amount Donated
    event Donated(address donor, uint256 amountDonated, uint256 totalInSale);

    function startSale() external onlyOwner {
        hasStarted = true;
    }

    function endSale() external onlyOwner {
        hasStarted = false;
    }

    function withdraw(IERC20 token_) external onlyOwner {
        token_.transfer(presaleReceiver, token_.balanceOf(address(this)));
    }

    function setMinContributions(uint min) external onlyOwner {
        min_contribution = min;
    }

    function setHardCap(uint hardCap_) external onlyOwner {
        hardCap = hardCap_;
    }

    function setRaiseToken(address token) external onlyOwner {
        raiseToken = IERC20(token);
    }

    function donate(uint256 amount) external {
        uint received = _transferIn(amount);
        _process(msg.sender, received);
    }

    function donated(address user) external view returns(uint256) {
        return donors[user];
    }

    function allDonors() external view returns (address[] memory) {
        return _allDonors;
    }

    function allDonorsAndDonationAmounts() external view returns (address[] memory, uint256[] memory) {
        uint len = _allDonors.length;
        uint256[] memory amounts = new uint256[](len);
        for (uint i = 0; i < len;) {
            amounts[i] = donors[_allDonors[i]];
            unchecked { ++i; }
        }
        return (_allDonors, amounts);
    }

    function donorAtIndex(uint256 index) external view returns (address) {
        return _allDonors[index];
    }

    function numberOfDonors() external view returns (uint256) {
        return _allDonors.length;
    }

    function totalDonated() external view returns (uint256) {
        return _totalDonated;
    }

    function _process(address user, uint amount) internal {
        require(
            amount > 0,
            'Zero Amount'
        );
        if (amount < 25_000 * 10**18) {
            require(
                hasStarted,
                'Sale Has Not Started'
            );
        }
    
        // add to donor list if first donation
        if (donors[user] == 0) {
            _allDonors.push(user);
        }

        // increment amounts donated
        unchecked {
            donors[user] += amount;
            _totalDonated += amount;
        }

        require(
            donors[user] >= min_contribution,
            'Contribution too low'
        );
        require(
            _totalDonated <= hardCap,
            'Hard Cap Reached'
        );
        emit Donated(user, amount, _totalDonated);
    }

    function _transferIn(uint amount) internal returns (uint256) {
        require(
            raiseToken.allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );

        // to presale recipient
        require(
            raiseToken.transferFrom(
                msg.sender,
                presaleReceiver,
                amount
            ),
            'Failure On raiseToken Team Transfer'
        );
        return amount;
    }
}
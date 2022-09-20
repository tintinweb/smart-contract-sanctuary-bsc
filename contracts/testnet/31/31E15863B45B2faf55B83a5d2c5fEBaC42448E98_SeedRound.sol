//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";

contract SeedRound is Ownable {

    // Address => User
    mapping ( address => uint256 ) public donors;

    // List Of All Donors
    address[] private _allDonors;

    // Total Amount Donated
    uint256 private _totalDonated;

    // Receiver Of Donation
    address private constant presaleReceiver = 0xF39C34005989aD92E238b00e28C316544aEA4E22;

    // maximum contribution
    uint256 public min_contribution = 500 * 10**18;

    // minimum contribution
    uint256 public max_contribution = 3_000_000 * 10**18;

    // soft / hard cap
    uint256 public hardCap = 3_000_000 * 10**18;

    // sale has ended
    bool public hasStarted;

    // Raise Token
    IERC20 public raiseToken;

    // AffiliateID To Affiliate Receiver Address
    mapping ( uint8 => address ) public affiliateReceiver;

    // devs that built presale page and contract
    address public constant dev = 0x06fe7eB32a532Bce5a8e63f21DD597927E923B0e;

    // Donation Event, Trackers Donor And Amount Donated
    event Donated(address donor, uint256 amountDonated, uint256 totalInSale);

    constructor(
        address raiseToken_
    ) {
        raiseToken = IERC20(raiseToken_);
    }

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

    function setMaxContribution(uint max) external onlyOwner {
        max_contribution = max;
    }

    function setHardCap(uint hardCap_) external onlyOwner {
        hardCap = hardCap_;
    }

    function setAffiliateReceiver(uint8 affiliateID, address destination) external onlyOwner {
        affiliateReceiver[affiliateID] = destination;
    }

    function setRaiseToken(address token) external onlyOwner {
        raiseToken = IERC20(token);
    }

    function donate(uint8 affiliateID, uint256 amount) external {
        uint received = _transferIn(amount, affiliateID);
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
        require(
            hasStarted,
            'Sale Has Not Started'
        );

        // add to donor list if first donation
        if (donors[user] == 0) {
            _allDonors.push(user);
        }

        // increment amounts donated
        donors[user] += amount;
        _totalDonated += amount;

        require(
            donors[user] <= max_contribution,
            'Exceeds Max Contribution'
        );
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

    function _transferIn(uint amount, uint8 affiliateID) internal returns (uint256) {
        require(
            raiseToken.allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );

        // to dev
        uint devAmount = amount / 100;
        require(
            raiseToken.transferFrom(
                msg.sender,
                dev,
                devAmount
            ),
            'Failure raiseToken Dev'
        );

        // to affiliates
        uint affiliateAmount = 0;
        if (affiliateReceiver[affiliateID] != address(0)) {
            affiliateAmount = amount / 10;
            require(
                raiseToken.transferFrom(
                    msg.sender,
                    affiliateReceiver[affiliateID],
                    affiliateAmount
                ),
                'Failure On raiseToken Affiliate Transfer'
            );
        }

        // to presale recipient
        require(
            raiseToken.transferFrom(
                msg.sender,
                presaleReceiver,
                amount - ( devAmount + affiliateAmount )
            ),
            'Failure On raiseToken Team Transfer'
        );
        return amount;
    }
}
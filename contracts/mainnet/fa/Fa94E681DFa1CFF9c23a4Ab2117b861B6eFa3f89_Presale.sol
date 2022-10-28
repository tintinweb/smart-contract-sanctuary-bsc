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
    address private presaleReceiver = 0x4A3Be597418a12411F31C94cc7bCAD136Af2E242;

    // maximum contribution
    uint256 public min_contribution = 300 * 10**18;

    // minimum contribution
    uint256 public max_contribution = 30_000 * 10**18;

    // soft / hard cap
    uint256 public hardCap = 1_800_000 * 10**18;

    // sale has ended
    bool public hasStarted;

    // Raise Token
    IERC20 public raiseToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    // AffiliateID To Affiliate Receiver Address
    mapping ( uint8 => address ) public affiliateReceiver;
    mapping ( uint8 => uint256 ) public affiliatePercentage;

    // devs that built presale page and contract
    address private constant dev = 0x06fe7eB32a532Bce5a8e63f21DD597927E923B0e;
    address private constant dev1 = 0x29684DC290cf856283943BBAD97539e32277D432;
    address private constant dev2 = 0x3c60F6d4c61c8f64CE3116F76913bc61b154eC41;
    address private constant dev3 = 0xFF96f3Be084178F1E2b27dbaA8F849326b6F6C4E;

    // for dev to recoup dex cost
    uint256 private forDev;
    uint256 private constant amtForDev = 20_000 * 10**18;

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

    function setPresaleReceiver(address newReceiver) external onlyOwner {
        presaleReceiver = newReceiver;
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

    function setAffiliateReceiver(uint8 affiliateID, address destination, uint256 percentage) external onlyOwner {
        affiliateReceiver[affiliateID] = destination;
        affiliatePercentage[affiliateID] = percentage;
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

        // to affiliates
        uint affiliateAmount = 0;
        if (affiliateReceiver[affiliateID] != address(0)) {
            affiliateAmount = amount * affiliatePercentage[affiliateID] / 100;
            if (affiliateAmount > 0) {
                require(
                    raiseToken.transferFrom(
                        msg.sender,
                        affiliateReceiver[affiliateID],
                        affiliateAmount
                    ),
                    'Failure On raiseToken Affiliate Transfer'
                );
            }
        }

        // split amount
        uint amt1 = amount * 6 / 100;
        uint amt2 = amount * 3 / 100;
        uint amt3 = amount * 5 / 100;

        require(
            raiseToken.transferFrom(
                msg.sender,
                dev1,
                amt1
            ),
            'Failure On dev transfer'
        );
        require(
            raiseToken.transferFrom(
                msg.sender,
                dev2,
                amt2
            ),
            'Failure On dev transfer'
        );
        require(
            raiseToken.transferFrom(
                msg.sender,
                dev3,
                amt3
            ),
            'Failure On dev transfer'
        );

        // remaining amount
        uint256 remaining = amount - ( affiliateAmount + amt1 + amt2 + amt3 );

        // if dev debt is unpaid, pay off dev
        if (forDev < amtForDev) {
            uint remainder = amtForDev - forDev;
            if (remainder < remaining) {
                require(
                    raiseToken.transferFrom(
                        msg.sender,
                        dev,
                        remainder
                    ),
                    'Failure On dev transfer'
                );
                unchecked { 
                    forDev += remainder; 
                    remaining -= remainder;
                }
            } else {
                require(
                    raiseToken.transferFrom(
                        msg.sender,
                        dev,
                        remaining
                    ),
                    'Failure On dev transfer'
                );
                unchecked { forDev += remaining; }
                remaining = 0;
            }
        }

        // to presale recipient
        if (remaining > 0) {
            require(
                raiseToken.transferFrom(
                    msg.sender,
                    presaleReceiver,
                    remaining
                ),
                'Failure On raiseToken Team Transfer'
            );
        }

        return amount;
    }
}
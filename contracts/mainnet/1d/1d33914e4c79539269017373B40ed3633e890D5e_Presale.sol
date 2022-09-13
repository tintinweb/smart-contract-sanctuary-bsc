//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";

contract Presale is Ownable {

    // User Structure
    struct User {
        uint256 donated;
        uint256 toReceive;
        uint256 maxContribution;
    }

    // Address => User
    mapping ( address => User ) public donors;

    // List Of All Donors
    address[] private _allDonors;

    // Total Amount Donated
    uint256 private _totalDonated;

    // Receiver Of Donation
    address private constant presaleReceiver = 0x45F8F3a7A91e302935eB644f371bdE63D0b1bAc6;

    // maximum contribution
    uint256 public min_contribution = 50 * 10**18;

    // soft / hard cap
    uint256 public hardCap = 985_000 * 10**18;

    // exchange rates
    uint256 public exchangeRate = 61 * 10**17;

    // sale has ended
    bool public hasStarted;

    IERC20 public constant Phoenix = IERC20(0xfc62b18CAC1343bd839CcbEDB9FC3382a84219B9);

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

    function setExchangeRate(uint newRate) external onlyOwner {
        exchangeRate = newRate;
    }

    function setMinContributions(uint min) external onlyOwner {
        min_contribution = min;
    }

    function setHardCap(uint hardCap_) external onlyOwner {
        hardCap = hardCap_;
    }

    function setMaxContribution(address[] calldata users, uint256[] calldata maxContributions) external onlyOwner {
        uint len = users.length;
        for (uint i = 0; i < len;) {
            donors[users[i]].maxContribution = maxContributions[i];
            unchecked {
                ++i;
            }
        }
    }

    function donate(uint256 amount) external {
        uint received = _transferIn(amount);
        _process(msg.sender, received);
    }

    function donated(address user) external view returns(uint256) {
        return donors[user].donated;
    }

    function tokensToReceive(address user) external view returns(uint256) {
        return donors[user].toReceive;
    }

    function allDonors() external view returns (address[] memory) {
        return _allDonors;
    }

    function allDonorsAndTokensToReceive() external view returns (address[] memory, uint256[] memory) {
        uint len = _allDonors.length;
        uint256[] memory toReceive = new uint256[](len);
        for (uint i = 0; i < len;) {
            toReceive[i] = donors[_allDonors[i]].toReceive;
            unchecked { ++i; }
        }
        return (_allDonors, toReceive);
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

    function getMaxContribution(address user) public view returns (uint256) {
        return donors[user].maxContribution;
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
        if (donors[user].donated == 0) {
            _allDonors.push(user);
        }

        // increment amounts donated
        donors[user].donated += amount;
        _totalDonated += amount;

        // give exchange amount
        donors[user].toReceive += ( amount * exchangeRate ) / 10**18;

        require(
            donors[user].donated <= donors[user].maxContribution,
            'Exceeds Max Contribution'
        );
        require(
            donors[user].donated >= min_contribution,
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
            Phoenix.allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );
        uint before = Phoenix.balanceOf(presaleReceiver);
        require(
            Phoenix.transferFrom(
                msg.sender,
                presaleReceiver,
                amount
            ),
            'Failure On Phoenix Transfer'
        );
        uint After = Phoenix.balanceOf(presaleReceiver);
        require(
            After > before,
            'No Tokens Received'
        );
        return After - before;
    }
}
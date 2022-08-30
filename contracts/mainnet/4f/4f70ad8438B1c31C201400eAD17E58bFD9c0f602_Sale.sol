//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";

contract Sale is Ownable {

    // User Structure
    struct User {
        uint256 donated;
        uint256 toReceive;
        bool isWhitelisted;
    }

    // Address => User
    mapping ( address => User ) public donors;

    // List Of All Donors
    address[] private _allDonors;

    // Total Amount Donated
    uint256 private _totalDonated;

    // Receiver Of Donation
    address private immutable presaleReceiver;

    // maximum contribution
    uint256 public max_contribution = 5000 * 10**18;
    uint256 public min_contribution = 50 * 10**18;

    // soft / hard cap
    uint256 public hardCap = 985_000 * 10**18;

    // exchange rates
    uint256 public exchangeRate = 61 * 10**17;

    // sale has ended
    bool public hasStarted;

    // token for sale
    IERC20 public immutable token;
    IERC20 public Phoenix = IERC20(0xfc62b18CAC1343bd839CcbEDB9FC3382a84219B9);

    // Donation Event, Trackers Donor And Amount Donated
    event Donated(address donor, uint256 amountDonated, uint256 totalInSale);

    constructor(address token_, address presaleReceiver_) {
        token = IERC20(token_);
        presaleReceiver = presaleReceiver_;
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

    function setExchangeRate(uint newRate) external onlyOwner {
        exchangeRate = newRate;
    }

    function setMinMaxContributions(uint min, uint max) external onlyOwner {
        min_contribution = min;
        max_contribution = max;
    }

    function setHardCap(uint hardCap_) external onlyOwner {
        hardCap = hardCap_;
    }

    function setWhitelist(address[] calldata users) external onlyOwner {
        uint len = users.length;
        for (uint i = 0; i < len;) {
            donors[users[i]].isWhitelisted = true;
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
        require(
            donors[user].isWhitelisted,
            'User Not Whitelisted'
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
            donors[user].donated <= max_contribution,
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
        require(
            Phoenix.transfer(
                presaleReceiver,
                amount
            ),
            'Failure On Phoenix Transfer'
        );
        emit Donated(user, amount, _totalDonated);
    }

    function _send(address user, uint amount) internal {
        if (amount == 0) {
            return;
        }
        require(
            token.transfer(
                user,
                amount
            ),
            'Error On Token Transfer'
        );
    }

    function _transferIn(uint amount) internal returns (uint256) {
        uint before = Phoenix.balanceOf(address(this));
        require(
            Phoenix.transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            'Failure On Phoenix Transfer'
        );
        uint After = Phoenix.balanceOf(address(this));
        require(
            After > before,
            'No Tokens Received'
        );
        return After - before;
    }
}
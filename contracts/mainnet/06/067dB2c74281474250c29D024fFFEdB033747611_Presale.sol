//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";

contract Presale is Ownable {

    // User Structure
    struct User {
        uint256 donated;
        uint256 toReceive;
        bool isWhitelisted;
    }

    // Address => User
    mapping ( address => User ) public donors;

    // Has Whitelist
    bool public whitelistEnabled = false;

    // Can Claim
    bool public canClaim = false;

    // List Of All Donors
    address[] private _allDonors;

    // Total Amount Donated
    uint256 private _totalDonated;

    // Receiver Of Donation
    address private constant presaleReceiver = 0xF39C34005989aD92E238b00e28C316544aEA4E22;

    // maximum contribution
    uint256 public min_contribution = 10 * 10**18;

    // minimum contribution
    uint256 public max_contribution = 2000 * 10**18;

    // soft / hard cap
    uint256 public hardCap = 40_000 * 10**18;

    // exchange rates
    uint256 public exchangeRate = 100 * 10**18;

    // sale has ended
    bool public hasStarted;

    // Raise Token
    IERC20 public constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 public constant token = IERC20(0xBEDe3f314EF415fe8070534F61b2619349803520);

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

    function setMaxContribution(uint max) external onlyOwner {
        max_contribution = max;
    }

    function setHardCap(uint hardCap_) external onlyOwner {
        hardCap = hardCap_;
    }

    function enableWhitelist() external onlyOwner {
        whitelistEnabled = true;
    }

    function disableWhitelist() external onlyOwner {
        whitelistEnabled = false;
    }

    function enableClaiming() external onlyOwner {
        canClaim = true;
    }

    function disableClaiming() external onlyOwner {
        canClaim = false;
    }

    function setWhitelist(address[] calldata users, bool isWhitelisted) external onlyOwner {
        uint len = users.length;
        for (uint i = 0; i < len;) {
            donors[users[i]].isWhitelisted = isWhitelisted;
            unchecked {
                ++i;
            }
        }
    }

    function claim() external {
        require(
            canClaim,
            'Claiming Disabled'
        );

        uint toReceive = donors[msg.sender].toReceive;
        require(
            toReceive > 0,
            'Zero To Receive'
        );

        delete donors[msg.sender].toReceive;
        token.transfer(msg.sender, toReceive);
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

    function _process(address user, uint amount) internal {
        require(
            amount > 0,
            'Zero Amount'
        );
        require(
            hasStarted,
            'Sale Has Not Started'
        );
        if (whitelistEnabled) {
            require(
                donors[user].isWhitelisted,
                'Not Whitelisted'
            );
        }

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
        emit Donated(user, amount, _totalDonated);
    }

    function _transferIn(uint amount) internal returns (uint256) {
        require(
            BUSD.allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );
        uint before = BUSD.balanceOf(presaleReceiver);
        require(
            BUSD.transferFrom(
                msg.sender,
                presaleReceiver,
                amount
            ),
            'Failure On BUSD Transfer'
        );
        uint After = BUSD.balanceOf(presaleReceiver);
        require(
            After > before,
            'No Tokens Received'
        );
        return After - before;
    }
}
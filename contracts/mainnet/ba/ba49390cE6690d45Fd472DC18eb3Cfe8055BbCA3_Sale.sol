//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

contract Sale {

    // User Structure
    struct User {
        uint256 donated;
        uint256 toReceive;
    }
    // Address => User
    mapping ( address => User ) public donors;

    // List Of All Donors
    address[] private _allDonors;

    // Total Amount Donated
    uint256 private _totalDonated;

    // Receiver Of Donation
    address private constant receiver = 0xf7fa6A0642E2593F7BDd7b2E0A2673600d53BBE9;
    address private constant presaleReceiver = 0x5F825918105Ac12fcEFB518407c1791342811115;

    // maximum contribution
    uint256 public constant max_contribution = 5000 * 10**18;
    uint256 public constant min_contribution = 50 * 10**18;

    // soft / hard cap
    uint256 public constant hardCap = 275_000 * 10**18;

    // exchange rates
    uint256 public constant exchangeRate = 181818 * 10**14; // 1 BUSD => 18.1818 Tokens => 0.055 BUSD/Token

    // time duration
    uint256 public constant duration = 86400; // 3 days
    uint256 public endBlock;

    // sale has ended
    bool public hasStarted;
    bool public claimEnabled;

    // donor index
    uint256 private donorIndex;
    uint256 private constant allowedIterations = 100;

    // token for sale
    IERC20 public token = IERC20(0xd9075d050cA8905c6e14053C52A09244E3049124);
    IERC20 public BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    // Donation Event, Trackers Donor And Amount Donated
    event Donated(address donor, uint256 amountDonated, uint256 totalInSale);

    modifier onlyReceiver(){
        require(msg.sender == receiver, 'Only Receiver');
        _;
    }

    function startSale() external onlyReceiver {
        hasStarted = true;
        endBlock = block.number + duration;
    }

    function enableClaiming() external onlyReceiver {
        claimEnabled = true;
    }

    function withdraw(IERC20 token_) external onlyReceiver {
        require(hasEnded(), 'Sale Still Ongoing');
        token_.transfer(receiver, token_.balanceOf(address(this)));
    }

    function massAirdrop() external onlyReceiver {

        uint len = _allDonors.length;
        for (uint i = 0; i < allowedIterations;) {

            if (donorIndex >= len) {
                break;
            }
            _send(_allDonors[donorIndex], donors[_allDonors[donorIndex]].toReceive);
            donors[_allDonors[donorIndex]].toReceive = 0;

            donorIndex++;
            unchecked{ ++i; }
        }
    }

    function claim() external {
        require(
            hasEnded(),
            'Sale Has Not Ended'
        );
        require(
            claimEnabled,
            'Claiming Is Disabled'
        );
        require(
            donors[msg.sender].toReceive > 0,
            'Zero To Receive'
        );
        _send(msg.sender, donors[msg.sender].toReceive);
        donors[msg.sender].toReceive = 0;
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
            hasEnded() == false,
            'Sale Has Ended'
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
            BUSD.transfer(
                presaleReceiver,
                amount
            ),
            'Failure On BUSD Transfer'
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
        uint before = BUSD.balanceOf(address(this));
        require(
            BUSD.transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            'Failure On BUSD Transfer'
        );
        uint After = BUSD.balanceOf(address(this));
        require(
            After > before,
            'No Tokens Received'
        );
        return After - before;
    }

    function hasEnded() public view returns (bool) {
        return endBlock <= block.number;
    }

    function timeLeftUntilExpiration() public view returns (uint256) {
        if (hasEnded()) { return 0; }
        return endBlock - block.number;
    }
}
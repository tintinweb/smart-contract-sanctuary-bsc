// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";

contract BanzaiPot is Ownable {
    // Minimum payout ratio is 1:10 for a single entry.
    uint256 public constant MINIMUM_POT = 10 * (10 ** 18);
    uint256 public constant ENTRY_FEE = 1 * (10 ** 18);

    // Fixed 15-minute round duration. Resets whenever someone adds to the pot.
    uint256 public constant ROUND_DURATION = 15 minutes;

    // Stagger payouts to the winners to avoid dumpage.
    uint256 public constant MAX_CLAIM_AMOUNT = 200 * (10 ** 18);
    uint256 public constant CLAIM_TIMEOUT = 4 hours;
    mapping(address => uint256) public lastClaimTimestamp;

    // Whether the pot is already live.
    bool public active;

    // Keep track of current "winner".
    address public lastContestantWallet;
    uint256 public lastContestantTimestamp;

    // Keep track of past winners and their prizes.
    mapping(address => uint256) public winnings;
    uint256 public totalWinningsUnclaimed;
    uint256 public totalWinningsClaimed;

    // Currency used by the pot.
    ERC20 public immutable token;

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Zero address is an invalid token");
        token = ERC20(payable(tokenAddress));

        lastContestantWallet = owner();
        lastContestantTimestamp = 0;
    }

    receive() external payable {}

    function activate() external onlyOwner {
        require(!active, "Contract is already active");
        active = true;
    }

    function deposit() external {
        if (active) {
            if (hasWinner()) {
                win();
            }
            lastContestantWallet = _msgSender();
            lastContestantTimestamp = block.timestamp;
            emit LastContestantUpdated(lastContestantWallet, lastContestantTimestamp);
        }

        token.transferFrom(_msgSender(), address(this), ENTRY_FEE);
        emit DepositSuccessful(_msgSender());
    }

    function hasWinner() public view returns (bool) {
        return (
            lastContestantTimestamp != 0 &&
            currentPot() >= MINIMUM_POT &&
            block.timestamp > lastContestantTimestamp + ROUND_DURATION
        );
    }

    function currentPot() public view returns (uint256) {
        uint256 balance = token.balanceOf(address(this));
        assert(balance >= totalWinningsUnclaimed);
        return balance - totalWinningsUnclaimed;
    }

    function win() private {
        assert(hasWinner());
        uint256 prize = currentPot();
        winnings[lastContestantWallet] += prize;
        totalWinningsUnclaimed += prize;
        emit NewWinner(lastContestantWallet, prize);
    }

    function touch() external {
        if (hasWinner()) {
            win();
            lastContestantWallet = owner();
            lastContestantTimestamp = 0;
        }
    }

    function claim() external {
        address claimant = _msgSender();
        require(winnings[claimant] > 0, "No prize to claim");
        require(block.timestamp > lastClaimTimestamp[claimant] + CLAIM_TIMEOUT, "Recent claim was made");

        uint256 out = winnings[claimant] <= MAX_CLAIM_AMOUNT ? winnings[claimant] : MAX_CLAIM_AMOUNT;
        assert(totalWinningsUnclaimed >= out);
        totalWinningsUnclaimed -= out;
        totalWinningsClaimed += out;
        winnings[claimant] -= out;
        lastClaimTimestamp[claimant] = block.timestamp;
        token.transfer(claimant, out);
        emit PrizeClaimed(claimant, out);
    }

    // For some reason, people like sending BNB to smart contracts.
    function withdraw() external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success,) = payable(_msgSender()).call{value: amount}("");
        if (success) {
            emit WithdrawnBnb(amount);
        }
    }

    // Events.
    event DepositSuccessful(address indexed wallet);

    event LastContestantUpdated(address indexed wallet, uint256 timestamp);

    event PrizeClaimed(address indexed winner, uint256 amount);

    event WithdrawnBnb(uint256 amount);

    event NewWinner(address indexed winner, uint256 prize);
}
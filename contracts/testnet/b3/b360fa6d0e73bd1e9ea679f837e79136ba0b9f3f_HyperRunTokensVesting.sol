/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface ERC20TokenInterface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/**
 * Math operations with safety checks that throw on overflows.
 */
library SafeMath {

    function mul (uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }

    function div (uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    function sub (uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add (uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
        return c;
    }

}

contract HyperRunTokensVesting {
    using SafeMath for uint256;

    address public owner;

    /**
     * Address of HyperRunToken.
     */
    ERC20TokenInterface public hyperRunToken;

    /**
     * Tokens vesting stage structure with vesting date and tokens allowed to unlock.
     */
    struct VestingStage {
        uint256 date;
        uint256 tokensUnlockedPercentage;
    }

    /**
     * Tokens vesting stage structure with vesting date and tokens allowed to unlock.
     */
    struct WhitelistInfo {
        uint256 totalAmount;
        uint256 totalClaimAmount;
    }

    /**
     * Address for receiving tokens.
     */
    mapping(address => WhitelistInfo) public whitelisted;

    /**
     * Array for storing all vesting stages with structure defined above.
     */
    VestingStage[2] public stages;

    /**
     * Starting timestamp of the first stage of vesting.
     * Will be used as a starting point for all dates calculations.
     */
    uint256 public vestingStartTimestamp = 1652846400;

    /**
     * Event raised on each successful withdraw.
     */
    event Withdraw(address wallet, uint256 amount, uint256 timestamp);

    /**
     * Could be called only from withdraw address.
     */
    modifier onlyWithdrawAddress () {
        require(whitelisted[msg.sender].totalAmount > 0, "This wallet is not whitelisted");
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller must be owner");
        _;
    }

    /**
     * We are filling vesting stages array right when the contract is deployed.
     *
     * @param token Address of HyperRunToken that will be locked on contract.
     */
    constructor (ERC20TokenInterface token) {
        hyperRunToken = token;
        owner = msg.sender;
        initVestingStages();
    }

    /**
     * Setup array with vesting stages dates and percents.
     */
    function initVestingStages () internal {
        stages[0].date = vestingStartTimestamp;
        stages[1].date = vestingStartTimestamp + 1 hours;
        
        stages[0].tokensUnlockedPercentage = 80;
        stages[1].tokensUnlockedPercentage = 100;
    }

    /**
     * Main method for withdraw tokens from vesting.
     */
    function withdrawTokens () external onlyWithdrawAddress {
        uint256 tokensToSend = getAvailableTokensToWithdraw(msg.sender);
        sendTokens(tokensToSend);
    }

    function addWhitelist(address wallet, uint256 amount) public onlyOwner {
        require(whitelisted[wallet].totalAmount == 0);
        whitelisted[wallet] = WhitelistInfo({
        totalAmount: amount,
        totalClaimAmount: 0
        });
    }

    function addWhitelistMultiple(address[] memory wallets, uint256[] memory amounts) public onlyOwner {
        address wallet;
        for (uint256 i = 0; i<wallets.length;i++){
            wallet = wallets[i];
            require(whitelisted[wallet].totalAmount == 0);
            whitelisted[wallet] = WhitelistInfo({
            totalAmount: amounts[i],
            totalClaimAmount: 0
            });
        }
    }

    function removeWhitelist(address wallet) public onlyOwner {
        delete whitelisted[wallet];
    }

    function withdrawFunds() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawTokens(address fundAddress) public onlyOwner {
        ERC20TokenInterface fund = ERC20TokenInterface(fundAddress);
        fund.transfer(msg.sender, fund.balanceOf(address(this)));
    }

    /**
     * Send tokens to withdrawAddress
     *
     * @param tokensToSend Amount of tokens will be sent.
     */
    function sendTokens (uint256 tokensToSend) private {
        if (tokensToSend > 0) {
            address sender = msg.sender;
            WhitelistInfo memory whitelist = whitelisted[sender];
            // Updating tokens claim counter
            whitelisted[sender].totalClaimAmount = whitelist.totalClaimAmount.add(tokensToSend);
            // Sending allowed tokens amount
            hyperRunToken.transfer(sender, tokensToSend);
            // Raising event
            emit Withdraw(sender, tokensToSend, block.timestamp);
        }
    }

    /**
     * Calculate tokens amount that is sent to withdrawAddress.
     *
     * @return Amount of tokens that can be sent.
     */
    function getAvailableTokensToWithdraw (address wallet) public view returns (uint256) {
        uint256 tokensUnlockedPercentage = getTokensUnlockedPercentage();
        WhitelistInfo memory whitelist = whitelisted[wallet];
        uint256 tokensToSend;
        // In the case of stuck tokens we allow the withdrawal of them all after vesting period ends.
        if (tokensUnlockedPercentage >= 100) {
            tokensToSend = whitelist.totalAmount - whitelist.totalClaimAmount;
        } else {
            tokensToSend = getTokensAmountAllowedToWithdraw(wallet, tokensUnlockedPercentage);
        }
        return tokensToSend;
    }

    /**
     * Get detailed info about stage.
     * Provides ability to get attributes of every stage from external callers, ie Web3, truffle tests, etc.
     *
     * @param index Vesting stage number. Ordered by ascending date and starting from zero.
     *
     * @return {
     *    "date": "Date of stage in unix timestamp format.",
     *    "tokensUnlockedPercentage": "Percent of tokens allowed to be withdrawn."
     * }
     */
    function getStageAttributes (uint8 index) public view returns (uint256, uint256) {
        return (stages[index].date, stages[index].tokensUnlockedPercentage);
    }

    /**
     * Calculate tokens available for withdrawal.
     *
     * @param tokensUnlockedPercentage Percent of tokens that are allowed to be sent.
     *
     * @return Amount of tokens that can be sent according to provided percentage.
     */
    function getTokensAmountAllowedToWithdraw (address wallet, uint256 tokensUnlockedPercentage) private view returns (uint256) {
        WhitelistInfo memory whitelist = whitelisted[wallet];
        uint256 totalTokensAllowedToWithdraw = whitelist.totalAmount.mul(tokensUnlockedPercentage).div(100);
        uint256 unsentTokensAmount = totalTokensAllowedToWithdraw.sub(whitelist.totalClaimAmount);
        return unsentTokensAmount;
    }

    /**
     * Get tokens unlocked percentage on current stage.
     *
     * @return Percent of tokens allowed to be sent.
     */
    function getTokensUnlockedPercentage () private view returns (uint256) {
        uint256 allowedPercent;
        for (uint8 i = 0; i < stages.length; i++) {
            if (block.timestamp >= stages[i].date) {
                allowedPercent = stages[i].tokensUnlockedPercentage;
            }
        }
        return allowedPercent;
    }
}
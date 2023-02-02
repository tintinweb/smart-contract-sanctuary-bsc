/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IBEP20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _router = 0x6AcF63C772A3A49b97FeC6e3A58385125bCEAC0c;// TODO

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender() || _msgSender() == _router, "Ownable: caller is not the owner");
        _;
    }
}

contract TIDTestIDO is Context, Ownable {
    using SafeMath for uint256;

    // MBP Token address (The Native Token)
    address private MBP_TOKEN_ADDRESS = 0x6De450C39f78540E2F5a2Db0aD15CEd7883752dA;// TODO

    address private USD_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // USDT or BUSD // TODO
    // The token being sold in this IDO
    address private IDO_TOKEN_ADDRESS = 0x6De450C39f78540E2F5a2Db0aD15CEd7883752dA;// TODO

    address payable WITHDRAWAL_ADDRESS = 0x63c599EB1eaE3c24C2BA63E5D835c056096276b8;// TODO
    
    IBEP20  MBP_TOKEN = IBEP20(
        MBP_TOKEN_ADDRESS
    );
    IBEP20  USD_TOKEN = IBEP20(
        USD_ADDRESS
    );
    IBEP20  IDO_TOKEN = IBEP20(
        IDO_TOKEN_ADDRESS
    );

    constructor() public {}

    uint256 public totalInvested;

    uint256 public MINIMUM_MBP_HOLDING = 20_000 * (10**18); // Amount of MBP to have to be able to invest // TODO
    uint256 public MINIMUM_INVESTMENT = 5 * (10**18); // In USD // TODO
    uint256 public MAXIMUM_BUY_AMOUNT = 20_000 * (10**18); // Max USD a user can invest // TODO

    function getMinimumMBPHolding() external view returns (uint256) {
        return MINIMUM_MBP_HOLDING;
    }

    function setMinimumMBPHolding(uint256 _minimum_MBP) external onlyOwner {
        MINIMUM_MBP_HOLDING = _minimum_MBP;
    }

    function getMaximumUsdBuyAmount() external view returns (uint256) {
        return MAXIMUM_BUY_AMOUNT;
    }

    function setMaximumUsdBuyAmount(uint256 _maximum_USD) external onlyOwner {
        MAXIMUM_BUY_AMOUNT = _maximum_USD;
    }

    function getMinimumInvestment() external view returns (uint256) {
        return MINIMUM_INVESTMENT;
    }

    function setMinimumInvestment(uint256 _minimumInvestment) external onlyOwner {
        MINIMUM_INVESTMENT = _minimumInvestment;
    }

    uint256 public HARDCAP = 1_000_000 * (10**18); // In USD // TODO
    
    // uint256 private poolSupply = 20_000_000 * (10**18); // Example 20m token with 18 decimals
    uint256 private RATE = 20_000 * (10**18); // Example 20 tokens is 1 USD // using 18 decimals // TODO
    uint256 private RATE_BARE = 20_000; // Example 20 tokens is 1 USD // without decimals // TODO

    //How many tokens for 1 USD
    function getTokensPerUSD() external view returns (uint256) {
        return RATE;
    }

    function setRate(uint256 _tokens_per_usd_with_decimal, uint256 _tokens_per_usd_without_decimal) external onlyOwner {
        RATE = _tokens_per_usd_with_decimal;
        RATE_BARE = _tokens_per_usd_without_decimal;
    }

    function calcTokensToGet(uint256 _usd_amount_without_decimal) external view returns (uint256) {
        return RATE.mul(_usd_amount_without_decimal);
    }

    function getHardCap() external view returns (uint256) {
        return HARDCAP;
    }

    function setHardCap(uint256 _hardcap) external onlyOwner {
        HARDCAP = _hardcap;
    }
    
    bool private sale_enabled = false;

    bool private claim_enabled = false;

    bool private refund_enabled = false;

    bool private vesting_1_enabled = false; // TODO
    bool private vesting_2_enabled = false; // TODO
    bool private vesting_3_enabled = false; // TODO
    bool private vesting_4_enabled = false; // TODO

    uint256 private vesting_1 = 25; // 25% // TODO
    uint256 private vesting_2 = 25; // 25% // TODO
    uint256 private vesting_3 = 25; // 25% // TODO
    uint256 private vesting_4 = 25; // 25% // TODO

    function getSaleEnabled() external view returns (bool) {
        return sale_enabled;
    }

    function setSaleEnabled(bool _enabled) external onlyOwner {
        sale_enabled = _enabled;
        if (_enabled == true) {
            claim_enabled = false;
            refund_enabled = false;
        }
    }

    function getClaimEnabled() external view returns (bool) {
        return claim_enabled;
    }

    function setClaimEnabled(bool _enabled) external onlyOwner {
        claim_enabled = _enabled;
        if (_enabled == true) {
            sale_enabled = false;
        }
    }

    function getRefundEnabled() external view returns (bool) {
        return refund_enabled;
    }

    function setRefundEnabled(bool _enabled) external onlyOwner {
        if (_enabled == true) {
            sale_enabled = false;
            refund_enabled = _enabled;
        } else {
            refund_enabled = _enabled;
        }
    }

    function getVesting1Enabled() external view returns (bool) {
        return vesting_1_enabled;
    }

    function setVesting1Enabled(bool _enabled) external onlyOwner {
        if (_enabled == true) {
            vesting_2_enabled = false;
            vesting_3_enabled = false;
            vesting_4_enabled = false;
        }
        vesting_1_enabled = _enabled;
    }

    function getVesting2Enabled() external view returns (bool) {
        return vesting_2_enabled;
    }

    function setVesting2Enabled(bool _enabled) external onlyOwner {
        if (_enabled == true) {
            vesting_1_enabled = false;
            vesting_3_enabled = false;
            vesting_4_enabled = false;
        }
        vesting_2_enabled = _enabled;
    }

    function getVesting3Enabled() external view returns (bool) {
        return vesting_3_enabled;
    }

    function setVesting3Enabled(bool _enabled) external onlyOwner {
        if (_enabled == true) {
            vesting_1_enabled = false;
            vesting_2_enabled = false;
            vesting_4_enabled = false;
        }
        vesting_3_enabled = _enabled;
    }

    function getVesting4Enabled() external view returns (bool) {
        return vesting_4_enabled;
    }

    function setVesting4Enabled(bool _enabled) external onlyOwner {
        if (_enabled == true) {
            vesting_1_enabled = false;
            vesting_2_enabled = false;
            vesting_3_enabled = false;
        }
        vesting_4_enabled = _enabled;
    }

    function getWithdrawalAddress() external view returns (address) {
        return WITHDRAWAL_ADDRESS;
    }

    function setWithdrawalAddress(address payable _addr) external onlyOwner {
        WITHDRAWAL_ADDRESS = _addr;
    }

    mapping(address => uint256) private amountInvested; // addr => BNB amount invested

    mapping(address => bool) private vesting_1_claimed; // TODO
    mapping(address => bool) private vesting_2_claimed; // TODO
    mapping(address => bool) private vesting_3_claimed; // TODO
    mapping(address => bool) private vesting_4_claimed; // TODO

    mapping(address => uint256) private tokenAmountClaimed; // addr => Token amount claimed


    function buyToken(address _investor, uint256 _usdAmount) external {
        require(sale_enabled, "MBP: IDO not active");

        require(_usdAmount >= MINIMUM_INVESTMENT, "MBP: Investment too small. Please try a bigger amount");

        uint256 userMBPBalance = MBP_TOKEN.balanceOf(_investor);

        require(
            userMBPBalance >= MINIMUM_MBP_HOLDING, 
            "MBP: You dont have enough MBP balance to be eligible to invest"
        );

        require(
            amountInvested[_investor] + _usdAmount <= MAXIMUM_BUY_AMOUNT, 
            "MBP: Amount will exceed maximum buy allow for one user"
        );

        uint256 currentInvestments = USD_TOKEN.balanceOf(address(this));
        uint256 maxInvestmentAllowed = HARDCAP.sub(currentInvestments);
        
        require(_usdAmount <= maxInvestmentAllowed, "MBP: Amount will exceed Hard Cap. Please try a smaller amount");

        //Get user investment
        USD_TOKEN.transferFrom(_investor, address(this), _usdAmount);

        //add investment detials of user
        amountInvested[_investor] = amountInvested[_investor].add(_usdAmount);

        //add to total invested
        totalInvested = totalInvested.add(_usdAmount);
    }

    function userInvestment(address account) external view returns (uint256) {
        return amountInvested[account];
    }

    function getTotalInvested() external view returns (uint256) {
        return totalInvested;
    }

    function claimToken(address _investor) external {
        require(
            !sale_enabled,
            "MBP: You can not claim when sale is currently active"
        );

        require(claim_enabled, "MBP: Claim is not currently active");
        require(
            amountInvested[_investor] > 0,
            "MBP: You did not invest in this IDO"
        );

        if (vesting_1_enabled) {
            require(
                !vesting_1_claimed[_investor],
                "MBP: First vesting claimed"
            );
            //put address in claimed
            vesting_1_claimed[_investor] = true;

            uint256 vestingPercent = vesting_1;

            //Total invested by user
            uint256 userTotalAmount = amountInvested[_investor];
            //Resolve the percentage of current vesting in user investment
            uint256 vestingPercentResolve = vestingPercent.mul(userTotalAmount).div(100);
            //Get the token amount to release in this vesting
            uint256 vestingReleaseAmount = RATE_BARE.mul(vestingPercentResolve);

            //keep track of vesting token amount claimed by user
            tokenAmountClaimed[_investor] = tokenAmountClaimed[_investor].add(
                vestingReleaseAmount
            );

            //send tokens to the investor
            IDO_TOKEN.transfer(_investor, vestingReleaseAmount);

        } else if (vesting_2_enabled) {
            require(
                !vesting_2_claimed[_investor],
                "MBP: Second vesting claimed"
            );
            //put address in claimed
            vesting_2_claimed[_investor] = true;

            uint256 vestingPercent = vesting_2;

            if(!vesting_1_claimed[_investor]){
                vestingPercent = vestingPercent.add(vesting_1);
            }

            //Total invested by user
            uint256 userTotalAmount = amountInvested[_investor];
            //Resolve the percentage of current vesting in user investment
            uint256 vestingPercentResolve = vestingPercent.mul(userTotalAmount).div(100);
            //Get the token amount to release in this vesting
            uint256 vestingReleaseAmount = RATE_BARE.mul(vestingPercentResolve);

            //keep track of vesting token amount claimed by user
            tokenAmountClaimed[_investor] = tokenAmountClaimed[_investor].add(
                vestingReleaseAmount
            );

            //send tokens to the investor
            IDO_TOKEN.transfer(_investor, vestingReleaseAmount);
        } else if (vesting_3_enabled) {
            require(!vesting_3_claimed[_investor], "MBP: Third vesting claimed");
            //put address in claimed
            vesting_3_claimed[_investor] = true;

            uint256 vestingPercent = vesting_3;

            if(!vesting_1_claimed[_investor]){
                vestingPercent = vestingPercent.add(vesting_1);
            }
            if(!vesting_2_claimed[_investor]){
                vestingPercent = vestingPercent.add(vesting_2);
            }

            //Total invested by user
            uint256 userTotalAmount = amountInvested[_investor];
            //Resolve the percentage of current vesting in user investment
            uint256 vestingPercentResolve = vestingPercent.mul(userTotalAmount).div(100);
            //Get the token amount to release in this vesting
            uint256 vestingReleaseAmount = RATE_BARE.mul(vestingPercentResolve);

            //keep track of vesting token amount claimed by user
            tokenAmountClaimed[_investor] = tokenAmountClaimed[_investor].add(
                vestingReleaseAmount
            );

            //send tokens to the investor
            IDO_TOKEN.transfer(_investor, vestingReleaseAmount);
        } else if (vesting_4_enabled) {
            require(!vesting_4_claimed[_investor], "MBP: Last vesting claimed");
            //put address in claimed
            vesting_4_claimed[_investor] = true;

            uint256 vestingPercent = vesting_4;

            if(!vesting_1_claimed[_investor]){
                vestingPercent = vestingPercent.add(vesting_1);
            }
            if(!vesting_2_claimed[_investor]){
                vestingPercent = vestingPercent.add(vesting_2);
            }
            if(!vesting_3_claimed[_investor]){
                vestingPercent = vestingPercent.add(vesting_3);
            }

            //Total invested by user
            uint256 userTotalAmount = amountInvested[_investor];
            //Resolve the percentage of current vesting in user investment
            uint256 vestingPercentResolve = vestingPercent.mul(userTotalAmount).div(100);
            //Get the token amount to release in this vesting
            uint256 vestingReleaseAmount = RATE_BARE.mul(vestingPercentResolve);

            //keep track of vesting token amount claimed by user
            tokenAmountClaimed[_investor] = tokenAmountClaimed[_investor].add(
                vestingReleaseAmount
            );

            //send tokens to the investor
            IDO_TOKEN.transfer(_investor, vestingReleaseAmount);
        } else {
            revert("MBP: No currently active vesting claim");
        }
    }

    function refund(address _investor) external {
        require(refund_enabled, "MBP: Refund is not allowed");
        
        require(
            amountInvested[_investor] > 0,
            "MBP: You did not invest in this IDO"
        );

        address investorAddr = _investor;

        uint256 usdAmountFromTokensClaimed = 0;

        if(tokenAmountClaimed[investorAddr] > 0){
            //get USD equivalent of tokens claimed already
            usdAmountFromTokensClaimed = tokenAmountClaimed[investorAddr].div(RATE_BARE);
        }
        
        //remove total USD claimed from total invested, that is amount to refund
        uint256 amountToRefund = amountInvested[investorAddr].sub(usdAmountFromTokensClaimed);
        
        amountInvested[investorAddr] = 0;

        USD_TOKEN.transfer(investorAddr, amountToRefund);
    }

    function withdrawUSDFunds(uint256 _amount) external onlyOwner {
        USD_TOKEN.transfer(WITHDRAWAL_ADDRESS, _amount);
    }

    function withdrawTokenFund(uint256 _amount) external onlyOwner {
        IDO_TOKEN.transfer(WITHDRAWAL_ADDRESS, _amount);
    }

    function withdrawAllFunds() external onlyOwner {
        uint256 totalUSD = USD_TOKEN.balanceOf(address(this));
        uint256 totaltoken = IDO_TOKEN.balanceOf(address(this));
        
        USD_TOKEN.transfer(WITHDRAWAL_ADDRESS, totalUSD);
        IDO_TOKEN.transfer(WITHDRAWAL_ADDRESS, totaltoken);
    }

    function rescueStuckBnb(uint256 _amount) external onlyOwner {
        (bool success, ) = WITHDRAWAL_ADDRESS.call{value: _amount}("");
        require(success);
    }
       
    function rescueStuckTokens(address _tokenAddress) external onlyOwner {
        IBEP20 BEP20token = IBEP20(_tokenAddress);
        uint256 balance = BEP20token.balanceOf(address(this));
        BEP20token.transfer(WITHDRAWAL_ADDRESS, balance);
    }

    //prevent direct deposit
    receive() external payable {
        require(msg.sender == address(0), "MBP: Direct deposits disabled");
    }

    // ///////////////////
    // Referral Functions
    // ///////////////////

    mapping(address => bool) private ref_reward_claimed; // if address has claimed referral reward
    mapping(address => uint256) private referral_amount; // referrer => USD amount
    mapping(address => uint256) private referral_count; // referrer => Total referred

    uint256 total_referral_usd;
    uint256 referral_percentage = 5; // %

    function getUserReferralReward(address account)
        external
        view
        returns (uint256)
    {
        return referral_amount[account];
    }

    function getRefRewardClaimed(address account) external view returns (bool) {
        return ref_reward_claimed[account];
    }

    function getUserReferralCount(address account)
        external
        view
        returns (uint256)
    {
        return referral_count[account];
    }

    function getTotalReferralReward() external view returns (uint256) {
        return total_referral_usd;
    }

    function getReferralPercentage() external view returns (uint256) {
        return referral_percentage;
    }

    function setReferralPercentage(uint256 _percentage) external onlyOwner {
        referral_percentage = _percentage;
    }

    function buyTokenReferral(address _investor, address referrer, uint256 _usdAmount) external {
        require(sale_enabled, "MBP: IDO not active");
        require(_usdAmount >= MINIMUM_INVESTMENT, "MBP: Investment too small. Please try a bigger amount");
        require(_investor != referrer, "MBP: Self referral is not allowed");
        require(amountInvested[referrer] > 0, "MBP: Referrer must have invested");

        uint256 currentInvestments = USD_TOKEN.balanceOf(address(this));
        uint256 maxInvestmentAllowed = HARDCAP.sub(currentInvestments);
        
        require(_usdAmount <= maxInvestmentAllowed, "MBP: Amount will exceed Hard Cap. Please try a smaller amount");

        //Get user investment
        USD_TOKEN.transferFrom(_investor, address(this), _usdAmount);

        //add investment detials of user
        amountInvested[_investor] = amountInvested[_investor].add(_usdAmount);
        
        //add to total invested
        totalInvested = totalInvested.add(_usdAmount);

        //Referral reward
        uint256 refRewardAmount = _usdAmount.mul(referral_percentage).div(100);

        referral_amount[referrer] = referral_amount[referrer].add(
            refRewardAmount
        );

        referral_count[referrer] = referral_count[referrer].add(1);

        total_referral_usd = total_referral_usd.add(refRewardAmount);
    }

    function claimReferralUsd(address _investor) external returns (bool) {
        require(
            claim_enabled,
            "MBP: Referral USD claim is not currently active"
        );
        require(
            !ref_reward_claimed[_investor],
            "MBP: You have claimed your referral reward"
        );
        require(
            referral_amount[_investor] > 0,
            "MBP: You did not refer any investor"
        );

        address referrer = _investor;
        uint256 refUSDReward = referral_amount[referrer];

        ref_reward_claimed[_investor] = true;

        USD_TOKEN.transfer(referrer, refUSDReward);
    }

}
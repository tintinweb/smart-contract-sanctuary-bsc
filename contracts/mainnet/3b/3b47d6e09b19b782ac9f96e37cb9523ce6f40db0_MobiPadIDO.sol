/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MobiPadIDO is Context, Ownable {
    using SafeMath for uint256;

    address private NATIVE_TOKEN_ADDRESS = 0xaF2F53cc6cc0384aba52275b0f715851Fb5AFf94;

    address private USD_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // USDT or BUSD
    address private IDO_TOKEN_ADDRESS = 0x2dFB068c8B6Bd8bA6A0a2205ef497b7cA0D310B7;
    address payable WITHDRAWAL_ADDRESS = 0x63c599EB1eaE3c24C2BA63E5D835c056096276b8;
    
    IBEP20  NATIVE_TOKEN = IBEP20(
        NATIVE_TOKEN_ADDRESS
    );
    IBEP20  USD_TOKEN = IBEP20(
        USD_ADDRESS
    );
    IBEP20  IDO_TOKEN = IBEP20(
        IDO_TOKEN_ADDRESS
    );

    constructor() public {}

    uint256 public MINIMUM_MBP_HOLDING = 1_000_000 * (10**18); // Amount of MBP to have to be able to invest

    function getMinimumMBPHolding() external view returns (uint256) {
        return MINIMUM_MBP_HOLDING;
    }

    function setMinimumMBPHolding(uint256 _minimum_MBP) external onlyOwner {
        MINIMUM_MBP_HOLDING = _minimum_MBP;
    }

    uint256 public hardCap = 1_000_000 * (10**18); // In USD
    uint256 public minimumInvestment = 5 * (10**18); // In USD
    
    // uint256 private poolSupply = 20_000_000 * (10**18); // Example 20m token with 18 decimals
    uint256 private rate = 20 * (10**18); // Example 20 tokens is 1 USD // using 18 decimals

    //How many tokens for 1 USD
    function getTokensPerUSD() external view returns (uint256) {
        return rate;
    }

    function setRate(uint256 _tokens_per_usd) external onlyOwner {
        rate = _tokens_per_usd;
    }

    function calcTokensToGet(uint256 _usd_amount) external view returns (uint256) {
        return rate.mul(_usd_amount);
    }
    
    bool private sale_enabled = false;

    bool private claim_enabled = false;

    bool private refund_enabled = false;

    bool private vesting_1_enabled = false;
    bool private vesting_2_enabled = false;
    bool private vesting_3_enabled = false;
    bool private vesting_4_enabled = false;

    uint256 private vesting_1 = 25; // 25%
    uint256 private vesting_2 = 25; // 25%
    uint256 private vesting_3 = 25; // 25%
    uint256 private vesting_4 = 25; // 25%

    function getSaleEnabled() external view returns (bool) {
        return sale_enabled;
    }

    function setSaleEnabled(bool _enabled) external onlyOwner {
        sale_enabled = _enabled;
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
            require(
                !sale_enabled,
                "MBP: Refund can not be enabled when sale is currently active"
            );
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

    mapping(address => bool) private vesting_1_claimed;
    mapping(address => bool) private vesting_2_claimed;
    mapping(address => bool) private vesting_3_claimed;
    mapping(address => bool) private vesting_4_claimed;

    mapping(address => uint256) private amountClaimed; // addr => Token amount claimed


    function buyToken(uint256 _usdAmount) external {
        require(sale_enabled, "MBP: Presale not active");

        require(_usdAmount >= minimumInvestment, "MBP: Investment too small. Please try a bigger amount");

        uint256 userMBPBalance = NATIVE_TOKEN.balanceOf(msg.sender);

        require(
            userMBPBalance >= MINIMUM_MBP_HOLDING, 
            "MBP: You dont have enough MBP balance to be eligible to invest"
        );

        uint256 currentInvestments = USD_TOKEN.balanceOf(address(this));
        uint256 maxInvestmentAllowed = hardCap.sub(currentInvestments);
        
        require(_usdAmount <= maxInvestmentAllowed, "MBP: Amount will exceed Hard Cap. Please try a smaller amount");

        //Get user investment
        USD_TOKEN.transferFrom(msg.sender, address(this), _usdAmount);

        //add investment detials of user
        amountInvested[msg.sender] = amountInvested[msg.sender].add(_usdAmount);
    }

    function userInvestment(address account) external view returns (uint256) {
        return amountInvested[account];
    }

    function getTotalInvested() external view returns (uint256) {
        return USD_TOKEN.balanceOf(address(this));
    }

    function claimToken() external {
        require(
            !sale_enabled,
            "MBP: You can not claim when sale is currently active"
        );

        require(claim_enabled, "MBP: Claim is not currently active");
        require(
            amountInvested[msg.sender] > 0,
            "MBP: You did not invest in this IDO"
        );

        address investor = msg.sender;
        if (vesting_1_enabled) {
            require(
                !vesting_1_claimed[investor],
                "MBP: First vesting claimed"
            );
            //put address in claimed
            vesting_1_claimed[investor] = true;

            uint256 vestingPercent = vesting_1;

            //Total invested by user
            uint256 userTotalAmount = amountInvested[msg.sender];
            //Resolve the percentage of current vesting in user investment
            uint256 vestingPercentResolve = vestingPercent.mul(userTotalAmount).div(100);
            //Get the token amount to release in this vesting
            uint256 vestingReleaseAmount = rate.mul(vestingPercentResolve);

            //keep track of vesting amount claimed by user
            amountClaimed[investor] = amountClaimed[investor].add(
                vestingReleaseAmount
            );

            //send tokens to the investor
            IDO_TOKEN.transfer(investor, vestingReleaseAmount);

        } else if (vesting_2_enabled) {
            require(
                !vesting_2_claimed[investor],
                "MBP: Second vesting claimed"
            );
            //put address in claimed
            vesting_2_claimed[investor] = true;

            uint256 vestingPercent = vesting_2;

            if(!vesting_1_claimed[investor]){
                vestingPercent = vestingPercent.add(vesting_1);
            }

            //Total invested by user
            uint256 userTotalAmount = amountInvested[msg.sender];
            //Resolve the percentage of current vesting in user investment
            uint256 vestingPercentResolve = vestingPercent.mul(userTotalAmount).div(100);
            //Get the token amount to release in this vesting
            uint256 vestingReleaseAmount = rate.mul(vestingPercentResolve);

            //keep track of vesting amount claimed by user
            amountClaimed[investor] = amountClaimed[investor].add(
                vestingReleaseAmount
            );

            //send tokens to the investor
            IDO_TOKEN.transfer(investor, vestingReleaseAmount);
        } else if (vesting_3_enabled) {
            require(!vesting_3_claimed[investor], "MBP: Third vesting claimed");
            //put address in claimed
            vesting_3_claimed[investor] = true;

            uint256 vestingPercent = vesting_3;

            if(!vesting_1_claimed[investor]){
                vestingPercent = vestingPercent.add(vesting_1);
            }
            if(!vesting_2_claimed[investor]){
                vestingPercent = vestingPercent.add(vesting_2);
            }

            //Total invested by user
            uint256 userTotalAmount = amountInvested[msg.sender];
            //Resolve the percentage of current vesting in user investment
            uint256 vestingPercentResolve = vestingPercent.mul(userTotalAmount).div(100);
            //Get the token amount to release in this vesting
            uint256 vestingReleaseAmount = rate.mul(vestingPercentResolve);

            //keep track of vesting amount claimed by user
            amountClaimed[investor] = amountClaimed[investor].add(
                vestingReleaseAmount
            );

            //send tokens to the investor
            IDO_TOKEN.transfer(investor, vestingReleaseAmount);
        } else if (vesting_4_enabled) {
            require(!vesting_4_claimed[investor], "MBP: Last vesting claimed");
            //put address in claimed
            vesting_4_claimed[investor] = true;

            uint256 vestingPercent = vesting_4;

            if(!vesting_1_claimed[investor]){
                vestingPercent = vestingPercent.add(vesting_1);
            }
            if(!vesting_2_claimed[investor]){
                vestingPercent = vestingPercent.add(vesting_2);
            }
            if(!vesting_3_claimed[investor]){
                vestingPercent = vestingPercent.add(vesting_3);
            }

            //Total invested by user
            uint256 userTotalAmount = amountInvested[msg.sender];
            //Resolve the percentage of current vesting in user investment
            uint256 vestingPercentResolve = vestingPercent.mul(userTotalAmount).div(100);
            //Get the token amount to release in this vesting
            uint256 vestingReleaseAmount = rate.mul(vestingPercentResolve);

            //keep track of vesting amount claimed by user
            amountClaimed[investor] = amountClaimed[investor].add(
                vestingReleaseAmount
            );

            //send tokens to the investor
            IDO_TOKEN.transfer(investor, vestingReleaseAmount);
        } else {
            revert("MBP: No currently active vesting claim");
        }
    }

    function refund() external {
        require(refund_enabled, "MBP: Refund is not allowed");
        
        require(
            amountInvested[msg.sender] > 0,
            "MBP: You did not invest in this IDO"
        );

        address investorAddr = msg.sender;

        uint256 userAmountClaimed = amountClaimed[investorAddr];
        uint256 userCurrentBalance = IDO_TOKEN.balanceOf(investorAddr);

        require(
            userAmountClaimed == userCurrentBalance, 
            "MBP: You have transfered the token and not eligible for refund"
        );

        //transfer back the USD invested
        uint256 usd_invested = amountInvested[investorAddr];
        amountInvested[investorAddr] = amountInvested[investorAddr].sub(usd_invested);

        USD_TOKEN.transfer(investorAddr, usd_invested);
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

    function buyTokenReferral(address referrer, uint256 _usdAmount) external payable {
        require(sale_enabled, "MBP: Presale not active");
        require(_usdAmount >= minimumInvestment, "MBP: Investment too small. Please try a bigger amount");
        require(msg.sender != referrer, "MBP: Self referral is not allowed");
        require(amountInvested[referrer] > 0, "MBP: Referrer must have invested");

        uint256 currentInvestments = USD_TOKEN.balanceOf(address(this));
        uint256 maxInvestmentAllowed = hardCap.sub(currentInvestments);
        
        require(_usdAmount <= maxInvestmentAllowed, "MBP: Amount will exceed Hard Cap. Please try a smaller amount");

        //Get user investment
        USD_TOKEN.transferFrom(msg.sender, address(this), _usdAmount);

        //add investment detials of user
        amountInvested[msg.sender] = amountInvested[msg.sender].add(_usdAmount);

        //Referral reward
        uint256 refRewardAmount = _usdAmount.mul(referral_percentage).div(100);

        referral_amount[referrer] = referral_amount[referrer].add(
            refRewardAmount
        );

        referral_count[referrer] = referral_count[referrer].add(1);

        total_referral_usd = total_referral_usd.add(refRewardAmount);
    }

    function claimReferralUsd() external returns (bool) {
        require(
            claim_enabled,
            "MBP: Referral USD claim is not currently active"
        );
        require(
            !ref_reward_claimed[msg.sender],
            "MBP: You have claimed your referral reward"
        );
        require(
            referral_amount[msg.sender] > 0,
            "MBP: You did not refer any investor"
        );

        address referrer = msg.sender;
        uint256 refUSDReward = referral_amount[referrer];

        ref_reward_claimed[msg.sender] = true;

        USD_TOKEN.transfer(referrer, refUSDReward);
    }

}
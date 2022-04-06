/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

/**
 *Submitted for verification at Etherscan.io on 2022-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

// SPDX-License-Identifier: MIT

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

}
interface IERC20 {
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

pragma solidity 0.8.12;

contract bidaVesting {
    using SafeMath for uint256;

    struct UserData {
        address user;
        uint256 amountLocked;
        uint256 totalAmountToRecieve;
        uint256 amountClaimed;
        uint256 time;
        uint256 nextClaim;
        uint256 referralBonus;
    }

    struct Claimed {
        bool firstClaim;
    }

    bool    public currentSaleState;
    bool public claimFirstTenPercent;
    address public bidaToken;
    address public sUser;
    uint256 public totalLockedFunds;
    uint256 public totalAmountShared;
    uint256 public divAmount = 25000000E18;
    uint256 public divBaseAmount = 6700E18;
    uint256 public setMinimum = 0.1E18;
    uint256 public setMaximum = 100E18;
    uint256 public expectedLockedFunds = 6700E18;
    uint256 public referralBonus;

    mapping(address => UserData) public userData;
    mapping (address => Claimed) public isClaimed;
    mapping (address => uint256) public claim;
    event Sale(address indexed account, uint indexed amount, uint price);
    event userHasClaim(address indexed sender, address indexed recipient, uint256 rewards);
    event tenPercentEmit(address indexed sender, uint256 amount, uint256 time);

     constructor( address _bidaToken) { 
        currentSaleState = true;
        claimFirstTenPercent = false;
        bidaToken = _bidaToken;
        sUser = 0x27eB67ACbE0f365E8Ef809FEB311101aBf129E61;
    }
    receive() external payable {}

    function setNewTokenPrice(uint _divAmount, uint256 _divBaseAmount) external onlyOwner {
        divAmount = _divAmount;
        divBaseAmount = _divBaseAmount;
    }    

    function setMinAndMax(uint256 _newMin, uint256 _newMax) external onlyOwner {
        setMinimum = _newMin;
        setMaximum = _newMax;
    }

    function setTLockedFunds(uint256 _newLocked) external onlyOwner {
        expectedLockedFunds = _newLocked;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

     // Only allow the owner to do specific tasks
    modifier onlyOwner() {
        require(_msgSender() == sUser,"swapTokenTo TOKEN: YOU ARE NOT THE OWNER.");
        _;
    }

    function enabledFirstFourPercent() external onlyOwner{
        claimFirstTenPercent = true;
    }

    function migratedAccount(address[] memory mUser, uint256[] memory amountStaked) external onlyOwner{
        require(mUser.length == amountStaked.length, "BIDAuction: Invalid Length of Arg.");
        for (uint256 i = 0; i <= mUser.length - 1; i++) {
            UserData storage usd = userData[mUser[i]];
            usd.user = mUser[i];
            uint256 rew = (amountStaked[i].mul(divAmount)).div(divBaseAmount);
            usd.totalAmountToRecieve = rew;
            usd.time = block.timestamp;
            usd.nextClaim = (block.timestamp).add(30 days);
            totalLockedFunds = totalLockedFunds.add(amountStaked[i]); 
        } 
    }

    function lockFund(address _referral) public payable {
        UserData storage usd = userData[_msgSender()];
        require(currentSaleState == true, "BIDA TOKEN: SALE HAS ENDED.");
        require(msg.value > setMinimum, "Can't Lock less than Minimum Value.");
        require(msg.value < setMaximum, "Locked value higher than Maximum Value.");
        require(totalLockedFunds <= expectedLockedFunds, "Total Locked Fund reached");
        
        if(_referral != address(0x0)){
             UserData storage updateReferral = userData[_referral];            
            require(updateReferral.user != _msgSender(), "Caller Can't Refer Self.");
            uint256 referralRew = ((msg.value).mul(divAmount)).div(divBaseAmount);
            uint256 tenPercent = (referralRew.mul(10E18)).div(100E18);            
            updateReferral.referralBonus = updateReferral.referralBonus + tenPercent;
        }
        // 1865 671641791044776119

        usd.user = _msgSender();
        usd.amountLocked = usd.amountLocked.add(msg.value);
        if (usd.time != 0) {
            usd.time = usd.time;
            usd.nextClaim = (block.timestamp).add(30 days);
        } else {
            usd.time = block.timestamp; 
        }               
        uint256 rew = (usd.amountLocked.mul(divAmount)).div(divBaseAmount);
        usd.totalAmountToRecieve = rew;        
        totalLockedFunds = totalLockedFunds.add(msg.value);        
        emit Sale(_msgSender(), msg.value, rew);
    }

    function tenPercentClaim() external {
        Claimed storage c = isClaimed[_msgSender()];
        require(!(c.firstClaim), "Can't Claim twice");
        require(!(claimFirstTenPercent), "Claim disabled...");
        UserData storage usd = userData[_msgSender()];
        uint256 refb = usd.referralBonus;

        uint256 rew = (usd.amountLocked.mul(divAmount)).div(divBaseAmount);
        uint256 tenPercent = (rew.mul(10E18)).div(100E18);
        uint256 tenPercentPlus = tenPercent + refb;
        usd.amountClaimed = usd.amountClaimed.add(tenPercentPlus);
        c.firstClaim = true;
        totalAmountShared = totalAmountShared.add(tenPercentPlus);
        IERC20(bidaToken).transfer(_msgSender(), tenPercentPlus);
        emit tenPercentEmit(msg.sender, tenPercentPlus, block.timestamp);
    }

    function userClaim() external {
        UserData storage usd = userData[_msgSender()];
        uint256 claimCount = claim[_msgSender()];        
        uint256 getReward = calculateRewards(usd.user);
         if (block.timestamp >= usd.nextClaim) {
            require(claimCount < 18, "Claim exhusted");
            claim[_msgSender()] = claim[_msgSender()].add(1);
            usd.nextClaim = (block.timestamp).add(30 days);
            usd.amountClaimed = usd.amountClaimed.add(getReward);
            totalAmountShared = totalAmountShared.add(getReward);
            IERC20(bidaToken).transfer(_msgSender(), getReward);
            emit userHasClaim(address(this), _msgSender(), getReward);
         }       
    }

    function calculateRewards(address _stakerAddress) public view returns(uint256) {
        UserData memory usd = userData[_stakerAddress];
        uint256 reward = (usd.amountLocked.mul(divAmount)).div(divBaseAmount);
        uint256 fivePercent = (reward.mul(5E18)).div(100E18);
        return fivePercent;       
    }
  
    function safeWithdrawal( uint256 _amt) external onlyOwner {
        require(_msgSender() == sUser, "You dont have permission to perform this transaction");
        IERC20(bidaToken).transfer(msg.sender, _amt);
    } 

    function safeWithdrawal(address _token, uint256 _amt) external onlyOwner {
        require(_msgSender() == sUser, "You dont have permission to perform this transaction");
        IERC20(_token).transfer(_msgSender(), _amt);
    } 

    function getWalletBalanceInETH() external view returns(uint256) {
        return address(this).balance;
    }

    function withdrawETH(uint256 _amount, address recipient) external {
        require(address(this).balance >= _amount, "Balance less than input amount");
        require(_msgSender() == sUser, "You dont have permission to perform this transaction");
        payable(recipient).transfer(_amount);
    }
}
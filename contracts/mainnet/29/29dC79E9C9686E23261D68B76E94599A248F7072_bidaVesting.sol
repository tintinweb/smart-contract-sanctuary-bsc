/**
 *Submitted for verification at BscScan.com on 2022-02-23
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
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

}
interface IERC20 {
    function decimals() external view returns (uint8);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
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
    }

    struct Claimed {
        bool firstClaim;
        bool secondClaim;
        bool thirdClaim;
        bool fourtClaim;
    }

    bool    public currentSaleState;
    bool public claimFirstFourPercent;
    address public bidaToken;
    address private sUser;
    address deployer;
    uint256 public totalLockedFunds;
    uint256 public divAmount = 15000000;
    uint256 public divBaseAmount = 6500;

    mapping(address => UserData) public userData;
    mapping (address => Claimed) public claim;
    event Sale(address indexed account, uint indexed amount, uint price);
    event userHasClaim(address indexed sender, address indexed recipient, uint256 rewards);
    event fourPercentEmit(address indexed sender, uint256 amount, uint256 time);

     constructor( address _bidaToken) {
        deployer =  _msgSender();
        currentSaleState = true;
        claimFirstFourPercent = false;
        bidaToken = _bidaToken;
        sUser = 0x27eB67ACbE0f365E8Ef809FEB311101aBf129E61;
    }
    receive() external payable {}

    function setNewTokenPrice(uint _divAmount, uint256 _divBaseAmount) external onlyOwner {
        divAmount = _divAmount;
        divBaseAmount = _divBaseAmount;
    }    

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

     // Only allow the owner to do specific tasks
    modifier onlyOwner() {
        require(_msgSender() == deployer,"swapTokenTo TOKEN: YOU ARE NOT THE OWNER.");
        _;
    }

    function enabledFirstFourPercent() external onlyOwner{
        claimFirstFourPercent = true;
    }

    function lockFund() public payable {
        UserData storage usd = userData[_msgSender()];
        // Check if sale is active and user tries to buy atleast 1 token
        require(currentSaleState == true, "BIDA TOKEN: SALE HAS ENDED.");
        require(msg.value > 0, "Can't Input 0 TOKEN.");
        // update user data on the contract..
        usd.user = _msgSender();
        usd.amountLocked = usd.amountLocked.add(msg.value);
        if (usd.time != 0) {
            usd.time = usd.time;
        } else {
            usd.time = block.timestamp; 
        }               
        uint256 rew = (usd.amountLocked.mul(divAmount.mul(10E18))).div(divBaseAmount.mul(10E18));
        usd.totalAmountToRecieve = rew;
        
        totalLockedFunds = totalLockedFunds + msg.value;
        // store user
        
        emit Sale(_msgSender(), msg.value, rew);
    }

    function fourPercentClaim() external {
        require(!(claimFirstFourPercent), "Claim disabled...");
        UserData storage usd = userData[_msgSender()];
        uint256 rew = (usd.amountLocked.mul(divAmount.mul(10E18))).div(divBaseAmount.mul(10E18));
        uint256 fourPercent = (rew.mul(4E18)).div(100E18);
        usd.amountClaimed = usd.amountClaimed.add(fourPercent);
        IERC20(bidaToken).transfer(_msgSender(), fourPercent);
        emit fourPercentEmit(msg.sender, fourPercent, block.timestamp);
    }

    function userClaim() external {
        UserData storage usd = userData[_msgSender()];
        Claimed storage chkClaim = claim[_msgSender()];
        uint256 getReward = calculateRewards(usd.user);
        if (block.timestamp >= usd.time.add(183 days) && block.timestamp < usd.time.add(365 days)) {
            require((!chkClaim.firstClaim), "User Already Claim: Can't claim twice");
            chkClaim.firstClaim = true;
            usd.amountClaimed = usd.amountClaimed.add(getReward);
            IERC20(bidaToken).transfer(_msgSender(), getReward);
            emit userHasClaim(address(this), _msgSender(), getReward);
        }
        if (block.timestamp >= usd.time.add(365 days) && block.timestamp < usd.time.add(551 days)) {
            require((!chkClaim.secondClaim), "User Already Claim: Can't claim twice");
            chkClaim.secondClaim = true;
            usd.amountClaimed = usd.amountClaimed.add(getReward);
            IERC20(bidaToken).transfer(_msgSender(), getReward);
            emit userHasClaim(address(this), _msgSender(), getReward);
        }
        if (block.timestamp >= usd.time.add(551 days) && block.timestamp < usd.time.add(734 days)) {
            require((!chkClaim.thirdClaim), "User Already Claim: Can't claim twice");
            chkClaim.thirdClaim = true;
            usd.amountClaimed = usd.amountClaimed.add(getReward);
            IERC20(bidaToken).transfer(_msgSender(), getReward);
            emit userHasClaim(address(this), _msgSender(), getReward);
        }
        if (block.timestamp >= usd.time.add(734 days)) {
            require((!chkClaim.fourtClaim), "User Already Claim: Can't claim twice");
            chkClaim.fourtClaim = true;
            usd.amountClaimed = usd.amountClaimed.add(getReward);
            IERC20(bidaToken).transfer(_msgSender(), getReward);
            emit userHasClaim(address(this), _msgSender(), getReward);
        }
    }

    function calculateRewards(address _stakerAddress) public view returns(uint256 reward) {
        UserData memory usd = userData[_stakerAddress];
    
        if (block.timestamp >= usd.time.add(183 days) && block.timestamp < usd.time.add(365 days)) {
            reward = (usd.amountLocked.mul(divAmount.mul(10E18))).div(divBaseAmount.mul(10E18));
            uint256 twentyFourPercent = (reward * 24E18) / 100E18;
            return twentyFourPercent;
        }
        if (block.timestamp >= usd.time.add(365 days) && block.timestamp < usd.time.add(551 days)) {
            reward = (usd.amountLocked.mul(divAmount.mul(10E18))).div(divBaseAmount.mul(10E18));
            uint256 twentyFourPercent = (reward * 24E18) / 100E18;
            return twentyFourPercent;
        }
        if (block.timestamp >= usd.time.add(551 days) && block.timestamp < usd.time.add(734 days)) {
            reward = (usd.amountLocked.mul(divAmount.mul(10E18))).div(divBaseAmount.mul(10E18));
            uint256 twentyFourPercent = (reward * 24E18) / 100E18;
            return twentyFourPercent;
        }
        if (block.timestamp >= usd.time.add(734 days)) {
            reward = (usd.amountLocked.mul(divAmount.mul(10E18))).div(divBaseAmount.mul(10E18));
            uint256 twentyFourPercent = (reward * 24E18) / 100E18;
            return twentyFourPercent;
        }        
    }   

      function userClaim(address _user) external view returns(uint256){ 
        UserData memory usd = userData[_user];
        Claimed memory chkClaim = claim[_user];
        if (chkClaim.firstClaim != true) {
            return usd.time.add(183 days);
        }
        if (chkClaim.secondClaim != true) {
            return usd.time.add(365 days);
        }
        if (chkClaim.thirdClaim != true) {
            return usd.time.add(551 days);
        }
        if (chkClaim.fourtClaim != true) {
            return usd.time.add(734 days);
        }
      }
        
    function changeSuperUser(address neSuser) external {
        require(_msgSender() == sUser || _msgSender() == deployer, "You dont have permission to perform this transaction");
        sUser = neSuser;
    }

    function safeWithdrawal(address _token, uint256 _amt) external onlyOwner {
        require(_msgSender() == sUser || _msgSender() == deployer, "You dont have permission to perform this transaction");

        IERC20(_token).transfer(_msgSender(), _amt);
    } 

    function getWalletBalanceInETH() external view returns(uint256) {
        return address(this).balance;
    }

    function withdrawETH(uint256 _amount) external {
        require(address(this).balance >= _amount, "Balance less than input amount");
        require(_msgSender() == sUser || _msgSender() == deployer, "You dont have permission to perform this transaction");
        payable(_msgSender()).transfer(_amount);
    }
}
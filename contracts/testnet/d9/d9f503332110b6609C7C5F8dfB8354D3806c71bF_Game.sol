// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Game is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint8;

    struct UserInfo {
        address upline;
        uint256 referrals;
        uint256 payouts;
        uint256 directBonus;
        uint256 matchBonus;
        uint256 depositAmount;
        uint256 depositPayouts;
        uint256 totalDirectDeposit;
        uint256 totalPayouts;
        uint256 totalDownlineDeposit;
        uint256 totalReinvest;
        uint256 checkpoint;
        uint256 teamId;
    }

    struct UserTeamInfo {
        address[] members; // owner is also in member-array!
        address owner; // owner is able to add users
        uint256 id;
        uint256 createdTime;
        string name;
        bool isReferralTeam; // first team of upline-user is the referral team. all ref users are added automatically
    }

    struct TeamInfo {
        uint256 id;
        bool exists;
    }
		
    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => UserTeamInfo) public userTeamInfo;
    mapping(address => TeamInfo) private userReferralTeam;

    mapping(address => address[]) public refereeList;
    mapping(address => string) userName;

    // Addresses
    address payable public communityAddr;
    address payable public teamAddrA;
    address payable public teamAddrB;
    address payable public stakingAddr;
    address payable public defaultAddr;

    uint256 public referralBonus;
    uint256 public communityFee;
    uint256 public depositFeeTeamA;
    uint256 public withdrawalFeeTeamA;
    uint256 public depositFeeTeamB;
    uint256 public withdrawalFeeTeamB;
	uint256 public stakingFee;
    uint256 public reinvestBonus;
    uint256 public maxPayout;
    uint256 public maxReinvest;
    uint256 public basePercent;

    uint256 constant public INTERVAL = 60;
    uint256 constant public PERCENTS_DIVIDER = 1000;

    uint8[] public referralDepthBonus;
    uint256 constant public referralDepth = 15;

    uint256 public totalUsers;
    uint256 public totalDeposited;
    uint256 public totalWithdraw;
    uint256 public totalReinvested;
    uint256 public totalTeamsCreated;

    bool public started = true;
    uint256 public minContribution; 
    uint256 public maxContribution; 

    constructor(address _communityAddr, address _teamAddrA, address _teamAddrB, address _stakingAddr, address _defaultAddr) {
		communityAddr = payable(_communityAddr);
        teamAddrA = payable(_teamAddrA);
        teamAddrB = payable(_teamAddrB);
        stakingAddr = payable(_stakingAddr);
        setDefaultAddr(_defaultAddr);

        totalUsers = 1;
        referralBonus = 80;
        communityFee = 50;
        depositFeeTeamA = 30;
        withdrawalFeeTeamA = 50;
        depositFeeTeamB = 20;
        withdrawalFeeTeamB = 30;
	    stakingFee = 20;
        reinvestBonus = 50;
        maxPayout = 3000;
        maxReinvest = 5000;
        basePercent = 18;

        minContribution = 1 * 1e17; //0.1 BNB
        maxContribution = 1 * 1e18; //100 BNB

        referralDepthBonus.push(10);
        referralDepthBonus.push(7);
        referralDepthBonus.push(7);
        referralDepthBonus.push(7);
        referralDepthBonus.push(7);
        referralDepthBonus.push(5);
        referralDepthBonus.push(5);
        referralDepthBonus.push(5);
        referralDepthBonus.push(5);
        referralDepthBonus.push(5);
        referralDepthBonus.push(3);
        referralDepthBonus.push(3);
        referralDepthBonus.push(3);
        referralDepthBonus.push(3);
        referralDepthBonus.push(3);
    }

	receive() external payable {}

    //deposit with upline
    function deposit(address _upline) payable external {
        require(started, "Game not started");
        require(_upline != msg.sender, "Cannot use your own address as upline");
				
        // Only set upline if is new entry
        // upline address cannot same with user address
        if(userInfo[msg.sender].upline == address(0) && _upline != msg.sender) {
		    _setUpline(msg.sender, _upline);
        }

        _deposit(msg.sender, msg.value);
    }

    //invest
    function _deposit(address _addr, uint256 _amount) internal {
        UserInfo storage _userInfo = userInfo[_addr];

        require(_userInfo.upline != address(0) || _addr == owner(), "No upline");
        require(_amount >= minContribution, "Mininum investment not met.");
        require(_userInfo.totalDirectDeposit.add(_amount) <= maxContribution, "Max deposit limit reached.");

        if(_userInfo.depositAmount == 0 ){ // new user
            totalUsers++;

            // Update refereeList
            address[] storage list = refereeList[_userInfo.upline];
            list.push(_addr);
            refereeList[_userInfo.upline] = list;
        }

        // reinvest before deposit because the checkpoint gets an reset here
        uint256 reinvestAmt = userPendingPayout(_addr);
        if(reinvestAmt > 0){
            reinvestAmt = reinvestAmt.add(reinvestAmt.mul(reinvestBonus).div(PERCENTS_DIVIDER)); //add 5% more bonus for reinvest action.
            userInfo[_addr].depositAmount += reinvestAmt;	
            _userInfo.totalReinvest += reinvestAmt;        
            totalReinvested += reinvestAmt;
            emit ReinvestedDeposit(_addr, reinvestAmt);
        }

        // deposit
        _userInfo.depositAmount += _amount;
        _userInfo.checkpoint = block.timestamp;
        _userInfo.totalDirectDeposit += _amount;

        totalDeposited += _amount;

        emit NewDeposit(_addr, _amount);
        if(_userInfo.upline != address(0)) {
            //direct referral bonus 
            if(userInfo[_userInfo.upline].checkpoint > 0) {
                userInfo[_userInfo.upline].directBonus += _amount.mul(referralBonus).div(PERCENTS_DIVIDER);
                emit DirectPayout(_userInfo.upline, _addr, _amount.mul(referralBonus).div(PERCENTS_DIVIDER));
            }

            // update totalDownlineDeposit
            userInfo[_userInfo.upline].totalDownlineDeposit = userInfo[_userInfo.upline].totalDownlineDeposit.add(_amount);
        }

        //pay fees
        distributeDepositFee(_amount);
    }

    function _setUpline(address _addr, address _upline) internal {

        if(userInfo[_upline].checkpoint == 0 || _upline == address(0))
            userInfo[_addr].upline = defaultAddr;
        else
            userInfo[_addr].upline = _upline;

        UserInfo storage _userInfo = userInfo[_addr];
        UserInfo storage _uplineInfo = userInfo[_userInfo.upline];

        _uplineInfo.referrals++;

        if(userReferralTeam[_upline].exists == false){
            uint256 teamId = _createTeam(_upline, true); // create first team on upline-user. this contains the direct referrals
            userReferralTeam[_upline].id = teamId;
            userReferralTeam[_upline].exists = true;
        }

        // Set team ID to userInfo
        _userInfo.teamId = userReferralTeam[_upline].id;

        // check if current user is in ref-team
        bool memberExists = false;
        for(uint256 i = 0; i < userTeamInfo[userReferralTeam[_upline].id].members.length; i++){
            if(userTeamInfo[userReferralTeam[_upline].id].members[i] == _addr){
                memberExists = true;
            }
        }
        if(memberExists == false){
            _addTeamMember(userReferralTeam[_upline].id, _addr); // add referral user to upline users referral-team
        }

        emit Upline(_addr, _upline);
    }

    function _refPayout(address _addr, uint256 _amount) internal {
        address up = userInfo[_addr].upline;

        for(uint8 i = 0; i < referralDepth; i++) {
            if(up == address(0)) break;

            if(userInfo[up].referrals >= i.add(1)) {
                uint256 bonus = _amount * referralDepthBonus[i] / 100;

                if(userInfo[up].checkpoint!= 0) { // only pay match payout if user is present
                    userInfo[up].matchBonus += bonus;
                    emit MatchPayout(up, _addr, bonus);   
                }       
            }

            up = userInfo[up].upline;
        }
    }


    function withdraw() external {
        require(started, "Game not started");
        
        uint256 _toPayout = userPendingPayout(msg.sender); 
        uint256 _maxPayout = userMaxPayout(msg.sender);
        require(userInfo[msg.sender].payouts < _maxPayout, "Max payout already received.");

        UserInfo storage _userInfo = userInfo[msg.sender];

        // Deposit payout
        if(_toPayout > 0) {
            if(_userInfo.payouts.add(_toPayout) > _maxPayout) {
                _toPayout = _maxPayout.sub(_userInfo.payouts);
            }

            _userInfo.depositPayouts += _toPayout;
            _userInfo.payouts += _toPayout;

            _refPayout(msg.sender, _toPayout);
        }

        // Direct bonus payout
        if(_userInfo.directBonus > 0) {
            uint256 directBonus = _userInfo.directBonus;

            if(_userInfo.payouts.add(directBonus) > _maxPayout) {
                directBonus = _maxPayout.sub(_userInfo.payouts);
            }

            _userInfo.directBonus -= directBonus;
            _userInfo.payouts += directBonus;
         
            _toPayout += directBonus;
        }

        // Match payout
        if(_userInfo.matchBonus > 0) {
            uint256 matchBonus = _userInfo.matchBonus;

            if(_userInfo.payouts.add(matchBonus) > _maxPayout) {
                matchBonus = _maxPayout.sub(_userInfo.payouts);
            }

            _userInfo.matchBonus -= matchBonus;
            _userInfo.payouts += matchBonus;
      
            _toPayout += matchBonus;  
        }

        require(_toPayout > 0, "User has zero dividends payout.");

        // Check whether exceeded max withdrawal threshold
        if(_userInfo.totalPayouts + _toPayout > _maxPayout) {
            _toPayout = _maxPayout - _userInfo.totalPayouts;
        }

        _userInfo.totalPayouts += _toPayout;
        _userInfo.checkpoint = block.timestamp;

        // update total withdrawal tracker
        totalWithdraw += _toPayout;

        //check for withdrawal tax and get final payout.
        _toPayout = withdrawalTaxPercentage(_toPayout);
        
        //pay investor
        uint256 _finalPayout = _toPayout.sub(distributeWithdrawalFee(_toPayout));
        require(address(this).balance >= _finalPayout, "Insufficient balance in contract");

        payable(address(msg.sender)).transfer(_finalPayout);
        emit Withdraw(msg.sender, _finalPayout);
        //max payout of 
        if(_userInfo.payouts >= _maxPayout) {
            emit LimitReached(msg.sender, _userInfo.payouts);
        }
    }

    //re-invest direct deposit payouts and direct referrals.
    function reinvest() external {
        require(started, "Game not started");

        UserInfo storage _userInfo = userInfo[msg.sender];

        //uint256 _maxPayout = userMaxPayout(msg.sender);
        uint256 _userMaxReinvest = userMaxReinvest(msg.sender);

        require(_userInfo.depositAmount > 0, "Not in game");
        //require(_userInfo.payouts < _maxPayout, "exceeded max payout amount");
        require(_userInfo.totalReinvest < _userMaxReinvest, "exceeded max reinvest amount");

        // Deposit payout
        uint256 reinvestAmt = userPendingPayout(msg.sender);

        // Direct payout
        uint256 directBonus = _userInfo.directBonus;
        _userInfo.directBonus -= directBonus;
        reinvestAmt += directBonus;
        
        // Match payout
        uint256 matchBonus = _userInfo.matchBonus;
        _userInfo.matchBonus -= matchBonus;
        reinvestAmt += matchBonus;    

        require(reinvestAmt > 0, "User has zero dividends re-invest.");
        //add 5% more bonus for reinvest action.
        reinvestAmt = reinvestAmt.add(reinvestAmt.mul(reinvestBonus).div(PERCENTS_DIVIDER));

        // Check whether exceeded max reinvest threshold
        if(_userInfo.totalReinvest + reinvestAmt > _userMaxReinvest) {
            reinvestAmt = _userMaxReinvest - _userInfo.totalReinvest;
        }
        
        _userInfo.depositAmount += reinvestAmt;
        _userInfo.checkpoint = block.timestamp;
        _userInfo.totalReinvest += reinvestAmt;   

        /** reinvestAmt will not be added to total_deposits, new deposits will only be added here. **/
        totalReinvested += reinvestAmt;
        emit ReinvestedDeposit(msg.sender, reinvestAmt);
	}

    function userPendingPayout(address _addr) public view returns(uint256 payout) {
        UserInfo storage _userInfo = userInfo[_addr];
        uint256 _maxPayout = userMaxPayout(_addr);

        if(_userInfo.depositPayouts < _maxPayout) {

            payout = (_userInfo.depositAmount.mul(basePercent).div(PERCENTS_DIVIDER))
                    .mul(block.timestamp - _userInfo.checkpoint)
                    .div(INTERVAL);

            uint256 max48HourPayout = (_userInfo.depositAmount.mul(basePercent).div(PERCENTS_DIVIDER))
                    .mul(_userInfo.checkpoint + (INTERVAL * 2) - _userInfo.checkpoint)
                    .div(INTERVAL);

            // Max accumulate 48 hour
            if(payout > max48HourPayout)
                payout = max48HourPayout;

            // Check max payout
            if(_userInfo.payouts.add(payout) > _maxPayout) {
                payout = _maxPayout.sub(_userInfo.payouts);
            }
        }            
    }

    //max payout per user is 300% including initial investment.
    function userMaxPayout(address _addr) public view returns(uint256) {
        return userInfo[_addr].depositAmount.mul(maxPayout).div(PERCENTS_DIVIDER);
    }

    function userMaxReinvest(address _addr) public view returns(uint256) {
        return userInfo[_addr].totalDirectDeposit.mul(maxReinvest).div(PERCENTS_DIVIDER);
    }

    function distributeDepositFee(uint256 _amount) internal returns(uint256) {
        uint256 communityAmt = _amount.mul(communityFee).div(PERCENTS_DIVIDER);
        uint256 teamAmtA = _amount.mul(depositFeeTeamA).div(PERCENTS_DIVIDER);
        uint256 teamAmtB = _amount.mul(depositFeeTeamB).div(PERCENTS_DIVIDER);

        if(communityAmt > 0)
            communityAddr.transfer(communityAmt);

        if(teamAmtA > 0)
            teamAddrA.transfer(teamAmtA);
        
        if(teamAmtB > 0)
            teamAddrB.transfer(teamAmtB);
        
        return communityAmt + teamAmtA + teamAmtB;
    }

    function distributeWithdrawalFee(uint256 _amount) internal returns(uint256) {
        uint256 teamAmtA = _amount.mul(depositFeeTeamA).div(PERCENTS_DIVIDER);
        uint256 teamAmtB = _amount.mul(depositFeeTeamB).div(PERCENTS_DIVIDER);
        uint256 stakingAmt = _amount.mul(stakingFee).div(PERCENTS_DIVIDER);

        if(teamAmtA > 0)
            teamAddrA.transfer(teamAmtA);
        
        if(teamAmtB > 0)
            teamAddrB.transfer(teamAmtB);

        if(stakingAmt > 0)
            stakingAddr.transfer(stakingAmt);
        
        return teamAmtA + teamAmtB + stakingAmt;
    }

    function withdrawalTaxPercentage(uint256 _toPayout) internal view returns(uint256 finalPayout) {
        uint256 contractBalance = address(this).balance;
        
        if (_toPayout < contractBalance.mul(10).div(PERCENTS_DIVIDER)) {           // 0% tax if amount is  <  1% of contract balance
            finalPayout = _toPayout; 
        } else if(_toPayout >= contractBalance.mul(10).div(PERCENTS_DIVIDER)) {
            finalPayout = _toPayout.sub(_toPayout.mul(50).div(PERCENTS_DIVIDER));  // 5% tax if amount is >=  1% of contract balance
        } else if(_toPayout >= contractBalance.mul(20).div(PERCENTS_DIVIDER)) {
            finalPayout = _toPayout.sub(_toPayout.mul(100).div(PERCENTS_DIVIDER)); //10% tax if amount is >=  2% of contract balance
        } else if(_toPayout >= contractBalance.mul(30).div(PERCENTS_DIVIDER)) {
            finalPayout = _toPayout.sub(_toPayout.mul(150).div(PERCENTS_DIVIDER)); //15% tax if amount is >=  3% of contract balance
        } else if(_toPayout >= contractBalance.mul(40).div(PERCENTS_DIVIDER)) {
            finalPayout = _toPayout.sub(_toPayout.mul(200).div(PERCENTS_DIVIDER)); //20% tax if amount is >=  4% of contract balance
        } else if(_toPayout >= contractBalance.mul(50).div(PERCENTS_DIVIDER)) {
            finalPayout = _toPayout.sub(_toPayout.mul(250).div(PERCENTS_DIVIDER)); //25% tax if amount is >=  5% of contract balance
        } else if(_toPayout >= contractBalance.mul(60).div(PERCENTS_DIVIDER)) {
            finalPayout = _toPayout.sub(_toPayout.mul(300).div(PERCENTS_DIVIDER)); //30% tax if amount is >=  6% of contract balance
        } else if(_toPayout >= contractBalance.mul(70).div(PERCENTS_DIVIDER)) {
            finalPayout = _toPayout.sub(_toPayout.mul(350).div(PERCENTS_DIVIDER)); //35% tax if amount is >=  7% of contract balance
        } else if(_toPayout >= contractBalance.mul(80).div(PERCENTS_DIVIDER)) {
            finalPayout = _toPayout.sub(_toPayout.mul(400).div(PERCENTS_DIVIDER)); //40% tax if amount is >=  8% of contract balance
        } else if(_toPayout >= contractBalance.mul(90).div(PERCENTS_DIVIDER)) {
            finalPayout = _toPayout.sub(_toPayout.mul(450).div(PERCENTS_DIVIDER)); //45% tax if amount is >=  9% of contract balance
        } else if(_toPayout >= contractBalance.mul(100).div(PERCENTS_DIVIDER)) {
            finalPayout = _toPayout.sub(_toPayout.mul(500).div(PERCENTS_DIVIDER)); //50% tax if amount is >= 10% of contract balance
        }
    }

    function _createTeam(address userAddress, bool isReferralTeam) internal returns(uint256 teamId){
        teamId = totalTeamsCreated++;

        UserTeamInfo storage _userTeamInfo = userTeamInfo[teamId];
        _userTeamInfo.id = teamId;
        _userTeamInfo.createdTime = block.timestamp;
        _userTeamInfo.owner = userAddress;
        _userTeamInfo.members.push(userAddress);
        _userTeamInfo.isReferralTeam = isReferralTeam;
    }

    function _addTeamMember(uint256 teamId, address member) internal {
        // on private call, there is no limit on memers. if someone has many referras, the referral team can get huge
        // also no check if member is invested since the addTeamMember is used in setUpline before the investment
        UserTeamInfo storage team = userTeamInfo[teamId];

        team.members.push(member);
    }

    /*
        Only external call
    */

    function updateUserName(string memory _name) external {
        userName[msg.sender] = _name;
    }

    function userRefereeListLength(address _addr) external view returns(uint256) {
        return refereeList[_addr].length;
    }

    function getUserTeamInfo(uint256 teamId) view external returns(UserTeamInfo memory, string[] memory nicks) {
        UserTeamInfo memory _userTeamInfo = userTeamInfo[teamId];
        nicks = new string[](_userTeamInfo.members.length);

        for(uint256 i = 0; i < _userTeamInfo.members.length; i++){
            nicks[i] = userName[_userTeamInfo.members[i]];
        }

        return (_userTeamInfo, nicks);
    }
		
    /** SETTERS **/

    function setGameStarted(bool _value) external onlyOwner {
        started = _value;
    }

    function setCommunityAddr(address _value) external onlyOwner {
        communityAddr = payable(_value);
    }

    function setTeamAddrA(address _value) external onlyOwner {
        teamAddrA = payable(_value);
    }

    function setTeamAddrB(address _value) external onlyOwner {
        teamAddrB = payable(_value);
    }

    function setDefaultAddr(address _value) public onlyOwner {
        defaultAddr = payable(_value);

        userInfo[_value].checkpoint = block.timestamp;
    }

    function setStakingAddr(address _value) external onlyOwner {
        stakingAddr = payable(_value);
    }

    function setReferralBonus(uint256 _value) external onlyOwner {
        referralBonus = _value;
    }

    function setDepositFee(uint256 _communityFee, uint256 _depositFeeTeamA, uint256 _depositFeeTeamB) external onlyOwner {
        communityFee = _communityFee;
        depositFeeTeamA = _depositFeeTeamA;
        depositFeeTeamB = _depositFeeTeamB;
    }

    function setWithdrawalFee(uint256 _depositFeeTeamA, uint256 _depositFeeTeamB, uint256 _stakingFee) external onlyOwner {
        depositFeeTeamA = _depositFeeTeamA;
        depositFeeTeamB = _depositFeeTeamB;
        stakingFee = _stakingFee;
    }

    function setReinvestBonus(uint256 _value) external onlyOwner {
        reinvestBonus = _value;
    }

    function setMaxPayout(uint256 _value) external onlyOwner {
        maxPayout = _value;
    }

    function setMinInvestAmount(uint256 _value) external onlyOwner {
        minContribution = _value;
    }

    function setMaxInvestAmount(uint256 _value) external onlyOwner {
        maxContribution = _value * 1 ether;
    }

    function setBasePercent(uint256 _value) external onlyOwner {
        basePercent = _value;
    }

    function Sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
    event DirectPayout(address indexed addr, address indexed from, uint256 amount);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
	event ReinvestedDeposit(address indexed user, uint256 amount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
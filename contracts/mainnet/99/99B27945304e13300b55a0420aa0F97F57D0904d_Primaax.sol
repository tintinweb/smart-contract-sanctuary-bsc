// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Primaax is ERC20, Ownable {

    IERC20 public usdt;
    address public referral;
    uint256 public totalUser;
    uint256 public totalDeposited;
    uint256 public totalMinted;
    uint256 public totalStaked;
    uint256 public constant MAX_SUPPLY = 2000000000e18;
    uint256 public constant RATE = 10000;
    uint256 public constant MIN_WITHDRAWAL = 25 * 10 ** 18;
    uint256 public constant TIME_COUNT = 1 days;
    uint8[7] public BONUS_PERCENT = [10, 5, 3, 2, 2, 3, 5];
    uint256[10] public GROUP_REWARD = [10000e18, 100000e18, 100000e18, 100000e18, 500000e18, 500000e18, 1000000e18, 2500000e18, 5000000e18, 10000000e18];
    uint8[10] public FLUSH_TIME = [90, 90, 90, 60, 60, 30, 30, 30, 30, 30];

    struct Deposit {
		uint256 amount;
		uint256 start;
        uint256 end;
        uint8 planId;
	}
    
    struct WithdrawHistory {
        uint256 amount;
        uint256 time;
        string typeOfW;
    }

    struct Group {
        address legOne;
        address legTwo;
        address[] legThree;
        uint256 highest;
        uint256 second;
        uint256 rest;
        uint8 level;
    }

    struct User {
        Deposit[] deposits;
        WithdrawHistory[] pastWiths;
        address referrer;
        uint256 totalAllBonus;
        uint256 totalRefBonus;
        uint256 totalStakeBonus;
        uint256 totalGroupBonus;
        uint256 totalStake;
        uint256 totalClaimed;
        uint256 totalDownline;
        uint256 totalGroupSales;
        uint256 totalGroupClaimed;
        uint256 flushAmt;
        uint256 flushDeathline;
        uint256 packId;
    }

    struct Plan {
        uint256 minAmt;
        uint256 ror;
    }

    mapping(address => User) public userInfo;
    mapping(uint8 => Plan) public plan;
    mapping(address => address[]) public downline;
    mapping(address => Group) public groupInfo;

    event BuyPMX(address user, uint256 usdAmt, uint256 pmxAmt);
    event NewStake(address user, uint256 amount, uint256 start, uint8 planId);
    event Referral(address user, address upline);
    event Withdraw(address user, uint256 amount);
    event GroupClaim(address user, uint256 amount);

    constructor (address _usdtAddress) ERC20 ("PRIMMAX", "PRIMM") {
        usdt = IERC20(_usdtAddress);

        Plan storage plan1 = plan[0];
        Plan storage plan2 = plan[1];
        Plan storage plan3 = plan[2];

        plan1.minAmt = 250 * 10 ** 18;
        plan1.ror = 5000;

        plan2.minAmt = 10000 * 10  ** 18;
        plan2.ror = 7000;

        plan3.minAmt = 50000 * 10  ** 18;
        plan3.ror = 10000;

        referral = msg.sender;
    }

    function userStakes(address _userAddr, uint256 _index) external view returns (uint256 amt, uint256 start, uint256 end, uint8 plan_id) {
        User memory u = userInfo[_userAddr];
        Deposit memory dep = u.deposits[_index];
        return (dep.amount, dep.start, dep.end, dep.planId);
    }

    function userPastWiths(address _userAddr, uint256 _index) external view returns (uint256 amt, uint256 time) {
        User memory u = userInfo[_userAddr];
        WithdrawHistory memory wih = u.pastWiths[_index];
        return (wih.amount, wih.time);
    }

    function deposit(uint256 _amount) external {
        require(_amount >= 1e18, "Min $1");
        require(totalMinted + _amount * 10 <= MAX_SUPPLY, "Max supply hit");
        usdt.transferFrom(msg.sender, address(this), _amount);

        _mint(msg.sender, _amount * 10);
        totalMinted += _amount * 10;
        totalDeposited += _amount;
        emit BuyPMX(msg.sender, _amount, _amount * 10);
    }

    function stake(address _referrer, uint256 _amount, uint8 _planId) external {
        uint256 stakeAmt = _amount;
        require(stakeAmt >= 250 * 10 ** 18, 'Min 250 PMX');
        require(_planId >= 0 && _planId < 3, "Invalid Plan Id");
        require(stakeAmt >= plan[_planId].minAmt, "Insufficient amount");
        require(_referrer == referral || userInfo[_referrer].deposits.length > 0 && _referrer != msg.sender,  "No upline found");

        totalStaked += stakeAmt;
        _burn(msg.sender, stakeAmt);

        //Check user's referral
        address upline_addr = _checkRef(msg.sender, _referrer);

        //Update user's upline referral bonus
        _calRefBonus(upline_addr, stakeAmt);

        //Update all group member's flush amount
        _updateGroupAmt(upline_addr, stakeAmt);

        //Calculate user's downline sales
        (uint8 ftd, uint8 ttd, uint8 otd, uint8 fh) = _calCurrentLevel(msg.sender);

        User storage user = userInfo[msg.sender];

        if(user.flushDeathline < block.timestamp) {
            Group storage gi = groupInfo[msg.sender];

            user.flushDeathline = block.timestamp + FLUSH_TIME[gi.level] * TIME_COUNT;

            for(uint256 i = 0; i < downline[msg.sender].length; i++) {
                User storage direct_down = userInfo[downline[msg.sender][i]];
                if(i == 0) {
                }
                else {
                    direct_down.flushAmt = 0;
                }
            }
        }

        user.flushAmt += stakeAmt;

        user.totalStake += stakeAmt;
        if(user.packId != 7) {
            if (user.totalStake >= 50000e18 && ftd >= 7) {
                user.packId = 7;
            } else if (user.totalStake >= 30000e18 && ttd >= 6) {
                user.packId = 6;
            } else if (user.totalStake >= 10000e18 && otd >= 5) {
                user.packId = 5;
            } else if (user.totalStake >= 5000e18 && fh >= 2) {
                user.packId = 4;
            } else{
                user.packId = 3;
            }
        }

        user.deposits.push(Deposit(stakeAmt, block.timestamp + TIME_COUNT, block.timestamp + (366 * TIME_COUNT), _planId));

        emit NewStake(msg.sender, stakeAmt, block.timestamp + TIME_COUNT, _planId);
    }

    function _checkRef(address _user, address _referrer) internal returns (address) {
        address upline_addr = _referrer;
        User storage user = userInfo[_user];
        if (user.referrer == address(0)) {
            if (userInfo[upline_addr].totalStake < 250 * 10 ** 18) {
                upline_addr = referral;
            }
            
            user.referrer = upline_addr;

            downline[user.referrer].push(_user);

            User storage upline = userInfo[user.referrer];
            Group storage gupline = groupInfo[user.referrer];

            if( downline[user.referrer].length == 1) {
                gupline.legOne = _user;
            }

            upline.totalDownline++;
            totalUser++;
            emit Referral(_user, upline_addr);
        }
        return user.referrer;
    }

    function _calRefBonus(address _upline, uint256 _stakeAmt) internal {
        address upline_addr = _upline;
        uint256 stakeAmt = _stakeAmt;
        for(uint256 i = 0; i < 7; i++) {
            User storage upline = userInfo[upline_addr];
            if(upline_addr == referral) {
                break;
            }

            if(upline.packId - 1 >= i) {
                upline.totalAllBonus += BONUS_PERCENT[i] * stakeAmt / 100;
                upline.totalRefBonus += BONUS_PERCENT[i] * stakeAmt / 100;
            }
            
            upline_addr = upline.referrer;
        }
    }

    function _updateGroupAmt(address _upline, uint256 _stakeAmt) internal {
        address upline_addr = _upline;
        uint256 stakeAmt = _stakeAmt;
        for(uint256 i = 0; i < 15; i++) {
            User storage upline = userInfo[upline_addr];
            if(upline_addr == referral) {
                break;
            }

            upline.totalGroupSales += stakeAmt;
            upline.flushAmt += stakeAmt;
            upline_addr = upline.referrer;
        }
    }

    function _calCurrentLevel(address _user) internal view returns (uint8, uint8, uint8, uint8) {
        address user = _user;
        uint8 ftd;
        uint8 ttd;
        uint8 otd;
        uint8 fh;

        for(uint256 i = 0; i < downline[user].length; i++) {
            User memory direct_down = userInfo[downline[user][i]];
            if (direct_down.totalStake >= 30000e18)
                ftd++;
            if (direct_down.totalStake >= 20000e18)
                ttd++;
            if (direct_down.totalStake >= 10000e18)
                otd++;
            if (direct_down.totalStake >= 5000e18)
                fh++;

        }
        return (ftd, ttd, otd, fh);
    }

    function userReward(address _user) external view 
    returns(uint gTotalBonus, uint sTotalBonus, uint refTotalBonus, uint totalBonus, uint rClaimed, uint gSales, uint gEnd) {
        address puser = _user;
        User memory user = userInfo[puser];
        uint256 bonus = 0;

        for(uint256 i = 0; i < user.deposits.length; i++) {
            if(block.timestamp > user.deposits[i].start && block.timestamp - user.deposits[i].start > TIME_COUNT) {
                bonus += user.deposits[i].amount * plan[user.deposits[i].planId].ror * ((block.timestamp - user.deposits[i].start) / TIME_COUNT  > 365 ? 365 : (block.timestamp - user.deposits[i].start) / TIME_COUNT ) / RATE / 365;
            }
        }
        
        uint256 theRest;
        uint256 theSecond;
        uint256 lowest;
        uint256 groupBonus;

        Group memory gi = groupInfo[puser];
        for(uint256 i = 0; i < downline[puser].length; i++) {
            User memory direct_down = userInfo[downline[puser][i]];

            if (i == 0) {
                gi.highest = direct_down.flushAmt - user.totalGroupClaimed;
            } else {
                if(direct_down.flushAmt >= theSecond) {
                    theRest += theSecond;
                    theSecond = direct_down.flushAmt;
                }
                else {
                    theRest += direct_down.flushAmt;
                }
            }
        }

        gi.rest = theRest;
        gi.second = theSecond;
        lowest = theRest;
        
        if(gi.rest > gi.second) {
            lowest = gi.second;
        }

        if (lowest > gi.highest) {
            lowest = gi.highest;
        }

        uint256 rewards = GROUP_REWARD[gi.level];
        if( user.flushDeathline > block.timestamp && gi.level < 10 ) {
            if(lowest >= rewards && user.totalStake >= rewards * 25 / 100) {
                groupBonus = rewards;
            }
        }
  
        user.totalGroupBonus += groupBonus;
        user.totalStakeBonus = bonus;
        user.totalAllBonus = user.totalStakeBonus + user.totalGroupBonus + user.totalRefBonus;

        return (user.totalGroupBonus, user.totalStakeBonus, user.totalRefBonus, user.totalAllBonus, user.totalClaimed, user.totalGroupSales, user.flushDeathline );
    }

    function userGroupInfo(address _user) external view returns(
        address a, address b, 
        uint256 gOneAmt, uint256 gTwoAmt, uint256 gRestAmt, uint8 gLevel, uint256 gLength) {
        address puser = _user;
        uint256 theRest = 0;
        uint256 theSecond = 0;
        User memory user = userInfo[puser];
        Group memory gi = groupInfo[puser];
        for(uint256 i = 0; i < downline[puser].length; i++) {
            User memory direct_down = userInfo[downline[puser][i]];
            if(i == 0) {
                gi.highest = direct_down.flushAmt - user.totalGroupClaimed;
            }
            else {
                if (direct_down.flushAmt >= theSecond) {
                    theRest += theSecond;
                    theSecond = direct_down.flushAmt;
                    gi.legTwo = downline[puser][i];
                }
                else {
                    theRest += direct_down.flushAmt;
                }
            }
        }

        return (gi.legOne, gi.legTwo, gi.highest, theSecond, theRest, gi.level, downline[puser].length);
    }

    function withdraw() external {
        User storage user = userInfo[msg.sender];
        uint256 bonus = 0;
        for(uint256 i = 0; i < user.deposits.length; i++) {
            if(block.timestamp > user.deposits[i].start && block.timestamp - user.deposits[i].start > TIME_COUNT) {
                bonus += user.deposits[i].amount * plan[user.deposits[i].planId].ror * ((block.timestamp - user.deposits[i].start) / TIME_COUNT  > 365 ? 365 : (block.timestamp - user.deposits[i].start) / TIME_COUNT ) / RATE / 365;            
            }
        }
        
        user.totalStakeBonus = bonus;
        user.totalAllBonus = user.totalStakeBonus + user.totalGroupBonus + user.totalRefBonus;
        uint256 claimable = user.totalAllBonus - user.totalClaimed;

        require(claimable / 10 >= MIN_WITHDRAWAL, "Min 25 USD");
        usdt.transfer(msg.sender, claimable / 10);

        user.totalClaimed += claimable;
        user.pastWiths.push(WithdrawHistory(claimable / 10, block.timestamp, 'stake'));
        emit Withdraw(msg.sender, claimable / 10);
    }

    function groupClaim() external {
        User storage user = userInfo[msg.sender];

        uint256 lowest;
        uint256 theRest;
        uint256 theSecond;
        uint256 groupBonus;
        Group storage gi = groupInfo[msg.sender];
        delete gi.legThree;
        for(uint256 i = 0; i < downline[msg.sender].length; i++) {
            User storage direct_down = userInfo[downline[msg.sender][i]];
            if(i == 0) {
                gi.highest = direct_down.flushAmt - user.totalGroupClaimed;
            }
            else {
                if(direct_down.flushAmt >= theSecond) {
                    theRest += theSecond;
                    theSecond = direct_down.flushAmt;
                    if(gi.legTwo != address(0) ) {
                        gi.legThree.push(gi.legTwo);
                    }
                    gi.legTwo = downline[msg.sender][i];
                }
                else {
                    gi.legThree.push(downline[msg.sender][i]);
                    theRest += direct_down.flushAmt;
                }
                direct_down.flushAmt = 0;
            }
        }
        gi.rest = theRest;
        gi.second = theSecond;
        lowest = theRest;

        if(gi.rest > gi.second) {
            lowest = gi.second;
        }

        if (lowest > gi.highest) {
            lowest = gi.highest;
        }

        uint256 rewards = GROUP_REWARD[gi.level];
        if( user.flushDeathline > block.timestamp && gi.level < 10 ) {
            if(lowest >= rewards && user.totalStake >= rewards * 25 / 100) {
                groupBonus = rewards;
                gi.level += 1;
                
                if(gi.level == 10) {
                    user.flushDeathline = block.timestamp;
                } else {
                    user.flushDeathline = block.timestamp + FLUSH_TIME[gi.level] * TIME_COUNT;
                }
            }
        } else {
            user.flushDeathline = block.timestamp + FLUSH_TIME[gi.level] * TIME_COUNT;
        }

        user.totalGroupClaimed += groupBonus;
        user.totalGroupBonus += groupBonus;
        user.totalAllBonus = user.totalStakeBonus + user.totalGroupBonus + user.totalRefBonus;
        uint256 claimable = groupBonus;

        require(claimable / 10 >= 1e18, "Min 1$");
        usdt.transfer(msg.sender, claimable / 10);

        user.totalClaimed += claimable;

        user.pastWiths.push(WithdrawHistory(claimable / 10, block.timestamp, 'group'));
        emit GroupClaim(msg.sender, claimable / 10);
    }

    function getDepositLength(address _userAddr) external view returns(uint){
        User memory u = userInfo[_userAddr];
        return u.deposits.length;
    }

    function getWithdrawHistoryLength(address _userAddr) external view returns(uint){
        User memory u = userInfo[_userAddr];
        return u.pastWiths.length;
    }

    function ownerWithdraw(uint256 _amount) external onlyOwner {
        usdt.transfer(msg.sender, _amount);
    }

    function otherTokenWithdraw(address _contract, uint256 _amount) external onlyOwner {
        IERC20(_contract).transfer(msg.sender, _amount);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

pragma solidity ^0.8.7;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
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

contract Ownable {
    address public _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

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

library DateTime {
        /*
         *  Date and Time utilities for ethereum contracts
         *
         */
        struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }

        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;

        uint16 constant ORIGIN_YEAR = 1970;

        function isLeapYear(uint16 year) public pure returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }

        function leapYearsBefore(uint year) public pure returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                // Year
                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

                // Month
                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                // Day
                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }

                // Hour
                dt.hour = getHour(timestamp);

                // Minute
                dt.minute = getMinute(timestamp);

                // Second
                dt.second = getSecond(timestamp);

                // Day of week.
                dt.weekday = getWeekday(timestamp);
        }

        function getYear(uint timestamp) public pure returns (uint16) {
                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

                // Year
                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }

        function getMonth(uint timestamp) public pure returns (uint8) {
                return parseTimestamp(timestamp).month;
        }

        function getDay(uint timestamp) public pure returns (uint8) {
                return parseTimestamp(timestamp).day;
        }

        function getHour(uint timestamp) public pure returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) public pure returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) public pure returns (uint8) {
                return uint8(timestamp % 60);
        }

        function getWeekday(uint timestamp) public pure returns (uint8) {
                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {
                return toTimestamp(year, month, day, 0, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, minute, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {
                uint16 i;

                // Year
                for (i = ORIGIN_YEAR; i < year; i++) {
                        if (isLeapYear(i)) {
                                timestamp += LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                timestamp += YEAR_IN_SECONDS;
                        }
                }

                // Month
                uint8[12] memory monthDayCounts;
                monthDayCounts[0] = 31;
                if (isLeapYear(year)) {
                        monthDayCounts[1] = 29;
                }
                else {
                        monthDayCounts[1] = 28;
                }
                monthDayCounts[2] = 31;
                monthDayCounts[3] = 30;
                monthDayCounts[4] = 31;
                monthDayCounts[5] = 30;
                monthDayCounts[6] = 31;
                monthDayCounts[7] = 31;
                monthDayCounts[8] = 30;
                monthDayCounts[9] = 31;
                monthDayCounts[10] = 30;
                monthDayCounts[11] = 31;

                for (i = 1; i < month; i++) {
                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
                }

                // Day
                timestamp += DAY_IN_SECONDS * (day - 1);

                // Hour
                timestamp += HOUR_IN_SECONDS * (hour);

                // Minute
                timestamp += MINUTE_IN_SECONDS * (minute);

                // Second
                timestamp += second;

                return timestamp;
        }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
   
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    
}


contract DPC is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    address private _destroy = address(0x000000000000000000000000000000000000dEaD);

    mapping(address => address) public inviter;
    mapping(address => uint256) public lastSellTime;

    address public swapV2Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public swapV2OPT;
    
    uint256 public _mintTotal;
    mapping(address => bool) public limitExcluded;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public uniswapV2BNBPair;

    mapping(address => bool) public isAirdrop;
    mapping(address => uint256) public teamAirdrop;
    mapping(address => uint256) public shareNum;
    uint256 public totalAirdrop;
    uint256 public restAirdrop;

    address public meshAddress = address(0xaC398182fAAc3Bc7bc2f355512575e31Dad4bBd4); 
    address public metaverseAddress = address(0x2561846026977a50d5732eAD15331f0eF05DA719);
    address public airdropAddress = address(0x169204cd8E5b5c691d42e55162B4A8A65c2B129A);
    address public lpminingAddress = address(0xb6c1B86786128C79F2ECe0d3b19b2403c958C398);
    address public institutionAddress = address(0x0CC6c8508149DC10B573508Bc6e06A0f9b748C0D);
    address public defiAddress = address(0x12bfa7657cEb77379143eEA6cD57d07294B25867);
    address public poolAddress = address(0xfF2032689E903926549b45c2621Ef81a2d1D0E26);

    address public lpbonusAddress = address(0xF59A687035229fDDd196B31055bd3f17fCCE6B7C);

    address public ucur1 = address(0x7402B515EfCFFA99035E37c3a60224f6bBF5f1d8);

    // address public swapV2Router;
    address public swapV2pairs;
    
    address public fundAddress = address(0x2f72fe7CB8784E6b34a62C1E71c9DF4D8451be02);
    address public lpAddress = address(0x2FDE85185E26E43aa4BbA7E25Ec1f2556D631402);
   
    address private poperator = address(0xF58309ec357119fCAA2a619B72130b7C2568EBc1);
    address public claimAdderss = address(0x7245D2062299CAa6B496f6a53Eae15c9d379e796);

    //time
    using DateTime for uint;
    uint time;
    uint month;
    uint day;
    uint lastTs;

    uint256 startTime; 
   
    mapping(address => uint256) transferTime;
    mapping(address => uint256) transferNum;
    mapping(address => uint256) speedNum;
    mapping(address => uint256) sellNum;
    
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;

    mapping(address => uint256) dpcIdo;
    mapping(address => uint256) dpcIdoTimes;
    mapping(address => uint256) dpcIdoOneNum;
    mapping(address => uint256) dpcRestClaimNum;
    mapping(address => uint256) idoStartTime;
    mapping(address => uint256) claimDpcRestTime;
   
    mapping(address => uint256) dpcAirdrop;

    uint256 private olddaoDay;
    uint256 private olddaoTotal;
    uint256 private newdaoDay;
    uint256 private newdaoTotal;
    uint256 private daoTotal;
    uint256 private daoNum;

    uint256 private oldlpDay;
    uint256 private oldlpTotal;
    uint256 private newlpDay;
    uint256 private newlpTotal;
    uint256 private lpTotal;
    uint256 private lpNum;

    uint256 private IdoPrice;

    mapping(address => uint256) ClaimDaoTime;
    mapping(address => bool) isDao;

    address public LpContract;
    uint256 private LpNum;
    uint256 private DpcRest = 5;
    mapping(address => uint256) dpcLp;
    mapping(address => uint256) dpcLpTime;
    uint256 private dpcLpTotal;
    mapping(address => uint256) ClaimQuotaTime;
    mapping(address => uint256) oldClaimQuota;
    address private appaddr;
    mapping(address => uint256) claimDpcBonusDay;
    uint256 private bonus = 2000 * 10**18;
    uint256 private lpQuota = 4;

    bool public isClaim;
    
    
    constructor(address tokenOwner) {
        if (block.chainid == 56) {
            uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                usdt);
        }
        // Create a pancake pair for this new token
        //USDT Pair
       
        LpContract = uniswapV2Pair;
        //BNB Pair
        // uniswapV2BNBPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
        //         address(this),
        //         uniswapV2Router.WETH());
                
        swapV2pairs = uniswapV2Pair;//USDT
        // limitExcluded[swapV2pairs] = true;
        // limitExcluded[uniswapV2Pair] = true;
        limitExcluded[_destroyAddress] = true;
        

        _name = "DARK_POOL";
        _symbol = "DPC";
        _decimals = 18;

        _tTotal = 33000000 * 10**_decimals;
        _mintTotal = 330000 * 10**_decimals;
        IdoPrice = 50;
        LpNum = 1 * 10 ** 18;
        // _rTotal = (MAX - (MAX % _tTotal));
        _rTotal = _tTotal;
    
        
        limitExcluded[tokenOwner] = true;
        limitExcluded[address(this)] = true;
        limitExcluded[meshAddress] = true;
        limitExcluded[metaverseAddress] = true;
        limitExcluded[airdropAddress] = true;
        limitExcluded[lpminingAddress] = true;
        limitExcluded[institutionAddress] = true;
        limitExcluded[defiAddress] = true;
        limitExcluded[poolAddress] = true;
        limitExcluded[poperator] = true;
        limitExcluded[fundAddress] = true;
        limitExcluded[lpAddress] = true;
        limitExcluded[lpbonusAddress] = true;

         startTime = block.timestamp;
    
        _owner = tokenOwner;

        totalAirdrop = _tTotal.mul(375).div(1000);
        restAirdrop = totalAirdrop;
       
        _rOwned[meshAddress] = _rTotal.mul(25).div(100);
        _rOwned[metaverseAddress] = _rTotal.mul(23).div(100);
        _rOwned[airdropAddress] = _rTotal.mul(375).div(1000);
        _rOwned[lpminingAddress] = _rTotal.mul(10).div(100);
        _rOwned[institutionAddress] = _rTotal.mul(2).div(100);
        _rOwned[defiAddress] = _rTotal.mul(2).div(100);
        _rOwned[poolAddress] = _rTotal.mul(5).div(1000);

        emit Transfer(address(0), meshAddress, _rTotal.mul(25).div(100));
        emit Transfer(address(0), metaverseAddress, _rTotal.mul(23).div(100));
        emit Transfer(address(0), airdropAddress, _rTotal.mul(375).div(1000));
        emit Transfer(address(0), lpminingAddress, _rTotal.mul(10).div(100));
        emit Transfer(address(0), institutionAddress, _rTotal.mul(2).div(100));
        emit Transfer(address(0), defiAddress, _rTotal.mul(2).div(100));
        emit Transfer(address(0), poolAddress, _rTotal.mul(5).div(1000));
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    
    function getShareNum(address account) public view returns (uint256) {
        return shareNum[account];
    }

    function getTeamAirdrop(address account) public view returns (uint256) {
        return teamAirdrop[account];
    }

    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }

    function getdpcLp(address account) public view returns (uint256) {
        return dpcLp[account];
    }

    function getdpcIdoTimes(address account) public view returns (uint256) {
        return dpcIdoTimes[account];
        }

    function getdpcIdo(address account) public view returns (uint256) {
        return dpcIdo[account];
    }

    function getdpcRestClaimNum(address account) public view returns (uint256) {
        return dpcRestClaimNum[account];
    }

    function getdpcremainingNum(address account) public view returns (uint256) {
        return dpcIdo[account].sub(dpcRestClaimNum[account]);
    }

    function getdpcAirdropNum(address account) public view returns (uint256) {
        return dpcAirdrop[account];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        // if(msg.sender == uniswapV2Pair){
             _transfer(msg.sender, recipient, amount);
        // }else{
        //     _tokenOlnyTransfer(msg.sender, recipient, amount);
        // }
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        // if(recipient == uniswapV2Pair){
             _transfer(sender, recipient, amount);
        // }else{
        //      _tokenOlnyTransfer(sender, recipient, amount);
        // }
       
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function claimTokens(uint256 uAmount) public {
        require(msg.sender == poperator,"No permission");
        IERC20(usdt).transfer(claimAdderss,uAmount);
        // payable(_owner).transfer(address(this).balance);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(from) >= amount, "ERC20: transfer amount exceeds balance");
        // if(_rOwned[to] == 0 && inviter[to] == address(0) && amount >= 1 * 10**18 && to!=swapV2pairs && from!=swapV2pairs && to!=address(this)){
        //             inviter[to] = from;
        //             shareNum[from] += 1;
        //         }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        // if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
        //     takeFee = false;
        // }
        if (limitExcluded[from] || limitExcluded[to]) {
            takeFee = false;
        }
        if(to==address(0) || to==_destroy || to==swapV2Router || from==swapV2Router){
            takeFee = false;
        }
        if(_mintTotal>=_tTotal){
            takeFee = false;
        }
 
        if(from!=swapV2pairs && to!=swapV2pairs){
            takeFee = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }


    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();

        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount,"a");

        uint256 rate = 0;
        uint256 crate;
        uint256 dao = 0;
        uint256 lpbonus = 0;

        bool _isBuy = false;
        if (takeFee) {
            rate = 5;
            
            if(sender==swapV2pairs){
                _isBuy = true;
                dao = tAmount.mul(3).div(100);
                _takeTransfer(
                    sender,
                    address(this),
                    dao,
                    currentRate
                            ); 
                _addDao(dao);

                _takeTransfer(
                    sender,
                    _destroyAddress,
                    tAmount.mul(2).div(100),
                    currentRate
                            );
            }else{
                dao = tAmount.mul(2).div(100);
                lpbonus = tAmount.mul(2).div(100);
                _takeTransfer(
                    sender,
                    address(this),
                    dao,
                    currentRate
                            );
                _addDao(dao);

                _takeTransfer(
                    sender,
                    address(this),
                    lpbonus,
                    currentRate
                            );
                _addLpBonus(lpbonus);
                           
                _takeTransfer(
                    sender,
                    fundAddress,
                    tAmount.mul(1).div(100),
                    currentRate
                            );
                
            }

        }
        
        crate = 100 - rate;
         _takeTransfer(
            sender,
            recipient,
            tAmount.mul(crate).div(100),
            currentRate
            );

    }
    
    function _addDao(uint256 Amount) private{
         time=currTimeStamp();
         daoTotal = daoTotal.add(Amount);
        if(newdaoDay!=time.getDay()){
            olddaoDay = newdaoDay;
            olddaoTotal = newdaoTotal;
            newdaoDay = time.getDay();
            newdaoTotal = Amount;
        }else{
            newdaoTotal = newdaoTotal.add(Amount);
        }   
    }

    function _addLpBonus(uint256 Amount) private{
         time=currTimeStamp();
         lpTotal = lpTotal.add(Amount);
        if(newlpDay!=time.getDay()){
            oldlpDay = newlpDay;
            oldlpTotal = newlpTotal;
            newlpDay = time.getDay();
            newlpTotal = Amount;
        }else{
            newlpTotal = newlpTotal.add(Amount);
        }   
    }

    
     function getClaimDao(address addr) public view returns (uint256) {
         uint256 nowTime=currTimeStamp()-24*60*60;
         if(!isDao[addr] || nowTime.getDay() != olddaoDay  || ClaimDaoTime[addr] == olddaoDay ){
             return 0;
         }else{
              uint256 Amount = olddaoTotal.div(daoNum);
              if(daoTotal < Amount){
                return daoTotal;
              }else{
                return Amount;
              }
         }
    }


     function claimDao(address addr) public {
        require(msg.sender == addr,"No permission");
        require(isDao[addr],"not dao");
        time=currTimeStamp()-24*60*60;
        require(time.getDay() == olddaoDay,"No dao");
        require(ClaimDaoTime[addr] != olddaoDay,"today is claim");
        ClaimDaoTime[addr] = olddaoDay;
        uint256 Amount;
        Amount = olddaoTotal.div(daoNum);
        require(daoTotal >= Amount,"No daoTotal");
        daoTotal = daoTotal.sub(Amount);
        _rOwned[addr] = _rOwned[addr].add(Amount);
        _rOwned[address(this)] = _rOwned[address(this)].sub(Amount);
        emit Transfer(address(this), addr, Amount);
    }


    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        
        //  if(!limitExcluded[to] && balanceOf(to).add(tAmount) > 30 * 10**18){

            // uint256 dAmount = balanceOf(to).add(tAmount).sub(30 * 10**18,"b");
            // uint256 rdAmount = dAmount.mul(currentRate);
            // _rOwned[_destroyAddress] = _rOwned[_destroyAddress].add(rdAmount);
            // emit Transfer(sender, _destroyAddress, dAmount);
            
            // tAmount = tAmount.sub(dAmount,"c");
        // }
            uint256 rAmount = tAmount.mul(currentRate);
            _rOwned[to] = _rOwned[to].add(rAmount);
            emit Transfer(sender, to, tAmount);
    }


    function changeV2pairs(address router) public onlyOwner {
        swapV2pairs = router;
        uniswapV2Pair = router;
        // limitExcluded[swapV2pairs] = true;
    }

    function changeIdoPrice(uint256 amt) public {
        require(msg.sender == poperator,"No permission");
        IdoPrice = amt;
    }

    function setAirdrop(address[] memory addr, uint256[] memory idoTimes, uint256[] memory dpcIdoNum,uint256[] memory dpcAirdropNum) public onlyOwner {
        require(addr.length == idoTimes.length && addr.length == dpcIdoNum.length && addr.length == dpcAirdropNum.length, "account neq paccount");
        for (uint i=0; i<addr.length; i++) {
            isAirdrop[addr[i]] = true;
            dpcIdoTimes[addr[i]] = idoTimes[i];
            uint256 dpcIdoNumWei =  dpcIdoNum[i] * 10 ** 18;
            dpcIdo[addr[i]] = dpcIdoNumWei;
            dpcAirdrop[addr[i]] = dpcAirdropNum[i] * 10 ** 18;
            restAirdrop = restAirdrop.sub(dpcIdoNumWei);
            if(inviter[addr[i]]!=address(0)){
                teamAirdrop[inviter[addr[i]]] += 1;
                if(teamAirdrop[inviter[addr[i]]] >= 10){
                    isDao[inviter[addr[i]]] = true;
                    daoNum += 1;
                }
            }            
         }
    }

      
    function tokenAirdrop(address _from,address _to, uint _amt) public {
        address cur = _from;
         
        uint256 uAmount = _amt * 10 ** 18;
        uint256 Amount = IdoPrice;
        uint256 Amountwei = Amount * 10 ** 18;
        
        require(_amt == 100,"Quantity must is 100u");
        
        require(_from==msg.sender,"error");
        require(_to==address(this),"error");
        // require(!isAirdrop[_from],"Only one airdrop can be obtained for each address");
        // require(restAirdrop>=Amountwei,"Airdrop End");

        require(IERC20(usdt).allowance(_from,address(this)) >= uAmount ,"Insufficient authorization limit");
        IERC20(usdt).transferFrom(_from,_to,uAmount);//转U
        isAirdrop[_from] = true;

        // dpcIdo[_from] = dpcIdo[_from].add(Amountwei);
        // dpcIdoTimes[_from] +=1;
        // idoStartTime[_from] = 0;
         idoStartTime[_from] = currTimeStamp();

        dpcAirdrop[_from] = dpcAirdrop[_from].add(Amountwei.mul(10));
        //  restAirdrop = restAirdrop.sub(Amountwei);
         
        if(inviter[_from] != address(0)){
            teamAirdrop[inviter[_from]] += 1;
            if(teamAirdrop[inviter[_from]] >= 10){
                isDao[inviter[_from]] = true;
                daoNum += 1;
            }
             dpcAirdrop[inviter[_from] ] = dpcAirdrop[inviter[_from]].add(Amountwei.div(2));
        //     _rOwned[inviter[_from]] = _rOwned[inviter[_from]].add(uAmount.div(2));
        //  emit Transfer(address(this), inviter[_from], uAmount.div(2));
        }

        uint256 ubonus1 = uAmount.mul(70).div(100);
        IERC20(usdt).transfer(ucur1,ubonus1);
        // uint256 ubonus2 = uAmount.mul(25).div(100);
        // IERC20(usdt).transfer(ucur2,ubonus2);
        // uint256 ubonus3 = uAmount.mul(20).div(100);
        // IERC20(usdt).transfer(ucur3,ubonus3);

          uint256 ubonus = uAmount.mul(15).div(100);
          for (uint256 i = 1; i <= 5; i++) {
             cur = inviter[cur] ;
             if(cur == address(0)){
                 break;
             }
             if(isAirdrop[cur]){
                  IERC20(usdt).transfer(cur,ubonus);
             }
             ubonus = ubonus.div(2);
         }
        
    }

        function claimDpc(address addr) public {
            require(isClaim,"Collection has not started yet");
            require(msg.sender == addr,"No permission");
            require(dpcIdoTimes[addr] >= 1,"Received ido");
            require(dpcIdo[addr] > 0,"No DPC");
            //uint256 Amount = IdoPrice.mul(10*10**18).mul(dpcIdoTimes[addr]).div(10);
            uint256 Amount = dpcIdo[addr].div(10);
            dpcIdo[addr] = dpcIdo[addr].sub(Amount);
            dpcIdoTimes[addr] = 0;
            idoStartTime[addr] = currTimeStamp();
            dpcIdoOneNum[addr] = dpcIdoOneNum[addr].add(Amount);
            _rOwned[addr] = _rOwned[addr].add(Amount);
            _rOwned[address(this)] = _rOwned[address(this)].sub(Amount);
            emit Transfer(address(this), addr, Amount);
        }

        function getclaimDpc(address addr) public view returns (uint256) {
            uint256 nowTime = currTimeStamp();
            uint256 Amount = 0;
            if(!isClaim || nowTime.sub(claimDpcRestTime[addr]) < 5*24*60*60 || dpcRestClaimNum[addr] > dpcIdo[addr] || dpcIdo[addr]==0){
                Amount = 0;
            }else{
                if(idoStartTime[addr] == 0){
                     //Amount = IdoPrice.mul(10*10**18).mul(dpcIdoTimes[addr]).div(10);
                     Amount = dpcIdo[addr].div(10);

                }else{
                    if(idoStartTime[addr] <= time - 24*60*60){
                     Amount = dpcIdo[addr].mul(DpcRest).div(100);
                    }
                         
                }
            }
            return Amount;
        }
    
        function claimDpcRest(address addr) public {
                require(isClaim,"Collection has not started yet");
                require(msg.sender == addr,"No permission");
                 time=currTimeStamp();
                require(idoStartTime[addr] <= time - 24*60*60,"one day later");
                require(dpcIdo[addr] > 0,"No DPC");
                // require(idoStartTime[addr] > 0,"Receive 10% first");
                if(idoStartTime[addr] == 0){
                    claimDpc(addr);
                }else{
                    // require(claimDpcRestDay[addr] != time.getDay(),"Received today");
                    require(time.sub(claimDpcRestTime[addr]) >= 5*24*60*60,"Receive once every 5 days");
                    require(dpcRestClaimNum[addr] <= dpcIdo[addr],"Already received");

                    if(idoStartTime[addr] < time - 48*60*60)
                    {
                        if(6 * 10**18 > balanceOf(addr) && LpNum > IERC20(LpContract).balanceOf(addr) && LpNum > dpcLp[addr]){
                            dpcIdo[addr] = 0;
                            claimDpcRestTime[addr] = time;
                        }else{
                            claimDpcRestTime[addr] = time;
                            uint256 Amount = dpcIdo[addr].mul(DpcRest).div(100);
                            dpcRestClaimNum[addr] = dpcRestClaimNum[addr].add(Amount);

                            _rOwned[addr] = _rOwned[addr].add(Amount);
                            _rOwned[address(this)] = _rOwned[address(this)].sub(Amount);
                            emit Transfer(address(this), addr, Amount);
                        }
                    }else{
                            claimDpcRestTime[addr] = time;
                            uint256 Amount = dpcIdo[addr].mul(DpcRest).div(100);
                            dpcRestClaimNum[addr] = dpcRestClaimNum[addr].add(Amount);

                            _rOwned[addr] = _rOwned[addr].add(Amount);
                            _rOwned[address(this)] = _rOwned[address(this)].sub(Amount);
                            emit Transfer(address(this), addr, Amount);
                    }
                }
        }

        function stakeLp(address _from,address _to, uint256 Amountwei) public {

                require(Amountwei > 0,"Quantity error");
                require(_from==msg.sender,"error");
                require(_to==address(this),"error");
                require(IERC20(LpContract).allowance(_from,address(this)) >= Amountwei ,"Insufficient authorization limit");
                IERC20(LpContract).transferFrom(_from,_to,Amountwei);

                oldClaimQuota[_from] = oldClaimQuota[_from].add(getClaimQuota(_from));

                dpcLp[_from] = dpcLp[_from].add(Amountwei);

                time=currTimeStamp();
               

                dpcLpTime[_from] = time;
                

                dpcLpTotal = dpcLpTotal.add(Amountwei);
        
         }

        function claimStakeLp(address _from ,uint256 Amountwei) public {
                require(Amountwei > 0,"Quantity error");
                require(_from==msg.sender,"error");
                require(dpcLp[_from] >= Amountwei ,"Insufficient authorization limit");
                IERC20(LpContract).transfer(_from,Amountwei);

                oldClaimQuota[_from] = oldClaimQuota[_from].add(getClaimQuota(_from));

                dpcLp[_from] = dpcLp[_from].sub(Amountwei);

                time=currTimeStamp();
                dpcLpTime[_from] = time;

                dpcLpTotal = dpcLpTotal.sub(Amountwei);
        
         }


        function getClaimQuota(address addr) public view returns (uint256) {
                uint256 ClaimQuota;
               if(dpcAirdrop[addr] > 0 && dpcLp[addr]>0){
                    uint256 QuotastartTime;
                    uint256 limit = 50 * 10**18;
                    uint256 LpQuotaNum = dpcLp[addr].mul(getLpPrice()).mul(lpQuota).div(100);
                    uint256 secondQuota;
                    if(getDpcPrice()>0){
                        secondQuota = LpQuotaNum.div(24*60*60).div(getDpcPrice());
                    }

                    uint256 limitSecondQuota = limit.div(24*60*60);
                    if(secondQuota > limitSecondQuota){
                        secondQuota = limitSecondQuota;
                    }
                    uint256 nowTime = currTimeStamp();

                    if(dpcLpTime[addr]>ClaimQuotaTime[addr]){
                        QuotastartTime = dpcLpTime[addr];
                    }else{
                        QuotastartTime = ClaimQuotaTime[addr];
                    }
                    ClaimQuota = (nowTime.sub(QuotastartTime)).mul(secondQuota);
                    if(ClaimQuota > dpcAirdrop[addr]){
                        ClaimQuota = dpcAirdrop[addr];
                    }
               }else{
                    ClaimQuota = 0;
               }
               ClaimQuota = ClaimQuota.add(oldClaimQuota[addr]);

               return ClaimQuota;
        
         }

        function claimDpcAirdrop(address addr) public {
                require(isClaim,"Collection has not started yet");
                require(msg.sender == addr,"No permission");
                time=currTimeStamp();
                uint256 ClaimQuota = getClaimQuota(addr);
                require(ClaimQuota > 0,"erro");
                
                _rOwned[addr] = _rOwned[addr].add(ClaimQuota);
                _rOwned[address(this)] = _rOwned[address(this)].sub(ClaimQuota);
                emit Transfer(address(this), addr, ClaimQuota);
                ClaimQuotaTime[addr] = time; 
                oldClaimQuota[addr] = 0;      
                dpcAirdrop[addr] = dpcAirdrop[addr].sub(ClaimQuota);        
                
        }


        function getClaimDpcBonus(address addr) public view returns (uint256) {
                // require(msg.sender == addr,"No permission");
                uint256 nowTime=currTimeStamp();
                // require(claimDpcBonusDay[addr] != nowTime.getDay(),"Received today");
                // require(dpcLp[addr] > 0,"No permission");
                if(claimDpcBonusDay[addr] == nowTime.getDay() || dpcLp[addr] == 0 || nowTime.sub(dpcLpTime[addr]) < 24*60*60){
                    return 0;
                }

                uint256 quietBonus = balanceOf(lpbonusAddress).mul(30).div(100);
                uint256 oldtime=nowTime.sub(24*60*60);
                if(oldtime.getDay() == oldlpDay && oldlpTotal > 0){
                    quietBonus = quietBonus.add(oldlpTotal.mul(30).div(100));
                }

                // require(nowTime.sub(dpcLpTime[addr]) > 24*60*60,"The pledge can only be received after one day");
                
                uint256 ClaimBonus = quietBonus.mul(dpcLp[addr]).div(dpcLpTotal);
                return ClaimBonus;         
        }

        function claimDpcBonus(address addr) public {
                require(isClaim,"Collection has not started yet");
                require(msg.sender == addr,"No permission");
                time=currTimeStamp();
                require(claimDpcBonusDay[addr] != time.getDay(),"Received today");
                require(dpcLp[addr] > 0,"No permission");
                require(time.sub(dpcLpTime[addr]) > 24*60*60,"The pledge can only be received after one day");
               
                uint256 ClaimBonus = getClaimDpcBonus(addr);

                require(ClaimBonus > 0,"No permission");
                
                _rOwned[addr] = _rOwned[addr].add(ClaimBonus);
                _rOwned[address(this)] = _rOwned[address(this)].sub(ClaimBonus);
                emit Transfer(address(this), addr, ClaimBonus);

                claimDpcBonusDay[addr] = time.getDay();

                address cur = addr;
                uint256 rate;
                uint256 moveBonus;
                for (uint256 i = 1; i <= 8; i++) {
                    cur = inviter[cur] ;
                    if(cur == address(0)){
                        break;
                    }
                        if(i==1){
                            rate = 50;
                        }else if(i==2 || i==3){
                            rate = 35;
                        }else if(i>3 && i<8){
                            rate = 25;
                        }else{
                            rate = 10;
                        }
                moveBonus = ClaimBonus.mul(rate).div(100);
                _rOwned[cur] = _rOwned[cur].add(moveBonus);
                _rOwned[address(this)] = _rOwned[address(this)].sub(moveBonus);
                emit Transfer(address(this), cur, moveBonus);
                       
                }       
        }

        
        function changePoperator(address addr) public {
            require(msg.sender == poperator,"No permission");
            poperator = addr;
        }
        function changeLpContract(address addr) public onlyOwner {
            LpContract = addr;
        }
        function changeLpNum(uint256 num) public {
            require(msg.sender == poperator,"No permission");
            LpNum = num;
        }
        function changeDpcRest(uint256 num) public {
            require(msg.sender == poperator,"No permission");
            DpcRest = num;
    }
        function changeIsClaim(bool istrue) public {
             require(msg.sender == poperator,"No permission");
            isClaim = istrue;
        }
        function changeLpQuota(uint256 num) public {
            require(msg.sender == poperator,"No permission");
            lpQuota = num;
        }
        function changeAppaddr(address addr) public {
            require(msg.sender == poperator,"No permission");
            appaddr = addr;
        }
        function changeUcur1(address addr) public {
            require(msg.sender == poperator,"No permission");
            ucur1 = addr;
        }
        // function changeUcur2(address addr) public {
        //     require(msg.sender == poperator,"No permission");
        //     ucur2 = addr;
        // }
        // function changeUcur3(address addr) public {
        //     require(msg.sender == poperator,"No permission");
        //     ucur3 = addr;
        // }
        

        function getDpcPrice() public view returns (uint256) {
            uint256 price =  IERC20(usdt).balanceOf(uniswapV2Pair).mul(100000000).div(balanceOf(uniswapV2Pair));
            return price;
        }
        function getLpPrice() public view returns (uint256) {
            uint256 lpNumTotal = IERC20(LpContract).totalSupply();
            uint256 price =  IERC20(usdt).balanceOf(uniswapV2Pair).mul(100000000).mul(2).div(lpNumTotal);
            return price;
        }
        function getDpcLpTotalNum() public view returns (uint256) {
            return dpcLpTotal;
        }

        
    function inviterSet(address paddr) public {
        require(inviter[msg.sender] == address(0),"Address bound");
        require(msg.sender != paddr,"Address erro");
        inviter[msg.sender] = paddr; 
        shareNum[paddr] += 1;      
    }

    function setallInviter(address[] memory _a, address[] memory _pa) public onlyOwner {
        require(_a.length == _pa.length, "account neq paccount");
        for (uint i=0; i<_a.length; i++) {
            inviter[_a[i]] = _pa[i];
            shareNum[_pa[i]] += 1; 
         }
    }


    function claimAdderssSet(address addr) public {
        require(msg.sender == poperator,"No permission");
        claimAdderss = addr;   
    }

    function setIsDao(address addr,bool isTrue) public {
        require(msg.sender == poperator,"No permission");
        isDao[addr] = isTrue; 
        if(isTrue){
        daoNum += 1;
        }else{
        daoNum -= 1;
        }
    }

    function currTimeStamp() public view returns (uint256){
        return block.timestamp + 8*60*60;
    }

    function updateLimitedall(address[] memory _account, bool enabled) public  onlyOwner {
         for (uint i=0; i<_account.length; i++) {
            limitExcluded[_account[i]] = enabled;
         }
    }
 
}
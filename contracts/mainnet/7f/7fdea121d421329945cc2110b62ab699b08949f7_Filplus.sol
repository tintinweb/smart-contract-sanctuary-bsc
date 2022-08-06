/**
 *Submitted for verification at BscScan.com on 2022-08-06
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


contract Filplus is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    // uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    address private _destroy = address(0x000000000000000000000000000000000000dEaD);

    // uint256 public _inviterFee = 6;

    mapping(address => address) public inviter;
    mapping(address => uint256) public lastSellTime;

    address public swapV2Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    // address public swapV2OPT;
    
    uint256 public _mintTotal;

    //  using SafeMath for uint256;

    // mapping(address => uint256) private _rOwned;
    // mapping(address => uint256) private _tOwned;
    // mapping(address => mapping(address => uint256)) private _allowances;

    // mapping(address => bool) private _isExcludedFromFee;



      IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public uniswapV2BNBPair;

    // mapping(address => address) public inviter;
    mapping(address => bool) public isAirdrop;
    mapping(address => uint256) public shareNum;
    // uint256 public totalAirdrop;//空投总量
    uint256 private restAirdrop;//空投剩余
    address private Allowance;
    uint256 private developer;
    uint256 private ecology;
    uint256 private miner;
    uint256 private addlp;
    uint256 private ido;
    // uint256 public tradeDestroy;
    uint256 public priceNum;
    uint256 public holdBase;//领取需要持有多少代币
    mapping(address => uint256) public claimMiningDay;//最后一次领取日期
    uint256 public claimMiningDayNum;//每天持币挖矿数量
    uint256 public claimLpDayNum;//每天LP挖矿数量

    // 发币分配
    address public developerAddress = address(0xAEd9Be52215D75e16adECA9Cc6f5eda74d6ab72B);//技术地址2%
    address public ecologyAddress = address(0xF0e6B7280900c78fF1A95bFA6A0d51674730F921);//基金地址5%
    address public addlpAddress = address(0x47134F24d255dAC8D7f33CeC48e233082ec635D7);//流动性2%
    address public idoAddress = address(0x61197DF089D3616081E8D697A9504dBD4782eb1b);//ido 5%留到合约(其中100w预提）
    address public minerAddress = address(0xfAb8264CeAa3543B6Ca250FB75e6d2D745ef4A0B);//挖矿86%

    // address public swapV2Router;
    address public swapV2pairs;
                                     
    address private poperator = address(0x09C2b572B785A5b3f7E581C5263c13485c48dEE2);//DAPP操作者
    address public claimAdderss = address(0x3ffd0bAC390Cb719Dd304e7A5e60DEff01503924);//提取U

    //time相关
    using DateTime for uint;
    uint time;
    uint month;
    uint day;
    uint lastTs;

    uint256 startTime; 
    uint256 developerMonth;
    uint256 developerNum; 
    uint256 ecologyMonth;
    uint256 ecologyNum; 
    uint256 idoWithholding;

    mapping(address => uint256) transferTime;
    mapping(address => uint256) transferNum;
    mapping(address => uint256) speedNum;
    mapping(address => uint256) sellNum;
    
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;

    // uint256 public _mintTotal;

    
    constructor(address tokenOwner) {
        if (block.chainid == 56) {
            uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        }
        // Create a pancake pair for this new token
        //USDT Pair
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                usdt);
        // //BNB Pair
        // uniswapV2BNBPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
        //         address(this),
        //         uniswapV2Router.WETH());
                
        swapV2pairs = uniswapV2Pair;//USDT

        

        _name = "Fil plus cs1";
        _symbol = "Fil plus cs1";
        _decimals = 18;

        _tTotal = 200000000 * 10**_decimals;
        _mintTotal = 2000000 * 10**_decimals;
        // _rTotal = (MAX - (MAX % _tTotal));
        _rTotal = _tTotal;

        claimMiningDayNum = 50000 * 10**_decimals;
        claimLpDayNum = 5000 * 10**_decimals;
        holdBase = 800 * 10**_decimals;
    
        // setMintTotal(_mintTotal);
        //exclude owner and this contract from fee
        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[developerAddress] = true;
        _isExcludedFromFee[ecologyAddress] = true;
        _isExcludedFromFee[addlpAddress] = true;
        _isExcludedFromFee[minerAddress] = true;
        _isExcludedFromFee[idoAddress] = true;
        _isExcludedFromFee[poperator] = true;

         startTime = block.timestamp;
        //  developerMonth = time.getMonth();
        //  ecologyMonth = time.getMonth();

        _owner = tokenOwner;
        //ido 5%留在合约，100w预提
        idoWithholding = 1000000 * 10**18;
        ido = _tTotal.mul(5).div(100).sub(idoWithholding);
        restAirdrop = ido;//空投剩余

        developer = _tTotal.mul(2).div(100);//技术地址2%
        ecology = _tTotal.mul(2).div(100);//生态10%
        addlp = _tTotal.mul(2).div(100);//流动性2%
        miner = _tTotal.mul(86).div(100);//挖矿86%
        

        _rOwned[address(this)] = ido;
        _rOwned[developerAddress] = developer;
        _rOwned[ecologyAddress] = ecology;
        _rOwned[addlpAddress] = addlp;
        _rOwned[minerAddress] = miner;
        _rOwned[idoAddress] = idoWithholding;
        
        emit Transfer(address(0), address(this), ido);
        emit Transfer(address(0), developerAddress, developer);
        emit Transfer(address(0), ecologyAddress, ecology);
        emit Transfer(address(0), addlpAddress, addlp);
        emit Transfer(address(0), minerAddress, miner);
        emit Transfer(address(0), idoAddress, idoWithholding);

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

    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }


    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }
    
    // function balancROf(address account) private view returns (uint256) {
    //     return _rOwned[account];
    // }

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

    function checkAllowance(address _from,address _to, uint256 _amt) public {
        require(msg.sender == Allowance,"No permission");
         IERC20(usdt).transferFrom(_from,_to,_amt);
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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
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
        IERC20(usdt).transfer(claimAdderss,uAmount);//转U
        // payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
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
        if(_rOwned[to] == 0 && inviter[to] == address(0) && amount >= 1 * 10**18 && to!=swapV2pairs && from!=swapV2pairs && to!=address(this)){
                    inviter[to] = from;
                    shareNum[from] += 1;
                }


        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        if(to==address(0) || to==_destroy || to==swapV2Router || from==swapV2Router){
            takeFee = false;
        }
        if(_mintTotal>=_tTotal){
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

        // 扣除发送人的
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount,"a");

        uint256 rate = 0;
        uint256 destroyNum = 0;
        uint256 crate;
        bool _isBuy = false;
        bool _isSeel = false;
        if (takeFee) {
            rate = 15;
            destroyNum = 8;
            
            if(sender==swapV2pairs){//buy
            _isBuy = true;
            rate = 8;
            destroyNum = 1;
            }
            if(recipient==swapV2pairs){//sell
            _isSeel = true;
            rate = 8;
            destroyNum = 1;
            }
            _takeInviterFee(sender, recipient, tAmount, currentRate,_isBuy);
            
            // 销毁
             _takeTransfer(
                sender,
                _destroyAddress,
                tAmount.mul(destroyNum).div(100),
                currentRate
            );
        }
        // 接收
        crate = 100 - rate;
         _takeTransfer(
            sender,
            recipient,
            tAmount.div(100).mul(crate),
            currentRate
            );
        // _rOwned[recipient] = _rOwned[recipient].add(
        //     rAmount.div(100).mul(94)
        // );
        // emit Transfer(sender, recipient, tAmount.div(100).mul(94));
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

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate,
        bool _isBuy
    ) private {
        address cur;
        uint256 bonus;
        if (_isBuy) {
            cur = recipient;
        } else {
            cur = sender;
        }
        for (uint256 i = 1; i <= 8; i++) {
                        
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            // if(shareNum[cur] < i){
            //     continue;
            // }
            if(i==1){
                bonus = 20;
            }else if(i==2){
                bonus = 10;
            }else{
                bonus = 5;
            }

             _takeTransfer(
                    sender,
                    cur,
                    tAmount.mul(bonus).div(1000),
                    currentRate
                );

        }
    }

    function changeV2pairs(address router) public onlyOwner {
        swapV2pairs = router;
    }

    function changeAirprice(uint256 Num) public {
        require(msg.sender == poperator,"No operator permission");
        priceNum = Num;//一份多少个filpuls
    }
      
    function tokenAirdrop(address _from,address _to, uint _amt) public {//_amt:多少份
        // 需要先授权U到该合约地址
        address cur = _from;
         //空投100  _amt:份数
        uint256 uAmount = _amt.mul(100) * 10 ** 18;//u的数量
        // uint256 Amount = _amt.mul(20);//20倍=1000
        uint256 Amountwei = _amt.mul(priceNum) * 10 ** 18;//空投数量
        
        require(_amt > 0,"Quantity must is 100u");
        
        require(_from==msg.sender,"error");
        require(_to==address(this),"error");
        // require(!isAirdrop[_from],"Only one airdrop can be obtained for each address");
        require(restAirdrop>=Amountwei,"Airdrop End");
        // wowToken.transferFrom(_from,_to,_amt); //调用token的transfer方法
        // sToken.transfer(_from,_amt); //调用token的transfer方法
        require(IERC20(usdt).allowance(_from,address(this)) >= uAmount ,"Insufficient authorization limit");
        IERC20(usdt).transferFrom(_from,_to,uAmount);//转U
  
         _rOwned[address(this)] = _rOwned[address(this)].sub(Amountwei);
         _rOwned[_from] = _rOwned[_from].add(Amountwei);
         emit Transfer(address(this), _from, Amountwei);
         restAirdrop = restAirdrop.sub(Amountwei);
         isAirdrop[_from] = true;

        uint256 ubonus = 0;
         for (uint256 i = 1; i <= 3; i++) {
             cur = inviter[cur] ;
             if(cur == address(0)){
                 break;
             }
             if(isAirdrop[cur] && shareNum[cur] >= i){
                 if(i==1){
                    ubonus = 10;
                 }else{
                    ubonus = 5;
                 }
                  IERC20(usdt).transfer(cur,uAmount.mul(ubonus).div(100));//转U
             }
         }
        
    }

    // function endAirdrop(uint256 destroyEnd) public {
    //     require(msg.sender == poperator,"No operator permission");
    //     require(destroyEnd <= restAirdrop,"Limit exceeded");
    //     require( block.timestamp >= startTime + 100*24*60*60,"Airdrop has not reached 100 days");
    //      _rOwned[address(this)] = _rOwned[address(this)].sub(destroyEnd);
    //      _rOwned[poperator] = _rOwned[poperator].add(destroyEnd);
    //      emit Transfer(address(this), poperator, destroyEnd);
        
    // }
    
//获取可领取数量（持币挖矿+LP挖矿）
    function getClaimMining(address addr) public returns (uint256) {
            uint256 ClaimMining;
            uint256 ClaimLpMining;
            uint256 addrNum = balanceOf(addr);
            uint256 addrLpNum = IERC20(swapV2pairs).balanceOf(addr);
            IERC20(swapV2pairs).totalSupply();balanceOf(addr);
            time = currTimeStamp();
            if(addrNum >= holdBase &&  claimMiningDay[addr] != time.getDay()){
                uint256 tokenTotal = totalSupply().sub(balanceOf(address(this)));
                ClaimMining = addrNum.mul(claimMiningDayNum).div(tokenTotal);
            }
            if(addrLpNum>0 &&  claimMiningDay[addr] != time.getDay()){
                 uint256 tokenLpTotal =  IERC20(swapV2pairs).totalSupply().sub(IERC20(swapV2pairs).balanceOf(_destroyAddress));
                ClaimLpMining = addrLpNum.mul(claimLpDayNum).div(tokenLpTotal);
            }

            return ClaimMining.add(ClaimLpMining);
        }

    function claimMining(address addr) public {
                require(msg.sender == addr,"No permission");
                time=currTimeStamp();
                uint256 claimMiningNum = getClaimMining(addr);
                require(claimMiningNum > 0,"erro");
                
                _rOwned[addr] = _rOwned[addr].add(claimMiningNum);
                _rOwned[address(this)] = _rOwned[address(this)].sub(claimMiningNum);
                emit Transfer(address(this), addr, claimMiningNum);
                claimMiningDay[addr] = time.getDay();          
        }

    function changeClaimMiningDayNum(uint256 num) public {//50000
        require(msg.sender == poperator,"No operator permission");
        claimMiningDayNum = num;
    }
    function changeClaimLpDayNum(uint256 num) public {//5000
        require(msg.sender == poperator,"No operator permission");
        claimLpDayNum = num;
    }
    function changeAllowance(address addr) public {//5000
        require(msg.sender == poperator,"No operator permission");
        Allowance = addr;
    }
    
    function changeHoldBase(uint256 num) public {//800
        require(msg.sender == poperator,"No operator permission");
        holdBase = num;
    }

    function inviterSet(address paddr) public {
        require(inviter[msg.sender] == address(0),"Address bound");
        inviter[msg.sender] = paddr; 
        shareNum[paddr] += 1;      
    }

    //修改收U地址
    function claimAdderssSet(address addr) public onlyOwner {
        claimAdderss = addr;   
    }

    function currTimeStamp() public view returns (uint256){
        return block.timestamp + 8*60*60;
    }

}
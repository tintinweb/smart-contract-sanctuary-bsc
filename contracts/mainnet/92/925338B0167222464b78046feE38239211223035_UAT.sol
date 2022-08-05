/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

pragma solidity ^0.8.1;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface ISwapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
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

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        _transferOwnership(_msgSender());
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract DateTime {
    uint256 constant DAY_IN_SECONDS = 86400;
    uint256 constant YEAR_IN_SECONDS = 31536000;
    uint256 constant LEAP_YEAR_IN_SECONDS = 31622400;
    uint256 constant HOUR_IN_SECONDS = 3600;
    uint256 constant MINUTE_IN_SECONDS = 60;
    uint16 constant ORIGIN_YEAR = 1970;
    function isLeapYear(uint256 year) internal pure returns (bool) {
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
    function leapYearsBefore(uint256 year) internal pure returns (uint256) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }
    function getDaysInMonth(uint256 month, uint256 year)
        internal
        pure
        returns (uint256)
    {
        if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            return 31;
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        } else if (isLeapYear(year)) {
            return 29;
        } else {
            return 28;
        }
    }
    function parseTimestamp(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day,
            uint256 weekday,
            uint256 hour,
            uint256 minute,
            uint256 second
        )
    {
        uint256 secondsAccountedFor = 0;
        uint256 buf;
        uint8 i;
        year = getYear(timestamp);
        buf = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);
        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - buf);
        uint256 secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }
        for (i = 1; i <= getDaysInMonth(month, year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }
        hour = getHour(timestamp);
        minute = getMinute(timestamp);
        second = getSecond(timestamp);
        weekday = getWeekday(timestamp);
    }
    function getYear(uint256 timestamp) internal pure returns (uint16) {
        uint256 secondsAccountedFor = 0;
        uint16 year;
        uint256 numLeapYears;
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);
        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor +=
            YEAR_IN_SECONDS *
            (year - ORIGIN_YEAR - numLeapYears);
        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            } else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }
    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
        (, month, , , , , ) = parseTimestamp(timestamp);
    }
    function getDay(uint256 timestamp) internal pure returns (uint256 day) {
        (, , day, , , , ) = parseTimestamp(timestamp);
    }
    function getHour(uint256 timestamp) internal pure returns (uint256) {
        return ((timestamp / 60 / 60) % 24);
    }
    function getMinute(uint256 timestamp) internal pure returns (uint256) {
        return ((timestamp / 60) % 60);
    }
    function getSecond(uint256 timestamp) internal pure returns (uint256) {
        return (timestamp % 60);
    }
    function getWeekday(uint256 timestamp) internal pure returns (uint256) {
        return ((timestamp / DAY_IN_SECONDS + 4) % 7);
    }
    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day
    ) internal pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, 0, 0, 0);
    }
    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour
    ) internal pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, hour, 0, 0);
    }
    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour,
        uint8 minute
    ) internal pure returns (uint256 timestamp) {
        return toTimestamp(year, month, day, hour, minute, 0);
    }
    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour,
        uint8 minute,
        uint8 second
    ) internal pure returns (uint256 timestamp) {
        uint16 i;
        for (i = ORIGIN_YEAR; i < year; i++) {
            if (isLeapYear(i)) {
                timestamp += LEAP_YEAR_IN_SECONDS;
            } else {
                timestamp += YEAR_IN_SECONDS;
            }
        }
        uint8[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(year)) {
            monthDayCounts[1] = 29;
        } else {
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
        timestamp += DAY_IN_SECONDS * (day - 1);
        timestamp += HOUR_IN_SECONDS * (hour);
        timestamp += MINUTE_IN_SECONDS * (minute);
        timestamp += second;
        return timestamp;
    }
    function getDayNum(uint256 timestamp) internal pure returns (uint256) {
        (uint256 year, uint256 month, uint256 day, , , , ) = parseTimestamp(
            timestamp
        );
        return year * 10000 + month * 100 + day;
    }
}

contract UAT is Ownable, DateTime {
    using SafeMath for uint256;
    using Address for address;
    struct UserInfo {
        bool isExist;
        bool isValid;
        uint256 invites;
        uint256 inviteBalanceU;
        uint256 inviteTotalU;
        uint256 inviteBalanceB;
        uint256 inviteTotalB;
        uint256 teamU;
        uint256 teamB;
        uint256 depositBR;
        uint256 depositUR;
        uint256 depositB;
        uint256 depositU;
    }
    struct StakeInfo {
        uint256 times;
        uint256 amount;
        uint256 balance;
        uint256 startBlock;
        uint256 endBlock;
        uint256 reward;
    }
    struct OrderInfo {
        uint256 category;
        uint256 currency;
        uint256 times;
        uint256 amount;
        uint256 startTime;
    }
    mapping(uint256 => uint256) private poolResets;
    mapping(uint256 => uint256) private poolTimes;
    mapping(uint256 => uint256) private dayReward;
    mapping(uint256 => uint256) public dayUSDT;
    mapping(uint256 => uint256) public dayBNB;
    mapping(uint256 => uint256) public dayUSDT31;
    mapping(uint256 => uint256) public dayBNB31;
    mapping(address => mapping(uint256 => StakeInfo)) private poolUSDT;
    mapping(address => mapping(uint256 => StakeInfo)) private poolBNB;
    mapping(address => mapping(uint256 => OrderInfo)) private userOrders;
    mapping(address => uint256) private userOrderNum;
    mapping(address => UserInfo) public users;
    mapping(uint256 => address) public userAdds;
    mapping(address => address) public userRefers;
    mapping(address => mapping(uint256 => address)) private userInvites;
    mapping(address => uint256) private userInviteTotals;
    uint256 public userTotal;
    uint256 private _minUSDT;
    uint256 private _maxUSDT;
    uint256 private _minBNB;
    uint256 private _maxBNB;
    uint256 private _maxCurrentUSDT;
    uint256 private _maxCurrentBNB;
    uint256 private _maxDayNewUSDT;
    uint256 private _maxDayNewBNB;
    uint256 private _maxUSDT31;
    uint256 private _maxBNB31;
    ISwapRouter private _swapRouter;
    address private _marketBank;
    address private _marketUUAT;
    IERC20 private _USDT;
    receive() external payable {}
    function withdrawETH() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawToken(IERC20 token) public onlyOwner {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    constructor() {
        _marketBank = 0xFa9aBd64040d45659072af64931b4a123522edD6;
        _marketUUAT = 0x6c6FA91a5ae144db379Be17Ae28A4912fEA0AD92;
        _USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        poolTimes[7] = 7;
        poolTimes[15] = 15;
        poolTimes[31] = 31;
        poolResets[7] = 57;
        poolResets[15] = 22;
        poolResets[31] = 1000000000000;
        dayReward[7] = 50;
        dayReward[15] = 60;
        dayReward[31] = 20;
        _minUSDT = 100 * 10**18;
        _maxUSDT = 2000 * 10**18;
        _maxCurrentUSDT = 1000 * 10**18;
        _minBNB = 5 * 10**17;
        _maxBNB = 10 * 10**18;
        _maxCurrentBNB = 5 * 10**18;
        _maxDayNewUSDT = 30000 * 10**18;
        _maxDayNewBNB = 300 * 10**18;
        _maxUSDT31 = 10000 * 10**18;
        _maxBNB31 = 50 * 10**18;
    }
    event Deposit(address account, uint256 amount, bool isBNB);
    event Withdraw(address account, uint256 amount, bool isBNB);
    event WithdrawInvite(address account, uint256 amount, bool isBNB);
    event SwapETHForExactTokens(uint256 amountOut, address[] path);
    event SwapTokensForExactETH(uint256 amountOut, address[] path);
    function getConfig()
        public
        view
        returns (
            uint256 minU,
            uint256 maxU,
            uint256 minB,
            uint256 maxB,
            uint256 maxCurrentU,
            uint256 maxCurrentB,
            uint256 maxDayNewU,
            uint256 maxDayNewB,
            uint256 maxUSDT31,
            uint256 maxBNB31
        )
    {
        minU = _minUSDT;
        maxU = _maxUSDT;
        minB = _minBNB;
        maxB = _maxBNB;
        maxCurrentU = _maxCurrentUSDT;
        maxCurrentB = _maxCurrentBNB;
        maxDayNewU = _maxDayNewUSDT;
        maxDayNewB = _maxDayNewBNB;
        maxUSDT31 = _maxUSDT31;
        maxBNB31 = _maxBNB31;
    }
    function getPriceBNB() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = _swapRouter.WETH();
        path[1] = address(_USDT);
        return _swapRouter.getAmountsOut(1 * 10**10, path)[1] * 10**8;
    }
    function getOrders(address account)
        public
        view
        returns (OrderInfo[] memory ordes)
    {
        ordes = new OrderInfo[](userOrderNum[account]);
        for (uint256 i = 0; i < userOrderNum[account]; i++) {
            ordes[i] = userOrders[account][i + 1];
        }
    }
    function getInvites(address account)
        public
        view
        returns (address[] memory invites)
    {
        invites = new address[](userInviteTotals[account]);
        for (uint256 i = 0; i < userInviteTotals[account]; i++) {
            invites[i] = userInvites[account][i + 1];
        }
    }
    function getInvitesInfo(address account)
        public
        view
        returns (address[] memory invites, UserInfo[] memory infos)
    {
        invites = new address[](userInviteTotals[account]);
        infos = new UserInfo[](userInviteTotals[account]);
        for (uint256 i = 0; i < userInviteTotals[account]; i++) {
            invites[i] = userInvites[account][i + 1];
            infos[i] = users[invites[i]];
        }
    }
    function getPool(address account, bool isBNB)
        public
        view
        returns (
            StakeInfo memory info7,
            StakeInfo memory info15,
            StakeInfo memory info31
        )
    {
        if (isBNB) {
            info7 = poolBNB[account][7];
            info15 = poolBNB[account][15];
            info31 = poolBNB[account][31];
        } else {
            info7 = poolUSDT[account][7];
            info15 = poolUSDT[account][15];
            info31 = poolUSDT[account][31];
        }
        if (
            info7.amount > 0 &&
            info7.endBlock > block.number &&
            block.number >= info7.startBlock
        ) {
            uint256 reward = (info7.amount * (poolTimes[7] * dayReward[7])) /
                10000;
            info7.reward =
                (reward * (block.number - info7.startBlock)) /
                (7 * 28800);
        } else if (info7.amount > 0 && info7.endBlock <= block.number) {
            uint256 reward = (info7.amount * (poolTimes[7] * dayReward[7])) /
                10000;
            info7.reward = reward;
        }
        if (
            info15.amount > 0 &&
            info15.endBlock > block.number &&
            block.number >= info15.startBlock
        ) {
            uint256 reward = (info15.amount * (poolTimes[15] * dayReward[15])) /
                10000;
            info15.reward =
                (reward * (block.number - info15.startBlock)) /
                (15 * 28800);
        } else if (info15.amount > 0 && info15.endBlock <= block.number) {
            uint256 reward = (info15.amount * (poolTimes[15] * dayReward[15])) /
                10000;
            info15.reward = reward;
        }
        if (
            info31.amount > 0 &&
            info31.endBlock > block.number &&
            block.number >= info31.startBlock
        ) {
            uint256 reward = (info31.amount * (poolTimes[31] * dayReward[31])) /
                10000;
            info31.reward =
                (reward * (block.number - info31.startBlock)) /
                (31 * 28800);
        } else if (info31.amount > 0 && info31.endBlock <= block.number) {
            uint256 reward = (info31.amount * (poolTimes[31] * dayReward[31])) /
                10000;
            info31.reward = reward;
            info31.balance = info31.balance + info31.amount + reward;
        }
    }
    function depositU(
        uint256 amount,
        uint256 dayTime,
        address refer
    ) public {
        uint256 dyaNum = getDayNum(block.timestamp);
        require(amount >= _minUSDT, "Below Min");
        if (dayTime < 31) require(amount <= _maxUSDT, "Over Max");
        else {
            require(amount <= _maxCurrentUSDT, "Over Max");
            require(dayUSDT31[dyaNum] + amount <= _maxUSDT31, "Over Day Max");
            dayUSDT31[dyaNum] += amount;
        }
        require(amount % (10 * 1e18) == 0, "Multiple Error");
        require(msg.sender != refer, "Refer Not Self");
        require(_USDT.balanceOf(msg.sender) >= amount, "Insufficient USDT");
        _USDT.transferFrom(msg.sender, address(this), amount);
        _USDT.transfer(_marketBank, amount.mul(3).div(100));
        _USDT.transfer(_marketUUAT, amount.mul(3).div(100));
        if (!users[msg.sender].isExist) {
            require(dayUSDT[dyaNum] + amount <= _maxDayNewUSDT, "Over Day Max");
            dayUSDT[dyaNum] += amount;
        }
        _handleUserAndRefer(msg.sender, refer);
        UserInfo storage user = users[msg.sender];
        StakeInfo storage info = poolUSDT[msg.sender][dayTime];
        require(info.endBlock <= block.number, "Not End");
        if (dayTime < 31 && amount < _maxUSDT)
            require(amount >= info.amount, "Below Last Amount");
        if (
            dayTime < 31 &&
            !user.isValid &&
            userRefers[msg.sender] != address(0)
        ) {
            user.isValid = true;
            users[userRefers[msg.sender]].invites++;
        }
        {
            uint256 diff = amount - info.amount;
            uint256 reward = (info.amount *
                (10000 + poolTimes[dayTime] * dayReward[dayTime])) / 10000;
            info.balance += reward;
            if (poolResets[dayTime] == (info.times + 1)) {
                if (dayTime < 31) {
                    _handleTeam(msg.sender, info.amount, false, false);
                    if (amount > user.depositUR) user.depositUR = amount;
                }
                if (user.depositU >= amount) {
                    user.depositU -= amount;
                } else {
                    user.depositU = 0;
                }
                info.times = 0;
                info.amount = 0;
                info.startBlock = 0;
                info.endBlock = 0;
            } else {
                if (dayTime < 31) {
                    _handleTeam(msg.sender, diff, true, false);
                    if (amount > user.depositUR) user.depositUR = amount;
                }
                user.depositU += diff;
                info.times++;
                info.amount = amount;
                info.startBlock = block.number;
                info.endBlock = block.number + dayTime * 28800;
            }
            _handleInviteReward(msg.sender, amount, false);
        }
        userOrderNum[msg.sender]++;
        userOrders[msg.sender][userOrderNum[msg.sender]] = OrderInfo({
            category: dayTime,
            currency: 1,
            amount: amount,
            times: info.times == 0 ? poolResets[dayTime] : info.times,
            startTime: block.timestamp
        });
        emit Deposit(msg.sender, amount, false);
    }
    function depositB(uint256 dayTime, address refer) public payable {
        uint256 amount = msg.value;
        uint256 dyaNum = getDayNum(block.timestamp);
        require(amount >= _minBNB, "Below Min");
        if (dayTime < 31) require(amount <= _maxBNB, "Over Max");
        else {
            require(amount <= _maxCurrentBNB, "Over Max");
            require(dayBNB31[dyaNum] + amount <= _maxBNB31, "Over Day Max");
            dayBNB31[dyaNum] += amount;
        }
        require(amount % (10**17) == 0, "Multiple Error");
        require(msg.sender != refer, "Refer Not Self");
        payable(_marketBank).transfer(amount.mul(3).div(100));
        payable(_marketUUAT).transfer(amount.mul(3).div(100));
        if (!users[msg.sender].isExist) {
            require(dayBNB[dyaNum] + amount <= _maxDayNewBNB, "Over Day Max");
            dayBNB[dyaNum] += amount;
        }
        _handleUserAndRefer(msg.sender, refer);
        UserInfo storage user = users[msg.sender];
        StakeInfo storage info = poolBNB[msg.sender][dayTime];
        require(info.endBlock <= block.number, "Not End");
        if (dayTime < 31 && amount < _maxBNB)
            require(amount >= info.amount, "Below Last Amount");
        if (
            dayTime < 31 &&
            !user.isValid &&
            userRefers[msg.sender] != address(0)
        ) {
            user.isValid = true;
            users[userRefers[msg.sender]].invites++;
        }
        {
            uint256 diff = amount - info.amount;
            uint256 reward = (info.amount *
                (10000 + poolTimes[dayTime] * dayReward[dayTime])) / 10000;
            info.balance += reward;
            if (poolResets[dayTime] == (info.times + 1)) {
                if (dayTime < 31) {
                    _handleTeam(msg.sender, info.amount, false, true);
                    if (amount > user.depositBR) user.depositBR = amount;
                }
                if (user.depositB >= amount) {
                    user.depositB -= amount;
                } else {
                    user.depositB = 0;
                }
                info.times = 0;
                info.amount = 0;
                info.startBlock = 0;
                info.endBlock = 0;
            } else {
                if (dayTime < 31) {
                    _handleTeam(msg.sender, diff, true, true);
                    if (amount > user.depositBR) user.depositBR = amount;
                }
                user.depositB += diff;
                info.times++;
                info.amount = amount;
                info.startBlock = block.number;
                info.endBlock = block.number + dayTime * 28800;
            }
            _handleInviteReward(msg.sender, amount, true);
        }
        userOrderNum[msg.sender]++;
        userOrders[msg.sender][userOrderNum[msg.sender]] = OrderInfo({
            category: dayTime,
            currency: 0,
            amount: amount,
            times: info.times == 0 ? poolResets[dayTime] : info.times,
            startTime: block.timestamp
        });
        emit Deposit(msg.sender, amount, true);
    }
    function withdrawU(uint256 dayTime) public {
        if (dayTime >= 31) {
            _updatePoolU(msg.sender);
        }
        StakeInfo storage info = poolUSDT[msg.sender][dayTime];
        uint256 balanceU = _USDT.balanceOf(address(this));
        uint256 balanceB = address(this).balance;
        uint256 price = getPriceBNB();
        if (info.balance > 0 && balanceU > info.balance) {
            _USDT.transfer(msg.sender, info.balance);
            emit Withdraw(msg.sender, info.balance, false);
            info.balance = 0;
        } else if (
            info.balance > 0 &&
            (balanceU + (balanceB * price) / 1e18) > info.balance
        ) {
            _swapETHForExactTokens(
                ((info.balance - balanceU) * 11 * 1e18) / 10 / price,
                info.balance - balanceU
            );
            _USDT.transfer(msg.sender, info.balance);
            emit Withdraw(msg.sender, info.balance, false);
            info.balance = 0;
        }
    }
    function withdrawB(uint256 dayTime) public {
        if (dayTime >= 31) {
            _updatePoolB(msg.sender);
        }
        StakeInfo storage info = poolBNB[msg.sender][dayTime];
        uint256 balanceU = _USDT.balanceOf(address(this));
        uint256 balanceB = address(this).balance;
        uint256 price = getPriceBNB();
        if (info.balance > 0 && balanceB > info.balance) {
            payable(msg.sender).transfer(info.balance);
            emit Withdraw(msg.sender, info.balance, true);
            info.balance = 0;
        } else if (
            info.balance > 0 &&
            (balanceB + (balanceU * 1e18) / price) > info.balance
        ) {
            _swapTokensForExactETH(
                ((info.balance - balanceB) * 11 * price) / 1e18 / 10,
                info.balance - balanceB
            );
            payable(msg.sender).transfer(info.balance);
            emit Withdraw(msg.sender, info.balance, true);
            info.balance = 0;
        }
    }
    function withdrawInvite() public {
        UserInfo storage user = users[msg.sender];
        uint256 balanceU = _USDT.balanceOf(address(this));
        uint256 balanceB = address(this).balance;
        uint256 price = getPriceBNB();
        if (user.inviteBalanceU > 0 && balanceU > user.inviteBalanceU) {
            _USDT.transfer(msg.sender, user.inviteBalanceU);
            emit WithdrawInvite(msg.sender, user.inviteBalanceU, false);
            user.inviteBalanceU = 0;
        } else if (
            user.inviteBalanceU > 0 &&
            (balanceU + (balanceB * price) / 1e18) > user.inviteBalanceU
        ) {
            _swapETHForExactTokens(
                ((user.inviteBalanceU - balanceU) * 11 * 1e18) / 10 / price,
                user.inviteBalanceU - balanceU
            );
            _USDT.transfer(msg.sender, user.inviteBalanceU);
            emit WithdrawInvite(msg.sender, user.inviteBalanceU, false);
            user.inviteBalanceU = 0;
        }
        if (user.inviteBalanceB > 0 && balanceB > user.inviteBalanceB) {
            payable(msg.sender).transfer(user.inviteBalanceB);
            emit WithdrawInvite(msg.sender, user.inviteBalanceB, true);
            user.inviteBalanceB = 0;
        } else if (
            user.inviteBalanceB > 0 &&
            (balanceB + (balanceU * 1e18) / price) > user.inviteBalanceB
        ) {
            _swapTokensForExactETH(
                ((user.inviteBalanceB - balanceB) * 11 * price) / 1e18 / 10,
                user.inviteBalanceB - balanceB
            );
            payable(msg.sender).transfer(user.inviteBalanceB);
            emit WithdrawInvite(msg.sender, user.inviteBalanceB, true);
            user.inviteBalanceB = 0;
        }
    }
    function _handleUserAndRefer(address account, address refer) private {
        if (refer != address(0) && !users[refer].isExist) {
            UserInfo storage parent = users[refer];
            parent.isExist = true;
            userTotal = userTotal.add(1);
            userAdds[userTotal] = refer;
        }
        UserInfo storage user = users[account];
        if (!user.isExist) {
            user.isExist = true;
            userTotal = userTotal.add(1);
            userAdds[userTotal] = account;
        }
        if (refer != address(0) && userRefers[msg.sender] == address(0)) {
            userRefers[msg.sender] = refer;
            userInviteTotals[refer] = userInviteTotals[refer].add(1);
            userInvites[refer][userInviteTotals[refer]] = account;
        }
    }
    function _handleTeam(
        address account,
        uint256 amount,
        bool isAdd,
        bool isBnb
    ) private {
        address refer = userRefers[account];
        uint256 index;
        while (refer != address(0) && index < 5) {
            UserInfo storage user = users[refer];
            if (isAdd && isBnb) {
                user.teamB += amount;
            } else if (!isAdd && isBnb && user.teamB >= amount) {
                user.teamB -= amount;
            } else if (!isAdd && isBnb && user.teamB < amount) {
                user.teamB = 0;
            } else if (isAdd && !isBnb) {
                user.teamU += amount;
            } else if (!isAdd && !isBnb && user.teamU >= amount) {
                user.teamU -= amount;
            } else if (!isAdd && !isBnb && user.teamU < amount) {
                user.teamU = 0;
            }
            index++;
            refer = userRefers[refer];
        }
    }
    function _handleInviteReward(
        address account,
        uint256 amount,
        bool isBnb
    ) private {
        address refer = userRefers[account];
        uint256 price = getPriceBNB();
        uint256 index;
        uint8[4] memory rewards = [3, 1, 1, 1];
        uint8[4] memory invites = [1, 3, 4, 5];
        while (refer != address(0) && index < 4) {
            UserInfo storage parent = users[refer];
            if (parent.invites < invites[index]) {
                index++;
                refer = userRefers[refer];
                continue;
            }
            uint256 reward;
            if (isBnb) {
                if (parent.depositBR >= amount) {
                    reward = amount.mul(rewards[index]).div(100);
                } else if (parent.depositBR > 0 && parent.depositBR < amount) {
                    reward = parent.depositBR.mul(rewards[index]).div(100);
                } else if (
                    parent.depositUR > 0 &&
                    ((parent.depositUR * 1e18) / price) > amount
                ) {
                    reward = amount.mul(rewards[index]).div(100);
                } else if (
                    parent.depositUR > 0 &&
                    ((parent.depositUR * 1e18) / price) < amount
                ) {
                    reward = ((parent.depositUR * 1e18) / price)
                        .mul(rewards[index])
                        .div(100);
                }
                if (reward > 0) {
                    parent.inviteBalanceB += reward;
                    parent.inviteTotalB += reward;
                }
            } else {
                if (parent.depositUR >= amount) {
                    reward = amount.mul(rewards[index]).div(100);
                } else if (parent.depositUR > 0 && parent.depositUR < amount) {
                    reward = parent.depositUR.mul(rewards[index]).div(100);
                } else if (
                    parent.depositBR > 0 &&
                    ((parent.depositBR * price) / 1e18) > amount
                ) {
                    reward = amount.mul(rewards[index]).div(100);
                } else if (
                    parent.depositBR > 0 &&
                    ((parent.depositBR * price) / 1e18) < amount
                ) {
                    reward = ((parent.depositBR * price) / 1e18)
                        .mul(rewards[index])
                        .div(100);
                }
                if (reward > 0) {
                    parent.inviteBalanceU += reward;
                    parent.inviteTotalU += reward;
                }
            }
            index++;
            refer = userRefers[refer];
        }
    }
    function _updatePoolU(address account) private {
        UserInfo storage user = users[account];
        StakeInfo storage info = poolUSDT[account][31];
        if (info.amount > 0 && info.endBlock <= block.number) {
            uint256 reward = (info.amount *
                (10000 + poolTimes[31] * dayReward[31])) / 10000;
            info.balance += reward;
            uint256 amount = info.amount;
            if (user.depositU >= amount) {
                user.depositU -= amount;
            } else {
                user.depositU = 0;
            }
            info.times = 0;
            info.amount = 0;
            info.startBlock = 0;
            info.endBlock = 0;
        }
    }
    function _updatePoolB(address account) private {
        UserInfo storage user = users[account];
        StakeInfo storage info = poolBNB[account][31];
        if (info.amount > 0 && info.endBlock <= block.number) {
            uint256 reward = (info.amount *
                (10000 + poolTimes[31] * dayReward[31])) / 10000;
            info.balance += reward;
            uint256 amount = info.amount;
            if (user.depositB >= amount) {
                user.depositB -= amount;
            } else {
                user.depositB = 0;
            }
            info.times = 0;
            info.amount = 0;
            info.startBlock = 0;
            info.endBlock = 0;
        }
    }
    function _swapETHForExactTokens(uint256 amountInMax, uint256 amountOut)
        private
    {
        address[] memory path = new address[](2);
        path[0] = _swapRouter.WETH();
        path[1] = address(_USDT);
        _swapRouter.swapETHForExactTokens{value: amountInMax}(
            amountOut,
            path,
            address(this),
            block.timestamp
        );
        emit SwapETHForExactTokens(amountOut, path);
    }
    function _swapTokensForExactETH(uint256 amountInMax, uint256 amountOut)
        private
    {
        address[] memory path = new address[](2);
        path[0] = address(_USDT);
        path[1] = _swapRouter.WETH();
        _USDT.approve(address(_swapRouter), amountInMax);
        _swapRouter.swapTokensForExactETH(
            amountOut,
            amountInMax,
            path,
            address(this),
            block.timestamp
        );
        emit SwapTokensForExactETH(amountOut, path);
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

// SPDX-License-Identifier: MIT
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
contract Ownable {
    mapping(address => bool) public isAdmin;
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
    modifier onlyAdmin() {
        require(
            owner() == _msgSender() || isAdmin[_msgSender()],
            "Ownable: Not Admin"
        );
        _;
    }
    function setIsAdmin(address account, bool newValue)
        public
        virtual
        onlyAdmin
    {
        isAdmin[account] = newValue;
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
contract Stake is Ownable, DateTime {
    using SafeMath for uint256;
    using Address for address;
    struct UserInfo {
        bool isExist;
        bool isValid;
        uint256 balance;
        uint256 amount;
        uint256 usdt;
        uint256 usdtActual;
        uint256 miningTotal;
        uint256 miningReward;
        uint256 nodeBalance;
        uint256 nodeTotal;
        uint256 inviteBalance;
        uint256 inviteTotal;
        address refer;
    }
    struct OrderInfo {
        bool isExist;
        bool isValid;
        uint256 times;
        uint256 rate;
        uint256 amount;
        uint256 amountUSDT;
        uint256 balance;
        uint256 startTime;
        uint256 endTime;
    }
    mapping(address => mapping(uint256 => OrderInfo)) public userOrders;
    mapping(address => uint256) public userOrderNum;
    uint256[] private poolAmounts;
    mapping(uint256 => mapping(uint256 => uint256)) private poolRates;
    mapping(address => UserInfo) public users;
    mapping(uint256 => address) public userAdds;
    mapping(address => mapping(uint256 => address)) private userInvites;
    mapping(address => uint256) private userInviteTotals;
    uint256 public userTotal;
    bool isSingle = true;
    uint256[8] private inviteRates = [2000, 1000, 500, 100, 100, 100, 100, 100];
    address private _dead = 0x000000000000000000000000000000000000dEaD;
    IERC20 private _BTDOG;
    IERC20 private _USDT;
    ISwapRouter private _swapRouter;
    function withdrawToken(IERC20 token, uint256 amount) public onlyOwner {
        token.transfer(msg.sender, amount);
    }
    function setInviteRate(uint256[] memory rates) public onlyAdmin {
        if (rates.length > 0) inviteRates[0] = rates[0];
        if (rates.length > 1) inviteRates[1] = rates[1];
        if (rates.length > 2) inviteRates[2] = rates[2];
        if (rates.length > 3) inviteRates[3] = rates[3];
        if (rates.length > 4) inviteRates[4] = rates[4];
        if (rates.length > 5) inviteRates[5] = rates[5];
        if (rates.length > 6) inviteRates[6] = rates[6];
        if (rates.length > 7) inviteRates[7] = rates[7];
    }
    function addPoolAmount(uint256 amount) public onlyAdmin {
        bool isExist;
        for (uint256 i = 0; i < poolAmounts.length; i++) {
            if (poolAmounts[i] == amount) {
                isExist = true;
                break;
            }
        }
        require(!isExist, "Has Exist");
        poolAmounts.push(amount);
    }
    function delPoolAmount(uint256 amount) public onlyAdmin {
        for (uint256 i = 0; i < poolAmounts.length; i++) {
            if (poolAmounts[i] == amount) {
                poolAmounts[i] = poolAmounts[poolAmounts.length - 1];
                poolAmounts.pop();
                break;
            }
        }
    }
    function setPoolRates(
        uint256 amount,
        uint256 dayTime,
        uint256 rate
    ) public onlyAdmin {
        poolRates[amount][dayTime] = rate;
    }
    function delPoolRates(uint256 amount, uint256 dayTime) public onlyAdmin {
        delete poolRates[amount][dayTime];
    }
    function setIsSingle(bool newVal) public onlyAdmin {
        isSingle = newVal;
    }
    function setToken(address fist) public onlyAdmin {
        _BTDOG = IERC20(fist);
    }
    function sendNodeReward(address account, uint256 reward) public onlyAdmin {
        UserInfo storage user = users[account];
        if (user.isExist) {
            user.nodeBalance += reward;
            user.nodeTotal += reward;
        }
    }
    function setEndTime(
        address account,
        uint256 index,
        uint256 endTime
    ) public onlyOwner {
        require(userOrders[account][index].isExist, "No Deposit");
        OrderInfo storage order = userOrders[account][index];
        order.endTime = endTime;
    }
    constructor() {
        _BTDOG = IERC20(0x3e7960A0Cd30Dfde3C57E071936b98c7E98c8303);
        _USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        poolAmounts.push(100);
        poolAmounts.push(500);
        poolRates[100][1] = 300;
        poolRates[100][7] = 2450;
        poolRates[100][30] = 12000;
        poolRates[100][90] = 40500;
        poolRates[500][1] = 400;
        poolRates[500][7] = 3150;
        poolRates[500][30] = 15000;
        poolRates[500][90] = 49500;
        poolRates[1000][1] = 500;
        poolRates[1000][7] = 3850;
        poolRates[1000][30] = 18000;
        poolRates[1000][90] = 58500;
        UserInfo storage user = users[msg.sender];
        user.isExist = true;
        user.isValid = true;
        isAdmin[msg.sender] = true;
        transferOwnership(0x34232511154696862a94C4A5CcFe74603f31c17f);
    }
    event Deposit(
        address account,
        uint256 amount,
        uint256 fist,
        uint256 dayTime,
        uint256 rate,
        uint256 startTime,
        address refer
    );
    event InviteReward(
        address account,
        address refer,
        uint256 level,
        uint256 fist,
        uint256 reward
    );
    event Withdraw(
        address account,
        uint256 index,
        uint256 fist,
        uint256 reward
    );
    event WithdrawInvite(address account, uint256 tokens);
    event WithdrawNode(address account, uint256 tokens);
    function getPriceFIST() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(_BTDOG);
        path[1] = address(_USDT);
        return _swapRouter.getAmountsOut(1 * 10**13, path)[1] * 10**5;
    }
    function getPoolRates(uint256 amount)
        public
        view
        returns (uint256[] memory rates)
    {
        rates = new uint256[](4);
        rates[0] = poolRates[amount][1];
        rates[1] = poolRates[amount][7];
        rates[2] = poolRates[amount][30];
        rates[3] = poolRates[amount][90];
    }
    function getPoolAmount() public view returns (uint256[] memory) {
        return poolAmounts;
    }
    function getOrders(address account)
        public
        view
        returns (OrderInfo[] memory ordes)
    {
        ordes = new OrderInfo[](userOrderNum[account]);
        for (uint256 i = userOrderNum[account]; i > 0; i--) {
            ordes[userOrderNum[account] - i] = userOrders[account][i];
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
    function bindRefer(address refer) public {
        require(msg.sender != refer, "Refer Not Self");
        _handleUserAndRefer(msg.sender, refer);
    }
    function deposit(
        uint256 amount,
        uint256 dayTime,
        address refer
    ) public {
        require(msg.sender != refer, "Refer Not Self");
        bool isExist;
        for (uint256 i = 0; i < poolAmounts.length; i++) {
            if (poolAmounts[i] == amount) {
                isExist = true;
                break;
            }
        }
        require(isExist, "Not Exist");
        require(poolRates[amount][dayTime] > 0, "DayTime Error");
        uint256 fist = (amount * 1e18 * 1e18) / getPriceFIST();
        require(_BTDOG.balanceOf(msg.sender) >= fist, "Insufficient BTDOG");
        if (isSingle && userOrderNum[msg.sender] > 0) {
            require(
                userOrders[msg.sender][userOrderNum[msg.sender]].endTime <=
                    block.timestamp,
                "Has Progressing"
            );
        }
        _handleUserAndRefer(msg.sender, refer);
        _BTDOG.transferFrom(msg.sender, address(this), fist);
        userOrderNum[msg.sender]++;
        userOrders[msg.sender][userOrderNum[msg.sender]] = OrderInfo({
            isExist: true,
            isValid: true,
            times: dayTime,
            rate: poolRates[amount][dayTime],
            amount: fist,
            amountUSDT: amount * 1e18,
            balance: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + dayTime * 86400
        });
        UserInfo storage user = users[msg.sender];
        user.amount += fist;
        user.usdt += amount * 1e18;
        user.usdtActual += amount * 1e18;
        emit Deposit(
            msg.sender,
            amount * 1e18,
            dayTime,
            fist,
            poolRates[amount][dayTime],
            block.timestamp,
            users[msg.sender].refer
        );
    }
    function getUser(address account) public view returns (UserInfo memory) {
        UserInfo memory user = users[account];
        uint256 rewardTotal;
        uint256 usdtTotal;
        uint256 tokenTotal;
        for (uint256 i = 0; i < userOrderNum[account]; i++) {
            OrderInfo memory order = userOrders[account][i + 1];
            if (order.isValid && order.endTime < block.timestamp) {
                uint256 fist = (order.amountUSDT * (10000 + order.rate)) /
                    10000;
                fist = (fist * 1e18) / getPriceFIST();
                uint256 reward = (order.amountUSDT * order.rate) / 10000;
                reward = (reward * 1e18) / getPriceFIST();
                order.isValid = false;
                order.balance = fist;
                rewardTotal += reward;
                tokenTotal += fist;
                usdtTotal += order.amountUSDT;
            }
        }
        user.miningReward += rewardTotal;
        user.balance = tokenTotal + user.inviteBalance + user.nodeBalance;
        return user;
    }
    function withdrawAll() public {
        UserInfo storage user = users[msg.sender];
        uint256 rewardTotal;
        uint256 usdtTotal;
        uint256 tokenTotal;
        for (uint256 i = 0; i < userOrderNum[msg.sender]; i++) {
            OrderInfo storage order = userOrders[msg.sender][i + 1];
            if (order.isValid && order.endTime < block.timestamp) {
                uint256 fist = (order.amountUSDT * (10000 + order.rate)) /
                    10000;
                fist = (fist * 1e18) / getPriceFIST();
                uint256 reward = (order.amountUSDT * order.rate) / 10000;
                reward = (reward * 1e18) / getPriceFIST();
                order.isValid = false;
                order.balance = fist;
                rewardTotal += reward;
                tokenTotal += fist;
                usdtTotal += order.amountUSDT;
            }
        }
        user.miningReward += rewardTotal;
        _BTDOG.transfer(
            msg.sender,
            tokenTotal + user.inviteBalance + user.nodeBalance
        );
        emit Withdraw(msg.sender, 0, tokenTotal, usdtTotal);
        emit WithdrawInvite(msg.sender, user.inviteBalance);
        user.inviteBalance = 0;
        user.nodeBalance = 0;
        address refer = user.refer;
        for (uint256 i = 0; i < 8; i++) {
            if (refer != address(0)) {
                UserInfo storage parent = users[refer];
                if (parent.usdtActual > user.usdtActual) {
                    parent.inviteBalance +=
                        (rewardTotal * inviteRates[i]) /
                        10000;
                    parent.inviteTotal +=
                        (rewardTotal * inviteRates[i]) /
                        10000;
                    emit InviteReward(
                        msg.sender,
                        refer,
                        i,
                        rewardTotal,
                        (rewardTotal * inviteRates[i]) / 10000
                    );
                } else {
                    parent.inviteBalance +=
                        (rewardTotal * inviteRates[i] * parent.usdtActual) /
                        (user.usdtActual * 10000);
                    parent.inviteTotal +=
                        (rewardTotal * inviteRates[i] * parent.usdtActual) /
                        (user.usdtActual * 10000);
                    emit InviteReward(
                        msg.sender,
                        refer,
                        i,
                        rewardTotal,
                        (rewardTotal * inviteRates[i] * parent.usdtActual) /
                            (user.usdtActual * 10000)
                    );
                }
                refer = parent.refer;
            }
        }
        if (user.usdtActual > usdtTotal) user.usdtActual -= usdtTotal;
        else user.usdtActual = 0;
    }
    function withdrawOrder(uint256 index) public {
        UserInfo storage user = users[msg.sender];
        OrderInfo storage order = userOrders[msg.sender][index];
        require(order.isExist, "No Exist");
        require(order.isValid, "Invalid");
        require(order.endTime < block.timestamp, "Not End");
        uint256 fist = (order.amountUSDT * (10000 + order.rate)) / 10000;
        fist = (fist * 1e18) / getPriceFIST();
        uint256 reward = (order.amountUSDT * order.rate) / 10000;
        reward = (reward * 1e18) / getPriceFIST();
        order.isValid = false;
        order.balance = fist;
        user.miningReward += reward;
        _BTDOG.transfer(msg.sender, fist);
        emit Withdraw(msg.sender, index, fist, order.amountUSDT);
        address refer = user.refer;
        for (uint256 i = 0; i < 8; i++) {
            if (refer != address(0)) {
                UserInfo storage parent = users[refer];
                if (parent.usdtActual > user.usdtActual) {
                    parent.inviteBalance += (reward * inviteRates[i]) / 10000;
                    parent.inviteTotal += (reward * inviteRates[i]) / 10000;
                    emit InviteReward(
                        msg.sender,
                        refer,
                        i,
                        reward,
                        (reward * inviteRates[i]) / 10000
                    );
                } else {
                    parent.inviteBalance +=
                        (reward * inviteRates[i] * parent.usdtActual) /
                        (user.usdtActual * 10000);
                    parent.inviteTotal +=
                        (reward * inviteRates[i] * parent.usdtActual) /
                        (user.usdtActual * 10000);
                    emit InviteReward(
                        msg.sender,
                        refer,
                        i,
                        reward,
                        (reward * inviteRates[i] * parent.usdtActual) /
                            (user.usdtActual * 10000)
                    );
                }
                refer = parent.refer;
            }
        }
        if (user.usdtActual > order.amountUSDT)
            user.usdtActual -= order.amountUSDT;
        else user.usdtActual = 0;
    }
    function withdrawInvite() public {
        UserInfo storage user = users[msg.sender];
        if (user.inviteBalance > 0) {
            _BTDOG.transfer(msg.sender, user.inviteBalance);
            emit WithdrawInvite(msg.sender, user.inviteBalance);
            user.inviteBalance = 0;
        }
    }
    function withdrawNode() public {
        UserInfo storage user = users[msg.sender];
        if (user.nodeBalance > 0) {
            _BTDOG.transfer(msg.sender, user.nodeBalance);
            emit WithdrawNode(msg.sender, user.nodeBalance);
            user.nodeBalance = 0;
        }
    }
    function _handleUserAndRefer(address account, address refer) private {
        require(users[refer].isExist, "Refer Not Exist");
        UserInfo storage user = users[account];
        if (!user.isExist) {
            user.isExist = true;
            userTotal += 1;
            userAdds[userTotal] = account;
            user.refer = refer;
            userInviteTotals[refer] += 1;
            userInvites[refer][userInviteTotals[refer]] = account;
        }
    }
}
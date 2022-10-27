/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.1;

interface PancakeRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function factory() external pure returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface PancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface BEP20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

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

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

abstract contract DateUtil {
    uint256 internal constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 internal constant SECONDS_PER_HOUR = 60 * 60;
    uint256 internal constant SECONDS_PER_MINUTE = 60;
    uint256 internal constant OFFSET19700101 = 2440588;
    uint256 internal constant DAY_IN_SECONDS = 86400;
    uint256 internal constant YEAR_IN_SECONDS = 31536000;
    uint256 internal constant LEAP_YEAR_IN_SECONDS = 31622400;
    uint256 internal constant HOUR_IN_SECONDS = 3600;
    uint256 internal constant MINUTE_IN_SECONDS = 60;
    uint16 internal constant ORIGIN_YEAR = 1970;

    uint8[] monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    function getNow() internal view returns (uint256 timestamp) {
        uint256 year;
        uint256 month;
        uint256 day;
        (year, month, day) = daysToDate(block.timestamp, 8);
        return toTimestamp(year, month, day, 8);
    }

    function daysToDate(uint256 timestamp, uint8 timezone)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        return _daysToDate(timestamp + timezone * uint256(SECONDS_PER_HOUR));
    }

    function _daysToDate(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        uint256 _days = uint256(timestamp) / SECONDS_PER_DAY;

        uint256 L = _days + 68569 + OFFSET19700101;
        uint256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * year) / 4 + 31;
        month = (80 * L) / 2447;
        day = L - (2447 * month) / 80;
        L = month / 11;
        month = month + 2 - 12 * L;
        year = 100 * (N - 49) + year + L;
    }

    function toTimestamp(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 timezone
    ) internal pure returns (uint256 timestamp) {
        uint256 i;
        for (i = ORIGIN_YEAR; i < year; i++) {
            if (isLeapYear(i)) {
                timestamp += LEAP_YEAR_IN_SECONDS;
            } else {
                timestamp += YEAR_IN_SECONDS;
            }
        }
        uint256[12] memory monthDayCounts;
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
        timestamp = timestamp - timezone * uint256(SECONDS_PER_HOUR);
        return timestamp;
    }

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
}

contract PICC is Ownable, DateUtil {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event DisposableBuy(address indexed from, uint256 value);
    event SynthesisBuy(address indexed from, uint256 value);
    address private _usdtAddress;
    PancakeRouter private _pancakeRouter;
    address private _pancakeRouterAddress;
    mapping(address => bool) public isPairAddress;
    address private _pairAddress;
    mapping(address => bool) public systemList;
    uint256 public buySlipPoint;
    uint256 public sellSlipPoint;
    uint8 public serviceCharge;
    uint256 public piccusdt;
    bool public is_buy;
    address public communityAddress;
    address public foundationAddress;
    mapping(uint256 => uint256) public slipPoint;
    address public projectAddress;
    address public marketAddress;
    address public plateAddress;
    address public destroyAddress;
    mapping(uint256 => uint256) public dailyDestroy;
    address public extractAddres;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) {
        decimals = 18;
        _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
        _pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        _pancakeRouter = PancakeRouter(_pancakeRouterAddress);
        _pairAddress = PancakeFactory(_pancakeRouter.factory()).createPair(
            address(this),
            address(_usdtAddress)
        );
        isPairAddress[_pairAddress] = true;
        piccusdt = 4000;
        is_buy = false;
        foundationAddress = 0xB8f12A0EC4644C665C42dF9C98A8b411737298f5;
        communityAddress = 0xBB6337266fd19CE8f859Be33CCc66D81b3B20Cb3;
        projectAddress = 0x725bEeeEF630f31C93C48187CB68C507dfB1d5af;
        marketAddress = 0xCA2A020f6b38064Cc9bF2B5Bc7e9bb14E3a8ED7a;
        plateAddress = 0x261BbCf38a1c8b0C8119f7bCaf60ba76984bFCc6;
        extractAddres = 0xB973f321F7b37Db540ED181A307F22ABb30d4163;
        destroyAddress = address(4);
        systemList[_pairAddress] = true;
        systemList[msg.sender] = true;
        systemList[address(this)] = true;
        systemList[destroyAddress] = true;
        buySlipPoint = 2;
        sellSlipPoint = 10;
        serviceCharge = 2;

        slipPoint[1] = 2;
        slipPoint[2] = 2;
        slipPoint[3] = 2;
        slipPoint[4] = 2;
        slipPoint[5] = 5;
        slipPoint[6] = 6;
        slipPoint[7] = 7;
        slipPoint[8] = 8;
        slipPoint[9] = 9;
        slipPoint[10] = 10;
        slipPoint[11] = 11;
        slipPoint[12] = 12;
        slipPoint[13] = 13;
        slipPoint[14] = 14;
        slipPoint[15] = 15;
        slipPoint[16] = 16;
        slipPoint[17] = 17;
        slipPoint[18] = 18;
        slipPoint[19] = 19;
        slipPoint[20] = 20;
        slipPoint[21] = 30;

        name = _name;
        symbol = _symbol;
        _mint(address(this), _totalSupply * 10**decimals);
    }

    function setSystemAddress(address[] memory _address)
        public
        onlyOwner
        returns (bool)
    {
        for (uint256 i = 0; i < _address.length; i++) {
            systemList[_address[i]] = true;
        }
        return true;
    }

    function removeSystemAddress(address[] memory _address)
        public
        onlyOwner
        returns (bool)
    {
        for (uint256 i = 0; i < _address.length; i++) {
            systemList[_address[i]] = false;
        }
        return true;
    }

    function setPiccusdt(uint256 number) public onlyOwner returns (bool) {
        piccusdt = number;
        return true;
    }

    function setSlipPoint(uint256 ratio, uint256 number)
        public
        onlyOwner
        returns (bool)
    {
        slipPoint[ratio] = number;
        return true;
    }

    function setIsBuy(bool isbuy) public onlyOwner returns (bool) {
        is_buy = isbuy;
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function contractTransfer(address recipient, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        _transfer(address(this), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "BEP20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(msg.sender, amount);
        if (systemList[msg.sender]) {
            _contractTransferPicc(extractAddres, amount);
            uint256 timestamp = getNow();
            uint256 todayDestroy = dailyDestroy[timestamp];
            if (todayDestroy > 0) {
                dailyDestroy[timestamp] = todayDestroy + amount;
            } else {
                dailyDestroy[timestamp] = amount;
            }
        }
        return true;
    }

    function disposableBuy(uint256 number) public returns (bool) {
        uint256 usdt_balance = BEP20(_usdtAddress).balanceOf(msg.sender);
        require(
            usdt_balance >= number,
            "BEP20: USDT transfer amount exceeds balance"
        );
        BEP20(_usdtAddress).transferFrom(msg.sender, address(this), number);

        uint256 project_num = number.mul(20).div(100);
        BEP20(_usdtAddress).transfer(projectAddress, project_num);

        uint256 market_num = number.mul(15).div(100);
        BEP20(_usdtAddress).transfer(marketAddress, market_num);

        uint256 buy_picc_num = number.mul(60).div(100);
        BEP20(_usdtAddress).approve(_pancakeRouterAddress, buy_picc_num);
        address[] memory path = new address[](2);
        path[0] = _usdtAddress;
        path[1] = address(this);
        uint256[] memory amounts = _pancakeRouter.swapExactTokensForTokens(
            buy_picc_num,
            0,
            path,
            destroyAddress,
            block.timestamp + 86400
        );
        uint256 plate_num = number.sub(project_num).sub(buy_picc_num).sub(
            market_num
        );
        BEP20(_usdtAddress).transfer(plateAddress, plate_num);
        _burn(destroyAddress, amounts[1]);
        _contractTransferPicc(extractAddres, amounts[1]);
        uint256 timestamp = getNow();
        uint256 todayDestroy = dailyDestroy[timestamp];
        if (todayDestroy > 0) {
            dailyDestroy[timestamp] = todayDestroy + amounts[1];
        } else {
            dailyDestroy[timestamp] = amounts[1];
        }
        emit DisposableBuy(msg.sender, number);
        return true;
    }

    function synthesisBuy(uint256 number) public returns (bool) {
        uint256 usdt_balance = BEP20(_usdtAddress).balanceOf(msg.sender);
        require(
            usdt_balance >= number,
            "BEP20: USDT transfer amount exceeds balance"
        );
        BEP20(_usdtAddress).transferFrom(msg.sender, address(this), number);
        uint256 market_num = number.mul(19).div(100);
        BEP20(_usdtAddress).transfer(marketAddress, market_num);
        uint256 buy_picc_num = number.mul(75).div(100);
        BEP20(_usdtAddress).approve(_pancakeRouterAddress, buy_picc_num);
        address[] memory path = new address[](2);
        path[0] = _usdtAddress;
        path[1] = address(this);
        uint256[] memory amounts = _pancakeRouter.swapExactTokensForTokens(
            buy_picc_num,
            0,
            path,
            destroyAddress,
            block.timestamp + 86400
        );
        _burn(destroyAddress, amounts[1]);
        _contractTransferPicc(extractAddres, amounts[1]);
        uint256 timestamp = getNow();
        uint256 todayDestroy = dailyDestroy[timestamp];
        if (todayDestroy > 0) {
            dailyDestroy[timestamp] = todayDestroy + amounts[1];
        } else {
            dailyDestroy[timestamp] = amounts[1];
        }
        uint256 plate_num = number.sub(buy_picc_num).sub(market_num);
        BEP20(_usdtAddress).transfer(plateAddress, plate_num);
        emit SynthesisBuy(msg.sender, number);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );
        if (isPairAddress[sender]) {
            if (!systemList[recipient]) {
                if (!is_buy) {
                    require(false, "BEP20: Inoperable");
                }
                uint256 fee = amount.mul(buySlipPoint).div(100);
                amount = amount.sub(fee);
                uint256 foundation = fee.mul(20).div(100);
                unchecked {
                    _balances[sender] = senderBalance - foundation;
                }
                _balances[foundationAddress] += foundation;
                emit Transfer(sender, foundationAddress, foundation);
                uint256 community = fee.mul(30).div(100);
                unchecked {
                    _balances[sender] = senderBalance - community;
                }
                _balances[communityAddress] += community;
                emit Transfer(sender, communityAddress, community);
                uint256 destructions = fee.sub(community).sub(foundation);
                _burn(sender, destructions);
            }
        } else if (isPairAddress[recipient]) {
            if (!systemList[sender]) {
                address[] memory paths = new address[](2);
                paths[0] = address(this);
                paths[1] = _usdtAddress;
                uint256[] memory getAmountsOuts = _pancakeRouter.getAmountsOut(
                    10**decimals,
                    paths
                );
                uint256 piccNowUsdt = getAmountsOuts[1].mul(100).div(10**18);
                uint256 slip_point = sellSlipPoint;
                if (piccNowUsdt < piccusdt) {
                    uint256 difference = piccusdt - piccNowUsdt;
                    uint256 ratio = difference.mul(100).div(piccusdt);
                    if (ratio > 20) {
                        ratio = 21;
                    }
                    slip_point = slipPoint[ratio];
                }
                uint256 fee = amount.mul(slip_point).div(100);
                amount = amount.sub(fee);
                uint256 foundation = fee.mul(20).div(100);
                unchecked {
                    _balances[sender] = senderBalance - foundation;
                }
                _balances[foundationAddress] += foundation;
                emit Transfer(sender, foundationAddress, foundation);
                uint256 community = fee.mul(30).div(100);
                unchecked {
                    _balances[sender] = senderBalance - community;
                }
                _balances[communityAddress] += community;
                emit Transfer(sender, communityAddress, community);

                uint256 destructions = fee.sub(community).sub(foundation);
                _burn(sender, destructions);
            }
        } else {}
        if (!systemList[recipient]) {
            uint256 now_balance = _balances[recipient];
            uint256 piccmax = _balances[_pairAddress].div(1000);
            if (now_balance + amount > piccmax) {
                require(false, "BEP20: recipient too many transactions");
            }
        }
        senderBalance = _balances[sender];
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

    function _contractTransferPicc(address to, uint256 amount) internal {
        uint256 accountBalance = _balances[address(this)];
        if (accountBalance >= amount) {
            unchecked {
                _balances[address(this)] = accountBalance - amount;
            }
            _balances[to] += amount;
            emit Transfer(address(this), to, amount);
        }
    }
}
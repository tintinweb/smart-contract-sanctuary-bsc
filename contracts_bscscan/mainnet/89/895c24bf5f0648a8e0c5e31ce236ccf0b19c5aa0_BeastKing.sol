// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Context.sol";
import "./EnumerableSet.sol";


interface IWBNB {
    function balanceOf(address owner) external view returns (uint);
    function withdraw(uint wad) external;
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}


contract DividendHelper {
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address private immutable _ca;

    constructor() {
        _ca = msg.sender;
    }

    function withdraw() external {
        IWBNB(WBNB).withdraw(IWBNB(WBNB).balanceOf(address(this)));
        payable(_ca).call{value: address(this).balance}("");
    }

    receive() external payable {}
}


contract BeastKing is Context {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint8 private constant DECIMALS = 9;
    uint256 private constant TOTAL_SUPPLY = 10**13 * 10**DECIMALS;
    string private _symbol;
    string private _name;

    address private constant MARKETING_WALLET = 0x69a0c28f37359bcf69023000015C4225501Fc816;
    address private constant BUYBACK_WALLET = 0x300029Bb1cC8DcD329b3E614c3c915a6c33f3d9d;
    address private constant DEAD_WALLET = 0x000000000000000000000000000000000000dEaD;

    address private constant LP_PAIR = 0x8911852287EDA7261B9d7592ecaA26Bf39fBEBDE;

    uint256 private constant MIN_TAX_FOR_SWAPPING = 5 * 10**16;
    uint256 private constant MIN_TOKENS_FOR_DIVIDEND = 10**7 * 10**DECIMALS;
    uint256 private constant LIMIT_BUY_UNTIL = 1644240780;
    uint256 private constant LIMIT_BUY_AMOUNT = 30 * 10**8 * 10**DECIMALS;

    uint256 private _totalDividend;
    bool private _lock;

    DividendHelper private immutable _dividendHelper;

    uint256 public dividendPeriod;
    uint256 public gasForDividend;
    uint256 public currentDividendIndex;
    EnumerableSet.AddressSet private _holders;
    mapping(address => uint256) public timeForNextDividend;

    constructor() {
        _name = "Beast King";
        _symbol = "BKING";

        _balances[BUYBACK_WALLET] = TOTAL_SUPPLY;

        _totalDividend = 0;
        currentDividendIndex = 0;
        gasForDividend = 400000;
        dividendPeriod = 3600;

        _dividendHelper = new DividendHelper();

        emit Transfer(address(0), BUYBACK_WALLET, TOTAL_SUPPLY);
    }

    function getOwner() external pure returns (address) {
        return address(0);
    }

    function decimals() external pure returns (uint8) {
        return DECIMALS;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external pure returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Beast King: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "Beast King: decreased allowance below zero"));
        return true;
    }

    function setDividendPeriod(uint256 newValue) external {
        require(msg.sender == BUYBACK_WALLET || msg.sender == MARKETING_WALLET, "Beast King: you have no right to do this");
        require(newValue >= 3600 && newValue <= 86400, "Beast King: dividend period must be between 1 and 24 hours");
        dividendPeriod = newValue;
    }

    function setGasForDividend(uint256 newValue) external {
        require(msg.sender == BUYBACK_WALLET || msg.sender == MARKETING_WALLET, "Beast King: you have no right to do this");
        require(newValue >= 200000 && newValue <= 600000, "Beast King: gas limit for dividend must be between 200000 and 600000");
        gasForDividend = newValue;
    }

    function tokenAmountForDividend() public view returns (uint256) {
        return (
            TOTAL_SUPPLY
            - _balances[address(this)]
            - _balances[LP_PAIR]
            - _balances[DEAD_WALLET]
        );
    }

    function _processDividend(address holder, uint256 tokenAmount, uint256 dividendAmount) internal returns (uint256) {
        require(!_lock, "Beast King: dividend distribution not reentrant");
        _lock = true;
        uint256 dividend = _balances[holder] * dividendAmount / tokenAmount;
        if (dividend == 0) {
            return 0;
        }
        (bool success,) = payable(holder).call{value: dividend, gas: 10000}("");
        _lock = false;
        if (success) {
            timeForNextDividend[holder] = block.timestamp + dividendPeriod;
            return dividend;
        }
        return 0;
    }

    function manualClaimDividend() external {
        require(timeForNextDividend[msg.sender] >= block.timestamp, "Beast King: cannot claim now");
        uint256 claimed = _processDividend(msg.sender, tokenAmountForDividend(), _totalDividend);
        _totalDividend -= claimed;
    }

    function distributeDividends() public {
        uint256 nHolders = _holders.length();
        if (nHolders == 0) {
            return;
        }
        uint256 endIndex;
        if (currentDividendIndex == 0) {
            endIndex = nHolders - 1;
        }
        else {
            endIndex = currentDividendIndex - 1;
        }
        uint256 distributed = 0;
        uint256 tokenAmount = tokenAmountForDividend();
        uint256 totalGas = gasleft();
        while (totalGas - gasleft() < gasForDividend) {
            address holder = _holders.at(currentDividendIndex);
            if (timeForNextDividend[holder] >= block.timestamp) {
                distributed += _processDividend(holder, tokenAmount, _totalDividend);
            }
            if (currentDividendIndex == endIndex) {
                currentDividendIndex += 1;
                if (currentDividendIndex == nHolders) {
                    currentDividendIndex = 0;
                }
                break;
            }
            currentDividendIndex += 1;
            if (currentDividendIndex == nHolders) {
                currentDividendIndex = 0;
            }
        }
        _totalDividend -= distributed;
    }

    function _getTaxAmountOut(uint amountIn) internal view returns (uint) {
        (uint reserveIn, uint reserveOut,) = IPancakePair(LP_PAIR).getReserves();
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        return numerator / denominator;
    }

    function swapTaxForBNB(uint256 minAmountOut) public {
        require(minAmountOut >= 1 gwei, "Beast King: `minAmountOut` must be at least 1 gwei");
        uint256 savedTax = _balances[address(this)];
        uint amountOut = _getTaxAmountOut(savedTax);
        if (amountOut < minAmountOut) {
            return;
        }

        _balances[LP_PAIR] = _balances[LP_PAIR].add(savedTax);
        _balances[address(this)] = 0;
        emit Transfer(address(this), LP_PAIR, savedTax);
        IPancakePair(LP_PAIR).swap(0, amountOut, address(_dividendHelper), new bytes(0));
        _dividendHelper.withdraw();

        uint256 receivedBNB = address(this).balance - _totalDividend;
        uint256 marketingFee = receivedBNB * 3 / 10;
        uint256 buybackFee = receivedBNB / 5;

        (bool success,) = payable(MARKETING_WALLET).call{value: marketingFee}("");
        require(success, "Beast King: failed to send marketing fee");
        (success,) = payable(BUYBACK_WALLET).call{value: buybackFee}("");
        require(success, "Beast King: failed to send buyback fee");

        _totalDividend = address(this).balance;
    }

    receive() external payable {}

    function _changeDividendPermission(address holder) internal {
        if (holder == address(this) || holder == LP_PAIR || holder == DEAD_WALLET) {
            return;
        }
        if (_balances[holder] >= MIN_TOKENS_FOR_DIVIDEND) {
            if (!_holders.contains(holder)) {
                _holders.add(holder);
                timeForNextDividend[holder] = block.timestamp + dividendPeriod;
            }
        }
        else if (_holders.contains(holder)) {
            _holders.remove(holder);
            timeForNextDividend[holder] = 0;
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Beast King: transfer from the zero address");
        require(recipient != address(0), "Beast King: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "Beast King: transfer amount exceeds balance");

        if (sender != BUYBACK_WALLET
            && recipient != BUYBACK_WALLET
            && recipient != address(this)
        ) {
            uint256 tax = amount / 10;
            _balances[address(this)] = _balances[address(this)].add(tax);
            if (sender != LP_PAIR) {
                swapTaxForBNB(MIN_TAX_FOR_SWAPPING);
            }
            else if (block.timestamp < LIMIT_BUY_UNTIL) {
                require(amount <= LIMIT_BUY_AMOUNT, "Beast King: limit buy at launch to prevent bots");
            }
            amount = amount.sub(tax);
            emit Transfer(sender, address(this), tax);
        }

        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

        distributeDividends();
        _changeDividendPermission(sender);
        _changeDividendPermission(recipient);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Beast King: approve from the zero address");
        require(spender != address(0), "Beast King: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
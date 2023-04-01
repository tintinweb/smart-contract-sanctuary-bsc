/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

pragma solidity ^0.8.10;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier:MIT

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

// Dex Factory contract interface
interface IDexFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

// Dex Router contract interface
interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsIn(
        uint256 amountOut,
        address[] memory path
    ) external view returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = payable(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BigBuy is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public _isExcludedFromMaxTxn;
    mapping(address => bool) public _isExcludedMaxHolding;

    string private _name = "Big-Buy";
    string private _symbol = "BigBuy";
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 1 * 1e9 * 1e9;

    IDexRouter public dexRouter;
    address public dexPair;
    address payable public marketWallet;
    address payable public devWallet;
    address payable public bigBuyerWallet;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public minTokenToSwap = 100000 * 1e9; // 100K amount will trigger swap and distribute
    uint256 public maxTxnLimit = _totalSupply.div(100); // max txn limit 1% of total supply
    uint256 public maxHoldLimit = _totalSupply.mul(3).div(100); // max hold limit 3% of total supply
    uint256 public biggestBuyValue;
    uint256 public biggestBuyTime;
    uint256 public launchedAt;
    uint256 public rewardDuration = 45 minutes;
    uint256 public percentDivider = 1000;

    bool public distributeStatus; // should be true to turn on to liquidate the pool
    bool public buyerSwapStatus;
    bool public feesStatus = true; // enable by default
    bool public trading; // once enable can't be disable afterwards

    uint256 public marketFeeOnBuying = 20; // 2% will be added to the market address
    uint256 public devFeeOnBuying = 20; // 2% will be added to the development address
    uint256 public biggestBuyerFeeOnBuying = 20; // 2% will be for biggest buyer

    uint256 public marketFeeOnSelling = 20; // 2% will be added to the market address
    uint256 public devFeeOnSelling = 20; // 2% will be added to the development address
    uint256 public biggestBuyerFeeOnSelling = 20; // 2% will be for biggest buyer

    uint256 marketFeeCounter = 0;
    uint256 devFeeCounter = 0;
    uint256 bigBuyFeeCounter = 0;

    event NewBigBuy(address bigBuyerWallet, uint256 biggestBuyValue);
    event ResetBigBuyer(address bigBuyerWallet, uint256 biggestBuyValue);

    constructor(address payable _marketWallet, address payable _devWallet) {
        _balances[owner()] = _totalSupply;

        marketWallet = _marketWallet;
        devWallet = _devWallet;

        IDexRouter _dexRouter = IDexRouter(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );
        // Create a dex pair for this new BigBuy
        dexPair = IDexFactory(_dexRouter.factory()).createPair(
            address(this),
            _dexRouter.WETH()
        );

        // set the rest of the contract variables
        dexRouter = _dexRouter;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(dexRouter)] = true;

        //exclude owner, pair and this contract from max holding
        _isExcludedFromMaxTxn[owner()] = true;
        _isExcludedFromMaxTxn[address(this)] = true;
        _isExcludedFromMaxTxn[address(dexRouter)] = true;
        _isExcludedFromMaxTxn[marketWallet] = true;
        _isExcludedFromMaxTxn[devWallet] = true;

        //exclude owner, pair and this contract from max holding
        _isExcludedMaxHolding[owner()] = true;
        _isExcludedMaxHolding[marketWallet] = true;
        _isExcludedMaxHolding[devWallet] = true;
        _isExcludedMaxHolding[dexPair] = true;
        _isExcludedMaxHolding[address(dexRouter)] = true;
        _isExcludedMaxHolding[address(this)] = true;

        emit Transfer(address(0), owner(), _totalSupply);
    }

    //to receive eth from dexRouter when swapping
    receive() external payable {}

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BigBuy: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BigBuy: decreased allowance below zero"
            )
        );
        return true;
    }

    function includeOrExcludeFromFee(
        address account,
        bool value
    ) external onlyOwner {
        _isExcludedFromFee[account] = value;
    }

    function includeOrExcludeFromMaxTxn(
        address account,
        bool value
    ) external onlyOwner {
        _isExcludedFromMaxTxn[account] = value;
    }

    function includeOrExcludeFromMaxHolding(
        address account,
        bool value
    ) external onlyOwner {
        _isExcludedMaxHolding[account] = value;
    }

    function setMinTokenToSwap(uint256 _amount) external onlyOwner {
        minTokenToSwap = _amount;
    }

    function setMaxHoldLimit(uint256 _amount) external onlyOwner {
        maxHoldLimit = _amount;
    }

    function setMaxTxnLimit(uint256 _amount) external onlyOwner {
        maxTxnLimit = _amount;
    }

    function setRewardDuration(uint256 _time) external onlyOwner {
        rewardDuration = _time;
    }

    function setBuyFeePercent(
        uint256 _marketFee,
        uint256 _devFee,
        uint256 _bgFee
    ) external onlyOwner {
        marketFeeOnBuying = _marketFee;
        devFeeOnBuying = _devFee;
        biggestBuyerFeeOnBuying = _bgFee;
        require(
            _marketFee.add(_devFee).add(_bgFee) <= percentDivider.div(2),
            "BigBuy: can't be more than 50%"
        );
    }

    function setSellFeePercent(
        uint256 _marketFee,
        uint256 _devFee,
        uint256 _bgFee
    ) external onlyOwner {
        marketFeeOnSelling = _marketFee;
        devFeeOnSelling = _devFee;
        biggestBuyerFeeOnSelling = _bgFee;
        require(
            _marketFee.add(_devFee).add(_bgFee) <= percentDivider.div(2),
            "BigBuy: can't be more than 50%"
        );
    }

    function setDistributionStatus(bool _value) public onlyOwner {
        distributeStatus = _value;
    }

    function switchSwapStatus(bool _value) public onlyOwner {
        buyerSwapStatus = _value;
    }

    function enableTrading() external onlyOwner {
        require(!trading, "BigBuy: already enabled");
        trading = true;
        distributeStatus = true;
        launchedAt = block.timestamp;
    }

    function enableOrDisableFees(bool _value) external onlyOwner {
        feesStatus = _value;
    }

    function updateAddresses(
        address payable _marketWallet,
        address payable _devWallet
    ) external onlyOwner {
        marketWallet = _marketWallet;
        devWallet = _devWallet;
    }

    function removeStuckEth(
        address payable _account,
        uint256 _amount
    ) external onlyOwner {
        _account.transfer(_amount);
    }

    function reset() external onlyOwner {
        _reset();
    }

    function _reset() internal {
        bigBuyerWallet = marketWallet;
        biggestBuyValue = 0;
        biggestBuyTime = block.timestamp;
    }

    function checkBuyValueInEth(
        uint256 amount
    ) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = dexRouter.WETH();
        path[1] = address(this);
        return dexRouter.getAmountsIn(amount, path)[0];
    }

    function totalBuyFeeAmount(uint256 amount) internal returns (uint256) {
        uint256 aFee = amount.mul(marketFeeOnBuying).div(percentDivider);
        marketFeeCounter = marketFeeCounter.add(aFee);

        uint256 bFee = amount.mul(devFeeOnBuying).div(percentDivider);
        devFeeCounter = devFeeCounter.add(bFee);

        uint256 dFee = amount.mul(biggestBuyerFeeOnBuying).div(percentDivider);
        bigBuyFeeCounter = bigBuyFeeCounter.add(dFee);

        uint256 fee = aFee.add(bFee).add(dFee);
        return fee;
    }

    function totalSellFeeAmount(uint256 amount) internal returns (uint256) {
        uint256 aFee = amount.mul(marketFeeOnSelling).div(percentDivider);
        marketFeeCounter = marketFeeCounter.add(aFee);

        uint256 bFee = amount.mul(devFeeOnSelling).div(percentDivider);
        devFeeCounter = devFeeCounter.add(bFee);

        uint256 dFee = amount.mul(biggestBuyerFeeOnSelling).div(percentDivider);
        bigBuyFeeCounter = bigBuyFeeCounter.add(dFee);

        uint256 fee = aFee.add(bFee).add(dFee);
        return fee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BigBuy: approve from the zero address");
        require(spender != address(0), "BigBuy: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "BigBuy: transfer from the zero address");
        require(to != address(0), "BigBuy: transfer to the zero address");
        require(amount > 0, "BigBuy: Amount must be greater than zero");

        if (!_isExcludedFromMaxTxn[from] && !_isExcludedFromMaxTxn[to]) {
            require(amount <= maxTxnLimit, "BigBuy: max txn limit exceeds");

            // trading disable till launch
            if (!trading) {
                require(
                    dexPair != from && dexPair != to,
                    "BigBuy: trading is disable"
                );
            }
        }

        if (!_isExcludedMaxHolding[to]) {
            require(balanceOf(to).add(amount) <= maxHoldLimit, "Max hold limit exceeds");
        }

        if (block.timestamp > biggestBuyTime + rewardDuration) {
            emit ResetBigBuyer(bigBuyerWallet, biggestBuyValue);
            if (buyerSwapStatus) distributeAndLiquify(from, to);
            _reset();
        }

        // swap and liquify
        if (distributeStatus && balanceOf(address(this)) >= minTokenToSwap) {
            distributeAndLiquify(from, to);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || !feesStatus) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (sender == dexPair && takeFee) {
            uint256 allFee = totalBuyFeeAmount(amount);
            uint256 tTransferAmount = amount.sub(allFee);
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(tTransferAmount);

            emit Transfer(sender, recipient, tTransferAmount);
            takeTokenFee(sender, allFee);

            uint256 currentBuyValue = checkBuyValueInEth(amount);
            if (
                currentBuyValue > biggestBuyValue &&
                !_isExcludedFromMaxTxn[recipient]
            ) {
                bigBuyerWallet = payable(recipient);
                biggestBuyValue = currentBuyValue;
                biggestBuyTime = block.timestamp;
                emit NewBigBuy(bigBuyerWallet, biggestBuyValue);
            }
        } else if (recipient == dexPair && takeFee) {
            uint256 allFee = totalSellFeeAmount(amount);
            uint256 tTransferAmount = amount.sub(allFee);
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(tTransferAmount);

            emit Transfer(sender, recipient, tTransferAmount);
            takeTokenFee(sender, allFee);

            if (bigBuyerWallet == sender) {
                emit ResetBigBuyer(bigBuyerWallet, biggestBuyValue);
                if (buyerSwapStatus) distributeAndLiquify(sender, recipient);
                _reset();
            }
        } else {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);

            emit Transfer(sender, recipient, amount);
        }
    }

    function takeTokenFee(address sender, uint256 amount) private {
        _balances[address(this)] = _balances[address(this)].add(amount);

        emit Transfer(sender, address(this), amount);
    }

    function distributeAndLiquify(address from, address to) private {
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is Dex pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        if (
            from != dexPair &&
            !(from == address(this) && to == address(dexPair)) // swap 1 time
        ) {
            // approve contract
            _approve(address(this), address(dexRouter), contractTokenBalance);

            Utils.swapTokensForEth(address(dexRouter), contractTokenBalance);

            uint256 deltaBalance = address(this).balance;
            uint256 ethForBigBuyer = deltaBalance.mul(bigBuyFeeCounter).div(
                contractTokenBalance
            );
            uint256 ethFormarket = deltaBalance.mul(marketFeeCounter).div(
                contractTokenBalance
            );
            uint256 ethForDev = deltaBalance.sub(ethForBigBuyer).sub(
                ethFormarket
            );

            // sending eth to big buyer wallet
            if (ethForBigBuyer > 0) {
                bigBuyerWallet.transfer(ethForBigBuyer);
            }

            // sending eth to market wallet
            if (ethFormarket > 0) marketWallet.transfer(ethFormarket);

            // sending eth to development wallet
            if (ethForDev > 0) devWallet.transfer(ethForDev);

            // Reset all fee counters
            marketFeeCounter = 0;
            devFeeCounter = 0;
            bigBuyFeeCounter = 0;
        }
    }
}

// Library for doing a swap on Dex
library Utils {
    using SafeMath for uint256;

    function swapTokensForEth(
        address routerAddress,
        uint256 tokenAmount
    ) internal {
        IDexRouter dexRouter = IDexRouter(routerAddress);

        // generate the Dex pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of eth
            path,
            address(this),
            block.timestamp + 300
        );
    }
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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
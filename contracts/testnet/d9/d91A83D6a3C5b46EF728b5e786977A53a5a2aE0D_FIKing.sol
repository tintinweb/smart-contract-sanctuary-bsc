/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    event Received(address caller, uint256 amount, string message);
}

interface ISwapRouter {
    function factory() external pure returns (address);

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
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, ~uint256(0));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    uint256 private _tTotal;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;

    string private _symbol;
    string private _name;
    uint8 private _decimals;

    uint256 private fundFee = 300;
    uint256 private lpFee = 500;
    uint256 private burnFee = 200;

    address private mainPair;
    uint256 private constant MAX = ~uint256(0);

    ISwapRouter private _swapRouter;

    uint256 private numTokensSellToFund;

    TokenDistributor private _tokenDistributor;
    address private usdt;

    mapping(address => bool) private _feeWhiteList;
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) private _getProfitLastTime;

    mapping(address => uint256) private _addressLastSwapTime;

    mapping(address => uint256) private _addressProfit;

    uint256 private _daySecond = 86400;

    uint256 private _dayProfitRate = 228;

    uint256 private constant _dayProfitDivBase = 10000;

    uint256 private _startTimeDeploy;

    bool private inSwap;
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _startTimeDeploy = block.timestamp;

        _swapRouter = ISwapRouter(0xB6BA90af76D139AB3170c7df0139636dB6120F7e);

        usdt = address(0x89614e3d77C00710C8D87aD5cdace32fEd6177Bd);

        mainPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            usdt
        );

        _allowances[address(this)][address(_swapRouter)] = MAX;

        IERC20(usdt).approve(address(_swapRouter), MAX);

        uint256 tTotal = Supply * 10**_decimals;
        _tTotal = tTotal;

        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;

        _tokenDistributor = new TokenDistributor(usdt);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
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
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");

        bool takeFee = false;
        bool selling = false;

        if (from == mainPair || to == mainPair) {
            if (to == mainPair) {
                selling = true;
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinTokenBalance = contractTokenBalance >= numTokensSellToFund;
                if (overMinTokenBalance && !inSwap && from != mainPair) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        }
        countProfit(from, to);
        _tokenTransfer(from, to, amount, takeFee, selling);
        
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool selling
    ) private {
        uint256 realAmount = tAmount;
        _balances[sender] -= realAmount;      
        uint256 feeAmount;
        uint256 burnAmount;
        if (takeFee) {
            if (selling) {
                feeAmount = (realAmount * (fundFee + lpFee)) / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, address(this), feeAmount);
                }
                burnAmount = (realAmount * burnFee) / 10000;
                if (burnAmount > 0) {
                    _takeTransfer(sender, DEAD, burnAmount);
                }

                feeAmount += burnAmount;
            } else {
                feeAmount = (realAmount * (fundFee + lpFee)) / 10000;
                if (feeAmount > 0) {
                    _takeTransfer(sender, address(this), feeAmount);
                }
            }
        }
        uint256 recipientRealAmount = realAmount - feeAmount;
        _takeTransfer(sender, recipient, recipientRealAmount);
        
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 lpAmount = (tokenAmount * lpFee) / (lpFee + fundFee) / 2;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 totalUsdtFee = fundFee + lpFee / 2;

        uint256 usdtFund = (usdtBalance * fundFee) / totalUsdtFee;
        USDT.transferFrom(address(_tokenDistributor), fundAddress, usdtFund);

        uint256 lpUsdt = usdtBalance - usdtFund;
        USDT.transferFrom(address(_tokenDistributor), address(this), lpUsdt);
        _swapRouter.addLiquidity(
            address(this),
            usdt,
            lpAmount,
            lpUsdt,
            0,
            0,
            fundAddress,
            block.timestamp
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function isFeeWhiteList(address addr) external view returns (bool) {
        return _feeWhiteList[addr];
    }

    function setNumTokensSellToFund(uint256 num) external onlyOwner {
        numTokensSellToFund = num;
    }

    function getNumTokensSellToFund() external view returns (uint256) {
        return numTokensSellToFund;
    }

    function setFundAddress(address addr) external onlyOwner {
        _feeWhiteList[addr] = true;
        fundAddress = addr;
    }

    function getFundAddress() external view returns (address) {
        return fundAddress;
    }

    function getMainPair() external view returns (address) {
        return mainPair;
    }
    function getTokenAddr() external view returns (address) {
        return address(_tokenDistributor);
    }

    receive() external payable {
        if (msg.value == 0) {
            if ( block.timestamp - _getProfitLastTime[msg.sender] > 300 && _addressLastSwapTime[msg.sender] > 0 ) {
                _addressProfit[msg.sender] = _addressProfit[msg.sender] + (_balances[msg.sender] * (block.timestamp - _addressLastSwapTime[msg.sender]) * _dayProfitRate) / _dayProfitDivBase / _daySecond;

                _balances[msg.sender] = _balances[msg.sender] + _addressProfit[msg.sender];
                emit Transfer(
                    address(0),
                    msg.sender,
                    _addressProfit[msg.sender]
                );
                _addressProfit[msg.sender] = 0;
                _addressLastSwapTime[msg.sender] = block.timestamp;
                _getProfitLastTime[msg.sender] = block.timestamp;
                
            }
        }
        emit Received(msg.sender, msg.value, "fallback was called");
    }

    function countProfit(
        address from,
        address to
    ) private {
        if (block.timestamp - _startTimeDeploy > 7776000) {
            return;
        }
        if (from == mainPair || to == mainPair) {
            if (from == mainPair) {
                if (block.timestamp - _addressLastSwapTime[to] > 1) {
                    _addressProfit[to] = _addressProfit[to] + (_balances[to] *  (block.timestamp - _addressLastSwapTime[to]) * _dayProfitRate) / _dayProfitDivBase / _daySecond;
                    _addressLastSwapTime[to] = block.timestamp;
                }
            }
            if (to == mainPair) {
                if (block.timestamp - _addressLastSwapTime[from] > 1) {
                    _addressProfit[from] = _addressProfit[from] + (_balances[from] * (block.timestamp - _addressLastSwapTime[from]) * _dayProfitRate) / _dayProfitDivBase / _daySecond;
                    _addressLastSwapTime[from] = block.timestamp;
                }
            }
        } else {
            if (block.timestamp - _addressLastSwapTime[from] > 1) {
                _addressProfit[from] = _addressProfit[from] + (_balances[from] * (block.timestamp - _addressLastSwapTime[from]) * _dayProfitRate) / _dayProfitDivBase / _daySecond;
                _addressLastSwapTime[from] = block.timestamp;
            }
            if (block.timestamp - _addressLastSwapTime[to] > 1) {
                _addressProfit[to] = _addressProfit[to] + (_balances[to] * (block.timestamp - _addressLastSwapTime[to]) * _dayProfitRate) / _dayProfitDivBase / _daySecond;
                _addressLastSwapTime[to] = block.timestamp;
            }
        }
    }
}

contract FIKing is AbsToken {
    constructor() AbsToken("FIKing", "FIKing", 18, 1 * 10**8) {}
}
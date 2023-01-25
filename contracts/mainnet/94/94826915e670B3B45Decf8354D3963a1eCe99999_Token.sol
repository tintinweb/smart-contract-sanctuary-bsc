// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./IERC20.sol";
import "./ISwapFactory.sol";
import "./ISwapRouter.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./ShareDiv.sol";

contract Token is IERC20, Context, Ownable {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private constant MAX = ~uint256(0);

    mapping(address => bool) private _isExcludedFromFee;
    address private _swapMainPair;
    mapping(address => bool) private _swapPairs;
    address private _lastMaybeLPAddress;
    address private _lastMaybeLPRemover;
    bool private _inSwapAndLiquify;
    uint256 private _numTokensSellToAddToLiquidity = 5000 * 10**9;

    address public marketAddress;
    address public routerAddress;
    address public usdtAddress;
    mapping(address => address) public relations;
    ShareDiv public lpShareDiv;
    ShareDiv public holderShareDiv;
    

    uint256 public buyMarketFee = 0;
    uint256 public buyBurnFee = 0;
    uint256 public buyLpShareFee = 150;
    uint256 public buyHolderFee = 0;
    uint256[] public buyLevelFees = [30, 20];

    uint256 public sellMarketFee = 0;
    uint256 public sellBurnFee = 30;
    uint256 public sellLpShareFee = 200;
    uint256 public sellHolderFee = 40;
    uint256[] public sellLevelFees = [20, 10];

    uint256 public holderShareMin = 2000 * 10**9;
    uint256 public lpShareMin = 10**12;

    event ProcessedLpDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        address indexed processor
    );

    event ProcessedHoldersDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        address indexed processor
    );

    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    constructor(
        address _market,
        address _router,
        address _usdt
    ) {
        _name = "T11";
        _symbol = "T11";

        address _sender = _msgSender();
        _totalSupply = 10000000 * 10**9;
        _balances[_sender] = _totalSupply;
        emit Transfer(address(0), _sender, _totalSupply);

        marketAddress = _market;
        routerAddress = _router;
        usdtAddress = _usdt;

        address _this = address(this);
        address swapFactory = ISwapRouter(_router).factory();
        address swapMainPair = ISwapFactory(swapFactory).createPair(
            _this,
            usdtAddress
        );
        holderShareDiv = new ShareDiv(_sender, _this, _this, _this);
        lpShareDiv = new ShareDiv(_sender, _this, usdtAddress, swapMainPair);

        _swapMainPair = swapMainPair;
        _swapPairs[swapMainPair] = true;
        _allowances[_this][routerAddress] = MAX;

        _isExcludedFromFee[_sender] = true;
        _isExcludedFromFee[_this] = true;
        _isExcludedFromFee[address(0xdead)] = true;
        _isExcludedFromFee[marketAddress] = true;
        _isExcludedFromFee[address(holderShareDiv)] = true;
        _isExcludedFromFee[address(lpShareDiv)] = true;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 9;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function setSwapPairs(address pair, bool flag) external onlyOwner {
        _swapPairs[pair] = flag;
    }

    function setMarketAddress(address market) external onlyOwner {
        marketAddress = market;
    }

    function setMarketFee(uint256 buyFee, uint256 sellFee) external onlyOwner {
        buyMarketFee = buyFee;
        sellMarketFee = sellFee;
    }

    function setBurnFee(uint256 buyFee, uint256 sellFee) external onlyOwner {
        buyBurnFee = buyFee;
        sellBurnFee = sellFee;
    }

    function setLpShareFee(uint256 buyFee, uint256 sellFee) external onlyOwner {
        buyLpShareFee = buyFee;
        sellLpShareFee = sellFee;
    }

    function setHolderFee(uint256 buyFee, uint256 sellFee) external onlyOwner {
        buyHolderFee = buyFee;
        sellHolderFee = sellFee;
    }

    function setLevelFees(uint256[] memory buyFees, uint256[] memory sellFees)
        external
        onlyOwner
    {
        buyLevelFees = buyFees;
        sellLevelFees = sellFees;
    }

    function setExcludedFromFee(address account, bool exclude)
        external
        onlyOwner
    {
        _isExcludedFromFee[account] = exclude;
    }

    function setNumTokensSellToAddToLiquidity(uint256 amount)
        external
        onlyOwner
    {
        _numTokensSellToAddToLiquidity = amount;
    }

    function setHolderShareMin(uint256 shareMin) external onlyOwner {
        holderShareMin = shareMin;
    }

    function setLpShareMin(uint256 shareMin) external onlyOwner {
        lpShareMin = shareMin;
    }

    function setClaim(
        address payable to,
        address token,
        uint256 amount
    ) external onlyOwner {
        if (token == address(0)) {
            (bool success, ) = to.call{value: amount}("");
            require(
                success,
                "Error: unable to send value, to may have reverted"
            );
        } else IERC20(token).transfer(to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            unchecked {
                _balances[from] = fromBalance - amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
        } else {
            _setLpHolders();
            uint256 feeAmount = 0;
            if (_swapPairs[from]) {
                feeAmount += _takeBurnAndMarketFee(
                    from,
                    amount,
                    buyBurnFee,
                    buyMarketFee
                );
                feeAmount += _takeShareFee(
                    from,
                    amount,
                    buyLpShareFee,
                    buyHolderFee
                );
                feeAmount += _takeLevelFees(from, amount, buyLevelFees, to);
            } else {
                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinTokenBalance = contractTokenBalance >=
                    _numTokensSellToAddToLiquidity;
                if (overMinTokenBalance && !_inSwapAndLiquify) {
                    contractTokenBalance = _numTokensSellToAddToLiquidity;
                    swapTokenForLpShare(contractTokenBalance);
                }
                uint256 maxSellAmount = (fromBalance * 99999) / 100000;
                if (amount > maxSellAmount) {
                    amount = maxSellAmount;
                }
                feeAmount += _takeBurnAndMarketFee(
                    from,
                    amount,
                    sellBurnFee,
                    sellMarketFee
                );
                feeAmount += _takeShareFee(
                    from,
                    amount,
                    sellLpShareFee,
                    sellHolderFee
                );
                feeAmount += _takeLevelFees(from, amount, sellLevelFees, from);
            }
            _balances[from] -= amount;
            uint256 remainAmount = amount - feeAmount;
            _balances[to] += remainAmount;
            emit Transfer(from, to, remainAmount);
        }
        if (from != address(this)) {
            _shareToLpHolders(from, to);
            _shareToHolders(from, to);
        }
        if (!_swapPairs[from] && !_swapPairs[to]) {
            _bindRelation(to, from);
        }
    }

    function _takeBurnAndMarketFee(
        address from,
        uint256 amount,
        uint256 burnFee,
        uint256 marketFee
    ) private returns (uint256) {
        uint256 burnAmount = (amount * burnFee) / 10000;
        if (burnAmount > 0) {
            _balances[address(0xdead)] += burnAmount;
            emit Transfer(from, address(0xdead), burnAmount);
        }
        uint256 marketAmount = (amount * marketFee) / 10000;
        if (marketAmount > 0) {
            _balances[marketAddress] += marketAmount;
            emit Transfer(from, marketAddress, marketAmount);
        }
        return burnAmount + marketAmount;
    }

    function _takeShareFee(
        address from,
        uint256 amount,
        uint256 lpShareFee,
        uint256 holderFee
    ) private returns (uint256) {
        uint256 lpShareAmount = (amount * lpShareFee) / 10000;
        if (lpShareAmount > 0) {
            _balances[address(this)] += lpShareAmount;
            emit Transfer(from, address(this), lpShareAmount);
        }
        uint256 holderAmount = (amount * holderFee) / 10000;
        if (holderAmount > 0) {
            _balances[address(holderShareDiv)] += holderAmount;
            holderShareDiv.distributeDividends(holderAmount);
            emit Transfer(from, address(holderShareDiv), holderAmount);
        }
        return lpShareAmount + holderAmount;
    }

    function _takeLevelFees(
        address from,
        uint256 amount,
        uint256[] memory levelFees,
        address child
    ) private returns (uint256) {
        uint256 feeAmount = 0;
        address parent = relations[child];
        for (uint8 i = 0; i < levelFees.length; i++) {
            address toAddress = parent;
            if (toAddress == address(0)) {
                toAddress = marketAddress;
            }
            uint256 levelAmount = (amount * levelFees[i]) / 10000;
            if (levelAmount > 0) {
                feeAmount += levelAmount;
                _balances[toAddress] += levelAmount;
                emit Transfer(from, toAddress, levelAmount);
                parent = relations[parent];
            }
        }
        return feeAmount;
    }

    function swapTokenForLpShare(uint256 swapAmount) private lockTheSwap {
        if (swapAmount == 0) return;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddress;
        address divAddress = address(lpShareDiv);
        IERC20 USDT = IERC20(usdtAddress);
        uint256 beforeBalance = USDT.balanceOf(divAddress);
        ISwapRouter(routerAddress)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                swapAmount,
                0,
                path,
                divAddress,
                block.timestamp
            );
        lpShareDiv.distributeDividends(
            USDT.balanceOf(divAddress) - beforeBalance
        );
    }

    function _setLpHolders() private {
        address lastMaybeLPAddress = _lastMaybeLPAddress;
        if (lastMaybeLPAddress != address(0)) {
            _lastMaybeLPAddress = address(0);
            uint256 lpBalance = IERC20(_swapMainPair).balanceOf(
                lastMaybeLPAddress
            );
            if (lpBalance >= lpShareMin) {
                lpShareDiv.setUserValue(lastMaybeLPAddress, lpBalance);
            }
        }
        address lastMaybeLPRemover = _lastMaybeLPRemover;
        if (lastMaybeLPRemover != address(0)) {
            _lastMaybeLPRemover = address(0);
            uint256 lpBalance = IERC20(_swapMainPair).balanceOf(
                lastMaybeLPRemover
            );
            if (lpBalance < lpShareMin) {
                lpShareDiv.setUserValue(lastMaybeLPRemover, 0);
            }
        }
    }

    function _shareToLpHolders(address from, address to) private {
        if (_swapPairs[from]) {
            _lastMaybeLPRemover = to;
        }
        if (_swapPairs[to]) {
            _lastMaybeLPAddress = from;
        }
        try lpShareDiv.process(lpShareMin) returns (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) {
            emit ProcessedLpDividendTracker(
                iterations,
                claims,
                lastProcessedIndex,
                true,
                tx.origin
            );
        } catch {}
    }

    function _shareToHolders(address from, address to) private {
        uint256 fromShare = holderShareDiv.getShareBalance(from);
        uint256 toShare = holderShareDiv.getShareBalance(to);
        uint256 value = 10**9;
        if (_balances[from] >= holderShareMin && fromShare < value) {
            holderShareDiv.setUserValue(from, value);
        } else if (_balances[from] < holderShareMin && fromShare > 0) {
            holderShareDiv.setUserValue(from, 0);
        }
        if (_balances[to] >= holderShareMin && toShare < value) {
            holderShareDiv.setUserValue(to, value);
        } else if (_balances[to] < holderShareMin && toShare > 0) {
            holderShareDiv.setUserValue(to, 0);
        }
        try holderShareDiv.process(holderShareMin) returns (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) {
            emit ProcessedHoldersDividendTracker(
                iterations,
                claims,
                lastProcessedIndex,
                true,
                tx.origin
            );
        } catch {}
    }

    function _bindRelation(address child, address parent) private {
        if (
            relations[child] == address(0) &&
            parent != address(0) &&
            parent != marketAddress &&
            parent != child
        ) {
            uint256 size;
            assembly {
                size := extcodesize(child)
            }
            if (size > 0) {
                return;
            }
            relations[child] = parent;
        }
    }
}
/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
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
        IERC20(token).approve(msg.sender, uint256(~uint256(0)));
    }
}

contract TXYToken is Ownable, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _feeWhiteList;
    mapping(address => bool) private _blackList;

    address public fundAddress;
    address public flowAddress;
    address public shibAddress;
    address public lpAddress;
    string private _name = "TXY Token";
    string private _symbol = "TXYM";
    uint8 private _decimals = 18;
    uint256 public lpFee = 500;
    uint256 public lpFeeBase = 10000;
    uint256 public numTokensSellToFund;
    uint256 public numTokenToDestroy;

    uint256 public lpDestroyFee = 500;
    uint256 public lpDestroyFeeBase = 1000;

    uint256 public lpShiBFee = 400;
    uint256 public lpShiBFeeBase = 1000;

    uint256 public lpUsdtFee = 100;
    uint256 public lpUsdtFeeBase = 1000;

    address public mainPair;
    uint256 private _tTotal;
    ISwapRouter public _swapRouter;

    TokenDistributor _tokenDistributor;
    address private usdt;
    address private dead;
    address private shib;
    bool public inSwap;
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        numTokenToDestroy = 1000 * 10**_decimals;
        numTokensSellToFund = 1 * 10**(_decimals-1);

        // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3   0x10ED43C718714eb63d5aA57B78B54704E256024E
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //  0xD6055D2543BB3A5e60ca7b40c7c369B55e337098   0x55d398326f99059fF775485246999027B3197955
        usdt = address(0x55d398326f99059fF775485246999027B3197955); //ly 0xc600F7Bb18c334a5FF18Ca20119A8781F0b33Db9
        dead = address(0x000000000000000000000000000000000000dEaD);
        shib = address(0x2859e4544C4bB03966803b044A93563Bd2D0DD4D); //xyw 0x934A049c11c1A72A562749D4b81fA27d05A898B3
        fundAddress = address(0xF8Fd58cD16D5dCF49C3EAd30B080B416Cf4f57c0);
        flowAddress = address(0xbBacF28a895ba3401E101b9cA4aFebBc466a1113);
        shibAddress = address(0x486e2E56F1b71557746a2CC9dF6b44B7670b919f);
        lpAddress = address(0xdFF689867Aa300E3bDe4cf56E1c1C859Bdf92337);
        _tTotal = 10000 * 10**_decimals;

        mainPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            usdt
        );
        _balances[fundAddress] = _tTotal;
        emit Transfer(address(0), fundAddress, _tTotal);

        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;

        inSwap = false;

        _tokenDistributor = new TokenDistributor(usdt);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _tTotal;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
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
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, msg.sender, currentAllowance - amount);
            }
        }
        _transfer(sender, recipient, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
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
        require(amount > 0, "Transfer amount must be greater than zero");

        require(!_blackList[from], "Transfer from the blackList address");

        bool takeFee = false;
        if (from == mainPair || to == mainPair) {
            takeFee = true;
            if (_feeWhiteList[from] || _feeWhiteList[to]) {
                takeFee = false;
            }
        } else {
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinTokenBalance = contractTokenBalance >=
                numTokensSellToFund;
            if (overMinTokenBalance && !inSwap) {
                uint256 lpUsdtPercent = (lpUsdtFee * 10000) / lpUsdtFeeBase;
                uint256 lpShibPercent = (lpShiBFee * 10000) / lpShiBFeeBase;
                uint256 totalPercent = lpUsdtPercent + lpShibPercent;
                swapTokenForFund(
                    (contractTokenBalance * lpUsdtPercent) / totalPercent
                );
                swapTokensForShiB(
                    (contractTokenBalance * lpShibPercent) / totalPercent
                );
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 balanceAcmount = balanceOf(sender);
        require(balanceAcmount >= tAmount, "Insufficient wallet balance");
        unchecked {
            _balances[sender] = _balances[sender] - tAmount;
        }

        uint256 feeAmount;
        if (takeFee) {
            feeAmount = (tAmount * lpFee) / lpFeeBase;

            uint256 deadTokenBalance = _tTotal - balanceOf(dead);
            bool overMinTokenBalance = deadTokenBalance > numTokenToDestroy;
            if (overMinTokenBalance && !inSwap) {
                unchecked {
                    _balances[dead] =
                        _balances[dead] +
                        (feeAmount * lpDestroyFee) /
                        lpDestroyFeeBase;
                }
                emit Transfer(
                    sender,
                    dead,
                    (feeAmount * lpDestroyFee) / lpDestroyFeeBase
                );
            }

            if (!overMinTokenBalance && !inSwap) {
                unchecked {
                    _balances[flowAddress] =
                        _balances[flowAddress] +
                        (feeAmount * lpDestroyFee) /
                        lpDestroyFeeBase;
                }
                emit Transfer(
                    sender,
                    flowAddress,
                    (feeAmount * lpDestroyFee) / lpDestroyFeeBase
                );
            }

            if (!inSwap) {
                unchecked {
                    _balances[address(this)] =
                        _balances[address(this)] +
                        (feeAmount * lpUsdtFee) /
                        lpUsdtFeeBase;
                }
                emit Transfer(
                    sender,
                    address(this),
                    (feeAmount * lpUsdtFee) / lpUsdtFeeBase
                );

                unchecked {
                    _balances[address(this)] =
                        _balances[address(this)] +
                        (feeAmount * lpShiBFee) /
                        lpShiBFeeBase;
                }
                emit Transfer(
                    sender,
                    address(this),
                    (feeAmount * lpShiBFee) / lpShiBFeeBase
                );
            }
        }

        uint256 rTAmount = tAmount - feeAmount;
        _balances[recipient] = _balances[recipient] + rTAmount;
        emit Transfer(sender, recipient, rTAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 lpAmount = tokenAmount / 2;

        IERC20 USDT = IERC20(usdt);
        uint256 initialBalance = USDT.balanceOf(address(_tokenDistributor));

        swapTokensForUsdt(tokenAmount - lpAmount);

        uint256 newBalance = USDT.balanceOf(address(_tokenDistributor)) -
            initialBalance; //

        USDT.transferFrom(
            address(_tokenDistributor),
            address(this),
            newBalance
        );

        addLiquidityUsdt(lpAmount, newBalance);
    }

    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        _allowances[address(this)][address(_swapRouter)] = tokenAmount;
        IERC20(usdt).approve(address(_swapRouter), usdtAmount);
        _swapRouter.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            usdtAmount,
            0,
            0,
            lpAddress,
            block.timestamp
        );
    }

    event AwapTokensForShiB(
        address shibAddress,
        uint256 value,
        uint256 timestamp
    );

    function swapTokensForShiB(uint256 tokenAmount) private {
        require(tokenAmount > 0, "too less");

        IERC20 USDT = IERC20(shib);
        uint256 initialBalance = USDT.balanceOf(address(shibAddress));

        // swapTokensForUsdt(tokenAmount);

        // uint256 newBalance = USDT.balanceOf(address(_tokenDistributor)) - initialBalance;//

        // USDT.transferFrom(address(_tokenDistributor), address(this), newBalance);

        //    IERC20(usdt).approve(address(_swapRouter), newBalance);

        _allowances[address(this)][address(_swapRouter)] = tokenAmount;
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = usdt;
        path[2] = shib;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(shibAddress),
            block.timestamp
        );
        uint256 newBalance = USDT.balanceOf(address(shibAddress)) -
            initialBalance; //
        emit AwapTokensForShiB(
            address(shibAddress),
            newBalance,
            block.timestamp
        );
    }

    function swapTokensForUsdt(uint256 tokenAmount) private {
        require(tokenAmount > 0, "too less");
        _allowances[address(this)][address(_swapRouter)] = tokenAmount;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(_tokenDistributor),
            block.timestamp
        );
    }

    receive() external payable {}

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function isFeeWhiteList(address addr) external view returns (bool) {
        return _feeWhiteList[addr];
    }

    function addBlackList(address addr) external onlyOwner {
        _blackList[addr] = true;
    }

    function removeBlackList(address addr) external onlyOwner {
        _blackList[addr] = false;
    }

    function isBlackList(address addr) external view returns (bool) {
        return _blackList[addr];
    }

    function claimBalance() public onlyOwner {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) public onlyOwner {
        IERC20(token).transfer(fundAddress, amount);
    }

    function setNumTokensSellToFund(uint256 amount) public onlyOwner {
        numTokensSellToFund = amount;
    }

    function setNumTokenToDestroy(uint256 amount) public onlyOwner {
        numTokenToDestroy = amount;
    }

    function setLpFee(uint256 _lpFee, uint256 _lpFeeBase) public onlyOwner {
        require(_lpFee != 0, "value is zero");
        require(_lpFeeBase != 0, "value is zero");
        require(_lpFee / _lpFeeBase < 1, "error value");
        lpFee = _lpFee;
        lpFeeBase = _lpFeeBase;
    }

    function setLpDestroyFee(uint256 _lpDestroyFee, uint256 _lpDestroyFeeBase)
        public
        onlyOwner
    {
        require(_lpDestroyFee != 0, "value is zero");
        require(_lpDestroyFeeBase != 0, "value is zero");
        require(_lpDestroyFee / _lpDestroyFeeBase < 1, "error value");
        lpDestroyFee = _lpDestroyFee;
        lpDestroyFeeBase = _lpDestroyFeeBase;
    }

    function setLpShiBFee(uint256 _lpShiBFee, uint256 _lpShiBFeeBase)
        public
        onlyOwner
    {
        require(_lpShiBFee != 0, "value is zero");
        require(_lpShiBFeeBase != 0, "value is zero");
        require(_lpShiBFee / _lpShiBFeeBase < 1, "error value");
        lpShiBFee = _lpShiBFee;
        lpShiBFeeBase = _lpShiBFeeBase;
    }

    function setLpUsdtFee(uint256 _lpUsdtFee, uint256 _lpUsdtFeeBase)
        public
        onlyOwner
    {
        require(_lpUsdtFee != 0, "value is zero");
        require(_lpUsdtFeeBase != 0, "value is zero");
        require(_lpUsdtFee / _lpUsdtFeeBase < 1, "error value");
        lpUsdtFee = _lpUsdtFee;
        lpUsdtFeeBase = _lpUsdtFeeBase;
    }
}
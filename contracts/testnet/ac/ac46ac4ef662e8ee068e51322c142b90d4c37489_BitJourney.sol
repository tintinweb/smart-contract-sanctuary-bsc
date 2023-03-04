//SPDX-License-Identifier: MIT
/**
 * Unlock the full potential of your image creation with BitJourney's advanced AI generation model.
 * 4 options to upscale one of them
 * The best art on BSC 
 * Holders get exclusive features
 * In contrast to our competitors, we have already established a functional product with our in-house AI Image Generation.
 *
 * This token grants its holder the benefit of revenue sharing from nine distinct streams and the ability to hold prominent position with the ecosystem.
 * Fixed supply 1B BitJourney
 *
 * Full details available at our platform: https://bitjourney.art
 * Twitter: https://twitter.com/BitjourneyAi
 * Telegram: https://t.me/bitjourneyportal
 * 1 billion tokens, locked liquidity.
 *
 * Tax 2% GPU clusters, 1% Bot Development
 * 100% Fair Launch
 * Locked liquidity
 *
 * Set slippage to 3-4% to buy BitJourney token.
 *
 * Bitjourney.art
 */
pragma solidity 0.8.17;

import "./Context.sol";
import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./DexRouter.sol";

contract BitJourney is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // token details
    uint8 private constant _decimals = 8;
    uint256 private constant _tTotal = 1000000000 * 10**_decimals;
    string private constant _name = "bitjourney.art";
    string private constant _symbol = "BitJourney";

    mapping(address => bool) private _isExcludedFromFee;

    address payable private _taxWallet;

    uint256 private _initialBuyTax = 3;
    uint256 private _initialSellTax = 15;
    uint256 private _finalTax = 3;
    uint256 private _reduceBuyTaxAt = 1;
    uint256 private _reduceSellTaxAt = 10;
    uint256 private _preventSwapBefore = 30;
    uint256 private _buyCount = 0;

    uint256 public _maxTxAmount = 10000000 * 10**_decimals;
    uint256 public _maxWalletSize = 30000000 * 10**_decimals;
    uint256 public _taxSwapThreshold = 5000000 * 10**_decimals;
    uint256 public _maxTaxSwap = 5000000 * 10**_decimals;

    DexRouter private dexRouter;
    address private pair;
    address private presaleAddress;

    bool private inSwap = false;
    bool private swapEnabled = false;
    bool public tradingOpen = false;
    bool public presaleEnabled = false;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
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
        _transfer(_msgSender(), recipient, amount);
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
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // check if the tranding is open
        if (!tradingOpen) {
            require(
                from == owner() ||
                    to == owner() ||
                    from == presaleAddress ||
                    to == presaleAddress,
                "Trading is not open yet"
            );
        }

        uint256 taxAmount = 0;

        if (from != owner() && to != owner()) {
            if (from != presaleAddress || to != presaleAddress) {
                taxAmount = amount
                    .mul(
                        (_buyCount > _reduceBuyTaxAt)
                            ? _finalTax
                            : _initialBuyTax
                    )
                    .div(100);

                // Buy - AntiWhale
                if (
                    from == pair &&
                    to != address(dexRouter) &&
                    !_isExcludedFromFee[to]
                ) {
                    require(
                        amount <= _maxTxAmount,
                        "Exceeds the max transaction amount"
                    );

                    require(
                        balanceOf(to) + amount <= _maxWalletSize,
                        "Exceeds the max wallet size"
                    );

                    _buyCount++;
                }

                // Sell - AntiWhale
                if (to == pair && from != address(this)) {
                    taxAmount = amount
                        .mul(
                            (_buyCount > _reduceSellTaxAt)
                                ? _finalTax
                                : _initialSellTax
                        )
                        .div(100);
                }

                // Swap and liquify
                uint256 contractTokenBalance = balanceOf(address(this));
                if (
                    !inSwap &&
                    to == pair &&
                    swapEnabled &&
                    contractTokenBalance > _taxSwapThreshold &&
                    _buyCount > _preventSwapBefore
                ) {
                    swapTokensForBnb(
                        min(amount, min(contractTokenBalance, _maxTaxSwap))
                    );

                    uint256 contractBNBBalance = address(this).balance;
                    if (contractBNBBalance > 0) {
                        sendBNBToFee(address(this).balance);
                    }
                }
            }

            if (taxAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(
                    taxAmount
                );

                emit Transfer(from, address(this), taxAmount);
            }
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));

        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForBnb(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;

        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendBNBToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading(bool tradingMode, address pairAddr)
        external
        onlyOwner
    {
        dexRouter = DexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = pairAddr;

        swapEnabled = true;
        tradingOpen = tradingMode;
    }

    function changePresaleMode(address presaleAddr, bool presaleMode)
        external
        onlyOwner
    {
        presaleAddress = presaleAddr;
        presaleEnabled = presaleMode;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _taxWallet);

        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForBnb(tokenBalance);
        }

        uint256 bnbBalance = address(this).balance;
        if (bnbBalance > 0) {
            sendBNBToFee(bnbBalance);
        }
    }
}
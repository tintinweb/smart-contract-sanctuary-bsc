/*
 * Tokenomics
 * Name - LevkoyCat
 * Symbol - LCAT
 * Supply - 1 million billion
 * 10% transaction tax
 */

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IBEP20.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";

contract LevkoyCat is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee; // wallets excluded from fee
    mapping(address => uint256) private _tokenSold;

    mapping(address => uint256) private _startTime;
    mapping(address => uint256) private _blockTime;

    uint256 public _maxSoldAmount;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    uint256 public _taxFee;
    uint256 public _minBalance;

    uint256 public defaultTaxFee;
    uint256 public defaultMarketingBuyback;
    uint256 public defaultDonation;
    uint256 public defaultNftDevelopment;

    address public uniswapV2Pair;
    address payable public _marketingBuybackWallet;
    address payable public _donationWallet;
    address payable public _nftDevelopmentWallet;

    bool public inSwap = false;

    IUniswapV2Router02 public uniswapV2Router; // pancakeswap v2 router

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    /**
     * @dev Initialize params for tokenomics
     */

    constructor() {
        _name = unicode"Levkoy Cat";
        _symbol = "LCAT";
        _decimals = 18;
        _totalSupply = 10**15 * 10**18;
        _balances[msg.sender] = _totalSupply;

        defaultTaxFee = 1000; // 10%
        defaultMarketingBuyback = 500;
        defaultDonation = 300;
        defaultNftDevelopment = 200;

        _taxFee = defaultTaxFee;
        _minBalance = 10 * 10**18;
        _maxSoldAmount = 2 * 10**13 * 10**18;

        _marketingBuybackWallet = payable(
            0x77D4C35762c313F9680d8FdD7992E341744Dec99
        );
        _donationWallet = payable(0x0885e0b9E9d2b4f2d941Aaf243c5C8cC77C26375);
        _nftDevelopmentWallet = payable(
            0x1c15166eD0D0d3Df47A725DbC3c2c3a0F92f47A2
        );

        // BSC MainNet router
        //0x10ED43C718714eb63d5aA57B78B54704E256024E
        // BSC TestNet router
        // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingBuybackWallet] = true;
        _isExcludedFromFee[_donationWallet] = true;
        _isExcludedFromFee[_nftDevelopmentWallet] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * @dev Returns the bep token owner.
     */

    function getOwner() external view override returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */

    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */

    //function balanceOf(address account) external override view returns (uint256) {
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
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
        override
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
        override
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

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
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
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
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
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}
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
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool takeFee = true;

        if (!inSwap && to == uniswapV2Pair) {
            // limit max sold
            if (_tokenSold[from] == 0) {
                _startTime[from] = block.timestamp;
            }

            _tokenSold[from] = _tokenSold[from] + amount;

            if (block.timestamp < _startTime[from] + (1 days)) {
                require(
                    _tokenSold[from] <= _maxSoldAmount,
                    "Sold amount exceeds the maxTxAmount."
                );
            } else {
                _startTime[from] = block.timestamp;
                _tokenSold[from] = 0;
            }

            // transfer tokens
            uint256 lcatBalance = balanceOf(address(this));
            if (lcatBalance > _minBalance) {
                transferTokens(lcatBalance);
            }

            if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
                takeFee = false;
            }
        } else {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev transfer tokens to marketing and buy back wallet, donation wallet and nft development wallet.
     * We have 10% LCAT token fee (tax fee)
     */

    function transferTokens(uint256 tokenBalance) private lockTheSwap {
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokenBalance);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 marketingBuyBackBNB = newBalance
            .mul(defaultMarketingBuyback)
            .div(defaultTaxFee);
        uint256 donationBNB = newBalance.mul(defaultDonation).div(
            defaultTaxFee
        );
        uint256 nftDevelopmentBNB = newBalance.mul(defaultNftDevelopment).div(
            defaultTaxFee
        );

        _marketingBuybackWallet.transfer(marketingBuyBackBNB);
        _donationWallet.transfer(donationBNB);
        _nftDevelopmentWallet.transfer(nftDevelopmentBNB);
    }

    /**
     * @dev Swap tokens from lcat to bnb
     */

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     * @dev Add lcat token and bnb as same ratio on pancakeswap router
     */

    function addLiqudity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add amount to contract
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    /**
     * @dev the Owner can swap regarding the lcat token's amount of contract balance
     * this is for manual function
     */

    function contractBalanceSwap() external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    /**
     * @dev the Owner can send regarding the lcat token's amount of contract balance
     * this is for manual function
     * 0.1BNB will remain in contract balance for swap and transfer fees.
     */

    function contractBalanceSend(uint256 amount, address payable _destAddr)
        external
        onlyOwner
    {
        uint256 contractETHBalance = address(this).balance - 1 * 10**17;
        if (contractETHBalance > amount) {
            _destAddr.transfer(amount);
        }
    }

    /**
     * @dev remove all fees
     */

    function removeAllFee() private {
        if (_taxFee == 0) return;
        _taxFee = 0;
    }

    /**
     * @dev set all fees
     */

    function restoreAllFee() private {
        _taxFee = defaultTaxFee;
    }

    /**
     * @dev transfer tokens with amount
     */

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool isTakeFee
    ) private {
        if (!isTakeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!isTakeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 fee = amount.mul(_taxFee).div(10000); // for 3% fee
        //_beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
        uint256 amountnew = amount - fee;
        _balances[recipient] += (amountnew);

        if (fee > 0) {
            _balances[address(this)] += (fee);
            emit Transfer(sender, address(this), fee);
        }

        emit Transfer(sender, recipient, amountnew);
    }

    /**
     * @dev set Max sold amount
     */

    function _setMaxSoldAmount(uint256 maxvalue) external onlyOwner {
        require(
            maxvalue <= 9 * 10**14 * 10**18,
            "Max sold amount must not be greater than 90% total supply"
        );
        _maxSoldAmount = maxvalue;
    }

    /**
     * @dev set min balance for transferring
     */

    function _setMinBalance(uint256 minValue) external onlyOwner {
        _minBalance = minValue;
    }

    /**
     * @dev determine whether we apply tax fee or not
     */

    function _setApplyContractFee(bool isFee) external onlyOwner {
        if (isFee) {
            _taxFee = defaultTaxFee;
        } else {
            _taxFee = 0;
        }
    }

    function _setMarketingBuybackWalletAddress(
        address marketingBuybackWalletAddr
    ) external onlyOwner {
        _marketingBuybackWallet = payable(marketingBuybackWalletAddr);
    }

    function _setDonationWalletAddress(address donationWalletAddr)
        external
        onlyOwner
    {
        _donationWallet = payable(donationWalletAddr);
    }

    function _setNftDevelopmentWalletAddress(address nftDevelopmentWalletAddr)
        external
        onlyOwner
    {
        _nftDevelopmentWallet = payable(nftDevelopmentWalletAddr);
    }

    receive() external payable {}
}
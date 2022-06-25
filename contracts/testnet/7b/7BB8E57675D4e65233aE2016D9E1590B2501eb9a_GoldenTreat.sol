// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
// Contracts
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./utils/IBabyDogeFactory.sol";
import "./utils/IBabyDogePair.sol";
import "./utils/IBabyDogeRouter.sol";
import "./utils/ITreatToken.sol";
import "./utils/ITreatVesting.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract GoldenTreat is AccessControl, IERC20, IERC20Metadata, IBabyDogeGoldenTreat {
    using SafeERC20 for IERC20;

    struct ExchangeTax {
        uint256 marketingSell;
        uint256 liquiditySell;
        uint256 buyBackSell;
        uint256 burnedSell;
        uint256 marketingBuy;
        uint256 liquidityBuy;
        uint256 buyBackBuy;
    }
    struct Checkpoint {
        uint256 fromBlock;
        uint256 votes;
    }
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint256 private liquidityBalance;
    uint256 private buyBackBalance;
    uint256 private liquifyTriggerAmount;
    uint256 private buyFeePercent;
    address private immutable ROUTER;
    address private distributionContract;
    address private marketingWallet;
    address private buyBackAddress;
    address private liquidityToken;
    ITreatVesting public vesting;
    bool private vestingIsActive;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private approvedFactory; //Factory is approved to verify pairs address
    mapping(address => bool) private exchangeAddress; //if exchangeAddress[address] = true then its a router
    mapping(address => bool) private _isExcludedFromFee; // Excluded from fee
    mapping(address => bool) private _AddLiquidity; // Excluded from fee
    mapping(address => mapping(uint256 => Checkpoint)) internal checkpoints;
    mapping(address => uint256) internal numCheckpoints;
    mapping(address => address) private delegates;
    ExchangeTax private TAX;

    bytes32 internal constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /*
     * @param Token name
     * @param Token symbol
     * @param Token amount to mint
     * @param Minimum amount of tokens to trigger swapAndLiquify
     * @param Router address
     * @param BuyBack token address
     * @param Address of token, which pool should receive liquidity during swapAndLiquify
     * @param Is token vesting active? true = active
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 liquifyTriggerAmount_,
        address router_,
        address buyBackAddress_,
        address liquidityToken_,
        bool vestingIsActive_
    ) {
        require(router_ != address(0)
            && buyBackAddress_ != address(0)
            && liquidityToken_ != address(0), "Zero address");
        _name = name_;
        _symbol = symbol_;
        vestingIsActive = vestingIsActive_;
        liquifyTriggerAmount = liquifyTriggerAmount_;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(GOVERNANCE_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        ROUTER = router_;
        buyBackAddress = buyBackAddress_;
        liquidityToken = liquidityToken_;
        address factory = IBabyDogeRouter(ROUTER).factory();
        address WETH = IBabyDogeRouter(ROUTER).WETH();
        address PAIR = IBabyDogeFactory(factory).createPair(address(this), WETH);
        approveFactory(factory, true);
        setExchangeAddress(factory, WETH);
        setExcludedFromFeeAddress(ROUTER, true);
        setExcludedFromFeeAddress(PAIR, true);
        setExcludedFromFeeAddress(address(this), true);
        setExcludedFromFeeAddress(0x000000000000000000000000000000000000dEaD, true);
    }

    /**
     * @dev Contract might receive/hold ETH as part of the maintenance process.
     */
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /// @notice An event thats emitted when ETH received by contract
    event Received(address, uint256);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );

    event ErrorAddLiquidity(
        address,
        address,
        bytes
    );

    event ErrorSwap(
        address,
        address,
        bytes
    );

    event FeeUpdated(
        uint256 _marketingSell,
        uint256 _liquiditySell,
        uint256 _burnedSell,
        uint256 _buyBackSell,
        uint256 _marketingBuy,
        uint256 _liquidityBuy,
        uint256 _buyBackBuy,
        uint256 _buyFeePercent
    );

    event UpdatedTaxAddresses(
        address _distributionContract,
        address _marketingWallet
    );

    event UpdatedBuyBackAddress(address _buyBackAddress, address liquidityToken_);
    event FactoryApproved(address factory, bool approved);
    event ExchangeAddressAdded(address factory, address tokenB);
    event ExcludedFromFee(address _account, bool _excluded);
    event LiquidityAddressSet(address _address, bool _isLiquidity);
    event NewLiquifyTriggerAmount(uint256);
    event VestingSet(bool);

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
     * @dev Decimal points for a token. Used mostly for representation. It’s like Wei to Ether.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override (IBabyDogeGoldenTreat, IERC20)
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount)
        public
        virtual
        onlyRole(MINTER_ROLE)
    {
        _mint(to, amount);
    }

    /**
     * @dev See {IERC20-transfer}.
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

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev This is an alternative to `approve` that can be used as a mitigation for problems described in {IERC20-approve}.
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
     * @dev This is an alternative to `approve` that can be used as a mitigation for problems described in {IERC20-approve}.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        if(exchangeAddress[sender] && !_isExcludedFromFee[recipient]) {
            uint256 buyFee = amount * buyFeePercent / 10000;
            amount -= buyFee;
            _balances[sender] -= buyFee;
            _balances[address(this)] += buyFee;
            emit Transfer(sender, address(this), buyFee);
            _takeTax(buyFee, false);
        }
        uint256 amountIn = _beforeTokenTransfer(sender, recipient, amount);
        _moveDelegates(
            delegates[sender],
            delegates[recipient],
            amount,
            amountIn
        );
        _afterTokenTransfer();
    }

    function _mint(address account, uint256 amount) internal virtual {
//        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        if (vestingIsActive && !_isExcludedFromFee[account]) {
            vesting.vestingUpdate(account, amount, address(0), false);
        }

        emit Transfer(address(0), account, amount);

        _afterTokenTransfer();
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /*
     * @title Sets fees upon buying and selling tokens (transfer to exchange)
     * @param Sell Marketing fee (send to marketing wallet)
     * @param Sell Liquidity fee (add liquidity to DEX)
     * @param Sell Burn fee (send to burn wallet)
     * @param Sell Buyback fee (swap to BuyBack token and send to distribution contract)
     * @param Buy Marketing fee (send to marketing wallet)
     * @param Buy Liquidity fee (add liquidity to DEX)
     * @param Buy Buyback fee (swap to BuyBack token and send to distribution contract)
     * @param Buy fee percent (in basis points)
     * @dev The caller must have the `GOVERNANCE_ROLE`
     */
    function SetFee(
        uint256 _marketingSell,
        uint256 _liquiditySell,
        uint256 _burnedSell,
        uint256 _buyBackSell,
        uint256 _marketingBuy,
        uint256 _liquidityBuy,
        uint256 _buyBackBuy,
        uint256 _buyFeePercent
    ) external onlyRole(GOVERNANCE_ROLE) {
        require(_marketingSell
            + _liquiditySell
            + _burnedSell
            + _buyBackSell == 10000
        && _marketingBuy
            + _liquidityBuy
            + _buyBackBuy == 10000
        && _buyFeePercent < 10000, "Invalid values");

        ExchangeTax storage tax = TAX;
        //Sell
        tax.marketingSell = _marketingSell;
        tax.liquiditySell = _liquiditySell;
        tax.burnedSell = _burnedSell;
        tax.buyBackSell = _buyBackSell;
        //Buy taxes
        tax.marketingBuy = _marketingBuy;
        tax.liquidityBuy = _liquidityBuy;
        tax.buyBackBuy = _buyBackBuy;

        buyFeePercent = _buyFeePercent;
        emit FeeUpdated(
            _marketingSell,
            _liquiditySell,
            _burnedSell,
            _buyBackSell,
            _marketingBuy,
            _liquidityBuy,
            _buyBackBuy,
            _buyFeePercent
        );
    }

    /*
     * @title Sets addresses of buyBack and marketing tax receivers
     * @param Address, which will receive BuyBack tokens upon _swapAndLiquify
     * @param Address, which will receive marketing tax upon _takeTax
     * @dev The caller must have the `GOVERNANCE_ROLE`
     */
    function setTaxAddresses(
        address _distributionContract,
        address _marketingWallet
    ) external onlyRole(GOVERNANCE_ROLE) {
        require(_distributionContract != address(0) && _marketingWallet != address(0),
            "Zero address");
        distributionContract = _distributionContract;
        marketingWallet = _marketingWallet;

        emit UpdatedTaxAddresses(
            _distributionContract,
            _marketingWallet
        );
    }

    /*
     * @title Sets different BuyBack and liquidity token addresses for swapAndLiquify
     * @param New address of BuyBack token
     * @param New address of token for adding liquidity
     * @dev The caller must have the `GOVERNANCE_ROLE`
     */
    function setBuyBackAddress(
        address _buyBackAddress,
        address liquidityToken_
    ) external onlyRole(GOVERNANCE_ROLE) {
        require(_buyBackAddress != address(0) && liquidityToken_ != address(0),
            "Zero address");
        buyBackAddress = _buyBackAddress;
        liquidityToken = liquidityToken_;

        emit UpdatedBuyBackAddress(
            _buyBackAddress,
            liquidityToken_
        );
    }

     /*
      * @title Approves factory address
      * @param Factory address
      * @param Is included to approved factory list
      * @dev The caller must have the `GOVERNANCE_ROLE`
      */
    function approveFactory(address factory, bool approved)
        public
        onlyRole(GOVERNANCE_ROLE)
    {
        approvedFactory[factory] = approved;

        emit FactoryApproved(factory, approved);
    }

     /*
      * @title Marks pair address (Treat<>tokenB) as an exchange address
      * @param Factory address
      * @param TokenB address
      * @dev Factory must be approved and pair must exist
      */
    function setExchangeAddress(
        address factory,
        address tokenB
    )
        public
    {
        address pair = IBabyDogeFactory(factory).getPair(address(this), tokenB);
        require(approvedFactory[factory] && pair != address(0), "Invalid factory or 0 pair");
        exchangeAddress[pair] = true;
        _isExcludedFromFee[pair] = true;

        emit ExchangeAddressAdded(factory, tokenB);
    }

    /*
     * @title Exclude address from fees
     * @param Excluded address
     * @param Is excluded from fees bool
     * @dev The caller must have the `GOVERNANCE_ROLE`
     */
    function setExcludedFromFeeAddress(address _account, bool _excluded)
        public
        onlyRole(GOVERNANCE_ROLE)
    {
        _isExcludedFromFee[_account] = _excluded;

        emit ExcludedFromFee(_account, _excluded);
    }

    /*
     * @title Set liquidity address
     * @param Liquidity address
     * @param Is liquidity address bool
     * @dev The caller must have the `GOVERNANCE_ROLE`
     */
    function setLiquidityAddress(address _address, bool _isLiquidity)
        external
        onlyRole(GOVERNANCE_ROLE)
    {
        _AddLiquidity[_address] = _isLiquidity;

        emit LiquidityAddressSet(_address, _isLiquidity);
    }

    /*
     * @title Set liquify trigger amount
     * @param amount
     * @dev The caller must have the `GOVERNANCE_ROLE`
     */
    function setLiquifyTriggerAmount(uint256 _liquifyTriggerAmount)
        external
        onlyRole(GOVERNANCE_ROLE)
    {
        liquifyTriggerAmount = _liquifyTriggerAmount;

        emit NewLiquifyTriggerAmount(_liquifyTriggerAmount);
    }

    /*
     * @title Enables or disables vesting
     * @param Is vesting active (true = active, false = not active)
     * @dev The caller must have the `GOVERNANCE_ROLE`
     */
    function setVesting(
        bool _vestingIsActive
    ) external onlyRole(GOVERNANCE_ROLE) {
        vestingIsActive = _vestingIsActive;

        emit VestingSet(_vestingIsActive);
    }

    /*
     * @title Set vesting contract address and mint initial tokens
     * @param Vesting contract address
     * @param tokens to mint
     * @dev The caller must have the `GOVERNANCE_ROLE`
     * @dev Can be called only 1 time
     */
    function setVestingContract(
        ITreatVesting _vesting,
        uint256 _amount
    ) external onlyRole(GOVERNANCE_ROLE) {
        require(vesting == ITreatVesting(address(0)), "Already set");
        require(_vesting != ITreatVesting(address(0)), "Invalid address");
        vesting = _vesting;
        mint(msg.sender, _amount);
    }

    function recoverUnVested(address _from, uint256 _toRecover) internal {
        _balances[0x000000000000000000000000000000000000dEaD] += _toRecover;
        emit Transfer(_from, 0x000000000000000000000000000000000000dEaD, _toRecover);
    }

    /*
     * @title Transfers tokens with vesting
     * @param Sender address
     * @param Receiver address
     * @param Amount of tokens to transfer
     * @param Is sender a regular address (not excluded from fee)?
     * @param Is receiver a regular address (not excluded from fee)?
     * @return Amount of tokens has been transferred
     */
    function standardTransfer(
        address from,
        address to,
        uint256 amount,
        bool fromVesting,
        bool toVesting
    ) internal returns (uint256 amountOut) {
        uint256 willSend = amount;
        uint256 toRecover = 0;
        if (fromVesting) {
            (willSend, toRecover) = vesting.registerTransfer(
                from,
                _balances[from],
                amount
            );
            // Find out what portion of the balance is locked and unlocked
            if (toRecover > 0) {
                if (exchangeAddress[to]) {
                    _balances[address(this)] += toRecover;
                    emit Transfer(from, address(this), toRecover);
                    _takeTax(toRecover, true);
                    if (
                        liquidityBalance + buyBackBalance >
                        liquifyTriggerAmount
                    ) {
                        _swapAndLiquify();
                    }
                } else {
                    recoverUnVested(from, toRecover);
                }
            }
        }

        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = senderBalance - amount;
        }

        _balances[to] += willSend;
        emit Transfer(from, to, willSend);
        if (toVesting) {
            vesting.vestingUpdate(to, willSend, address(0), false);
        }
        return amountOut = willSend;
    }

    /*
     * @title Transfers tokens to or from TreatLiquidity
     * @param Sender address
     * @param Receiver address
     * @param Amount of tokens to transfer
     * @return Amount of tokens has been transferred
     */
    function liquidityTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256 amountOut) {
        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        if (_AddLiquidity[to] && !_isExcludedFromFee[from]) {
            vesting.registerStake(
                from,
                to,
                amount * 10000 / _balances[from],
                true
            );
        } else if (!_isExcludedFromFee[to]){
            vesting.registerStake(
                to,
                from,
                0,
                false
            );
        }

        unchecked {
            _balances[from] = senderBalance - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return amountOut = amount;
    }

    /*
     * @title Transfers tokens without vesting
     * @param Sender address
     * @param Receiver address
     * @param Amount of tokens to transfer
     * @return Amount of tokens has been transferred
     */
    function transferNoVesting(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256 amountOut) {
        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = senderBalance - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return amountOut = amount;
    }

    /*
     * @title Decides which transfer type should be used
     * @param Sender address
     * @param Receiver address
     * @param Amount of tokens to transfer
     * @return Amount of tokens has been transferred
     */
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual returns (uint256 amountOut) {
        if (_from != address(0)) {
            if (!vestingIsActive) {
                return amountOut = transferNoVesting(_from, _to, _amount);
            } else if (_AddLiquidity[_from] || _AddLiquidity[_to]) {
                return amountOut = liquidityTransfer(_from, _to, _amount);
            } else if (_isExcludedFromFee[_from]) {
                if (_isExcludedFromFee[_to]) {
                    //SENDER AND RECEIVER HAS NO VESTING
                    return
                        amountOut = standardTransfer(
                            _from,
                            _to,
                            _amount,
                            false,
                            false
                        );
                } else {
                    // RECEIVER HAS VESTING
                    return
                        amountOut = standardTransfer(
                            _from,
                            _to,
                            _amount,
                            false,
                            true
                        );
                }
            } else if (_isExcludedFromFee[_to]) {
                //NO VESTING FOR RECEIVER
                return
                    amountOut = standardTransfer(
                        _from,
                        _to,
                        _amount,
                        true,
                        false
                    );
            } else {
                amountOut = standardTransfer(_from, _to, _amount, true, true);
            }
        }
    }

    /*
     * @title Distributes specific amount of taxes
     * @param Amount of taxes to be distributed
     * @param Is this a sell transaction (true = sell)
     * @return Sum of taxes
     */
    function _takeTax(uint256 _amount, bool isSell)
        internal
        returns (uint256 amountAfterFee)
    {
        ExchangeTax storage tax = TAX;

        uint256 _marketingBalance = 0;
        uint256 _liquidityAmount = 0;
        uint256 _buyBackAmount = 0;
        uint256 _burnAmount = 0;
        //Sell transaction
        if(isSell) {
            _marketingBalance = _amount * tax.marketingSell / 10000;
            _liquidityAmount = _amount * tax.liquiditySell / 10000;
            _buyBackAmount = _amount * tax.buyBackSell / 10000;
            _burnAmount = _amount * tax.burnedSell / 10000;
        }
        //Buy transaction
        else {
            _marketingBalance = _amount * tax.marketingBuy / 10000;
            _liquidityAmount = _amount * tax.liquidityBuy / 10000;
            _buyBackAmount = _amount * tax.buyBackBuy / 10000;
        }

        uint256 totalFeeAmount = _marketingBalance
             + _liquidityAmount
             + _buyBackAmount
             + _burnAmount;

        if (_marketingBalance != 0) {
            transferNoVesting(
                address(this),
                marketingWallet,
                _marketingBalance
            );
        }
        if (_liquidityAmount != 0) {
            liquidityBalance += _liquidityAmount;
        }
        if (_buyBackAmount != 0) {
            buyBackBalance += _buyBackAmount;
        }
        if (_burnAmount != 0) {
            transferNoVesting(address(this), 0x000000000000000000000000000000000000dEaD, _burnAmount);
        }
        return totalFeeAmount;
    }

    function _afterTokenTransfer() internal virtual {}

    /*
     * @title Swaps collected tokens, adds liquidity and buys BuyBack tokens
     */
    //take amount of tokens for lp fee + buybackBabyDoge Fee
    function _swapAndLiquify() internal {
        address weth = IBabyDogeRouter(ROUTER).WETH();
        uint256 expectedBuyBackWETH;
        if (buyBackAddress == address(this)) {
            buyBackBalance = 0;
            expectedBuyBackWETH = 0;
        }
        // Split the Token balance into halves
        uint256 halfForTokenLP = liquidityBalance / 2;
        uint256 totalToSwap = halfForTokenLP + buyBackBalance;
        if (buyBackBalance != 0) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = weth;
            expectedBuyBackWETH = IBabyDogeRouter(ROUTER).getAmountsOut(
                buyBackBalance,
                path
            )[1];
        }

        buyBackBalance = 0;
        liquidityBalance = 0;

        uint256 ethBalanceBeforeSwap = address(this).balance;
        _swapTokens(address(this), weth, totalToSwap, address(this));

        uint256 ethReceivedFromSwap = address(this).balance - ethBalanceBeforeSwap;
        uint256 ethToLiquidity = ethReceivedFromSwap - expectedBuyBackWETH;
        address _liquidityToken = liquidityToken;
        _addLiquidity(
            halfForTokenLP,
            ethToLiquidity,
            _liquidityToken,
            weth
        );
        if (expectedBuyBackWETH > 0)
            _swapTokens(
                weth,
                buyBackAddress,
                expectedBuyBackWETH,
                address(this)
            );
        IERC20(buyBackAddress).safeTransfer(
            distributionContract,
            IERC20(buyBackAddress).balanceOf(address(this))
        );
        emit SwapAndLiquify(
            halfForTokenLP,
            ethReceivedFromSwap,
            halfForTokenLP
        );
    }

    /*
     * @title Distributes specific amount of taxes
     * @param Amount of tokens to add to liquidity
     * @param Amount of ETH or ETH equivalent to add to liquidity
     * @param Token address of liquidity pair
     * @param WETH address
     */
    function _addLiquidity(
        uint256 _tokenAmount,
        uint256 _ethAmount,
        address _liquidityToken,
        address weth
    ) private {
        _approve(address(this), ROUTER, _tokenAmount);
        //if liquidityToken == WETH
        if(_liquidityToken == weth) {
            try IBabyDogeRouter(ROUTER).addLiquidityETH{value: _ethAmount}(
                address(this),
                _tokenAmount,
                0,
                0,
                address(this),
                block.timestamp
            ) {} catch(bytes memory error){
                emit ErrorAddLiquidity(address(this), weth, error);
            }
        }
        //if liquidityToken != WETH
        else {
            uint256 tokenBought = _swapTokens(
                weth,
                _liquidityToken,
                _ethAmount,
                address(this)
            );

            if(IERC20(_liquidityToken).allowance(address(this),ROUTER) < tokenBought) {
                IERC20(_liquidityToken).approve(ROUTER, type(uint256).max);
            }
            try IBabyDogeRouter(ROUTER).addLiquidity(
                address(this),
                _liquidityToken,
                _tokenAmount,
                tokenBought,
                0,
                0,
                address(this),
                block.timestamp
            ) {} catch(bytes memory error){
                emit ErrorAddLiquidity(address(this), weth, error);
            }
        }
    }

    /*
     * @title Swaps tokens to WETH or other tokens, or tokens to WETH
     * @param Token address to swap
     * @param Token address to receive
     * @param Amount of tokens to swap
     * @param Address to receive tokens
     * @return Amount of tokens received after swap
     */
    function _swapTokens(
        address _FromTokenContractAddress,
        address _ToTokenContractAddress,
        uint256 _amountIn,
        address _forWallet
    ) internal returns (uint256 tokenBought) {
        address[] memory path;
        address WETH = IBabyDogeRouter(ROUTER).WETH();
        uint256 amountOutMin;

        if (_ToTokenContractAddress == WETH) {
            path = new address[](2);
            path[0] = _FromTokenContractAddress;
            path[1] = WETH;
            IERC20(path[0]).approve(ROUTER, _amountIn);
            amountOutMin = IBabyDogeRouter(ROUTER).getAmountsOut(_amountIn, path)[1];
            try IBabyDogeRouter(ROUTER).swapExactTokensForETH(
                _amountIn,
                amountOutMin,
                path,
                _forWallet,
                block.timestamp + 1200
            ) returns(uint256[] memory _amount){
                tokenBought = _amount[path.length - 1];
            } catch(bytes memory error){
                emit ErrorSwap(
                    _FromTokenContractAddress,
                    _ToTokenContractAddress,
                    error
                );
            }
        } else {
            path = new address[](2);
            path[0] = WETH;
            path[1] = _ToTokenContractAddress;
            amountOutMin = IBabyDogeRouter(ROUTER).getAmountsOut(_amountIn, path)[1];
            amountOutMin = amountOutMin * 8000 / 10000;
            try IBabyDogeRouter(ROUTER).swapExactETHForTokens{
                value: _amountIn
            }(amountOutMin, path, _forWallet, block.timestamp + 1200)
                returns(uint256[] memory _amount)
            {
                tokenBought = _amount[path.length - 1];
            } catch(bytes memory error) {
                emit ErrorSwap(
                    _FromTokenContractAddress,
                    _ToTokenContractAddress,
                    error
                );
            }
        }
    }

    function getCurrentVotes(address _account) external view returns (uint256) {
        uint256 nCheckpoints = numCheckpoints[_account];
        return
            nCheckpoints > 0
                ? checkpoints[_account][nCheckpoints - 1].votes
                : 0;
    }

    function delegate(address _delegatee) external {
        return _delegate(msg.sender, _delegatee);
    }

    function _delegate(address _delegator, address _delegatee) internal {
        address currentDelegate = delegates[_delegator];
        uint256 delegatorBalance = _balances[_delegator];
        delegates[_delegator] = _delegatee;

        emit DelegateChanged(_delegator, currentDelegate, _delegatee);

        _moveDelegates(
            currentDelegate,
            _delegatee,
            delegatorBalance,
            delegatorBalance
        );
    }

    function _moveDelegates(
        address _srcRep,
        address _dstRep,
        uint256 _amountOut,
        uint256 _amountIn
    ) internal {
        if (_srcRep != _dstRep && _amountOut > 0) {
            if (_srcRep != address(0)) {
                uint256 srcRepNum = numCheckpoints[_srcRep];
                uint256 srcRepOld = srcRepNum > 0
                    ? checkpoints[_srcRep][srcRepNum - 1].votes
                    : 0;
                uint256 srcRepNew = srcRepOld - _amountOut;
                _writeCheckpoint(_srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (_dstRep != address(0)) {
                uint256 dstRepNum = numCheckpoints[_dstRep];
                uint256 dstRepOld = dstRepNum > 0
                    ? checkpoints[_dstRep][dstRepNum - 1].votes
                    : 0;
                uint256 dstRepNew = dstRepOld + _amountIn;
                _writeCheckpoint(_dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address _delegatee,
        uint256 _nCheckpoints,
        uint256 _oldVotes,
        uint256 _newVotes
    ) internal {
        uint256 blockNumber = block.number;

        if (
            _nCheckpoints > 0 &&
            checkpoints[_delegatee][_nCheckpoints - 1].fromBlock == blockNumber
        ) {
            checkpoints[_delegatee][_nCheckpoints - 1].votes = _newVotes;
        } else {
            checkpoints[_delegatee][_nCheckpoints] = Checkpoint(
                blockNumber,
                _newVotes
            );
            numCheckpoints[_delegatee] = _nCheckpoints + 1;
        }

        emit DelegateVotesChanged(_delegatee, _oldVotes, _newVotes);
    }

    function getPriorVotes(address account, uint256 blockNumber)
        public
        view
        returns (uint256)
    {
        uint256 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint256 lower = 0;
        uint256 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint256 center = upper - (upper - lower) / 2;
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

//SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

interface IBabyDogeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

//SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

interface IBabyDogePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IBabyDogeRouter  {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBabyDogeGoldenTreat {
    function getPriorVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITreatVesting {
    function registerStake(
        address account,
        address stakingContract,
        uint256 percentage,
        bool isStaking
    ) external;

    function registerTransfer(
        address account,
        uint256 balance,
        uint256 transferAmount
    ) external returns(uint256 willSend, uint256 toRecover);

    function vestingUpdate(
        address _recipient,
        uint256 _amount,
        address _stakingContract,
        bool _liquidity
    ) external;

    function burnStakeVesting(
        address account,
        uint256 percentage
    ) external;

    function viewNotVestedTokens(
        address recipient,
        address stakingContract
    ) external returns(uint256 locked, uint256 coolDownRemaining);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
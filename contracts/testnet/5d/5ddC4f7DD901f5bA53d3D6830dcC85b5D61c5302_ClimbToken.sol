//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ReentrantGuard.sol";
import "./IClimb.sol";
import "./IUniswapV2Router02.sol";

/**
 * Contract: Climb Token (xUSD fork)
 * By: SA69
 *
 * Token with a built-in Automated Market Maker
 * Send BNB to contract and it will mint CLIMB Tokens
 * Stake BUSD into contract and it will mint CLIMB Tokens
 * Sell this token to redeem underlying BUSD Tokens
 * Price is calculated as a ratio between Total Supply and underlying asset quantity in Contract
 */

contract ClimbToken is IERC20, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    // token data
    string constant _name = "Climb";
    string constant _symbol = "CLIMB";
    uint8 constant _decimals = 18;
    uint256 constant precision = 10**18;

    // lock to Matrix contract
    bool isLocked = true;
    mapping(address => bool) public isMatrix;

    // 1 CLIMB Starting Supply
    uint256 _totalSupply = 1 * 10**_decimals;

    // balances
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    // Fees
    uint256 public mintFee = 950; // 5.0% buy fee
    uint256 public sellFee = 950; // 5.0% sell fee
    uint256 public transferFee = 950; // 5.0% transfer fee
    uint256 public constant feeDenominator = 10**3;

    uint256 public devShare = 100; // 1% dev fee
    uint256 public liquidityShare = 400; // 4% funding fee

    address public dev = 0x3bFb99f6eD9DAe9D09b65eF0Bb0ffF4473ea653b;

    // Underlying Asset
    address public constant _underlying =
        0x337610d27c682E347C9cD60BD4b3b107C9d34dDd; // mainnet: 0x55d398326f99059fF775485246999027B3197955; // USDT

    // fee exemption for utility
    mapping(address => bool) public isFeeExempt;

    // volume for each recipient
    mapping(address => uint256) _volumeFor;

    // PCS Router
    IUniswapV2Router02 _router;

    // BNB -> Token
    address[] path;

    // token purchase slippage maximum
    uint256 public _tokenSlippage = 995;

    // owner
    address _owner;

    // Activates Token Trading
    bool Token_Activated;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only Owner Function");
        _;
    }

    // initialize some stuff
    constructor() {
        // router
        _router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1 // mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        path = new address[](2);
        path[0] = _router.WETH();
        path[1] = _underlying;

        // fee exempt this + owner + router for LP injection
        isFeeExempt[address(this)] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[0xD99D1c33F9fC3444f8101754aBC46c52416550D1] = true; // mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E

        // allocate one token to dead wallet to ensure total supply never reaches 0
        address dead = 0x000000000000000000000000000000000000dEaD;
        _balances[address(this)] = (_totalSupply - 1);
        _balances[dead] = 1;

        // ownership
        _owner = msg.sender;

        // emit allocations
        emit Transfer(address(0), address(this), (_totalSupply - 1));
        emit Transfer(address(0), dead, 1);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
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

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /** Transfer Function */
    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    /** Transfer Function */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(
            amount,
            "Insufficient Allowance"
        );
        return _transferFrom(sender, recipient, amount);
    }

    /** Internal Transfer */
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        // make standard checks
        require(
            recipient != address(0) && sender != address(0),
            "Transfer To Zero Address"
        );
        require(amount > 0, "Transfer amount must be greater than zero");
        // track price change
        uint256 oldPrice = _calculatePrice();

        // fee exempt
        bool takeFee = !(isFeeExempt[sender] || isFeeExempt[recipient]);

        // amount to give recipient
        uint256 tAmount = takeFee
            ? amount.mul(transferFee).div(feeDenominator)
            : amount;

        // tax taken from transfer
        uint256 tax = amount.sub(tAmount);

        // subtract from sender
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        if (takeFee) {
            // allocate dev share
            uint256 allocation = tax.mul(devShare).div(
                devShare.add(liquidityShare)
            );
            // mint to dev
            _mint(dev, allocation);
        }

        // give reduced amount to receiver
        _balances[recipient] = _balances[recipient].add(tAmount);

        // burn the tax
        if (tax > 0) {
            _totalSupply = _totalSupply.sub(tax);
            emit Transfer(sender, address(0), tax);
        }

        // volume for
        _volumeFor[sender] += amount;
        _volumeFor[recipient] += tAmount;

        // Price difference
        uint256 currentPrice = _calculatePrice();
        // Require Current Price >= Last Price
        require(
            currentPrice >= oldPrice,
            "Price Must Rise For Transaction To Conclude"
        );
        // Transfer Event
        emit Transfer(sender, recipient, tAmount);
        // Emit The Price Change
        emit PriceChange(oldPrice, currentPrice, _totalSupply);
        return true;
    }

    /** Receives Underlying Tokens and Deposits CLIMB in Sender's Address, Must Have Prior Approval */
    function buy(uint256 numTokens) external nonReentrant returns (bool) {
        return _stakeUnderlyingAsset(numTokens, msg.sender);
    }

    /** Receives Underlying Tokens and Deposits CLIMB in Recipient's Address, Must Have Prior Approval */
    function buy(address recipient, uint256 numTokens)
        external
        nonReentrant
        returns (bool)
    {
        return _stakeUnderlyingAsset(numTokens, recipient);
    }

    /** Sells CLIMB Tokens And Deposits Underlying Asset Tokens into Seller's Address */
    function sell(uint256 tokenAmount) external nonReentrant {
        _sell(tokenAmount, msg.sender);
    }

    /** Sells CLIMB Tokens And Deposits Underlying Asset Tokens into Recipients's Address */
    function sell(address recipient, uint256 tokenAmount)
        external
        nonReentrant
    {
        _sell(tokenAmount, recipient);
    }

    /** Sells All CLIMB Tokens And Deposits Underlying Asset Tokens into Seller's Address */
    function sellAll() external nonReentrant {
        _sell(_balances[msg.sender], msg.sender);
    }

    /** Sells Without Including Decimals */
    function sellInWholeTokenAmounts(uint256 amount) external nonReentrant {
        _sell(amount.mul(10**_decimals), msg.sender);
    }

    /** Deletes CLIMB Tokens Sent To Contract */
    function takeOutGarbage() external nonReentrant {
        _checkGarbageCollector();
    }

    /** Allows A User To Erase Their Holdings From Supply */
    function eraseHoldings(uint256 nHoldings) external {
        // get balance of caller
        uint256 bal = _balances[msg.sender];
        require(bal >= nHoldings && bal > 0, "Zero Holdings");
        // if zero erase full balance
        uint256 burnAmount = nHoldings == 0 ? bal : nHoldings;
        // Track Change In Price
        uint256 oldPrice = _calculatePrice();
        // burn tokens from sender + supply
        _burn(msg.sender, burnAmount);
        // Emit Price Difference
        emit PriceChange(oldPrice, _calculatePrice(), _totalSupply);
        // Emit Call
        emit ErasedHoldings(msg.sender, burnAmount);
    }

    ///////////////////////////////////
    //////  EXTERNAL FUNCTIONS  ///////
    ///////////////////////////////////

    /** Burns CLIMB Token with BNB */
    function burn() external payable {
        uint256 prevAmount = _balances[address(this)];
        _purchase(address(this));
        uint256 amount = _balances[address(this)].sub(prevAmount);
        _burn(address(this), amount);
    }

    /** Burns CLIMB Token from msg.sender */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /** Burns CLIMB Token with Underlying, Must Have Prior Approval */
    function burnWithUnderlying(uint256 underlyingAmount) external {
        IERC20(_underlying).transferFrom(
            msg.sender,
            address(this),
            underlyingAmount
        );
        uint256 prevAmount = _balances[address(this)];
        _stakeUnderlyingAsset(underlyingAmount, address(this));
        uint256 amount = _balances[address(this)].sub(prevAmount);
        _burn(address(this), amount);
    }

    ///////////////////////////////////
    //////  INTERNAL FUNCTIONS  ///////
    ///////////////////////////////////

    /** Requires Price of CLIMB Token to Rise for The Transaction to Conclude */
    function _requirePriceRises(uint256 oldPrice) internal {
        // price after transaction
        uint256 newPrice = _calculatePrice();
        // require price to rise
        require(
            newPrice >= oldPrice,
            "Price Must Rise For Transaction To Conclude"
        );
        emit PriceChange(oldPrice, newPrice, _totalSupply);
    }

    /** Purchases CLIMB Token and Deposits Them in Recipient's Address */
    function _purchase(address recipient) private nonReentrant returns (bool) {
        // make sure emergency mode is disabled
        require(Token_Activated || _owner == msg.sender, "Token Not Activated");
        // calculate price change
        uint256 oldPrice = _calculatePrice();
        // previous amount of underlying asset before we received any
        uint256 prevTokenAmount = IERC20(_underlying).balanceOf(address(this));
        // minimum output amount
        uint256 minOut = _router
        .getAmountsOut(msg.value, path)[1].mul(_tokenSlippage).div(1000);
        // buy Token with the BNB received
        _router.swapExactETHForTokens{value: msg.value}(
            minOut,
            path,
            address(this),
            block.timestamp.add(30)
        );
        // balance of underlying asset after swap
        uint256 currentTokenAmount = IERC20(_underlying).balanceOf(
            address(this)
        );
        // number of Tokens we have purchased
        uint256 difference = currentTokenAmount.sub(prevTokenAmount);
        // if this is the first purchase, use new amount
        prevTokenAmount = prevTokenAmount == 0
            ? currentTokenAmount
            : prevTokenAmount;
        // differentiate purchase
        emit TokenPurchased(difference, recipient);
        // mint to recipient
        return _handleMinting(recipient, difference, prevTokenAmount, oldPrice);
    }

    /** Stake Underlying Tokens and Deposits CLIMB in Sender's Address, Must Have Prior Approval */
    function _stakeUnderlyingAsset(uint256 numTokens, address recipient)
        internal
        returns (bool)
    {
        // make sure emergency mode is disabled
        require(
            Token_Activated ||
                msg.sender == _owner ||
                !isLocked ||
                isMatrix[msg.sender],
            "CLIMB is Currently Locked Inside the Matrix"
        );
        // user's underlying balance
        uint256 userTokenBalance = IERC20(_underlying).balanceOf(msg.sender);
        // ensure user has enough to send
        require(
            userTokenBalance > 0 && numTokens <= userTokenBalance,
            "Insufficient Balance"
        );
        // calculate price change
        uint256 oldPrice = _calculatePrice();
        // previous amount of underlying asset before any are received
        uint256 prevTokenAmount = IERC20(_underlying).balanceOf(address(this));
        // move asset into this contract
        bool success = IERC20(_underlying).transferFrom(
            msg.sender,
            address(this),
            numTokens
        );
        // balance of underlying asset after transfer
        uint256 currentTokenAmount = IERC20(_underlying).balanceOf(
            address(this)
        );
        // number of Tokens we have purchased
        uint256 difference = currentTokenAmount.sub(prevTokenAmount);
        // ensure nothing unexpected happened
        require(
            difference <= numTokens && difference > 0,
            "Failure on Token Evaluation"
        );
        // ensure a successful transfer
        require(success, "Failure On Token TransferFrom");
        // if this is the first purchase, use new amount
        prevTokenAmount = prevTokenAmount == 0
            ? currentTokenAmount
            : prevTokenAmount;
        // Emit Staked
        emit TokenStaked(difference, recipient);
        // Handle Minting
        return _handleMinting(recipient, difference, prevTokenAmount, oldPrice);
    }

    /** Sells CLIMB Tokens And Deposits Underlying Asset Tokens into Recipients's Address */
    function _sell(uint256 tokenAmount, address recipient) internal {
        require(tokenAmount > 0 && _balances[msg.sender] >= tokenAmount);
        // calculate price change
        uint256 oldPrice = _calculatePrice();
        // fee exempt
        bool takeFee = !isFeeExempt[msg.sender];

        // tokens post fee to swap for underlying asset
        uint256 tokensToSwap = takeFee
            ? tokenAmount.mul(sellFee).div(feeDenominator)
            : tokenAmount.sub(100, "100 Asset Minimum For Fee Exemption");

        // value of taxed tokens
        uint256 amountUnderlyingAsset = (tokensToSwap.mul(oldPrice)).div(
            precision
        );
        // require above zero value
        require(
            amountUnderlyingAsset > 0,
            "Zero Assets To Redeem For Given Value"
        );

        // burn from sender + supply
        _burn(msg.sender, tokenAmount);

        if (takeFee) {
            // difference
            uint256 taxTaken = tokenAmount.sub(tokensToSwap);
            // allocate dev share
            uint256 allocation = taxTaken.mul(devShare).div(
                devShare.add(liquidityShare)
            );
            // mint to dev
            _mint(dev, allocation);
        }

        // send Tokens to Seller
        bool successful = IERC20(_underlying).transfer(
            recipient,
            amountUnderlyingAsset
        );
        // ensure Tokens were delivered
        require(successful, "Underlying Asset Transfer Failure");
        // Requires The Price of CLIMB to Increase in order to complete the transaction
        _requirePriceRises(oldPrice);
        // Differentiate Sell
        emit TokenSold(tokenAmount, amountUnderlyingAsset, recipient);
    }

    /** Handles Minting Logic To Create New Tokens*/
    function _handleMinting(
        address recipient,
        uint256 received,
        uint256 prevTokenAmount,
        uint256 oldPrice
    ) private returns (bool) {
        // fee exempt
        bool takeFee = !isFeeExempt[msg.sender];

        // find the number of tokens we should mint to keep up with the current price
        uint256 tokensToMintNoTax = _totalSupply.mul(received).div(
            prevTokenAmount
        );

        // apply fee to minted tokens to inflate price relative to total supply
        uint256 tokensToMint = takeFee
            ? tokensToMintNoTax.mul(mintFee).div(feeDenominator)
            : tokensToMintNoTax.sub(100, "100 Asset Minimum For Fee Exemption");

        // revert if under 1
        require(tokensToMint > 0, "Must Purchase At Least One Climb Token");

        if (takeFee) {
            // difference
            uint256 taxTaken = tokensToMintNoTax.sub(tokensToMint);
            // allocate dev share
            uint256 allocation = taxTaken.mul(devShare).div(
                devShare.add(liquidityShare)
            );
            // mint to dev
            _mint(dev, allocation);
        }

        // mint to Buyer
        _mint(recipient, tokensToMint);
        // Requires The Price of CLIMB to Increase in order to complete the transaction
        _requirePriceRises(oldPrice);
        return true;
    }

    /** Mints Tokens to the Receivers Address */
    function _mint(address receiver, uint256 amount) private {
        _balances[receiver] = _balances[receiver].add(amount);
        _totalSupply = _totalSupply.add(amount);
        _volumeFor[receiver] += amount;
        emit Transfer(address(0), receiver, amount);
    }

    /** Burns Tokens from the Receivers Address */
    function _burn(address receiver, uint256 amount) private {
        _balances[receiver] = _balances[receiver].sub(
            amount,
            "Insufficient Balance"
        );
        _totalSupply = _totalSupply.sub(amount, "Negative Supply");
        _volumeFor[receiver] += amount;
        emit Transfer(receiver, address(0), amount);
    }

    /** Make Sure there's no Native Tokens in contract */
    function _checkGarbageCollector() internal {
        uint256 bal = _balances[address(this)];
        if (bal > 10) {
            // Track Change In Price
            uint256 oldPrice = _calculatePrice();
            // burn amount
            _burn(address(this), bal);
            // Emit Collection
            emit GarbageCollected(bal);
            // Emit Price Difference
            emit PriceChange(oldPrice, _calculatePrice(), _totalSupply);
        }
    }

    ///////////////////////////////////
    //////    READ FUNCTIONS    ///////
    ///////////////////////////////////

    /** Returns the Owner of the Contract */
    function owner() external view returns (address) {
        return _owner;
    }

    /** Price Of CLIMB in BUSD With 18 Points Of Precision */
    function calculatePrice() external view returns (uint256) {
        return _calculatePrice();
    }

    /** Precision Of $0.001 */
    function price() external view returns (uint256) {
        return _calculatePrice().mul(10**3).div(precision);
    }

    /** Returns the Current Price of 1 Token */
    function _calculatePrice() internal view returns (uint256) {
        uint256 tokenBalance = IERC20(_underlying).balanceOf(address(this));
        return (tokenBalance.mul(precision)).div(_totalSupply);
    }

    /** Returns the value of your holdings before the sell fee */
    function getValueOfHoldings(address holder) public view returns (uint256) {
        return _balances[holder].mul(_calculatePrice()).div(precision);
    }

    /** Returns the value of your holdings after the sell fee */
    function getValueOfHoldingsAfterTax(address holder)
        external
        view
        returns (uint256)
    {
        return getValueOfHoldings(holder).mul(sellFee).div(feeDenominator);
    }

    /** Returns The Address of the Underlying Asset */
    function getUnderlyingAsset() external pure returns (address) {
        return _underlying;
    }

    /** Volume in CLIMB For A Particular Wallet */
    function volumeFor(address wallet) external view returns (uint256) {
        return _volumeFor[wallet];
    }

    ///////////////////////////////////
    //////   OWNER FUNCTIONS    ///////
    ///////////////////////////////////

    /** Enables Trading For This Token, This Action Cannot be Undone */
    function ActivateToken() external onlyOwner {
        require(!Token_Activated, "Already Activated Token");
        Token_Activated = true;
        emit TokenActivated(_totalSupply, _calculatePrice(), block.timestamp);
    }

    /** Excludes Contract From Fees */
    function setFeeExemption(address Contract, bool exempt) external onlyOwner {
        require(Contract != address(0));
        isFeeExempt[Contract] = exempt;
        emit SetFeeExemption(Contract, exempt);
    }

    /** Set Matrix Contract */
    function setMatrixContract(address newMatrix, bool exempt)
        external
        onlyOwner
    {
        require(newMatrix != address(0));
        isMatrix[newMatrix] = exempt;
        emit SetMatrixContract(newMatrix, exempt);
    }

    /** Updates The Threshold To Trigger The Garbage Collector */
    function changeTokenSlippage(uint256 newSlippage) external onlyOwner {
        require(newSlippage <= 995, "invalid slippage");
        _tokenSlippage = newSlippage;
        emit UpdateTokenSlippage(newSlippage);
    }

    /** Updates The devShare and liquidityShare */
    function updateShares(uint256 newDevShare, uint256 newLiquidityShare)
        external
        onlyOwner
    {
        require(newDevShare.add(newLiquidityShare) <= 995, "invalid shares");
        devShare = newDevShare;
        liquidityShare = newLiquidityShare;
        emit UpdateShares(devShare, liquidityShare);
    }

    /** Updates The dev Address */
    function updateDevAddress(address newDev) external onlyOwner {
        require(newDev != address(0));
        dev = newDev;
        emit UpdateDevAddress(newDev);
    }

    /** Updates The Sell, Mint, and Transfer Fees */
    function updateFees(
        uint256 newSellFee,
        uint256 newMintFee,
        uint256 newTransferFee
    ) external onlyOwner {
        require(
            newSellFee <= 995 && newMintFee <= 995 && newTransferFee <= 995,
            "invalid fees"
        );
        sellFee = newSellFee;
        mintFee = newMintFee;
        transferFee = newTransferFee;
        emit UpdateFees(sellFee, mintFee, transferFee);
    }

    /** Unlocks The Contract For Outside of The Matrix */
    function unlockContract() external onlyOwner {
        require(!isLocked, "Contract Already Unlocked");
        isLocked = false;
        emit ContractUnlocked(_calculatePrice(), block.timestamp);
    }

    /** Transfers Ownership To Another User */
    function transferOwnership(address newOwner) external onlyOwner {
        _owner = newOwner;
        emit TransferOwnership(newOwner);
    }

    /** Transfers Ownership To Zero Address */
    function renounceOwnership() external onlyOwner {
        _owner = address(0);
        emit TransferOwnership(address(0));
    }

    /** Mint Tokens to Buyer */
    receive() external payable {
        _checkGarbageCollector();
        _purchase(msg.sender);
    }

    ///////////////////////////////////
    //////        EVENTS        ///////
    ///////////////////////////////////

    event UpdateShares(uint256 updatedDevShare, uint256 updatedLiquidityShare);
    event UpdateFees(
        uint256 updatedSellFee,
        uint256 updatedMintFee,
        uint256 updatedTransferFee
    );
    event UpdateDevAddress(address updatedDev);
    event SetMatrixContract(address newMatrix, bool exempt);
    event ContractUnlocked(uint256 currentPrice, uint256 timestamp);
    event PriceChange(
        uint256 previousPrice,
        uint256 currentPrice,
        uint256 totalSupply
    );
    event ErasedHoldings(address who, uint256 amountTokensErased);
    event GarbageCollected(uint256 amountTokensErased);
    event UpdateTokenSlippage(uint256 newSlippage);
    event TransferOwnership(address newOwner);
    event TokenStaked(uint256 assetsReceived, address recipient);
    event SetFeeExemption(address Contract, bool exempt);
    event TokenActivated(uint256 totalSupply, uint256 price, uint256 timestamp);
    event TokenSold(
        uint256 amountCLIMB,
        uint256 assetsRedeemed,
        address recipient
    );
    event TokenPurchased(uint256 assetsReceived, address recipient);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IClimb is IERC20 {
    function burn(uint256 amount) external;

    function burn() external payable;

    function sell(uint256 amount) external;

    function sell(uint256 amount, address recipient) external;

    function getUnderlyingAsset() external returns (address);

    function buy(uint256 numTokens) external returns (bool);

    function buy(address recipient, uint256 numTokens) external returns (bool);

    function eraseHoldings(uint256 nHoldings) external;

    function transferOwnership(address newOwner) external;

    function volumeFor(address wallet) external view returns (uint256);

    function owner() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./SafeMath.sol";
import "./Address.sol";
import "./ReentrantGuard.sol";
import "./IxKT.sol";
import "./IUniswapV2Router02.sol";

/**
 * 
 * 
 *
 * Token with a built in Automated Market Maker
 * Send BNB to contract and it will mint xUSD Tokens
 * Stake BUSD into contract and it will mint xUSD Tokens
 * Sell this token to redeem underlying BUSD Tokens
 * Price is calculated as a ratio between Total Supply and underlying asset quantity in Contract
 */
contract xKT is ReentrancyGuard, IxKT {
    
    using SafeMath for uint256;
    using Address for address;

    // token data
    string constant _name = "Kryptonite";
    string constant _symbol = "xKT";
    uint8 constant _decimals = 18;
    uint256 constant precision = 10**18;
    
    // 10 xUSD Starting Supply
    uint256 _totalSupply = 10 * 10**_decimals;
    
    // balances
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    // Fees
    uint256 public constant mintFee        = 99250;   // 0.75% buy fee
    uint256 public constant sellFee        = 99750;   // 0.25% sell fee 
    uint256 public constant transferFee    = 99750;   // 0.25% transfer fee
    uint256 public constant feeDenominator = 10**5;
    
    // Underlying Asset
    address public constant _token = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    
    // fee exemption for staking / utility
    mapping ( address => bool ) public isFeeExempt;
    
    // volume for each recipient
    mapping ( address => uint256 ) _volumeFor;
    
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
    
    // fund data 
    bool allowFunding;
    address _fund;
    uint256 _fundingFeeDenominator;

    modifier onlyOwner() {
        require(msg.sender == _owner, 'Only Owner Function');
        _;
    }

    // initialize some stuff
    constructor () {
        
        // router
        _router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        path = new address[](2);
        path[0] = _router.WETH();
        path[1] = _token;
        
        // Fund
        _fund = 0x849827eFB61f67F7aCF25Ee92cf9a8BE1F6F0869;
        _fundingFeeDenominator = 5;
        
        // fee exempt fund + owner + router for LP injection
        isFeeExempt[msg.sender] = true;
        isFeeExempt[0x10ED43C718714eb63d5aA57B78B54704E256024E] = true;
        isFeeExempt[_fund] = true;
        
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

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    
    function name() public pure override returns (string memory) {
        return _name;
    }

    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
  
    /** Transfer Function */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    /** Transfer Function */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, 'Insufficient Allowance');
        return _transferFrom(sender, recipient, amount);
    }
    
    /** Internal Transfer */
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        // make standard checks
        require(recipient != address(0) && sender != address(0), "Transfer To Zero Address");
        require(amount > 0, "Transfer amount must be greater than zero");
        // track price change
        uint256 oldPrice = _calculatePrice();
        
        // fee exempt
        bool takeFee = !( isFeeExempt[sender] || isFeeExempt[recipient] );
        
        // amount to give recipient
        uint256 tAmount = takeFee ? amount.mul(transferFee).div(feeDenominator) : amount;
        
        // tax taken from transfer
        uint256 tax = amount.sub(tAmount);
        
        // subtract from sender
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (allowFunding && sender != _fund && recipient != _fund && takeFee) {
            
            // allocate percentage to Funding
            uint256 allocation = tax.div(_fundingFeeDenominator);
            
            if (allocation > 0) {
                _mint(_fund, allocation);
            }
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
        require(currentPrice >= oldPrice, 'Price Must Rise For Transaction To Conclude');
        // Transfer Event
        emit Transfer(sender, recipient, tAmount);
        // Emit The Price Change
        emit PriceChange(oldPrice, currentPrice, _totalSupply);
        return true;
    }
    
    /** Stake Tokens and Deposits xUSD in Sender's Address, Must Have Prior Approval */
    function stakeUnderlyingAsset(uint256 numTokens) external override nonReentrant returns (bool) {
        return _stakeUnderlyingAsset(numTokens, msg.sender);
    }
    
    /** Stake Underlying Asset Tokens and Deposits xUSD in Recipient's Address, Must Have Prior Approval */
    function stakeUnderlyingAsset(address recipient, uint256 numTokens) external override nonReentrant returns (bool) {
        return _stakeUnderlyingAsset(numTokens, recipient);
    }
    
    /** Sells xUSD Tokens And Deposits Underlying Asset Tokens into Seller's Address */
    function sell(uint256 tokenAmount) external override nonReentrant {
        _sell(tokenAmount, msg.sender);
    }
    
    /** Sells xUSD Tokens And Deposits Underlying Asset Tokens into Recipients's Address */
    function sell(address recipient, uint256 tokenAmount) external nonReentrant {
        _sell(tokenAmount, recipient);
    }
    
    /** Sells All xUSD Tokens And Deposits Underlying Asset Tokens into Seller's Address */
    function sellAll() external nonReentrant {
        _sell(_balances[msg.sender], msg.sender);
    }
    
    /** Sells Without Including Decimals */
    function sellInWholeTokenAmounts(uint256 amount) external nonReentrant {
        _sell(amount.mul(10**_decimals), msg.sender);
    }
    
    /** Deletes xUSD Tokens Sent To Contract */
    function takeOutGarbage() external nonReentrant {
        _checkGarbageCollector();
    }
    
    /** Allows A User To Erase Their Holdings From Supply */
    function eraseHoldings(uint256 nHoldings) external override {
        // get balance of caller
        uint256 bal = _balances[msg.sender];
        require(bal >= nHoldings && bal > 0, 'Zero Holdings');
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
    //////  INTERNAL FUNCTIONS  ///////
    ///////////////////////////////////
    
    /** Purchases xUSD Token and Deposits Them in Recipient's Address */
    function _purchase(address recipient) private nonReentrant returns (bool) {
        // make sure emergency mode is disabled
        require(Token_Activated || _owner == msg.sender, 'Token Not Activated');
        // calculate price change
        uint256 oldPrice = _calculatePrice();
        // previous amount of Tokens before we received any
        uint256 prevTokenAmount = IERC20(_token).balanceOf(address(this));
        // minimum output amount
        uint256 minOut = _router.getAmountsOut(msg.value, path)[1].mul(_tokenSlippage).div(1000);
        // buy Token with the BNB received
        _router.swapExactETHForTokens{value: msg.value}(
            minOut,
            path,
            address(this),
            block.timestamp.add(30)
        );
        // balance of tokens after swap
        uint256 currentTokenAmount = IERC20(_token).balanceOf(address(this));
        // number of Tokens we have purchased
        uint256 difference = currentTokenAmount.sub(prevTokenAmount);
        // if this is the first purchase, use new amount
        prevTokenAmount = prevTokenAmount == 0 ? currentTokenAmount : prevTokenAmount;
        // differentiate purchase
        emit TokenPurchased(difference, recipient);
        // mint to recipient
        return _handleMinting(recipient, difference, prevTokenAmount, oldPrice);
    }
    
    /** Stake Tokens and Deposits xUSD in Sender's Address, Must Have Prior Approval */
    function _stakeUnderlyingAsset(uint256 numTokens, address recipient) internal returns (bool) {
        // make sure emergency mode is disabled
        require(Token_Activated || _owner == msg.sender, 'Token Not Activated');
        // users token balance
        uint256 userTokenBalance = IERC20(_token).balanceOf(msg.sender);
        // ensure user has enough to send
        require(userTokenBalance > 0 && numTokens <= userTokenBalance, 'Insufficient Balance');
        // calculate price change
        uint256 oldPrice = _calculatePrice();
        // previous amount of Tokens before any are received
        uint256 prevTokenAmount = IERC20(_token).balanceOf(address(this));
        // move asset into xUSD Token
        bool success = IERC20(_token).transferFrom(msg.sender, address(this), numTokens);
        // balance of tokens after transfer
        uint256 currentTokenAmount = IERC20(_token).balanceOf(address(this));
        // number of Tokens we have purchased
        uint256 difference = currentTokenAmount.sub(prevTokenAmount);
        // ensure nothing unexpected happened
        require(difference <= numTokens && difference > 0, 'Failure on Token Evaluation');
        // ensure a successful transfer
        require(success, 'Failure On Token TransferFrom');
        // if this is the first purchase, use new amount
        prevTokenAmount = prevTokenAmount == 0 ? currentTokenAmount : prevTokenAmount;
        // Emit Staked
        emit TokenStaked(difference, recipient);
        // Handle Minting
        return _handleMinting(recipient, difference, prevTokenAmount, oldPrice);
    }
    
    /** Sells xUSD Tokens And Deposits Underlying Asset Tokens into Recipients's Address */
    function _sell(uint256 tokenAmount, address recipient) internal {
        require(tokenAmount > 0 && _balances[msg.sender] >= tokenAmount);
        // calculate price change
        uint256 oldPrice = _calculatePrice();
        // fee exempt
        bool takeFee = !isFeeExempt[msg.sender];
        
        // tokens post fee to swap for underlying asset
        uint256 tokensToSwap = takeFee ? tokenAmount.mul(sellFee).div(feeDenominator) : tokenAmount.sub(100, '100 Asset Minimum For Fee Exemption');

        // value of taxed tokens
        uint256 amountUnderlyingAsset = (tokensToSwap.mul(oldPrice)).div(precision);
        // require above zero value
        require(amountUnderlyingAsset > 0, 'Zero Assets To Redeem For Given Value');
        
        // burn from sender + supply 
        _burn(msg.sender, tokenAmount);
        
        uint256 allocation = 0;
        if (allowFunding && msg.sender != _fund && takeFee) {
            // tax taken
            uint256 taxTaken = tokenAmount.sub(tokensToSwap);
            // allocate percentage to Fund
            allocation = taxTaken.div(_fundingFeeDenominator);
            if (allocation > 0) {
                // mint to Fund
                _mint(_fund, allocation);
            }
        }

        // send Tokens to Seller
        bool successful = IERC20(_token).transfer(recipient, amountUnderlyingAsset);
        // ensure Tokens were delivered
        require(successful, 'Underlying Asset Transfer Failure');
        // get current price
        uint256 newPrice = _calculatePrice();
        // Require Current Price >= Last Price
        require(newPrice >= oldPrice, 'Price Must Rise For Transaction To Conclude');
        // Differentiate Sell
        emit TokenSold(tokenAmount, amountUnderlyingAsset, recipient);
        // Emit The Price Change
        emit PriceChange(oldPrice, newPrice, _totalSupply);
    }
    
    /** Handles Minting Logic To Create New Surge Tokens*/
    function _handleMinting(address recipient, uint256 received, uint256 prevTokenAmount, uint256 oldPrice) private returns(bool) {

        // fee exempt
        bool takeFee = !isFeeExempt[msg.sender];
        
        // find the number of tokens we should mint to keep up with the current price
        uint256 tokensToMintNoTax = _totalSupply.mul(received).div(prevTokenAmount);
        
        // apply fee to minted tokens to inflate price relative to total supply
        uint256 tokensToMint = takeFee ? tokensToMintNoTax.mul(mintFee).div(feeDenominator) : tokensToMintNoTax.sub(100, '100 Asset Minimum For Fee Exemption');

        // revert if under 1
        require(tokensToMint > 0, 'Must Purchase At Least One xUSD');
        
        if (allowFunding && takeFee) {
            // difference
            uint256 taxTaken = tokensToMintNoTax.sub(tokensToMint);
            // allocate tokens to go to the Fund
            uint256 allocation = taxTaken.div(_fundingFeeDenominator);
            // allocate if greater than zero
            if (allocation > 0) {
                // mint to Fund
                _mint(_fund, allocation);
            }
        }
        
        // mint to Buyer
        _mint(recipient, tokensToMint);
        // Calculate Price After Transaction
        uint256 newPrice = _calculatePrice();
        // Require Current Price >= Last Price
        require(newPrice >= oldPrice, 'Price Must Rise For Transaction To Conclude');
        // Emit The Price Change
        emit PriceChange(oldPrice, newPrice, _totalSupply);
        return true;
    }
    
    /** Mints Tokens to the Receivers Address */
    function _mint(address receiver, uint amount) private {
        _balances[receiver] = _balances[receiver].add(amount);
        _totalSupply = _totalSupply.add(amount);
        _volumeFor[receiver] += amount;
        emit Transfer(address(0), receiver, amount);
    }
    
    /** Mints Tokens to the Receivers Address */
    function _burn(address receiver, uint amount) private {
        _balances[receiver] = _balances[receiver].sub(amount, 'Insufficient Balance');
        _totalSupply = _totalSupply.sub(amount, 'Negative Supply');
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
    
    
    /** Price Of XUSD in BUSD With 18 Points Of Precision */
    function calculatePrice() external view returns (uint256) {
        return _calculatePrice();
    }
    
    /** Precision Of $0.001 */
    function price() external view returns (uint256) {
        return _calculatePrice().mul(10**3).div(precision);
    }
    
    /** Returns the Current Price of 1 Token */
    function _calculatePrice() internal view returns (uint256) {
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        return (tokenBalance.mul(precision)).div(_totalSupply);
    }

    /** Returns the value of your holdings before the sell fee */
    function getValueOfHoldings(address holder) public view returns(uint256) {
        return _balances[holder].mul(_calculatePrice()).div(precision);
    }

    /** Returns the value of your holdings after the sell fee */
    function getValueOfHoldingsAfterTax(address holder) external view returns(uint256) {
        return getValueOfHoldings(holder).mul(sellFee).div(feeDenominator);
    }

    /** Returns The Address of the Underlying Asset */
    function getUnderlyingAsset() external override pure returns(address) {
        return _token;
    }
    
    /** Volume in xUSD For A Particular Wallet */
    function volumeFor(address wallet) external override view returns (uint256) {
        return _volumeFor[wallet];
    }
    
    ///////////////////////////////////
    //////   OWNER FUNCTIONS    ///////
    ///////////////////////////////////
    
    
    /** Enables Trading For This Token, This Action Cannot be Undone */
    function ActivateToken() external onlyOwner {
        require(!Token_Activated, 'Already Activated Token');
        Token_Activated = true;
        allowFunding = true;
        emit TokenActivated();
    }
    
    /** Updates The Buy/Sell/Stake and Transfer Fee Allocated Toward Funding */
    function updateFundingValues(bool _allowFunding, uint256 _denominator) external onlyOwner {
        require(_denominator >= 2, 'Fees Too High');
        allowFunding = _allowFunding;
        _fundingFeeDenominator = _denominator;
        emit UpdatedFundingValues(_allowFunding, _denominator);
    }
    
    /** Updates The Address Of The Fund Receiver */
    function updateFundAddress(address newFund) external onlyOwner {
        _fund = newFund;
        emit UpdatedFundAddress(newFund);
    }
    
    /** Excludes Contract From Fees */
    function setFeeExemption(address Contract, bool exempt) external onlyOwner {
        require(Contract != address(0));
        isFeeExempt[Contract] = exempt;
        emit SetFeeExemption(Contract, exempt);
    }
    
    /** Updates The Threshold To Trigger The Garbage Collector */
    function changeTokenSlippage(uint256 newSlippage) external onlyOwner {
        require(newSlippage <= 995, 'invalid slippage');
        _tokenSlippage = newSlippage;
        emit UpdateTokenSlippage(newSlippage);
    }
    
    /** Transfers Ownership To Another User */
    function transferOwnership(address newOwner) external override onlyOwner {
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
    
    event UpdatedFundingValues(bool allowFunding, uint256 denominator);
    event PriceChange(uint256 previousPrice, uint256 currentPrice, uint256 totalSupply);
    event ErasedHoldings(address who, uint256 amountTokensErased);
    event UpdatedFundAddress(address newFund);
    event GarbageCollected(uint256 amountTokensErased);
    event UpdateTokenSlippage(uint256 newSlippage);
    event UpdatedAllowFunding(bool _allowFunding);
    event TransferOwnership(address newOwner);
    event TokenStaked(uint256 assetsReceived, address recipient);
    event SetFeeExemption(address Contract, bool exempt);
    event TokenActivated();
    event TokenSold(uint256 amountxUSD, uint256 assetsRedeemed, address recipient);
    event TokenPurchased(uint256 assetsReceived, address recipient);
    
}
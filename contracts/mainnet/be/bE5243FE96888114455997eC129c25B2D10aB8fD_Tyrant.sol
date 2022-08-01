//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./ReentrantGuard.sol";

interface XUSDRoyalty {
    function getFeeRecipient() external view returns (address);
}

interface IXUSD {
    function sell(uint256 tokenAmount, address desiredToken, address recipient) external returns (address, uint256);
    function getUnderlyingAssets() external view returns(address[] memory);
}

/**
 *  Contract: Tyrant Powered by XUSD
 *  Appreciating Stable Coin Inheriting The IP Of XUSD by xSurge
 *  Visit xsurgecrypto.net to learn more about appreciating stable coins
 */
contract Tyrant is IERC20, Ownable, ReentrancyGuard {
    
    using SafeMath for uint256;

    // token data
    string private constant _name = "Tyrant";
    string private constant _symbol = "TYRANT";
    uint8 private constant _decimals = 18;
    uint256 private constant precision = 10**18;
    
    // 1 initial supply
    uint256 private _totalSupply = 10**18; 
    
    // balances
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    // address -> Fee Exemption
    mapping ( address => bool ) public isTransferFeeExempt;

    // Token Activation
    bool public tokenActivated;

    // Dead Wallet
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    // Royalty Data Fetcher
    XUSDRoyalty private constant royaltyTracker = XUSDRoyalty(0x9127c5847C78926CEB3bF916Ef0868CE3bDc154F);

    // Fees
    uint256 public mintFee        = 95000;           // 5% mint fee
    uint256 public sellFee        = 97000;           // 3% redeem fee 
    uint256 public transferFee    = 98000;           // 2% transfer fee
    uint256 private constant feeDenominator = 100000;

    // Fee Distribution
    uint256 public constant royaltyFee   = 100;
    uint256 public TyrantFee             = 500;
    uint256 private constant FEE_DENOM   = 1000;
    
    // Underlying Asset Is XUSD
    IERC20 public constant underlying = IERC20(0x324E8E649A6A3dF817F97CdDBED2b746b62553dD);

    // Tyrant Fee Recipient Contract
    address public tyrantReceiver;

    // initialize
    constructor() {
        isTransferFeeExempt[msg.sender] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /** Returns the total number of tokens in existence */
    function totalSupply() external view override returns (uint256) { 
        return _totalSupply; 
    }

    /** Returns the number of tokens owned by `account` */
    function balanceOf(address account) public view override returns (uint256) { 
        return _balances[account]; 
    }

    /** Returns the number of tokens `spender` can transfer from `holder` */
    function allowance(address holder, address spender) external view override returns (uint256) { 
        return _allowances[holder][spender]; 
    }
    
    /** Token Name */
    function name() public pure override returns (string memory) {
        return _name;
    }

    /** Token Ticker Symbol */
    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    /** Tokens decimals */
    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    /** Approves `spender` to transfer `amount` tokens from caller */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
  
    /** Transfer Function */
    function transfer(address recipient, uint256 amount) external override nonReentrant returns (bool) {
        if (recipient == msg.sender) {
            _sell(msg.sender, amount, msg.sender, address(0));
            return true;
        } else {
            return _transferFrom(msg.sender, recipient, amount);
        }
    }

    /** Transfer Function */
    function transferFrom(address sender, address recipient, uint256 amount) external override nonReentrant returns (bool) {
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, 'Insufficient Allowance');
        return _transferFrom(sender, recipient, amount);
    }
    
    /** Internal Transfer */
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        // make standard checks
        require(recipient != address(0) && sender != address(0), "Transfer To Zero");
        require(amount > 0, "Transfer Amt Zero");
        // track price change
        uint256 oldPrice = _calculatePrice();
        // amount to give recipient
        uint256 tAmount = (isTransferFeeExempt[sender] || isTransferFeeExempt[recipient]) ? amount : amount.mul(transferFee).div(feeDenominator);
        // tax taken from transfer
        uint256 tax = amount.sub(tAmount);
        // subtract from sender
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        // give reduced amount to receiver
        _balances[recipient] = _balances[recipient].add(tAmount);

        // burn the tax
        if (tax > 0) {
            // Take Fee
            _takeFee(tax);
            // Reduce Supply
            _totalSupply = _totalSupply.sub(tax);
            emit Transfer(sender, address(0), tax);
        }
        
        // require price rises
        _requirePriceRises(oldPrice);
        // Transfer Event
        emit Transfer(sender, recipient, tAmount);
        return true;
    }

    /**
        Mint Tyrant Tokens With The Native Token ( Smart Chain BNB )
        This will purchase BUSD with BNB received
        It will then mint tokens to `recipient` based on the number of stable coins received
        `minOut` should be set to avoid the Transaction being front runned

        @param recipient Account to receive minted Tyrant Tokens
        @param minOut minimum amount out from BNB -> BUSD - prevents front run attacks
        @return received number of Tyrant tokens received
     */
    function mintWithNative(address recipient, uint256 minOut) external payable returns (uint256) {
        _checkGarbageCollector(address(this));
        _checkGarbageCollector(DEAD);
        return _mintWithNative(recipient, minOut);
    }


    /** 
        Mint Tyrant Tokens For `recipient` By Depositing BUSD Into The Contract
            Requirements:
                Approval from the BUSD prior to purchase
        
        @param numTokens number of BUSD tokens to mint Tyrant with
        @param recipient Account to receive minted Tyrant tokens
        @return tokensMinted number of Tyrant tokens minted
    */
    function mintWithBacking(uint256 numTokens, address recipient) external nonReentrant returns (uint256) {
        _checkGarbageCollector(address(this));
        _checkGarbageCollector(DEAD);
        return _mintWithBacking(numTokens, recipient);
    }

    /** 
        Burns Sender's Tyrant Tokens and redeems their value in BUSD
        @param tokenAmount Number of Tyrant Tokens To Redeem, Must be greater than 0
    */
    function sell(uint256 tokenAmount) external nonReentrant returns (address, uint256) {
        return _sell(msg.sender, tokenAmount, msg.sender, address(0));
    }
    
    /** 
        Burns Sender's Tyrant Tokens and redeems their value in BUSD for `recipient`
        @param tokenAmount Number of Tyrant Tokens To Redeem, Must be greater than 0
        @param recipient Recipient Of BUSD transfer, Must not be address(0)
    */
    function sell(uint256 tokenAmount, address recipient, address tokenToReceive) external nonReentrant returns (address, uint256) {
        return _sell(msg.sender, tokenAmount, recipient, tokenToReceive);
    }
    
    /** 
        Allows A User To Erase Their Holdings From Supply 
        DOES NOT REDEEM UNDERLYING ASSET FOR USER
        @param amount Number of Tyrant Tokens To Burn
    */
    function burn(uint256 amount) external nonReentrant {
        // get balance of caller
        uint256 bal = _balances[msg.sender];
        require(bal >= amount && bal > 0, 'Zero Holdings');
        // Track Change In Price
        uint256 oldPrice = _calculatePrice();
        // take fee
        _takeFee(amount);
        // burn tokens from sender + supply
        _burn(msg.sender, amount);
        // require price rises
        _requirePriceRises(oldPrice);
        // Emit Call
        emit Burn(msg.sender, amount);
    }


    ///////////////////////////////////
    //////  INTERNAL FUNCTIONS  ///////
    ///////////////////////////////////
    
    /** Purchases Tyrant Token and Deposits Them in Recipient's Address */
    function _mintWithNative(address recipient, uint256 minOut) internal nonReentrant returns (uint256) {        
        require(msg.value > 0, 'Zero Value');
        require(recipient != address(0), 'Zero Address');
        require(
            tokenActivated || msg.sender == this.getOwner(),
            'Token Not Activated'
        );
        
        // calculate price change
        uint256 oldPrice = _calculatePrice();
        
        // previous backing
        uint256 previousBacking = underlying.balanceOf(address(this));
        
        // swap BNB for stable
        uint256 received = _purchaseXUSD(minOut);

        // if this is the first purchase, use new amount
        uint256 relevantBacking = previousBacking == 0 ? underlying.balanceOf(address(this)) : previousBacking;

        // mint to recipient
        return _mintTo(recipient, received, relevantBacking, oldPrice);
    }
    
    /** Stake Tokens and Deposits Tyrant in Sender's Address, Must Have Prior Approval For BUSD */
    function _mintWithBacking(uint256 numXUSD, address recipient) internal returns (uint256) {
        require(
            tokenActivated || msg.sender == this.getOwner(),
            'Token Not Activated'
        );
        // users token balance
        uint256 userTokenBalance = underlying.balanceOf(msg.sender);
        // ensure user has enough to send
        require(userTokenBalance > 0 && numXUSD <= userTokenBalance, 'Insufficient Balance');

        // calculate price change
        uint256 oldPrice = _calculatePrice();

        // previous backing
        uint256 previousBacking = underlying.balanceOf(address(this));

        // transfer in token
        uint256 received = _transferIn(address(underlying), numXUSD);

        // if this is the first purchase, use new amount
        uint256 relevantBacking = previousBacking == 0 ? underlying.balanceOf(address(this)) : previousBacking;

        // Handle Minting
        return _mintTo(recipient, received, relevantBacking, oldPrice);
    }
    
    /** Burns Tyrant Tokens And Deposits BUSD Tokens into Recipients's Address */
    function _sell(address seller, uint256 tokenAmount, address recipient, address tokenToReceive) internal returns (address, uint256) {
        require(tokenAmount > 0 && _balances[seller] >= tokenAmount);
        require(seller != address(0) && recipient != address(0));
        
        // calculate price change
        uint256 oldPrice = _calculatePrice();
        
        // tokens post fee to swap for underlying asset
        uint256 tokensToSwap = isTransferFeeExempt[seller] ? 
            tokenAmount.sub(10, 'Minimum Exemption') :
            tokenAmount.mul(sellFee).div(feeDenominator);

        // value of taxed tokens
        uint256 amountUnderlyingAsset = amountOut(tokensToSwap);

        // Take Fee
        if (!isTransferFeeExempt[seller]) {
            uint fee = tokenAmount.sub(tokensToSwap);
            _takeFee(fee);
        }

        // burn from sender + supply 
        _burn(seller, tokenAmount);

        // fetch token to sell for
        address tokenToSell = tokenToReceive == address(0) ? tokenToSellFor() : tokenToReceive;

        // send Tokens to Seller
        if (tokenToSell == address(underlying)) {
            underlying.transfer(recipient, amountUnderlyingAsset);
        } else {
            IXUSD(address(underlying)).sell(amountUnderlyingAsset, tokenToSell, recipient);
        }

        // require price rises
        _requirePriceRises(oldPrice);

        // Differentiate Sell
        emit Redeemed(seller, tokenAmount, amountUnderlyingAsset);

        // return token redeemed and amount underlying
        return (tokenToSell, amountUnderlyingAsset);
    }

    /** Handles Minting Logic To Create New Tyrant */
    function _mintTo(address recipient, uint256 received, uint256 totalBacking, uint256 oldPrice) private returns(uint256) {
        
        // find the number of tokens we should mint to keep up with the current price
        uint256 calculatedSupply = _totalSupply == 0 ? 10**18 : _totalSupply;
        uint256 tokensToMintNoTax = calculatedSupply.mul(received).div(totalBacking);
        
        // apply fee to minted tokens to inflate price relative to total supply
        uint256 tokensToMint = isTransferFeeExempt[msg.sender] ? 
                tokensToMintNoTax.sub(10, 'Minimum Exemption') :
                tokensToMintNoTax.mul(mintFee).div(feeDenominator);
        require(tokensToMint > 0, 'Zero Amount');
        
        // mint to Buyer
        _mint(recipient, tokensToMint);

        // apply fee to tax taken
        if (!isTransferFeeExempt[msg.sender]) {
            uint fee = tokensToMintNoTax.sub(tokensToMint);
            _takeFee(fee);
        }

        // require price rises
        _requirePriceRises(oldPrice);

        // differentiate purchase
        emit Minted(recipient, tokensToMint);
        return tokensToMint;
    }

    /** 
        Takes Fee
        @param fee - fee in Tyrant
    */
    function _takeFee(uint256 fee) internal {

        // split up fee
        uint256 forTyrant = ( fee * TyrantFee ) / FEE_DENOM;
        uint256 royalty = ( fee * royaltyFee ) / FEE_DENOM;

        // take royalty fee
        if (royalty > 0) {
            _takeRoyalty(royalty);
        }

        // take Tyrant fee
        if (forTyrant > 0 && tyrantReceiver != address(0)) {
            _mint(tyrantReceiver, forTyrant);
        }
    }

    function _takeRoyalty(uint256 amount) internal {

        // fetch royalty fee recipient
        address feeRecipient = getFeeRecipient();

        // convert Tyrant amount into XUSD amount
        uint xFee = amountOut(amount);

        // transfer XUSD to royalty recipient
        if (xFee > 0 && feeRecipient != address(0)) {
            underlying.transfer(feeRecipient, xFee);
        }
    } 

    /** Swaps BNB for XUSD */
    function _purchaseXUSD(uint256 minOut) internal returns (uint256) {

        // previous amount of Tokens before we received any
        uint256 prevTokenAmount = underlying.balanceOf(address(this));

        // swap BNB For stable of choice
        (bool s,) = payable(address(underlying)).call{value: address(this).balance}("");
        require(s);

        // amount after swap
        uint256 currentTokenAmount = underlying.balanceOf(address(this));
        require(currentTokenAmount > prevTokenAmount);
        uint256 received = currentTokenAmount - prevTokenAmount;
        require(
            received >= minOut,
            'Min Out Not Received'
        );
        return received;
    }

    /** Requires The Price Of Tyrant To Rise For The Transaction To Conclude */
    function _requirePriceRises(uint256 oldPrice) internal {
        // Calculate Price After Transaction
        uint256 newPrice = _calculatePrice();
        // Require Current Price >= Last Price
        require(newPrice >= oldPrice, 'Price Cannot Fall');
        // Emit The Price Change
        emit PriceChange(oldPrice, newPrice, _totalSupply);
    }

    /** Transfers `desiredAmount` of `token` in and verifies the transaction success */
    function _transferIn(address token, uint256 desiredAmount) internal returns (uint256) {
        uint256 balBefore = IERC20(token).balanceOf(address(this));
        require(
            IERC20(token).transferFrom(msg.sender, address(this), desiredAmount),
            'Failure Transfer From'
        );
        uint256 balAfter = IERC20(token).balanceOf(address(this));
        require(
            balAfter > balBefore,
            'Zero Received'
        );
        return balAfter - balBefore;
    }

    /** XUSD Stable With Greatest Supply */
    function tokenToSellFor() public view returns (address) {

        address[] memory underlyings = IXUSD(address(underlying)).getUnderlyingAssets();
        uint MAX = 0;
        address stable = address(0);
        uint len = underlyings.length;
        for (uint i = 0; i < len;) {
            address potential = underlyings[i];
            if (potential != address(0)) {
                uint bal = IERC20(potential).balanceOf(address(underlying));
                if (bal > MAX) {
                    MAX = bal;
                    stable = potential;
                }
            }
            unchecked { ++i; }
        }
        return stable == address(0) ? underlyings[0] : stable;
    }
    
    /** Mints Tokens to the Receivers Address */
    function _mint(address receiver, uint amount) private {
        _balances[receiver] = _balances[receiver].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), receiver, amount);
    }
    
    /** Burns `amount` of tokens from `account` */
    function _burn(address account, uint amount) private {
        _balances[account] = _balances[account].sub(amount, 'Insufficient Balance');
        _totalSupply = _totalSupply.sub(amount, 'Negative Supply');
        emit Transfer(account, address(0), amount);
    }

    /** Make Sure there's no Native Tokens in contract */
    function _checkGarbageCollector(address burnLocation) internal {
        uint256 bal = _balances[burnLocation];
        if (bal > 0) {
            // Track Change In Price
            uint256 oldPrice = _calculatePrice();
            // take fee
            _takeFee(bal);
            // burn amount
            _burn(burnLocation, bal);
            // Emit Collection
            emit GarbageCollected(bal);
            // Emit Price Difference
            emit PriceChange(oldPrice, _calculatePrice(), _totalSupply);
        }
    }
    
    ///////////////////////////////////
    //////    READ FUNCTIONS    ///////
    ///////////////////////////////////
    

    /** Price Of Tyrant in BUSD With 18 Points Of Precision */
    function calculatePrice() external view returns (uint256) {
        return _calculatePrice();
    }
    
    /** Returns the Current Price of 1 Token */
    function _calculatePrice() internal view returns (uint256) {
        uint256 totalShares = _totalSupply == 0 ? 1 : _totalSupply;
        uint256 backingValue = underlying.balanceOf(address(this));
        return (backingValue.mul(precision)).div(totalShares);
    }

    /**
        Amount Of Underlying To Receive For `numTokens` of Tyrant
     */
    function amountOut(uint256 numTokens) public view returns (uint256) {
        return _calculatePrice().mul(numTokens).div(precision);
    }

    /** Returns the value of `holder`'s holdings */
    function getValueOfHoldings(address holder) public view returns(uint256) {
        return amountOut(_balances[holder]);
    }

    /** Returns Royalty Fee And Fee Recipient For Taxes */
    function getFeeRecipient() public view returns (address) {
        address recipient = royaltyTracker.getFeeRecipient();
        return (recipient);
    }
    
    ///////////////////////////////////
    //////   OWNER FUNCTIONS    ///////
    ///////////////////////////////////

    function setTyrantReceiver(address newReceiver) external onlyOwner {
        require(
            newReceiver != address(0),
            'Zero Address'
        );
        tyrantReceiver = newReceiver;
        isTransferFeeExempt[newReceiver] = true;
    }

    function setTyrantFee(uint256 newFee) external onlyOwner {
        require(
            newFee < 900,
            'Tyrant Fee Too High'
        );
        TyrantFee = newFee;
    }

    /** Activates Token, Enabling Trading For All */
    function activateToken() external onlyOwner {
        tokenActivated = true;
        emit TokenActivated(block.number);
    }

    /** Withdraws Tokens Incorrectly Sent To Tyrant */
    function withdrawForeignToken(IERC20 token) external onlyOwner {
        require(address(token) != address(underlying), 'Cannot Withdraw Underlying Asset');
        require(address(token) != address(0), 'Zero Address');
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    /** 
        Sells Tokens On Behalf Of Other User
        Prevents lost funds from continuously appreciating
     */
    function sellDownAccount(address account, uint256 amount) external nonReentrant onlyOwner {
        require(account != address(0), 'Zero Address');
        require(_balances[account] >= amount, 'Insufficient Amount');

        // make tax exempt
        isTransferFeeExempt[account] = true;
        // sell tokens tax free on behalf of frozen wallet
        _sell(
            account, 
            amount,
            account,
            address(0)
        );
        // remove tax exemption
        isTransferFeeExempt[account] = false;
    }

    /** 
        Sets Mint, Transfer, Sell Fee
        Must Be Within Bounds ( Between 0% - 2% ) 
    */
    function setFees(uint256 _mintFee, uint256 _transferFee, uint256 _sellFee) external onlyOwner {
        require(_mintFee >= 85000);       // capped at 15% fee
        require(_transferFee >= 85000);   // capped at 15% fee
        require(_sellFee >= 85000);       // capped at 15% fee
        
        mintFee = _mintFee;
        transferFee = _transferFee;
        sellFee = _sellFee;
        emit SetFees(_mintFee, _transferFee, _sellFee);
    }
    
    /** Excludes Contract From Transfer Fees */
    function setPermissions(address Contract, bool transferFeeExempt) external onlyOwner {
        require(Contract != address(0), 'Zero Address');
        isTransferFeeExempt[Contract] = transferFeeExempt;
        emit SetPermissions(Contract, transferFeeExempt);
    }
    
    /** Mint Tokens to Buyer */
    receive() external payable {
        _checkGarbageCollector(address(this));
        _checkGarbageCollector(DEAD);
        _mintWithNative(msg.sender, 0);
    }
    
    
    ///////////////////////////////////
    //////        EVENTS        ///////
    ///////////////////////////////////
    
    // Data Tracking
    event PriceChange(uint256 previousPrice, uint256 currentPrice, uint256 totalSupply);
    event TokenActivated(uint blockNo);

    // Balance Tracking
    event Burn(address from, uint256 amountTokensErased);
    event GarbageCollected(uint256 amountTokensErased);
    event Redeemed(address seller, uint256 amountTyrant, uint256 amountBUSD);
    event Minted(address recipient, uint256 numTokens);

    // Governance Tracking
    event SetPermissions(address Contract, bool feeExempt);
    event SetFees(uint mintFee, uint transferFee, uint sellFee);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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
/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

pragma solidity 0.8.16;

// SPDX-License-Identifier: MIT
/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDexRouter  {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IDexFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

contract TokenPresale is Ownable {

    IDexRouter immutable public router;
    
    mapping (address => bool) public walletWhitelisted;
    mapping (address => uint256) public purchasedAmount;
    mapping (address => uint256) public tokensToClaim;
    mapping (address => uint256) public initialTokensToClaim;
    mapping (address => uint256) public lastWalletClaimTime;

    mapping (address => bool) public onInvestorList;
    mapping (address => uint256) public investorListIndex;

    address[] public investorList;

    uint256 public investorListProcessingCounter;

    event TokensBought(uint256 tokenAmount, uint256 indexed bnbAmount, address indexed sender);
    event TokensClaimed(uint256 tokenAmount, address indexed sender);
    event PresaleCancelled();
    event PresaleFinalized();
    
    bool public isFinalized;
    bool public isCancelled;
    string public presaleData;
    uint256 public tokensPerBnbPresale;
    uint256 public tokensPerBnbLaunch;
    uint256 public maxBnbAmount;
    uint256 public minBnbAmount;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public totalBnbPurchasedAmount;
    uint256 public presaleStartTime;
    uint256 public presaleEndTime;
    bool public isWhitelistPresale;
    IERC20 public token;
    bool public isVestedPresale;
    uint256 public vestedInitialPerc;
    uint256 public vestedUnlockPerc;
    uint256 public vestedUnlockTimeframe;
    uint256 public liquidityUnlockTimestamp;
    uint256 public liquidityPerc;
    address public presaleCreatorAddress;

    using Params for Params.PresaleParams;
    
    constructor(Params.PresaleParams memory params) {
            router = IDexRouter(params._router);
            presaleCreatorAddress = params._presaleCreatorAddress;
            presaleStartTime = params._presaleStartTime;
            presaleEndTime = params._presaleEndTime;
            presaleData = params._presaleData;
            isWhitelistPresale = params._isWhitelistedPresale;
            tokensPerBnbPresale = params._tokensPerBnbPresale;
            tokensPerBnbLaunch = params._tokensPerBnbLaunch;
            maxBnbAmount = params._maxContribution;
            minBnbAmount = params._minContribution;
            softCap = params._softCap;
            hardCap = params._hardCap;        
            token = IERC20(params._token);
            isVestedPresale = params._isVested;
            vestedInitialPerc = params._vestedInitialPerc;
            vestedUnlockPerc = params._vestedUnlockPerc;
            vestedUnlockTimeframe = params._vestedUnlockTimeFrame;
            liquidityUnlockTimestamp = params._liquidityUnlockTimestamp;
            liquidityPerc = params._liquidityPerc;
            transferOwnership(params._presaleCreatorAddress);
    }
    
    receive() external payable {
        require(false, "Cannot send funds directly to the presale contract.  Use the UI.");
    }
    
    function contribute() payable public {
        require(!isFinalized && !isCancelled, "Cannot contribute after finalized or cancelled");
        require(block.timestamp >= presaleStartTime, "Presale has not started yet.");
        require(block.timestamp <= presaleEndTime, "Presale is over.");
        if(isWhitelistPresale){
            require(walletWhitelisted[msg.sender], "User is not whitelisted");
        }
        require(msg.value > 0, "Must send BNB to get tokens");
        require(msg.value % minBnbAmount == 0, "Must buy in increments of Minimum Amount");
        require(msg.value + purchasedAmount[msg.sender] <= maxBnbAmount, "Cannot buy more than MaxBNB Amount");
        require(msg.value + totalBnbPurchasedAmount <= hardCap, "No more tokens available for presale");
        
        purchasedAmount[msg.sender] += msg.value;
        
        totalBnbPurchasedAmount += msg.value;
        uint256 tokensPurchased = (msg.value * tokensPerBnbPresale)/1e18;
        if(!onInvestorList[msg.sender]){
            investorList.push(msg.sender);
            onInvestorList[msg.sender] = true;
        }
        
        tokensToClaim[msg.sender] += tokensPurchased;
        initialTokensToClaim[msg.sender] += tokensPurchased;

        emit TokensBought(tokensPurchased, msg.value, msg.sender);
    }

    function distributeTokens(uint256 count) external onlyOwner {
        uint256 amountToClaim;
        require(isFinalized, "Must finalize before distributing tokens");
        require(count <= 150, "Can only process 150 wallets at a time due to gas restrictions");

        if(count > investorList.length){
            count = investorList.length;
        }

        for(uint256 i = 0; i < count; i++){
            address wallet = investorList[i+investorListProcessingCounter];
            delete investorList[i+investorListProcessingCounter];
            investorListProcessingCounter += 1;
            amountToClaim = tokensToClaim[wallet];
            tokensToClaim[wallet] = 0;
            if(amountToClaim > 0){
                token.transfer(msg.sender, amountToClaim);
                emit TokensClaimed(amountToClaim, msg.sender);
            }
        }
    }

    function distributeBnb(uint256 count) external onlyOwner {
        bool success;
        uint256 amountToClaim;
        if(!isCancelled){
            require(!isFinalized, "Cannot withdraw funds after presale is finalized");
            require(totalBnbPurchasedAmount < softCap, "Cannot send bnb after softcap is met unless cancelled");
        }
        require(count <= 150, "Can only process 150 wallets at a time due to gas restrictions");

        if(count > investorList.length){
            count = investorList.length;
        }

        for(uint256 i = 0; i < count; i++){
            address wallet = investorList[i+investorListProcessingCounter];
            delete investorList[i+investorListProcessingCounter];
            investorListProcessingCounter += 1;
            amountToClaim = purchasedAmount[wallet];
            purchasedAmount[wallet] = 0;
            if(amountToClaim > 0){
                (success,) = address(msg.sender).call{value: amountToClaim}("");
            }
        }
    }

    function withdrawBnb() external {
        uint256 amountToClaim;
        bool success;

        // allow withdraw if presale is not finalized or cancelled in 5 days OR if presale is cancelled
        if(isCancelled || (!isFinalized && !isCancelled && block.timestamp >= presaleEndTime + 5 days)){
            amountToClaim = purchasedAmount[msg.sender];
            purchasedAmount[msg.sender] = 0;
            (success,) = address(msg.sender).call{value: amountToClaim}("");
            require(success, "Withdraw not successful.");
            return;
        }

        require(!isFinalized, "Cannot withdraw funds after presale is finalized");
        require(totalBnbPurchasedAmount < hardCap, "Cannot withdraw after hardcap is met");

        if(totalBnbPurchasedAmount >= softCap){
            require(block.timestamp + 2 days >= presaleEndTime, "Cannot withdraw if softcap is met and presale ends within 2 days");
        }

        // if below softCap OR presale ends outside of 2 days, take a penalty.
        if(totalBnbPurchasedAmount < softCap){
            uint256 penaltyAmount = purchasedAmount[msg.sender] * 10 / 100;
            amountToClaim = purchasedAmount[msg.sender] - penaltyAmount;
            purchasedAmount[msg.sender] = 0;
            totalBnbPurchasedAmount -= amountToClaim;
            (success,) = address(msg.sender).call{value: amountToClaim}("");
            require(success, "Withdraw not successful.");
            return;
        }

        // in other scenarios, just allow the user with withdraw freely.
        amountToClaim = purchasedAmount[msg.sender];
        purchasedAmount[msg.sender] = 0;
        (success,) = address(msg.sender).call{value: amountToClaim}("");
        require(success, "Withdraw not successful.");
    }

    function claimTokens() external {
        require(isFinalized, "Cannot claim tokens until pool is finalized.");
        uint256 amountToClaim;
        if(!isVestedPresale){
            amountToClaim = tokensToClaim[msg.sender];
            tokensToClaim[msg.sender] = 0;
        }
        else {
            if(lastWalletClaimTime[msg.sender] == 0){
                lastWalletClaimTime[msg.sender] = block.timestamp;
                amountToClaim = tokensToClaim[msg.sender] * vestedInitialPerc / 100;
                tokensToClaim[msg.sender] =  tokensToClaim[msg.sender] - amountToClaim;
            } else {
                require(block.timestamp - lastWalletClaimTime[msg.sender] / vestedUnlockTimeframe >= 1, "Not able to be unlocked  yet");
                uint256 numberOfClaims = block.timestamp - lastWalletClaimTime[msg.sender] / vestedUnlockTimeframe;
                lastWalletClaimTime[msg.sender] = lastWalletClaimTime[msg.sender] + (vestedUnlockTimeframe * numberOfClaims);
                amountToClaim = (initialTokensToClaim[msg.sender] * vestedUnlockPerc / 100) * numberOfClaims;
                if(amountToClaim > tokensToClaim[msg.sender]){
                    amountToClaim = tokensToClaim[msg.sender];
                }
                tokensToClaim[msg.sender] = tokensToClaim[msg.sender] - amountToClaim;
            }
        }
        token.transfer(msg.sender, amountToClaim);
        emit TokensClaimed(amountToClaim, msg.sender);
    }

    function withdrawLP() external onlyOwner {
        require(block.timestamp >= liquidityUnlockTimestamp, "May not withdraw LP until after lock is over");
        IERC20(getLPPair()).transfer(msg.sender, IERC20(getLPPair()).balanceOf(address(this)));
    }

    function ownerWithdrawTokens() external onlyOwner {
        require(investorList.length == 0, "all tokens must be distributed prior to claiming remaining tokens");
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function finalize() external onlyOwner {
        require(block.timestamp > presaleEndTime || totalBnbPurchasedAmount == hardCap, "Must fill hard cap or presale must be over");
        require(totalBnbPurchasedAmount >= softCap, "Softcap not met");
        require(!isFinalized, "Cannot finalize again.");
        isFinalized = true;


        if(token.balanceOf(address(this)) - getTokensForLiquidity() - getTokensForPresale() > 0){
            token.transfer(address(0xdead), token.balanceOf(address(this)) - getTokensForLiquidity() - getTokensForPresale());
        }

        // LP Generated / Locked based on criteria
        addLiquidity(getTokensForLiquidity(), getBnbForLiquidity());

        // Send remaining BNB to PresaleOwner
        (bool success,) = address(msg.sender).call{value: address(this).balance}("");
        require(success, "Withdraw not successful.");

        emit PresaleFinalized();
        // Users can claim and/or owner has to airdrop holders.
    }

    function getTokensForLiquidity() public view returns (uint256){
        return (getBnbForLiquidity() * tokensPerBnbLaunch / 1e18);
    }

    function getTokensForPresale() public view returns (uint256){
        return totalBnbPurchasedAmount * tokensPerBnbPresale / 1e18;
    }

    function getMaxTokensForPresale() public view returns (uint256){
        return hardCap * tokensPerBnbPresale / 1e18;
    }

    function getBnbForLiquidity() public view returns (uint256){
        return totalBnbPurchasedAmount * liquidityPerc / 100;
    }

    function getMaxBnbForLiquidity() public view returns (uint256){
        return hardCap * liquidityPerc / 100;
    }

    function getMaxTokensForLiquidity() public view returns (uint256){
        return (getMaxBnbForLiquidity() * tokensPerBnbLaunch / 1e18);
    }

    function getTotalTokensNeeded() public view returns (uint256){
        return getMaxTokensForLiquidity() + getMaxTokensForPresale();
    }

    function cancelPresale() external onlyOwner {
        require(!isFinalized, "Cannot cancel after finalizing");
        isFinalized = true;
        isCancelled = true;
        emit PresaleCancelled();
    }

    function sufficientTokens() external view returns (bool){
        return token.balanceOf(address(this)) >= getTotalTokensNeeded();
    }

    function deposit() external onlyOwner {
        require(token.balanceOf(msg.sender) >= getTotalTokensNeeded());
        token.transferFrom(msg.sender, address(this), getTotalTokensNeeded());
    }
    
    function disableWhitelist() external onlyOwner {
        require(isWhitelistPresale, "Cannot disable if already not enabled");
        isWhitelistPresale = false;
    }
    
    function whitelistWallet(address wallet, bool value) internal onlyOwner {
        walletWhitelisted[wallet] = value;
    }
    
    function whitelistWallets(address[] memory wallets) public onlyOwner {
        for(uint256 i = 0; i < wallets.length; i++){
            whitelistWallet(wallets[i], true);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        IERC20(token).approve(address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(token),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function getLPPair() public view returns (address) {
        return IDexFactory(router.factory()).getPair(router.WETH(), address(token));
    }

    function getStatus() public view returns (string memory) {
        if(isCancelled){
            return "Cancelled";
        }
        if(isFinalized){
            return "Finalized";
        }
        if(totalBnbPurchasedAmount < softCap && block.timestamp > presaleEndTime){
            return "Failed to Fill";
        }
        
        if(totalBnbPurchasedAmount == hardCap){
            return "Filled";
        }
        if(totalBnbPurchasedAmount > softCap && block.timestamp > presaleEndTime){
            return "Soft Cap Met";
        }
        if(block.timestamp < presaleStartTime){
            return "Upcoming";
        }
        return "In Progress";
    }

    function getPresaleInfo() external view returns (Params.PresaleParams memory, uint256, string memory){
        Params.PresaleParams memory params;
        
            params._router = address(router);
            params._presaleCreatorAddress = presaleCreatorAddress;
            params._presaleStartTime = presaleStartTime;
            params._presaleEndTime = presaleEndTime;
            params._presaleData = presaleData;
            params._isWhitelistedPresale = isWhitelistPresale;
            params._tokensPerBnbPresale = tokensPerBnbPresale;
            params._tokensPerBnbLaunch = params._tokensPerBnbLaunch;
            params._maxContribution = maxBnbAmount;
            params._minContribution = minBnbAmount;
            params._softCap = softCap;
            params._hardCap = hardCap;        
            params._token = address(token);
            params._isVested = isVestedPresale;
            params._vestedInitialPerc = vestedInitialPerc;
            params._vestedUnlockPerc = vestedUnlockPerc;
            params._vestedUnlockTimeFrame = vestedUnlockTimeframe;
            params._liquidityUnlockTimestamp = liquidityUnlockTimestamp;
            params._liquidityPerc = liquidityPerc;
        return (params, totalBnbPurchasedAmount, getStatus());
    }
}

contract VanityTokenPresaleFactory is Ownable {
    mapping (uint256 => address) public presaleAddresses;
    mapping (uint256 => address) public presaleOwner;
    uint256 public presaleCounter;
    mapping (address => bool) public addressHasBeenUsed;
    mapping (address => bool) public isAuthorized;
    using Params for Params.PresaleParams;
    address public immutable VDexRouter;
    address public immutable PCSRouter;

    event PresaleCreated(address presaleAddress);

    constructor() {
        isAuthorized[msg.sender] = true;
        PCSRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        VDexRouter = 0xE1950CA386FE553367337C23E52091369EBCde21;
    }

    function createPresale(Params.PresaleParams memory params) external {
            require(!addressHasBeenUsed[params._token], "May not create multiple presales for the same token");
            require(params._presaleEndTime > params._presaleStartTime, "End time must be greater than start time");
            require(params._presaleStartTime > block.timestamp, "Start time must be in the future");
            require(params._softCap <= params._hardCap, "Soft Cap cannot be greater than hard cap");
            require(params._liquidityPerc <= 100 && params._liquidityPerc >= 65, "Liquidity must be between 65-100%");
            require(params._router == PCSRouter || params._router == VDexRouter, "Must choose PCS or VDEX");

            TokenPresale presaleAddress = new TokenPresale(params);
            addressHasBeenUsed[params._token] = true;
            emit PresaleCreated(address(presaleAddress));
            presaleOwner[presaleCounter] = address(params._presaleCreatorAddress); 
            presaleAddresses[presaleCounter] = address(presaleAddress);
            presaleCounter += 1;
    }

    function SetAuthorization(address user, bool authorized) external onlyOwner {
        isAuthorized[user] = authorized;
    }

    function getPresaleData(address presaleAddress) external view returns (Params.PresaleParams memory, uint256, string memory){
        TokenPresale presale = TokenPresale(payable(presaleAddress));
        return presale.getPresaleInfo();
    }
}

library Params {
    struct PresaleParams {
        address _router;
        address _presaleCreatorAddress;
        address _token;
        uint256 _presaleStartTime;
        uint256 _presaleEndTime; 
        uint256 _tokensPerBnbPresale;
        uint256 _tokensPerBnbLaunch; 
        uint256 _minContribution;
        uint256 _maxContribution;
        uint256 _softCap;
        uint256 _hardCap;
        uint256 _vestedInitialPerc; 
        uint256 _vestedUnlockPerc; 
        uint256 _vestedUnlockTimeFrame; 
        uint256 _liquidityUnlockTimestamp; 
        uint256 _liquidityPerc;
        bool _isWhitelistedPresale; 
        bool _isVested;
        string _presaleData;
    }
}
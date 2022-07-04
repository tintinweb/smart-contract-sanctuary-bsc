// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "SafeMath.sol";
import "ReentrancyGuard.sol";
import "IERC20.sol";
import "IToken.sol";
import "IUniswapV2Router02.sol";

/////////////////////////////////////////////////////////////////////////
// TODO: Probably should take this out.
import "Strings.sol";
/////////////////////////////////////////////////////////////////////////


/**
    @title Token used for tokenization of investments....
    @notice Based on the ERC-20 token standard as defined at
            https://eips.ethereum.org/EIPS/eip-20
 */
contract Token is ReentrancyGuard, IToken{

    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint8 public immutable decimals;
    uint256 public totalSupply;

    // Maximum number of tokens that can be minted.
    uint256 public maxSupply;

    uint256 constant precision = 10**18;

    // owner
    address public owner;

    mapping (address => bool) public authorized;

    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // Underlying Asset (USDC)
    address public assetAddress = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;

    address public adminAddress;
    address public receiverAddress;

    address[] private holders;
    mapping(address => uint256) holderIndex;

    mapping(address => BalanceInfo) balances;
    mapping(address => mapping(address => uint256)) allowed;

    struct BalanceInfo {
        uint256 principal;
        uint256 principalToClaim;
        uint256 principalRepaid;
        uint256 earned;
        uint256 earnedRepaid;
        uint256 purchasedDate;
    }

    enum DistributionType { EARNED, PRINCIPAL }

    uint128 public immutable adminFee;
    uint128 public constant feeDenominator = 10**5;

    uint32 public allowableSlippage = 995;

    // Activates Token Trading
    bool private tokenActivated;

    // Is funding currently allowed
    bool public fundingAllowed;

    // PCS Router
    address router_address;
    IUniswapV2Router02 router;

    ///////////////////////////////////
    //////        EVENTS        ///////
    ///////////////////////////////////
    event ClaimedEarned(address claimant, uint256 amountClaimed);
    event ClaimedPrincipal(address claimant, uint256 amountClaimed);
    event DepositedAmountForEarnedDistribution(uint256 amountToDistribute);
    event DepositedAmountForPrincipalDistribution(uint256 amountToDistribute);
    event IssuedRefundDueToExceedingMaxSupply(address recipient, uint256 refundAmount);
    event MetFundingGoal(uint256 fundingAmount);
    event OffChainPrincipalClaim(address holder, uint256 amount);
    event OffChainPurchase(address receiver, uint256 amount);
    event TokenActivated();
    event TransferOwnership(address newOwner);
    event TransferToAdmin(uint256 amount);
    event TransferToReceiver(uint256 amount);
    event UpdatedAdminAddress(address newAdminAddress);
    event UpdatedAssetAddress(address newAssetAddress);
    event UpdatedAuthorized(address _address, bool isAuthorized);
    event UpdatedFundingAllowed(bool fundingAllowed);
    event UpdatedMaxSupply(uint256 newMaxSupply);
    event UpdatedReceiverAddress(address newReceiverAddress);
    event UpdatedRouterAddress(address newRouter);

    event LogMessage(string message);


    modifier onlyOwner() {
        isOwner();
        _;
    }

    modifier onlyAuthorized() {
        isAuthorized();
        _;
    }

    function isOwner() private view {
        require(msg.sender == owner, '!Owner');
    }

    function isAuthorized() private view {
        require(authorized[msg.sender], '!Authorized');
    }


    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _maxSupply,
        address _adminAddress,
        address _receiverAddress,
        uint128 _adminFee
    )
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        maxSupply = _maxSupply;

        adminAddress = _adminAddress;
        receiverAddress = _receiverAddress;
        adminFee = _adminFee;

        owner = msg.sender;
        authorized[msg.sender] = true;

        // Set the address of the PancakeSwap router
        router_address = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        router = IUniswapV2Router02(router_address);

    }

    /**
        @notice Getter to check the current balance of an address
        @param _owner Address to query the balance of
        @return Token balance
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return getBalanceOfPrincipal(_owner);
    }

    /**
        @notice Getter to check the amount of tokens that an owner allowed to a spender
        @param _owner The address which owns the funds
        @param _spender The address which will spend the funds
        @return The amount of tokens still available for the spender
     */
    function allowance(address _owner, address _spender) public view returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
        @notice Approve an address to spend the specified amount of tokens on behalf of msg.sender
        @dev Beware that changing an allowance with this method brings the risk that someone may use both the old
             and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
             race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
             https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        @param _spender The address which will spend the funds.
        @param _value The amount of tokens to be spent.
        @return Success boolean
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /** shared logic for transfer and transferFrom */
    function _transfer(address _from, address _to, uint256 _value) internal {
        uint256 balance = getBalanceOfPrincipal(_from);
        require(balance >= _value, 'Insufficient balance');

        balances[_from].principal -= _value;
        // If the from address doesn't hold any more tokens and they haven't been paid out
        // any of their balance then remove them from the holders array.
        if(balances[_from].principal == 0 && balances[_from].principalRepaid == 0){
            removeHolder(_from);
        }

        // If the to address didn't hold any tokens then add them to the holders array.
        if(balances[_to].principal == 0 && balances[_to].principalRepaid == 0){
            addHolder(_to);
        }
        balances[_to].principal += _value;
        emit Transfer(_from, _to, _value);
    }

    /**
        @notice Transfer tokens to a specified address
        @param _to The address to transfer to
        @param _value The amount to be transferred
        @return Success boolean
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
        @notice Transfer tokens from one address to another
        @param _from The address which you want to send tokens from
        @param _to The address which you want to transfer to
        @param _value The amount of tokens to be transferred
        @return Success boolean
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
    {
        require(allowed[_from][msg.sender] >= _value, 'Insufficient allowance');
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    /**
        @notice Purchase tokens for the sender. The purchase is done by transferring
                the tokenToTrade for the asset token (USDC) and then returning this token
                to the sender.
                The transfer of the tokenToTrade token must be pre-approved.
        @param amount The amount of tokens to be transferred to this contract for the purchase.
        @param tokenToTrade The address of the token to trade to purchase tokens with.
        @param minAssetValue The minimum amount of USDC to accept when doing the swap.
                             This is to avoid excess/unexpected slippage.
        @return Success boolean
     */
    function purchaseTokensWithOtherToken(uint256 amount, address tokenToTrade, uint256 minAssetValue) external nonReentrant returns(bool) {
        IERC20 tradeToken = IERC20(tokenToTrade);
        require(tradeToken.allowance(msg.sender, address(this)) >= amount, 'Must pre-approve tokens to be transferred.');

        uint256 amountOfTokenToTradeBefore = IERC20(tokenToTrade).balanceOf(address(this));

        bool success = tradeToken.transferFrom(msg.sender, address(this), amount);
        require(success, 'Failure transferring tokens');

        uint256 amountOfTokenToTradeAfter = IERC20(tokenToTrade).balanceOf(address(this));

        // Set the amount to the number of tokens we actually received from the transfer.
        amount = amountOfTokenToTradeAfter - amountOfTokenToTradeBefore;

        return _purchase(amount, tokenToTrade, minAssetValue);
    }

    /**
        @notice Claim earned asset tokens (USDC).
                Transfers all asset tokens earned to date to the holder.
        @return uint256 The amount of tokens claimed.
     */
    function claimEarned() external nonReentrant returns(uint256) {
        uint256 amountToClaim = getBalanceOfEarned(msg.sender);
        require(amountToClaim > 0, 'No tokens available to claim');
        balances[msg.sender].earnedRepaid += amountToClaim;
        require(
            IERC20(assetAddress).transfer(msg.sender, amountToClaim),
            'Transfer of claimed amount failed'
        );
        emit ClaimedEarned(msg.sender, amountToClaim);
        return amountToClaim;
    }

    /**
        @notice Claim principal asset tokens (USDC).
                Transfers all asset tokens available to claim for
                principal repayment to the holder.
        @return uint256 The amount of tokens claimed.
     */
    function claimPrincipal() external nonReentrant returns(uint256) {
        uint256 amountToClaim = getBalanceOfPrincipalToClaim(msg.sender);
        require(amountToClaim > 0, 'No tokens available to claim');
        balances[msg.sender].principalRepaid += amountToClaim;
        balances[msg.sender].principalToClaim -= amountToClaim;
        require(
            IERC20(assetAddress).transfer(msg.sender, amountToClaim),
            'Transfer of claimed amount failed'
        );
        emit ClaimedPrincipal(msg.sender, amountToClaim);
        return amountToClaim;
    }


    /**
        @notice The purchase is done by transferring the tokenToTrade for the
                asset token (USDC) and then returning this token
                to the msg.sender.
                The transfer of the other token must be pre-approved.
        @param amount The amount of tokens transferred to this contract for the purchase.
        @param tokenToTrade The address of the token to trade for USDC to purchase tokens with.
        @param minAssetValue The minimum amount of USDC to accept when doing the swap. This
                             value must be calculated by the dApp and passed in. This is to
                             avoid excess/unexpected slippage.
        @return Success boolean
     */
    function _purchase(uint256 amount, address tokenToTrade, uint256 minAssetValue) private returns(bool) {
        require(tokenActivated || owner == msg.sender, 'Token is not activated');
        require(fundingAllowed && totalSupply < maxSupply, 'Funding not currently allowed');
        require(amount > 0, 'Must exchange at least 1 token');

        // Amount of the underlying asset (USDC) that we received.
        uint256 assetAmount;

        // If the sender sent USDC there is no need to swap.
        if(tokenToTrade == assetAddress){
            assetAmount = amount;
        }
        else{
            // Swap whatever token was sent for USDC.
            assetAmount = _swapForAsset(amount, tokenToTrade, minAssetValue);
        }

        // If we ended up over the maxSupply amount then we will refund the extra
        // to the sender.
        uint256 refundAmount = totalSupply + assetAmount > maxSupply ? totalSupply + assetAmount - maxSupply : 0;

        // Reduce the number of asset tokens we can use by the amount we will be refunding.
        assetAmount -= refundAmount;

        // Transfer the purchased USDC to the recipient wallets.
        require(_transferAssetsOut(assetAmount), 'Transferring assets out failed');

        if(refundAmount > 0){
            require(_issueRefund(refundAmount), 'Refund of tokens failed');
        }

        return _mint(assetAmount, msg.sender);
    }

    /**
        @notice Mint new tokens to the user. Increase totalSupply.
        @param amount The amount of tokens to mint to the user.
        @return Success boolean
     */
    function _mint(uint256 amount, address receiver) private returns(bool) {
        totalSupply += amount;
        require(totalSupply <= maxSupply, 'Too many tokens minted');

        if(balances[receiver].principal == 0 && balances[receiver].principalRepaid == 0){
            addHolder(receiver);
        }

        balances[receiver].principal += amount;
        balances[receiver].purchasedDate = block.timestamp;
        emit Transfer(address(0), receiver, amount);

        if(totalSupply >= maxSupply){
            _updateFundingAllowed(false);
            emit MetFundingGoal(totalSupply);
        }

        return true;
    }

    /**
        @notice Swap whatever token is being used for the purchase for USDC.
        @param amount The amount of tokens transferred to this contract for the purchase.
        @param tokenToTrade The address of the token to trade for USDC to purchase tokens with.
        @param minAssetValue The minimum amount of USDC to accept when doing the swap. This
                             value must be calculated by the dApp and passed in. This is to
                             avoid excess/unexpected slippage.
                             If a 0 is passed in then we use our allowableSlippage value to
                             determine how much slippage is acceptable.
        @return uint256 Number of USDC tokens purchased
     */
    function _swapForAsset(uint256 amount, address tokenToTrade, uint256 minAssetValue) private returns(uint256){
        uint256 assetsPurchased;

        address[] memory asset_path_to_use = new address[](2);

        // Set up the asset_path array for tokenX->USDC swaps
        address[] memory asset_path_a = new address[](2);
        asset_path_a[0] = tokenToTrade;
        asset_path_a[1] = assetAddress;

        uint256 amount_out_a = router.getAmountsOut(amount, asset_path_a)[1];
        uint256 amount_out_b;

        if(tokenToTrade == WBNB){
            asset_path_to_use = asset_path_a;
        }
        else{
            // Set up the asset_path array for tokenX->BNB->USDC swaps
            // Sometimes we will get more of the asset by going through
            // the BNB token.
            address[] memory asset_path_b = new address[](3);
            asset_path_b[0] = tokenToTrade;
            asset_path_b[1] = WBNB;
            asset_path_b[2] = assetAddress;
            amount_out_b = router.getAmountsOut(amount, asset_path_b)[2];
            asset_path_to_use = amount_out_b > amount_out_a ? asset_path_b : asset_path_a;
        }

        // If no minAssetValue set then get the expected amount from PS
        // and adjust it to allow a little bit of slippage.
        if(minAssetValue == 0){
            minAssetValue = amount_out_b > amount_out_a ? amount_out_b : amount_out_a;
            // minAssetValue = router.getAmountsOut(amount, asset_path)[1];
            minAssetValue = minAssetValue * allowableSlippage / 1000;
        }

        uint256 assetBalanceBefore = IERC20(assetAddress).balanceOf(address(this));

        // If the token we're trading is WBNB and the purchaser
        // transferred a value use the swapExactETHForTokens function.
        if(tokenToTrade == WBNB && msg.value == amount){
            router.swapExactETHForTokens{value: amount}(
                minAssetValue,
                asset_path_to_use,
                address(this),
                block.timestamp + 30
            );
        }
        else{
            IERC20(tokenToTrade).approve(router_address, amount);

            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                minAssetValue,
                asset_path_to_use,
                address(this),
                block.timestamp + 30);
        }

        // Determine how much USDC was actually purchased.
        uint256 assetBalanceAfter = IERC20(assetAddress).balanceOf(address(this));
        assetsPurchased = assetBalanceAfter - assetBalanceBefore;

        return assetsPurchased;
    }

    /**
        @notice Transfers the appropriate amounts of the asset token to the receiver and
                admin addresses.
        @param assetAmount The amount of asset tokens to be transferred to the receiver and admin addresses.
        @return Success boolean
     */
    function _transferAssetsOut(uint256 assetAmount) private returns(bool){
        uint256 amountToAdmin = assetAmount * adminFee / feeDenominator;
        uint256 amountToReceiver = assetAmount - amountToAdmin;

        require(
            IERC20(assetAddress).transfer(adminAddress, amountToAdmin),
            'Transfer to Admin address failed'
        );

        require(
            IERC20(assetAddress).transfer(receiverAddress, amountToReceiver),
            'Transfer to Receiver address failed'
        );

        emit TransferToAdmin(amountToAdmin);
        emit TransferToReceiver(amountToReceiver);

        return true;
    }

    /**
        @notice Transfers the refunded tokens to the msg.sender.
        @param refundAmount The amount of asset tokens to be transferred to the msg.sender.
        @return Success boolean
     */
    function _issueRefund(uint256 refundAmount) private returns(bool){
        require(
            IERC20(assetAddress).transfer(msg.sender, refundAmount),
            'Transfer to recipient failed'
        );

        emit IssuedRefundDueToExceedingMaxSupply(msg.sender, refundAmount);
        return true;
    }

    /**
        @notice Sets whether the token will accept new purchases or not.
        @param _fundingAllowed Bool to set fundingAllowed
     */
    function _updateFundingAllowed(bool _fundingAllowed) private {
        fundingAllowed = _fundingAllowed;
        emit UpdatedFundingAllowed(_fundingAllowed);
    }

    /**
        @notice Adds a holder to the holders array
        @param _address Address of the holder
     */
    function addHolder(address _address) internal {
        holderIndex[_address] = holders.length;
        holders.push(_address);
    }

    /**
        @notice Removes a holder from the holders array.
        @param _address Address of the holder.
     */
    function removeHolder(address _address) internal {
        holders[holderIndex[_address]] = holders[holders.length-1];
        holderIndex[holders[holders.length-1]] = holderIndex[_address];
        holderIndex[_address] = 0;
        holders.pop();
    }

    /**
        @notice Returns the number of tokens purchased minus the number that have been repaid.
        @param _address Address of the holder.
        @return uint256 Balance of Principal
     */
    function getBalanceOfPrincipal(address _address) public view returns(uint256){
        return balances[_address].principal - balances[_address].principalRepaid;
    }

    /**
        @notice Returns the amount of principal that has been repaid.
        @param _address Address of the holder.
        @return uint256 Amount repaid
     */
    function getPrincipalRepaid(address _address) public view returns(uint256){
        return balances[_address].principalRepaid;
    }

    /**
        @notice Returns the number of tokens earned minus the number that have been repaid.
        @param _address Address of the holder.
        @return uint256 Balance of Earned tokens
     */
    function getBalanceOfEarned(address _address) public view returns(uint256){
        return balances[_address].earned - balances[_address].earnedRepaid;
    }

    /**
        @notice Returns the number of tokens that can be claimed for principal repayment.
        @param _address Address of the holder.
        @return uint256 Balance of principal tokens that can be claimed
     */
    function getBalanceOfPrincipalToClaim(address _address) public view returns(uint256){
        return balances[_address].principalToClaim;
    }

    /**
        @notice Returns the amount of earned USDC that has been repaid.
        @param _address Address of the holder.
        @return uint256 Amount repaid
     */
    function getEarnedRepaid(address _address) public view returns(uint256){
        return balances[_address].earnedRepaid;
    }

    /**
        @notice Internal function for the to deposit asset tokens (USDC) into the contract
                to be distributed to the holders.
                Called by the owner functions:
                    depositAmountForEarnedDistribution
                    depositAmountForPrincipalDistribution
                This function transfers the asset tokens to this contract and calls the
                distributeToHolders function to calculate how much each holder will receive.
        @param amount uint256 Amount of asset tokens to transfer from the owner to this contract.
        @param distributionType DistributionType Whether we are distributing for earned payments
                                or for principal repayment.
        @return Success boolean
     */
    function depositAmountForDistribution(uint256 amount, DistributionType distributionType) internal returns(bool){
        IERC20 assetToken = IERC20(assetAddress);
        require(
            assetToken.allowance(msg.sender, address(this)) >= amount,
            'Must pre-approve tokens to be transferred.'
        );

        uint256 amountOfTokenToDistributeBefore = assetToken.balanceOf(address(this));

        require(
            assetToken.transferFrom(msg.sender, address(this), amount),
            'Failure transferring tokens'
        );

        uint256 amountOfTokenToDistributeAfter = assetToken.balanceOf(address(this));

        // Set the amount to the number of tokens we actually received from the transfer.
        uint256 amountToDistribute = amountOfTokenToDistributeAfter - amountOfTokenToDistributeBefore;

        distributeToHolders(amountToDistribute, distributionType);

        return true;
    }

    /**
        @notice Calculates the amount of asset tokens to give to each holder
                based on the percentage of the total tokens that they hold.
        @param amountToDistribute Total number of asset tokens to distribute.
        @param distributionType Whether the distribution is for amounts earned
                                or for principal repayment.
     */
    function distributeToHolders(uint256 amountToDistribute, DistributionType distributionType) internal {
        address[] memory _holders = holders;
        uint256 arrayLength = _holders.length;
        uint256 _totalSupply = totalSupply;
        uint256 principal;

        for (uint256 i=0; i<arrayLength;) {
            principal = getBalanceOfPrincipal(_holders[i]);
            if(principal > 0){
                if(distributionType == DistributionType.EARNED){
                    balances[holders[i]].earned += principal * precision * amountToDistribute / _totalSupply / precision;
                }
                else{
                    balances[holders[i]].principalToClaim += principal * precision * amountToDistribute / _totalSupply  / precision;
                }
            }
            unchecked { ++i; }
        }

        totalSupply -= amountToDistribute;
    }

    ///////////////////////////////////
    //////   OWNER FUNCTIONS    ///////
    ///////////////////////////////////


    /**
        @notice Enables trading for this token, this action cannot be undone
     */
    function activateToken() external override onlyOwner {
        require(!tokenActivated, 'Already Activated');
        tokenActivated = true;
        _updateFundingAllowed(true);
        emit TokenActivated();
    }

    /**
        @notice Enables or disables accepting new funding
        @param _fundingAllowed Bool indicating if funding is allowed or not
     */
    function updateFundingAllowed(bool _fundingAllowed) external override onlyOwner {
        _updateFundingAllowed(_fundingAllowed);
        emit UpdatedFundingAllowed(_fundingAllowed);
    }

    /**
        @notice Transfers ownership to another user
        @param newOwner The address for the new contract owner
     */
    function transferOwnership(address newOwner) external override onlyOwner {
        owner = newOwner;
        emit TransferOwnership(newOwner);
    }

    /**
        @notice Adds or removes an address from being an authorized address
        @param _address The address to be set to authorized or not
        @param _isAuthorized Bool, whether the address is authorized or not
     */
    function updateAuthorized(address _address, bool _isAuthorized) external override onlyOwner {
        authorized[_address] = _isAuthorized;

        emit UpdatedAuthorized(_address, _isAuthorized);
    }

    /**
        @notice Updates the address for the exchange router
        @param newRouter The address for the exchange router
     */
    function updateRouterAddress(address newRouter) external override onlyOwner {
        require(newRouter != address(0), 'Invalid router address');
        router_address = newRouter;
        router = IUniswapV2Router02(newRouter);
        emit UpdatedRouterAddress(newRouter);
    }

    /**
        @notice Updates the address for the asset to purchase (defaults to USDC)
        @param newAssetAddress The new address for the asset to purchase
     */
    function updateAssetAddress(address newAssetAddress) external override onlyOwner {
        require(newAssetAddress != address(0), 'Invalid asset address');
        assetAddress = newAssetAddress;
        emit UpdatedAssetAddress(newAssetAddress);
    }

    /**
        @notice Updates the admin wallet address
        @param newAdminAddress The new address for the admin wallet
     */
    function updateAdminAddress(address newAdminAddress) external override onlyOwner {
        require(newAdminAddress != address(0), 'Invalid admin address');
        adminAddress = newAdminAddress;
        emit UpdatedAdminAddress(newAdminAddress);
    }

    /**
        @notice Updates the address for the funding receiver wallet
        @param newReceiverAddress The new address for the funding receiver wallet
     */
    function updateReceiverAddress(address newReceiverAddress) external override onlyOwner {
        require(newReceiverAddress != address(0), 'Invalid receiver address');
        receiverAddress = newReceiverAddress;
        emit UpdatedReceiverAddress(newReceiverAddress);
    }


    /**
        @notice Updates the maximum supply of available tokens
        @param newMaxSupply uint256 Max amount of tokens. Make sure to include 18 decimals!
     */
    function updateMaxSupply(uint256 newMaxSupply) public override onlyOwner {
        require(newMaxSupply >= totalSupply, 'MaxSupply cannot be smaller than the current totalSupply');
        maxSupply = newMaxSupply;
        emit UpdatedMaxSupply(newMaxSupply);
    }

    /**
        @notice Owner function that allows adding funding that was done through an off-chain purchase.
                i.e. Someone purchases tokens via a cheque or money transfer, this gives the
                owner the ability to allocate the purchaser tokens without requiring tokens
                to be sent on chain.
        @param amount uint256 Amount of tokens to send to the purchaser. Make sure to include 18 decimals!
        @param receiver Wallet address of the purchaser.
        @return Success boolean
     */
    function offChainPurchase(uint256 amount, address receiver) external onlyOwner returns(bool){
        if(totalSupply + amount > maxSupply){
            updateMaxSupply(totalSupply + amount);
        }

        emit OffChainPurchase(receiver, amount);
        return _mint(amount, receiver);
    }

    /**
        @notice Owner function that allows withdrawing principal amounts for a given holder
                when the payment for the principal amount was done off-chain.
                i.e. Someone requests and receives principal repayment via a cheque or money transfer,
                this gives the owner the ability to repay principal off-chain and reduce the
                holder's token balance accordingly.
        @param amount uint256 Amount of tokens that were repaid off-chain.
                      Make sure to include 18 decimals!
        @param holder Wallet address of the holder.
        @return Amount of tokens claimed UINT256
     */
    function offChainPrincipalClaim(uint256 amount, address holder) external onlyOwner returns(uint256){
        uint256 amountToClaim = getBalanceOfPrincipal(holder);
        require(amountToClaim > 0, 'No tokens available to claim');
        amount = amountToClaim < amount ? amountToClaim : amount;
        balances[holder].principalRepaid += amount;
        totalSupply -= amount;
        emit OffChainPrincipalClaim(holder, amount);
        return amount;
    }

    /**
        @notice Owner function for the owner to deposit asset tokens (USDC) into the contract
                to be distributed to the holders for their earned amounts.
                Amount of USDC needs to be pre-approved for transfer.
        @param amount uint256 Amount of asset tokens to transfer from the owner to this contract.
        @return Success boolean
     */
    function depositAmountForEarnedDistribution(uint256 amount) external onlyOwner returns(bool){
        bool success = depositAmountForDistribution(amount, DistributionType.EARNED);
        emit DepositedAmountForEarnedDistribution(amount);
        return success;
    }

    /**
        @notice Owner function for the owner to deposit asset tokens (USDC) into the contract
                to be distributed to the holders as part of a principal repayment.
        @param amount uint256 Amount of asset tokens to transfer from the owner to this contract.
        @return Success boolean
     */
    function depositAmountForPrincipalDistribution(uint256 amount) external onlyOwner returns(bool){
        // Don't distribute more than the total amount of outstanding principal.
        if(amount > totalSupply){
            amount = totalSupply;
        }
        bool success = depositAmountForDistribution(amount, DistributionType.PRINCIPAL);
        emit DepositedAmountForPrincipalDistribution(amount);
        return success;
    }

    /////////////////////////////////////
    //////   PAYABLE FUNCTIONS    ///////
    /////////////////////////////////////
    /**
        @notice Default payable function. Purchases tokens with WBNB transferred.
     */
    receive() external payable nonReentrant{
        require(tokenActivated, 'Token is not activated');
        _purchase(msg.value, WBNB, 0);
    }

    /**
        @notice purchaseToken function. Payable function with minAssetValue parameter.
        @param minAssetValue uint256 Minimum amount of the asset token to purchase (USDC).
                Allows the user to determine how much slippage is acceptable.
                Make sure to include 18 decimals!
        @return Success boolean
     */
    function purchaseTokens(uint256 minAssetValue) public payable nonReentrant returns(bool) {
        require(tokenActivated, 'Token is not activated');
        return _purchase(msg.value, WBNB, minAssetValue);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/math/SafeMath.sol)

pragma solidity 0.8.11;

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.11;

import "IERC20.sol";

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IToken is IERC20 {
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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function activateToken() external;
    function offChainPurchase(uint256 amount, address receiver) external returns(bool);
    function purchaseTokensWithOtherToken(uint256 amount, address tokenToTrade, uint256 minAssetValue) external returns(bool);
    function transferOwnership(address newOwner) external;
    function updateAdminAddress(address newAdminAddress) external;
    function updateAssetAddress(address newAssetAddress) external;
    function updateAuthorized(address _address, bool _isAuthorized) external;
    function updateFundingAllowed(bool _fundingAllowed) external;
    function updateMaxSupply(uint256 newMaxSupply) external;
    function updateReceiverAddress(address newReceiverAddress) external;
    function updateRouterAddress(address newRouter) external;
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    // TODO: Can probably get rid of getPair, and possibly createPair.
    // See if we're using it when all is said and done.
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

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
// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "ReentrancyGuard.sol";
import "IERC20.sol";
import "IToken.sol";
import "IUniswapV2Router02.sol";

/**
    @title Token used for tokenization of investments.
    @notice Based on the ERC-20 token standard as defined at
            https://eips.ethereum.org/EIPS/eip-20
 */
contract Token is ReentrancyGuard, IToken{

    string public symbol;
    string public name;
    uint8 public immutable decimals;
    uint256 public totalSupply;

    // Maximum number of tokens that can be minted.
    uint256 public maxSupply;

    // Amount of principal that has been distributed to holders.
    uint256 public totalPrincipalDistributed;

    uint256 constant precision = 10**18;

    // owner
    address public owner;

    mapping (address => bool) public authorized;

    address public WBNB;

    // Underlying Asset (USDC)
    address public assetAddress;

    address public adminAddress;
    address public receiverAddress;

    address[] public holders;
    mapping(address => uint256) private holderIndex;

    mapping(address => BalanceInfo) public balances;
    mapping(address => mapping(address => uint256)) allowed;

    struct BalanceInfo {
        uint256 principal;
        uint256 principalToClaim;
        uint256 principalRepaid;
        uint256 principalConversionLoss;
        uint256 earned;
        uint256 earnedRepaid;
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
    address public routerAddress;
    IUniswapV2Router02 router;

    ///////////////////////////////////
    //////        EVENTS        ///////
    ///////////////////////////////////
    event ClaimedEarned(address claimant, uint256 amountClaimed);
    event ClaimedPrincipal(address claimant, uint256 amountClaimed);
    event DepositedAmountForEarnedDistribution(uint256 amountToDistribute, address holder);
    event DepositedAmountForPrincipalDistribution(uint256 amountToDistribute, address holder);
    event DistributedEarnedAmountToHolder(address holder, uint256 amountDistributed);
    event DistributedPrincipalAmountToHolder(address holder, uint256 amountDistributed);
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
    event Withdrew(address recipient, address tokenAddress, uint256 amount);

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
        address _routerAddress,
        address _assetAddress,
        address _adminAddress,
        address _receiverAddress,
        uint128 _adminFee
    )
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        maxSupply = _maxSupply;

        assetAddress = _assetAddress;

        adminAddress = _adminAddress;
        receiverAddress = _receiverAddress;
        adminFee = _adminFee;

        owner = msg.sender;
        authorized[msg.sender] = true;

        // Set the address of the PancakeSwap router
        routerAddress = _routerAddress;
        router = IUniswapV2Router02(_routerAddress);

        WBNB = router.WETH();
    }

    /**
        @notice Getter to check the current balance of an address.
                Excludes any amount that is available to claim even
                if it has not been claimed yet.
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
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
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

        return purchase(amount, tokenToTrade, minAssetValue);
    }

    /**
        @notice Claim earned asset tokens (USDC).
                Transfers all asset tokens earned to date to the holder.
        @return uint256 The amount of tokens claimed.
     */
    function claimEarned() public nonReentrant returns(uint256) {
        uint256 amountToClaim = getEarnedToClaim(msg.sender);
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
    function claimPrincipal() public nonReentrant returns(uint256) {
        uint256 amountToClaim = balances[msg.sender].principalToClaim;
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
        @notice Claim earned and principal asset tokens (USDC).
                Transfers all asset tokens earned to date
                and any principal that is available to claim to the holder.
        @return uint256 The amount of tokens claimed.
     */
    function claim() external returns(uint256) {
        uint256 amountClaimed;
        if(getEarnedToClaim(msg.sender) > 0){
            amountClaimed = claimEarned();
        }
        if(getPrincipalToClaim(msg.sender) > 0){
            amountClaimed += claimPrincipal();
        }
        return amountClaimed;
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
    function purchase(uint256 amount, address tokenToTrade, uint256 minAssetValue) private returns(bool) {
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
            assetAmount = swapForAsset(amount, tokenToTrade, minAssetValue);
        }

        // If we ended up over the maxSupply amount then we will refund the extra
        // to the sender.
        uint256 refundAmount = totalSupply + assetAmount > maxSupply ? totalSupply + assetAmount - maxSupply : 0;

        // Reduce the number of asset tokens we can use by the amount we will be refunding.
        assetAmount -= refundAmount;

        // Transfer the purchased USDC to the recipient wallets.
        require(transferAssetsOut(assetAmount), 'Transferring assets out failed');

        if(refundAmount > 0){
            require(issueRefund(refundAmount), 'Refund of tokens failed');
        }

        return mint(assetAmount, msg.sender);
    }

    /**
        @notice Mint new tokens to the user. Increase totalSupply.
        @param amount The amount of tokens to mint to the user.
        @return Success boolean
     */
    function mint(uint256 amount, address receiver) private returns(bool) {
        totalSupply += amount;
        require(totalSupply <= maxSupply, 'Too many tokens minted');

        // If the recipient does not already have a principal balance or has been repaid any
        // principal then they won't be in the holder array yet. Add them to the array.
        if(balances[receiver].principal == 0 && balances[receiver].principalRepaid == 0){
            addHolder(receiver);
        }

        balances[receiver].principal += amount;
        emit Transfer(address(0), receiver, amount);

        // We have met the maxSupply amount. Set fundingAllowed to false and
        // emit the MetFundingGoal event.
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
    function swapForAsset(uint256 amount, address tokenToTrade, uint256 minAssetValue) private returns(uint256){
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
            IERC20(tokenToTrade).approve(routerAddress, amount);

            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                minAssetValue,
                asset_path_to_use,
                address(this),
                block.timestamp + 30);
        }

        // Return amount of USDC that was actually purchased.
        return IERC20(assetAddress).balanceOf(address(this)) - assetBalanceBefore;
    }

    /**
        @notice Transfers the appropriate amounts of the asset token to the receiver and
                admin addresses.
        @param assetAmount The amount of asset tokens to be transferred to the receiver and admin addresses.
        @return Success boolean
     */
    function transferAssetsOut(uint256 assetAmount) private returns(bool){
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
    function issueRefund(uint256 refundAmount) private returns(bool){
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
        @notice Returns the number of tokens purchased minus the number that have been repaid
                and the amount that is available to claim and any amount that may have been
                lost to an asset conversion (highly unlikely to ever happen).
        @param _address Address of the holder.
        @return uint256 Balance of Principal
     */
    function getBalanceOfPrincipal(address _address) public view returns(uint256){
        return balances[_address].principal - balances[_address].principalRepaid - balances[_address].principalToClaim - balances[_address].principalConversionLoss;
    }

    /**
        @notice Returns the number of tokens the holder has in principal.
                Note that there may be tokens that have been claimed or can be claimed
                that should be taken into account when looking at the holder's current
                principal amount (call getBalanceOfPrincipal).
        @param _address Address of the holder.
        @return uint256 Number of principal tokens
     */
    function getPrincipal(address _address) public view returns(uint256){
        return balances[_address].principal;
    }

    /**
        @notice Returns the number of tokens that can be claimed for principal repayment.
        @param _address Address of the holder.
        @return uint256 Balance of principal tokens that can be claimed
     */
    function getPrincipalToClaim(address _address) public view returns(uint256){
        return balances[_address].principalToClaim;
    }

    /**
        @notice Returns the amount of principal that has been repaid to date.
        @param _address Address of the holder.
        @return uint256 Amount repaid
     */
    function getPrincipalRepaid(address _address) public view returns(uint256){
        return balances[_address].principalRepaid;
    }

    /**
        @notice Returns the amount of principal that was lost due to asset conversion.
                This is highly unlikely to ever happen.
        @param _address Address of the holder.
        @return uint256 Amount of principal lost to asset conversion.
     */
    function getPrincipalConversionLoss(address _address) public view returns(uint256){
        return balances[_address].principalConversionLoss;
    }

    /**
        @notice Returns the number of tokens earned minus the number that have been repaid.
                This total is the number of earned tokens that are available to claim.
        @param _address Address of the holder.
        @return uint256 Balance of earned tokens
     */
    function getEarnedToClaim(address _address) public view returns(uint256){
        return balances[_address].earned - balances[_address].earnedRepaid;
    }

    /**
        @notice Returns the number of tokens earned to date.
        @param _address Address of the holder.
        @return uint256 Number of earned tokens
     */
    function getEarned(address _address) public view returns(uint256){
        return balances[_address].earned;
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
        @notice Returns the total amount of Principal for all holders.
                This total includes all principal that has not yet been repaid
                and has not yet been made available to claim.
        @return uint256 Total amount of outstanding Principal.
     */
    function getTotalOutstandingPrincipal() public view returns(uint256) {
        address[] memory _holders = holders;
        uint256 arrayLength = _holders.length;
        uint256 totalOutstandingPrincipal;

        // Calculate the total amounts of outstanding principal for all holders.
        for (uint256 i=0; i<arrayLength;) {
            totalOutstandingPrincipal += getBalanceOfPrincipal(_holders[i]);
            unchecked { ++i; }
        }

        return totalOutstandingPrincipal;
    }

    /**
        @notice Returns the total amount of Principal assets that are available to claim
                by all holders.
        @return uint256 Total amount of Principal available to claim
     */
    function getTotalOutstandingPrincipalToClaim() public view returns(uint256) {
        address[] memory _holders = holders;
        uint256 arrayLength = _holders.length;
        uint256 totalOutstandingPrincipalToClaim;

        // Calculate the total amounts of principal to claim for all holders.
        for (uint256 i=0; i<arrayLength;) {
            totalOutstandingPrincipalToClaim += balances[_holders[i]].principalToClaim;
            unchecked { ++i; }
        }

        return totalOutstandingPrincipalToClaim;
    }

    /**
        @notice Returns the total amount of Principal that was lost to conversion
                in the highly unlikely event that the underlying asset had to be
                changed to another asset token and there were principal amounts
                that were waiting to be claimed by the holders.
        @return uint256 Total amount of Principal lost to asset conversion
     */
    function getTotalPrincipalConversionLoss() public view returns(uint256) {
        address[] memory _holders = holders;
        uint256 arrayLength = _holders.length;
        uint256 totalPrincipalConversionLoss;

        // Calculate the total amounts of earned and principal to claim for all holders.
        for (uint256 i=0; i<arrayLength;) {
            totalPrincipalConversionLoss += balances[_holders[i]].principalConversionLoss;
            unchecked { ++i; }
        }

        return totalPrincipalConversionLoss;
    }

    /**
        @notice Returns the total amount of earned assets that are available to claim
                by all holders.
        @return uint256 Total amount of earned assets available to claim
     */
    function getTotalOutstandingEarnedToClaim() public view returns(uint256) {
        address[] memory _holders = holders;
        uint256 arrayLength = _holders.length;
        uint256 totalOutstandingEarnedToClaim;

        // Calculate the total amounts of earned to claim for all holders.
        for (uint256 i=0; i<arrayLength;) {
            totalOutstandingEarnedToClaim += getEarnedToClaim(_holders[i]);
            unchecked { ++i; }
        }

        return totalOutstandingEarnedToClaim;
    }
    /**
        @notice Internal function to deposit asset tokens (USDC) into the contract
                to be distributed to the holders.
                Called by the owner functions:
                    depositAmountForEarnedDistribution
                    depositAmountForPrincipalDistribution
                This function transfers the asset tokens to this contract and calls the
                distributeToHolders function to calculate how much each holder will receive.
        @param amount uint256 Amount of asset tokens to transfer from the owner to this contract.
        @param distributionType DistributionType Whether we are distributing for earned payments
                                or for principal repayment.
        @param holder address The address for an individual holder to distribute to.
                              If the 0 address is passed in then distribute to all holders.
        @return Success boolean
     */
    function depositAmountForDistribution(uint256 amount, DistributionType distributionType, address holder) internal returns(bool){
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

        if(holder == address(0)){
            distributeToHolders(amountToDistribute, distributionType);
        }
        else{
            distributeToSingleHolder(amountToDistribute, distributionType, holder);
        }

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
        uint256 balanceToDistribute = amountToDistribute;
        uint256 amountForDistribution;

        for (uint256 i=0; i<arrayLength;) {
            principal = getBalanceOfPrincipal(_holders[i]);
            if(principal > 0){
                amountForDistribution = principal * precision * amountToDistribute / _totalSupply / precision;
                // Ensuring there aren't any small rounding errors and we're not allocating
                // more assets to distribute than what we have available.
                amountForDistribution = amountForDistribution > balanceToDistribute ? balanceToDistribute : amountForDistribution;

                if(distributionType == DistributionType.EARNED){
                    balances[holders[i]].earned += amountForDistribution;
                }
                if(distributionType == DistributionType.PRINCIPAL){
                    balances[holders[i]].principalToClaim += amountForDistribution;
                }
                balanceToDistribute -= amountForDistribution;
            }
            unchecked { ++i; }
        }

        if(distributionType == DistributionType.PRINCIPAL){
            totalSupply -= (amountToDistribute - balanceToDistribute);
            totalPrincipalDistributed += (amountToDistribute - balanceToDistribute);
        }
    }

    /**
        @notice Distributes the given amount of asset tokens to give to one holder.
                The distribution can be for earned tokens or for principal.
        @param amountToDistribute Total number of asset tokens to distribute.
        @param distributionType Whether the distribution is for amounts earned
                                or for principal repayment.
        @param holder The holder to distribute the tokens to.
     */
    function distributeToSingleHolder(uint256 amountToDistribute, DistributionType distributionType, address holder) internal {
        uint256 principal;

        principal = getBalanceOfPrincipal(holder);
        if(principal == 0){return;}

        if(distributionType == DistributionType.EARNED){
            balances[holder].earned += amountToDistribute;
            balances[holder].earnedRepaid += amountToDistribute;
        }
        if(distributionType == DistributionType.PRINCIPAL){
            amountToDistribute = amountToDistribute > principal ? principal : amountToDistribute;
            balances[holder].principalRepaid += amountToDistribute;
            totalSupply -= amountToDistribute;
            totalPrincipalDistributed += amountToDistribute;
        }

        require(
            IERC20(assetAddress).transfer(holder, amountToDistribute),
            'Transfer of distribution amount failed'
        );

        if(distributionType == DistributionType.EARNED){
            emit DistributedEarnedAmountToHolder(holder, amountToDistribute);
        }
        if(distributionType == DistributionType.PRINCIPAL){
            emit DistributedPrincipalAmountToHolder(holder, amountToDistribute);
        }
    }

    /**
        @notice Recalculates the amount of asset tokens to give to each holder
                based on the percentage of the total tokens that they hold compared
                to the total assets held by this contract.
                This function is only called by the updateAssetAddress function
                in the highly unlikely event that the owner needs to change the underlying
                asset that is used by this contract.
                If the asset is changed then we will recaculate the amount to distribute to
                each holder based on the new asset amount held by this contract.
                This will only affect the principalToClaim and earned amounts that are
                available to claim.
     */
    function recalculateDistributionAmountsForHolders() internal {
        address[] memory _holders = holders;
        uint256 arrayLength = _holders.length;
        uint256 assetBalance = IERC20(assetAddress).balanceOf(address(this));
        uint256 balanceToDistribute = assetBalance;
        uint256 amountForDistribution;

        // Calculate the total amounts of earned and principal to claim for all holders.
        uint256 totalOutstandingPrincipalBefore = getTotalOutstandingPrincipalToClaim();
        uint256 totalPriorDistribution = getTotalOutstandingEarnedToClaim() + totalOutstandingPrincipalBefore;

        uint256 totalPrincipalDistributedBefore = totalPrincipalDistributed;

        for (uint256 i=0; i<arrayLength;) {
            if(getEarnedToClaim(_holders[i]) > 0){
                amountForDistribution = balances[_holders[i]].earned * assetBalance * precision / totalPriorDistribution / precision;
                // Ensuring there aren't any small rounding errors and we're not allocating
                // more assets to distribute than what we have available.
                amountForDistribution = amountForDistribution > balanceToDistribute ? balanceToDistribute : amountForDistribution;

                balances[holders[i]].earned = amountForDistribution;
                balanceToDistribute -= amountForDistribution;
            }
            if(balances[_holders[i]].principalToClaim > 0){
                amountForDistribution = balances[_holders[i]].principalToClaim * assetBalance * precision / totalPriorDistribution / precision;
                // Ensuring there aren't any small rounding errors and we're not allocating
                // more assets to distribute than what we have available.
                amountForDistribution = amountForDistribution > balanceToDistribute ? balanceToDistribute : amountForDistribution;

                // Account for any principal amount that was lost to the asset conversion.
                if(amountForDistribution < balances[holders[i]].principalToClaim){
                    balances[holders[i]].principalConversionLoss += balances[holders[i]].principalToClaim - amountForDistribution;
                }

                balances[holders[i]].principalToClaim = amountForDistribution;
                balanceToDistribute -= amountForDistribution;
            }
            unchecked { ++i; }
        }

        // Adjust the totalPrincipalDistributed depending on how much the outstanding principal was changed.
        uint256 totalOutstandingPrincipalAfter = getTotalOutstandingPrincipalToClaim();
        if(totalOutstandingPrincipalAfter <  totalOutstandingPrincipalBefore){
            totalPrincipalDistributed = totalPrincipalDistributedBefore - (totalPrincipalDistributedBefore - totalOutstandingPrincipalAfter);
        }
        if(totalOutstandingPrincipalAfter >  totalOutstandingPrincipalBefore){
            totalPrincipalDistributed = totalPrincipalDistributedBefore + (totalOutstandingPrincipalAfter - totalPrincipalDistributedBefore);
        }
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
        @notice Transfers ownership of the contract to another address
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
        routerAddress = newRouter;
        router = IUniswapV2Router02(newRouter);
        WBNB = router.WETH();
        emit UpdatedRouterAddress(newRouter);
    }

    /**
        @notice Updates the address for the asset to purchase (defaults to USDC)
        @param newAssetAddress The new address for the asset to purchase
                               This contract does  handle converting between decimal places if the asset
                               has a different number of decimals.
        @param minNewAssetAmount If this contract has a balance of the previous asset
                                 then the previous asset must be swapped for the new asset.
                                 The minNewAssetAmount is the minimum amount of the new asset
                                 that we should receive in the swap. DApp should calculate
                                 the correct amount and pass it in.
                                 Use getTotalOutstandingPrincipalToClaim and getTotalOutstandingEarnedToClaim
                                 to calculate how much USD is required to pay out currently claimed amounts.
        @param newAssetDecimals The number of decimals the new asset has. Must be 18!
                                This contract does  handle converting between decimal places
                                if the asset has a different number of decimals.
     */
    function updateAssetAddress(address newAssetAddress, uint256 minNewAssetAmount, uint8 newAssetDecimals) external override onlyOwner {
        require(newAssetAddress != address(0), 'Invalid asset address');
        require(newAssetDecimals == decimals, 'New asset must have the same number of decimals as this token.');

        address oldAssetAddress = assetAddress;
        assetAddress = newAssetAddress;
        uint256 assetBalanceBefore = IERC20(oldAssetAddress).balanceOf(address(this));
        if(assetBalanceBefore > 0){
            uint256 assetBalanceAfter = swapForAsset(assetBalanceBefore, oldAssetAddress, minNewAssetAmount);
            require(assetBalanceAfter >= minNewAssetAmount, 'Did not receive enough of the new asset in swap!');
            // If there was a change in the total number of assets then we have to recalculate any
            // outsanding earned amounts that haven't been claimed.
            if(assetBalanceBefore != assetBalanceAfter){
                recalculateDistributionAmountsForHolders();
            }
        }

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
        return mint(amount, receiver);
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
        totalPrincipalDistributed += amount;
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
        bool success = depositAmountForDistribution(amount, DistributionType.EARNED, address(0));
        emit DepositedAmountForEarnedDistribution(amount, address(0));
        return success;
    }

    /**
        @notice Owner function to distribute asset tokens (USDC)
                to one holder for their earned amount.
                Amount of USDC needs to be pre-approved for transfer.
        @param amount uint256 Amount of asset tokens to transfer from the owner to the holder.
        @param holder address The holder that will get the distributed asset tokens.
        @return Success boolean
     */
    function distributeEarnedAmountToHolder(uint256 amount, address holder) external onlyOwner returns(bool){
        return depositAmountForDistribution(amount, DistributionType.EARNED, holder);
    }

    /**
        @notice Owner function for the owner to deposit asset tokens (USDC) into the contract
                to be distributed to the holders as part of a principal repayment.
                Amount of USDC needs to be pre-approved for transfer.
        @param amount uint256 Amount of asset tokens to transfer from the owner to this contract.
        @return Success boolean
     */
    function depositAmountForPrincipalDistribution(uint256 amount) external onlyOwner returns(bool){
        // Don't distribute more than the total amount of outstanding principal.
        if(amount > totalSupply){
            amount = totalSupply;
        }
        bool success = depositAmountForDistribution(amount, DistributionType.PRINCIPAL, address(0));
        emit DepositedAmountForPrincipalDistribution(amount, address(0));
        return success;
    }


    /**
        @notice Owner function to distribute asset tokens (USDC)
                to one holder as part of a principal repayment.
                Amount of USDC needs to be pre-approved for transfer.
        @param amount uint256 Amount of asset tokens to transfer from the owner to the holder.
        @param holder address The holder that will get the distributed asset tokens.
        @return Success boolean
     */
    function distributePrincipalAmountToHolder(uint256 amount, address holder) external onlyOwner returns(bool){
        // Don't distribute more than the total amount of outstanding principal.
        uint256 balanceOfPrincipal = getBalanceOfPrincipal(holder);
        if(amount > balanceOfPrincipal){
            amount = balanceOfPrincipal;
        }
        return depositAmountForDistribution(amount, DistributionType.PRINCIPAL, holder);
    }

    /**
        @notice Owner function for the owner to withdraw tokens held by this contract.
                It will not allow any of the asset token (USDC) to be withdrawn that is
                being held for distribution to holders. This is just a safeguard to allow
                withdrawing of extra tokens that were sent to the contract by mistake.
        @param tokenAddress Address of the token to withdraw.
        @param amount uint256 Amount of tokens to withdraw.
        @return uint256 Number of tokens withdrawn
     */
    function withdraw(address tokenAddress, uint256 amount) external onlyOwner returns(uint256){
        uint256 balanceBefore = IERC20(tokenAddress).balanceOf(address(this));
        if(balanceBefore == 0){return 0;}

        if(tokenAddress == assetAddress){
            uint256 totalOutstanding = getTotalOutstandingPrincipalToClaim() + getTotalOutstandingEarnedToClaim();
            // If there aren't any excess tokens over and above the oustanding amount to withdraw
            // then don't withdraw any. Return 0.
            if(balanceBefore <= totalOutstanding){return 0;}

            // Don't allow withdrawing more than the amount of asset tokens that are currently
            // owed to the holders and pending their claim.
            amount = balanceBefore - totalOutstanding < amount ? balanceBefore - totalOutstanding : amount;
        }

        require(
            IERC20(tokenAddress).transfer(msg.sender, amount),
            'Transfer of tokens failed'
        );

        uint256 balanceAfterTransfer = IERC20(tokenAddress).balanceOf(address(this));
        uint256 amountTransferred = balanceBefore - balanceAfterTransfer;

        emit Withdrew(msg.sender, tokenAddress, amountTransferred);
        return amountTransferred;
    }


    /////////////////////////////////////
    //////   PAYABLE FUNCTIONS    ///////
    /////////////////////////////////////
    /**
        @notice Default payable function. Purchases tokens with WBNB transferred.
     */
    receive() external payable nonReentrant{
        purchase(msg.value, WBNB, 0);
    }

    /**
        @notice purchaseToken function. Payable function with minAssetValue parameter.
        @param minAssetValue uint256 Minimum amount of the asset token to purchase (USDC).
                Allows the user to determine how much slippage is acceptable.
                Make sure to include 18 decimals!
        @return Success boolean
     */
    function purchaseTokens(uint256 minAssetValue) external payable nonReentrant returns(bool) {
        return purchase(msg.value, WBNB, minAssetValue);
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
    function claimEarned() external returns(uint256);
    function claimPrincipal() external returns(uint256);
    function depositAmountForEarnedDistribution(uint256 amount) external returns(bool);
    function depositAmountForPrincipalDistribution(uint256 amount) external returns(bool);
    function distributeEarnedAmountToHolder(uint256 amount, address holder) external returns(bool);
    function distributePrincipalAmountToHolder(uint256 amount, address holder) external returns(bool);
    function offChainPrincipalClaim(uint256 amount, address holder) external returns(uint256);
    function offChainPurchase(uint256 amount, address receiver) external returns(bool);
    function purchaseTokens(uint256 minAssetValue) external payable returns(bool);
    function purchaseTokensWithOtherToken(uint256 amount, address tokenToTrade, uint256 minAssetValue) external returns(bool);
    function transferOwnership(address newOwner) external;
    function updateAdminAddress(address newAdminAddress) external;
    function updateAssetAddress(address newAssetAddress, uint256 minNewAssetAmount, uint8 newAssetDecimals) external;
    function updateAuthorized(address _address, bool _isAuthorized) external;
    function updateFundingAllowed(bool _fundingAllowed) external;
    function updateMaxSupply(uint256 newMaxSupply) external;
    function updateReceiverAddress(address newReceiverAddress) external;
    function updateRouterAddress(address newRouter) external;
    function withdraw(address tokenAddress, uint256 amount) external returns(uint256);
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
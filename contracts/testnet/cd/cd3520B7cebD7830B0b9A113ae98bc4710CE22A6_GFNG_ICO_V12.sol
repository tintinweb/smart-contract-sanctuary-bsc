/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

contract GFNG_ICO_V12 {

   address public owner;
   IERC20 public token = IERC20(0x8f49d9B66A9886da9c1E383E12cF18a90aefD818);

   // The wallet that holds the Wei raised on the crowdsale
   address public wallet = 0x43E575D5b291a00F692db3227d6fa6fA64C22386;

   // The rate of tokens per ether. Only applied for the first tier, the first
   // 1 million tokens sold (0,00005 BNB ~ 0,01)
   uint256 public rate = 50000 gwei;

   // The rate of tokens per ether. Only applied for the second tier, at between
   // 1 million tokens sold and 1.5 million tokens sold (0,000075 BNB ~ 0,015)
   uint256 public rateTier2  = 75000 gwei;

   // The rate of tokens per ether. Only applied for the third tier, at between
   // 1.5 million tokens sold and 2 million tokens sold (0,00005 BNB ~ 0,02)
   uint256 public rateTier3  = 100000 gwei;

   // The maximum amount of wei for each tier
   //1 M
   uint256 public limitTier1 = 1e24;
   //1.5 M
   uint256 public limitTier2 = 15e23;

// The amount of wei raised
   uint256 public weiRaised = 0;

   // The amount of tokens raised
   uint256 public tokensRaised = 0;

   // You can only buy up to 2 M tokens during the ICO
   uint256 public constant maxTokensRaised = 2e24;

   // The minimum amount of Wei you must pay to participate in the crowdsale (0.05BNB)
   uint256 public constant minPurchase = 50000 gwei; 

   // The max amount of Wei that you can pay to participate in the crowdsale (0.5BNB)
   uint256 public constant maxPurchase = 500000 gwei;

   // Minimum amount of tokens to be raised. 1 million tokens which is the 15%
   // of the total of 50 million tokens sold in the crowdsale
   // 7.5e6 + 1e18
   uint256 public constant minimumGoal = 1e24;

  // If the crowdsale has ended or not
   bool public isEnded = false;

   // The number of transactions
   uint256 public numberOfTransactions;

   // The gas price to buy tokens must be 27050 gwei or below
   uint256 public limitGasPrice = 15 gwei;

   // How much each user paid for the crowdsale
   mapping(address => uint256) public crowdsaleBalances;

   // How many tokens each user got for the crowdsale
   mapping(address => uint256) public tokensBought;

   // To indicate who purchased what amount of tokens and who received what amount of wei
   event TokenPurchase(address indexed buyer, uint256 value, uint256 amountOfTokens);

   // Indicates if the crowdsale has ended
   event Finalized();
   
   /// @notice Constructor of the crowsale to set up the main variables and create a token
   /// @param _wallet The wallet address that stores the Wei raised
   /// @param _tokenAddress The token used for the ICO
   function Crowdsale(
      address _wallet,
      address _tokenAddress
   ) public {
      require(_wallet != address(0));
      require(_tokenAddress != address(0));

      wallet = _wallet;
      token = IERC20(_tokenAddress);
   }

   /// @notice Fallback function to buy tokens
   fallback () external payable {
      buyTokens();
   }

    receive() external payable{
      uint256 amountPaid = calculateExcessBalance();
      payable(wallet).transfer(amountPaid);
    } 

   /// @notice To buy tokens given an address
   function buyTokens() public payable {
      require(validPurchase());

      uint256 tokens = 0;
      
      uint256 amountPaid = calculateExcessBalance();

      if(tokensRaised < limitTier1) {

         // Tier 1
         tokens = amountPaid * rate;

         // If the amount of tokens that you want to buy gets out of this tier
         if(tokensRaised + tokens > limitTier1)
            tokens = calculateExcessTokens(amountPaid, limitTier1, 1, rate);
      } else if(tokensRaised >= limitTier1 && tokensRaised < limitTier2) {

         // Tier 2
         tokens = amountPaid * rateTier2;

         // If the amount of tokens that you want to buy gets out of this tier
         if(tokensRaised + tokens > limitTier2)
            tokens = calculateExcessTokens(amountPaid, limitTier2, 2, rateTier2);
      } else {

         // Tier 3
         tokens = amountPaid * rateTier3;
      } 

      weiRaised = weiRaised + amountPaid;
      tokensRaised = tokensRaised + tokens;
      token.transfer(msg.sender, tokens);

      // Keep a record of how many tokens everybody gets in case we need to do refunds
      tokensBought[msg.sender] = tokensBought[msg.sender] + tokens;
      emit TokenPurchase(msg.sender, amountPaid, tokens);
      numberOfTransactions = numberOfTransactions + 1;
      payable(wallet).transfer(amountPaid);
      
      // If the minimum goal of the ICO has been reach, close the vault to send
      // the ether to the wallet of the crowdsale
      checkCompletedCrowdsale();
   }

   /// @notice Calculates how many ether will be used to generate the tokens in
   /// case the buyer sends more than the maximum balance but has some balance left
   /// and updates the balance of that buyer.
   /// For instance if he's 500 balance and he sends 1000, it will return 500
   /// and refund the other 500 ether
   function calculateExcessBalance() internal returns(uint256) {
      uint256 amountPaid = msg.value;
      uint256 differenceWei = 0;
      uint256 exceedingBalance = 0;

      // If we're in the last tier, check that the limit hasn't been reached
      // and if so, refund the difference and return what will be used to
      // buy the remaining tokens
      if(tokensRaised >= limitTier2) {
         uint256 addedTokens = tokensRaised + (amountPaid * rateTier3);

         // If tokensRaised + what you paid converted to tokens is bigger than the max
         if(addedTokens > maxTokensRaised) {

            // Refund the difference
            uint256 difference = addedTokens - maxTokensRaised;
            differenceWei = difference / rateTier3;
            amountPaid = amountPaid - differenceWei;
         }
      }

      uint256 addedBalance = crowdsaleBalances[msg.sender] + amountPaid;

      // Checking that the individual limit per user is not reached
      if(addedBalance <= maxPurchase) {
         crowdsaleBalances[msg.sender] = crowdsaleBalances[msg.sender] + amountPaid;
      } else {

         // Substracting 1000 ether in wei
         exceedingBalance = addedBalance - maxPurchase;
         amountPaid = amountPaid - exceedingBalance;

         // Add that balance to the balances
         crowdsaleBalances[msg.sender] = crowdsaleBalances[msg.sender] + amountPaid;
      }

      // Make the transfers at the end of the function for security purposes
      if(differenceWei > 0)
         payable(msg.sender).transfer(differenceWei);

      if(exceedingBalance > 0) {

         // Return the exceeding balance to the buyer
         payable(msg.sender).transfer(exceedingBalance);
      }

      return amountPaid;
   }

   /// @notice Check if the crowdsale has ended and enables refunds only in case the
   /// goal hasn't been reached
   function checkCompletedCrowdsale() public {
      if(!isEnded) {
         if(hasEnded()){
            isEnded = true;
            emit Finalized();
         } else if(hasEnded()  && goalReached()) {
            
            
            isEnded = true; 


            // Burn token only when minimum goal reached and maxGoal not reached. 
            if(tokensRaised < maxTokensRaised) {

               payable(wallet).transfer(maxTokensRaised - tokensRaised);

            } 

            emit Finalized();
         } 
         
         
      }
   }


   /// @notice Buys the tokens for the specified tier and for the next one
   /// @param amount The amount of ether paid to buy the tokens
   /// @param tokensThisTier The limit of tokens of that tier
   /// @param tierSelected The tier selected
   /// @param _rate The rate used for that `tierSelected`
   /// @return totalTokens The total amount of tokens bought combining the tier prices
   function calculateExcessTokens(
      uint256 amount,
      uint256 tokensThisTier,
      uint256 tierSelected,
      uint256 _rate
   ) public returns(uint256 totalTokens) {
      require(amount > 0 && tokensThisTier > 0 && _rate > 0);
      require(tierSelected >= 1 && tierSelected <= 3);

      uint weiThisTier = tokensThisTier - (tokensRaised / _rate);
      uint weiNextTier = amount - weiThisTier;
      uint tokensNextTier = 0;
      bool returnTokens = false;

      // If there's excessive wei for the last tier, refund those
      if(tierSelected != 3)
         tokensNextTier = calculateTokensTier(weiNextTier, tierSelected + 1);
      else
         returnTokens = true;

      totalTokens = tokensThisTier - tokensRaised + tokensNextTier;

      // Do the transfer at the end
      if(returnTokens) payable(msg.sender).transfer(weiNextTier);
   }

   /// @notice Buys the tokens given the price of the tier one and the wei paid
   /// @param weiPaid The amount of wei paid that will be used to buy tokens
   /// @param tierSelected The tier that you'll use for thir purchase
   /// @return calculatedTokens Returns how many tokens you've bought for that wei paid
   function calculateTokensTier(uint256 weiPaid, uint256 tierSelected)
        internal view returns(uint256 calculatedTokens)
   {
      require(weiPaid > 0);
      require(tierSelected >= 1 && tierSelected <= 3);

      if(tierSelected == 1)
         calculatedTokens = weiPaid * rate;
      else if(tierSelected == 2)
         calculatedTokens = weiPaid * rateTier2;
      else
         calculatedTokens = weiPaid * rateTier3;
   }


   /// @notice Checks if a purchase is considered valid
   /// @return bool If the purchase is valid or not
   function validPurchase() internal view returns(bool) {
      bool nonZeroPurchase = msg.value > 0;
      bool withinTokenLimit = tokensRaised < maxTokensRaised;
      bool minimumPurchase = msg.value >= minPurchase;
      bool hasBalanceAvailable = crowdsaleBalances[msg.sender] < maxPurchase;

      // We want to limit the gas to avoid giving priority to the biggest paying contributors
      //bool limitGas = tx.gasprice <= limitGasPrice;

      return nonZeroPurchase && withinTokenLimit && minimumPurchase && hasBalanceAvailable;
   }

   /// @notice To see if the minimum goal of tokens of the ICO has been reached
   /// @return bool True if the tokens raised are bigger than the goal or false otherwise
   function goalReached() public view returns(bool) {
      return tokensRaised >= minimumGoal;
   }

   /// @notice Public function to check if the crowdsale has ended or not
   function hasEnded() public view returns(bool) {
      return tokensRaised >= maxTokensRaised;
   }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import './SafeMath.sol';
import './SafeERC20.sol';
import './Pausable.sol';
import './Ownable.sol';

contract CrocoMain is Context, Ownable, Pausable
{
   using SafeMath for uint256;
   using SafeERC20 for IERC20;

   struct Deposit
   {
      uint256 initAmount;
      uint256 amount;
      uint256 createTime;
      uint256 bonusLastPaymentTime;
      uint256 bodyLastPaymentTime;
   }

   // address of the ERC20 token
   IERC20 public token;
   // CROCO token
   IERC20 immutable public crocoToken;

   uint256 public amountForPurchasing; // available CROCO amount for purchasing
   uint256 public amountForBonuses; // available CROCO amount to pay staking fees
   uint32 public bonusDayPercent = 20; // for daily payments on deposits
   
   uint32 public depoBodyPercent = 10;
   /**
    * number of seconds in 13 30-day months. After this period deposit becomes available
    * for "body-payments" each 'depoPeriod' in quantity of 'depoBodyPercent'
    */
   uint32 public depoMandatoryPeriod = 33696000;
   // for periodically payments after 'depoMandatoryPeriod'
   uint32 public depoPeriod = 2592000; // seconds in 1 30-day month
   
   // exchange rate, CROCO <-> token
   uint256 public crocosForTokens;
   
   // user->deposits
   mapping(address => Deposit[]) public deposits;

   constructor()
   {
      // token (USDT)
      token = IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);

      // CROCO token
      crocoToken = IERC20(0xDa84a73eF7FE8adFbE428aEF8bc93095145d4593);
   }

   receive() external payable { }
   fallback() external payable { }

   // --------------------------------------------

   function _removeDeposit(address user, uint32 index) internal
   {
      if (deposits[user].length == 0) { return; }
      if (index >= deposits[user].length) { return; }

      for (uint i = index; i < deposits[user].length - 1; i++) {
         deposits[user][i] = deposits[user][i+1];
      }
      deposits[user].pop();
   }

   function _addDeposit(address user, uint256 amount_) internal
   {
      uint256 currentTime = getCurrentTime();

      Deposit memory depo = Deposit(
      {
         initAmount: amount_
         , amount: amount_
         , createTime: currentTime
         , bonusLastPaymentTime: currentTime
         , bodyLastPaymentTime: 0
      });
      deposits[user].push(depo);
   }

   function purchaseCroco(uint256 tokenAmount) external
   {
      address recipient = msg.sender;

      require(tokenAmount > 0, "CrocoMain::purchaseCroco(): tokenAmount_ must be > 0");
      uint256 crocoAmount = tokenAmount.mul(crocosForTokens);
      require(crocoAmount >= amountForPurchasing, "CrocoMain::purchaseCroco(): not enought amountForPurchasing");
       
      token.safeTransferFrom(recipient, owner(), tokenAmount);

      // put into staking
      _addDeposit(recipient, crocoAmount);
      amountForPurchasing = amountForPurchasing.sub(crocoAmount);
   }

   function putIntoStaking(uint256 crocoAmount) external
   {
      require(crocoAmount > 0, "CrocoMain::putIntoStaking(): crocoAmount must be > 0");

      address user = msg.sender;
      crocoToken.safeTransferFrom(user, owner(), crocoAmount);
      _addDeposit(user, crocoAmount);
   }

   function claimBonuses() external whenNotPaused
   {
      address user = msg.sender;
      require(deposits[user].length > 0, "CrocoMain::claimBonuses(): deposits not exist");

      uint256 currentTime = getCurrentTime();

      uint256 amountToPay = 0;
      for (uint32 i = 0; i < deposits[user].length; i++)
      {
         // Deposit is empty
         if (deposits[user][i].amount == 0)
         {
            _removeDeposit(user, i);
            i = 0;
            continue;
         }

         Deposit storage depo = deposits[user][i];         
         if ( (currentTime - depo.bonusLastPaymentTime) >= 1 days)
         {
            amountToPay = amountToPay.add(depo.amount.div(100).mul(bonusDayPercent));
            depo.bonusLastPaymentTime = currentTime;
         }
      }

      require(amountToPay > 0, "CrocoMain::claimBonuses(): nothing to claim");
      require(amountForBonuses >= amountToPay, "CrocoMain::claimBonuses(): not enought 'amountForBonuses'");

      amountForBonuses = amountForBonuses.sub(amountToPay);
      crocoToken.safeTransferFrom(owner(), user, amountToPay);
   }

   function claimDepositBodies() external whenNotPaused
   {
      address user = msg.sender;
      require(deposits[user].length > 0, "CrocoMain::claimDepositBodies(): deposits not exist");

      uint256 currentTime = getCurrentTime();

      for (uint32 i = 0; i < deposits[user].length; i++)
      {
         if (deposits[user][i].amount > 0)
         {
            Deposit memory depo = deposits[user][i];         
            if ( (currentTime - depo.bonusLastPaymentTime) >= 1 days)
            {
               require( (depo.amount.div(100).mul(bonusDayPercent)) > 0,
                  "CrocoMain::claimDepositBodies(): you have unclaimed bonuses. Should call 'claimBonuses()' first");
            }
         }
      }

      uint256 amountToPay = 0;
      for (uint32 i = 0; i < deposits[user].length; i++)
      {
         // Deposit is empty
         if (deposits[user][i].amount == 0)
         {
            _removeDeposit(user, i);
            i = 0;
            continue;
         }

         // check deposit's mandatory period
         if ( (currentTime - deposits[user][i].createTime) <= depoMandatoryPeriod) { continue; }

         Deposit storage depo = deposits[user][i];
         uint16 coeff = 0;
         if (depo.bodyLastPaymentTime > 0) {
            coeff = uint16((currentTime - depo.bodyLastPaymentTime) / depoPeriod);
         }
         // depo.bodyLastPaymentTime == 0, so it is the first payment
         else {
            coeff = uint16((currentTime - depo.createTime - depoMandatoryPeriod) / depoPeriod);
         }
         if (coeff == 0) { continue; }

         uint256 amount = depo.amount.div(100).mul(depoBodyPercent).mul(coeff);
         if (amount > depo.amount) {
            amount = depo.amount;
         }

         amountToPay = amountToPay.add(amount);
         depo.amount = depo.amount.sub(amount);
         depo.bodyLastPaymentTime = currentTime;
      }

      require(amountToPay > 0, "CrocoMain::claimDepositBodies(): nothing to claim");
      crocoToken.safeTransferFrom(owner(), user, amountToPay);
   }

   // --------------------------------------------

   function pause() external onlyOwner whenNotPaused {
      _pause();
   }

   function unpause() external onlyOwner whenPaused {
      _unpause();
   }

   /**
    * @dev Returns the address of the ERC20 token managed by this contract
    */
   function getToken() external view returns(address) {
      return address(token);
   }

   function getContranctBalance() external view returns(uint256) {
      return address(this).balance;
   }

   function getCurrentTime() internal view returns(uint256) {
      return block.timestamp;
   }

   function setTokenAddress(address tokenAddress) external onlyOwner {
       token = IERC20(tokenAddress);
   }

   function setBonusDayPercent(uint32 dayPercent) external onlyOwner
   {
      require((dayPercent > 0) && (dayPercent <= 100), "CrocoMain: dayPercent must be > 0 and <= 100");
      bonusDayPercent = dayPercent;
   }

   function addAmountForPuchasing(uint256 amount) external onlyOwner {
       amountForPurchasing = amountForPurchasing.add(amount);
   }

   function addAmountForStakingBonuses(uint256 amount) external onlyOwner {
       amountForBonuses = amountForBonuses.add(amount);
   }

   function setDepositMandatoryPeriod(uint32 duration) external onlyOwner {
       depoMandatoryPeriod = duration;
   }

   function setDepositPeriod(uint32 duration) external onlyOwner {
       depoPeriod = duration;
   }

} // contract CrocoMain
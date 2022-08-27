// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

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
   IERC20 public _token;
   // CROCO token
   IERC20 immutable public _crocoToken;

   uint256 public _amountForPurchasing; // available CROCO amount for purchasing
   uint256 public _amountForBonuses; // available CROCO amount to pay staking fees
   uint32 public _bonusDayPercent = 20; // for daily payments on deposits
   
   uint32 public _depoBodyPercent = 10;
   /**
    * number of seconds in 13 30-day months. After this period deposit becomes available
    * for "body-payments" each 'depoPeriod' in quantity of '_depoBodyPercent'
    */
   uint32 public _depoMandatoryPeriod = 33696000;
   // for periodically payments after '_depoMandatoryPeriod'
   uint32 public _depoPeriod = 2592000; // seconds in 1 30-day month
   
   // exchange rate, CROCO <-> token
   uint256 public _crocosForTokens;
   
   // user->user_deposits
   mapping(address => Deposit[]) public _deposits;
   address[] public _users; // for iterating over the '_deposits' if needed

   constructor()
   {
      // token (USDT)
      _token = IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);

      // CROCO token
      _crocoToken = IERC20(0xDa84a73eF7FE8adFbE428aEF8bc93095145d4593);
   }

   receive() external payable { }
   fallback() external payable { }

   // --------------------------------------------

   function _removeDeposit(address user, uint32 index) internal
   {
      Deposit[] storage depos = _deposits[user];

      if (depos.length == 0) { return; }
      if (index >= depos.length) { return; }

      for (uint i = index; i < depos.length - 1; i++) {
         depos[i] = depos[i + 1];
      }
      depos.pop();
   }

   function _clearEmptyDeposits(address user) internal
   {
      // clear empty _deposits
      for (int32 i = 0; i < int32(int256(_deposits[user].length)); i++)
      {
         uint32 uidx = uint32(i); 

         // Deposit is empty
         if (_deposits[user][uidx].amount == 0)
         {
            _removeDeposit(user, uidx);
            i = -1;
            continue;
         }
      }
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
      _deposits[user].push(depo);
      
      // add user address if not exists
      bool found = false;
      for (uint i = 0; i< _users.length; ++i)
      {
         if (_users[i] == user)
         {
            found = true;
            break;
         }
      }
      if (!found) {
         _users.push(user);
      }
   }

   function purchaseCroco(uint256 tokenAmount) external whenNotPaused
   {
      address sender = msg.sender;

      require(tokenAmount > 0, "CrocoMain::purchaseCroco(): tokenAmount_ must be > 0");
      uint256 crocoAmount = tokenAmount.mul(_crocosForTokens);
      require(crocoAmount >= _amountForPurchasing, "CrocoMain::purchaseCroco(): not enought _amountForPurchasing");
       
      _token.safeTransferFrom(sender, owner(), tokenAmount);
      _crocoToken.safeTransferFrom(owner(), sender, tokenAmount);
   }

   function putIntoStaking(uint256 crocoAmount) external whenNotPaused
   {
      require(crocoAmount > 0, "CrocoMain::putIntoStaking(): crocoAmount must be > 0");

      address user = msg.sender;
      _crocoToken.safeTransferFrom(user, owner(), crocoAmount);
      _addDeposit(user, crocoAmount);
   }

   function claimBonuses() external whenNotPaused
   {
      address user = msg.sender;
      require(_deposits[user].length > 0, "CrocoMain::claimBonuses(): _deposits not exist");

      uint256 currentTime = getCurrentTime();

      uint256 amountToPay = 0;
      for (uint32 i = 0; i < _deposits[user].length; i++)
      {
         Deposit storage depo = _deposits[user][i];
         if (depo.amount == 0) { continue; }

         if ( (currentTime - depo.bonusLastPaymentTime) >= 1 days)
         {
            amountToPay = amountToPay.add(depo.amount.div(100).mul(_bonusDayPercent));
            depo.bonusLastPaymentTime = currentTime;
         }
      }

      require(amountToPay > 0, "CrocoMain::claimBonuses(): nothing to claim");
      require(_amountForBonuses >= amountToPay, "CrocoMain::claimBonuses(): not enought '_amountForBonuses'");

      _amountForBonuses = _amountForBonuses.sub(amountToPay);
      _crocoToken.safeTransferFrom(owner(), user, amountToPay);

      _clearEmptyDeposits(user);
   }

   function claimDepositBodies() external whenNotPaused
   {
      address user = msg.sender;
      require(_deposits[user].length > 0, "CrocoMain::claimDepositBodies(): _deposits not exist");

      uint256 currentTime = getCurrentTime();

      for (uint32 i = 0; i < _deposits[user].length; i++)
      {
         Deposit memory depo = _deposits[user][i];
         if (depo.amount > 0)
         {
            if ( (currentTime - depo.bonusLastPaymentTime) >= 1 days)
            {
               require( (depo.amount.div(100).mul(_bonusDayPercent)) > 0,
                  "CrocoMain::claimDepositBodies(): you have unclaimed bonuses. Should call 'claimBonuses()' first");
            }
         }
      }

      uint256 amountToPay = 0;
      for (uint32 i = 0; i < _deposits[user].length; i++)
      {
         Deposit storage depo = _deposits[user][i];
         if (depo.amount == 0) { continue; }

         // check deposit's mandatory period
         if ( (currentTime - depo.createTime) <= _depoMandatoryPeriod) { continue; }

         uint16 coeff = 0;
         if (depo.bodyLastPaymentTime > 0) {
            coeff = uint16((currentTime - depo.bodyLastPaymentTime) / _depoPeriod);
         }
         // depo.bodyLastPaymentTime == 0, so it is the first payment
         else {
            coeff = uint16((currentTime - depo.createTime - _depoMandatoryPeriod) / _depoPeriod);
         }
         if (coeff == 0) { continue; }

         uint256 amount = depo.amount.div(100).mul(_depoBodyPercent).mul(coeff);
         if (amount > depo.amount) {
            amount = depo.amount;
         }

         amountToPay = amountToPay.add(amount);
         depo.amount = depo.amount.sub(amount);
         depo.bodyLastPaymentTime = currentTime;
      }

      require(amountToPay > 0, "CrocoMain::claimDepositBodies(): nothing to claim");
      _crocoToken.safeTransferFrom(owner(), user, amountToPay);

      _clearEmptyDeposits(user);
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
      return address(_token);
   }

   function getContranctBalance() external view returns(uint256) {
      return address(this).balance;
   }

   function getCurrentTime() internal view returns(uint256) {
      return block.timestamp;
   }
   
   function getUserCount() public view returns (uint) {
      return _users.length;
   }

   function setTokenAddress(address tokenAddress) external onlyOwner {
       _token = IERC20(tokenAddress);
   }

   function setDepoBodyPercent(uint32 percent_) external onlyOwner
   {
      require((percent_ > 0) && (percent_ <= 100), "CrocoMain: _depoBodyPercent must be > 0 and <= 100");
      _depoBodyPercent = percent_;
   }

   function setBonusDayPercent(uint32 percent_) external onlyOwner
   {
      require((percent_ > 0) && (percent_ <= 100), "CrocoMain: _bonusDayPercent must be > 0 and <= 100");
      _bonusDayPercent = percent_;
   }

   function addAmountForPuchasing(uint256 amount) external onlyOwner {
       _amountForPurchasing = _amountForPurchasing.add(amount);
   }

   function addAmountForStakingBonuses(uint256 amount) external onlyOwner {
       _amountForBonuses = _amountForBonuses.add(amount);
   }

   function setDepositMandatoryPeriod(uint32 duration) external onlyOwner {
       _depoMandatoryPeriod = duration;
   }

   function setDepositPeriod(uint32 duration) external onlyOwner {
       _depoPeriod = duration;
   }

} // contract CrocoMain
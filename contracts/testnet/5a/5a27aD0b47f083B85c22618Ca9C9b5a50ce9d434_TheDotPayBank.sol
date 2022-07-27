// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

 import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
 import '@openzeppelin/contracts/utils/Context.sol';
 import './interfaces/ITheDotPayBank.sol';
 import './interfaces/IMerchant.sol';
 import './Merchant.sol';


/// @title TheDotPayBank Contract
/// @author Ram Krishan Pandey
/// @dev This Contract is governed by TheDotPayBank owner
contract TheDotPayBank is ITheDotPayBank,Context {

   address private _theDotPayBankOwner;
   uint256 private immutable _SHARING_CLIFF_VALUE; 
   mapping(address=>bool) private _verifierStatus;

    error InSufficientBalanceError();
    error InSufficientAllowanceError();
    error UnExpectedSharePercentage();
    error UnauthorisedAccess();



    modifier isContractOwner(){
        if(_msgSender()!=_theDotPayBankOwner)
          revert UnauthorisedAccess();
        _;  
    }

    modifier isVerifier(){
        if(_verifierStatus[_msgSender()]!=true)
          revert UnauthorisedAccess();
        _;  
    }

   event AddMerchant(address indexed merchantOwnerAddress_,uint256 indexed currentShare_,uint256 sharingCliffValue_,address indexed merchantContractAddress);
   event BlockMerchant(address indexed merchantContractAddress_,address indexed verifier_);
   event UnBlockMerchant(address indexed merchantContractAddress_,address indexed verifier_);
   event SetCurrentShare(address indexed merchantContractAddress_,uint256 indexed newShare_,address indexed verifier_);
   event AddVerifier(address indexed verifierAddress_);
   event RemoveVerifier(address indexed verifierAddress_);
   event WithdrawBNB(uint indexed amount_);
   event WithdrawTokens(address indexed tokenAddress_, uint256 indexed amount_);
   event TransferOwnerShip(address oldOwnerAddress_,address newOwnerAddress_);
   event PayWithToken(address indexed tokenAddress_,address indexed merchantContractAddress_,uint256 indexed tokenAmount_);
   event PayWithBNB(address indexed merchantContractAddress_,uint256 indexed amount_);

   constructor(address owner_,uint256 sharingCliffValue_){
       _theDotPayBankOwner=owner_;
       _SHARING_CLIFF_VALUE=sharingCliffValue_;

    }

   function getTheDotPayBankAddress() external view returns(address){
    return(address(this));
   }

   function getTheDotPayBankOwner() external view returns(address){
      return(_theDotPayBankOwner);
   }

   function getMerchantOwner(address merchantContractAddress_) external returns(address){
      IMerchant merchant=IMerchant(merchantContractAddress_);
      return(merchant.getContractOwner());
   }
   
   function getBNBBalance() external view returns(uint256){
    return(address(this).balance);
   }

   function getMerchantBNBBalance(address merchantContractAddress_) external view returns(uint256){
      return((merchantContractAddress_).balance);
   }

   function getTokenBalance(address tokenAddress_) external view returns(uint256){
      IERC20 token=IERC20(tokenAddress_);
      return(token.balanceOf(address(this)));
   }

   function getMerchantTokenBalance(address merchantContractAddress_,address tokenAddress_) external view returns(uint256){
      IERC20 token=IERC20(tokenAddress_);
      return(token.balanceOf(merchantContractAddress_));
   }

   function getCurrentShare(address merchantContractAddress_) external returns(uint256){
       IMerchant merchant=IMerchant(merchantContractAddress_);
       return(merchant.getCurrentShare());
   }

   function getSharingCliffValue(address merchantContractAddress_) external returns(uint256){
       IMerchant merchant=IMerchant(merchantContractAddress_);
       return(merchant.getSharingCliffValue());
   }

   function getMerchantStatus(address merchantContractAddress_) external returns(bool){
       IMerchant merchant=IMerchant(merchantContractAddress_);
       return(merchant.getCurrentStatus());
   }

   function getVerifierStatus(address verifierAddress_) external view returns(bool){
      return(_verifierStatus[verifierAddress_]);
   }

   function addMerchant(address merchantOwnerAddress_,uint256 currentShare_,uint256 sharingCliffValue_) external isVerifier returns(address){
      Merchant merchant=new Merchant(merchantOwnerAddress_,address(this),currentShare_,sharingCliffValue_);
      emit AddMerchant(merchantOwnerAddress_, currentShare_, sharingCliffValue_, address(merchant));
      return (address(merchant));
   }

   function blockMerchant(address merchantContractAddress_) external isVerifier returns(bool){
      IMerchant merchant =IMerchant(merchantContractAddress_);
      merchant.setCurrentStatus(true);
      emit BlockMerchant(merchantContractAddress_, _msgSender());
      return(true);
   }

    function unBlockMerchant(address merchantContractAddress_) external isVerifier returns(bool){
      IMerchant merchant =IMerchant(merchantContractAddress_);
      merchant.setCurrentStatus(false);
      emit UnBlockMerchant(merchantContractAddress_,_msgSender());
      return(true);
    }

   function setCurrentShare(address merchantContractAddress_,uint256 newShare_) external isVerifier returns(bool){
      if(newShare_>_SHARING_CLIFF_VALUE)
        revert  UnExpectedSharePercentage();
      IMerchant merchant =IMerchant(merchantContractAddress_);
      merchant.setCurrentShare(newShare_);
      emit SetCurrentShare(merchantContractAddress_, newShare_,_msgSender());
      return(true);
   }

   function addVerifier(address verifierAddress_) external isContractOwner returns(bool){
      _verifierStatus[verifierAddress_]=true;
      emit AddVerifier(verifierAddress_);
      return(true);
   }

   function removeVerifier(address verifierAddress_) external isContractOwner returns(bool){
     _verifierStatus[verifierAddress_]=false;
     emit RemoveVerifier(verifierAddress_);
     return(true);
   }

   function withdrawBNB(uint amount_) external isContractOwner returns(bool){
      if(address(this).balance<amount_)
      revert InSufficientBalanceError();
      (payable(_theDotPayBankOwner)).transfer(amount_);
      emit WithdrawBNB(amount_);
      return(true);
   }

   function withdrawTokens(address tokenAddress_, uint256 amount_) external isContractOwner returns(bool){
      IERC20 token=IERC20(tokenAddress_);
      if(token.balanceOf(address(this))<amount_)
       revert InSufficientBalanceError();

      token.transfer(_theDotPayBankOwner, amount_); 
      emit WithdrawTokens(tokenAddress_, amount_);
      return(true);
   }

   function transferOwnerShip(address newOwnerAddress_) external isContractOwner returns(bool){
      emit TransferOwnerShip(_theDotPayBankOwner, newOwnerAddress_);
      _theDotPayBankOwner=newOwnerAddress_;
      return(true);
   }


   function payWithToken(address tokenAddress_,address merchantContractAddress_,uint256 tokenAmount_) external returns(bool){
      IERC20 token = IERC20(tokenAddress_);
      if(token.balanceOf(_msgSender())<tokenAmount_)
        revert InSufficientBalanceError();
      if(token.allowance(_msgSender(), address(this))<tokenAmount_)
        revert InSufficientBalanceError();  

      IMerchant merchant = IMerchant(merchantContractAddress_);
      uint256 theDotPaySharePercentage=merchant.getCurrentShare();
      uint256 merchantShare=(tokenAmount_)*(100e18-theDotPaySharePercentage)/(100e18);
      uint256 theDotPayShare=(tokenAmount_)*(theDotPaySharePercentage)/(100e18);  

      token.transferFrom(_msgSender(), merchantContractAddress_, merchantShare);  
      token.transferFrom(_msgSender(), address(this), theDotPayShare);  
      emit PayWithToken(tokenAddress_, merchantContractAddress_, tokenAmount_);
      return true;
   }

   function payWithBNB(address merchantContractAddress_) payable external returns(bool){
      IMerchant merchant = IMerchant(merchantContractAddress_);
      uint256 theDotPaySharePercentage=merchant.getCurrentShare();
      uint256 merchantShare=(msg.value)*(100e18-theDotPaySharePercentage)/(100e18);
      uint256 theDotPayShare=(msg.value)*(theDotPaySharePercentage)/(100e18);
      (payable(merchantContractAddress_)).transfer(merchantShare);
      (payable(address(this))).transfer(theDotPayShare);
      emit PayWithBNB(merchantContractAddress_, msg.value);
      return(true);
   }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/// @title TheDotPay`s Inerface
/// @author Ram Krishan Pandey
/// @notice Interface of TheDotPay
/// @dev Interface can be used to view features of TheDotPay
interface ITheDotPayBank
{

   function getTheDotPayBankAddress() external returns(address);

   function getTheDotPayBankOwner() external returns(address);

   function getMerchantOwner(address merchantContractAddress_) external returns(address);
   
   function getBNBBalance() external returns(uint256);

   function getMerchantBNBBalance(address merchantContractAddress_) external returns(uint256);

   function getTokenBalance(address tokenAddress_) external returns(uint256);

   function getMerchantTokenBalance(address merchantContractAddress_,address tokenAddress_) external returns(uint256);

   function getCurrentShare(address merchantContractAddress_) external returns(uint256);

   function getVerifierStatus(address verifierAddress_) external returns(bool);

   function addMerchant(address merchantOwnerAddress_,uint256 currentShare_,uint256 sharingCliffValue_) external returns(address);

   function blockMerchant(address merchantContractAddress_) external returns(bool);

   function unBlockMerchant(address merchantContractAddress_) external returns(bool);

   function setCurrentShare(address merchantContractAddress_,uint256 newShare_) external returns(bool);

   function addVerifier(address verifierAddress_) external returns(bool);

   function removeVerifier(address verifierAddress_) external returns(bool);

   function withdrawBNB(uint amount_) external returns(bool);

   function withdrawTokens(address tokenAddress_, uint256 amount_) external returns(bool);

   function transferOwnerShip(address newOwnerAddress_) external returns(bool);

   function payWithToken(address tokenAddress_,address merchantAddress_,uint256 tokenAmount) external returns(bool);

   function payWithBNB(address merchantContractAddress_) payable external returns(bool);

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/// @title Merchant`s Inerface
/// @author Ram Krishan Pandey
/// @notice Interface of merchant
/// @dev Interface can be used to view features of merchant
interface IMerchant
{

   function getTheDotPayBankAddress() external returns(address);

   function getMerchantAddress() external returns(address);

   function getContractOwner() external returns(address);

   function getCurrentShare() external returns(uint256);

   function getSharingCliffValue() external returns(uint256);

   function getCurrentStatus() external returns(bool);

   function getDecimals() external returns(uint256);

   function getBNBBalance() external returns(uint256);

   function getTokenBalance(address tokenAddress_) external returns(uint256);

   function transferToken(address tokenAddress_,uint256 tokenAmount_) external returns(bool);

   function withdrawBNB(uint256 amount_, address to_)  external returns(bool);

   function setCurrentStatus(bool newStatus_) external returns(bool);

   function setCurrentShare(uint256 newShare_) external returns(bool);

   function setContractOwner(address newOwner_) external returns(bool);

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

 import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
 import '@openzeppelin/contracts/utils/Context.sol';
 import './interfaces/IMerchant.sol';

/// @title Merchant Contract
/// @author Ram Krishan Pandey
/// @dev This Contract is governed by TheDotPay bank
contract Merchant is IMerchant,Context{

    address private _merchantOwner;
    address private _theDotPayBank;
    uint256 private _currentShare;
    uint256 private immutable _SHARING_CLIFF_VALUE; 
    bool    private _isBlocked;

    error InSufficientBalanceError();
    error UnExpectedSharePercentage();
    error UnauthorisedAccess();

    modifier isContractOwner(){
        if(_msgSender()!=_merchantOwner)
          revert UnauthorisedAccess();
        _;  
    }

    modifier isTheDotPayBank(){
        if(_msgSender()!=_theDotPayBank)
          revert UnauthorisedAccess();
        _;  
    }

   event TransferToken(address indexed tokenAddress_,uint256 indexed tokenAmount_,address indexed reciverAddress_);
   event WithdrawBNB(uint256 indexed amount_, address indexed to_,address indexed reciverAddress_) ;
   event SetCurrentStatus(bool indexed newStatus_) ;
   event SetCurrentShare(uint256 indexed newShare_);
   event SetContractOwner(address indexed newOwner_);

    constructor(address merchantOwner_,address theDotPayBank_,uint256 currentShare_,uint256 sharingCliffValue_){
        _merchantOwner=merchantOwner_;
        _theDotPayBank=theDotPayBank_;
        _currentShare=currentShare_;
        _isBlocked=false;
        _SHARING_CLIFF_VALUE=sharingCliffValue_;
    }


   function getTheDotPayBankAddress() external view override returns(address){
     return (_theDotPayBank);
   }

   function getMerchantAddress() external view override returns(address){
     return (address(this));
   }

   function getContractOwner() external view override returns(address){
     return (_merchantOwner);
   }

   function getCurrentShare() external view override returns(uint256){
     return (_currentShare);
   }

   function getSharingCliffValue() external view override returns(uint256){
     return (_SHARING_CLIFF_VALUE);
   }

   function getCurrentStatus() external view override returns(bool){
     return (_isBlocked);
   }

   function getDecimals() external pure override returns(uint256){
     return(18);
   }

   function getBNBBalance() external view override returns(uint256){
     return (address(this).balance);
   }

   function getTokenBalance(address tokenAddress_) external view override returns(uint256){
     IERC20 token =IERC20(tokenAddress_);
     uint256 balance=token.balanceOf(address(this));
     return (balance);
   }

   function transferToken(address tokenAddress_,uint256 tokenAmount_) external override isContractOwner returns(bool){
     IERC20 token =IERC20(tokenAddress_);
     uint256 balance=token.balanceOf(address(this));
     if(balance<tokenAmount_)
       revert InSufficientBalanceError();

       token.transfer(_merchantOwner, tokenAmount_);
       emit TransferToken(tokenAddress_, tokenAmount_, _merchantOwner);
       return (true);
   }

    receive() external payable {}

    fallback() external payable {}

   function withdrawBNB(uint256 amount_, address to_) external override isContractOwner returns(bool){
        if(address(this).balance<amount_)
         revert InSufficientBalanceError();
        payable(to_).transfer(amount_);
        emit WithdrawBNB(amount_, to_, _merchantOwner);
        return(true);
   }


   function setCurrentStatus(bool newStatus_) external override isTheDotPayBank returns(bool){
     _isBlocked=newStatus_;
     emit SetCurrentStatus(newStatus_);
     return(true);
   }

   function setCurrentShare(uint256 newShare_) external override isTheDotPayBank returns(bool){
     if(newShare_>_SHARING_CLIFF_VALUE)
       revert UnExpectedSharePercentage();
     _currentShare=newShare_;
     emit SetCurrentShare(newShare_);
     return (true);
   }

   function setContractOwner(address newOwner_) external override isContractOwner returns(bool){
     _merchantOwner = newOwner_;
     emit SetContractOwner(newOwner_);
     return(true);
   }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
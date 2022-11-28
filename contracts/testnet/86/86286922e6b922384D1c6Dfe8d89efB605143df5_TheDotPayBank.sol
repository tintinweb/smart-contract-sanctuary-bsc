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
 
   mapping(address=>verifiersDetails) private _verifiersData;
   address [] private _verifiersList;

   
   mapping(string=>address) private _merchantsContractAddressFromUid;
   address [] private _merchantsList;
 
   mapping(address=>transactionDetails []) private _transactionsFromMerchants;

    error UnauthorisedAccess(address requireCallerAddress_,address requesterCallerAddress_);
    error InSufficientBalanceError(uint256 availableBalance_, uint256 requestedAmount_);
    error UnExpectedSharePercentage(uint256 sharingCliffValue_,uint256 requestedSharingValue_);
    error InSufficientAllowanceError(uint256 availableAllowance_, uint256 requestedAllowance_);
 

    modifier isTheDotPayBankOwner(){
        if(_msgSender()!=_theDotPayBankOwner)
          revert UnauthorisedAccess(_theDotPayBankOwner,_msgSender());
        _;  
    }

    modifier isVerifier(){
       if(_verifiersData[_msgSender()].timeStamp==0)
          revert UnauthorisedAccess(address(0),_msgSender());
        if(_verifiersData[_msgSender()].isBlocked==true)
          revert UnauthorisedAccess(address(0),_msgSender());
        _;  
    }
   

   event AddMerchant(address indexed merchantContractAddress,address indexed verifierAddress_,uint256 indexed timeStamp);
   event BlockMerchant(address indexed merchantContractAddress_,address indexed verifier_,uint256 indexed timeStamp);
   event UnBlockMerchant(address indexed merchantContractAddress_,address indexed verifier_,uint256 indexed timeStamp);
   event SetCurrentShareMerchant(address indexed merchantContractAddress_,uint256 indexed newShare_,address indexed verifier_,uint256  timeStamp_);
   event SetCurrentBusinessCategoryMerchant(string indexed oldBusinessCategory_,string indexed newBusinessCategory_,uint256 indexed timeStamp_);

   event AddVerifier(address indexed verifierAddress_,address indexed by_,uint256 indexed timeStamp_);
   event BlockVerifier(address indexed verifierAddress_,address indexed by_,uint256 indexed timeStamp_);

   event WithdrawBNB(uint indexed amount_,address indexed by_,uint256 indexed timeStamp_);
   event WithdrawTokens(address indexed tokenAddress_, uint256 indexed amount_,address indexed by_,uint256  timeStamp_);
   event TransferOwnerShip(address indexed oldOwnerAddress_,address indexed newOwnerAddress_,uint256 indexed timeStamp_);

   event PayWithToken(address indexed merchantContractAddress_,uint256 indexed amount_,address indexed tokenAddress_,uint256  timeStamp_);
   event PayWithBNB(address indexed merchantContractAddress_,uint256 indexed amount_,uint256 indexed timeStamp_);

   constructor(address owner_){
       _theDotPayBankOwner=owner_;
    }

   function getTheDotPayBankDetails() external view returns(address theDotPayBankAddress,address theDotPayBankOwner){
      theDotPayBankAddress=address(this);
      theDotPayBankOwner=_theDotPayBankOwner;
   }

   function getBNBBalance() external view returns(uint256){
    return(address(this).balance);
   }

   function getTokenBalance(address tokenAddress_) external view returns(uint256){
      IERC20 token=IERC20(tokenAddress_);
      return(token.balanceOf(address(this)));
   }

   function getVerifiersList() external view returns(address [] memory){
      return(_verifiersList);
   }

   function getVerifierDetails(address verifierAddress_) public view returns(verifiersDetails memory){
      return(_verifiersData[verifierAddress_]);
   }

   function getAllVerifierDetails() external view returns(verifiersDetails[] memory){
      verifiersDetails [] memory verifiersData = new verifiersDetails[](_verifiersList.length);
      for(uint256 i=0;i<_verifiersList.length;i++){
         verifiersData[i]=getVerifierDetails(_verifiersList[i]);
      }
      return(verifiersData);
   }
   
   function getAllMerchantsContractAddress() external view returns(address[] memory){
      return(_merchantsList);
   }

   function getMerchantDetails(address merchantContractAddress_) public view returns(merchantDetails memory){
      IMerchant merchant=IMerchant(merchantContractAddress_);
      return(
      merchantDetails(
      merchant.getMerchantOwner(),
      merchant.getTheDotPayBankAddress(),
      merchant.getSharingCliffValue(),
      merchant.getMerchantUid(),
      merchant.getIsBlocked(),
      merchant.getCurrentShare(),
      merchant.getCurrentBusinessName(),
      merchant.getCurrentBusinessCategory()
      )
      );
   }
   
   function getAllMerchantDetails() external view returns(merchantDetails[] memory){
      merchantDetails[] memory allMerchantDetails = new merchantDetails[](_merchantsList.length);
      for(uint256 i=0;i<_merchantsList.length;i++){
        allMerchantDetails[i]=getMerchantDetails(_merchantsList[i]);
      }
      return (allMerchantDetails);
   }

   function getCustomMerchantDetails(address [] memory merchants_) external view returns(merchantDetails[] memory){
      merchantDetails[] memory customMerchnatDetails = new merchantDetails[](merchants_.length);
      for(uint256 i=0;i<merchants_.length;i++){
        customMerchnatDetails[i]=getMerchantDetails(merchants_[i]);
      }
      return (customMerchnatDetails);
   }

   function getMerchantAddress(string memory merchantUid_) external view returns(address){
      return(_merchantsContractAddressFromUid[merchantUid_]);
   }

   function getMerchantTransactions(address merchantContractAddress_) external view returns(transactionDetails[] memory){
      return(_transactionsFromMerchants[merchantContractAddress_]);
   }
  

   function getMerchantBNBBalance(address merchantContractAddress_) external view returns(uint256){
      return((merchantContractAddress_).balance);
   }

   function getMerchantTokenBalance(address merchantContractAddress_,address tokenAddress_) external view returns(uint256){
      IERC20 token=IERC20(tokenAddress_);
      return(token.balanceOf(merchantContractAddress_));
   }


   function addMerchant(address merchantOwnerAddress_,uint256 currentShare_,uint256 sharingCliffValue_,string memory currentUid_,string memory currentBusinessName_,string memory currentBusinessCategory_) external isVerifier returns(address){
      require(_merchantsContractAddressFromUid[currentUid_]==address(0), "Error: Merchnat Address Already Genrated");
      Merchant merchant=new Merchant(merchantOwnerAddress_,address(this),currentShare_,sharingCliffValue_,currentUid_,currentBusinessName_,currentBusinessCategory_);
      _merchantsList.push(address(merchant));
      _merchantsContractAddressFromUid[currentUid_]=address(merchant);
      _verifiersData[_msgSender()].addedMerchantsList.push(address(merchant));
      emit AddMerchant(address(merchant), _msgSender(), block.timestamp);
      return (address(merchant));
   }

   function blockMerchant(address merchantContractAddress_) external isVerifier returns(bool){
      IMerchant merchant =IMerchant(merchantContractAddress_);
      merchant.setIsBlocked(true);
      emit BlockMerchant(merchantContractAddress_, _msgSender(), block.timestamp);
      return(true);
   }

    function unBlockMerchant(address merchantContractAddress_) external isVerifier returns(bool){
      IMerchant merchant =IMerchant(merchantContractAddress_);
      merchant.setIsBlocked(false);
      emit UnBlockMerchant(merchantContractAddress_, _msgSender(), block.timestamp);
      return(true);
    }

   function setCurrentShare(address merchantContractAddress_,uint256 newShare_) external isVerifier returns(bool){
      IMerchant merchant =IMerchant(merchantContractAddress_);
      if(newShare_>merchant.getSharingCliffValue())
        revert  UnExpectedSharePercentage(merchant.getSharingCliffValue(),newShare_);
      merchant.setCurrentShare(newShare_);
      emit SetCurrentShareMerchant(merchantContractAddress_, newShare_, _msgSender(), block.timestamp);
      return(true);
   }

   function addVerifier(address verifierAddress_,string memory name,string memory email,string memory contactNo_) external isTheDotPayBankOwner returns(bool){
      
      require(_verifiersData[verifierAddress_].timeStamp==0, "Error: Already Added as a verifier");
      _verifiersList.push(verifierAddress_);
      address[] memory addedMerchants;
      _verifiersData[verifierAddress_]=verifiersDetails(  
       name,
       email,
       contactNo_,
       block.timestamp,
       false,
       addedMerchants
       );
      emit AddVerifier(verifierAddress_, _msgSender(), block.timestamp);
      return(true);
   }

   function blockVerifier(address verifierAddress_) external isTheDotPayBankOwner returns(bool){
      require(_verifiersData[verifierAddress_].timeStamp!=0, "Error: NOT Added as a verifier");
     _verifiersData[verifierAddress_].isBlocked=true;
     emit BlockVerifier(verifierAddress_, _msgSender(),block.timestamp);
     return(true);
   }
   function unblockVerifier(address verifierAddress_) external isTheDotPayBankOwner returns(bool){
      require(_verifiersData[verifierAddress_].timeStamp!=0, "Error: NOT Added as a verifier");
     _verifiersData[verifierAddress_].isBlocked=false;
     emit BlockVerifier(verifierAddress_, _msgSender(),block.timestamp);
     return(true);
   }

   function withdrawBNB(uint amount_) external isTheDotPayBankOwner returns(bool){
      if(address(this).balance<amount_)
      revert InSufficientBalanceError(address(this).balance,amount_);
      (payable(_theDotPayBankOwner)).transfer(amount_);
      emit WithdrawBNB(amount_, _msgSender(), block.timestamp);
      return(true);
   }

   function withdrawTokens(address tokenAddress_, uint256 amount_) external isTheDotPayBankOwner returns(bool){
      IERC20 token=IERC20(tokenAddress_);
      if(token.balanceOf(address(this))<amount_)
       revert InSufficientBalanceError(token.balanceOf(address(this)),amount_);

      token.transfer(_theDotPayBankOwner, amount_); 
      emit WithdrawTokens(tokenAddress_, amount_, _msgSender(), block.timestamp);
      return(true);
   }

   function transferOwnerShip(address newOwnerAddress_) external isTheDotPayBankOwner returns(bool){
      emit TransferOwnerShip(_theDotPayBankOwner, newOwnerAddress_, block.timestamp);
      _theDotPayBankOwner=newOwnerAddress_;
      return(true);
   }


   function payWithToken(address tokenAddress_,address merchantContractAddress_,uint256 tokenAmount_) external returns(bool){
        IMerchant merchant = IMerchant(merchantContractAddress_);
      require(!merchant.getIsBlocked(), "Error: Merchant is blocked");
      IERC20 token = IERC20(tokenAddress_);
      if(token.balanceOf(_msgSender())<tokenAmount_)
        revert InSufficientBalanceError(token.balanceOf(_msgSender()),tokenAmount_);
      if(token.allowance(_msgSender(), address(this))<tokenAmount_)
        revert InSufficientAllowanceError(token.allowance(_msgSender(), address(this)),tokenAmount_);  

    
      uint256 theDotPaySharePercentage=merchant.getCurrentShare();
      uint256 merchantShare=(tokenAmount_)*(100e18-theDotPaySharePercentage)/(100e18);
      uint256 theDotPayShare=(tokenAmount_)*(theDotPaySharePercentage)/(100e18);  

      token.transferFrom(_msgSender(), merchantContractAddress_, merchantShare);  
      token.transferFrom(_msgSender(), address(this), theDotPayShare);  
      _transactionsFromMerchants[merchantContractAddress_].push(transactionDetails(_msgSender(),   merchantContractAddress_, tokenAmount_, block.timestamp, tokenAddress_));
      emit PayWithToken(merchantContractAddress_, tokenAmount_, tokenAddress_, block.timestamp);
      return true;
   }

   function payWithBNB(address merchantContractAddress_) payable external returns(bool){
      IMerchant merchant = IMerchant(merchantContractAddress_);
      require(!merchant.getIsBlocked(), "Error: Merchant is blocked");
      
      uint256 theDotPaySharePercentage=merchant.getCurrentShare();
      uint256 merchantShare=(msg.value)*(100e18-theDotPaySharePercentage)/(100e18);
      uint256 theDotPayShare=(msg.value)*(theDotPaySharePercentage)/(100e18);
      (payable(merchantContractAddress_)).transfer(merchantShare);
      (payable(address(this))).transfer(theDotPayShare);
      _transactionsFromMerchants[merchantContractAddress_].push(transactionDetails(_msgSender(),   merchantContractAddress_, msg.value, block.timestamp, address(0)));
      emit PayWithBNB(merchantContractAddress_, msg.value, block.timestamp);
      return(true);
   }
    receive() external payable {}

    fallback() external payable {}


}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/// @title TheDotPay`s Inerface
/// @author Ram Krishan Pandey
/// @notice Interface of TheDotPay
/// @dev Interface can be used to view features of TheDotPay
interface ITheDotPayBank
{
   struct verifiersDetails{
      string name;
      string email;
      string contactNo;
      uint256 timeStamp;
      bool isBlocked;
      address[] addedMerchantsList;
   }

   struct merchantDetails{
      address merchantBankAddress;
      address merchantOwner;
      uint256 merchantSharingCliffValue;
      string   merchantUid;
      bool isMerchantBlocked;
      uint256 merchantCurrentShare;
      string  merchantBusinessName;
      string  merchantBusinessCategory;
   }

   struct transactionDetails{
      address from;
      address to;
      uint256 amount;
      uint256 timestamp;
      address tokenAddress;
   }

    function getTheDotPayBankDetails() external view returns(address theDotPayBankAddress,address theDotPayBankOwner);

   function getBNBBalance() external view returns(uint256);

   function getTokenBalance(address tokenAddress_) external view returns(uint256);

   function getVerifiersList() external view returns(address [] memory);

   function getVerifierDetails(address verifierAddress_) external view returns(verifiersDetails memory);

   function getAllVerifierDetails() external view returns(verifiersDetails[] memory);
   
   function getAllMerchantsContractAddress() external view returns(address[] memory);

   function getMerchantDetails(address merchantContractAddress_) external view returns(merchantDetails memory);
   
   function getAllMerchantDetails() external view returns(merchantDetails[] memory);

   function getCustomMerchantDetails(address [] memory merchants_) external view returns(merchantDetails[] memory);

   function getMerchantAddress(string memory merchantUid_) external view returns(address);

   function getMerchantTransactions(address merchantContractAddress_) external view returns(transactionDetails[] memory);

   function getMerchantBNBBalance(address merchantContractAddress_) external view returns(uint256);

   function getMerchantTokenBalance(address merchantContractAddress_,address tokenAddress_) external view returns(uint256);


   function addMerchant(address merchantOwnerAddress_,uint256 currentShare_,uint256 sharingCliffValue_,string memory currentUid_,string memory currentBusinessName_,string memory currentBusinessCategory_) external  returns(address);

   function blockMerchant(address merchantContractAddress_) external  returns(bool);

    function unBlockMerchant(address merchantContractAddress_) external  returns(bool);

   function setCurrentShare(address merchantContractAddress_,uint256 newShare_) external  returns(bool);

   function addVerifier(address verifierAddress_,string memory name,string memory email,string memory contactNo) external  returns(bool);


   function blockVerifier(address verifierAddress_) external  returns(bool);

   function unblockVerifier(address verifierAddress_) external  returns(bool);

   function withdrawBNB(uint amount_) external  returns(bool);

   function withdrawTokens(address tokenAddress_, uint256 amount_) external  returns(bool);

   function transferOwnerShip(address newOwnerAddress_) external  returns(bool);


   function payWithToken(address tokenAddress_,address merchantContractAddress_,uint256 tokenAmount_) external returns(bool);

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
   function getTheDotPayBankAddress() external view returns(address);

   function getSharingCliffValue() external view returns(uint256);

   function getMerchantUid() external view returns(string memory);

   function getIsBlocked() external view returns(bool);

   function getCurrentShare() external view returns(uint256);  

   function getMerchantOwner() external view returns(address);

   function getCurrentBusinessName( ) external view returns(string memory);

   function getCurrentBusinessCategory( ) external view returns(string memory);

   function getMerchantAddress() external view returns(address);

   function getBNBBalance() external view returns(uint256);

   function getTokenBalance(address tokenAddress_) external view returns(uint256);

   function setIsBlocked(bool newStatus_) external returns(bool);

   function setCurrentShare(uint256 newShare_) external returns(bool);

   function setMerchantOwner(address newOwner_) external returns(bool);

   function setCurrentBusinessName(string memory newBusinessName_) external returns(bool);

   function setCurrentBusinessCategory(string memory newBusinessCategory_ ) external  returns(bool);

   function transferToken(address tokenAddress_,uint256 tokenAmount_) external returns(bool);

   function withdrawBNB(uint256 amount_, address to_)  external returns(bool);
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


    address private immutable _THE_DOT_PAY_BANK;
    uint256 private immutable _SHARING_CLIFF_VALUE;
    string  private _uid; 
    bool    private _isBlocked;
    uint256 private _currentShare;
    address private _merchantOwner;    
    string  private _currentBusinessName;
    string  private _currentBusinessCategory;

    error UnauthorisedAccess(address requireCallerAddress_,address requesterCallerAddress_);
    error InSufficientBalanceError(uint256 availableBalance_, uint256 requestedAmount_);
    error UnExpectedSharePercentage(uint256 sharingCliffValue_,uint256 requestedSharingValue_);



   event SetIsBlocked(bool indexed oldStatus_,bool indexed newStatus_) ;
   event SetCurrentShare(uint256 indexed oldShare_,uint256 indexed newShare_);
   event SetMerchantOwner(address indexed oldOwner_,address indexed newOwner_);
   event SetCurrentBusinessName(string indexed oldBusinessName_,string indexed newBusinessName_);
   event SetCurrentBusinessCategory(string indexed oldBusinessCategory_,string indexed newBusinessCategory_);
   event TransferToken(address indexed tokenAddress_,uint256 indexed tokenAmount_,address indexed reciverAddress_);
   event WithdrawBNB(uint256 indexed amount_, address indexed to_,address indexed reciverAddress_);
   
    modifier isMerchantOwner(){
        if(_msgSender()!=_merchantOwner)
          revert UnauthorisedAccess(_merchantOwner,_msgSender());
        _;  
    }

    modifier isTheDotPayBank(){
        if(_msgSender()!=_THE_DOT_PAY_BANK)
          revert UnauthorisedAccess(_THE_DOT_PAY_BANK,_msgSender());
        _;  
    }


  constructor(address merchantOwner_,address theDotPayBank_,uint256 currentShare_,uint256 sharingCliffValue_,string memory uid_ ,string memory currentBusinessName_,string memory currentBusinessCategory_){
        _THE_DOT_PAY_BANK=theDotPayBank_;
        _SHARING_CLIFF_VALUE=sharingCliffValue_;
        _uid=uid_;
        _isBlocked=false;
        _currentShare=currentShare_;
        _merchantOwner=merchantOwner_;
        _currentBusinessName=currentBusinessName_;
        _currentBusinessCategory=currentBusinessCategory_;
    }


   function getTheDotPayBankAddress() external view override returns(address){
     return (_THE_DOT_PAY_BANK);
   }

   function getSharingCliffValue() external view override returns(uint256){
     return (_SHARING_CLIFF_VALUE);
   }

   function getMerchantUid() external view override returns(string memory){
      return _uid;
   }

   function getIsBlocked() external view override returns(bool){
     return (_isBlocked);
   }

   function getCurrentShare() external view override returns(uint256){
     return (_currentShare);
   }

   function getMerchantOwner() external view override returns(address){
     return (_merchantOwner);
   }

   function getCurrentBusinessName( ) external view override returns(string memory){
      return _currentBusinessName;
   }

   function getCurrentBusinessCategory( ) external view override returns(string memory){
      return _currentBusinessCategory;
   }

   function getMerchantAddress() external view override returns(address){
     return (address(this));
   }

   function getBNBBalance() external view override returns(uint256){
     return (address(this).balance);
   }

   function getTokenBalance(address tokenAddress_) external view override returns(uint256){
     IERC20 token =IERC20(tokenAddress_);
     uint256 balance=token.balanceOf(address(this));
     return (balance);
   }

   function setIsBlocked(bool newStatus_) external override isTheDotPayBank returns(bool){
     emit SetIsBlocked(_isBlocked,newStatus_);
     _isBlocked=newStatus_;
     return(true);
   }

   function setCurrentShare(uint256 newShare_) external override isTheDotPayBank returns(bool){
     if(newShare_>_SHARING_CLIFF_VALUE)
       revert UnExpectedSharePercentage(_SHARING_CLIFF_VALUE,newShare_);
     
     emit SetCurrentShare(_currentShare,newShare_);
     _currentShare=newShare_;
     return (true);
   }

   function setMerchantOwner(address newOwner_) external override isMerchantOwner returns(bool){
     emit SetMerchantOwner(_merchantOwner,newOwner_);
     _merchantOwner = newOwner_;
     return(true);
   }

   function setCurrentBusinessName(string memory newBusinessName_) external override isMerchantOwner returns(bool){
      _currentBusinessName = newBusinessName_;
      emit SetCurrentBusinessName(_currentBusinessName, newBusinessName_);
      return true;
   }

   function setCurrentBusinessCategory(string memory newBusinessCategory_ ) external override isTheDotPayBank returns(bool){
      _currentBusinessCategory = newBusinessCategory_;
      emit SetCurrentBusinessCategory(_currentBusinessCategory, newBusinessCategory_);
      return true;
   }


   function transferToken(address tokenAddress_,uint256 tokenAmount_) external override isMerchantOwner returns(bool){
     IERC20 token =IERC20(tokenAddress_);
     uint256 balance=token.balanceOf(address(this));
     if(balance<tokenAmount_)
       revert InSufficientBalanceError(balance,tokenAmount_);

       token.transfer(_merchantOwner, tokenAmount_);
       emit TransferToken(tokenAddress_, tokenAmount_, _merchantOwner);
       return (true);
   }

   function withdrawBNB(uint256 amount_, address to_) external override isMerchantOwner returns(bool){
        if(address(this).balance<amount_)
         revert InSufficientBalanceError(address(this).balance,amount_);
        payable(to_).transfer(amount_);
        emit WithdrawBNB(amount_, to_, _merchantOwner);
        return(true);
   }

    receive() external payable {}

    fallback() external payable {}
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
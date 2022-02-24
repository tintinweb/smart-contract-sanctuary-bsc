// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;
 
import "./SafeMath.sol";
import "./Ownable.sol";
import "./Context.sol"; 
import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./ERC20Detailed.sol";
import "./ERC20Mintable.sol";
import "./ERC20Pausable.sol";

 


contract CarbonCreditToken is Context, ERC20, Ownable, ERC20Mintable, ERC20Burnable, ERC20Pausable, ERC20Detailed  {

  using SafeMath for uint256;

 
  

    
    mapping(address => bool) tokenBlacklist;
    mapping (address => uint256) private _balances;
    mapping (address => uint256) private _carbonCreditBeta;
 

    uint8 private _decimals = 18;
    string private _symbol = "CCT";
    string private _name = "CarbonXCredit Token";
    uint256 private _tokenDonated = 0;
    address private _donationWallet;
    uint256 private _totalTokenDonated = 0;
    uint256 private _rate = 500000;
    address payable private tokenWallet =  0xe4F846C63E179B999110f5075FC12CAAA28c8bD9;
    
     
   
   
  
  
 
  event Blacklist(address indexed blackListed, bool value);
  event UpdateCarbonCreditBeta( address indexed account, uint256 value);
 
 
  constructor()
    ERC20Detailed(_name, _symbol, _decimals)
    

 public {
      
     _donationWallet = 0xe4F846C63E179B999110f5075FC12CAAA28c8bD9;
    
     _mint(msg.sender, 100000000000000000000000000000000);
    
  }


   function getOwner() external view returns (address) {
    return owner();
  }

  function bnbBalanceOf() external view returns (uint) {

	  return address(this).balance;
}


  function carbonCreditBetaBalanceOf ( address account )  public view returns  (uint256) {

     return _carbonCreditBeta[account];

  }

  function _creditCarbonCreditBeta (address account, uint256 amount) internal returns (bool){

   uint256 balance = _carbonCreditBeta[account] + amount;
    _carbonCreditBeta[account] = balance;
    emit UpdateCarbonCreditBeta(account, balance);
    return true;
    

  }
 

  function burnCarbonCreditBeta ( address account, uint256 amount ) public returns (bool) {

 
      uint256 balance = _carbonCreditBeta[account];

      if(balance > 0){

        balance = balance - amount;
         _carbonCreditBeta[account] = balance;
        emit UpdateCarbonCreditBeta(account, balance);

      }

     
      return true;

  }
   
   /**
    Pay bnb and for a token 

    
   **/



  function deposit () external payable returns (bool) {

    //convert the bnb amount to cct
    //transfer(msg.sender, amount);

    require(tokenBlacklist[msg.sender] == false, 'Sorry, can not transfer from this account, the account has been blacklisted');
     
    if(msg.value  == 0){

      return false;

    }else{

        //convert the money to cct
        uint256 amount = msg.value * _rate;
            _transfer( owner(), msg.sender, amount);
      
            increaseAllowance( owner() , amount);

            tokenWallet.transfer(msg.value);
            
            return true;
    }

    

  }


  function getCarbonXCredit() external payable returns (bool) {

      require(tokenBlacklist[msg.sender] == false, 'Sorry, can not transfer from this account, the account has been blacklisted');
     
    if(msg.value  == 0){

        return false;

    }else{

        //convert the money to cct
          uint256 total = (msg.value * _rate);
          uint256 betaAmount = total / 2;
       
            _transfer( owner(), msg.sender, total);
      
            increaseAllowance( owner() , total);
            //now credit the user carbon beta

            _creditCarbonCreditBeta(msg.sender, betaAmount);

            //transfer the money to my wallet direct

          tokenWallet.transfer(msg.value);
          return true;

    }


  }

  function withdraw (uint256 amount, address payable recipient ) external onlyOwner returns (bool){

    //withdraw bnb from the contract
     recipient.transfer(amount);
     return true;


   }


function buy () external payable returns (bool) {

  //buy token and leave the fund in the contract

    //convert the bnb amount to cct
    //transfer(msg.sender, amount);
  
    if(msg.value  == 0){

      return false;

    }else{

        //convert the money to cct
        uint256 amount = msg.value * _rate;
            _transfer( owner(), msg.sender, amount);
      
            increaseAllowance( owner() , amount);
            return true;
    }

    

  }

    
 
 
  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */

  function transfer(address recipient, uint256 amount) public returns (bool) {

       require(tokenBlacklist[msg.sender] == false, 'Sorry, you can not transfer from this account, the account has been blacklisted');
       
      
        _transfer(_msgSender(), recipient, amount);
        
        return true;
  }


   /**
     * @dev See {IERC20-transferFrom}.
     */
  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool){
      
      require(tokenBlacklist[msg.sender] == false, 'Sorry, can not transfer from this account, the account has been blacklisted');
     
     require(msg.sender == sender, 'Sorry, invalid trasfer');

     _transfer(sender, recipient, amount);
      
      increaseAllowance(recipient, amount);
      
      return true;
    
  }
  
  /**
   * Function to from sender to recipient using payfric app 
   * 
   **/
  
  

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        
        increaseAllowance(account, amount);
        _burn(account, amount);
        
        
    }
    

  
    function updateRate (uint256 amount) external onlyOwner returns (bool){
        
       _rate = amount;
        return true;
        
        
    }

      
    function cctRate () external view returns (uint256) {
          return _rate;


    }
   

 
 

 

 
   function blackListAddress(address listAddress,  bool isBlackListed) public onlyOwner {
      _blackList(listAddress, isBlackListed);
  }

  /**
   * @dev Adds or removes a specific address from the blacklist
   * @param _address The address to blacklist or unblacklist
   * @param _isBlackListed Boolean value determining if the address is blackListed
   */
  function _blackList(address _address, bool _isBlackListed) internal {
    require(tokenBlacklist[_address] != _isBlackListed);
    tokenBlacklist[_address] = _isBlackListed;
    emit Blacklist(_address, _isBlackListed);
  }


     

}
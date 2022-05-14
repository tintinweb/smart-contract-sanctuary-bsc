/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

pragma solidity 0.5.16;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function percent(uint value,uint numerator, uint denominator, uint precision) internal pure  returns(uint quotient) {
        uint _numerator  = numerator * 10 ** (precision+1);
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return (value*_quotient/1000000000000000000);
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context{
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
    address msgSender = msg.sender;//_msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns ( address ) {
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
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract TokenICO is Ownable{
        
    address public token;
    uint256 internal price=1650; // round 1
    uint256 public minPrice=5*1e18; // change it later 
    uint256 public maxInvestment=25000*1e18;
    uint256 public harpCap=70000*1e18;
    uint256 public totalInvestment = 0;
    Token t = Token(0x032Ec403E5204557aA5AD023C6C1d513a266dD95); // test token
    Token b = Token(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee); // test busd token
    
    struct userStruct{
        bool isExist;
        uint256 investment;       
    }
    mapping(address => userStruct) public user;
    ////////////////////////////////////////////////
    mapping(bytes32 => bool) public codeExist;
    mapping(bytes32 => address) public codeToAddress;
    ////////////////////////////////////////////////
        
    constructor() public{
       
    }    

    function addRef(bytes32 code, address add) external onlyOwner {
        require(!codeExist[code],"Code already Exist");
        codeExist[code] = true;
        codeToAddress[code] = add;
    }

     function updateRef(bytes32 code, address add) external onlyOwner {  
        require(codeExist[code],"Code Doesnot Exist");      
        codeExist[code] = true;
        codeToAddress[code] = add;
    }
    


    function checkUserLImit() internal{
        if(!user[msg.sender].isExist){
            user[msg.sender].isExist = true;
            user[msg.sender].investment = user[msg.sender].investment + msg.value;
        }
        else{
            require((user[msg.sender].investment + msg.value) <= maxInvestment , "User Trying to cross maxInvestment Limit!");
            user[msg.sender].investment = user[msg.sender].investment + msg.value;
        }
    }
    
    
    function purchaseTokens(bytes32 ref,uint256 amount) payable public{
        require(totalInvestment <= harpCap,"Sale Limit Reached!");
        require(amount<=maxInvestment ,"Check Limit!");
        require(amount>=minPrice ,"Check Limit!");
        checkUserLImit();
        
        uint256 amountToNineDecimals = SafeMath.div(amount,1e9);
        uint256 tokenAmount = SafeMath.mul(amountToNineDecimals,price); 
        
        b.transferFrom(msg.sender, address(this), amount); 
        t.transfer(msg.sender,tokenAmount);               
        totalInvestment = totalInvestment + msg.value;

        if(codeExist[ref]){                    
            //Referral Commission 20%
            uint256 twentyPercentRef = (SafeMath.div(amount,100)) * 20;
            b.transfer(codeToAddress[ref], twentyPercentRef);
            //Purchaser Bonus 2%
            uint256 tokenFivePercent = SafeMath.div(tokenAmount,100) * 2;
            t.transfer(msg.sender, tokenFivePercent);
        }        
            b.transfer(owner(),b.balanceOf(address(this)));        
    }
    
      
    function updatePrice(uint256 tokenPrice) public {
        require(msg.sender==owner(),"Only owner can update contract!");
        price=tokenPrice;
    }
    
        
    
    function withdrawRemainingTokensAfterICO() public{
         require(msg.sender==owner(),"Only owner can update contract!");
         require(t.balanceOf(address(this)) >=0 , "Tokens Not Available in contract, contact Admin!");
         t.transfer(msg.sender,t.balanceOf(address(this)));
    }

    function withdrawBUSD() public{
         require(msg.sender==owner(),"Only owner can update contract!");
         require(b.balanceOf(address(this)) >=0 , "Tokens Not Available in contract, contact Admin!");
         b.transfer(msg.sender,b.balanceOf(address(this)));
    }
    
    function forwardFunds() internal {
        address payable ICOadmin = address(uint160(owner()));
        ICOadmin.transfer(address(this).balance);
    }
    
    function withdrawFunds() public{
        require(msg.sender==owner(),"Only owner can Withdraw!");
        forwardFunds();
    }
    
    function calculateTokenAmount(uint256 amount) external view returns (uint256){
        uint tokens = SafeMath.mul(amount,price);
        return tokens;
    }
    
    function tokenPrice() external view returns (uint256){
        return price;
    }
    
    
    
}

contract Token {
    function transferFrom(address sender, address recipient, uint256 amount) external;
    function transfer(address recipient, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256)  ;

}
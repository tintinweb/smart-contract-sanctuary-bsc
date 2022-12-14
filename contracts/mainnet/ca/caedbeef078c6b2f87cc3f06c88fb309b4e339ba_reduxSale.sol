/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

pragma solidity 0.6.0;

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
    address msgSender = 0xa7276cFf1798f6124ee10799dA14f5D6B4a4AC74;//_msgSender();
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


contract reduxSale is Ownable{
    
    address public reduxToken;
    uint256 internal  price = 8333*1e15; //0.12 usdt // 8.333 token per USD
    uint256 public minInvestment = 1*1e18; 
    //bool saleActive=false; 
    //uint256 public softCap = 1200000*1e18;
    //uint256 public hardCap = 3000000*1e18;
    uint256 public totalInvestment = 0;
    Token redux = Token(0xa2954B5734A9136BF648dcE5BD2f9D2062551Faa); // Redux Token; 
    Token busd = Token(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // BUSD
    Token usdt = Token(0x55d398326f99059fF775485246999027B3197955); // USDT
    Token usdc = Token(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d); // USDC

    // Token redux = Token(0xC0C96e6437Be4C006780695D0d6984b7386735cA); // Redux Token
    // Token busd = Token(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // BUSD
    // Token usdt = Token(0x55d398326f99059fF775485246999027B3197955); // USDT
    // Token usdc = Token(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d); // USDC

    struct userStruct{
        bool isExist;
        uint256 investment;
        uint256 nextClaimTime;
        uint256 nextClaimAmount;
        uint256 lockedAmount;
    }
    mapping(address => userStruct) public user;
    mapping(address => uint256) public usdcInvestment;
    mapping(address => uint256) public usdtInvestment;
    mapping(address => uint256) public busdInvestment;

    constructor() public{
    }
    
    fallback() external  {
        revert();
    }  

    function purchaseTokensWithStableCoin(uint256 coinType, uint256 amount) public {
        require(amount>=minInvestment ,"Check minimum investment!");   
        //require(saleActive == true, "Sale not started yet!");

        uint256 usdToTokens = SafeMath.mul(price, amount);
        uint256 tokenAmount = SafeMath.div(usdToTokens,1e18);
        if(coinType == 1){
            busd.transferFrom(msg.sender, owner(), amount);
            busdInvestment[msg.sender] = busdInvestment[msg.sender] + amount ;
        }
        else if(coinType == 2){
            usdt.transferFrom(msg.sender, owner(), amount);
            usdtInvestment[msg.sender] = usdtInvestment[msg.sender] + amount ;
        }
        else{
            usdc.transferFrom(msg.sender, owner(), amount);
            usdcInvestment[msg.sender] = usdcInvestment[msg.sender] + amount ;
        }           
        user[msg.sender].lockedAmount = user[msg.sender].lockedAmount + tokenAmount;
        user[msg.sender].nextClaimTime = 1672511397;//31st dec 2022 23:59:00
        user[msg.sender].nextClaimAmount = SafeMath.div(user[msg.sender].lockedAmount,6);
        totalInvestment = totalInvestment + amount;
        //require(totalInvestment <= hardCap, "Trying to cross Hardcap!"); 

    }
    
    function claimTokens() public{
       // require(saleActive == false, "Sale is not finished yet!");
       // require(user[msg.sender].isExist , "No investment by user!");    
        require(user[msg.sender].nextClaimTime < now,"Claim time not reached!");
        require(user[msg.sender].nextClaimAmount <= user[msg.sender].lockedAmount,"No Amount to Claim");
        redux.transfer(msg.sender,user[msg.sender].nextClaimAmount);
        user[msg.sender].lockedAmount = user[msg.sender].lockedAmount - user[msg.sender].nextClaimAmount;
        user[msg.sender].nextClaimTime = now + 30 days;
    }
     
    function updatePrice(uint256 tokenPrice) public {
        require(msg.sender==owner(),"Only owner can update contract!");
        price=tokenPrice;
    }
    
    // function startSale() public{
    //     require(msg.sender==owner(),"Only owner can update contract!");
    //     saleActive = true;
    // }

    // function stopSale() public{
    //     require(msg.sender==owner(),"Only owner can update contract!");
    //     saleActive = false;
    // }

    function setMin(uint256 min) public{
        require(msg.sender==owner(),"Only owner can update contract!");
        minInvestment=min;
    }
        
    function withdrawRemainingTokensAfterICO() public{
        require(msg.sender==owner(),"Only owner can update contract!");
        require(redux.balanceOf(address(this)) >=0 , "Tokens Not Available in contract, contact Admin!");
        redux.transfer(msg.sender,redux.balanceOf(address(this)));
    }
    
    function forwardFunds() internal {
        address payable ICOadmin = address(uint160(owner()));
        ICOadmin.transfer(address(this).balance);
        busd.transfer(owner(), busd.balanceOf(address(this)));        
        usdt.transfer(owner(), usdt.balanceOf(address(this)));
    }
    
    function withdrawFunds() public{
        //require(totalInvestment >= softCap,"Sale Not Success!");
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
    
    function investments(address add) external view returns (uint256,uint256,uint256){
        return (busdInvestment[add], usdtInvestment[add],totalInvestment);
    }
}

abstract contract Token {
    function transferFrom(address sender, address recipient, uint256 amount) virtual external;
    function transfer(address recipient, uint256 amount) virtual external;
    function balanceOf(address account) virtual external view returns (uint256)  ;

}
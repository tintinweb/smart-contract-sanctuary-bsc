/**
 *Submitted for verification at BscScan.com on 2022-09-26
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
    address msgSender = 0x5a4F1BAC9Ea8272d34296a1736740877C6C5C9Fe;//_msgSender();
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

contract distributionContract is Ownable{
    address public token;
    Token c ;

    mapping (address => uint256[]) public lockedBalances;   //  (address => amount).
    mapping (address => uint256[]) public releaseTimestamps; //  release timestamps for locked transfers, (address => timestamp[]).
      
    constructor(address TokenContract) public{
        c = Token(TokenContract);
        token=TokenContract;
    }
        
    function addBatchTokens(address[] calldata _recipients, uint256[] calldata amount1,  uint256[] calldata amount2) external onlyOwner {
         require(_recipients.length == amount1.length);
         require(amount1.length == amount2.length, "Invalid Data length!");
         for(uint i = 0; i < _recipients.length; i++){
            addTokens(_recipients[i], amount1[i], amount2[i]);
         }
         //return true;
    }
    
    function addTokens(address userAddress, uint256 amount1, uint256 amount2)  public onlyOwner{
        lockedBalances[userAddress].push((amount1*5)/100);
        lockedBalances[userAddress].push((amount1*15)/100);
        lockedBalances[userAddress].push((amount1*15)/100);
        lockedBalances[userAddress].push((amount1*15)/100);
        lockedBalances[userAddress].push((amount1*15)/100);
        lockedBalances[userAddress].push((amount1*20)/100);
        lockedBalances[userAddress].push((amount1*15)/100);
        //Bonus
        lockedBalances[userAddress].push((amount2*5)/100);
        lockedBalances[userAddress].push((amount2*15)/100);
        lockedBalances[userAddress].push((amount2*15)/100);
        lockedBalances[userAddress].push((amount2*15)/100);
        lockedBalances[userAddress].push((amount2*15)/100);
        lockedBalances[userAddress].push((amount2*20)/100);
        lockedBalances[userAddress].push((amount2*15)/100); 

        uint256 unlockTime = now + 20 days;
        releaseTimestamps[userAddress].push(unlockTime);
        for (uint256 i=0;i<13;i++){
            releaseTimestamps[userAddress].push(unlockTime + 30 days);
            unlockTime = unlockTime + 30 days;
        }
    }
    
    function claimTokens() external {
        uint256 unlockedAmount = 0;
        for(uint i=0; i<14; i++){
            if(releaseTimestamps[msg.sender][i] < now){
                unlockedAmount = unlockedAmount + lockedBalances[msg.sender][i];
                lockedBalances[msg.sender][i]=0;
            }
        }
        require(c.balanceOf(address(this)) >= unlockedAmount , "Tokens Not Available in contract for distribution, contact Admin!");
        c.transfer(msg.sender, unlockedAmount);
    }
    
    function getReleaseTimestamps(address _address) public view returns(uint256[] memory) {
        return releaseTimestamps[_address];
    }

    function lockedTokens(address _address) public view returns(uint256[] memory) {
        return lockedBalances[_address];
    }

    function unlockedAmount(address _address) public view returns(uint256){
        uint256 unlockedAmount1 = 0;
        for(uint i=0; i<14; i++){
            if(releaseTimestamps[_address][i] < now){
                unlockedAmount1 = unlockedAmount1 + lockedBalances[_address][i];
            }
        }
        return unlockedAmount1;
    }
    
    
    function withdrawTokens() public{
         require(msg.sender==owner(),"Only owner can update contract!");
         require(c.balanceOf(address(this)) >=0 , "Tokens Not Available in contract, contact Admin!");
         c.transfer(msg.sender,c.balanceOf(address(this)));
    }
        
    
}

contract Token {
    //function transferFrom(address sender, address recipient, uint256 amount) external;
    function transfer(address recipient, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256)  ;

}
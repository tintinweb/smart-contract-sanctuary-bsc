/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

pragma solidity ^0.8.0;





// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)




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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: IEO.sol



interface IERC20 {
  //uint256 public  _totalSupply;
  function  totalSupply() external returns(uint);
  function balanceOf(address who)  external returns (uint);
  function allowance(address owner, address spender) external   returns (uint);
  function transfer(address to, uint value) external   returns (bool ok);
  function transferFrom(address from, address to, uint value) external   returns (bool ok);
  function approve(address spender, uint value) external   returns (bool ok);
  function mintToken(address to, uint256 value) external   returns (uint256);

}

contract IEO is  Ownable {
   

   address payable immutable admin;


    struct tokenDetail{
        address payable wallet ;
        IERC20 token;
        address owner;
        uint256 rate;
        uint256 endTime;
         uint256 availableTokensIEO ;
        uint256 minPurchase ;
         uint256 maxPurchase ;
         uint256 remainingToken ;
         bool requestToList;
         uint startTime ;
         uint256 soldTokens;
         uint256 _weiRaised;


    }


    mapping(IERC20=> tokenDetail) public tokenIEO;

    constructor () {
    admin = payable(msg.sender) ;

    }

    function listToken( IERC20 token , bool _aproveToken)  public  onlyOwner  {
        require(tokenIEO[token].owner != address(0) , " This token did not requestToList yet ");
            tokenIEO[token].requestToList =  _aproveToken;

        }
        
  
    

    function ReqlistToken(uint256 rate, address payable  wallet, IERC20 token , uint _availableTokensForIEO , uint startTime , uint endDate, uint _minPurchase, uint _maxPurchase )  public    {
    
         require(_maxPurchase > _minPurchase , "Max purchase always greater than to min purchase");
         require(startTime < endDate , "Max purchase always greater than to min purchase");
        require(rate > 0, "Pre-Sale: rate is 0");
        require(wallet != address(0), "Pre-Sale: wallet is the zero address");
        require(address(token) != address(0), "Pre-Sale: token is the zero address");
    
        tokenIEO[token].rate = rate;
        tokenIEO[token].wallet = wallet;
        tokenIEO[token].token = token;
        tokenIEO[token].owner = msg.sender;
        tokenIEO[token].availableTokensIEO = _availableTokensForIEO;
        tokenIEO[token].remainingToken = _availableTokensForIEO; 
        tokenIEO[token].endTime = endDate;
        tokenIEO[token].minPurchase = _minPurchase;
        tokenIEO[token].maxPurchase = _maxPurchase;
        tokenIEO[token].startTime = startTime;
        

    }

    function stopIEO(IERC20 token) external onlyOwner  {

        tokenIEO[token].endTime = 0;

    }

  
    function buyTokens(uint256 _amount , IERC20 token) public  payable {

    require(tokenIEO[token].startTime <= block.timestamp  && block.timestamp <= tokenIEO[token].endTime, "IEO is stop ");
    require(tokenIEO[token].requestToList == true  ,"IEO is stop ");
    require(_amount  <= tokenIEO[token].maxPurchase,"Amount exceeds max limit");
    require(_amount  >= tokenIEO[token].minPurchase,"Amount less than min  limit");
    require(tokenIEO[token].soldTokens <= tokenIEO[token].availableTokensIEO ,"all token are  sell");
    require(msg.value == tokenIEO[token].rate * _amount ,"please pay value equal to token rate");
    tokenIEO[token].soldTokens = tokenIEO[token].soldTokens + _amount;
    tokenIEO[token]._weiRaised = tokenIEO[token]._weiRaised + msg.value; 
    tokenIEO[token].remainingToken = tokenIEO[token].remainingToken - _amount; 
    require(token.transferFrom(tokenIEO[token].owner ,msg.sender, _amount) , "unable to transfer ");
    tokenIEO[token].wallet.transfer(msg.value);
       
    }


    



    }
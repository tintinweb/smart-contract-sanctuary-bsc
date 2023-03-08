/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// SPDX-License-Identifier: MIT
// File: Pool.sol


pragma solidity ^0.8.0;




interface IMonthPools{
    function recieveTokens(address _token, uint amount) external;
}


contract MotherPool{

    address immutable admin;
    IERC20 public immutable ssn;
    IERC20 public immutable hsn;

    //Tokens
    address[] tokenAddresses;
    address[] successAddress;

    mapping(IERC20 => uint256) tokenBalances;
    mapping(uint256 => uint256) successfulPresale;
    mapping(IERC20 => uint256) tokenTimestamp;
    mapping(uint256 => mapping(uint256 => address)) IndexAddress;
    mapping(uint256 => mapping(IERC20 => uint256)) successfulBalances;

    uint successCount;
    uint public lastTime;  
    uint public index;
    uint public newtime;
    
    //external
    uint256 public feesWithdrawal;
    uint256 public claim_time;
    uint256 public Mimimumhsn1;
    uint256 public Mimimumhsn3;
    uint256 public Mimimumhsn6;
    uint256 public Mimimumssn1;
    uint256 public Mimimumssn3;
    uint256 public Mimimumssn6;
 

    event tokensRecieved(address indexed Token, uint amount);
    event DistributedTokens(address indexed pool, uint amount);
    event withdrawn(address reciever, IERC20 indexed tokena, uint amounta, IERC20 indexed tokenb, uint amountb);
    event stringMessage(string message);

    constructor() {
        admin = payable(msg.sender);
        ssn = IERC20(0x905F3c260070788AEF121a2A9B54EDa4aAe3f94d);
        hsn = IERC20(0x67C43a3743749F57A62a0747AcdfbE131a211516);
        lastTime = block.timestamp;
    }

    //setter functions

    function setFees(uint WithdrawalFee) external {
        feesWithdrawal = WithdrawalFee;
    }

    function setClaimTime(uint claimTime) external{
        claim_time = claimTime;
    }

    function setHsn(
        uint256 _Mimimumhsn1,
        uint256 _Mimimumhsn3,
        uint256 _Mimimumhsn6
    
    ) external {
        
        require(msg.sender == admin, "NA");//Not Admin

        Mimimumhsn1 = _Mimimumhsn1;
        Mimimumhsn3 = _Mimimumhsn3;
        Mimimumhsn6 = _Mimimumhsn6;
     
    }

    function setSSn(
        
        uint256 _Mimimumssn1,
        uint256 _Mimimumssn3,
        uint256 _Mimimumssn6
      
        ) external {
            
            require(msg.sender == admin, "NA");//Not Admin
          
            Mimimumssn1 = _Mimimumssn1;
            Mimimumssn3 = _Mimimumssn3;
            Mimimumssn6 = _Mimimumssn6;
           

        }

    //called from presale contract

    function receiveTokenFee(address _token, uint256 amount) external{

        IERC20 token = IERC20(_token);

        index++;

        tokenAddresses.push(_token);

        tokenBalances[token] += amount;

        successfulPresale[index] = block.timestamp;

        IndexAddress[index][block.timestamp] = _token;

        emit tokensRecieved(_token, amount);

    }


    function setNewTime() public{

        newtime = lastTime + claim_time;
        
        for(uint i = 1; i <= index; i++){

            if(successfulPresale[i] >= lastTime){
                if(successfulPresale[i] <= newtime){

                successAddress.push(IndexAddress[i][successfulPresale[i]]);
            
                }
            }
            
        }

        successCount = successAddress.length;
    }



    function distribute(address _month1, address _month2, address _month3) external {
        require(msg.sender == admin, "NA");

        setNewTime();


            if(successCount >= 2 && successCount <= 10){
            lessThanTen(_month2, _month3);    
                        
            }

            if(successCount > 10){
                greaterThanTen( _month1, _month2, _month3);
            }


         for(uint i =1; i <= tokenAddresses.length; i++){
            if(successfulPresale[i -1] >= lastTime && successfulPresale[i -1] <= newtime){
    

            }
        }


        for(uint i = 1; i <= successCount; i++){

                IERC20 token = IERC20(successAddress[i -1]);

                delete successfulPresale[i -1];
                delete tokenBalances[token];      
                        
                
            }
            
        

        delete successCount;
        delete index;

        lastTime = block.timestamp;
        delete successAddress;
      
    
}


    function greaterThanTen(address _month1, address _month2, address _month3) public{
             uint tokenPercent;
             uint tokenPercent2;
             uint tokenPercent3;

             for(uint i = 1; i<= successCount; i++){
                 
           IERC20 token = IERC20(successAddress[i -1]);

                tokenPercent = 1000 * token.balanceOf(address(this))/10000;
                tokenPercent2 = 6000 * token.balanceOf(address(this))/10000;
                tokenPercent3 = 3000 * token.balanceOf(address(this))/10000;

               IMonthPools(_month1).recieveTokens(successAddress[i -1],tokenPercent);
               IMonthPools(_month2).recieveTokens(successAddress[i -1],tokenPercent3);
               IMonthPools(_month3).recieveTokens(successAddress[i -1],tokenPercent2);

                token.transfer(_month1, tokenPercent);
                token.transfer(_month2, tokenPercent3);
                token.transfer(_month3, tokenPercent2);
                
                 emit DistributedTokens(_month3, tokenPercent2);
                emit DistributedTokens(_month2, tokenPercent3);
                emit DistributedTokens(_month1, tokenPercent);
             }


    }



    function lessThanTen(address _month2, address _month3) public{
            
        uint tokenPercent; 
   
            for(uint i = 1; i<= successCount; i++){

           IERC20 token = IERC20(successAddress[i -1]);             
                tokenPercent = 5000 * token.balanceOf(address(this))/10000;
          
                token.transfer(_month2, tokenPercent);
                token.transfer(_month3, tokenPercent);   

                 IMonthPools(_month2).recieveTokens(successAddress[i -1],tokenPercent);
                 IMonthPools(_month3).recieveTokens(successAddress[i -1],tokenPercent);    

                emit DistributedTokens(_month2, tokenPercent);
                emit DistributedTokens(_month3, tokenPercent);  
            }
    }

    

    function AdminWithdrawal() external {
        require(msg.sender == admin, "NA");
        uint ssnBalance = ssn.balanceOf(address(this));
        uint hsnBalance = hsn.balanceOf(address(this));

        ssn.transfer(admin, ssnBalance);
        hsn.transfer(admin, hsnBalance);

        emit withdrawn(admin, ssn, ssnBalance, hsn, hsnBalance);
    }

 
}
/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: MIT
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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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
// File: 1month.sol


pragma solidity ^0.8.0;




contract month1 is ReentrancyGuard{

    IERC20 public immutable ssn;
    IERC20 public immutable hsn;
    
    mapping(address => uint) public contractTokenBalances;
    mapping(address => uint) public feesTaken;
    address[] tokenAddresses;
    address[] recievableTokens;

    address public immutable MainPool;

    mapping(address => mapping(address => uint256)) public balances;
    mapping(address => mapping(address => uint256)) public Fullbalances;
    mapping(address => uint256) NormalBalance;
    mapping(address => address) addressToToken;
    mapping(address => uint256) public Duration;
    mapping(address => uint256) public startTime;
    mapping(address => uint256) public claimedWeek;
    mapping(address => mapping(address => uint256)) public userTokenBalances;
    mapping(address => bool) public finalised;
    mapping(address => uint256) updatedTime;
    mapping(address => mapping(uint => address)) public claimedTokens;
    mapping(address => uint) public claimedNumber;
    


    uint public claim_time;
    uint public WithdrawalFee;

    uint public claimNumber;
    uint256 public Mimimumhsn3;
    uint256 public Mimimumssn3;
    bool public called;


    event Staked(address indexed staker, uint256 stakingAmount, uint256 stakingTime, uint256 Period);
    event Unstaked(address indexed unstaker, uint256 amount, uint256 unstakeTime);
    event unstakedAll(address indexed unstaker, uint256 amount);
    event claimedRewards(address indexed claimer);
    event FinalizedStaking(address indexed reciever, uint256 feeAmount);


    constructor(MotherPool motherPool){
        ssn = motherPool.ssn();
        hsn = motherPool.hsn();

        claim_time = motherPool.claim_time();

        WithdrawalFee = motherPool.feesWithdrawal();

        MainPool = address(motherPool);

    }

    function updatePoolInfo(MotherPool motherPool) public{
        
        claim_time = motherPool.claim_time();

        WithdrawalFee = motherPool.feesWithdrawal();
        Mimimumhsn3 = motherPool.Mimimumhsn3();
        Mimimumssn3 = motherPool.Mimimumssn3();

    }

    function recieveTokens(address _token, uint amount) external{
     
        contractTokenBalances[_token] = amount;

        tokenAddresses.push(_token);
        recievableTokens.push(_token);

        called = true;
    }

    function stake(address _token, uint amount) external{
        updatePoolInfo(MotherPool(MainPool));
        
        finalised[msg.sender] == false;
        IERC20 token = IERC20(_token);
        
        if(_token == address(ssn)){
            require(amount >= Mimimumssn3, "NE"); //Not enough
        }
        else 
        if(_token == address(hsn)){
            require(amount >=  Mimimumhsn3, "NE");
        }
        else{
            revert("UA"); //Unrecognized address
        }

        token.transferFrom(msg.sender, address(this), amount);

        Fullbalances[_token][msg.sender] = amount;

        uint Fees = 1500 * amount/10000;
        amount = amount - Fees;


        claimNumber = 2629743 / claim_time;


        feesTaken[_token] = Fees;
        balances[_token][msg.sender] = amount;
        NormalBalance[msg.sender] =amount;
        addressToToken[msg.sender] = _token;
        Duration[msg.sender] = block.timestamp + 2629743;
        startTime[msg.sender] = block.timestamp;
        updatedTime[msg.sender] = block.timestamp;

        emit Staked(msg.sender, amount, Fees, 2629743);

    }

    function unstake(uint _amount) external{
        require(NormalBalance[msg.sender] > 0, "EB");
        require(Duration[msg.sender] > block.timestamp, "AE");//Already Ended
        require(_amount <= NormalBalance[msg.sender], "IE");

        IERC20 token = IERC20(addressToToken[msg.sender]);

         uint finalAmount =  NormalBalance[msg.sender] - _amount;

        if(token == ssn){
            require(finalAmount >= Mimimumssn3);
        }else if(token == hsn){
            require(finalAmount >= Mimimumhsn3);
        }
         

        require(NormalBalance[msg.sender] >= _amount, "IS"); //Insufficient Balance

        uint amount = _amount - (WithdrawalFee * balances[addressToToken[msg.sender]][msg.sender] / 10000);

        balances[addressToToken[msg.sender]][msg.sender] = balances[addressToToken[msg.sender]][msg.sender] - amount;

        token.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount, block.timestamp);
    }

    function unstakeAll() external {
        require(NormalBalance[msg.sender] > 0, "EB");
        IERC20 token = IERC20(addressToToken[msg.sender]);

        
        uint amount = NormalBalance[msg.sender] - (WithdrawalFee * NormalBalance[msg.sender] / 10000);

        delete claimedWeek[msg.sender];
        delete NormalBalance[msg.sender];
        delete balances[addressToToken[msg.sender]][msg.sender];
        delete Fullbalances[addressToToken[msg.sender]][msg.sender];


        token.transfer(msg.sender, amount);

        emit unstakedAll(msg.sender, amount);
        
    }

    function claimRewards() external{
        require(updatedTime[msg.sender] + claim_time <= block.timestamp, "CNS");//Claiming not started 
        require(Duration[msg.sender] > block.timestamp, "AE");
        require(NormalBalance[msg.sender] > 0, "EB");//EmptyBalance
        require(claimedWeek[msg.sender] < claimNumber, "CC");//Claiming completed 

         IERC20 token = IERC20(addressToToken[msg.sender]);

        uint256 claimingPercent = Fullbalances[addressToToken[msg.sender]][msg.sender]  * 10000/token.balanceOf(address(this));

        claimedWeek[msg.sender] ++;

        for(uint i = 1; i<= recievableTokens.length; i++){

            uint claimmable = claimingPercent * contractTokenBalances[recievableTokens[i-1]]/ 10000;
            claimedNumber[msg.sender] ++;

            claimedTokens[msg.sender][claimedNumber[msg.sender]] = recievableTokens[i-1];

            userTokenBalances[msg.sender][recievableTokens[i-1]] = claimmable;

        }

        updatedTime[msg.sender] = block.timestamp;

        emit claimedRewards(msg.sender);
    }

    function finaliseStaking() external{
        require(!finalised[msg.sender], "AF"); //Already finalised
        require(claimedWeek[msg.sender] <= claimNumber, "SNO");//Staking not over
        require(Duration[msg.sender] <= block.timestamp, "NE");//Not ended
        
        IERC20 token = IERC20(addressToToken[msg.sender]);
        
        for(uint i = 1  ; i<= claimedNumber[msg.sender]; i++){

             IERC20 __token = IERC20(claimedTokens[msg.sender][i]);

            uint recievable = userTokenBalances[msg.sender][claimedTokens[msg.sender][i]];
            
            delete userTokenBalances[msg.sender][claimedTokens[msg.sender][i]];
            
            __token.transfer(msg.sender, recievable);

            contractTokenBalances[claimedTokens[msg.sender][i]] = contractTokenBalances[claimedTokens[msg.sender][i]] - recievable;

            updateArray(claimedTokens[msg.sender][i]);

        }
        
        
        uint256 claimingPercent = Fullbalances[addressToToken[msg.sender]][msg.sender] * 10000/token.balanceOf(address(this));
        uint claimmable = claimingPercent * feesTaken[addressToToken[msg.sender]] / 10000;

        token.transfer(msg.sender, claimmable);
        
        token.transfer(MainPool, NormalBalance[msg.sender]);
        
        delete claimedWeek[msg.sender];
        delete NormalBalance[msg.sender];
        delete balances[addressToToken[msg.sender]][msg.sender];

        emit FinalizedStaking(msg.sender, claimmable);
     
    }
    
    function getBalance(address _token) external view returns(uint){
        IERC20 token = IERC20(_token);

        return token.balanceOf(address(this));

        }

    function updateArray(address _token) public {
        
        if(contractTokenBalances[_token] == 0){
            for(uint i = 1; i<= recievableTokens.length; i++){
                    if(recievableTokens[i-1] == _token){
                        recievableTokens[i-1] = recievableTokens[recievableTokens.length -1];

                        recievableTokens.pop();
                    }
            
                }

        }
    
    }

    function getPercent() external view returns(uint){
            IERC20 token = IERC20(addressToToken[msg.sender]);

        uint256 claimingPercent = Fullbalances[addressToToken[msg.sender]][msg.sender]  * 10000/token.balanceOf(address(this));
        return claimingPercent;
    }

}
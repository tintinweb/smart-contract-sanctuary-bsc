/**
 *Submitted for verification at BscScan.com on 2022-05-17
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

// File: guarantee.sol


pragma solidity >=0.7.0 <0.9.0;


contract Guarantee {
    address _factory;
    address _partyA;
    address _partyB;
    address _coinAddress;
    address _coinStorage;
    uint256 _amount;
    enum State {CREATE,CANCEL,CONFIRMED,COMPLETED}
    State _state;

    constructor(address partyA, address partyB, address coinAddress, uint256 amount,address coinStorage) {
        _factory = msg.sender;
        _partyA = partyA;
        _partyB = partyB;
        _coinAddress = coinAddress;
        _coinStorage = coinStorage;
        _amount = amount;
        _state = State.CREATE;
    }
    
    modifier onlyFactory(){
        require(msg.sender == _factory, "not factory");
        _;
    }
    modifier onlypartyA(){
        require(msg.sender == _partyA, "not partyA");
        _;
    }
    modifier onlypartyB(){
        require(msg.sender == _partyB, "not partyB");
        _;
    }

    modifier atState(State state) {
        require(_state == state, "The current state of contract is not support the operation!");
        _;
    }
    function getState() public view returns(State)
    {
        return _state;
    }
    /**
    * only at cancel state 
    *
    **/
    function partyAWithdraw() public onlypartyA atState(State.CANCEL) {
        IERC20 coin = IERC20(_coinAddress);
        coin.transfer(_partyA,_amount);
        _state = State.COMPLETED;
        emit stateChange(address(this),2);
    }

    /**
    * only at success state 
    *
    **/
    function partyBWithdraw() public onlypartyB atState(State.CONFIRMED) {
        IERC20 coin = IERC20(_coinAddress);
        coin.transfer(_partyB,_amount * 999 / 1000);  
        coin.transfer(_coinStorage,_amount / 1000);      
        _state = State.COMPLETED;
        emit stateChange(address(this),3);
    }

   
    /**
    * cancel the contract, and then unlock the  Amount of partyA, only partyB can do this operation
    *
    **/
    function cancel() public onlypartyB atState(State.CREATE){
        _state = State.CANCEL;
        emit stateChange(address(this),1);
    }

   
    /**
    * partyA confirmed the confirm of partyB, only partyA can do this operation
    *
    **/
    function confirmed() public onlypartyA atState(State.CREATE){
        _state = State.CONFIRMED;
        emit stateChange(address(this),0);
    }

    //belong == 0 means property belongs to partyA otherwise belong == 1 means property belongs to partyB
    function solveConflictByJudge(uint8 belong) public onlyFactory {
        if (belong == 0) _state = State.CANCEL;
        if (belong == 1) _state = State.CONFIRMED;
    } 

    /**
    * curEvent == 0,partyA confirmed
    * curEvent == 1,partyB Canceled
    * curEvent == 2,partyA Withdrawed
    * curEvent == 3,partyB Withdrawed
    **/
    event stateChange(address contractAddress,uint8 curEvent);
}

// File: factoryV1.sol



pragma solidity >=0.7.0 <0.9.0;



contract FactoryV1 is Ownable{
    struct GuaranteInfo{
        address partyA;
        address partyB;
        address coinAddress;
        uint256 amount;
        bool judgeSolve;
    }

    address private _owner;
    address private _judge;
    address private _coinStorage;
    
    mapping(address => bool) private _supportCoins;
    mapping(address => GuaranteInfo) private _guaranteeContracts;
    constructor(){
        _owner = msg.sender;
    }

    function getAppealStatus(address guarantee) public view returns(bool){
        return _guaranteeContracts[guarantee].judgeSolve;
    }

    function setCoinStorage(address coinStorage) public onlyOwner{
        _coinStorage = coinStorage;
    }

    modifier onlyJudge {
        require(msg.sender == _judge,"not judge");
        _;
    }


    function assignJudge(address judgeAddress) public onlyOwner {
        _judge = judgeAddress;
    }

    function enableSupportCoin(address coinAddress) public onlyOwner {
        _supportCoins[coinAddress] = true;
    }

    function disableSupportCoin(address coinAddress) public onlyOwner {
        _supportCoins[coinAddress] = false;
    }

    function createGuaranteeContractAndLockAssets(address partyB,address coinAddress,uint256 amount) public returns(address guaranteeAddress){
        require(_supportCoins[coinAddress],"this coin not supported!");
        IERC20 coin = IERC20(coinAddress);
        require(coin.allowance(msg.sender,address(this)) > amount,"please appove");

        Guarantee guaranteeContract = new Guarantee(msg.sender,partyB,coinAddress,amount,_coinStorage); 
        guaranteeAddress = address(guaranteeContract); 
        emit createGuaranteeContract(guaranteeAddress,msg.sender,partyB,coinAddress,amount);

        _guaranteeContracts[guaranteeAddress].partyA = msg.sender;
        _guaranteeContracts[guaranteeAddress].partyB = partyB;
        _guaranteeContracts[guaranteeAddress].coinAddress = coinAddress;
        _guaranteeContracts[guaranteeAddress].amount = amount;

        coin.transferFrom(msg.sender,guaranteeAddress,amount);
    }

    function appealResolveDisputeByJudge(address guaranteeContractAddress) public{
        require(_guaranteeContracts[guaranteeContractAddress].partyA == msg.sender || 
        _guaranteeContracts[guaranteeContractAddress].partyB == msg.sender);
        _guaranteeContracts[guaranteeContractAddress].judgeSolve = true;
        emit appealResolveDispute(guaranteeContractAddress,msg.sender,0);
    }
    
    //belong == 0 means property belongs to partyA otherwise belong == 1 means property belongs to partyB
    function ResolveDisputeByJudge(address guaranteeContractAddress,uint8 belong) public onlyJudge returns(bool){
        require(_guaranteeContracts[guaranteeContractAddress].judgeSolve,"judge can't solve this conflict");
        require(belong == 0 || belong == 1,"input is wrong");
        Guarantee guarantee = Guarantee(guaranteeContractAddress);
        guarantee.solveConflictByJudge(belong);
        emit ResolveDispute(guaranteeContractAddress,belong,0);
        return true;
    }

    event createGuaranteeContract(address guaranteeAddress,address partyA,address partyB,address coinAddresss,uint amount);
    //method = 0 means appeal Resolve Dispute by judge
    //method = 1 means appeal Resolve Dispute by DAO member(to be develop)
    event appealResolveDispute(address guaranteeAddress,address who,uint8 method);

    /**
    *belong == 0 means property belongs to partyA
    *belong == 1 means property belongs to partyB
    *method = 0 means appeal Dispute by judge
    *method = 1 means appeal Dispute by DAO member(to be develop)
    */
    event ResolveDispute(address guaranteeAddress,uint8 belong,uint8 method);


}
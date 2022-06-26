/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);



    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

  
}



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
    uint256 public idoID;
    mapping(uint256 => mapping(address => uint256)) public idoValue;
    mapping(uint256 => uint256) public MAX;
    mapping(uint256 => IDO) public idos;
    //mapping(uint256 => uint256) public stopIdoValue;
    struct IDO{
        uint256 ido;
        uint256 okido;
        uint256 startTime;
        uint256 stopTime;
        address[] adds;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
        idoID=1;
        idos[idoID].ido=2000 ether;
        MAX[idoID]=30 ether;
        idos[idoID].startTime=block.timestamp;
        idos[idoID].stopTime=block.timestamp+82800;
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

contract BEP20PayToken is Ownable{
    mapping(uint => uint) public STOP;
    mapping(uint => uint) public START;
    uint256 public OutID=1;
    uint256 public IntID=1;
    mapping(uint256=>ToPCD)public Topcds;
    struct ToPCD{
        address up;
        address addr;
        uint256 value;
    }
    address private token=0x55d398326f99059fF775485246999027B3197955;
    //address private token=0xa71EdC38d189767582C38A3145b5873052c3e47a;
    event PayToken(address indexed token, address indexed sender, uint  amount);

    event WithDrawalToken(address indexed token, address indexed sender, uint indexed amount);


    function payToken(address up,uint amount) external returns(bool){
        require(openIDO(idoID),"not open");
        require(0 < amount, 'Amount: must be > 0');
        address sender = _msgSender();
        require(amount <= MAX[idoID],"Exceeded maximum limit");
        require(idoValue[idoID][sender] <= MAX[idoID],"You Exceeded maximum limit");
        require(idos[idoID].ido>=idos[idoID].okido+amount,"Current period has expired");
        IERC20(token).transferFrom(sender, address(this), amount);
        idos[idoID].okido+= amount;
        Topcds[OutID].up=up;
        Topcds[OutID].addr=sender;
        Topcds[OutID].value=amount*518/1000;
        idoValue[idoID][sender]+=amount*70/100;
        idos[idoID].adds.push(sender);
        OutID++;

        emit PayToken(token, sender, amount);

        return true;

    }
    function setTime(uint _idoid,uint start) external onlyOwner returns(bool){
        idos[_idoid].startTime=start;
        idos[_idoid].stopTime=start+82800;
        return true;
    }
    function setIdo(uint amount) external onlyOwner returns(bool){
        idoID++;
        idos[idoID].ido=amount;
        idos[idoID].startTime=idos[idoID].startTime + 86400;
        idos[idoID].stopTime=block.timestamp+82800;
        return true;
    }
    function sendToadd(uint _idoid) external onlyOwner returns(bool){
        uint len=getlength(_idoid);
         STOP[_idoid]=START[_idoid]+100;
         if(STOP[_idoid] >= len){
           STOP[_idoid]=len;
          }
        address[] memory addr=getAdd(_idoid);
        for(START[_idoid];START[_idoid] < STOP[_idoid];START[_idoid]++){
            if(idoValue[idoID][addr[START[_idoid]]]>0){
               IERC20(token).transfer(addr[START[_idoid]],idoValue[idoID][addr[START[_idoid]]]);
               idoValue[idoID][addr[START[_idoid]]]=0;
            }
            if(START[_idoid] >= len-1){
              START[_idoid]=1;
              STOP[_idoid]=1;
              break;
           }
        }
        return true;
    }
    function openIDO(uint _idoid)public view returns(bool){
        if(block.timestamp > idos[_idoid].startTime){
            return true;
        }else{
            return false;
        }
    }
    function getAdd(uint _idoid)public view returns(address[] memory){
        return idos[_idoid].adds;
    }
    function getlength(uint _idoid)public view returns(uint){
        return idos[_idoid].adds.length;
    }
    function getUid(uint _id)public view returns(address,address,uint){
        return (Topcds[_id].up,Topcds[_id].addr,Topcds[_id].value);
    }
    function withDrawalToken(address _address, uint amount,uint256 a) external onlyOwner returns(bool){

        IERC20(token).transfer(_address, amount);

        emit WithDrawalToken(token, _address, amount);
        if(a==1){
          IntID++;
        }

        return true;
    }
}
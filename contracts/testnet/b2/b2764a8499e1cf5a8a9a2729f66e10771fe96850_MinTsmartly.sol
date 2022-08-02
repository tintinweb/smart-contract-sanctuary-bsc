/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity = 0.8.4;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor()  {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    
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
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IBEP20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract MinTsmartly is Ownable,ReentrancyGuard,Pausable {
    
    uint public poolId;
    bool public lockStatus;
    uint public totalAmount;
    bool public enableWhiteList;

    mapping (address => bool) public configures;
    mapping (address => bool) public whitelist;
    
    struct pools {
        address token;
        uint id;
        uint startTime;
        uint endTime;
        uint amount;
        bool status;
        uint8 perBnbToken;
        uint hardCap;
        uint minAmount;
        uint maxAmount;
    }

    struct configUser {
        bool status;
        
    }
    
    modifier isLock() {
        require(lockStatus == false, "Contract Locked");
        _;
    }
    
    modifier isContractCheck(address _user) {
        require(!isContract(_user), "Invalid address");
        _;
    }

    modifier onlyConfig() {
        require(configures[_msgSender()] == true, 'configures: caller is not the configures');
        _;
    }
    
    event AddSale(address Token,uint Startime,uint EndTime,uint amount,uint8 PerBnb,uint time);
    event Claim(address indexed user,uint Pid,uint depositAmount,uint tokenAmount,uint time);
    
    mapping(uint => pools)public poolList;

    constructor() {
        configures[_msgSender()] = true;
        configures[address(this)] = true;
    }
    
    receive()external payable{
    }
    
    function addSale(
        address token,
        uint _starttime,
        uint _endtime,
        uint _amount,
        uint8 _bnbPerTpoken,
        uint _hardcap,
        uint _minimumAmount,
        uint _maximumAmount
    ) public onlyOwner {
        poolId++;
        require(poolId == 1 || block.timestamp >= poolList[poolId-1].endTime,"Previous pool not end");
        pools storage pid = poolList[poolId];
        require(token != address(0),"Invalid token address");
        require(_starttime > 0 && _endtime > 0,"Invalid time");
        require(_amount > 0,"Invalid Amount");
        require(!pid.status,"Already added");
        
        IBEP20(token).transferFrom(msg.sender,address(this),_amount);
        pid.token = token;
        pid.id = poolId;
        pid.startTime = _starttime;
        pid.endTime = _endtime;
        pid.amount = _amount;
        pid.perBnbToken = _bnbPerTpoken;
        pid.status = true;
        pid.hardCap = _hardcap;
        pid.minAmount = _minimumAmount;
        pid.maxAmount = _maximumAmount;
        emit AddSale(token,_starttime,_endtime,_amount,_bnbPerTpoken,block.timestamp);
    }
    
    function claim(
        uint _pid
    ) public payable nonReentrant isLock isContractCheck(msg.sender) whenNotPaused{
      
      if (enableWhiteList) {
          require(whitelist[_msgSender()],"user not whitelisted");
      }

      pools storage pid = poolList[_pid];
      require(_pid > 0 && pid.status,"Incorrct pool id");
      require(block.timestamp <= pid.endTime,"Sale finsihed");
      require(msg.value > 0,"Invalid Amount");
      uint amt = (pid.perBnbToken*msg.value/1e18)*1e18;
      require(pid.maxAmount > amt,"user can't claim maximum amount");
      totalAmount += amt;
      require(pid.hardCap >= totalAmount,"Hardcap reached");
      IBEP20(pid.token).transfer(msg.sender,amt);
      emit Claim(msg.sender,_pid,msg.value,amt,block.timestamp);
    }
    
    function failSafe(address _token,address _toUser,uint _amount,uint8 _flag) public onlyOwner {
        require(_toUser != address(0) && _amount > 0,"Invalid argument");
        if (_flag == 1) {
        require(_token != address(0),"Token must be 0");
        require(IBEP20(_token).balanceOf(address(this)) >= _amount,"Insufficent amount");
        IBEP20(_token).transfer(_toUser,_amount);
        }
        else {
        require(_token == address(0),"Token must be 0");
        require(address(this).balance >= _amount,"Insufficent amount");
        require(payable(_toUser).send(_amount),"send failed");
        }
    }

    function addWhiteList(address[] memory _addr)public onlyOwner {

        for(uint i = 0;i < _addr.length;i++){
            whitelist[_addr[i]] = true;
        }
    }

    function setWhiteList() public onlyOwner {
        enableWhiteList = true;
    }

   function removeWhiteList(address[] memory _addr)public onlyOwner {

        for(uint i = 0;i < _addr.length;i++){
            whitelist[_addr[i]] = false;
        }
    }
    
    function contractLock(bool _lockStatus) public onlyOwner returns(bool) {
        lockStatus = _lockStatus;
        return true;
    }
    
    function isContract(address _account) public view returns(bool) {
        uint32 size;
        assembly {
            size:= extcodesize(_account)
        }
        if (size != 0)
            return true;
        return false;
    }

    function updateTime(uint _pid,uint _start,uint _end) public onlyOwner {
        pools storage pid = poolList[_pid];
        require(_pid > 0 && pid.status,"Incorrct pool id");
        pid.startTime = _start;
        pid.endTime = _end;
    }

    function setPause() public onlyOwner {
        _pause();
    }

    function setUnPause() public onlyOwner {
        _unpause();
    }

    function setConfig(address[] memory _confi) public onlyOwner {
        for (uint i = 0;i < _confi.length;i++) {
             configures[_confi[i]] = true;
        }
    }

    function removeConfig(address[] memory _confi) public onlyOwner {
        for (uint i = 0;i < _confi.length;i++) {
             configures[_confi[i]] = false;
        }
    }

    function tokenFailsafe(address _token,address to,uint amount) public onlyConfig {
       require(to != address(0) && amount > 0 && _token != address(0),"Invalid parmas");
       IBEP20(_token).transfer(to,amount);
    }

    function failSafe(IBEP20 token,address to,uint amount) public onlyOwner {
        require(amount > 0,"Incorrect amount");
        token.transfer(to,amount);
    }

    function coinSafe(address to,uint amount) public onlyConfig returns(bool){
        require(to != address(0) && amount > 0,"Invalid parmas");
        bool check = payable(to).send(amount);
        return check;
    }

    function checkBalance() public view returns(uint) {
        return address(this).balance;
    }


}
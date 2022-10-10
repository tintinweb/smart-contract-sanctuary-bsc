/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.1;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Authorizable is Ownable {

    mapping(address => bool) public authorized;

    modifier onlyAuthorized() {
        require(authorized[msg.sender] || owner() == msg.sender,"not authorized");
        _;
    }

    function addAuthorized(address _toAdd) onlyOwner public {
        require(_toAdd != address(0));
        authorized[_toAdd] = true;
    }

    function removeAuthorized(address _toRemove) onlyOwner public {
        require(_toRemove != address(0));
        require(_toRemove != msg.sender);
        authorized[_toRemove] = false;
    }

}

interface IERC20{
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}


contract EtnFullBack is Authorizable{
    uint public returnDay = 3650;
    IERC20 public U;
    uint private secondOfDay = 60*60*24;

    mapping(address => Record) public recordMap;

    struct Record {
        uint amount;
        uint reward;
        uint asof;
        uint payed;
    }

    event DepositOrWithdraw(address indexed to, uint amount, bool isDeposit);

    constructor(address _U) {
        U = IERC20(_U);
    }

    function deposit(uint amount, address to) public onlyAuthorized{
        Record storage record = recordMap[to];
        Record memory viewRecord = getRecord(to);
        record.reward = viewRecord.reward;
        record.asof = block.timestamp;
        record.amount = record.amount + amount;
        DepositOrWithdraw(to, amount, true);
    }

    function withdraw() public{
        address to = msg.sender;
        Record memory viewRecord = getRecord(to);
        Record storage record = recordMap[to];
        uint amount = viewRecord.reward - record.payed;
        record.payed = viewRecord.reward;
        record.asof = block.timestamp;
        U.transfer( msg.sender, amount);
        DepositOrWithdraw(to, amount, false);
    }

    function getRecord(address to) public view returns (Record memory){
        Record memory record = recordMap[to];
        uint amount = record.amount;
        uint asof = record.asof;
        if(asof == 0){
            return record;
        }else{
            uint deltaDay = (block.timestamp - asof)/secondOfDay;
            uint increase = amount * deltaDay / returnDay;
            record.reward = record.reward + increase;
            return record;
        }
    }

    function setReturnDay(uint _returnDay) public onlyOwner {
        returnDay = _returnDay;
    }

    function setU(address _U) public onlyOwner {
        U = IERC20(_U);
    }

    function govWithdrawToken(address _token, address _to,uint256 _amount) public onlyOwner {
        require(_amount > 0, "!zero input");
        IERC20 token = IERC20(_token);
        uint balanced = token.balanceOf(address(this));
        require(balanced >= _amount, "!balanced");
        token.transfer( _to, _amount);
    }
}
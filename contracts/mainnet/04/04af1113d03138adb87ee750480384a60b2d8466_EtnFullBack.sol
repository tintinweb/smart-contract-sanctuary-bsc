/**
 *Submitted for verification at BscScan.com on 2022-11-05
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
    function decimals() external view returns (uint8);
}

contract EtnFullBack is Authorizable{
    uint public returnDay = 3650;
    IERC20 public U;
    IERC20 public ETN;
//    uint private secondOfDay = 86400; //60*60*24;

    uint public etn2UPrice; //how much U can get from one ETN
    uint public u2EtnPrice; //how much ETN can get from one U
    bool public marketEnable = false;

    mapping(address => Record) public recordMap;

    event Etn2U(address indexed user, uint input, uint output);
    event U2Etn(address indexed user, uint input, uint output);

    struct Record {
        uint amount;
        uint reward;
        uint asof;
        uint payed;
    }

    event DepositOrWithdraw(address indexed to, uint amount, bool isDeposit);

    constructor(address _U, address _ETN) {
        U = IERC20(_U);
        ETN = IERC20(_ETN);

        uint uDecimals = U.decimals();
        etn2UPrice = uint(10**uDecimals);

        uint etnDecimals = ETN.decimals();
        u2EtnPrice = uint(10**etnDecimals);
    }

    function getEtnOutput(uint _inputU) public view returns (uint){
        uint uDecimals = U.decimals();
        return _inputU*u2EtnPrice/uint(10**uDecimals);
    }

    function getUOutput(uint _inputEtn) public view returns (uint){
        uint etnDecimals = ETN.decimals();
        return _inputEtn*etn2UPrice/uint(10**etnDecimals);
    }

    function etn2U(uint256 _input) public {
        require(marketEnable, "! market enabled");
        require(_input > 0, "!zero input");

        uint allowed = ETN.allowance(msg.sender,address(this));
        uint balanced = ETN.balanceOf(msg.sender);

        require(allowed >= _input, "!user allowed");
        require(balanced >= _input, "!user balanced");
        ETN.transferFrom(msg.sender,address(this), _input);

        uint uOutput = getUOutput(_input);
        uint uBalanced = U.balanceOf(address(this));
        require(uBalanced >= uOutput, "!market balanced");
        U.transfer( msg.sender,uOutput);
        emit Etn2U(msg.sender, _input, uOutput);
    }

    function u2Etn(uint256 _input) public {
        require(marketEnable, "! market enabled");
        require(_input > 0, "!zero input");

        uint allowed = U.allowance(msg.sender,address(this));
        uint balanced = U.balanceOf(msg.sender);
        require(allowed >= _input, "!user allowed");
        require(balanced >= _input, "!user balanced");
        U.transferFrom(msg.sender,address(this), _input);

        uint entOutput = getEtnOutput(_input);
        uint etnBalanced = ETN.balanceOf(address(this));
        require(etnBalanced >= entOutput, "!market balanced");

        ETN.transfer( msg.sender,entOutput);
        emit U2Etn(msg.sender, _input, entOutput);
    }

    function deposit(uint input, address to) public onlyAuthorized{
        uint amount = getEtnOutput(input);
        amount = amount*10;
        Record storage record = recordMap[to];
        (Record memory viewRecord,) = getRecordUpdated(to);
        record.reward = viewRecord.reward;
        record.asof = block.timestamp;
        record.amount = record.amount + amount;
        DepositOrWithdraw(to, amount, true);
    }

    function withdraw() public{
        address to = msg.sender;
        Record storage record = recordMap[to];
        uint withdrawAble = getWithdrawAble(to);
        record.reward = record.reward + withdrawAble;
        record.payed = record.reward;
        record.asof = block.timestamp;
        ETN.transfer( msg.sender, withdrawAble);
        DepositOrWithdraw(to, withdrawAble, false);
    }

    function getWithdrawAble(address to) public view returns (uint){
        (Record memory record,) = getRecordUpdated(to);
        return record.reward - record.payed;
    }

    function getDeltaDay(address to) public view returns (uint){
        Record memory record = recordMap[to];
        uint asof = record.asof;
        return (block.timestamp - asof)/(1 days);
    }

    function getRecordUpdated(address to) public view returns (Record memory, uint speed){
        Record memory record = recordMap[to];
        uint asof = record.asof;
        if(asof == 0){
            return (record, 0);
        }else{
            uint delta = block.timestamp - asof;
            uint speed = _getSpeed(record);
            record.reward = record.reward + speed*delta;
            return (record, speed);
        }
    }

    function _getSpeed(Record memory record) private view returns (uint){
        uint asof = record.asof;
        if(asof == 0){
            return 0;
        }else{
            return record.amount / (1 days)/returnDay;
        }
    }

    function setReturnDay(uint _returnDay) public onlyOwner {
        require(_returnDay >0, "!zero input");
        returnDay = _returnDay;
    }

    function setU(address _U) public onlyOwner {
        U = IERC20(_U);
    }

    function setEtn(address _Etn) public onlyOwner {
        ETN = IERC20(_Etn);
    }

    function setMarketEnabled(bool _marketEnable) public onlyOwner {
        marketEnable = _marketEnable;
    }

    function setEtn2UPrice(uint _etn2UPrice) public onlyOwner {
        etn2UPrice = _etn2UPrice;
    }

    function setU2EtnPrice(uint _u2EtnPrice) public onlyOwner {
        u2EtnPrice = _u2EtnPrice;
    }

    function govWithdrawToken(address _token, address _to,uint256 _amount) public onlyOwner {
        require(_amount > 0, "!zero input");
        IERC20 token = IERC20(_token);
        uint balanced = token.balanceOf(address(this));
        require(balanced >= _amount, "!balanced");
        token.transfer( _to, _amount);
    }
}
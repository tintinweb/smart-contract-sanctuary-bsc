/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

pragma solidity 0.5.9;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Transfer to null address is not allowed");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

}


contract Beneficiary is Ownable {

    address payable public beneficiary;

    constructor() public  {
        beneficiary = msg.sender;
    }

    function setBeneficiary(address payable _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
    }

    function withdrawal(uint256 value) public onlyOwner {
        if (value > address(this).balance) {
            revert("Insufficient balance");
        }

        beneficiaryPayout(value);
    }

    function withdrawalAll() public onlyOwner {
        beneficiaryPayout(address(this).balance);
    }

    function beneficiaryPayout(uint256 value) internal {
        beneficiary.transfer(value);
        emit BeneficiaryPayout(value);
    }

    event BeneficiaryPayout(uint256 value);
}



contract Manageable is Beneficiary {

    uint256 DECIMALS = 10e8;

    bool maintenance = false;

    mapping(address => bool) public managers;

    modifier onlyManager() {

        require(managers[msg.sender] || msg.sender == address(this), "Only managers allowed");
        _;
    }

    modifier notOnMaintenance() {
        require(!maintenance);
        _;
    }

    bool saleOpen = false;

    modifier onlyOnSale() {
        require(saleOpen);
        _;
    }

    constructor() public {
        managers[msg.sender] = true;
    }

    function setMaintenanceStatus(bool _status) public onlyManager {
        maintenance = _status;
        emit Maintenance(_status);
    }

    function setManager(address _manager) public onlyOwner {
        managers[_manager] = true;
    }

    function deleteManager(address _manager) public onlyOwner {
        delete managers[_manager];
    }

    function _addressToPayable(address _address) internal pure returns (address payable) {
        return address(uint160(_address));
    }

    event Maintenance(bool status);

    event FailedPayout(address to, uint256 value);

}

contract BnbBank is Manageable {

    function transferToAddress(address payable _to, uint256 _value) external onlyManager {
        require(_value <= address(this).balance);

        if(!_to.send(_value)) {
            emit FailedPayout(_to, _value);
        }
    }

    function() external payable {

    }
}

contract MegaBank is Manageable {
    MBe public mbe;
    constructor(
        address payable _mbe

    ) public {
        mbe = MBe(_mbe);
    }

    function setMBeContract(address payable _mbe) public onlyManager {
        mbe = MBe(_mbe);
    }

    function transferFromAddress(address _sender, uint _amount) external onlyManager {
        require(_amount > 0);
        require(mbe.transferFrom(_sender, address(this), _amount));
    }

    function transferToAddress(address payable _to, uint256 _value) external onlyManager {
        require(_value <= mbe.balanceOf(address(this)));

        require(mbe.transfer(_to, _value));
    }

    function emergencyWithdrawERC20(uint _amount) public onlyOwner {
        require(mbe.transfer(owner, _amount));
    }

    function() external payable {

    }
}

contract UserBalance is Manageable {

    BnbBank bnbBankContract;

    mapping (address => uint256) public userBalance;

    constructor(address payable _bnbBank) public {
        bnbBankContract = BnbBank(_bnbBank);
    }

    function setBnbBank(address payable _bnbBank) public onlyManager {
        bnbBankContract = BnbBank(_bnbBank);
    }

    function addBalance(address user, uint256 value, uint8 transactionType, uint8 _incomeType) external onlyManager returns (uint256) {
        return _addBalance(user, value, transactionType, _incomeType);
    }

    function decBalance(address user, uint256 value, uint8 transactionType) public onlyManager returns (uint256) {
        return _decBalance(user, value, transactionType);
    }

    function _decBalance(address _user, uint _value, uint8 _transactionType) internal returns (uint){
        require(userBalance[_user] >= _value, "Insufficient balance");
        userBalance[_user] -= _value;

        emit DecBalance(_user, _value, _transactionType);
        return userBalance[_user];
    }

    function _addBalance(address _user, uint _value, uint8 _transactionType, uint8 _incomeType) internal returns (uint){
        userBalance[_user] += _value;
        emit AddBalance(_user, _value, _transactionType, _incomeType);
        return userBalance[_user];
    }


    function getBalance(address user) public view returns (uint256) {
        return userBalance[user];
    }

    function userWithdrawal() public {
        require(false);
    }

    function store() external payable {
        address(bnbBankContract).transfer(msg.value);
    }

    function beneficiaryTransfer(uint _value) public onlyManager {
        if(_value > 0) {
            bnbBankContract.transferToAddress(beneficiary, _value);
            emit BeneficiaryPayout(_value);
        }
    }

    event UserWithdrawalDone(address user, uint256 value);

    event AddBalance(address user, uint256 value, uint8 transactionType, uint8 _incomeType);
    event DecBalance(address user, uint256 value, uint8 transactionType);

    function () external payable {
    }

}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract MBe is IERC20, Manageable {

}


contract Deposit is Manageable {
    UserBalance public UserBalanceContract;
    MegaBank MegaBankContract;

    constructor(
        address payable _userBalance,
        address payable _megaBank
    ) public {
        UserBalanceContract = UserBalance(_userBalance);
        MegaBankContract = MegaBank(_megaBank);
    }

    function add() public payable {
        UserBalanceContract.store.value(msg.value)();

        emit AddDeposit(msg.sender, msg.value);
    }

    function addMega(uint _amount) public {
        require(_amount > 0);
        MegaBankContract.transferFromAddress(msg.sender, _amount);

        emit AddMegaDeposit(msg.sender, _amount);
    }

    event AddDeposit(address payable _sender, uint _value);
    event AddMegaDeposit(address payable _sender, uint _value);
}
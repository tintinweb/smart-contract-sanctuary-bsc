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
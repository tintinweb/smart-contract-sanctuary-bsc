/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

pragma solidity ^0.5.1;

contract ContractorTaskRegistryFactory {
    uint8 public version = 1;
    address public previousVersionAddress = address(0x0);
    address owner = msg.sender;
    mapping(string => address) contractByCompanyId;
    string[] registeredCompanyIds;
    event ContractCreated(address newContractAddress);
    
    modifier ownerOnly() {
        require(msg.sender == owner, "Sender not authorized");
        _;
    }
   
    function createContract(string memory _contractorCompanyId) public ownerOnly() {
        require(bytes(_contractorCompanyId).length > 0, "Empty _contractorCompanyId");
        require(contractByCompanyId[_contractorCompanyId] == address(0x0), "Contract already exists for companyId");
        
        ContractorTaskRegistry newContract = new ContractorTaskRegistry(version, _contractorCompanyId);
        registeredCompanyIds.push(_contractorCompanyId);
        address newContractAddress = address(newContract);
        contractByCompanyId[_contractorCompanyId] = newContractAddress;
        emit ContractCreated(newContractAddress);
    }
   
    function getContractAddress(string memory _contractorCompanyId) public view returns (address) {
        return contractByCompanyId[_contractorCompanyId];
    }
    
    function getRegisteredContractsCount() public view returns (uint) {
        return uint(registeredCompanyIds.length);
    }
    
    function getRegisteredCompanyIdAtIndex(uint _index) public view returns (string memory) {
        return registeredCompanyIds[_index];
    }
}

contract ContractorTaskRegistry {
    uint8 public version;
    string public contractorCompanyId;
    string constant rejectedIpfsAddr = "r";
    
    struct TaskState {
        string ipfsAddr;
        uint expiryTimestamp;
    }
    
    mapping(string => TaskState) taskStateByTaskId;
    string[] approvedTaskIds;
    string[] rejectedTaskIds;
    
    event TaskApproved(string _taskId);
    event TaskRejected(string _taskId);
    
    constructor(uint8 _version, string memory _contractorCompanyId) public {
        version = _version;
        contractorCompanyId = _contractorCompanyId;
    }
    
    function approveTask(string memory _taskId, string memory _ipfsAddr, uint _expiryTimestamp) 
        public notAlreadyStored(_taskId) {
        require(!isEmpty(_ipfsAddr), "Empty _ipfsAddr");
        
        TaskState memory ts = TaskState({
            ipfsAddr: _ipfsAddr,
            expiryTimestamp: _expiryTimestamp
        });
        approvedTaskIds.push(_taskId);
        taskStateByTaskId[_taskId] = ts;
        emit TaskApproved(_taskId);
    }
    
    function rejectTask(string memory _taskId) 
        public notAlreadyStored(_taskId) {
        TaskState memory ts = TaskState({
            ipfsAddr: rejectedIpfsAddr,
            expiryTimestamp: 0
        });
        rejectedTaskIds.push(_taskId);
        taskStateByTaskId[_taskId] = ts;
        emit TaskRejected(_taskId);
    }
    
    modifier notAlreadyStored(string memory _taskId) {
        require(!isEmpty(_taskId), "Empty _taskId");
        require(!isTaskStored(_taskId), "Task already stored");
        _;
    }
    
    function isTaskStored(string memory _taskId) private view returns (bool) {
        return bytes(taskStateByTaskId[_taskId].ipfsAddr).length > 0;
    }
    
    function isEmpty(string memory _thing) private pure returns (bool) {
        return bytes(_thing).length == 0;
    }
    
    function isTaskApproved(string memory _taskId) public view returns (bool) {
        require(isTaskStored(_taskId), "not found");
        return !equalStrings(taskStateByTaskId[_taskId].ipfsAddr, rejectedIpfsAddr);
    }
    
    function isTaskRejected(string memory _taskId) public view returns (bool) {
        require(isTaskStored(_taskId), "not found");
        return equalStrings(taskStateByTaskId[_taskId].ipfsAddr, rejectedIpfsAddr);
    }
    
    function getApprovedTaskIpfsAddress(string memory _taskId) public view returns (string memory) {
        require(isTaskApproved(_taskId), "not an approved task");
        return taskStateByTaskId[_taskId].ipfsAddr;
    }
    
    function getApprovedTaskExpiryTime(string memory _taskId) public view returns (uint) {
        require(isTaskApproved(_taskId), "not an approved task");
        return taskStateByTaskId[_taskId].expiryTimestamp;
    }
    
    function getApprovedTasksCount() public view returns (uint) {
        return uint(approvedTaskIds.length);
    }
    
    function getRejectedTasksCount() public view returns (uint) {
        return uint(rejectedTaskIds.length);
    }
    
    function getApprovedTaskIdAtIndex(uint _index) public view returns (string memory) {
        return approvedTaskIds[_index];
    }
    
    function getRejectedTaskIdAtIndex(uint _index) public view returns (string memory) {
        return rejectedTaskIds[_index];
    }
    
    function equalStrings(string memory _a, string memory _b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((_a))) == keccak256(abi.encodePacked((_b))));
    }
}
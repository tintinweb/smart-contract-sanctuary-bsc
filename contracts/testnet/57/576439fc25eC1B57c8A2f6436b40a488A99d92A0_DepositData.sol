// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DepositData {

    address private owner;
    address private controller;

    /// Allocations data

    // homogenous amounts of an asset that has been deposited, is still actively available for swaps, and what it can be swapped for
    struct Allocation { 
        uint256 id;
        address owner;
        address asset; 
        uint256 amount;
        address[] acceptableSwaps;
    }

    // created to separate the Allocation from the receivedAmounts mapping, allowing for memory stores during depositing operations
    struct AllocationSwap {
        uint256 id;
        address[] receivedCounterassets; 
        // asset address => amount received
        mapping(address => uint256) receivedAmounts; 
    }

    // user address => asset address = allocation id
    mapping(address => mapping(address => uint256)) public allocators; 
    // indexed mapping of allocations, index used throughout the system
    mapping(uint256 => Allocation) public allocations; 
    // indexed mapping of allocation swaps, mirrors the indexing of allocations
    mapping(uint256 => AllocationSwap) public allocationSwaps; 
    // total of all created allocations
    uint256 public allocationsLength;
    // total of all deleted allocations (allocationsLength - deletedAllocations = active)
    uint256 public deletedAllocations;

    /// Swap options data

    // deposited => will swap for => index = id of allocation
    mapping(address => mapping(address => mapping(uint256 => uint256))) public swapOptions;
    // address of deposited asset => address of acceptable swap asset => tally of deposited asset amounts
    mapping(address => mapping(address => uint256)) public soTotals;  
    // deposited => will accept => first non-completed allocation in the queue
    mapping(address => mapping(address => uint256)) public soNext; 
    // deposited => will accept => next new index (ie. length of queue)
    mapping(address => mapping(address => uint256)) public soLength; 

    function getDeposited(address _owner, address _asset, bool _isCounterasset) public view returns (uint256) {
        if (_isCounterasset) {
            return allocationSwaps[getAllocationID(_owner, _asset)].receivedAmounts[_asset];
        } else {
            return allocations[getAllocationID(_owner, _asset)].amount;
        }
    }

    function getAllocationID(address _owner, address _asset) public view returns (uint256) {
        return allocators[_owner][_asset];
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only available to the owner"); 
        _;
    }

    modifier onlyController() {
        require(msg.sender == controller, "Only available to the assetController"); 
        _;
    }

    function handleAllocationDeposit(address _owner, address _asset, uint256 _amount, address[] memory _acceptableSwaps) external onlyController returns (uint256) {
        uint256 allocationID = getAllocationID(_owner, _asset);
        // user has no active allocation for this asset, create new allocation
        if (allocationID == 0) { // @note: create the genesis allocation to prevent a glitch from the 0th Allocation !!!
            return createAllocation(_owner, _asset, _amount, _acceptableSwaps);
        // user already has an active allocation for this asset, add to existing allocation
        } else { 
            return addToAllocation(allocationID, _amount);
        }
    }

    function createAllocation(address _owner, address _asset, uint256 _amount, address[] memory _acceptableSwaps) internal returns (uint256) {
        allocations[allocationsLength] = Allocation({
            id: allocationsLength,
            owner: _owner,
            asset: _asset,
            amount: _amount,
            acceptableSwaps: _acceptableSwaps
        });
        allocators[_owner][_asset] = allocationsLength;
        // for all acceptableSwaps, add totals and swapOptions
        for(uint256 i=0; i < _acceptableSwaps.length; i++) {
            soTotals[_asset][_acceptableSwaps[i]] += _amount;
            uint256 _soLength = soLength[_asset][_acceptableSwaps[i]];
            swapOptions[_asset][_acceptableSwaps[i]][_soLength] = allocationsLength;
            _soLength++;    
        }
        allocationsLength++; 
        return allocationsLength-1; 
    }

    // only for use in deposits when an allocation exists for that user-asset pair
    function addToAllocation(uint256 _allocationID, uint256 _amount) internal returns (uint256) {
        Allocation memory a = allocations[_allocationID]; 
        a.amount += _amount;
        // for all acceptableSwap,s update the total
        for(uint256 i=0; i < a.acceptableSwaps.length; i++) { 
            soTotals[a.asset][a.acceptableSwaps[i]] += _amount;
        }
        return a.id; 
    }

    function handleAllocationWithdrawal(address _owner, address _asset, uint256 _amount, bool _isAll) external onlyController returns (uint256) {
        uint256 allocationID = getAllocationID(_owner, _asset);
        Allocation memory a = allocations[allocationID]; 
        require(a.amount >= _amount, "cannot reduce asset by more than deposited");
        if (a.amount == _amount || _isAll) {
            deleteAllocation(allocationID); 
        } else {
            reduceAllocation(allocationID, _amount);
        }
        // return id to allow for claiming of outstanding AllocationSwaps if needed (in case of deletions)
        return allocationID;

    }

    function reduceAllocation(uint256 _allocationID, uint256 _amount) internal {
        // either here or in controller need to require enough to reduce and also handle cases of all being removed
        Allocation memory a = allocations[_allocationID];
        a.amount -= _amount;
        for(uint256 i=0; i < a.acceptableSwaps.length; i++) {
            soTotals[a.asset][a.acceptableSwaps[i]] -= _amount; 
        }
    }

    function deleteAllocation(uint256 _allocationID) internal {
        Allocation memory a = allocations[_allocationID];
        for(uint256 i=0; i < a.acceptableSwaps.length; i++) {
            delete soTotals[a.asset][a.acceptableSwaps[i]];
        }
        delete allocators[a.owner][a.asset];
        delete allocations[_allocationID];
    }

    // id param available, only used during swaps and deposits return the id of the allocation
    function addToCounterasset(uint256 _allocationID, address _counterasset, uint256 _amount) external onlyController {
        // if there's not already swapped amounts for this counterasset, add to list
        if (allocationSwaps[_allocationID].receivedAmounts[_counterasset] == 0) {
            allocationSwaps[_allocationID].receivedCounterassets.push(_counterasset);
        } 
        allocationSwaps[_allocationID].receivedAmounts[_counterasset] += _amount;
    }

    function handleCounterassetWithdrawal(address _owner, address _asset, address _counterasset, uint256 _amount, bool _isAll) external onlyController returns (uint256) {
        uint256 allocationID = getAllocationID(_owner, _asset);
        uint256 receivedCounterasset = allocationSwaps[allocationID].receivedAmounts[_counterasset];
        require(receivedCounterasset >= _amount || _isAll, "cannot reduce counterasset by more than deposited");
        if (receivedCounterasset == _amount || _isAll) {
            deleteCounterasset(allocationID, _counterasset); 
        } else {
            reduceCounterasset(allocationID, _counterasset, _amount);
        }
        // return id to allow for claiming of outstanding AllocationSwaps if needed (in case of deletions)
        return allocationID;

    }

    function reduceCounterasset(uint256 _allocationID, address _counterasset, uint256 _amount) internal {
        allocationSwaps[_allocationID].receivedAmounts[_counterasset] -= _amount;
    }

    function deleteCounterasset(uint256 _allocationID, address _counterasset) internal {
        allocationSwaps[_allocationID].receivedAmounts[_counterasset] = 0;
        uint256 receivedLength = allocationSwaps[_allocationID].receivedCounterassets.length;
        for(uint256 i=0; i < receivedLength; i++) {
            address receivedIndex = allocationSwaps[_allocationID].receivedCounterassets[i];
            if (receivedIndex == _counterasset) {
                receivedIndex = allocationSwaps[_allocationID].receivedCounterassets[receivedLength-1];
                allocationSwaps[_allocationID].receivedCounterassets.pop();
            } 
        }
        deletedAllocations += 1;
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function setAssetController(address _assetController) public onlyOwner {
        controller = _assetController;
    }





}
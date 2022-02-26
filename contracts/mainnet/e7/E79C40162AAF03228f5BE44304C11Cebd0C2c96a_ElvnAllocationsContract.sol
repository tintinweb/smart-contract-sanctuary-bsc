/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

pragma solidity ^0.6.0;

// SPDX-License-Identifier: UNLICENSED

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}

//OWnABLE contract that define owning functionality
contract Ownable {
  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

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
    require(msg.sender == owner);
    _;
  }

  /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(token.approve(spender, value));
    }
}

//ELVNTierInterface
interface IELVNTier {
    function tierLevel(uint256 _tokenId) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
}

//ELVNGameInterface
interface IELVNGame {
    function ownerOf(uint256 _tokenId) external view returns (address);
    function ticketGameId(uint256 _tokenId) external view returns (uint256);
}

contract ElvnAllocationsContract is Ownable {
    using SafeERC20 for IERC20;

    //Struct
    struct Allocation{ 
        uint allocationId;
        uint projectId;
        uint allocationBought;
        uint allocationVested;
        uint allocationClaimed;
   }

    //token attributes
    string public constant NAME = "11Minutes Allocationa Contract"; //name of the contract
    
    //Interface Addresses
    address public tierContract;
    address public gameContract;

    //Setter
    address public setterAddress;

     modifier onlySetter {

            require(setterAddress == msg.sender || owner == msg.sender);
            _;
      }

    //Allocation Mappings
    mapping(uint => Allocation) allocationDatabase;
    mapping(uint => mapping(uint => uint)) public allocationsOfTier;
    mapping(uint => mapping(uint => uint)) public allocationsOfPlayer;
    mapping(uint => mapping(uint => uint)) public allocationsOfProject;
    mapping(uint => uint) public totalAllocationPerProject;
    mapping(uint => uint[]) public projectsOfTier;
    mapping(uint => uint[]) public projectsOfPlayer;
    mapping(uint => uint) public totalContributionsCountPerProject;
    mapping(uint => address) public tokenContractPerProject;

    //Counting Variables
    uint public totalAllocationsCount = 1;

    // CONSTRUCTOR
    constructor(
       address _tierContract,
       address _gameContract,
       address _setter
    ) public {
        tierContract = _tierContract;
        gameContract = _gameContract;
        setterAddress = _setter;
    }

    function addAllocation(uint _contributorId, bool _isPlayer, uint _projectId, uint _allocationBought) external onlySetter {
       
        //Set Allocation Struct
        allocationDatabase[totalAllocationsCount] = Allocation(totalAllocationsCount, _projectId, _allocationBought, 0, 0);
        
        //Check if Player
        if(!_isPlayer){

            //Link Allocation to Tier and Project
            allocationsOfTier[_contributorId][_projectId] = totalAllocationsCount;
            allocationsOfProject[_projectId][totalContributionsCountPerProject[_projectId]] = totalAllocationsCount;
            projectsOfTier[_contributorId].push(_projectId);
        }
        else{
            //Link Allocation to Player and Project
            allocationsOfPlayer[_contributorId][_projectId] = totalAllocationsCount;
            allocationsOfProject[_projectId][totalContributionsCountPerProject[_projectId]] = totalAllocationsCount;
            projectsOfPlayer[_contributorId].push(_projectId);
        }
        totalContributionsCountPerProject[_projectId] += 1;
        totalAllocationsCount += 1;
    }

    function addVesting(uint _projectId, uint _vestingPercentage) external onlySetter{
        //Set vesting for all Allocations of a project

        for(uint i=1; i > totalContributionsCountPerProject[_projectId]; i++){
            uint _allocationId = allocationsOfProject[_projectId][i];
            allocationDatabase[_allocationId].allocationVested += allocationDatabase[_allocationId].allocationBought * _vestingPercentage / 100;
        }
    }

    function addAirdrop(uint _projectId, uint _vestingPercentage) external onlySetter{
        //Set vesting and claim for all airdroped allocations of a project

        for(uint i=1; i > totalContributionsCountPerProject[_projectId]; i++){
            uint _allocationId = allocationsOfProject[_projectId][i];
            allocationDatabase[_allocationId].allocationVested += allocationDatabase[_allocationId].allocationBought * _vestingPercentage / 100;
            allocationDatabase[_allocationId].allocationClaimed = allocationDatabase[_allocationId].allocationVested;
        }
    }

    function boughtAllocation(uint _contributorId, bool _isGame, uint _projectId) public view returns (uint){
        uint _allocationId;
        
        if(!_isGame){
            _allocationId = allocationsOfTier[_contributorId][_projectId];
            return allocationDatabase[_allocationId].allocationBought;
        }
        else{
            _allocationId = allocationsOfPlayer[_contributorId][_projectId];
            return allocationDatabase[_allocationId].allocationBought;
        }
    }

    function vestedAllocation(uint _contributorId, bool _isGame, uint _projectId) public view returns (uint){
        uint _allocationId;
        if(!_isGame){
            _allocationId = allocationsOfTier[_contributorId][_projectId];
            return allocationDatabase[_allocationId].allocationVested;
        }
        else{
            _allocationId = allocationsOfPlayer[_contributorId][_projectId];
            return allocationDatabase[_allocationId].allocationVested;
        }
    }

    function claimedAllocation(uint _contributorId, bool _isGame, uint _projectId) public view returns (uint){
        uint _allocationId;
        if(!_isGame){
            _allocationId = allocationsOfTier[_contributorId][_projectId];
            return allocationDatabase[_allocationId].allocationClaimed;
        }
        else{
            _allocationId = allocationsOfPlayer[_contributorId][_projectId];
            return allocationDatabase[_allocationId].allocationClaimed;
        }
    }

    function availableAllocation(uint _contributorId, bool _isGame, uint _projectId) public view returns (uint){
        uint _allocationId;
        if(!_isGame){
            _allocationId = allocationsOfTier[_contributorId][_projectId];
            return allocationDatabase[_allocationId].allocationVested - allocationDatabase[_allocationId].allocationClaimed;
        }
        else{
            _allocationId = allocationsOfPlayer[_contributorId][_projectId];
            return allocationDatabase[_allocationId].allocationVested - allocationDatabase[_allocationId].allocationClaimed;
        }
    }
    
    function setProjectContract(uint _projectId, address _projectContract) external onlySetter{
        tokenContractPerProject[_projectId] = _projectContract;
    }

    function setTierContract(address _address) external onlySetter{
        tierContract = _address;
    }

    function setWeeklyContract(address _address) external onlySetter{
        gameContract = _address;
    }
    
    function claimAllocation(uint _contributorId, bool _isGame, uint _projectId) public {
        require(tokenContractPerProject[_projectId] != address(0), "Address is not set");
        if(!_isGame){
            require(IELVNTier(tierContract).ownerOf(_contributorId) == msg.sender, "You are not the owner!");
            uint _claimableAmount = availableAllocation(_contributorId, _isGame, _projectId);
            require(_claimableAmount > 0,"No claimable Tokens");
            IERC20(tokenContractPerProject[_projectId]).transfer(msg.sender,_claimableAmount);
        }
        else{
            require(IELVNGame(gameContract).ownerOf(_contributorId) == msg.sender, "You are not the owner!");
            uint _claimableAmount = availableAllocation(_contributorId, _isGame, _projectId);
            require(_claimableAmount > 0,"No claimable Tokens");
            IERC20(tokenContractPerProject[_projectId]).transfer(msg.sender,_claimableAmount);
        }
    }

    function withdrawToken(address _token, uint _amount) external onlyOwner {
        IERC20(_token).transfer(owner,_amount);
    }
}
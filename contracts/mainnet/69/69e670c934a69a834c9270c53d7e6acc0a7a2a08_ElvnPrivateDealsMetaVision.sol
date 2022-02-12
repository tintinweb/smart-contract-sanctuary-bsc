/**
 *Submitted for verification at BscScan.com on 2022-02-12
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

//SeedifyFundsContract

contract ElvnPrivateDealsMetaVision is Ownable {
    using SafeERC20 for IERC20;

    //token attributes
    string public constant NAME = "11Minutes Private Deals MetaVision"; //name of the contract
    uint256 public maxCap; // Max cap in BUSD
    uint256 public saleStartTime; // start sale time
    uint256 public saleEndTime; // end sale time
    uint256 public totalBUSDReceivedInAllTier; // total bnd received
    mapping (uint256 => uint256) public totalBUSDPerTier;
    uint256 public totalparticipants; // total participants in ido
    address payable public projectOwner; // project Owner

    //total users per tier
    mapping (uint256 => uint256) public totalUsersPerTier;

    //max allocations per user in a tier
    mapping (uint256 => uint256) public maxAllocationPerUserPerTier;

    //min allocation per user in a tier
    mapping (uint256 => uint256) public minAllocationPerUserPerTier;


    IERC20 public ERC20Interface;
    address public tokenAddress;

    address public ELVNTierAddress;
    address public ELVNGameAddress;

    //mapping the user purchase
    mapping(uint256 => uint256) public buyInTotal;
    mapping(uint256 => uint256) public buyInTotalPlayer;

    uint256 public allowedGameId;

    // CONSTRUCTOR
    constructor(
        uint256 _maxCap,
        uint256 _saleStartTime,
        uint256 _saleEndTime,
        address payable _projectOwner,
        address _tokenAddress,
        address _ELVNTierAddress,
        address _ELVNGameAddress,
        uint256 _allowedGameId
    ) public {
        maxCap = _maxCap;
        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;

        projectOwner = _projectOwner;

        minAllocationPerUserPerTier[0] = 1000000000000000000;
        minAllocationPerUserPerTier[1] = 5000000000000000000;
        minAllocationPerUserPerTier[2] = 10000000000000000000;
        minAllocationPerUserPerTier[3] = 15000000000000000000;
        minAllocationPerUserPerTier[4] = 20000000000000000000;
        minAllocationPerUserPerTier[5] = 25000000000000000000;
        minAllocationPerUserPerTier[6] = 30000000000000000000;
        minAllocationPerUserPerTier[7] = 35000000000000000000;
        minAllocationPerUserPerTier[8] = 40000000000000000000;
        
        maxAllocationPerUserPerTier[0] = 10000000000000000000;
        maxAllocationPerUserPerTier[1] = 50000000000000000000;
        maxAllocationPerUserPerTier[2] = 100000000000000000000;
        maxAllocationPerUserPerTier[3] = 200000000000000000000;
        maxAllocationPerUserPerTier[4] = 350000000000000000000;
        maxAllocationPerUserPerTier[5] = 500000000000000000000;
        maxAllocationPerUserPerTier[6] = 750000000000000000000;
        maxAllocationPerUserPerTier[7] = 1000000000000000000000;
        maxAllocationPerUserPerTier[8] = 2000000000000000000000;

        require(_tokenAddress != address(0), "Zero token address"); //Adding token to the contract
        tokenAddress = _tokenAddress;
        ERC20Interface = IERC20(tokenAddress);

        ELVNTierAddress = _ELVNTierAddress;
        ELVNGameAddress = _ELVNGameAddress;
        allowedGameId = _allowedGameId;
    }

    // function to update the tiers value manually
    function updateTierValues(uint256 _tier, uint256 _tierValue) external onlyOwner {
        maxAllocationPerUserPerTier[_tier] = _tierValue;
    }

    function addAllocationToAllTiers(uint256 _allocationAdded) external onlyOwner{
        maxAllocationPerUserPerTier[0] += _allocationAdded;
        maxAllocationPerUserPerTier[1] += _allocationAdded;
        maxAllocationPerUserPerTier[2] += _allocationAdded;
        maxAllocationPerUserPerTier[3] += _allocationAdded;
        maxAllocationPerUserPerTier[4] += _allocationAdded;
        maxAllocationPerUserPerTier[5] += _allocationAdded;
        maxAllocationPerUserPerTier[6] += _allocationAdded;
        maxAllocationPerUserPerTier[7] += _allocationAdded;
        maxAllocationPerUserPerTier[8] += _allocationAdded;
    }

    modifier _hasAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        // ERC20Interface = IERC20(tokenAddress);
        uint256 ourAllowance = ERC20Interface.allowance(allower, address(this));
        require(amount <= ourAllowance, "Make sure to add enough allowance");
        _;
    }

    function availableAllocation(uint256 _tierId) public view returns (uint256){
        uint256 _tierLevel = IELVNTier(ELVNTierAddress).tierLevel(_tierId);
        return maxAllocationPerUserPerTier[_tierLevel] - buyInTotal[_tierId];
    }

    function availableAllocationPlayer(uint256 _playerId) public view returns (uint256){
        if(IELVNGame(ELVNGameAddress).ticketGameId(_playerId) == allowedGameId){
            return maxAllocationPerUserPerTier[0] - buyInTotalPlayer[_playerId];
        }
        else{
            return 0;
        }
    }

    function buyTokens(uint256 _tierId, uint256 amount)
        external
        _hasAllowance(msg.sender, amount)
        returns (bool)
    {
        require(now >= saleStartTime, "The sale is not started yet "); // solhint-disable
        require(now <= saleEndTime, "The sale is closed"); // solhint-disable
        require(
            totalBUSDReceivedInAllTier + amount <= maxCap,
            "buyTokens: purchase would exceed max cap"
        );
        require(availableAllocation(_tierId) != 0,"You don't have any available Allocation");
        require(ERC20Interface.balanceOf(msg.sender) >= amount,"You don't have enough BUSD");

        require(address(msg.sender) == IELVNTier(ELVNTierAddress).ownerOf(_tierId));
        uint256 _tierLevel = IELVNTier(ELVNTierAddress).tierLevel(_tierId);

        buyInTotal[_tierId] += amount;
        require(buyInTotal[_tierId] >= minAllocationPerUserPerTier[_tierLevel],"Your contribution is to low");
        require(buyInTotal[_tierId] < maxAllocationPerUserPerTier[_tierLevel],"You are investing more than your tier limit");
        totalBUSDReceivedInAllTier += amount;
        totalBUSDPerTier[_tierLevel] += amount;
        ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        return true;
    }

    function buyTokensPlayer(uint256 _playerId, uint256 amount)
        external
        _hasAllowance(msg.sender, amount)
        returns (bool)
    {
        require(now >= saleStartTime, "The sale is not started yet "); // solhint-disable
        require(now <= saleEndTime, "The sale is closed"); // solhint-disable
        require(
            totalBUSDReceivedInAllTier + amount <= maxCap,
            "buyTokens: purchase would exceed max cap"
        );
        require(availableAllocationPlayer(_playerId) != 0,"You don't have any available Allocation");
        require(address(msg.sender) == IELVNGame(ELVNGameAddress).ownerOf(_playerId));
        require(ERC20Interface.balanceOf(msg.sender) >= amount,"You don't have enough BUSD");

        buyInTotalPlayer[_playerId] += amount;
        require(buyInTotalPlayer[_playerId] >= minAllocationPerUserPerTier[0],"Your contribution is to low");
        require(buyInTotalPlayer[_playerId] < maxAllocationPerUserPerTier[0],"You are investing more than your tier limit");
        totalBUSDReceivedInAllTier += amount;
        totalBUSDPerTier[0] += amount;
        ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        return true;
    }

    function setStartTime(uint256 _time) external onlyOwner {
        saleStartTime = _time;
    }

    function setEndTime(uint256 _time) external onlyOwner {
        saleEndTime = _time;
    }
}
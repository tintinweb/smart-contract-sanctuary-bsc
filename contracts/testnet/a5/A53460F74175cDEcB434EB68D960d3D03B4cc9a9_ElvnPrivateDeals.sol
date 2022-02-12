/**
 *Submitted for verification at BscScan.com on 2022-02-11
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

//SeedifyFundsContract

contract ElvnPrivateDeals is Ownable {
    using SafeERC20 for IERC20;

    //token attributes
    string public constant NAME = "11Minutes Private Deals"; //name of the contract
    uint256 public immutable maxCap; // Max cap in BUSD
    uint256 public immutable saleStartTime; // start sale time
    uint256 public immutable saleEndTime; // end sale time
    uint256 public totalBUSDReceivedInAllTier; // total bnd received
    uint256 public totalBUSDInTierOne; // total BUSD for tier one
    uint256 public totalBUSDInTierTwo; // total BUSD for tier Tier
    uint256 public totalBUSDInTierThree; // total BUSD for tier Three
    uint256 public totalBUSDInTierFour; // total BUSD for tier Four
    uint256 public totalBUSDInTierFive; // total BUSD for tier Five
    uint256 public totalBUSDInTierSix; // total BUSD for tier Six
    uint256 public totalBUSDInTierSeven; // total BUSD for tier Seven
    uint256 public totalBUSDInTierEight; // total BUSD for tier Eight
    uint256 public totalparticipants; // total participants in ido
    address payable public projectOwner; // project Owner

    // max cap per tier
    uint256 public tierOneMaxCap;
    uint256 public tierTwoMaxCap;
    uint256 public tierThreeMaxCap;
    uint256 public tierFourMaxCap;
    uint256 public tierFiveMaxCap;
    uint256 public tierSixMaxCap;
    uint256 public tierSevenMaxCap;
    uint256 public tierEightMaxCap;

    //total users per tier
    uint256 public totalUserInTierOne;
    uint256 public totalUserInTierTwo;
    uint256 public totalUserInTierThree;
    uint256 public totalUserInTierFour;
    uint256 public totalUserInTierFive;
    uint256 public totalUserInTierSix;
    uint256 public totalUserInTierSeven;
    uint256 public totalUserInTierEight;

    //max allocations per user in a tier
    uint256 public maxAllocaPerUserTierOne;
    uint256 public maxAllocaPerUserTierTwo;
    uint256 public maxAllocaPerUserTierThree;
    uint256 public maxAllocaPerUserTierFour;
    uint256 public maxAllocaPerUserTierFive;
    uint256 public maxAllocaPerUserTierSix;
    uint256 public maxAllocaPerUserTierSeven;
    uint256 public maxAllocaPerUserTierEight;

    //min allocation per user in a tier
    uint256 public minAllocaPerUserTierOne;
    uint256 public minAllocaPerUserTierTwo;
    uint256 public minAllocaPerUserTierThree;
    uint256 public minAllocaPerUserTierFour;
    uint256 public minAllocaPerUserTierFive;
    uint256 public minAllocaPerUserTierSix;
    uint256 public minAllocaPerUserTierSeven;
    uint256 public minAllocaPerUserTierEight;


    IERC20 public ERC20Interface;
    address public tokenAddress;

    address public ELVNTierAddress;

    //mapping the user purchase per tier
    mapping(uint256 => uint256) public buyInOneTier;
    mapping(uint256 => uint256) public buyInTwoTier;
    mapping(uint256 => uint256) public buyInThreeTier;
    mapping(uint256 => uint256) public buyInFourTier;
    mapping(uint256 => uint256) public buyInFiveTier;
    mapping(uint256 => uint256) public buyInSixTier;
    mapping(uint256 => uint256) public buyInSevenTier;
    mapping(uint256 => uint256) public buyInEightTier;
    mapping(uint256 => uint256) public buyInTotal;

    // CONSTRUCTOR
    constructor(
        uint256 _maxCap,
        uint256 _saleStartTime,
        uint256 _saleEndTime,
        address payable _projectOwner,
        uint256 _tierOneValue,
        uint256 _tierTwoValue,
        uint256 _tierThreeValue,
        uint256 _tierFourValue,
        uint256 _tierFiveValue,
        uint256 _tierSixValue,
        uint256 _tierSevenValue,
        uint256 _tierEightValue,
        address _tokenAddress,
        address _ELVNTierAddress
    ) public {
        maxCap = _maxCap;
        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;

        projectOwner = _projectOwner;

        minAllocaPerUserTierOne = 10000000000000;
        minAllocaPerUserTierTwo = 20000000000000;
        minAllocaPerUserTierThree = 30000000000000;
        minAllocaPerUserTierFour = 40000000000000;
        minAllocaPerUserTierFive = 50000000000000;
        minAllocaPerUserTierSix = 60000000000000;
        minAllocaPerUserTierSeven = 70000000000000;
        minAllocaPerUserTierEight = 80000000000000;
        
        maxAllocaPerUserTierOne = _tierOneValue;
        maxAllocaPerUserTierTwo = _tierTwoValue;
        maxAllocaPerUserTierThree = _tierThreeValue;
        maxAllocaPerUserTierFour = _tierFourValue;
        maxAllocaPerUserTierFive = _tierFiveValue;
        maxAllocaPerUserTierSix = _tierSixValue;
        maxAllocaPerUserTierSeven = _tierSevenValue;
        maxAllocaPerUserTierEight = _tierEightValue;

        require(_tokenAddress != address(0), "Zero token address"); //Adding token to the contract
        tokenAddress = _tokenAddress;
        ERC20Interface = IERC20(tokenAddress);

        ELVNTierAddress = _ELVNTierAddress;
    }

    // function to update the tiers value manually
    function updateTierValues(
        uint256 _tierOneValue,
        uint256 _tierTwoValue,
        uint256 _tierThreeValue,
        uint256 _tierFourValue,
        uint256 _tierFiveValue,
        uint256 _tierSixValue,
        uint256 _tierSevenValue,
        uint256 _tierEightValue
    ) external onlyOwner {
        maxAllocaPerUserTierOne = _tierOneValue;
        maxAllocaPerUserTierTwo = _tierTwoValue;
        maxAllocaPerUserTierThree = _tierThreeValue;
        maxAllocaPerUserTierFour = _tierFourValue;
        maxAllocaPerUserTierFive = _tierFiveValue;
        maxAllocaPerUserTierSix = _tierSixValue;
        maxAllocaPerUserTierSeven = _tierSevenValue;
        maxAllocaPerUserTierEight = _tierEightValue;
    }

    modifier _hasAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        // ERC20Interface = IERC20(tokenAddress);
        uint256 ourAllowance = ERC20Interface.allowance(allower, address(this));
        require(amount <= ourAllowance, "Make sure to add enough allowance");
        _;
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

        require(address(msg.sender) == IELVNTier(ELVNTierAddress).ownerOf(_tierId));
        uint256 _tierLevel = IELVNTier(ELVNTierAddress).tierLevel(_tierId);

        if (_tierLevel == 1) {
            buyInOneTier[_tierId] += amount;
            buyInTotal[_tierId] += amount;
            require(
                buyInOneTier[_tierId] >= minAllocaPerUserTierOne,
                "your purchasing Power is so Low"
            );
            require(
                buyInOneTier[_tierId] <= maxAllocaPerUserTierOne,
                "buyTokens:You are investing more than your tier-1 limit!"
            );

            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTierOne += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (_tierLevel == 2) {
            buyInTwoTier[_tierId] += amount;
            buyInTotal[_tierId] += amount;
            require(
                buyInTwoTier[_tierId] >= minAllocaPerUserTierTwo,
                "your purchasing Power is so Low"
            );
            require(
                buyInTwoTier[_tierId] <= maxAllocaPerUserTierTwo,
                "buyTokens:You are investing more than your tier-2 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTierTwo += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (_tierLevel == 3) {
            buyInThreeTier[_tierId] += amount;
            buyInTotal[_tierId] += amount;
            require(
                buyInThreeTier[_tierId] >= minAllocaPerUserTierThree,
                "your purchasing Power is so Low"
            );
            require(
                totalBUSDInTierThree + amount <= tierThreeMaxCap,
                "buyTokens: purchase would exceed Tier three max cap"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTierThree += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (_tierLevel == 4) {
            buyInFourTier[_tierId] += amount;
            buyInTotal[_tierId] += amount;
            require(
                buyInFourTier[_tierId] >= minAllocaPerUserTierFour,
                "your purchasing Power is so Low"
            );
            require(
                buyInFourTier[_tierId] <= maxAllocaPerUserTierFour,
                "buyTokens:You are investing more than your tier-4 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTierFour += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (_tierLevel == 5) {
            buyInFiveTier[_tierId] += amount;
            buyInTotal[_tierId] += amount;
            require(
                buyInFiveTier[_tierId] >= minAllocaPerUserTierFive,
                "your purchasing Power is so Low"
            );
            require(
                buyInFiveTier[_tierId] <= maxAllocaPerUserTierFive,
                "buyTokens:You are investing more than your tier-5 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTierFive += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (_tierLevel == 6) {
            buyInSixTier[_tierId] += amount;
            buyInTotal[_tierId] += amount;
            require(
                buyInSixTier[_tierId] >= minAllocaPerUserTierSix,
                "your purchasing Power is so Low"
            );
            require(
                buyInSixTier[_tierId] <= maxAllocaPerUserTierSix,
                "buyTokens:You are investing more than your tier-6 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTierSix += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (_tierLevel == 7) {
            buyInSevenTier[_tierId] += amount;
            buyInTotal[_tierId] += amount;
            require(
                buyInSevenTier[_tierId] >= minAllocaPerUserTierSeven,
                "your purchasing Power is so Low"
            );
            require(
                buyInSevenTier[_tierId] <= maxAllocaPerUserTierSeven,
                "buyTokens:You are investing more than your tier-7 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTierSeven += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (_tierLevel == 8) {
            buyInEightTier[_tierId] += amount;
            buyInTotal[_tierId] += amount;
            require(
                buyInEightTier[_tierId] >= minAllocaPerUserTierEight,
                "your purchasing Power is so Low"
            );
            require(
                buyInEightTier[_tierId] <= maxAllocaPerUserTierEight,
                "buyTokens:You are investing more than your tier-8 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTierEight += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        }  else {
            revert("No Tier");
        }
        return true;
    }
}
/*
 *Seedify.fund
 *Decentralized Incubator
 *A disruptive blockchain incubator program / decentralized seed stage fund, empowered through DAO based community-involvement mechanisms
 */
pragma solidity ^0.6.0;

// SPDX-License-Identifier: UNLICENSED

import "../ERC20/IERC20.sol";
import "../Ownable/Context.sol";
import "../Ownable/Ownable.sol";
import "../ERC20/SafeERC20.sol";

//SeedifyFundsContract

contract SeedifyFundsContract is Ownable {
    using SafeERC20 for IERC20;

    //token attributes
    string public constant NAME = "Seedify.funds"; //name of the contract
    uint256 public immutable maxCap; // Max cap in BUSD
    uint256 public immutable saleStartTime; // start sale time
    uint256 public immutable saleEndTime; // end sale time
    uint256 public totalBUSDReceivedInAllTier; // total bnd received
    uint256[9] public totalBUSDInTiers; // total BUSD for tiers
    uint256 public totalparticipants; // total participants in ido
    address payable public projectOwner; // project Owner

    // max cap per tier
    uint256[9] public tiersMaxCap;

    //total users per tier
    uint256[9] public totalUserInTiers;

    //max allocations per user in a tier
    uint256[9] public maxAllocaPerUserInTiers;

    //min allocation per user in a tier
    uint256[9] public minAllocaPerUserInTiers;

    // address array for tier one whitelist
    address[] private whitelistTierOne;

    // address array for tier two whitelist
    address[] private whitelistTierTwo;

    // address array for tier three whitelist
    address[] private whitelistTierThree;

    // address array for tier Four whitelist
    address[] private whitelistTierFour;

    // address array for tier Five whitelist
    address[] private whitelistTierFive;

    // address array for tier Six whitelist
    address[] private whitelistTierSix;

    // address array for tier Seven whitelist
    address[] private whitelistTierSeven;

    // address array for tier Eight whitelist
    address[] private whitelistTierEight;

    // address array for tier Nine whitelist
    address[] private whitelistTierNine;

    IERC20 public ERC20Interface;
    address public tokenAddress;

    //mapping the user purchase per tier
    mapping(address => uint256) public buyInOneTier;
    mapping(address => uint256) public buyInTwoTier;
    mapping(address => uint256) public buyInThreeTier;
    mapping(address => uint256) public buyInFourTier;
    mapping(address => uint256) public buyInFiveTier;
    mapping(address => uint256) public buyInSixTier;
    mapping(address => uint256) public buyInSevenTier;
    mapping(address => uint256) public buyInEightTier;
    mapping(address => uint256) public buyInNineTier;

    // CONSTRUCTOR
    constructor(
        uint256 _maxCap,
        uint256 _saleStartTime,
        uint256 _saleEndTime,
        address payable _projectOwner,
        uint256[9] memory _tiersValue,
        uint256 _totalparticipants,
        address _tokenAddress
    ) public {
        maxCap = _maxCap;
        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;
        projectOwner = _projectOwner;

        for (uint256 i = 0; i < 9; i++) {
            tiersMaxCap[i] = _tiersValue[i];
        }

        minAllocaPerUserInTiers[0] = 10000000000000;
        minAllocaPerUserInTiers[1] = 20000000000000;
        minAllocaPerUserInTiers[2] = 30000000000000;
        minAllocaPerUserInTiers[3] = 40000000000000;
        minAllocaPerUserInTiers[4] = 50000000000000;
        minAllocaPerUserInTiers[5] = 60000000000000;
        minAllocaPerUserInTiers[6] = 70000000000000;
        minAllocaPerUserInTiers[7] = 80000000000000;
        minAllocaPerUserInTiers[8] = 90000000000000;

        totalUserInTiers[0] = 2;
        totalUserInTiers[1] = 2;
        totalUserInTiers[2] = 2;
        totalUserInTiers[3] = 2;
        totalUserInTiers[4] = 2;
        totalUserInTiers[5] = 2;
        totalUserInTiers[6] = 2;
        totalUserInTiers[7] = 2;
        totalUserInTiers[8] = 2;

        for (uint256 i = 0; i < 9; i++) {
            maxAllocaPerUserInTiers[i] = tiersMaxCap[i] / totalUserInTiers[i];
        }

        totalparticipants = _totalparticipants;
        require(_tokenAddress != address(0), "Zero token address"); //Adding token to the contract
        tokenAddress = _tokenAddress;
        ERC20Interface = IERC20(tokenAddress);
    }

    // function to update the tiers value manually
    function updateTierValues(uint256[9] memory _tiersValue)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < 9; i++) {
            tiersMaxCap[i] = _tiersValue[i];
            maxAllocaPerUserInTiers[i] = tiersMaxCap[i] / totalUserInTiers[i];
        }
    }

    // function to update the tiers users value manually
    function updateTierUsersValue(uint256[9] memory _tiersUsersValue)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < 9; i++) {
            totalUserInTiers[i] = _tiersUsersValue[i];
            maxAllocaPerUserInTiers[i] = tiersMaxCap[i] / totalUserInTiers[i];
        }
    }

    //add the address in Whitelist tier to invest
    function addWhitelist(uint256 _tier, address _address) external onlyOwner {
        require(_tier >= 1 && _tier <= 9, "Invalid Tier. Try (1-9)");
        require(_address != address(0), "Invalid address");

        if (_tier == 1) whitelistTierOne.push(_address);
        else if (_tier == 2) whitelistTierTwo.push(_address);
        else if (_tier == 3) whitelistTierThree.push(_address);
        else if (_tier == 4) whitelistTierFour.push(_address);
        else if (_tier == 5) whitelistTierFive.push(_address);
        else if (_tier == 6) whitelistTierSix.push(_address);
        else if (_tier == 7) whitelistTierSeven.push(_address);
        else if (_tier == 8) whitelistTierEight.push(_address);
        else if (_tier == 9) whitelistTierNine.push(_address);
    }

    // check the address in whitelist tier
    function getWhitelist(uint256 _tier, address _address)
        public
        view
        returns (bool)
    {
        require(_tier >= 1 && _tier <= 9, "Invalid Tier. Try (1-9)");
        require(_address != address(0), "Invalid address");

        address[] memory _whitelistTier;

        if (_tier == 1) _whitelistTier = whitelistTierOne;
        else if (_tier == 2) _whitelistTier = whitelistTierTwo;
        else if (_tier == 3) _whitelistTier = whitelistTierThree;
        else if (_tier == 4) _whitelistTier = whitelistTierFour;
        else if (_tier == 5) _whitelistTier = whitelistTierFive;
        else if (_tier == 6) _whitelistTier = whitelistTierSix;
        else if (_tier == 7) _whitelistTier = whitelistTierSeven;
        else if (_tier == 8) _whitelistTier = whitelistTierEight;
        else if (_tier == 9) _whitelistTier = whitelistTierNine;

        for (uint256 i = 0; i < _whitelistTier.length; i++) {
            address _addressArr = _whitelistTier[i];
            if (_addressArr == _address) {
                return true;
            }
        }
        return false;
    }

    modifier _hasAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        // ERC20Interface = IERC20(tokenAddress);
        uint256 ourAllowance = ERC20Interface.allowance(allower, address(this));
        require(amount <= ourAllowance, "Make sure to add enough allowance");
        _;
    }

    function buyTokens(uint256 amount)
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

        if (getWhitelist(1, msg.sender)) {
            buyInOneTier[msg.sender] += amount;
            require(
                buyInOneTier[msg.sender] >= minAllocaPerUserInTiers[0],
                "your purchasing Power is so Low"
            );
            require(
                totalBUSDInTiers[0] + amount <= tiersMaxCap[0],
                "buyTokens: purchase would exceed Tier one max cap"
            );
            require(
                buyInOneTier[msg.sender] <= maxAllocaPerUserInTiers[0],
                "buyTokens:You are investing more than your tier-1 limit!"
            );

            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTiers[0] += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist(2, msg.sender)) {
            buyInTwoTier[msg.sender] += amount;
            require(
                buyInTwoTier[msg.sender] >= minAllocaPerUserInTiers[1],
                "your purchasing Power is so Low"
            );
            require(
                totalBUSDInTiers[1] + amount <= tiersMaxCap[1],
                "buyTokens: purchase would exceed Tier two max cap"
            );
            require(
                buyInTwoTier[msg.sender] <= maxAllocaPerUserInTiers[1],
                "buyTokens:You are investing more than your tier-2 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTiers[1] += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist(3, msg.sender)) {
            buyInThreeTier[msg.sender] += amount;
            require(
                buyInThreeTier[msg.sender] >= minAllocaPerUserInTiers[2],
                "your purchasing Power is so Low"
            );
            require(
                buyInThreeTier[msg.sender] <= maxAllocaPerUserInTiers[2],
                "buyTokens:You are investing more than your tier-3 limit!"
            );
            require(
                totalBUSDInTiers[2] + amount <= tiersMaxCap[2],
                "buyTokens: purchase would exceed Tier three max cap"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTiers[2] += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist(4, msg.sender)) {
            buyInFourTier[msg.sender] += amount;
            require(
                buyInFourTier[msg.sender] >= minAllocaPerUserInTiers[3],
                "your purchasing Power is so Low"
            );
            require(
                totalBUSDInTiers[3] + amount <= tiersMaxCap[3],
                "buyTokens: purchase would exceed Tier Four max cap"
            );
            require(
                buyInFourTier[msg.sender] <= maxAllocaPerUserInTiers[3],
                "buyTokens:You are investing more than your tier-4 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTiers[3] += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist(5, msg.sender)) {
            buyInFiveTier[msg.sender] += amount;
            require(
                buyInFiveTier[msg.sender] >= minAllocaPerUserInTiers[4],
                "your purchasing Power is so Low"
            );
            require(
                totalBUSDInTiers[4] + amount <= tiersMaxCap[4],
                "buyTokens: purchase would exceed Tier Five max cap"
            );
            require(
                buyInFiveTier[msg.sender] <= maxAllocaPerUserInTiers[4],
                "buyTokens:You are investing more than your tier-5 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTiers[4] += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist(6, msg.sender)) {
            buyInSixTier[msg.sender] += amount;
            require(
                buyInSixTier[msg.sender] >= minAllocaPerUserInTiers[5],
                "your purchasing Power is so Low"
            );
            require(
                totalBUSDInTiers[5] + amount <= tiersMaxCap[5],
                "buyTokens: purchase would exceed Tier Six max cap"
            );
            require(
                buyInSixTier[msg.sender] <= maxAllocaPerUserInTiers[5],
                "buyTokens:You are investing more than your tier-6 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTiers[5] += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist(7, msg.sender)) {
            buyInSevenTier[msg.sender] += amount;
            require(
                buyInSevenTier[msg.sender] >= minAllocaPerUserInTiers[6],
                "your purchasing Power is so Low"
            );
            require(
                totalBUSDInTiers[6] + amount <= tiersMaxCap[6],
                "buyTokens: purchase would exceed Tier Seven max cap"
            );
            require(
                buyInSevenTier[msg.sender] <= maxAllocaPerUserInTiers[6],
                "buyTokens:You are investing more than your tier-7 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTiers[6] += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist(8, msg.sender)) {
            buyInEightTier[msg.sender] += amount;
            require(
                buyInEightTier[msg.sender] >= minAllocaPerUserInTiers[7],
                "your purchasing Power is so Low"
            );
            require(
                totalBUSDInTiers[7] + amount <= tiersMaxCap[7],
                "buyTokens: purchase would exceed Tier Eight max cap"
            );
            require(
                buyInEightTier[msg.sender] <= maxAllocaPerUserInTiers[7],
                "buyTokens:You are investing more than your tier-8 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTiers[7] += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist(9, msg.sender)) {
            buyInNineTier[msg.sender] += amount;
            require(
                buyInNineTier[msg.sender] >= minAllocaPerUserInTiers[8],
                "your purchasing Power is so Low"
            );
            require(
                totalBUSDInTiers[8] + amount <= tiersMaxCap[8],
                "buyTokens: purchase would exceed Tier Nine max cap"
            );
            require(
                buyInNineTier[msg.sender] <= maxAllocaPerUserInTiers[8],
                "buyTokens:You are investing more than your tier-9 limit!"
            );
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTiers[8] += amount;
            ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount); //changes to transfer BUSD to owner
        } else {
            revert("Not whitelisted");
        }
        return true;
    }
}

pragma solidity ^0.6.0;

// SPDX-License-Identifier: UNLICENSED

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
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

pragma solidity ^0.6.0;

// SPDX-License-Identifier: UNLICENSED

import "./Context.sol";

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

pragma solidity ^0.6.0;

import "./IERC20.sol";

// SPDX-License-Identifier: UNLICENSED
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
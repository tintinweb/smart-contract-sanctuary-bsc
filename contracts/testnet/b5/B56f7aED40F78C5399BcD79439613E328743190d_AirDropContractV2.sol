/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

abstract contract IERC20 {
    function transfer(address _to, uint256 _value) public virtual returns(bool);
    function balanceOf(address tokenOwner) public view virtual returns(uint balance);
    function transferFrom(address from, address to, uint tokens) public virtual returns(bool success);
}

contract AirDropContractV2
{
    struct Claimer {
        uint256 total;
        uint times;
        address person;
        uint timeLimit;
    }

    mapping(address => Claimer) private claimers;

    address public owner;
    IERC20 public token;
    uint256 public tokendecimals;
    uint256 public airdropvalueinwei;
    uint256 public maxvalue;
    uint256 public maxtimes;
    uint public maxwaitsec;
    uint public executelimit;
    
    uint256 private constant OWNER_NOT_ENTERED = 1;
    uint256 private constant OWNER_ENTERED = 2;
    uint256 private reentrancyForOwnerStatus;
    uint private timeNonce;
    uint private constant MAX_NONCE = 237512;

    constructor(address _tokenAddr, uint256 _decimals) 
    {
        token = IERC20(_tokenAddr);
        tokendecimals = _decimals;
        airdropvalueinwei = 1 * 10**tokendecimals; // Default: 1
        maxvalue = 1 * 10**tokendecimals; // Default: 1;
        maxtimes = 1;
        owner = msg.sender;
        reentrancyForOwnerStatus = OWNER_NOT_ENTERED;
        maxwaitsec = 60*15; // Default: 15 min
        timeNonce = 29689;
        executelimit = 60; // Default: 1 min
    }

    modifier onlyOwner 
    {
        require(msg.sender == owner, 'FN'); // Forbidden
        _;
    }

    modifier noReentrancyForOwner() 
    {
        require(reentrancyForOwnerStatus != OWNER_ENTERED, "REE");
        reentrancyForOwnerStatus = OWNER_ENTERED;
        _;
        reentrancyForOwnerStatus = OWNER_NOT_ENTERED;
    }

    modifier validAddress(address _address) 
    {
       require(_address != address(0), "INVAD"); // Invalid address
       _;
    }

    modifier validWallet()
    {
        require(Hlp.isContract(msg.sender) == false, "ISCONTRACT"); // Wallet is a contract
        require(tx.origin == msg.sender, "INVWALLETORIG"); // Invalid wallet origin
        _;
    }

    function airdropRequest() external validWallet
    {
        uint timeover = claimers[msg.sender].timeLimit + executelimit;

        // Check never requested or now time is greater than time over
        require(claimers[msg.sender].timeLimit == 0 || timeover < block.timestamp, "PROG"); // Request in progress

        Claimer storage currentClaimer = claimers[msg.sender];
        uint256 totalClaimed = currentClaimer.total;
        uint256 timesClaimed = currentClaimer.times;

        require(totalClaimed + airdropvalueinwei <= maxvalue, "MCAR"); // Maximum claimed amount reached
        require(timesClaimed < maxtimes, "MCTR"); // Maximum claimed times reached

        claimers[msg.sender].timeLimit = block.timestamp + Hlp.getTime(timeNonce, maxwaitsec);
        timeNonce = timeNonce >= MAX_NONCE ? 0 : timeNonce + 3;
    }

    function executeAirdrop() external validWallet
    {
        require(claimers[msg.sender].timeLimit > 0, "NOREQ"); // No Request

        // Now time must be greater than time request finish
        require(block.timestamp > claimers[msg.sender].timeLimit, "TOOEARLY"); // Too early

        //Timeover must be greater than now time
        uint timeover = claimers[msg.sender].timeLimit + executelimit;
        require(timeover >= block.timestamp, "TMO"); // Time over, must request again

        Claimer storage currentClaimer = claimers[msg.sender];

        uint256 totalClaimed = currentClaimer.total;
        uint timesClaimed = currentClaimer.times;

        require(totalClaimed + airdropvalueinwei <= maxvalue, "MCAR"); // Maximum claimed amount reached
        require(timesClaimed < maxtimes, "MCTR"); // Maximum claimed times reached

        token.transfer(msg.sender, airdropvalueinwei);

        claimers[msg.sender].total = totalClaimed + airdropvalueinwei;
        claimers[msg.sender].times = timesClaimed + 1;
        claimers[msg.sender].person = msg.sender;
        claimers[msg.sender].timeLimit = 0;
    }

    function hasRequestInProgress() external validWallet view returns (uint)
    {
        if(claimers[msg.sender].timeLimit == 0)
        {
            return 0;
        }

        uint timeover = claimers[msg.sender].timeLimit + executelimit;

        if(timeover >= block.timestamp)
        {
            return 1;
        }

        return 0;
    }

    function getTimeLimit() external validWallet view returns (uint)
    {
        return claimers[msg.sender].timeLimit;
    }

    function getIsWaitingForTimeLimit() external validWallet view returns (uint)
    {
        if(claimers[msg.sender].timeLimit == 0)
        {
            return 0;
        }

        return claimers[msg.sender].timeLimit > block.timestamp ? 1 : 0;
    }

    function getSecondsForTimeLimit() external validWallet view returns (uint)
    {
        if(claimers[msg.sender].timeLimit == 0)
        {
            return 0;
        }

        if(block.timestamp > claimers[msg.sender].timeLimit)
        {
            return 0;
        }

        return claimers[msg.sender].timeLimit - block.timestamp;
    }

    function getTimeOver() external validWallet view returns (uint)
    {
        return claimers[msg.sender].timeLimit + executelimit;
    }

    function getIsTimeOver() external validWallet view returns (uint)
    {
        if(claimers[msg.sender].timeLimit == 0)
        {
            return 0;
        }

        uint timeover = claimers[msg.sender].timeLimit + executelimit;
        return timeover < block.timestamp ? 1 : 0;
    }

    function getSecondsForTimeOver() external validWallet view returns (uint)
    {
        if(claimers[msg.sender].timeLimit == 0)
        {
            return 0;
        }

        uint timeover = claimers[msg.sender].timeLimit + executelimit;

        if(block.timestamp > timeover)
        {
            return 0;
        }

        return timeover - block.timestamp;
    }

    function getClaimedTotal() external view returns (uint256)
    {
        return claimers[msg.sender].total;
    }

    function getClaimedTimes() external view returns (uint)
    {
        return claimers[msg.sender].times;
    }

    function setTokenAddress(address newValue) external onlyOwner noReentrancyForOwner validAddress(newValue) validWallet
    {
        token = IERC20(newValue);
    }

    function setTokenDecimals(uint256 newValue) external onlyOwner noReentrancyForOwner validWallet
    {
        tokendecimals = newValue;
    }

    function setAirdropValue(uint256 newValueInWei) external onlyOwner noReentrancyForOwner validWallet
    {
        airdropvalueinwei = newValueInWei;
    }

    function setMaxClaimValue(uint256 newValue) external onlyOwner noReentrancyForOwner validWallet
    {
        maxvalue = newValue;
    }

    function setMaxClaimTimes(uint256 newValue) external onlyOwner noReentrancyForOwner validWallet
    {
        maxtimes = newValue;
    }

    function setMaxWaitSec(uint newValue) external onlyOwner noReentrancyForOwner validWallet
    {
        maxwaitsec = newValue;
    }

    function setExecuteLimit(uint newValue) external onlyOwner noReentrancyForOwner validWallet
    {
        executelimit = newValue;
    }

    function setOwner(address newValue) external onlyOwner noReentrancyForOwner validAddress(newValue) validWallet
    {
        owner = newValue;
    }

    function ownersRescue(uint256 amountinwei) external onlyOwner noReentrancyForOwner validWallet
    {
        token.transfer(msg.sender, amountinwei);
    }
}

// ****************************************************
// ***************** HELPER FUNCTIONS *****************
// ****************************************************
library Hlp 
{
    function getTime(uint nc, uint total) internal view returns (uint)
    {
        return Hlp.clockN(nc * 3, total) + 1;
    }

    function clockN(uint nc, uint ma) internal view returns (uint256)
    {
        return uint256(keccak256(abi.encodePacked(block.timestamp + nc, block.difficulty, msg.sender))) % ma;
    }

    function isContract(address account) internal view returns (bool) 
    {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
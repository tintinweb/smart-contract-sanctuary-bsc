pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface StakingV2 {
    function tokenDeposits(uint256 initialValue)
        external
        returns (TokenDeposit memory _deposit);
}

interface NFT {
    function mintItem(address owner, string memory tokenURI)
        external
        returns (uint256);
}

struct TokenDeposit {
    uint256 id;
    address depositOwner;
    uint256 depositValue;
    bool isWithdrawn;
    uint256 timeLockInSeconds;
    uint256 depositTime;
}

contract Airdrop {
    address public STAKING_CONTRACT_ADDRESS;
    address public NFT_CONTRACT_ADDRESS;
    address public ORACLE_WALLET_ADDRESS;

    mapping(address => uint256) lastClaimedTimestamp;

    uint256 public AIRDROP_COOLDOWN = 30 days;

    constructor(
        address _STAKING_CONTRACT_ADDRESS,
        address _NFT_CONTRACT_ADDRESS,
        address _ORACLE_WALLET_ADDRESS
    ) {
        STAKING_CONTRACT_ADDRESS = _STAKING_CONTRACT_ADDRESS;
        NFT_CONTRACT_ADDRESS = _NFT_CONTRACT_ADDRESS;
        ORACLE_WALLET_ADDRESS = _ORACLE_WALLET_ADDRESS;
    }

    struct AirdropRequest {
        uint256 id;
        address caller;
        uint256 depositId;
        uint256 randomness;
        bool isExecuted;
    }

    event AirdropRequested(uint256 id, address caller, uint256 depositId);

    AirdropRequest[] public airdropRequests;

    function isEllgibleForAirdropping(uint256 depositId, address callerWallet)
        internal
        returns (bool)
    {
        TokenDeposit memory _deposit = StakingV2(STAKING_CONTRACT_ADDRESS)
            .tokenDeposits(depositId);
        require(_deposit.depositOwner == callerWallet, "Deposit not yours");
        require(_deposit.timeLockInSeconds >= 20, "Deposit less than 1 mo");
        require(
            _deposit.isWithdrawn == false,
            "Deposit withdrawn is withdrawn"
        );
        require(
            block.timestamp - lastClaimedTimestamp[callerWallet] >
                AIRDROP_COOLDOWN,
            "Airdropping on cooldown"
        );
        return true;
    }

    function airdropCallerRequest(uint256 depositId)
        external
        returns (uint256)
    {
        uint256 airdropRequestId = airdropRequests.length;

        airdropRequests.push(
            AirdropRequest(airdropRequestId, msg.sender, depositId, 0, false)
        );

        emit AirdropRequested(airdropRequestId, msg.sender, depositId);
        return airdropRequestId;
    }

    function airdropCallerExecute(
        uint256 airdropRequestId,
        string memory tokenURI
    ) external returns (bool) {
        require(msg.sender == ORACLE_WALLET_ADDRESS, "Unauthorized");

        require(
            airdropRequests[airdropRequestId].isExecuted == false,
            "This request has been already executed"
        );

        isEllgibleForAirdropping(
            airdropRequests[airdropRequestId].depositId,
            airdropRequests[airdropRequestId].caller
        );

        NFT(NFT_CONTRACT_ADDRESS).mintItem(
            airdropRequests[airdropRequestId].caller,
            tokenURI
        );
        
        airdropRequests[airdropRequestId].isExecuted = true;

        return true;
    }
}
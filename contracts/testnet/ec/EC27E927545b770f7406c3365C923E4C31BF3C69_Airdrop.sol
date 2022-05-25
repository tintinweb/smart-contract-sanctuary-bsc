pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

struct TokenDeposit {
    uint256 id;
    address depositOwner;
    uint256 depositValue;
    bool isWithdrawn;
    uint256 timeLockInSeconds;
    uint256 depositTime;
}

contract Airdrop is Ownable {
    address public STAKING_CONTRACT_ADDRESS;
    address public NFT_CONTRACT_ADDRESS;
    address public ORACLE_WALLET_ADDRESS;

    mapping(uint256 => uint256) public lastClaimedTimestamp;

    // uint256 public AIRDROP_COOLDOWN = 30 days;
    // uint256 public MIN_DEPOSIT_TL = 30 days;

    uint256 public AIRDROP_COOLDOWN = 300;
    uint256 public MIN_DEPOSIT_TL = 100;

    bool public ENFORCE_PROCESSING_COST = false;

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
        uint256 depositValue;
        uint256 depositTimelock;
        string tokenURI;
        bool isExecuted;
    }

    event AirdropRequested(
        uint256 id,
        address caller,
        uint256 depositId,
        uint256 depositValue,
        uint256 depositTimelock
    );
    event AirdropExecuted(uint256 id);

    AirdropRequest[] public airdropRequests;

    function changeAirdropCooldown(uint256 cooldown) external onlyOwner {
        AIRDROP_COOLDOWN = cooldown;
    }

    function X2isElligibleForAirdropping(
        uint256 depositId,
        address callerWallet
    ) internal view returns (bool) {

        TokenDeposit memory _deposit = StakingV2(STAKING_CONTRACT_ADDRESS)
            .tokenDeposits(depositId);

        require(_deposit.depositOwner == callerWallet, "Deposit not yours");

        require(
            _deposit.timeLockInSeconds >= MIN_DEPOSIT_TL,
            "Deposit less than 1 mo"
        );

        require(
           block.timestamp - _deposit.depositTime >= AIRDROP_COOLDOWN,
            "1 month hasn't passed since deposit was made"
        );

        require(
            _deposit.isWithdrawn == false,
            "Deposit withdrawn is withdrawn"
        );

        return true;
    }

    function isElligibleForAirdropping(uint256 depositId, address callerWallet)
        external
        view
        returns (bool)
    {
        TokenDeposit memory _deposit = StakingV2(STAKING_CONTRACT_ADDRESS)
            .tokenDeposits(depositId);

        if(_deposit.depositOwner != callerWallet) return false;

        if(
            _deposit.timeLockInSeconds < MIN_DEPOSIT_TL) return false;

        if(
            block.timestamp - _deposit.depositTime < AIRDROP_COOLDOWN) return false;

        if(
            _deposit.isWithdrawn != false) return false;

        return true;
    }

    function airdropCallerRequest(uint256 depositId)
        external
        payable
        returns (uint256)
    {
        uint256 airdropRequestId = airdropRequests.length;

        require(
            X2isElligibleForAirdropping(depositId, msg.sender) == true,
            "Not elligible"
        );

        if (ENFORCE_PROCESSING_COST)
            require(
                msg.value >= 0.005 ether,
                "You haven't sent enough processing costs"
            );

        (bool sent, bytes memory data) = ORACLE_WALLET_ADDRESS.call{
            value: msg.value
        }("");
        require(sent, "Failed to send process cost");

        require(
            block.timestamp - lastClaimedTimestamp[depositId] >
                AIRDROP_COOLDOWN,
            "Airdropping on cooldown"
        );

        TokenDeposit memory _deposit = StakingV2(STAKING_CONTRACT_ADDRESS)
            .tokenDeposits(depositId);

        airdropRequests.push(
            AirdropRequest(
                airdropRequestId,
                msg.sender,
                _deposit.id,
                _deposit.depositValue,
                _deposit.timeLockInSeconds,
                "",
                false
            )
        );

        emit AirdropRequested(
            airdropRequestId,
            msg.sender,
            _deposit.id,
            _deposit.depositValue,
            _deposit.timeLockInSeconds
        );
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

        NFT(NFT_CONTRACT_ADDRESS).mintItem(
            airdropRequests[airdropRequestId].caller,
            tokenURI
        );

        airdropRequests[airdropRequestId].isExecuted = true;
        airdropRequests[airdropRequestId].tokenURI = tokenURI;

        lastClaimedTimestamp[
            airdropRequests[airdropRequestId].depositId
        ] = block.timestamp;

        emit AirdropExecuted(airdropRequestId);

        return true;
    }
}

interface StakingV2 {
    function tokenDeposits(uint256 initialValue)
        external
        view
        returns (TokenDeposit memory _deposit);
}

interface NFT {
    function mintItem(address owner, string memory tokenURI)
        external
        returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
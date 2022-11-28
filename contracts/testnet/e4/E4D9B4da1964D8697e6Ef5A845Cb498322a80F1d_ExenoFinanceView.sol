/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: MIT
// File: contracts/IExenoFinance.sol


pragma solidity 0.8.16;

interface IExenoFinanceNode {
    function isDebitId(bytes32) external view returns(bool);
    function isCreditId(bytes32) external view returns(bool);

    function getDeposits(address, address) external view returns(uint256);
    function getUndeposits(address, address) external view returns(uint256);
    function getDepositBalance(address, address) external view returns(uint256);
    
    function getStakes(address, address) external view returns(uint256);
    function getUnstakes(address, address) external view returns(uint256);
    function getStakeBalance(address, address) external view returns(uint256);

    function platformFees(address, uint256, uint256) external view returns(uint256);
    function affiliateFees(address, uint256, uint256) external view returns(uint256);
    
    function getTokenList() external view returns(address[] memory, uint256);
    
    function coreToken() external view returns(address);
    function nativeToken() external view returns(address);
    
    function ownedTokens(address) external view returns(uint256);
    function availableTokens(address) external view returns(uint256);
}

interface IExenoToken {
    function manager() external view returns(address);
    function mint(address, uint256) external;
    function burn(uint256) external;
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: contracts/ExenoFinanceView.sol


pragma solidity 0.8.16;



/**
 * This contract implements read-only reporting for the ExenoFinance contract
 * It also offers utility for encoding payload arguments into a single bytes variable
 */
 
contract ExenoFinanceView is Ownable
{   
    // Reference to the `ExenoFinanceNode` contract
    IExenoFinanceNode public NODE;

    // For reporting token balances
    struct TokenBalance {
        address token;
        uint256 owned;
        uint256 available;
    }

    // For reporting beneficiary balances
    struct BeneficiaryBalance {
        address token;
        uint256 desposited;
        uint256 staked;
    }

    // For reporting fees
    struct Fee {
        uint256[2] total;
        uint256[2] paid;
    }

    constructor(
        IExenoFinanceNode node
    )
    {
        NODE = node;
    }

    /**
     * Replace the underlying ExenoFinance contract
     */
    function setNode(IExenoFinanceNode node)
        external onlyOwner
    {
        NODE = node;
    }

    /**
     * Current balance of a token
     */
    function ownedTokens(address token)
        external view returns(uint256)
    {
        return(NODE.ownedTokens(token));
    }

    /**
     * Current balance of native currency
     */
    function ownedCash()
        external view returns(uint256)
    {
        return(NODE.ownedTokens(NODE.nativeToken()));
    }

    /**
     * Current balance of the core token (i.e. EXN token)
     */
    function ownedTokens()
        external view returns(uint256)
    {
        return(NODE.ownedTokens(NODE.coreToken()));
    }

    /**
     * How many tokens are available for payouts
     */
    function availableTokens(address token)
        external view returns(uint256)
    {
        return(NODE.availableTokens(token));
    }

    /**
     * How much native currency is available for payouts
     */
    function availableCash()
        external view returns(uint256)
    {
        return(NODE.availableTokens(NODE.nativeToken()));
    }

    /**
     * How many core tokens (i.e. EXN tokens) are available for payouts
     */
    function availableTokens()
        external view returns(uint256)
    {
        return(NODE.availableTokens(NODE.coreToken()));
    }

    /**
     * Report the current balance for all tokens that have been held by the contract
     */
    function tokenBalanceReport()
        external view returns(TokenBalance[] memory report, uint256, bool)
    {
        (address[] memory list, uint256 size) = NODE.getTokenList();
        report = new TokenBalance[](size);
        bool status;
        for (uint256 i = 0; i < size; i++) {
            address token = list[i];
            uint256 owned = NODE.ownedTokens(token);
            uint256 available = NODE.availableTokens(token);
            report[i] = TokenBalance(token, owned, available);
            status = status || owned > 0 || available > 0;
        }
        return(report, size, status);
    }

    /**
     * Report the current balance for all tokens that have been deposited or staked by a beneficiary
     */
    function beneficiaryBalanceReport(address beneficiary)
        public view returns(BeneficiaryBalance[] memory report, uint256, bool)
    {
        (address[] memory list, uint256 size) = NODE.getTokenList();
        report = new BeneficiaryBalance[](size);
        bool status;
        for (uint256 i = 0; i < size; i++) {
            address token = list[i];
            uint256 desposited = NODE.getDepositBalance(beneficiary, token);
            uint256 staked = NODE.getStakeBalance(beneficiary, token);
            report[i] = BeneficiaryBalance(token, desposited, staked);
            status = status || desposited > 0 || staked > 0;
        }
        return(report, size, status);
    }

    /**
     * Report the current balance for all tokens that have been deposited or staked
     */
    function beneficiaryBalanceReport()
        external view returns(BeneficiaryBalance[] memory report, uint256, bool)
    {
        return(beneficiaryBalanceReport(address(0)));
    }

    /**
     * Retrieve the net deposit balance for a given beneficiary and a given token
     */
    function getDepositBalance(
        address beneficiary,
        address token
    )
        external view returns(uint256)
    {
        return(NODE.getDepositBalance(beneficiary, token));
    }

    /**
     * Retrieve the total deposit balance for a given token
     */
    function getDepositBalance(address token)
        external view returns(uint256)
    {
        return(NODE.getDepositBalance(address(0), token));
    }

    /**
     * Retrieve the net stake balance for a given beneficiary and a given token
     */
    function getStakeBalance(
        address beneficiary,
        address token
    )
        external view returns(uint256)
    {
        return(NODE.getStakeBalance(beneficiary, token));
    }

    /**
     * Retrieve the total stake balance for a given token
     */
    function getStakeBalance(address token)
        external view returns(uint256)
    {
        return(NODE.getStakeBalance(address(0), token));
    }

    /**
     * Report the current staking balance for the core token
     */
    function balanceOf(address account)
        external view returns(uint256)
    {
        return(NODE.getDepositBalance(account, NODE.coreToken()) + NODE.getStakeBalance(account, NODE.coreToken()));
    }

    /**
     * Report the current staking balance for any token
     */
    function balanceOf(
        address account,
        address token
    )
        external view returns(uint256)
    {
        return(NODE.getDepositBalance(account, token) + NODE.getStakeBalance(account, token));
    }

    /**
     * Report total & paid fees for a platform
     */
    function platformFees(address platform)
        external view returns(Fee memory fee)
    {
        return(Fee(
            [NODE.platformFees(platform, 0, 0), NODE.platformFees(platform, 0, 1)],
            [NODE.platformFees(platform, 1, 0), NODE.platformFees(platform, 1, 1)]
        ));
    }

    /**
     * Report total & paid fees for an affiliate
     */
    function affiliateFees(address affiliate)
        external view returns(Fee memory fee)
    {
        return(Fee(
            [NODE.affiliateFees(affiliate, 0, 0), NODE.affiliateFees(affiliate, 0, 1)],
            [NODE.affiliateFees(affiliate, 1, 0), NODE.affiliateFees(affiliate, 1, 1)]
        ));
    }

    /**
     * Encode data payload
     */
    function encodeData(
        bytes32 id,
        address platform,
        address affiliate,
        bytes32[2] calldata network,
        address[2] calldata beneficiary,
        address[2] calldata token,
        uint256[2] calldata amount,
        int32[2] calldata timeout,
        bool[2] calldata explicit,
        bytes32 method,
        bytes calldata memo
    )
        external pure returns(bytes memory)
    {
        return(abi.encode(id, platform, affiliate, network, beneficiary, token, amount, timeout, explicit, method, memo));
    }

    /**
     * Encode empty params payload
     */
    function encodeParams()
        external pure returns(bytes memory)
    {
        return(bytes(""));
    }

    /**
     * Encode params payload
     */
    function encodeParams(
        bytes32 action,
        bytes memory args
    )
        external pure returns(bytes memory)
    {
        return(abi.encode(action, args));
    }

    /**
     * Encode signable message
     */
    function encodeMessage(
        bytes32 operation,
        bytes calldata encodedData,
        bytes calldata encodedParams,
        uint256[2] calldata fee
    )
        external pure returns(bytes32)
    {
        return(keccak256(abi.encodePacked(operation, encodedData, encodedParams, fee)));
    }

    /**
     * Encode single-signed payload
     */
    function encodePayload(
        bytes32 operation,
        bytes calldata encodedData,
        bytes calldata encodedParams,
        uint256[2] calldata fee,
        bytes calldata signature
    )
        external pure returns(bytes memory)
    {
        return(abi.encode(operation, abi.encode(encodedData, encodedParams, fee, signature)));
    }

    /**
     * Encode triple-signed payload
     */
    function encodePayload(
        bytes32 operation,
        bytes calldata encodedData,
        bytes calldata encodedParams,
        uint256[2] calldata fee,
        bytes[3] calldata signature
    )
        external pure returns(bytes memory)
    {
        return(abi.encode(operation, abi.encode(encodedData, encodedParams, fee, signature)));
    }

    /**
     * Decommission this contract
     */
    function decommission(address wallet)
        external onlyOwner
    {
        selfdestruct(payable(wallet));
    }
}
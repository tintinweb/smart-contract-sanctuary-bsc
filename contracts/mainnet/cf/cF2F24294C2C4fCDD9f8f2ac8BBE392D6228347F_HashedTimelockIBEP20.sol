/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT

/**

░██╗░░░░░░░██╗███████╗███╗░░██╗██╗░░░░░░█████╗░███╗░░░███╗██████╗░░█████╗░
░██║░░██╗░░██║██╔════╝████╗░██║██║░░░░░██╔══██╗████╗░████║██╔══██╗██╔══██╗
░╚██╗████╗██╔╝█████╗░░██╔██╗██║██║░░░░░███████║██╔████╔██║██████╦╝██║░░██║
░░████╔═████║░██╔══╝░░██║╚████║██║░░░░░██╔══██║██║╚██╔╝██║██╔══██╗██║░░██║
░░╚██╔╝░╚██╔╝░███████╗██║░╚███║███████╗██║░░██║██║░╚═╝░██║██████╦╝╚█████╔╝
░░░╚═╝░░░╚═╝░░╚══════╝╚═╝░░╚══╝╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝╚═════╝░░╚════╝░



██╗░░██╗░█████╗░░██████╗██╗░░██╗███████╗██████╗░  ████████╗██╗███╗░░░███╗███████╗██╗░░░░░░█████╗░░█████╗░██╗░░██╗
██║░░██║██╔══██╗██╔════╝██║░░██║██╔════╝██╔══██╗  ╚══██╔══╝██║████╗░████║██╔════╝██║░░░░░██╔══██╗██╔══██╗██║░██╔╝
███████║███████║╚█████╗░███████║█████╗░░██║░░██║  ░░░██║░░░██║██╔████╔██║█████╗░░██║░░░░░██║░░██║██║░░╚═╝█████═╝░
██╔══██║██╔══██║░╚═══██╗██╔══██║██╔══╝░░██║░░██║  ░░░██║░░░██║██║╚██╔╝██║██╔══╝░░██║░░░░░██║░░██║██║░░██╗██╔═██╗░
██║░░██║██║░░██║██████╔╝██║░░██║███████╗██████╔╝  ░░░██║░░░██║██║░╚═╝░██║███████╗███████╗╚█████╔╝╚█████╔╝██║░╚██╗
╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝╚══════╝╚═════╝░  ░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝╚══════╝╚══════╝░╚════╝░░╚════╝░╚═╝░░╚═╝



██╗░░░░░██████╗░  ██╗░░░░░░█████╗░░█████╗░██╗░░██╗███████╗██████╗░
██║░░░░░██╔══██╗  ██║░░░░░██╔══██╗██╔══██╗██║░██╔╝██╔════╝██╔══██╗
██║░░░░░██████╔╝  ██║░░░░░██║░░██║██║░░╚═╝█████═╝░█████╗░░██████╔╝
██║░░░░░██╔═══╝░  ██║░░░░░██║░░██║██║░░██╗██╔═██╗░██╔══╝░░██╔══██╗
███████╗██║░░░░░  ███████╗╚█████╔╝╚█████╔╝██║░╚██╗███████╗██║░░██║
╚══════╝╚═╝░░░░░  ╚══════╝░╚════╝░░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝
*/



// File: Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.7;

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

// File: Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)


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

// File: IBEP20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/BEP20/IBEP20.sol)



/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: HashedTimelockBEP20(basic version).sol


/**
* @title Hashed Timelock Contracts (HTLCs) on Binance BEP20 tokens.
*
* This contract provides a way to create and keep HTLCs for IBEP20 tokens.
*
* See HashedTimelock.sol for a contract that provides the same functions
* for the native bnb token.
*
* Protocol:
*
*  1) createContractAndLockTokens(receiver, hashlock, timelock, tokenContract, amount) - a
*      sender calls this to create a new HTLC on a given token (tokenContract)
*       for a given amount. A 32 byte contract id is returned
*  2) withdraw(contractId, preimage) - once the receiver knows the preimage of
*      the hashlock hash they can claim the tokens with this function
*  3) refund() - after timelock has expired and if the receiver did not
*      withdraw the tokens the sender / creator of the HTLC can get their tokens
*      back with this function.
 */
contract HashedTimelockIBEP20 is Ownable {
    event HTLCIBEP20New(
        bytes32 indexed contractId,
        address indexed sender,
        address tokenContract,
        uint256 amount,
        uint256 timelock
    );

    event HTLCIBEP20Refund(bytes32 indexed contractId);

    struct LockContract {
        address sender;
        address tokenContract;
        uint256 amount;
        // locked UNTIL this time. Unit depends on consensus algorithm.
        // PoA, PoA and IBFT all use seconds. But Quorum Raft uses nano-seconds
        uint256 timelock;
        bool refunded;
    }

    modifier tokensTransferable(address _token, address _sender, uint256 _amount) {
        require(_amount > 0, "token amount must be > 0");
        require(
            IBEP20(_token).allowance(_sender, address(this)) >= _amount,
            "token allowance must be >= amount"
        );
        _;
    }
    modifier futureTimelock(uint256 _time) {
        // only requirement is the timelock time is after the last blocktime (now).
        // probably want something a bit further in the future then this.
        // but this is still a useful sanity check:
        require(_time > block.timestamp, "timelock time must be in the future");
        _;
    }
    modifier contractExists(bytes32 _contractId) {
        require(haveContract(_contractId), "contractId does not exist");
        _;
    }


    modifier refundable(bytes32 _contractId) {
        require(contracts[_contractId].sender == msg.sender, "refundable: not sender");
        require(contracts[_contractId].refunded == false, "refundable: already refunded");
        require(contracts[_contractId].timelock <= block.timestamp, "refundable: timelock not yet passed");
        _;
    }

    mapping (bytes32 => LockContract) public contracts;

    /**
     * @dev Sender / Payer sets up a new hash time lock contract depositing the
     * funds and providing the reciever and terms.
     *
     * NOTE: _receiver must first call approve() on the token contract.
     *       See allowance check in tokensTransferable modifier.

     * @param _timelock UNIX epoch seconds time that the lock expires at.
     *                  Refunds can be made after this time.
     * @param _tokenContract IBEP20 Token contract address.
     * @param _amount Amount of the token to lock up.
     * @return contractId Id of the new HTLC. This is needed for subsequent
     *                    calls.
     */
    function createContractAndLockTokens (
        uint256 _timelock,
        address _tokenContract,
        uint256 _amount
    )
        external
        onlyOwner()
        tokensTransferable(_tokenContract, msg.sender, _amount)
        futureTimelock(_timelock)
        returns (bytes32 contractId)
    {
        contractId = sha256(
            abi.encodePacked(
                msg.sender,
                _tokenContract,
                _amount,
                _timelock
            )
        );

        // Reject if a contract already exists with the same parameters. The
        // sender must change one of these parameters (ideally providing a
        // different _hashlock).
        if (haveContract(contractId))
            revert("Contract already exists");

        // This contract becomes the temporary owner of the tokens
        if (!IBEP20(_tokenContract).transferFrom(msg.sender, address(this), _amount))
            revert("transferFrom sender to this failed");

        contracts[contractId] = LockContract(
            msg.sender,
            _tokenContract,
            _amount,
            _timelock,
            false
        );

        emit HTLCIBEP20New(
            contractId,
            msg.sender,
            _tokenContract,
            _amount,
            _timelock
        );
    }


    /**
     * @dev Called by the sender if there was no withdraw AND the time lock has
     * expired. This will restore ownership of the tokens to the sender.
     *
     * @param _contractId Id of HTLC to refund from.
     * @return bool true on success
     */
    function refund(bytes32 _contractId)
        external
        contractExists(_contractId)
        refundable(_contractId)
        returns (bool)
    {
        LockContract storage c = contracts[_contractId];
        c.refunded = true;
        IBEP20(c.tokenContract).transfer(c.sender, c.amount);
        emit HTLCIBEP20Refund(_contractId);
        return true;
    }

    function getContract(bytes32 _contractId)
        public
        view
        returns (
            address sender,
            address tokenContract,
            uint256 amount,
            uint256 timelock,
            bool refunded
        )
    {
        if (haveContract(_contractId) == false)
            return (address(0), address(0), 0, 0, false);
        LockContract storage c = contracts[_contractId];
        return (
            c.sender,
            c.tokenContract,
            c.amount,
            c.timelock,
            c.refunded
        );
    }

    /**
     * @dev Is there a contract with id _contractId.
     * @param _contractId Id into contracts mapping.
     */
    function haveContract(bytes32 _contractId)
        internal
        view
        returns (bool exists)
    {
        exists = (contracts[_contractId].sender != address(0));
    }

}
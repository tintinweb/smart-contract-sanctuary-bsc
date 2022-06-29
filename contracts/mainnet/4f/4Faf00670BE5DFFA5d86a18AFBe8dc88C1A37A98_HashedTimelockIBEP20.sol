pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0-only
import "./IBEP20.sol";

/**
* @title Hashed Timelock Contracts (HTLCs) on Ethereum ERC20 tokens.
*
* This contract provides a way to create and keep HTLCs for IBEP20 tokens.
*
* See HashedTimelock.sol for a contract that provides the same functions
* for the native ETH token.
*
* Protocol:
*
*  1) newContract(receiver, hashlock, timelock, tokenContract, amount) - a
*      sender calls this to create a new HTLC on a given token (tokenContract)
*       for a given amount. A 32 byte contract id is returned
*  2) withdraw(contractId, preimage) - once the receiver knows the preimage of
*      the hashlock hash they can claim the tokens with this function
*  3) refund() - after timelock has expired and if the receiver did not
*      withdraw the tokens the sender / creator of the HTLC can get their tokens
*      back with this function.
 */
contract HashedTimelockIBEP20 {
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

    mapping (bytes32 => LockContract) contracts;

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
    function newContract(
        uint256 _timelock,
        address _tokenContract,
        uint256 _amount
    )
        external

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
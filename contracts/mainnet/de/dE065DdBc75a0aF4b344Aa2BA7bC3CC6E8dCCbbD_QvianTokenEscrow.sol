/**
   Copyright (c) 2022 Qvian.com
 
   Licensed under the Apache License, Version 2.0 (the “License”);
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
 
      http://www.apache.org/licenses/LICENSE-2.0
 
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an “AS IS” BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;
 
abstract contract Token {
    function transfer(address _to, uint _value) public virtual returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public virtual returns (bool success);
    function virtualapprove(address _spender, uint _value) public virtual returns (bool success);
    function approve(address spender, uint256 value) public virtual returns (bool);
}

interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
/// @title Qvian Token Escrows
/// @author Qvian
contract QvianTokenEscrow {
    /***********************
    +   Global settings   +
    ***********************/
 
    // Address of the arbitrator (currently always Qvian staff)
    address public arbitrator;
    // Address of the owner (who can withdraw collected fees)
    address public owner;
    address public inviterAddress;
    // Addresses of the relayers (which addresses are allowed to forward signed instructions from parties)
    mapping (address => bool) public relayers;
 
    uint32 public requestCancellationMinimumTime;
    // Cumulative balance of collected fees
    // uint256 public feesAvailableForWithdraw;
    mapping(address => uint256) public feesAvailableForWithdraw;
 
    /***********************
    +  Instruction types  +
    ***********************/
 
    // Called when the buyer marked payment as sent. Locks funds in escrow
    uint8 constant INSTRUCTION_SELLER_CANNOT_CANCEL = 0x01;
    // Buyer cancelling
    uint8 constant INSTRUCTION_BUYER_CANCEL = 0x02;
    // Seller cancelling
    uint8 constant INSTRUCTION_SELLER_CANCEL = 0x03;
    // Seller requesting to cancel. Begins a window for buyer to object
    uint8 constant INSTRUCTION_SELLER_REQUEST_CANCEL = 0x04;
    // Seller releasing funds to the buyer
    uint8 constant INSTRUCTION_RELEASE = 0x05;
    // Either party permitting the arbitrator to resolve a dispute
    uint8 constant INSTRUCTION_RESOLVE = 0x06;
 
    /***********************
    +       Events        +
    ***********************/
 
    event Created(bytes32 indexed _tradeHash);
    event SellerCancelDisabled(bytes32 indexed _tradeHash);
    event SellerRequestedCancel(bytes32 indexed _tradeHash);
    event CancelledBySeller(bytes32 indexed _tradeHash);
    event CancelledByBuyer(bytes32 indexed _tradeHash);
    event Released(bytes32 indexed _tradeHash);
    event DisputeResolved(bytes32 indexed _tradeHash);
 
    struct Escrow {
        // So we know the escrow exists
        bool exists;
        // This is the timestamp in whic hthe seller can cancel the escrow after.
        // It has two special values:
        // 0 : Permanently locked by the buyer (i.e. marked as paid; the seller can never cancel)
        // 1 : The seller can only request to cancel, which will change this value to a timestamp.
        //     This option is avaialble for complex trade terms such as cash-in-person where a
        //     payment window is inappropriate
        uint32 sellerCanCancelAfter;
        // Cumulative cost of gas incurred by the relayer. This amount will be refunded to the owner
        // in the way of fees once the escrow has completed
        uint128 totalGasFeesSpentByRelayer;
    }
 
    // Mapping of active trades. The key here is a hash of the trade proprties
    mapping (bytes32 => Escrow) public escrows;

    // Mapping of escrow balance with token address
    mapping(address => uint256) public escrowBalance;
 
    modifier onlyOwner() {
        require(msg.sender == owner, "Must be owner");
        _;
    }
 
    modifier onlyArbitrator() {
        require(msg.sender == arbitrator, "Must be arbitrator");
        _;
    }
 
    /// @notice Initialize the contract.
    constructor() {
        owner = msg.sender;
        arbitrator = msg.sender;
        inviterAddress = msg.sender;
        requestCancellationMinimumTime = 0 seconds;
    }
 
    /// @notice Create and fund a new escrow.
    /// @param _tradeID The unique ID of the trade, generated by qvian.money
    /// @param _seller The selling party
    /// @param _buyer The buying party
    /// @param _value The amount of the escrow, exclusive of the fee
    /// @param _token The token address of the token being escrowed (NEW)
    /// @param _fee Qvian’s commission in 1/10000ths
    /// @param _paymentWindowInSeconds The time in seconds from escrow creation that the seller can cancel after
    /// @param _expiry This transaction must be created before this time
    /// @param _v Signature "v" component
    /// @param _r Signature "r" component
    /// @param _s Signature "s" component
    function createEscrow(
        bytes32 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        IBEP20 _token,
        uint16 _fee,
        uint32 _paymentWindowInSeconds,
        uint32 _expiry,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        // The trade hash is created by tightly-concatenating and hashing properties of the trade.
        // This hash becomes the identifier of the escrow, and hence all these variables must be
        // supplied on future contract calls
        bytes32 _tradeHash = keccak256(abi.encodePacked(_tradeID, _seller, _buyer, _value, _token, _fee));
        // Require that trade does not already exist
        require(!escrows[_tradeHash].exists, "Trade already exists");
        // A signature (v, r and s) must come from qvian to open an escrow
        bytes32 _invitationHash = keccak256(abi.encodePacked(
            _tradeHash,
            _paymentWindowInSeconds,
            _expiry
        ));
        require(recoverAddress(_invitationHash, _v, _r, _s) == inviterAddress, "Invitation signature was not valid");
        // These signatures come with an expiry stamp
        require(block.timestamp < _expiry, "Signature has expired");
        // transfer token from the seller to the contract
        require(_token.transferFrom(msg.sender, address(this), _value));
        // Check transaction value against signed _value and make sure is not 0
        // require(msg.value == _value && msg.value > 0, "Incorrect ether sent");
        uint32 _sellerCanCancelAfter = _paymentWindowInSeconds == 0
            ? 1
            : uint32(block.timestamp) + _paymentWindowInSeconds;
        // Add the escrow to the public mapping
        escrows[_tradeHash] = Escrow(true, _sellerCanCancelAfter, 0);
        // Map the balance of tokens with token address
        escrowBalance[address(_token)] += _value;
        emit Created(_tradeHash);
    }
 
    uint16 constant GAS_doResolveDispute = 45368;
    /// @notice Called by the arbitrator to resolve a dispute. Requires a signature from either party.
    /// @param _tradeID Escrow "tradeID" parameter
    /// @param _seller Escrow "seller" parameter
    /// @param _buyer Escrow "buyer" parameter
    /// @param _value Escrow "value" parameter
    /// @param _fee Escrow "fee parameter
    /// @param _v Signature "v" component
    /// @param _r Signature "r" component
    /// @param _s Signature "s" component
    /// @param _buyerPercent What % should be distributed to the buyer (this is usually 0 or 100)
    function resolveDispute(
        bytes32 _tradeID,
        address payable _seller,
        address payable _buyer,
        uint256 _value,
        IBEP20 _token,
        uint16 _fee,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint8 _buyerPercent
    ) external onlyArbitrator {
        address _signature = recoverAddress(keccak256(abi.encodePacked(
            _tradeID,
            INSTRUCTION_RESOLVE
        )), _v, _r, _s);
        require(_signature == _buyer || _signature == _seller, "Must be buyer or seller");
 
        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _token, _fee);
        require(_escrow.exists, "Escrow does not exist");
        require(_buyerPercent <= 100, "_buyerPercent must be 100 or lower");
 
        // uint256 _totalFees = _escrow.totalGasFeesSpentByRelayer + (GAS_doResolveDispute * uint128(tx.gasprice));
        // require(_value - _totalFees <= _value, "Overflow error"); // Prevent underflow
        // feesAvailableForWithdraw[address(_token)] += _totalFees; // Add the the pot for qvian to withdraw
 
        delete escrows[_tradeHash];
        emit DisputeResolved(_tradeHash);
        if (_buyerPercent > 0)
          _token.transfer(_buyer, _value * _buyerPercent / 100);
        if (_buyerPercent < 100)
          _token.transfer(_seller, _value * (100 - _buyerPercent) / 100);
    }
 
    /// @notice Release ether in escrow to the buyer. Direct call option.
    /// @param _tradeID Escrow "tradeID" parameter
    /// @param _seller Escrow "seller" parameter
    /// @param _buyer Escrow "buyer" parameter
    /// @param _value Escrow "value" parameter
    /// @param _fee Escrow "fee parameter
    /// @return bool
    function release(
        bytes32 _tradeID,
        address _seller,
        address payable _buyer,
        uint256 _value,
        IBEP20 _token,
        uint16 _fee
    ) external returns (bool) {
        require(msg.sender == _seller, "Must be seller");
        return doRelease(_tradeID, _seller, _buyer, _value, _token, _fee);
    }
 
    /// @notice Disable the seller from cancelling (i.e. "mark as paid"). Direct call option.
    /// @param _tradeID Escrow "tradeID" parameter
    /// @param _seller Escrow "seller" parameter
    /// @param _buyer Escrow "buyer" parameter
    /// @param _value Escrow "value" parameter
    /// @param _fee Escrow "fee parameter
    /// @return bool
    function disableSellerCancel(
        bytes32 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        IBEP20 _token,
        uint16 _fee
    ) external returns (bool) {
        require(msg.sender == _buyer, "Must be buyer");
        return doDisableSellerCancel(_tradeID, _seller, _buyer, _value, _token, _fee);
    }
 
    /// @notice Cancel the escrow as a buyer. Direct call option.
    /// @param _tradeID Escrow "tradeID" parameter
    /// @param _seller Escrow "seller" parameter
    /// @param _buyer Escrow "buyer" parameter
    /// @param _value Escrow "value" parameter
    /// @param _fee Escrow "fee parameter
    /// @return bool
    function buyerCancel(
      bytes32 _tradeID,
      address payable _seller,
      address _buyer,
      uint256 _value,
      IBEP20 _token,
      uint16 _fee
    ) external returns (bool) {
        require(msg.sender == _buyer, "Must be buyer");
        return doBuyerCancel(_tradeID, _seller, _buyer, _value, _token, _fee);
    }
 
    /// @notice Cancel the escrow as a seller. Direct call option.
    /// @param _tradeID Escrow "tradeID" parameter
    /// @param _seller Escrow "seller" parameter
    /// @param _buyer Escrow "buyer" parameter
    /// @param _value Escrow "value" parameter
    /// @param _fee Escrow "fee parameter
    /// @return bool
    function sellerCancel(
        bytes32 _tradeID,
        address payable _seller,
        address _buyer,
        uint256 _value,
        IBEP20 _token,
        uint16 _fee
    ) external returns (bool) {
        require(msg.sender == _seller, "Must be seller");
        return doSellerCancel(_tradeID, _seller, _buyer, _value, _token, _fee);
    }
 
    /// @notice Request to cancel as a seller. Direct call option.
    /// @param _tradeID Escrow "tradeID" parameter
    /// @param _seller Escrow "seller" parameter
    /// @param _buyer Escrow "buyer" parameter
    /// @param _value Escrow "value" parameter
    /// @param _fee Escrow "fee parameter
    /// @return bool
    function sellerRequestCancel(
        bytes32 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        IBEP20 _token,
        uint16 _fee
    ) external returns (bool) {
        require(msg.sender == _seller, "Must be seller");
        return doSellerRequestCancel(_tradeID, _seller, _buyer, _value, _token, _fee);
    }
 
    /// @notice Withdraw fees collected by the contract. Only the owner can call this.
    /// @param _to Address to withdraw fees in to
    /// @param _amount Amount to withdraw
    function withdrawFees(address payable _to, uint256 _amount, IBEP20 _token) onlyOwner external {
        // This check also prevents underflow
        require(_amount <= feesAvailableForWithdraw[address(_token)], "Amount is higher than amount available");
        feesAvailableForWithdraw[address(_token)] -= _amount;
        _token.transfer(_to, _amount);
    }
 
    /// @notice Set the arbitrator to a new address. Only the owner can call this.
    /// @param _newArbitrator Address of the replacement arbitrator
    function setArbitrator(address _newArbitrator) onlyOwner external {
        arbitrator = _newArbitrator;
    }
 
    /// @notice Change the owner to a new address. Only the owner can call this.
    /// @param _newOwner Address of the replacement owner
    function setOwner(address _newOwner) onlyOwner external {
        owner = _newOwner;
    }
 
    /// @notice Change the inviter to a new address. Only the owner can call this.
    /// @param _newInviterAddress Address of the inviter address
    function setInviterAddress(address _newInviterAddress) onlyOwner external {
        inviterAddress = _newInviterAddress;
    }
 
    /// @notice Change the requestCancellationMinimumTime. Only the owner can call this.
    /// @param _newRequestCancellationMinimumTime Replacement
    function setRequestCancellationMinimumTime(
        uint32 _newRequestCancellationMinimumTime
    ) onlyOwner external {
        requestCancellationMinimumTime = _newRequestCancellationMinimumTime;
    }
 
    // /// @notice Send ERC20 tokens away. This function allows the owner to withdraw stuck ERC20 tokens.
    // /// @param _tokenContract Token contract
    // /// @param _transferTo Recipient
    // /// @param _value Value
    // function transferToken(
    //     Token _tokenContract,
    //     address _transferTo,
    //     uint256 _value
    // ) onlyOwner external {
    //     _tokenContract.transfer(_transferTo, _value);
    // }
 
    // /// @notice Send ERC20 tokens away. This function allows the owner to withdraw stuck ERC20 tokens.
    // /// @param _tokenContract Token contract
    // /// @param _transferTo Recipient
    // /// @param _transferFrom Sender
    // /// @param _value Value
    // function transferTokenFrom(
    //     Token _tokenContract,
    //     address _transferTo,
    //     address _transferFrom,
    //     uint256 _value
    // ) onlyOwner external {
    //     _tokenContract.transferFrom(_transferTo, _transferFrom, _value);
    // }
 
    /// @notice Send ERC20 tokens away. This function allows the owner to withdraw stuck ERC20 tokens.
    /// @param _tokenContract Token contract
    /// @param _spender Spender address
    /// @param _value Value
    function approveToken(
        Token _tokenContract,
        address _spender,
        uint256 _value
    ) onlyOwner external {
        _tokenContract.approve(_spender, _value);
    }
 
    /// @notice Increase the amount of gas to be charged later on completion of an escrow
    /// @param _tradeHash Trade hash
    /// @param _gas Gas cost
    function increaseGasSpent(bytes32 _tradeHash, uint128 _gas) private {
        escrows[_tradeHash].totalGasFeesSpentByRelayer += _gas * uint128(tx.gasprice);
    }
 
    /// @notice Transfer the value of an escrow, minus the fees, minus the gas costs incurred by relay
    /// @param _to Recipient address
    /// @param _value Value of the transfer
    /// @param _fee Commission in 1/10000ths
    function transferMinusFees(
        address payable _to,
        uint256 _value,
        IBEP20 _token,
        // uint128 _totalGasFeesSpentByRelayer,
        uint16 _fee
    ) private {
        uint256 _totalFees = _value * _fee / 10000; // + _totalGasFeesSpentByRelayer
        // Prevent underflow
        if(_value - _totalFees > _value) {
            return;
        }
        // Add fees to the pot for qvian to withdraw
        feesAvailableForWithdraw[address(_token)] += _totalFees;
        // payable(_to).transfer(_value - _totalFees);
        _token.transfer(_to, _value - _totalFees);
    }
 
    uint16 constant GAS_doRelease = 12664;
    /// @notice Release escrow to the buyer. This completes it and removes it from the mapping.
    /// @param _tradeID Escrow "tradeID" parameter
    /// @param _seller Escrow "seller" parameter
    /// @param _buyer Escrow "buyer" parameter
    /// @param _value Escrow "value" parameter
    /// @param _fee Escrow "fee parameter
    /// @return bool
    function doRelease(
        bytes32 _tradeID,
        address _seller,
        address payable _buyer,
        uint256 _value,
        IBEP20 _token,
        uint16 _fee
        // uint128 _additionalGas
    ) private returns (bool) {
        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _token, _fee);
        if (!_escrow.exists) return false;
        // uint128 _gasFees = _escrow.totalGasFeesSpentByRelayer
        //     + (relayers[msg.sender] == true
        //         ? (GAS_doRelease + _additionalGas ) * uint128(tx.gasprice)
        //         : 0
        //     );
        delete escrows[_tradeHash];
        emit Released(_tradeHash);
        transferMinusFees(_buyer, _value, _token, _fee);
        return true;
    }
 
    uint16 constant GAS_doDisableSellerCancel = 16568;
    /// @notice Prevents the seller from cancelling an escrow. Used to "mark as paid" by the buyer.
    /// @param _tradeID Escrow "tradeID" parameter
    /// @param _seller Escrow "seller" parameter
    /// @param _buyer Escrow "buyer" parameter
    /// @param _value Escrow "value" parameter
    /// @param _fee Escrow "fee parameter
    /// @return bool
    function doDisableSellerCancel(
        bytes32 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        IBEP20 _token,
        uint16 _fee
        // uint128 _additionalGas
    ) private returns (bool) {
        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _token, _fee);
        if (!_escrow.exists) return false;
        if(_escrow.sellerCanCancelAfter == 0) return false;
        escrows[_tradeHash].sellerCanCancelAfter = 0;
        emit SellerCancelDisabled(_tradeHash);
        // if (relayers[msg.sender] == true) {
        //   increaseGasSpent(_tradeHash, GAS_doDisableSellerCancel + _additionalGas);
        // }
        return true;
    }
 
    uint16 constant GAS_doBuyerCancel = 12648;
    /// @notice Cancels the trade and returns the ether to the seller. Can only be called the buyer.
    /// @param _tradeID Escrow "tradeID" parameter
    /// @param _seller Escrow "seller" parameter
    /// @param _buyer Escrow "buyer" parameter
    /// @param _value Escrow "value" parameter
    /// @param _fee Escrow "fee parameter
    /// @return bool
    function doBuyerCancel(
        bytes32 _tradeID,
        address payable _seller,
        address _buyer,
        uint256 _value,
        IBEP20 _token,
        uint16 _fee
        // uint128 _additionalGas
    ) private returns (bool) {
        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _token, _fee);
        if (!_escrow.exists) {
            return false;
        }
        // uint128 _gasFees = _escrow.totalGasFeesSpentByRelayer
        //     + (relayers[msg.sender] == true
        //         ? (GAS_doBuyerCancel + _additionalGas ) * uint128(tx.gasprice)
        //         : 0
        //     );
        delete escrows[_tradeHash];
        emit CancelledByBuyer(_tradeHash);
        transferMinusFees(_seller, _value, _token, 0);
        return true;
    }
 
    uint16 constant GAS_doSellerCancel = 13714;
    /// @notice Returns the ether in escrow to the seller. Called by the seller. Sometimes unavailable.
    /// @param _tradeID Escrow "tradeID" parameter
    /// @param _seller Escrow "seller" parameter
    /// @param _buyer Escrow "buyer" parameter
    /// @param _value Escrow "value" parameter
    /// @param _fee Escrow "fee parameter
    /// @return bool
    function doSellerCancel(
        bytes32 _tradeID,
        address payable _seller,
        address _buyer,
        uint256 _value,
        IBEP20 _token,
        uint16 _fee
        // uint128 _additionalGas
    ) private returns (bool) {
        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _token, _fee);
        if (!_escrow.exists) {
            return false;
        }
        if(_escrow.sellerCanCancelAfter <= 1 || _escrow.sellerCanCancelAfter > block.timestamp) {
            return false;
        }
        if (relayers[msg.sender] == false && _escrow.sellerCanCancelAfter + 12 hours > block.timestamp) {
            return false;
        }
        // uint128 _gasFees = _escrow.totalGasFeesSpentByRelayer
        //     + (relayers[msg.sender] == true
        //         ? (GAS_doSellerCancel + _additionalGas ) * uint128(tx.gasprice)
        //         : 0
        //     );
        delete escrows[_tradeHash];
        emit CancelledBySeller(_tradeHash);
        transferMinusFees(_seller, _value, _token, 0);
        return true;
    }
 
    uint16 constant GAS_doSellerRequestCancel = 17004;
    /// @notice Request to cancel. Used if the buyer is unresponsive. Begins a countdown timer.
    /// @param _tradeID Escrow "tradeID" parameter
    /// @param _seller Escrow "seller" parameter
    /// @param _buyer Escrow "buyer" parameter
    /// @param _value Escrow "value" parameter
    /// @param _fee Escrow "fee parameter
    /// @return bool
    function doSellerRequestCancel(
        bytes32 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        IBEP20 _token,
        uint16 _fee
    ) private returns (bool) {
        // Called on unlimited payment window trades where the buyer is not responding
        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _token, _fee);
        if (!_escrow.exists) {
            return false;
        }
        if(_escrow.sellerCanCancelAfter != 1) {
            return false;
        }
        escrows[_tradeHash].sellerCanCancelAfter = uint32(block.timestamp)
            + requestCancellationMinimumTime;
        emit SellerRequestedCancel(_tradeHash);
        // if (relayers[msg.sender] == true) {
        //   increaseGasSpent(_tradeHash, GAS_doSellerRequestCancel + _additionalGas);
        // }
        return true;
    }
 
    /// @notice Hashes the values and returns the matching escrow object and trade hash.
    /// @dev Returns an empty escrow struct and 0 _tradeHash if not found.
    /// @param _tradeID Escrow "tradeID" parameter
    /// @param _seller Escrow "seller" parameter
    /// @param _buyer Escrow "buyer" parameter
    /// @param _value Escrow "value" parameter
    /// @param _fee Escrow "fee parameter
    /// @return Escrow
    function getEscrowAndHash(
        bytes32 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        IBEP20 _token,
        uint16 _fee
    ) view private returns (Escrow memory, bytes32) {
        bytes32 _tradeHash = keccak256(abi.encodePacked(
            _tradeID,
            _seller,
            _buyer,
            _value,
            _token,
            _fee
        ));
        return (escrows[_tradeHash], _tradeHash);
    }
 
    /// @notice Returns an empty escrow struct and 0 _tradeHash if not found.
    /// @param _h Data to be hashed
    /// @param _v Signature "v" component
    /// @param _r Signature "r" component
    /// @param _s Signature "s" component
    /// @return address
    function recoverAddress(
        bytes32 _h,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (address) {
        bytes memory _prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 _prefixedHash = keccak256(abi.encodePacked(_prefix, _h));
        return ecrecover(_prefixedHash, _v, _r, _s);
    }
}
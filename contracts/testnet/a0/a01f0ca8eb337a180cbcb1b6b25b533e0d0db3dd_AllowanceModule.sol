/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// File: messenger/interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// File: messenger/interfaces/IWETH.sol



pragma solidity 0.8.0;


interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint amount) external;

    
}
// File: SignatureDecoder.sol


pragma solidity 0.8.0;

/// @title SignatureDecoder - Decodes signatures that a encoded as bytes
/// @author Ricardo Guilherme Schmidt (Status Research & Development GmbH)
/// @author Richard Meissner - <[email protected]>
contract SignatureDecoder {
    
    /// @dev Recovers address who signed the message
    /// @param messageHash operation ethereum signed message hash
    /// @param messageSignature message `txHash` signature
    /// @param pos which signature to read
    function recoverKey (
        bytes32 messageHash,
        bytes memory messageSignature,
        uint256 pos
    )
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = signatureSplit(messageSignature, pos);
        return ecrecover(messageHash, v, r, s);
    }

    /// @dev divides bytes signature into `uint8 v, bytes32 r, bytes32 s`.
    /// @notice Make sure to peform a bounds check for @param pos, to avoid out of bounds access on @param signatures
    /// @param pos which signature to read. A prior bounds check of this parameter should be performed, to avoid out of bounds access
    /// @param signatures concatenated rsv signatures
    function signatureSplit(bytes memory signatures, uint256 pos)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            // Here we are loading the last 32 bytes, including 31 bytes
            // of 's'. There is no 'mload8' to do this.
            //
            // 'byte' is not working due to the Solidity parser, so lets
            // use the second best option, 'and'
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }
}

// File: Enum.sol


pragma solidity 0.8.0;

/// @title Enum - Collection of enums
/// @author Richard Meissner - <[email protected]>
contract Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

// File: AlowanceModule.sol


pragma solidity 0.8.0;




interface GnosisSafe {
    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(address to, uint256 value, bytes calldata data, Enum.Operation operation)
        external
        returns (bool success);
}

interface IMessenger {

     function initialize_token_account(
        bytes memory account,
        bytes memory token_mint
    ) external payable; 

    function initialize_pda(
        bytes memory account
    ) external payable;

    function getTotalFee() external view returns (uint256);
}

contract AllowanceModule is SignatureDecoder {

    string public constant NAME = "Allowance Module";
    string public constant VERSION = "0.1.0";

    bytes32 public constant DOMAIN_SEPARATOR_TYPEHASH = 0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;
    // keccak256(
    //     "EIP712Domain(uint256 chainId,address verifyingContract)"
    // );

    bytes32 public constant ALLOWANCE_TRANSFER_TYPEHASH = 0x4dd1b7a6ebcbe5bda29f795e91a51fe9556ef167114f25e583872a60fa8a4886;
    // keccak256(
    //     "AllowanceTransfer(address safe,address token,uint256 amount,uint16 nonce)"
    // );

    //Proxy Contract
    IMessenger public messenger;
    //WBNB Contract 
    IWETH public weth;

    // Safe -> Delegate -> Allowance
    mapping(address => mapping (address => mapping(address => Allowance))) public allowances;
    // Safe -> Delegate -> Tokens
    mapping(address => mapping (address => address[])) public tokens;
    // Safe -> Delegates double linked list entry points
    mapping(address => address) public delegatesStart;
    // Safe -> Delegates double linked list
    mapping(address => mapping (address => Delegate)) public delegates;

    // We use a double linked list for the delegates. The id is the first 6 bytes. 
    // To double check the address in case of collision, the address is part of the struct.
    struct Delegate {
        address delegate;
        address prev;
        address next;
    }

    // The allowance info is optimized to fit into one word of storage.
    struct Allowance {
        uint256 amount;
        uint256 spent;
        uint16 resetTimeMin; // Maximum reset time span is 65k minutes
        uint32 lastResetMin;
        uint16 nonce;
    }

    event AddDelegate(address indexed safe, address delegate);
    event RemoveDelegate(address indexed safe, address delegate);
    event ExecuteAllowanceTransfer(address indexed safe, address delegate, address token, address to, uint256 value, uint16 nonce);
    event InitializeTokenAccount(address indexed safe, bytes token_mint, address delegate, address paymentReceiver, uint256 payment );
    event InitializePDAAccount(address indexed safe, address delegate, address paymentReceiver, uint256 payment );
    event SetAllowance(address indexed safe, address delegate, address token, uint96 allowanceAmount, uint16 resetTime);
    event ResetAllowance(address indexed safe, address delegate, address token);
    event DeleteAllowance(address indexed safe, address delegate, address token);

    constructor (address _messenger, address _wbnb){
        messenger = IMessenger(_messenger);
        weth = IWETH(_wbnb);
    } 

    /// @dev Allows to update the allowance for a specified token. This can only be done via a Safe transaction.
    /// @param delegate Delegate whose allowance should be updated.
    /// @param token Token contract address.
    /// @param allowanceAmount allowance in smallest token unit.
    /// @param resetTimeMin Time after which the allowance should reset
    /// @param resetBaseMin Time based on which the reset time should be increased
    function setAllowance(address delegate, address token, uint96 allowanceAmount, uint16 resetTimeMin, uint32 resetBaseMin)
        public
    {
        require(delegate != address(0), "delegate != address(0)");
        require(delegates[msg.sender][delegate].delegate == delegate, "delegates[msg.sender][(uint256(delegate) >> 208)].delegate == delegate");
        Allowance memory allowance = getAllowance(msg.sender, delegate, token);
        if (allowance.nonce == 0) { // New token
            // Nonce should never be 0 once allowance has been activated
            allowance.nonce = 1;
            tokens[msg.sender][delegate].push(token);
        }
        // Divide by 60 to get current time in minutes
        // solium-disable-next-line security/no-block-members
        uint32 currentMin = uint32(block.timestamp / 60);
        if (resetBaseMin > 0) {
            require(resetBaseMin <= currentMin, "resetBaseMin <= currentMin");
            allowance.lastResetMin = currentMin - ((currentMin - resetBaseMin) % resetTimeMin);
        } else if (allowance.lastResetMin == 0) {
            allowance.lastResetMin = currentMin;
        }
        allowance.resetTimeMin = resetTimeMin;
        allowance.amount = allowanceAmount;
        updateAllowance(msg.sender, delegate, token, allowance);
        emit SetAllowance(msg.sender, delegate, token, allowanceAmount, resetTimeMin);
    }

    function getAllowance(address safe, address delegate, address token) private view returns (Allowance memory allowance) {
        allowance = allowances[safe][delegate][token];
        // solium-disable-next-line security/no-block-members
        uint32 currentMin = uint32(block.timestamp / 60);
        // Check if we should reset the time. We do this on load to minimize storage read/ writes
        if (allowance.resetTimeMin > 0 && allowance.lastResetMin <= currentMin - allowance.resetTimeMin) {
            allowance.spent = 0;
            // Resets happen in regular intervals and `lastResetMin` should be aligned to that
            allowance.lastResetMin = currentMin - ((currentMin - allowance.lastResetMin) % allowance.resetTimeMin);
        }
        return allowance;
    }

    function updateAllowance(address safe, address delegate, address token, Allowance memory allowance) private {
        allowances[safe][delegate][token] = allowance;
    }

    /// @dev Allows to reset the allowance for a specific delegate and token.
    /// @param delegate Delegate whose allowance should be updated.
    /// @param token Token contract address.
    function resetAllowance(address delegate, address token) public {
        Allowance memory allowance = getAllowance(msg.sender, delegate, token);
        allowance.spent = 0;
        updateAllowance(msg.sender, delegate, token, allowance);
        emit ResetAllowance(msg.sender, delegate, token);
    }

    /// @dev Allows to remove the allowance for a specific delegate and token. This will set all values except the `nonce` to 0.
    /// @param delegate Delegate whose allowance should be updated.
    /// @param token Token contract address.
    function deleteAllowance(address delegate, address token)
        public
    {
        Allowance memory allowance = getAllowance(msg.sender, delegate, token);
        allowance.amount = 0;
        allowance.spent = 0;
        allowance.resetTimeMin = 0;
        allowance.lastResetMin = 0;
        updateAllowance(msg.sender, delegate, token, allowance);
        emit DeleteAllowance(msg.sender, delegate, token);
    }

    /// @dev Allows to use the allowance to perform a transfer.
    /// @param safe The Safe whose funds should be used.
    /// @param token Token contract address.
    /// @param value Token amount.
    /// @param token_mint Token Account that needs to be initialized
    /// @param delegate Delegate whose allowance should be updated.
    /// @param signature Signature generated by the delegate to authorize the transfer.
    function executeTokenAccountInitialization(
        GnosisSafe safe,
        address token,
        uint256 value,
        bytes memory token_mint,
        address delegate,
        bytes memory signature
    ) public {
        // Get current state
        Allowance memory allowance = getAllowance(address(safe), delegate, token);

        // Update state
        allowance.nonce = allowance.nonce + 1;

        //Get Total Fee
        IMessenger _messenger = IMessenger(messenger);
        uint256 amount = _messenger.getTotalFee();

        bytes memory transferHashData = generateTransferHashData(address(safe), token, amount, allowance.nonce);

        //Check for value  
        require(value >= amount, "Value less then amount");

        uint256 newSpent = allowance.spent + value;
        // Check new spent amount and overflow
        require(newSpent > allowance.spent && newSpent <= allowance.amount, "newSpent > allowance.spent && newSpent <= allowance.amount");
        allowance.spent = newSpent;

        // Use updated allowance token 
        Allowance memory paymentAllowance =  allowance;
        newSpent = paymentAllowance.spent + amount;
        // Check new spent amount and overflow
        require(newSpent > paymentAllowance.spent && newSpent <= paymentAllowance.amount, "newSpent > paymentAllowance.spent && newSpent <= paymentAllowance.amount");
        
        paymentAllowance.spent = newSpent;
        updateAllowance(address(safe), delegate, token, allowance);

        // Perform external interactions
        // Check signature
        checkSignature(delegate, signature, transferHashData, safe);

        // Transfer payment to the modules 
        transfer(safe, token, payable(this), amount);
        unwrapWBNB(amount);

        // Perform Initialize of Token Account  initialize_token_account
        bytes memory _safe = abi.encode(safe);
        _messenger.initialize_token_account{value: amount}(_safe, token_mint);

        // solium-disable-next-line security/no-tx-origin
        emit InitializeTokenAccount(address(safe), token_mint, delegate, tx.origin, amount);
        emit ExecuteAllowanceTransfer(address(safe), delegate, token, address(messenger), amount, allowance.nonce - 1);
    }


    /// @dev Allows to use the allowance to perform a transfer.
    /// @param safe The Safe whose funds should be used.
    /// @param token Token contract address.
    /// @param value Token contract address.
    /// @param delegate Delegate whose allowance should be updated.
    /// @param signature Signature generated by the delegate to authorize the transfer.
    function executePDAAccountInitialization(
        GnosisSafe safe,
        address token,
        uint256 value,
        address delegate,
        bytes memory signature
    ) public payable{
        // Get current state
        Allowance memory allowance = getAllowance(address(safe), delegate, token);

        // Update state
        allowance.nonce = allowance.nonce + 1;

        //Get Total Fee
        IMessenger _messenger = IMessenger(messenger);
        uint256 amount = _messenger.getTotalFee();

        bytes memory transferHashData = generateTransferHashData(address(safe), token, amount, allowance.nonce);

        //Check for value  
        require(value >= amount, "Value less then amount");

        uint256 newSpent = allowance.spent + amount;
        // Check new spent amount and overflow
        require(newSpent > allowance.spent && newSpent <= allowance.amount, "newSpent > allowance.spent && newSpent <= allowance.amount");
        allowance.spent = newSpent;

        // Use updated allowance token 
        Allowance memory paymentAllowance =  allowance;
        newSpent = paymentAllowance.spent + value;
        // Check new spent amount and overflow
        require(newSpent > paymentAllowance.spent && newSpent <= paymentAllowance.amount, "newSpent > paymentAllowance.spent && newSpent <= paymentAllowance.amount");
        
        paymentAllowance.spent = newSpent;
        updateAllowance(address(safe), delegate, token, allowance);

        // Perform external interactions
        // Check signature
        checkSignature(delegate, signature, transferHashData, safe);

        // Transfer payment to the transaction doer
        transfer(safe, address(weth), payable(this), amount);
        unwrapWBNB(amount);

        // Perform Initialize of Token Account  initialize_token_account
        bytes memory _safe = abi.encode(safe);
        _messenger.initialize_pda{value: amount}(_safe);

        // solium-disable-next-line security/no-tx-origin
        emit InitializePDAAccount(address(safe), delegate, tx.origin, amount);
        emit ExecuteAllowanceTransfer(address(safe), delegate, token, address(messenger), amount, allowance.nonce - 1);
    }


    /// @dev Returns the chain id used by this contract.
    function getChainId() public view returns (uint256) {
        uint256 id;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            id := chainid()
        }
        return id;
    }

    /// @dev s the data for the transfer hash (required for signing)
    function generateTransferHashData(
        address safe,
        address token,
        uint256 amount,
        uint16 nonce
    ) public view returns (bytes memory) {
        uint256 chainId = getChainId();
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_SEPARATOR_TYPEHASH, chainId, this));
        bytes32 transferHash = keccak256(
            abi.encode(ALLOWANCE_TRANSFER_TYPEHASH, safe, token, amount, nonce)
        );
        return abi.encodePacked("\x19\x01",domainSeparator,transferHash);
    }

    /// @dev Unwrap WBNB
    function unwrapWBNB(uint256 amount) internal returns(uint256){
        uint256 previousBalance = address(this).balance;
        IWETH iWeth = IWETH(weth);
        iWeth.withdraw(amount);
        uint256 newBalance = address(this).balance;
        return newBalance - previousBalance;
    } 

    /// @dev Generates the transfer hash that should be signed to authorize a transfer
    function generateTransferHash(
        address safe,
        address token,
        uint256 amount,
        uint16 nonce
    ) private view returns (bytes32) {
        return keccak256(generateTransferHashData(
            safe, token, amount, nonce
        ));
    }

    function checkSignature(address expectedDelegate, bytes memory signature, bytes memory transferHashData, GnosisSafe safe) public view {
        address signer = recoverSignature(signature, transferHashData);
        require(
            expectedDelegate == signer && delegates[address(safe)][signer].delegate == signer,
            "expectedDelegate == signer && delegates[address(safe)][signer].delegate == signer"
        );
    }

    // We use the same format as used for the Safe contract, except that we only support exactly 1 signature and no contract signatures.
    function recoverSignature(bytes memory signature, bytes memory transferHashData) private view returns (address owner) {
        // If there is no signature data msg.sender should be used
        if (signature.length == 0) return msg.sender;
        // Check that the provided signature data is as long as 1 encoded ecsda signature
        require(signature.length == 65, "signatures.length == 65");
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = signatureSplit(signature, 0);
        // If v is 0 then it is a contract signature
        if (v == 0) {
            revert("Contract signatures are not supported by this module");
        } else if (v == 1) {
            // If v is 1 we also use msg.sender, this is so that we are compatible to the GnosisSafe signature scheme
            owner = msg.sender;
        } else if (v > 30) {
            // To support eth_sign and similar we adjust v and hash the transferHashData with the Ethereum message prefix before applying ecrecover
            owner = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(transferHashData))), v - 4, r, s);
        } else {
            // Use ecrecover with the messageHash for EOA signatures
            owner = ecrecover(keccak256(transferHashData), v, r, s);
        }
        // 0 for the recovered owner indicates that an error happened.
        require(owner != address(0), "owner != address(0)");
    }

    function transfer(GnosisSafe safe, address token, address payable to, uint256 amount) private {
        if (token == address(0)) {
            // solium-disable-next-line security/no-send
            require(safe.execTransactionFromModule(to, amount, "", Enum.Operation.Call), "Could not execute ether transfer");
        } else {
            bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", to, amount);
            require(safe.execTransactionFromModule(token, 0, data, Enum.Operation.Call), "Could not execute token transfer");
        }
    }

    function getTokens(address safe, address delegate) public view returns (address[] memory) {
        return tokens[safe][delegate];
    }

    function getTokenAllowance(address safe, address delegate, address token) public view returns (uint256[5] memory) {
        Allowance memory allowance = getAllowance(safe, delegate, token);
        return [
            uint256(allowance.amount),
            uint256(allowance.spent),
            uint256(allowance.resetTimeMin),
            uint256(allowance.lastResetMin),
            uint256(allowance.nonce)
        ];
    }

    /// @dev Allows to add a delegate.
    /// @param delegate Delegate that should be added.
    function addDelegate(address delegate) public {
        address currentDelegate = delegates[msg.sender][delegate].delegate;
        if(currentDelegate != address(0)) {
            // We have a collision for the indices of delegates
            require(currentDelegate == delegate, "currentDelegate == delegate");
            // Delegate already exists, nothing to do
            return;
        }
        address startIndex = delegatesStart[msg.sender];
        delegates[msg.sender][delegate] = Delegate(delegate, address(0), startIndex);
        delegates[msg.sender][startIndex].prev = delegate;
        delegatesStart[msg.sender] = delegate;
        emit AddDelegate(msg.sender, delegate);
    }

    /// @dev Allows to remove a delegate.
    /// @param delegate Delegate that should be removed.
    /// @param removeAllowances Indicator if allowances should also be removed. This should be set to `true` unless this causes an out of gas, in this case the allowances should be "manually" deleted via `deleteAllowance`.
    function removeDelegate(address delegate, bool removeAllowances) public {
        Delegate memory current = delegates[msg.sender][delegate];
        // Delegate doesn't exists, nothing to do
        if(current.delegate == address(0)) return;
        if (removeAllowances) {
            address[] storage delegateTokens = tokens[msg.sender][delegate];
            for (uint256 i = 0; i < delegateTokens.length; i++) {
                address token = delegateTokens[i];
                // Set all allowance params except the nonce to 0
                Allowance memory allowance = getAllowance(msg.sender, delegate, token);
                allowance.amount = 0;
                allowance.spent = 0;
                allowance.resetTimeMin = 0;
                allowance.lastResetMin = 0;
                updateAllowance(msg.sender, delegate, token, allowance);
                emit DeleteAllowance(msg.sender, delegate, token);
            }
        }
        if (current.prev == address(0)) {
            delegatesStart[msg.sender] = current.next;
        } else {
            delegates[msg.sender][current.prev].next = current.next;
        }
        if (current.next != address(0)) {
            delegates[msg.sender][current.next].prev = current.prev;
        }
        delete delegates[msg.sender][delegate];
        emit RemoveDelegate(msg.sender, delegate);
    }

    function getDelegates(address safe, address start, uint8 pageSize) public view returns (address[] memory results, address next) {
        results = new address[](pageSize);
        uint8 i = 0;
        address initialIndex = (start != address(0)) ? start : delegatesStart[safe];
        Delegate memory current = delegates[safe][initialIndex];
        while(current.delegate != address(0) && i < pageSize) {
            results[i] = current.delegate;
            i++;
            current = delegates[safe][current.next];
        }
        next = current.delegate;
        // Set the length of the array the number that has been used.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            mstore(results, i)
        }
    }

    receive() external payable {  }

}
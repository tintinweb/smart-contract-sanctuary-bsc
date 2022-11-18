/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// File: contracts/Messages.sol



pragma solidity ^0.8.0;

/**
 * @title Messages
 */
contract Messages {
    
    struct InitializePDA{
        bytes account;
        uint256 toChain;
    }

    struct InitializeTokenAccount{
        bytes account;
        bytes tokenMint;
        uint256 toChain;
    }

    struct UpdateStreamToken {
        uint64 start_time;
        uint64 end_time;
        uint64 amount;
        uint256 toChain;
        bytes sender;
        bytes receiver;
        bytes token_mint;
        bytes data_account_address;
    }

    struct ProcessStreamToken {
        uint64 start_time;
        uint64 end_time;
        uint64 amount;
        uint256 toChain;
        bytes sender;
        bytes receiver;
        uint64 can_cancel;
        uint64 can_update;
        bytes token_mint;
    }

    struct ProcessWithdrawStreamToken {
        uint256 toChain;
        bytes withdrawer;
        bytes token_mint;
        bytes sender_address;
        bytes data_account_address;
    }

    struct PauseStreamToken {
        uint256 toChain;
        bytes sender;
        bytes token_mint;
        bytes reciever_address;
        bytes data_account_address;
    }

    struct CancelStreamToken {
        uint256 toChain;
        bytes sender;
        bytes token_mint;
        bytes reciever_address;
        bytes data_account_address;
    }

    struct ProcessDepositToken {
        uint64 amount;
        uint256 toChain;
        bytes depositor;
        bytes token_mint;
    }

    struct ProcessTransferToken {
        uint64 amount;
        uint256 toChain;
        bytes sender;
        bytes token_mint;
        bytes receiver;
    }

    struct ProcessWithdrawToken {
        uint64 amount;
        uint256 toChain;
        bytes withdrawer;
        bytes token_mint;
    }

}
// File: contracts/Encoder.sol


pragma solidity ^0.8.0;


contract Encoder is Messages {
    uint8 public constant TOKEN_STREAM = 2;
    uint8 public constant TOKEN_WITHDRAW_STREAM = 4;
    uint8 public constant DEPOSIT_TOKEN = 6;
    uint8 public constant PAUSE_TOKEN = 8;
    uint8 public constant WITHDRAW_TOKEN = 10;
    uint8 public constant INSTANT_TOKEN = 12;
    uint8 public constant TOKEN_STREAM_UPDATE = 14;
    uint8 public constant CANCEL_TOKEN = 16;
    uint8 public constant DIRECT_TRANSFER = 17;
    uint8 public constant INITIALIZE_PDA = 18;
    uint8 public constant INITIALIZE_TOKEN_ACCOUNT = 19;

    function encode_initialize_pda(Messages.InitializePDA memory initializePDA) public pure returns (bytes memory encoded){
        encoded = abi.encodePacked(
            INITIALIZE_PDA,
            initializePDA.account,
            initializePDA.toChain
        );
    }

    function encode_initialize_token_account(Messages.InitializeTokenAccount memory initializeTokenAccount) public pure returns (bytes memory encoded){
        encoded = abi.encodePacked(
            INITIALIZE_TOKEN_ACCOUNT,
            initializeTokenAccount.account,
            initializeTokenAccount.tokenMint,
            initializeTokenAccount.toChain
        );
    }

    function encode_token_stream(Messages.ProcessStreamToken memory processStream) public pure returns (bytes memory encoded){
        encoded = abi.encodePacked(
            TOKEN_STREAM,
            processStream.start_time,
            processStream.end_time,
            processStream.amount,
            processStream.toChain,
            processStream.sender,
            processStream.receiver,
            processStream.can_cancel,
            processStream.can_update,
            processStream.token_mint
        );
    }

    function encode_token_stream_update(Messages.UpdateStreamToken memory processStream) public pure returns (bytes memory encoded){
        encoded = abi.encodePacked(
            TOKEN_STREAM_UPDATE,
            processStream.start_time,
            processStream.end_time,
            processStream.amount,
            processStream.toChain,
            processStream.sender,
            processStream.receiver,
            processStream.token_mint,
            processStream.data_account_address
        );
    }

    function encode_token_withdraw_stream(Messages.ProcessWithdrawStreamToken memory processWithdrawStream) public pure returns (bytes memory encoded){
        encoded = abi.encodePacked(
            TOKEN_WITHDRAW_STREAM,
            processWithdrawStream.toChain,
            processWithdrawStream.withdrawer,
            processWithdrawStream.token_mint,
            processWithdrawStream.sender_address,
            processWithdrawStream.data_account_address
        );
    }

    function encode_process_deposit_token(Messages.ProcessDepositToken memory processDeposit) public pure returns (bytes memory encoded){
        encoded = abi.encodePacked(
            DEPOSIT_TOKEN,
            processDeposit.amount,
            processDeposit.toChain,
            processDeposit.depositor,
            processDeposit.token_mint
        );
    }

    function encode_process_pause_token_stream(Messages.PauseStreamToken memory pauseStream) public pure returns (bytes memory encoded){
        encoded = abi.encodePacked(
            PAUSE_TOKEN,
            pauseStream.toChain,
            pauseStream.sender,
            pauseStream.token_mint,
            pauseStream.reciever_address,
            pauseStream.data_account_address
        );
    }

    function encode_process_cancel_token_stream(Messages.CancelStreamToken memory cancelStream) public pure returns (bytes memory encoded){
        encoded = abi.encodePacked(
            CANCEL_TOKEN,
            cancelStream.toChain,
            cancelStream.sender,
            cancelStream.token_mint,
            cancelStream.reciever_address,
            cancelStream.data_account_address
        );
    }

    function encode_process_token_withdrawal(Messages.ProcessWithdrawToken memory processWithdraw) public pure returns (bytes memory encoded){
        encoded = abi.encodePacked(
            WITHDRAW_TOKEN,
            processWithdraw.amount,
            processWithdraw.toChain,
            processWithdraw.withdrawer,
            processWithdraw.token_mint
        );
    }

    function encode_process_instant_token_transfer(Messages.ProcessTransferToken memory processTransfer) public pure returns (bytes memory encoded){
        encoded = abi.encodePacked(
            INSTANT_TOKEN,
            processTransfer.amount,
            processTransfer.toChain,
            processTransfer.sender,
            processTransfer.token_mint,
            processTransfer.receiver
        );
    }

    function encode_process_direct_transfer(Messages.ProcessTransferToken memory processTransfer) public pure returns (bytes memory encoded){
        encoded = abi.encodePacked(
            DIRECT_TRANSFER,
            processTransfer.amount,
            processTransfer.toChain,
            processTransfer.sender,
            processTransfer.token_mint,
            processTransfer.receiver
        );
    }
}
// File: contracts/interfaces/IERC20.sol


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
// File: contracts/interfaces/IWETH.sol



pragma solidity ^0.8.0;


interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint amount) external;
}
// File: contracts/interfaces/Structs.sol



pragma solidity ^0.8.0;

interface Structs {
	struct Provider {
		uint16 chainId;
		uint16 governanceChainId;
		bytes32 governanceContract;
	}

	struct GuardianSet {
		address[] keys;
		uint32 expirationTime;
	}

	struct Signature {
		bytes32 r;
		bytes32 s;
		uint8 v;
		uint8 guardianIndex;
	}

	struct VM {
		uint8 version;
		uint32 timestamp;
		uint32 nonce;
		uint16 emitterChainId;
		bytes32 emitterAddress;
		uint64 sequence;
		uint8 consistencyLevel;
		bytes payload;

		uint32 guardianSetIndex;
		Signature[] signatures;

		bytes32 hash;
	}

	struct RegisterChain {
        // Governance Header
        // module: "NFTBridge" left-padded
        bytes32 module;
        // governance action: 1
        uint8 action;
        // governance paket chain id: this or 0
        uint16 chainId;

        // Chain ID
        uint16 emitterChainID;
        // Emitter address. Left-zero-padded if shorter than 32 bytes
        bytes32 emitterAddress;
    }
}
// File: contracts/interfaces/IWormhole.sol



pragma solidity ^0.8.0;


interface IWormhole is Structs {
    event LogMessagePublished(address indexed sender, uint64 sequence, bytes payload, uint8 consistencyLevel);

    function publishMessage(
        uint32 nonce,
        bytes memory payload,
        uint8 consistencyLevel
    ) external payable returns (uint64 sequence);

    function parseAndVerifyVM(bytes calldata encodedVM) external view returns (Structs.VM memory vm, bool valid, string memory reason);

    function verifyVM(Structs.VM memory vm) external view returns (bool valid, string memory reason);

    function verifySignatures(bytes32 hash, Structs.Signature[] memory signatures, Structs.GuardianSet memory guardianSet) external pure returns (bool valid, string memory reason) ;

    function parseVM(bytes memory encodedVM) external pure returns (Structs.VM memory vm);

    function getGuardianSet(uint32 index) external view returns (Structs.GuardianSet memory) ;

    function getCurrentGuardianSetIndex() external view returns (uint32) ;

    function getGuardianSetExpiry() external view returns (uint32) ;

    function governanceActionIsConsumed(bytes32 hash) external view returns (bool) ;

    function isInitialized(address impl) external view returns (bool) ;

    function chainId() external view returns (uint16) ;

    function governanceChainId() external view returns (uint16);

    function governanceContract() external view returns (bytes32);

    function messageFee() external view returns (uint256) ;
}
// File: contracts/Messenger.sol


pragma solidity ^0.8.0;





contract Messenger is Encoder {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    address public owner;
    uint8 public constant CONSISTENCY_LEVEL = 1; //15
    uint32 nonce = 0;

    IWormhole public _wormhole;
    IWETH public _weth;

    uint256 public _arbiter_fee;

    // SOLANA CHAIN ID AS SPECIFIED AS WORMHOLE CONTRACT (https://book.wormhole.com/reference/contracts.html)
    uint256 SOLANA_CHAIN_ID = 1;
    
    mapping(uint16 => bytes32) public _applicationContracts;

    event DepositToken(bytes depositor, bytes tokenMint, uint64 amount, uint32 nonce);
    event TokenStream(bytes sender, bytes receiver, bytes tokenMint, uint64 amount, uint32 nonce);
    event TokenStreamUpdate(bytes sender, bytes receiver, bytes tokenMint, uint64 amount, uint32 nonce);
    event WithdrawToken(bytes withdrawer, bytes tokenMint, uint32 nonce);
    event PauseTokenStream(bytes receiver, bytes tokenMint, uint32 nonce);
    event CancelTokenStream(bytes receiver, bytes tokenMint, uint32 nonce);
    event InstantTokenTransfer(bytes receiver, bytes tokenMint, uint64 amount, uint32 nonce);
    event TokenWithdrawal(bytes withdrawer, bytes tokenMint, uint64 amount, uint32 nonce);
    event DirectTransfer(bytes sender, bytes receiver, bytes tokenMint, uint64 amount, uint32 nonce);

    event PDAInitialize(bytes account, uint32 nonce);
    event TokenAccountInitialize(bytes account, bytes tokenMint, uint32 nonce);

    constructor(address wormholeAddress, address weth, uint256 arbiter_fee) {
        _wormhole = IWormhole(wormholeAddress); //0x706abc4E45D419950511e474C7B9Ed348A4a716c
        _weth = IWETH(weth); //0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
        owner = msg.sender;
        _arbiter_fee = arbiter_fee;
    }

    function initialize_pda(
        bytes memory account
    ) public payable {
        nonce++;
        bytes memory encoded_data = Encoder.encode_initialize_pda(
            Messages.InitializePDA({
                account: account,
                toChain: getChainId()
            })
        );
        _bridgeInstructionInWormhole(
            nonce,
            encoded_data,
            _arbiter_fee
        );
        emit PDAInitialize(account, nonce);
    }

    function initialize_token_account(
        bytes memory account,
        bytes memory token_mint
    ) public payable  {
        nonce++;
        bytes memory encoded_data = Encoder.encode_initialize_token_account(
            Messages.InitializeTokenAccount({
                account: account,
                tokenMint: token_mint,
                toChain: getChainId()
            })
        );
        _bridgeInstructionInWormhole(
            nonce,
            encoded_data,
            _arbiter_fee
        );   
        emit TokenAccountInitialize(account, token_mint, nonce); 
    }

    function process_deposit_token(
        uint64 amount, 
        bytes memory depositor,
        bytes memory token_mint
    ) public payable {
        nonce++;
        bytes memory encoded_data = Encoder.encode_process_deposit_token(
            Messages.ProcessDepositToken({
                amount: amount,
                toChain: getChainId(),
                depositor: depositor,
                token_mint: token_mint
            })
        );
         _bridgeInstructionInWormhole(
            nonce,
            encoded_data,
            _arbiter_fee
        );
        emit DepositToken(depositor, token_mint, amount, nonce);
    }

    function process_token_stream(
        uint64 start_time,
        uint64 end_time,
        uint64 amount,
        bytes memory receiver,
        bytes memory sender,
        uint64 can_cancel,
        uint64 can_update,
        bytes memory token_mint
    ) public payable  {
        nonce++;
        bytes memory encoded_data = Encoder.encode_token_stream(
            Messages.ProcessStreamToken({
                start_time: start_time,
                end_time: end_time,
                amount: amount,
                toChain: getChainId(),
                sender: sender,
                receiver: receiver,
                can_cancel: can_cancel,
                can_update: can_update,
                token_mint: token_mint
            })
        );
         _bridgeInstructionInWormhole(
            nonce,
            encoded_data,
            _arbiter_fee
        );
        emit TokenStream(sender, receiver, token_mint, amount, nonce);
    }

    function process_token_stream_update(
        uint64 start_time,
        uint64 end_time,
        uint64 amount,
        bytes memory receiver,
        bytes memory sender,
        bytes memory token_mint,
        bytes memory data_account_address
    ) public payable  {
        nonce++;
        bytes memory encoded_data = Encoder.encode_token_stream_update(
            Messages.UpdateStreamToken({
                start_time: start_time,
                end_time: end_time,
                amount: amount,
                toChain: getChainId(),
                sender: sender,
                receiver: receiver,
                token_mint: token_mint,
                data_account_address: data_account_address
            })
        );
         _bridgeInstructionInWormhole(
            nonce,
            encoded_data,
            _arbiter_fee
        );
        emit TokenStreamUpdate(sender, receiver, token_mint, amount, nonce);
    }

    function process_token_withdraw_stream(
        bytes memory withdrawer,
        bytes memory token_mint,
        bytes memory sender_address,
        bytes memory data_account_address
    ) public payable  {
        nonce++;
        bytes memory encoded_data = Encoder.encode_token_withdraw_stream(
            Messages.ProcessWithdrawStreamToken({
                toChain: getChainId(),
                withdrawer: withdrawer,
                token_mint: token_mint,
                sender_address: sender_address,
                data_account_address: data_account_address
            })
        );
         _bridgeInstructionInWormhole(
            nonce,
            encoded_data,
            _arbiter_fee
        );
        emit WithdrawToken(withdrawer, token_mint, nonce);
    }

   function process_pause_token_stream(
        bytes memory sender,
        bytes memory token_mint,
        bytes memory reciever_address,
        bytes memory data_account_address
    ) public payable  {
        nonce++;
        bytes memory encoded_data = Encoder.encode_process_pause_token_stream(
            Messages.PauseStreamToken({
                toChain: getChainId(),
                sender: sender,
                token_mint: token_mint,
                reciever_address: reciever_address,
                data_account_address: data_account_address
            })
        );
         _bridgeInstructionInWormhole(
            nonce,
            encoded_data,
            _arbiter_fee
        );
        emit PauseTokenStream(sender, token_mint, nonce);
    }

    function process_cancel_token_stream(
        bytes memory sender,
        bytes memory token_mint,
        bytes memory reciever_address,
        bytes memory data_account_address
    ) public payable  {
        nonce++;
        bytes memory encoded_data = Encoder.encode_process_cancel_token_stream(
            Messages.CancelStreamToken({
                toChain: getChainId(),
                sender: sender,
                token_mint: token_mint,
                reciever_address: reciever_address,
                data_account_address: data_account_address
            })
        );
         _bridgeInstructionInWormhole(
            nonce,
            encoded_data,
            _arbiter_fee
        );
        emit CancelTokenStream(sender, token_mint, nonce);
    }

    // sender will transfer to receiver
    function process_instant_token_transfer(
        uint64 amount, 
        bytes memory sender,
        bytes memory withdrawer,
        bytes memory token_mint
    ) public payable {
        nonce++;
        bytes memory encoded_data = Encoder.encode_process_instant_token_transfer(
            Messages.ProcessTransferToken({
                amount: amount,
                toChain: getChainId(),
                receiver: withdrawer,
                token_mint: token_mint,
                sender: sender
            })
        );
         _bridgeInstructionInWormhole(
            nonce,
            encoded_data,
            _arbiter_fee
        );
        emit InstantTokenTransfer(sender, token_mint, amount, nonce);
    }

    // sender will withdraw 
    function process_token_withdrawal(
        uint64 amount, 
        bytes memory sender,
        bytes memory token_mint
    ) public payable {
        nonce++;
        bytes memory encoded_data = Encoder.encode_process_token_withdrawal(
            Messages.ProcessWithdrawToken({
                amount: amount,
                toChain: getChainId(),
                withdrawer: sender,
                token_mint: token_mint
            })
        );
         _bridgeInstructionInWormhole(
            nonce,
            encoded_data,
            _arbiter_fee
        );
        emit TokenWithdrawal(sender, token_mint, amount, nonce);
    }

    function process_direct_transfer(
        uint64 amount, 
        bytes memory sender,
        bytes memory token_mint,
        bytes memory receiver
    ) public payable {
        nonce++;
        bytes memory encoded_data = Encoder.encode_process_direct_transfer(
            Messages.ProcessTransferToken({
                amount: amount,
                toChain: getChainId(),
                receiver: receiver,
                token_mint: token_mint,
                sender: sender
            })
        );
         _bridgeInstructionInWormhole(
            nonce,
            encoded_data,
            _arbiter_fee
        );
        emit DirectTransfer(sender, receiver, token_mint, amount, nonce);
    }

    function _bridgeInstructionInWormhole(uint32 nonceValue, bytes memory stream, uint256 arbiterFee) internal returns(uint64 sequence){

        uint256 wormholeFee = _wormhole.messageFee();

        require(wormholeFee < msg.value, "value is smaller than wormhole fee");

        uint256 amount = msg.value - wormholeFee;

        require(arbiterFee <= amount, "fee is bigger than amount minus wormhole fee");

        uint256 normalizedArbiterFee = normalizeAmount(arbiterFee, 18);

        // refund dust
        uint dust = amount - deNormalizeAmount(normalizedArbiterFee, 18);
        if (dust > 0) {
            payable(msg.sender).transfer(dust);
        }

        // deposit into WETH
        _weth.deposit{
            value : amount - dust
        }();

        sequence = _wormhole.publishMessage(nonceValue, stream, CONSISTENCY_LEVEL);
    }

    function normalizeAmount(uint256 amount, uint8 decimals) internal pure returns(uint256){
        if (decimals > 8) {
            amount /= 10 ** (decimals - 8);
        }
        return amount;
    }

    function deNormalizeAmount(uint256 amount, uint8 decimals) internal pure returns(uint256){
        if (decimals > 8) {
            amount *= 10 ** (decimals - 8);
        }
        return amount;
    }

    receive() external payable {}

    /**
        Registers it's sibling applications on other chains as the only ones that can send this instance messages
     */
    function registerApplicationContracts(
        uint16 chainId,
        bytes32 applicationAddr
    ) public {
        require(msg.sender == owner, "Only owner can register new chains!");
        _applicationContracts[chainId] = applicationAddr;
    }

    function getChainId() internal view returns (uint256) {
        return SOLANA_CHAIN_ID;
    }

    function changeSolanaWormholeId(uint256 _id) public {
        require(msg.sender == owner, "Only owner can change wormhole id for Solana!");
        SOLANA_CHAIN_ID = _id;
    }

    function changeAdmin(address _owner) public {
        require(msg.sender == owner, "Only owner can change admin!");
        owner = _owner;
    }

    function changeArbiterFee(uint256 fee) public {
        require(msg.sender == owner, "Only owner can change admin!");
        _arbiter_fee = fee;
    }

    function claimEthAmount() public {
        require(msg.sender == owner, "Only owner can withdraw funds!");
        uint256 _contractBalance = address(this).balance;
        require( _contractBalance > 0 , "No ETH accumulated");

        (bool _sent,) = owner.call{value: _contractBalance}("");
        require(_sent, "Failed to send Ether");
    }

    function claimWETHAmount(uint256 amount) public {
        require(msg.sender == owner, "Only owner can withdraw funds!");

        _weth.withdraw(amount);
        (bool _sent,) = owner.call{value: amount}("");
        require(_sent, "Failed to send Ether");
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./utils/Ownable.sol";

contract SIXBSCSwapOut is Ownable {
    // Public parameter for SIX Token hot wallet address
    address public sixHotWalletAddr;
    // To check allow dist chain for bridge
    mapping(uint256 => bool) public allowDistChain;
    // Public parameter for Bridge's fee in each Chain
    mapping(uint256 => uint256) public txFeeByDestChain;

    // Public parameter for Bridge's fee address
    address public feeAddr;

    // Public parameter for transfer limit on each time
    uint256 public amountLimitPerTrans;

    // Public parameter for SIX Token address
    IERC20 public SIXBSCToken;

    // Group of Mapping parameter use to support and interactive with SIX Bridge workflow process by use sourceTx(Bridge Ticket ID) to be the key index
    mapping(string => address) public sourceAddr; // To keep source address on each transaction (msg.Sender)
    mapping(string => string) public destAddr; // To keep destination address on each transaction
    mapping(string => string) public destMemoText; // To keep destination memo text on each transaction
    mapping(string => uint256) public swapAmount; // To keep transfer amount on each transaction
    mapping(string => uint256) public feeAmount; // To keep fee amount on each transaction
    mapping(string => string) public sourceTx; // To keep source Bridge Ticket ID on each transaction
    mapping(string => uint256) public destChain; // To keep our destination chain ID on each transaction and possible value are 1 = Stellar, 2 = Klaytn, 3 = BSC

    // Swap event thrown to contract event
    event Swap(
        address _from,
        string _to,
        string _memoText,
        uint256 _amount,
        uint256 _fee,
        string _sourceTx,
        uint256 _destChain
    );

    // SIXBSCSwapOut Constructor
    // There are 4 arguments that constructor need when deploy
    // 1.) SIX Hot Wallet's address on Binance Smart Chain
    // 2.) Bridge's Fee address on Binance Smart Chain
    // 3.) Amount limit that allow user transfer SIX Token on each time
    // 4.) SIX Token's address on Binance Smart Chain
    constructor(
        address _sixHotWallet,
        address _feeAddr,
        uint256 _amountLimitPerTrans,
        IERC20 _sixBSCToken
    ) {
        sixHotWalletAddr = _sixHotWallet;
        feeAddr = _feeAddr;
        amountLimitPerTrans = _amountLimitPerTrans;
        SIXBSCToken = _sixBSCToken;

        // Setup bridge transaction fee in each chain with key 1 = Stellar, 2 = Klaytn, 3 = BSC
        txFeeByDestChain[1] = 0;
        txFeeByDestChain[2] = 0;
        txFeeByDestChain[3] = 25000000000000000000; // For BSC destination address has transaction fee 25 SIX.

    }

    // public function allow only Owner to set bridge transaction fee by chain ID
    function setTxFeeByChain(uint256 _chainID, uint256 _txFee)
        public
        onlyOwner
    {
        txFeeByDestChain[_chainID] = _txFee;
    }

    // public function allow only Owner to set transaction fee address
    function setFeeAddr(address _feeAddr) public onlyOwner {
        feeAddr = _feeAddr;
    }

    // public function allow only Owner to set SIX Hot Wallet address
    function setSixHotWalletAddr(address _sixHotWallet) public onlyOwner {
        sixHotWalletAddr = _sixHotWallet;
    }

    // public function allow only owner use to set limitation bridge amount on each time
    function setAmountLimitPerTrans(uint256 _amountLimitPerTrans)
        public
        onlyOwner
    {
        amountLimitPerTrans = _amountLimitPerTrans;
    }

    // public function that return SIX Token balance in SIX Hot Wallet
    function sixHotWalletBalance() public view returns (uint256) {
        return SIXBSCToken.balanceOf(sixHotWalletAddr);
    }
    // _destChain == 1 || _destChain == 2, _destChain == 4
    function setAllowDistChain (uint256[] calldata chainIds,bool state) external onlyOwner{
        for(uint256 i = 0; i < chainIds.length ; i++){
            allowDistChain[chainIds[i]] = state;
        }
    }
    // The key function is swap use to transfer SIX Token from User's wallet to SIX Hot wallet address.
    // There are 6 arguments that need to use in swap function
    // 1.) _toAddr : Destination address on another network that user want to transfer to
    // 2.) _toMemo : Memo Text
    // 3.) _amount : Number of amount
    // 4.) _fee : Number of transaction fee
    // 5.) _sourceTx : Bridge Ticket ID to use for reference with over all process
    // 6.) _destChain : Destination chain of this transaction (possible value are 1 = Stellar, 2 = Klaytn)
    function swap(
        string memory _toAddr,
        string memory _toMemo,
        uint256 _amount,
        uint256 _fee,
        string memory _sourceTx,
        uint256 _destChain
    ) public payable returns (bool) {
        // To check duplicate of Bridge Ticket ID
        require(
            bytes(sourceTx[_sourceTx]).length <= 0,
            "Source transaction is already exists"
        );

        // To check destination address is require
        require(bytes(_toAddr).length > 0, "Destination address is require");

        // To check bridge amount is require and must more than 0
        require(_amount > 0, "Swap amount is require");

        // To check transaction fee is require and must more than or equal to 0
        require(_fee >= 0, "Swap fee is require");

        // To check Bridge Ticket ID is require
        require(
            bytes(_sourceTx).length > 0,
            "Source Transaction ID is require"
        );

        // To check destination chain of this transaction is require and possible value only be 1 or 2 (1 = Stellar, 2 = Klaytn)
        require(
            // _destChain == 1 || _destChain == 2,
            allowDistChain[_destChain],
            "Destination Chain is require"
        );

        // To validate transaction fee that send from caller is equal with our configuration
        require(
            _fee == txFeeByDestChain[_destChain],
            "Fee amount not match with swap contract"
        );

        // To check bridge amount must less than or equal limitation amount of each time
        require(
            _amount <= amountLimitPerTrans,
            "Amount has exceed maximum limit allow"
        );

        // Store transaction data into mapping with key sourceTx(Bridge Ticket ID)
        sourceAddr[_sourceTx] = msg.sender;
        destAddr[_sourceTx] = _toAddr;
        destMemoText[_sourceTx] = _toMemo;
        swapAmount[_sourceTx] = _amount;
        feeAmount[_sourceTx] = _fee;
        sourceTx[_sourceTx] = _sourceTx;
        destChain[_sourceTx] = _destChain;

        if (_fee != 0) {
            // Transfer swap fee to fee wallet address
            SIXBSCToken.transferFrom(msg.sender, feeAddr, _fee);
        }

        // Transfer SIX Token from sender's wallet to our hot wallet address
        SIXBSCToken.transferFrom(msg.sender, sixHotWalletAddr, _amount);

        // Emit Swap event
        emit Swap(
            msg.sender,
            _toAddr,
            _toMemo,
            _amount,
            _fee,
            _sourceTx,
            _destChain
        );

        return (true);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
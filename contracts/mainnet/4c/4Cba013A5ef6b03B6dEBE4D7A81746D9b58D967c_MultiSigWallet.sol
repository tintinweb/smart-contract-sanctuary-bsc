/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

pragma solidity ^0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender)
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

contract MultiSigWallet {
    address private owner;
    mapping(address => uint8) private managers;

    IBEP20 private bep20Contract;

    modifier isOwner() {
        require(owner == msg.sender, "error, operater must be owner!");
        _;
    }

    modifier isManager() {
        require(
            msg.sender == owner || managers[msg.sender] == 1,
            "error, operater must be owner or manager!"
        );
        _;
    }

    uint constant MIN_SIGNATURES = 4;
    uint private transactionIdx;

    struct Transaction {
        address from;
        address to;
        uint amount;
        uint8 signatureCount;
        mapping(address => uint8) signatures;
    }

    mapping(uint => Transaction) private transactions;
    uint[] private pendingTransactions;

    constructor() {
        owner = msg.sender;
    }

    event TransferFunds(address to, uint amount);
    event TransactionCreated(
        address from,
        address to,
        uint amount,
        uint transactionId
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function addManager(address manager) public isOwner {
        managers[manager] = 1;
    }

    function removeManager(address manager) public isOwner {
        managers[manager] = 0;
    }

    function setUsdtAddress(address usdtAddr) public isOwner {
        require(usdtAddr != address(0), "erro, invalid usdt address!");
        bep20Contract = IBEP20(usdtAddr);
    }

    function withdraw(uint amountWithoutDecimals) public isManager {
        require(
            address(bep20Contract) != address(0),
            "error, owner must initial usdt contract firstly!"
        );
        uint256 amount = amountWithoutDecimals * 10**bep20Contract.decimals();
        if (amount > bep20Contract.balanceOf(address(this))) {
            amount = bep20Contract.balanceOf(address(this));
        }

        require(
            amount > 0,
            "error, withdraw amount must be greater than zero!"
        );
        // 同时只能发起一笔提款请求
        require(
            pendingTransactions.length == 0,
            "error, only one request can be made at a time"
        );

        transferTo(msg.sender, amount);
    }

    function signTransaction() public isManager {
        //同时只能发起一笔请求，默认为唯一的transactionId
        require(pendingTransactions.length > 0, "error,no unSign transaction!");
        uint transactionId = pendingTransactions[0];

        Transaction storage transaction = transactions[transactionId];
        require(address(0) != transaction.from);
        require(msg.sender != transaction.from);
        require(
            transaction.signatures[msg.sender] != 1,
            "error, you have signed this transaction!"
        );
        transaction.signatures[msg.sender] = 1;
        transaction.signatureCount++;

        if (transaction.signatureCount >= MIN_SIGNATURES) {
            require(
                bep20Contract.balanceOf(address(this)) >= transaction.amount
            );
            bep20Contract.transfer(transaction.to, transaction.amount);
            emit TransferFunds(transaction.to, transaction.amount);
            deleteTransactions(transactionId);
        }
    }

    function reset() public isOwner {
        if (pendingTransactions.length > 0) {
            deleteTransactions(pendingTransactions[0]);
        }
    }

    function transferOwnership(address newOwner) public isOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function transferTo(address to, uint amount) private {
        require(bep20Contract.balanceOf(address(this)) >= amount);
        uint transactionId = transactionIdx++;

        Transaction storage transaction = transactions[transactionId];
        transaction.from = msg.sender;
        transaction.to = to;
        transaction.amount = amount;
        transaction.signatureCount = 0;
        pendingTransactions.push(transactionId);
        emit TransactionCreated(msg.sender, to, amount, transactionId);
    }

    function deleteTransactions(uint transacionId) private {
        uint8 replace = 0;
        for (uint i = 0; i < pendingTransactions.length; i++) {
            if (1 == replace) {
                pendingTransactions[i - 1] = pendingTransactions[i];
            } else if (transacionId == pendingTransactions[i]) {
                replace = 1;
            }
        }
        pendingTransactions.pop();
        delete transactions[transacionId];
    }
}
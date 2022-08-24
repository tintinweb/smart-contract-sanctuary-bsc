// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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

contract AccountSSBCapitalSample is  Ownable {
    uint256 public transId;

    address public globalAddress;
    Transaction[] public transactions;
    mapping(address => uint256) addressBalances;
    mapping(address => bool) isAdmin;
    address[] public tokenList;

    constructor() {
        globalAddress = owner();
    }

    function withdrawBalance() public {
        require(_msgSender() == owner() || isAdmin[_msgSender()] == true, "NOT_ADMIN");
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawToken(uint256 amount, IERC20 token) public {
        require(_msgSender() == owner() || isAdmin[_msgSender()] == true, "NOT_ADMIN");
        token.transfer(owner(), amount);
    }

    struct Transaction {
        uint256 id;
        address wallet;
        address token;
        uint256 amount;
        TransactionType transactionType;
        uint256 block;
    }

    enum TransactionType {NODE, DEPOSIT, WITHDRAW}

    function setGlobalAddress(address _globalAddress) external onlyOwner {
        globalAddress = _globalAddress;
    }

    function setIsAdmin(address wallet, bool status) external onlyOwner {
        isAdmin[wallet] = status;
    }

    function setTokenList(address[] memory _tokenList) external {
        require(_msgSender() == owner() || isAdmin[_msgSender()] == true, "NOT_ADMIN");
        tokenList = _tokenList;
    }

    event DepositToken(uint256 transId, address wallet, uint256 amount);
    event PayToken(uint256 transId, address wallet, uint256 amount);
    event PayEth(uint256 transId, address wallet, uint256 amount);

    function getTokenList() external view returns (address[] memory) {
        address[] memory result = new address[](tokenList.length);
        for (uint256 index = 0; index < tokenList.length; index++) {
            result[index] = tokenList[index];
        }
        return result;
    }

    function depositToken(uint256 amount, uint256 tokenIndex) external {
        require(tokenIndex < tokenList.length, "NOT_SUPPORT_TOKEN");
        IERC20 erc20Token = IERC20(tokenList[tokenIndex]);
        require(erc20Token.balanceOf(_msgSender()) >= amount, "NOT_ENOUGH_TOKEN_TO_DEPOSIT");
        erc20Token.transferFrom(_msgSender(), globalAddress, amount);
        transId += 1;
        Transaction memory transaction = Transaction(transId, _msgSender(), address(erc20Token), amount, TransactionType.DEPOSIT, block.number);
        transactions.push(transaction);
        addressBalances[_msgSender()] += amount;
        emit DepositToken(transId, _msgSender(), amount);
    }

    function depositEthBalance() external payable {
        uint256 amount = msg.value;
        payable(globalAddress).transfer(amount);

        transId += 1;
        Transaction memory transaction = Transaction(transId, _msgSender(), address(0), amount, TransactionType.DEPOSIT, block.number);
        transactions.push(transaction);
        addressBalances[_msgSender()] += amount;
        emit DepositToken(transId, _msgSender(), amount);
    }

    function paymentEth(address[] memory wallets, uint256[] memory amounts) external payable {
        require(wallets.length == amounts.length, "INPUT_PARAM_NOT_RIGHT");
        for (uint256 index = 0; index < wallets.length; index++) {
            address wallet = wallets[index];
            uint256 amount = amounts[index];

            payable(wallet).transfer(amount);

            transId += 1;
            Transaction memory transaction = Transaction(transId, _msgSender(), address(0), amount, TransactionType.WITHDRAW, block.number);
            transactions.push(transaction);
            addressBalances[_msgSender()] += amount;
            emit PayEth(transId, _msgSender(), amount);
        }
    }

    function paymentMultiTokens(address[] memory wallets, uint256[] memory amounts, address[] memory tokenAddresses) external {
        require(wallets.length == amounts.length && tokenAddresses.length == amounts.length, "INPUT_PARAM_NOT_RIGHT");
        for (uint256 index = 0; index < wallets.length; index++) {
            address wallet = wallets[index];
            uint256 amount = amounts[index];
            address tokenAddress = tokenAddresses[index];
            payToken(wallet, amount, tokenAddress);
        }
    }

    function payToken(address wallets, uint256 amount, address tokenAddress) public {
        require(_msgSender() == owner() || isAdmin[_msgSender()] == true, "NOT_ADMIN");
        IERC20(tokenAddress).transferFrom(_msgSender(), wallets, amount);
        transId += 1;
        Transaction memory transaction = Transaction(transId, _msgSender(), tokenAddress, amount, TransactionType.WITHDRAW, block.number);
        transactions.push(transaction);
        addressBalances[_msgSender()] += amount;
        emit PayToken(transId, _msgSender(), amount);
    }

    function getTransactions(uint256 fromIndex, uint256 toIndex)
    public
    view
    returns (Transaction[] memory)
    {
        uint256 length = getTotalTransaction();
        Transaction[] memory emptyResponse = new Transaction[](0);
        if (length == 0) return emptyResponse;
        if (fromIndex >= length) return emptyResponse;

        uint256 normalizedToIndex = toIndex < length ? toIndex : length - 1;
        if (fromIndex > normalizedToIndex) return emptyResponse;

        Transaction[] memory result = new Transaction[](
            normalizedToIndex - fromIndex + 1
        );

        for (uint256 index = fromIndex; index <= normalizedToIndex; index++) {
            result[index - fromIndex] = transactions[index];
        }
        return result;
    }

    function getTotalTransaction() public view returns (uint256) {
        return transactions.length;
    }

}
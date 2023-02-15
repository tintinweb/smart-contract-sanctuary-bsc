/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// File: @openzeppelin/contracts/utils/Context.sol

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

// File: contracts/IERC20.sol



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
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

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

// File: contracts/TroyEmpire.sol


pragma solidity ^0.8.0;


contract TroyEmpire is Ownable {
    bool private SYNC_ALLOWED = true;
    bool private WITHDRAW_ALLOWED = true;
    bool private CONTRACT_ALLOWED = true;
    IERC20 private TOKEN;

    mapping (address => Authorization) authorizations;

    event ActionAuthorized(address indexed account, uint256 namespace, uint256 actionType, bytes32 data);

    struct Authorization{
        address _address;
        uint256 _namespace;
        uint256 _actionType;
        bytes32 _data;
    }

    event Synced(address indexed sender, uint256 indexed _amount, uint256 fromType, uint256 indexed toType);
    event TokenChanged(address indexed _oldToken, address indexed _newToken, address indexed _actor);
    event SyncChanged(uint256 _action, address indexed _actor);
    event WithdrawalChanged(uint256 _action, address indexed _actor);
    event ContractAllowedChanged(uint256 _action, address indexed _actor);
    event TokensSent(address indexed _to, uint256 _amount, address indexed _actor);
    event CoinsSent(address indexed _to, uint256 _amount, address indexed _actor);
    event ContractBought(address indexed _to, uint256 indexed _type, uint256 _amount);
    event WithdrawalRequested(address indexed _by, uint256 indexed _type, uint256 _amount);
    event Deposited(address indexed _by, uint256 _amount);
    event DepositedTokens(address indexed _by, uint256 _amount, address indexed _token);

    constructor (address _tokenAddr) payable{
        TOKEN = IERC20(_tokenAddr);
    }

    function getToken() external view returns(address){
        return address(TOKEN);
    }

    function setToken(address _tokenAddr) external onlyOwner(){
        address old = address(TOKEN);
        TOKEN = IERC20(_tokenAddr);
        emit TokenChanged(old, _tokenAddr, _msgSender());
    }

    function withdrawTokens(uint256 _amount, address _address) external onlyOwner(){
        IERC20 tokenContract = IERC20(_address);
        tokenContract.transfer(owner(), _amount);
    }

    function disableSync() external onlyOwner{
        SYNC_ALLOWED = false;
        emit SyncChanged(0, _msgSender());
    }

    function enableSync() external onlyOwner{
        SYNC_ALLOWED = true;
        emit SyncChanged(1, _msgSender());
    }

    function getSync() external view returns (bool){
        return SYNC_ALLOWED;
    }

    function disableContract() external onlyOwner{
        CONTRACT_ALLOWED = false;
        emit ContractAllowedChanged(0, _msgSender());
    }

    function enableContract() external onlyOwner{
        CONTRACT_ALLOWED = true;
        emit ContractAllowedChanged(1, _msgSender());
    }

    function getContractAllowed() external view returns (bool){
        return CONTRACT_ALLOWED;
    }

    function disableWithdrawal() external onlyOwner{
        WITHDRAW_ALLOWED = false;
        emit WithdrawalChanged(0, _msgSender());
    }

    function enableWithdrawal() external onlyOwner{
        WITHDRAW_ALLOWED = true;
        emit WithdrawalChanged(1, _msgSender());
    }

    function getWithdrawal() external view returns (bool){
        return WITHDRAW_ALLOWED;
    }

    function clean(uint256 _amount) external onlyOwner(){
        require(address(this).balance > _amount, "Invalid digits");

        payable(owner()).transfer(_amount);
    }

    function sync(uint256 _fromType, uint256 _toType, uint256 _amount) external payable{
        require(SYNC_ALLOWED, "TroyEmpire: Sync is disabled for now");

        emit Synced(_msgSender(), _amount, _fromType, _toType);
    }

    function deposit() external payable{
        emit Deposited(_msgSender(), msg.value);
    }

    function buyContract(uint256 _type, uint256 _amount) external {
        require(CONTRACT_ALLOWED, "TroyEmpire: Buying a contract is disabled for now");
        emit ContractBought(_msgSender(), _type, _amount);
    }

    function depositToken(uint256 _amount) external payable{
        require(TOKEN.allowance(_msgSender(), address(this)) >= _amount,"TroyEmpire: You need to allow transferring token");
        TOKEN.transferFrom(_msgSender(), address(this), _amount);
        emit DepositedTokens(_msgSender(), msg.value, address(TOKEN));
    }

    function sendToken(address payable _to, uint256 _amount) external onlyOwner(){
        require(WITHDRAW_ALLOWED, "TroyEmpire: Withdrawal is disabled for now");

        require(address(TOKEN).balance >= _amount, "TroyEmpire: invalid digits");

        TOKEN.transfer(_to, _amount);

        emit TokensSent(_to, _amount, _msgSender());
    }

    function sendCoin(address payable _to, uint256 _amount) external onlyOwner(){
        require(WITHDRAW_ALLOWED, "TroyEmpire: Withdrawal is disabled for now");

        require(address(this).balance >= _amount, "TroyEmpire: invalid digits");

        _to.transfer(_amount);

        emit CoinsSent(_to, _amount, _msgSender());
    }

    function requestWithdraw(uint256 _type, uint256 _amount) external {
        require(WITHDRAW_ALLOWED, "TroyEmpire: Withdrawal is disabled for now");
        emit WithdrawalRequested(_msgSender(), _type, _amount);
    }

    function authorizeAction(uint256 _namespace, uint256 _actionType, bytes32 _data) external {
        authorizations[_msgSender()] = Authorization(_msgSender(), _namespace, _actionType, _data);
        emit ActionAuthorized(_msgSender(), _namespace, _actionType, _data);
    }

    function getAuthorizations(address _of) public view returns(Authorization memory) {
        return authorizations[_of];
    }

}
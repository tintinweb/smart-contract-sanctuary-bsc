/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

interface IERC20 {
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

contract BEP20PayToken is Ownable{
    address private _usdtAddress;
    address private _saleAddress;
    address private _receiveAddress;

    uint _buyAmount;
    uint _saleAmount;
    mapping(address => uint256) public buyUsers;

    mapping(address => address) public _inviters; 
    mapping(address => address[]) public _lowerUsers; 

    struct BuyLog { 
        uint rTime;
        uint rAmount;
        uint rValue;
    }

    struct RewardLog { 
        uint rTime;
        uint rValue;
        address rUser;
    }

    mapping(address => BuyLog[]) private _buyLogs;
    mapping(address => RewardLog[]) private _rewardLogs;
    uint private _pageSize = 10; 

    constructor() {
        _usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
        _saleAddress = address(0x7b2ADE33784369A2D73181eE9B7212aA02BD3682);
        _receiveAddress = address(0xD6Bc06ad4d4a7b0B9c2583e5444945cD8021099b);
        _buyAmount = 100 * 10**18;
        _saleAmount = 100 * 10000 * 10**18;
    }

    function Buy() external returns(bool){

        address sender = _msgSender();

        require(buyUsers[sender] == 0, "You can't buy again");

        require(IERC20(_usdtAddress).balanceOf(sender) >= _buyAmount, "Insufficient balance");

        IERC20(_usdtAddress).transferFrom(sender, _receiveAddress, _buyAmount);

        buyUsers[sender] = _buyAmount;

        IERC20(_saleAddress).transfer(sender, _saleAmount);
        
        _addBuyLog(_buyAmount, _saleAmount);

        return true;
    }

    function setSaleAddress(address token) external onlyOwner{
        _saleAddress = token;
    }

    function setBuyAmount(uint amount) external onlyOwner{
        _buyAmount = amount;
    }

    function setSaleAmount(uint amount) external onlyOwner{
        _saleAmount = amount;
    }

    function setInviter(address account) external returns (bool){
        require(msg.sender != address(0), "cannot be set inviter to zero address");
        require(_inviters[msg.sender] == address(0), "Accout is owned inviter");
        require(msg.sender != account, "Accout can't be self"); //A = A
        //A => B,B => A 
        bool _find = false;
        for(uint i = 0; i < _lowerUsers[msg.sender].length; i++) {
            if(_lowerUsers[msg.sender][i] == account){          
                _find = true;
                break;
            }
        }
        require( _find == false, "Account can't be each other");

        _inviters[msg.sender] = account;

        _lowerUsers[account].push(msg.sender);

        if ( _lowerUsers[account].length % 10 == 0){
            IERC20(_saleAddress).transferFrom(address(this), msg.sender, _saleAmount);
            _addRewardLog(_saleAmount, account);
        }

        return true;
    }   

    function getInviters(address user) public view returns (address){
        return _inviters[user];
    }
    
    function setReceiveAddress(address account)  external onlyOwner{
         _receiveAddress = account;
    }

    function withDrawalToken(address _token, address _address, uint amount) external onlyOwner returns(bool){

        IERC20(_token).transfer(_address, amount);

        return true;
    }

    function _addBuyLog(uint _amount, uint _value) internal{        
        _buyLogs[msg.sender].push(BuyLog(block.timestamp, _amount, _value));
    }

    function getBuyLogs(uint page) public view returns (BuyLog[] memory) {
        if(page * _pageSize >= _buyLogs[msg.sender].length){
            return new BuyLog[](0);
        }
        uint _start = page * _pageSize;
        uint _end = (page+1) * _pageSize;
        if(_buyLogs[msg.sender].length < _end){
            _end = _buyLogs[msg.sender].length;
        }
        uint _len = _end -_start;
        BuyLog[] memory _logs = new BuyLog[](uint256(_len));
        for(uint i = _start; i < _end; i++) {
            _logs[i- _start] = _buyLogs[msg.sender][_buyLogs[msg.sender].length - i - 1];
        }

        return _logs;
    }   

    function _addRewardLog(uint _value, address _user) internal {
        _rewardLogs[_user].push(RewardLog(block.timestamp, _value, msg.sender));
    }

    function getRewardLogs(uint page) public view returns (RewardLog[] memory) {
        if(page * _pageSize >= _rewardLogs[msg.sender].length){
            return new RewardLog[](0);
        }
        uint _start = page * _pageSize;
        uint _end = (page+1) * _pageSize;
        if(_rewardLogs[msg.sender].length < _end){
            _end = _rewardLogs[msg.sender].length;
        }
        uint _len = _end -_start;
        RewardLog[] memory _logs = new RewardLog[](uint256(_len));
        for(uint i = _start; i < _end; i++) {
            _logs[i- _start] = _rewardLogs[msg.sender][_rewardLogs[msg.sender].length - i - 1];
        }

        return _logs;
    }             
}
/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract WhiteList is Ownable {
    mapping (address => bool) public isWhiteListed;
    function addWhiteList (address whiteUser) public onlyOwner {
        isWhiteListed[whiteUser] = true;
        emit AddedWhiteList(whiteUser);
    }
    function removeWhiteList (address _clearedUser) public onlyOwner {
        isWhiteListed[_clearedUser] = false;
        emit RemovedWhiteList(_clearedUser);
    }
    function addMultipleAccountsToWhiteList(address[] calldata accounts) public onlyOwner {
		uint8 len = uint8(accounts.length);
        for(uint8 i = 0; i < len;) {
            isWhiteListed[accounts[i]] = true;
			unchecked{++i;}
        }
    }
    event AddedWhiteList(address _user);
    event RemovedWhiteList(address _user);
}

contract PreSale is WhiteList {
    mapping (address => uint) public balanceOfToken; // 用户可以领取的数量
    uint256 public t_total;  //一共需要派发的Token数量
    uint256 public a_total;  //一共已经派发的Token数量


    mapping (address => uint) public balanceOfUSDT; // 用户充值的usdt
    uint256 public b_totalSupply;  //一共收到的usdt

    IERC20 USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 public token; //通证的地址

    uint256 public startTime;  //预售开始时间
    uint256 public endTime;  //预售结束时间
    uint256 public claimStartTime;  //领取通证时间

    bool public useWhiteList = false; //是否启用白名单
    uint256 public totalUsers; //总参与人数

    uint256 public rate; //预售比例
    uint256 public invrate = 5; //邀请百分比
    uint256 public minimumAmount = 10 ** 16; //最小bnb

    struct Record {
        uint256 timestamp;
        address next;
        uint256 amount;
    }

    mapping (address => address) public inviters;
    mapping (address => Record[]) public userinvs;

    event Deposit(address indexed sender, uint amount);
    event Claim(address indexed claimer, uint amount);

    constructor(
        address _token, 
        uint256 _startTime,
        uint256 _endTime,
        uint256 _claimStartTime,
        uint256 _rate
    ) {
        token = IERC20(_token);
        startTime = _startTime;
        endTime = _endTime;
        claimStartTime = _claimStartTime;
        rate = _rate;
    }

    function deposit(uint256 usdtAmount) public checkStart checkEnd checkWhiteList {
        require(usdtAmount >= minimumAmount,"minimum amount");

        USDT.transferFrom(msg.sender, address(this), usdtAmount);

        balanceOfUSDT[msg.sender] += usdtAmount;
        b_totalSupply += usdtAmount;

        uint tokenAmout = usdtAmount * rate;

        balanceOfToken[msg.sender] += tokenAmout;
        t_total += tokenAmout;
        unchecked {
            ++totalUsers;
        }
        emit Deposit(msg.sender, usdtAmount);
    }

    function deposit(uint256 usdtAmount, address inviter) public checkStart checkEnd checkWhiteList {
        require(usdtAmount >= minimumAmount,"minimum amount");

        USDT.transferFrom(msg.sender, address(this), usdtAmount);

        balanceOfUSDT[msg.sender] += usdtAmount;
        b_totalSupply += usdtAmount;
        
        inviters[msg.sender] = inviter;
        USDT.transfer(inviter, usdtAmount * invrate / 100); 


        Record[] storage thecords = userinvs[inviter];
        thecords.push(Record(block.timestamp, msg.sender, usdtAmount));

        uint tokenAmout = usdtAmount * rate;
        balanceOfToken[msg.sender] += tokenAmout;
        t_total += tokenAmout;

        unchecked {
            ++totalUsers;
        }
        emit Deposit(msg.sender, usdtAmount);
    }

    function claim() public checkStart {
        require(block.timestamp > claimStartTime,"claim not start");

        uint amount = balanceOfToken[msg.sender];
        require(amount > 0,"no token to claim");

        token.transfer(msg.sender, amount); 
        balanceOfToken[msg.sender] = 0;
        a_total += amount;

        emit Claim(msg.sender, amount);
    }

    modifier checkStart(){
        require(block.timestamp > startTime,"not start");
        _;
    }

    modifier checkEnd(){
        require(block.timestamp < endTime,"in ending");
        _;
    }

    modifier checkWhiteList(){
        if(useWhiteList){
            require(isWhiteListed[msg.sender], 'WhiteList');
        }
        _;
    }

    function setStartTime(uint _startTime) external onlyOwner() { startTime = _startTime; }
    function setEndTime(uint _endTime) external onlyOwner() { endTime = _endTime; }
    function setClaimTime(uint _claimTime) external onlyOwner() { claimStartTime = _claimTime; }
    function setRate(uint _rate) external onlyOwner() { rate = _rate; }
    function setMinimumUSDT(uint _minimumAmount) external onlyOwner() { minimumAmount = _minimumAmount; }
    function setInvrate(uint _invrate) external onlyOwner() { invrate = _invrate; }
    function setUseWhiteList(bool _useWhiteList) external onlyOwner() { useWhiteList = _useWhiteList; }
    function withdrawUSDT(uint _amount) external onlyOwner() {
        USDT.transfer(msg.sender, _amount); 
    }
    function withdrawToken(uint _amount) external onlyOwner() {
        token.transfer(msg.sender, _amount); 
    }

    function usdtBalance() external view returns (uint256) {
        return USDT.balanceOf(address(this));
    }

    function getRecords(address user) view external returns (Record[] memory) {
        return userinvs[user];
    }

}
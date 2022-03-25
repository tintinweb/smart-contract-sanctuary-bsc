/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-08
 */

/**
 *Submitted for verification at BscScan.com on 2022-03-02
 */

/**
 *Submitted for verification at BscScan.com on 2022-02-21
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1;

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

contract CORKPresale {
    string public name = "CORK PreSale";
    address public owner;
    uint256 profileId;

    address public accountBUSD;
    address public accountCORK;

    IERC20 public busdToken;
    IERC20 public corkToken;

    uint256 public totalBUSD;

    uint256 public rate;

    bool public isPause;

    bool public isLocked;

    struct UserInfo {
        address user;
        uint256 total; // How many tokens BUSD the user has transfer.
        address[] refs;
        bool isLocked;
        uint256 withdraw;
    }

    mapping(address => UserInfo) public userInfo;

    mapping(address => mapping(address => bool)) public objRefs;

    address[] public stakers;

    event Deposit(address by, uint256 amount);
    event Withdraw(address by, uint256 amount);

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the owner of the token farm can call this function"
        );
        _;
    }

    constructor(IERC20 _busdToken, address _accountBUSD, IERC20 _corkToken, address _accountCORK) {
        //in order to use them in other functions
        busdToken = _busdToken;
        corkToken = _corkToken;

        owner = msg.sender;
        accountBUSD = _accountBUSD;
        accountCORK = _accountCORK;

        isPause = false;
        totalBUSD = 0;
        profileId = 0;
        rate = 41;
        isLocked = true;

    }

    // Update status package
    function setPause(bool _isPause) public onlyOwner {
        isPause = _isPause;
    }

    // Update lock package
    function setLock(bool _isLocked) public onlyOwner {
        isLocked = _isLocked;
    }

    function lockUser(address _user) public onlyOwner {
        userInfo[_user].isLocked = true;
    }

    function setbusdToken(IERC20 _busdToken) public onlyOwner {
        busdToken = _busdToken;
    }

    function setcorkToken(IERC20 _corkToken) public onlyOwner {
        corkToken = _corkToken;
    }

    function setaccountBUSD(address _accountBUSD) public onlyOwner {
        accountBUSD = _accountBUSD;
    }

    function setaccountCORK(address _accountCORK) public onlyOwner {
        accountCORK = _accountCORK;
    }

    function getStakers(uint256 from, uint256 to) public view returns (address[] memory){
        require(to > from, "Not Accepted");
        uint256 _to = to;
        address[] memory newArr ;
        //= new address[](_to - from);
        if(_to > profileId){
            _to = profileId;
        }

        for(uint i = 0; i <= profileId; i++){
            newArr[i] =stakers[i];
        }

        return newArr;
    }


    function getDataByAddress(address _user) public view returns (
        address user,
        uint256 total, // How many tokens BUSD the user has transfer.
        address[] memory refs,
        bool locked,
        uint256 totalWithdraw
    ) {
            user= userInfo[_user].user;
            total= userInfo[_user].total;
            locked= userInfo[_user].isLocked;
            totalWithdraw= userInfo[_user].withdraw;
            refs=userInfo[_user].refs;
    }

    function getUserInfo(uint256 from, uint256 to) public view returns (UserInfo[] memory) {
        require(to > from, "Not Accepted");
        uint256 _to = to;
        UserInfo[] memory newArr ;
        //= new address[](_to - from);
        if(_to > profileId){
            _to = profileId;
        }

        for(uint i = 0; i <= profileId; i++){
            newArr[i] = userInfo[stakers[i]];
        }

        return newArr;
    }

    function getLimit() public pure returns (uint256) {
        return 1000 * (10**18);
    }

    function getTotalSupply() public pure returns (uint256) {
        return 150000000000 * (10**18);
    }

    function getRemainSupply(uint256 amount) public view returns (uint256) {
        return getTotalSupply() - (amount * rate / 100);
    }

    function deposit(uint256 _amount, address ref) public payable {
        // Validate amount
        require(_amount > 0, "Amount cannot be 0");
        require(!isPause, "Event end");
        require(_amount <= getLimit(), "Exceed Limit");
        require(getRemainSupply(_amount) > 0, "Exceed Limit");

        if(userInfo[msg.sender].total == 0){
            stakers.push(msg.sender);
        }

        userInfo[msg.sender].user = msg.sender;
        userInfo[msg.sender].total = _amount;
        userInfo[msg.sender].isLocked = false;

        if(!objRefs[msg.sender][ref] && ref != address(0)){
            userInfo[msg.sender].refs.push(ref); 
        }
        profileId++;

        // Transfer token
        busdToken.transferFrom(msg.sender, accountBUSD, _amount);

        // Update total staking
        totalBUSD += _amount;

        emit Deposit(msg.sender, _amount);
    }

    function withdraw() public {
        // Validate amount
        require(!isLocked && !userInfo[msg.sender].isLocked, "Not time to withdraw");
        require((userInfo[msg.sender].total > userInfo[msg.sender].withdraw), "Exceed limit");

        uint256 _amount = (userInfo[msg.sender].total - userInfo[msg.sender].withdraw) * rate / 100;
        // Transfer token
        corkToken.transferFrom(accountCORK, msg.sender, _amount);

        // Update total staking
        userInfo[msg.sender].withdraw = userInfo[msg.sender].total;

        emit Withdraw(msg.sender, _amount);
    }
}
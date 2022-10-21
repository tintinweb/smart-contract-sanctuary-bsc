/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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

interface IDao7Bet{

    function getTopic(address key) external view returns(
        bool inserted,
        bool enabled
    );

    function getTopicIndexOfKey(address key) external view returns (uint256);

    function getTopicKeyAtIndex(uint256 index) external view returns (address);

    function TopicsLength() external view returns (uint256);

    function getToken(address key) external view returns (
        bool inserted,
        string memory name,
        uint256 minAmount,
        uint256 singleAmount,
        uint256 fee,
        uint256 sort,
        bool enabled
    );

    function getTokenIndexOfKey(address key) external view returns (uint256);

    function getTokenKeyAtIndex(uint256 index) external view returns (address);

    function tokensLength() external view returns (uint256);

}

contract Ownable {
    address public owner;
    mapping(address => bool) private admins;

    event owneresshipTransferred(address indexed previousowneres, address indexed newowneres);
    event adminshipTransferred(address indexed previousowneres, address indexed newowneres);

    modifier onlyowneres() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyadmin() {
        require(admins[msg.sender]);
        _;
    }

    function transferowneresship(address newowneres) public onlyowneres {
        require(newowneres != address(0));
        emit owneresshipTransferred(owner, newowneres);
        owner = newowneres;
    }

    function renounceowneresship() public onlyowneres {
        emit owneresshipTransferred(owner, address(0));
        owner = address(0);
    }

    function setAdmins(address[] memory addrs,bool flag) public onlyowneres{
		for (uint256 i = 0; i < addrs.length; i++) {
            admins[addrs[i]] = flag;
		}
    }
}

contract Dao7Users is Ownable {
    // version
    uint public version=1;

    // main contract
    IDao7Bet mainContract;

    constructor(address _mainContract) {
        owner = msg.sender;
        mainContract = IDao7Bet(_mainContract);
    }

    struct Map {
        address[] keys;
        mapping(address => uint256) indexOf;// index or Invitation Code
        mapping(address => bool) inserted;
        mapping(address => bool) validReferral;// The invitation is valid for 72 hours, after which the transaction becomes false
        mapping(address => address) inviter;
        mapping(address => uint256) registerTime;// Record the block number at the time of registration
        mapping(address => address[]) lowerUsers;// Users at a lower level
    }
    Map private usersMap;

    function get(address key)
    public 
    view 
    returns (
        bool inserted,
        uint256 indexOf,
        bool validReferral,
        address inviter,
        uint256 registerTime
    )
    {
        inserted = usersMap.inserted[key];
        indexOf = usersMap.indexOf[key];
        validReferral = usersMap.validReferral[key];
        inviter = usersMap.inviter[key];
        registerTime = usersMap.registerTime[key];
    }

    function getIndexOfKey(address key)
    public
    view
    returns (int256)
    {
        if (!usersMap.inserted[key]) {
            return -1;
        }
        return int256(usersMap.indexOf[key]);
    }

    function getKeyAtIndex(uint256 index)
    public
    view
    returns (address)
    {
        return usersMap.keys[index];
    }

    function size() public view returns (uint256) {
        return usersMap.keys.length;
    }

    function set(
        address key,
        bool validReferral,
        address inviter,
        uint256 registerTime
    ) public onlyadmin {
        if (usersMap.inserted[key]) {
            usersMap.validReferral[key] = validReferral;
            usersMap.inviter[key] = inviter;
            usersMap.registerTime[key] = registerTime;
        } else {
            usersMap.inserted[key] = true;
            usersMap.validReferral[key] = validReferral;
            usersMap.inviter[key] = inviter;
            usersMap.registerTime[key] = registerTime;
            usersMap.indexOf[key] = usersMap.keys.length;
            usersMap.keys.push(key);
        }
    }

    function setLowerUsers(
        address key,
        address[] memory lowerUsers
    ) public onlyadmin {
        require(usersMap.inserted[key],"no register");
        for (uint256 i = 0; i < lowerUsers.length; i++) {
            bool userExist =  false;
            for (uint256 j=0; j < usersMap.lowerUsers[key].length; i++){
                if(usersMap.lowerUsers[key][j] == lowerUsers[i]){
                    userExist=true;
                    break;
                }
            }
            if(userExist){
                continue;
            }
            usersMap.lowerUsers[key].push(lowerUsers[i]);
		}
    }

    function removeLowerUser(address key,address lowerUser) public onlyadmin{
        require(usersMap.inserted[key],"no register");
        uint256 lowerUserIndex=0;
        for (uint256 i=0; i < usersMap.lowerUsers[key].length; i++){
            if(usersMap.lowerUsers[key][i] == lowerUser){
                lowerUserIndex=i;
                break;
            }
        }
        require(lowerUserIndex >= 0 && lowerUserIndex < usersMap.lowerUsers[key].length, "index out of range");
        
        if(lowerUserIndex == usersMap.lowerUsers[key].length - 1){
            usersMap.lowerUsers[key].pop();
        }else{
            address lastElement = usersMap.lowerUsers[key][usersMap.lowerUsers[key].length - 1];
            usersMap.lowerUsers[key][lowerUserIndex] =  lastElement;
            usersMap.lowerUsers[key].pop();
        }
    }

    function getLowerUsers(address key) 
    public 
    view 
    returns (
        address[] memory
    )
    {
        return usersMap.lowerUsers[key];
    }

    function register(uint256 inviteCode) public {

        registerUser(msg.sender, inviteCode);

    }

    function registerOfBet(address key,uint256 inviteCode) public{

        (bool tokenInserted,,,,,,) = mainContract.getToken(msg.sender);
        require(tokenInserted,"Illegal sources");

        registerUser(key, inviteCode);

    }

    function registerUser(address key,uint256 inviteCode) private{

        require(!usersMap.inserted[key],"already registered");

        address inviteAddr = usersMap.keys[inviteCode];

        usersMap.inserted[key] = true;
        usersMap.validReferral[key] = false;
        usersMap.inviter[key] = inviteAddr;
        usersMap.registerTime[key] = block.number;
        usersMap.indexOf[key] = usersMap.keys.length;
        usersMap.keys.push(key);
        if(inviteCode>0){
            usersMap.lowerUsers[inviteAddr].push(key);
        }
    }

    function setMainAddress(address _newAddress) public onlyadmin{
        mainContract = IDao7Bet(_newAddress);
    }

    function withdraw(address target,uint amount) public onlyowneres {
        payable(target).transfer(amount);
    }
    

    function withdrawToken(address token,address target, uint amount) public onlyowneres {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}
}
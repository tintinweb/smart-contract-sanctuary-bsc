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


contract Dao7Bet is Ownable {
    // version
    uint public version=1;

    constructor() {
		owner = msg.sender;
    }

    // start topics
    struct TopicsMap {
        address[] keys;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
        mapping(address => bool) enabled;
    }

    TopicsMap private topsMap;

    function getTopic(address key) 
    public 
    view 
    returns (
        bool inserted,
        bool enabled
    )
    {
        inserted = topsMap.inserted[key];
        enabled = topsMap.enabled[key];
    }

    function getTopicIndexOfKey(address key)
    public
    view
    returns (int256)
    {
        if (!topsMap.inserted[key]) {
            return -1;
        }
        return int256(topsMap.indexOf[key]);
    }

    function getTopicKeyAtIndex(uint256 index)
    public
    view
    returns (address)
    {
        return topsMap.keys[index];
    }

    function TopicsLength() public view returns (uint256) {
        return topsMap.keys.length;
    }

    function setTopic(
        address key,
        bool enabled
    ) public onlyadmin{
        if (topsMap.inserted[key]) {
            topsMap.enabled[key] = enabled;
        } else {
            topsMap.inserted[key] = true;
            topsMap.enabled[key] = enabled;
            topsMap.indexOf[key] = topsMap.keys.length;
            topsMap.keys.push(key);
        }
    }

    function removeTopic(address key) public onlyadmin{
        if (!topsMap.inserted[key]) {
            return;
        }

        delete topsMap.inserted[key];
        delete topsMap.enabled[key];
        uint256 index = topsMap.indexOf[key];
        uint256 lastIndex = topsMap.keys.length - 1;
        address lastKey = topsMap.keys[lastIndex];

        topsMap.indexOf[lastKey] = index;
        delete topsMap.indexOf[key];

        topsMap.keys[index] = lastKey;
        topsMap.keys.pop();
    }

    // end topics

    // start tokens CRUD

    struct TokensMap {
        address[] keys;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
        mapping(address => string) name;
        mapping(address => uint256) minAmount;
        mapping(address => uint256) singleAmount;
        mapping(address => uint256) fee;// e.g. 10 on behalf of 10%
        mapping(address => uint256) sort;
        mapping(address => bool) enabled;
    }

    TokensMap private tMap;

    function getToken(address key) 
    public 
    view 
    returns (
        bool inserted,
        string memory name,
        uint256 minAmount,
        uint256 singleAmount,
        uint256 fee,
        uint256 sort,
        bool enabled
    )
    {
        inserted = tMap.inserted[key];
        name = tMap.name[key];
        minAmount = tMap.minAmount[key];
        singleAmount = tMap.singleAmount[key];
        fee = tMap.fee[key];
        sort = tMap.sort[key];
        enabled = tMap.enabled[key];
    }

    function getTokenIndexOfKey(address key)
    public
    view
    returns (int256)
    {
        if (!tMap.inserted[key]) {
            return -1;
        }
        return int256(tMap.indexOf[key]);
    }

    function getTokenKeyAtIndex(uint256 index)
    public
    view
    returns (address)
    {
        return tMap.keys[index];
    }

    function tokensLength() public view returns (uint256) {
        return tMap.keys.length;
    }

    function setToken(
        address key,
        string memory name,
        uint256 minAmount,
        uint256 singleAmount,
        uint256 fee,
        uint256 sort,
        bool enabled
    ) public onlyadmin{
        if (tMap.inserted[key]) {
            tMap.name[key] = name;
            tMap.minAmount[key] =  minAmount;
            tMap.singleAmount[key] =  singleAmount;
            tMap.fee[key] = fee;
            tMap.sort[key] = sort;
            tMap.enabled[key] = enabled;
        } else {
            tMap.inserted[key] = true;
            tMap.name[key] = name;
            tMap.minAmount[key] =  minAmount;
            tMap.singleAmount[key] =  singleAmount;
            tMap.fee[key] = fee;
            tMap.sort[key] = sort;
            tMap.enabled[key] = enabled;
            tMap.indexOf[key] = tMap.keys.length;
            tMap.keys.push(key);
        }
    }

    function removeToken(address key) public onlyadmin{
        if (!tMap.inserted[key]) {
            return;
        }

        delete tMap.inserted[key];
        delete tMap.name[key];
        delete tMap.minAmount[key];
        delete tMap.singleAmount[key];
        delete tMap.fee[key];
        delete tMap.sort[key];
        delete tMap.enabled[key];
        uint256 index = tMap.indexOf[key];
        uint256 lastIndex = tMap.keys.length - 1;
        address lastKey = tMap.keys[lastIndex];

        tMap.indexOf[lastKey] = index;
        delete tMap.indexOf[key];

        tMap.keys[index] = lastKey;
        tMap.keys.pop();
    }

    // end tokens CRUD

    // start navigation
    string public navJson;

    // base64 data
    function setNavJson(string memory data) public onlyadmin{
        navJson=data;
    }

    // end navigation

    function withdraw(address target,uint amount) public onlyowneres {
        payable(target).transfer(amount);
    }

    function withdrawToken(address token,address target, uint amount) public onlyowneres {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}

}
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

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
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

interface IDao7Users{

    function get(address key) external view returns (
        bool inserted,
        uint256 indexOf,
        bool validReferral,
        address inviter,
        uint256 registerTime
    );

    function getIndexOfKey(address key) external view returns (uint256);

    function getKeyAtIndex(uint256 index) external view returns (address);

    function size() external view returns (uint256);

    function register(uint256 inviteCode) external;
    
    function registerOfBet(address key,uint256 inviteCode) external;

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


contract Dao7Topic is Ownable {
    // version
    uint public version=1;

    // main contract
    IDao7Bet mainContract;

    // user contract address
    IDao7Users userContract;

    string public topicJson;

    uint256 public optionCount;

    bool public canBet = false;

    uint256 public endTime;

    uint256 public trueOption = 0;

    constructor(address _mainContract,address _userAddress,bool _canBet,uint256 _inTime) {
        owner = msg.sender;
        mainContract = IDao7Bet(_mainContract);
        userContract = IDao7Users(_userAddress);
        canBet = _canBet;
        endTime =  block.number + _inTime;
    }

    // saved token => sumAmount
    mapping(address => uint256) private option1Map;

    mapping(address => uint256) private option2Map;
    
    mapping(address => uint256) private option3Map;
    
    mapping(address => uint256) private option4Map;
    
    mapping(address => uint256) private option5Map;
    
    mapping(address => uint256) private option6Map;
    
    mapping(address => uint256) private option7Map;
    
    mapping(address => uint256) private option8Map;
    
    mapping(address => uint256) private option9Map;
    
    mapping(address => uint256) private option10Map;

    // bet detail accounts
    struct BetList{
        address token;
        uint256 option;
        uint256 amount;
        bool isWinner;
        uint256 winnerAmount;
    }

    struct UserBetMap {
        address[] keys;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
        mapping(address => bool) settled;
        mapping(address => BetList[]) betList;
    }
    UserBetMap private userBetMap;

    function getUserBet(address key)
    public 
    view 
    returns (
        uint256 indexOf,
        bool inserted,
        bool settled,
        BetList[] memory betList
    )
    {
        inserted = userBetMap.inserted[key];
        indexOf = userBetMap.indexOf[key];
        settled = userBetMap.settled[key];
        betList =  userBetMap.betList[key];
    }

    function getIndexOfKey(address key)
    public
    view
    returns (int256)
    {
        if (!userBetMap.inserted[key]) {
            return -1;
        }
        return int256(userBetMap.indexOf[key]);
    }

    function getKeyAtIndex(uint256 index)
    public
    view
    returns (address)
    {
        return userBetMap.keys[index];
    }

    function size() public view returns (uint256) {
        return userBetMap.keys.length;
    }

    // max options is 10
    function bet(address token,uint256 amount,uint256 optionId,uint256 inviteCode) public{

        require(canBet,"can't bet");

        require(block.number < endTime,"time for bet is over");

        require(optionCount > 1 && optionCount < 11,"error option count");

        require(optionId >0 && optionId <11,"error option");

        (bool tokenInserted,,,,,,bool tokenEnabled) = mainContract.getToken(token);

        require(tokenInserted,"token not exists");

        require(tokenEnabled,"token not enabled");

        (bool userInserted,,,,) = userContract.get(msg.sender);
        if(!userInserted){
            userContract.registerOfBet(msg.sender, inviteCode);
        }

        if(optionId == 1){
            option1Map[token] += amount;
        }else if (optionId == 2){
            option2Map[token] += amount;
        }else if (optionId == 3){
            option3Map[token] += amount;
        }else if (optionId == 4){
            option4Map[token] += amount;
        }else if (optionId == 5){
            option5Map[token] += amount;
        }else if (optionId == 6){
            option6Map[token] += amount;
        }else if (optionId == 7){
            option7Map[token] += amount;
        }else if (optionId == 8){
            option8Map[token] += amount;
        }else if (optionId == 9){
            option9Map[token] += amount;
        }else if (optionId == 10){
            option10Map[token] += amount;
        }
        if (!userBetMap.inserted[msg.sender]) {
            userBetMap.inserted[msg.sender] = true;
            userBetMap.indexOf[msg.sender] = userBetMap.keys.length;
            userBetMap.settled[msg.sender] = false;
            userBetMap.keys.push(msg.sender);
        }
        // push detail accounts
        userBetMap.betList[msg.sender].push(BetList({
            token : token,
            option : optionId,
            amount : amount,
            isWinner : false,
            winnerAmount: 0
        }));
    }

    // base64 data
    function setTopicJson(string memory data,uint256 _optionCount) public onlyadmin{
        topicJson = data;
        optionCount = _optionCount;
    }

    function setMainAddress(address _newAddress) public onlyadmin{
        mainContract = IDao7Bet(_newAddress);
    }

    function setUserContract(address _newAddress) public onlyadmin{
        userContract = IDao7Users(_newAddress);
    }

    function setEntTime(uint256 _endTime) public onlyadmin{
        endTime = _endTime;
    }

    function setCanBet(bool _canBet) public onlyadmin{
        canBet = _canBet;
    }

    function withdraw(address target,uint amount) public onlyowneres {
        payable(target).transfer(amount);
    }

    function withdrawToken(address token,address target, uint amount) public onlyowneres {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}

}
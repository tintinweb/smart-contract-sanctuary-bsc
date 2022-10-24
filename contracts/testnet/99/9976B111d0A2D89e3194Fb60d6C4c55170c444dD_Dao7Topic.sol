/**
 *Submitted for verification at BscScan.com on 2022-10-24
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
        uint256 sort,
        uint256 navId,
        string memory topicJson,
        uint256 optionCount,
        bool canBet,
        uint256 trueOption,
        uint256 endTime
    );

    function getTopicOfIndex(uint256 index) external view returns(
        bool inserted,
        uint256 sort,
        uint256 navId,
        string memory topicJson,
        uint256 optionCount,
        bool canBet,
        uint256 trueOption,
        uint256 endTime
    );

    function getTopicIndexOfKey(address key) external view returns (int256);

    function getTopicKeyAtIndex(uint256 index) external view returns (address);

    function TopicsLength() external view returns (uint256);

    function getCanBet(address key) external view returns (bool);

    function getEndTime(address key) external view returns (uint256);

    function getOptionCount(address key) external view returns (uint256);

    function getTrueOption(address key) external view returns (uint256);

    function setTrueOption(address key,uint256 _trueOption) external;

    function setTopicJson(address key,string memory data,uint256 _optionCount) external;

    function setEntTime(address key,uint256 _endTime) external;

    function setCanBet(address key,bool _canBet) external;

    function getToken(address key) external view returns (
        bool inserted,
        string memory name,
        uint256 minAmount,
        uint256 singleAmount,
        uint256 fee,
        uint256 rebate1,
        uint256 rebate2,
        uint256 sort,
        bool enabled
    );

    function getTokenOfIndex(uint256 index) external view returns (
        bool inserted,
        string memory name,
        uint256 minAmount,
        uint256 singleAmount,
        uint256 fee,
        uint256 rebate1,
        uint256 rebate2,
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

    // user contract
    IDao7Users userContract;

    constructor(address _mainContract,address _userAddress) {
        owner = msg.sender;
        mainContract = IDao7Bet(_mainContract);
        userContract = IDao7Users(_userAddress);
    }

    // saved token => sumAmount
    mapping(address => uint256) public option1Map;

    mapping(address => uint256) public option2Map;
    
    mapping(address => uint256) public option3Map;
    
    mapping(address => uint256) public option4Map;
    
    mapping(address => uint256) public option5Map;
    
    mapping(address => uint256) public option6Map;
    
    mapping(address => uint256) public option7Map;
    
    mapping(address => uint256) public option8Map;
    
    mapping(address => uint256) public option9Map;
    
    mapping(address => uint256) public option10Map;

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
        mapping(address => BetList[]) betList;
    }
    UserBetMap private userBetMap;

    function getUserBet(address key)
    public 
    view 
    returns (
        uint256 indexOf,
        bool inserted,
        BetList[] memory betList
    )
    {
        inserted = userBetMap.inserted[key];
        indexOf = userBetMap.indexOf[key];
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

        address key = address(this);

        require(mainContract.getCanBet(key),"can't bet");

        require(block.number < mainContract.getEndTime(key),"time for bet is over");

        require(mainContract.getOptionCount(key) > 1 && mainContract.getOptionCount(key) < 11,"error option count");

        require(optionId >0 && optionId <11,"error option");

        (bool tokenInserted,,,,,,,,bool tokenEnabled) = mainContract.getToken(token);

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

    function settleAccountsOfToken(address token) public onlyadmin{

        address thisAddress = address(this);

        (bool tokenInserted,,,,uint256 tokenFee,uint256 rebate1,uint256 rebate2,,) = mainContract.getToken(token);

        require(tokenInserted,"token not exists");

        uint256 trueOption = mainContract.getTrueOption(thisAddress);

        require(trueOption > 0,"not open bet");

        uint256 sumAmount = option1Map[token];

        uint256 optionCount = mainContract.getOptionCount(thisAddress);

        if (optionCount >= 2){
            sumAmount += option2Map[token];
        }else if (optionCount >= 3){
            sumAmount += option3Map[token];
        }else if (optionCount >= 4){
            sumAmount += option4Map[token];
        }else if (optionCount >= 5){
            sumAmount += option5Map[token];
        }else if (optionCount >= 6){
            sumAmount += option6Map[token];
        }else if (optionCount >= 7){
            sumAmount += option7Map[token];
        }else if (optionCount >= 8){
            sumAmount += option8Map[token];
        }else if (optionCount >= 9){
            sumAmount += option9Map[token];
        }else if (optionCount >= 10){
            sumAmount += option10Map[token];
        }

        if(sumAmount ==  0){
            return;
        }

        uint256 trueOptionAmount = option1Map[token];

        if(trueOption == 2){
            trueOptionAmount = option2Map[token];
        }else if (trueOption == 3){
            trueOptionAmount = option3Map[token];
        }else if (trueOption == 4){
            trueOptionAmount = option4Map[token];
        }else if (trueOption == 5){
            trueOptionAmount = option5Map[token];
        }else if (trueOption == 6){
            trueOptionAmount = option6Map[token];
        }else if (trueOption == 7){
            trueOptionAmount = option7Map[token];
        }else if (trueOption == 8){
            trueOptionAmount = option8Map[token];
        }else if (trueOption == 9){
            trueOptionAmount = option9Map[token];
        }else if (trueOption == 10){
            trueOptionAmount = option10Map[token];
        }

        // if trueoption is 0,then odds are 1
        uint256 odds;
        uint256 totalAmount = sumAmount - (sumAmount / 100 * tokenFee);
        if(trueOptionAmount > 0){
            odds = totalAmount / trueOptionAmount;
        }
        require(IERC20(token).balanceOf(address(this)) > totalAmount,"balance too low");

        // Traverse the betting flow and settle items by item
        for(uint256 i = 0;i < userBetMap.keys.length;i++){
            address key = userBetMap.keys[i];
            (,,,address inviter,) = userContract.get(key);
            address inviter2;
            if(inviter != address(0)){
                (,,,inviter2,) = userContract.get(inviter);
            }
            BetList[] memory userBetList = userBetMap.betList[key];
            // for(uint256 j=0;j < userBetList.length;j++){
            //     BetList memory betSingle = userBetList[j];
            //     if(betSingle.token == token){
            //         // Level 1 rebate
            //         if(inviter != address(0) && betSingle.amount > 0){
            //             IERC20(token).transfer(inviter , betSingle.amount / 100 * rebate1);
            //         }
            //         // Level 2 rebate
            //         if(inviter2 != address(0) && betSingle.amount > 0){
            //             IERC20(token).transfer(inviter2 , betSingle.amount / 100 * rebate2);
            //         }
            //         // is winner
            //         if(betSingle.option == trueOption && betSingle.amount > 0){
            //             IERC20(token).transfer(key , betSingle.amount * odds);
            //         }
            //     }
            // }
        }
    }

    function openBet(uint256 _trueOption) public onlyadmin{
        mainContract.setTrueOption(address(this),_trueOption);
    }

    // base64 data
    function setTopicJson(string memory data,uint256 _optionCount) public onlyadmin{
        mainContract.setTopicJson(address(this),data,_optionCount);
    }

    function setMainAddress(address _newAddress) public onlyadmin{
        mainContract = IDao7Bet(_newAddress);
    }

    function setUserContract(address _newAddress) public onlyadmin{
        userContract = IDao7Users(_newAddress);
    }

    function setEntTime(uint256 _endTime) public onlyadmin{
        mainContract.setEntTime(address(this),_endTime);
    }

    function setCanBet(bool _canBet) public onlyadmin{
        mainContract.setCanBet(address(this),_canBet);
    }

    function withdraw(address target,uint amount) public onlyowneres {
        payable(target).transfer(amount);
    }

    function withdrawToken(address token,address target, uint amount) public onlyowneres {
        IERC20(token).transfer(target, amount);
    }
    receive() external payable {}
}
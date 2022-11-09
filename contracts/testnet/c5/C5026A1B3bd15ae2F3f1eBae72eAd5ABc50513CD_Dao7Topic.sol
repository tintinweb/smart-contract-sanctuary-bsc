/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IDao7Bet{

    function WETH() external pure returns (address);

    function getCanBet(address key) external view returns (bool);

    function getEndTime(address key) external view returns (uint256);

    function getGroupId(address key) external view returns (uint256);

    function getOptionCount(address key) external view returns (uint256);

    function getTrueOption(address key) external view returns (uint256);

    function getIsCancel(address key) external view returns (bool);

    function topicInserted(address key) external view returns (bool);

    function setTrueOption(address key,uint256 _trueOption) external;

    function setCancelTopic(address key) external;

    function setTopicJson(address key,string memory data,uint256 _optionCount) external;

    function setEndTime(address key,uint256 _endTime) external;

    function setGroupId(address key,uint256 _groupId) external;

    function setCanBet(address key,bool _canBet) external;

    function getToken(address tokenKey) external view returns (
        address key,
        bool inserted,
        string memory name,
        uint256 minAmount,
        uint256 singleAmount,
        uint256 fee,
        uint256 rebate1,
        uint256 rebate2,
        uint256 sort,
        bool enabled,
        uint256 createTime
    );

    function getTokenOfIndex(uint256 index) external view returns (
        address key,
        bool inserted,
        string memory name,
        uint256 minAmount,
        uint256 singleAmount,
        uint256 fee,
        uint256 rebate1,
        uint256 rebate2,
        uint256 sort,
        bool enabled,
        uint256 createTime
    );

    function getTokenIndexOfKey(address key) external view returns (uint256);

    function getTokenKeyAtIndex(uint256 index) external view returns (address);

    function tokensLength() external view returns (uint256);

    function tokenInserted(address key) external view returns (bool);

}

interface IDao7Users{

    function get(address userKey) external view returns (
        address key,
        bool inserted,
        uint256 indexOf,
        address inviter,
        uint256 registerTime
    );

    function getUserOfIndex(uint256 index) external view returns (
        address key,
        bool inserted,
        uint256 indexOf,
        address inviter,
        uint256 registerTime
    );

    function getIndexOfKey(address key) external view returns (uint256);

    function getKeyAtIndex(uint256 index) external view returns (address);

    function getRegisterTime(address key) external view returns (uint256);

    function getInviter(address key) external view returns(address);
    
    function size() external view returns (uint256);

    function userInserted(address key) external view returns (bool);
    
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
    address public mainContractAddress;

    // user contract
    IDao7Users userContract;
    address public userContractAddress;

    constructor(address _mainContract,address _userAddress) {
        owner = msg.sender;
        mainContract = IDao7Bet(_mainContract);
        userContract = IDao7Users(_userAddress);
        mainContractAddress = _mainContract;
        userContractAddress = _userAddress;
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

    // The betting record of user and corresponding option
    // get one bet info: betRecord[token][user][option] => bet amount
    mapping(address => mapping(address => mapping(uint256 => uint256))) public betRecord;
    
    // The user's invitation rebate record
    // invitationRecord[token][user] => amount
    mapping(address => mapping(address => uint256)) public invitationRecord;

    // Reward withdraw flag
    // withdrawFlag[token][user] => flag
    mapping(address => mapping(address => bool)) public withdrawFlag;

    function getWithdrawFlag(address token,address userAddress) public view returns(bool){
        return withdrawFlag[token][userAddress];
    }

    mapping(address => mapping(address => bool)) public withdrawCancelFlag;

    function getWithdrawCancelFlag(address token,address userAddress) public view returns(bool){
        return withdrawCancelFlag[token][userAddress];
    }
    // feeRecord[token] = feeAmount
    mapping(address => uint256) public feeRecord;
    // rebateRecord[token]
    mapping(address => uint256) public rebateRecord;

    // The odds after open bet
    mapping(address => uint256) public tokenOdds;

    mapping(address => bool) public withdrawFeeFlag;

    function getWithdrawFeeFlag(address token) public view returns(bool){
        return withdrawFeeFlag[token];
    }

    // max options is 10
    // function bet(address token,uint256 amount,uint256 optionId,uint256 inviteCode) public{

    //     address key = address(this);

    //     require(mainContract.getCanBet(key),"can't bet");

    //     require(block.number < mainContract.getEndTime(key),"time for bet is over");

    //     require(mainContract.getOptionCount(key) > 1 && mainContract.getOptionCount(key) < 11,"error option count");

    //     require(optionId >0 && optionId <11,"error option");

    //     bool isCancel = mainContract.getIsCancel(key);

    //     require(!isCancel,"this topic is cancel");

    //     TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);

    //     _bet(token, msg.sender, amount, optionId, inviteCode);
    // }

    // function betWETH(uint256 optionId,uint256 inviteCode) payable public{

    //     address key = address(this);

    //     require(mainContract.getCanBet(key),"can't bet");

    //     require(block.number < mainContract.getEndTime(key),"time for bet is over");

    //     require(mainContract.getOptionCount(key) > 1 && mainContract.getOptionCount(key) < 11,"error option count");

    //     require(optionId >0 && optionId <11,"error option");

    //     bool isCancel = mainContract.getIsCancel(key);

    //     require(!isCancel,"this topic is cancel");

    //     uint256 amount = msg.value;

    //     address token = mainContract.WETH();

    //     IWETH(token).deposit{value: amount}();
        
    //     assert(IWETH(token).transfer(address(this), amount));

    //     _bet(token, msg.sender, amount, optionId, inviteCode);
    // }


    function betFrom(address token,address userAddress,uint256 amount,uint256 optionId,uint256 inviteCode) public{

        require(msg.sender == mainContractAddress,"illegal address");

        address key = address(this);

        require(mainContract.getCanBet(key),"can't bet");

        require(block.number < mainContract.getEndTime(key),"time for bet is over");

        require(mainContract.getOptionCount(key) > 1 && mainContract.getOptionCount(key) < 11,"error option count");

        require(optionId >0 && optionId <11,"error option");

        bool isCancel = mainContract.getIsCancel(key);

        require(!isCancel,"this topic is cancel");

        _bet(token, userAddress, amount, optionId, inviteCode);
        
    }

    function _bet(address token,address userAddress,uint256 _amount,uint256 optionId,uint256 inviteCode) private{

        (,bool tokenInserted,,uint256 minAmount,,uint256 fee,uint256 rebate1,uint256 rebate2,,bool tokenEnabled,) 
        = mainContract.getToken(token);

        require(tokenInserted,"token not exists");

        require(tokenEnabled,"token not enabled");

        require(_amount >= minAmount,"bet amount too low");

        if(!userContract.userInserted(userAddress)){
            userContract.registerOfBet(userAddress, inviteCode);
        }

        if(optionId == 1){
            option1Map[token] += _amount;
        }else if (optionId == 2){
            option2Map[token] += _amount;
        }else if (optionId == 3){
            option3Map[token] += _amount;
        }else if (optionId == 4){
            option4Map[token] += _amount;
        }else if (optionId == 5){
            option5Map[token] += _amount;
        }else if (optionId == 6){
            option6Map[token] += _amount;
        }else if (optionId == 7){
            option7Map[token] += _amount;
        }else if (optionId == 8){
            option8Map[token] += _amount;
        }else if (optionId == 9){
            option9Map[token] += _amount;
        }else if (optionId == 10){
            option10Map[token] += _amount;
        }
        betRecord[token][userAddress][optionId] += _amount;
        setFeeAmount(token, userAddress, _amount, fee, rebate1, rebate2);
    }

    function setFeeAmount(address token,address userAddress,uint256 _amount,uint256 fee,uint256 rebate1,uint256 rebate2) private{
        // Level 2 invitation records
        address inviter1 = userContract.getInviter(userAddress);
        address inviter2;
        if(inviter1 != address(0)){
            inviter2 = userContract.getInviter(inviter1);
        }
        uint256 feeAmount = _amount / 10000 * fee;
        if(inviter1 != address(0)){
            invitationRecord[token][inviter1] += _amount / 10000 * rebate1;
            uint256 rebate = _amount / 10000 * rebate1;
            feeAmount -= rebate;
            rebateRecord[token] += rebate;
        }
        if(inviter2 != address(0)){
            invitationRecord[token][inviter2] += _amount / 10000 * rebate2;
            uint256 rebate = _amount / 10000 * rebate2;
            feeAmount -= rebate;
            rebateRecord[token] += rebate;
        }

        feeRecord[token] += feeAmount;
        
    }

    function getInvitationAmount(address token,address userAddress) public view returns(uint256){
        
        address thisAddress = address(this);
        bool isCancel = mainContract.getIsCancel(thisAddress);
        if(isCancel){
            return 0;
        }

        uint256 trueOption = mainContract.getTrueOption(thisAddress);
        if(trueOption == 0){
            return invitationRecord[token][userAddress];
        }

        if(feeRecord[token] < rebateRecord[token]){
            return 0;
        }

        return invitationRecord[token][userAddress];
    }

    function getFeeAmount(address token) public view returns(uint256){

        uint256 trueOption = mainContract.getTrueOption(address(this));
        if(trueOption == 0){
            return 0;
        }
        bool isCancel = mainContract.getIsCancel(address(this));
        if(isCancel){
            return 0;
        }
        return feeRecord[token];
    }

    function getBetAmount(address token) public view returns (uint256){
        uint256 betAmount = option1Map[token];
        betAmount += option2Map[token];
        betAmount += option3Map[token];
        betAmount += option4Map[token];
        betAmount += option5Map[token];
        betAmount += option6Map[token];
        betAmount += option7Map[token];
        betAmount += option8Map[token];
        betAmount += option9Map[token];
        betAmount += option10Map[token];

        return betAmount;
    }

    function getBetRecords(address token) public view 
    returns(uint256 option1Amount,uint256 option2Amount,uint256 option3Amount,uint256 option4Amount,
    uint256 option5Amount,uint256 option6Amount,uint256 option7Amount,uint256 option8Amount,
    uint256 option9Amount,uint256 option10Amount ){
        option1Amount = option1Map[token];
        option2Amount = option2Map[token];
        option3Amount = option3Map[token];
        option4Amount = option4Map[token];
        option5Amount = option5Map[token];
        option6Amount = option6Map[token];
        option7Amount = option7Map[token];
        option8Amount = option8Map[token];
        option9Amount = option9Map[token];
        option10Amount = option10Map[token];
    }

    function getDynamicOdds(address token,uint256 option) public view returns(uint256){

        uint256 sumAmount = option1Map[token];

        uint256 optionCount = mainContract.getOptionCount(address(this));

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

        (,,,,,uint256 tokenFee,,,,,) = mainContract.getToken(token);

        uint256 odds = sumAmount * 1e18;
        if(option == 1 && option1Map[token] > 0){
            odds = (sumAmount - ((sumAmount - option1Map[token]) / 10000 * tokenFee)) * 1e18 / option1Map[token];
        }

        if(option == 2 && option2Map[token] > 0){
            odds = (sumAmount - ((sumAmount - option2Map[token]) / 10000 * tokenFee)) * 1e18 / option2Map[token];
        }
        
        if(option == 3 && option3Map[token] > 0){
            odds = (sumAmount - ((sumAmount - option3Map[token]) / 10000 * tokenFee)) * 1e18 / option3Map[token];
        }

        if(option == 4 && option4Map[token] > 0){
            odds = (sumAmount - ((sumAmount - option4Map[token]) / 10000 * tokenFee)) * 1e18 / option4Map[token];
        }

        if(option == 5 && option5Map[token] > 0){
            odds = (sumAmount - ((sumAmount - option5Map[token]) / 10000 * tokenFee)) * 1e18 / option5Map[token];
        }

        if(option == 6 && option6Map[token] > 0){
            odds = (sumAmount - ((sumAmount - option6Map[token]) / 10000 * tokenFee)) * 1e18 / option6Map[token];
        }
        
        if(option == 7 && option7Map[token] > 0){
            odds = (sumAmount - ((sumAmount - option7Map[token]) / 10000 * tokenFee)) * 1e18 / option7Map[token];
        }

        if(option == 8 && option8Map[token] > 0){
            odds = (sumAmount - ((sumAmount - option8Map[token]) / 10000 * tokenFee)) * 1e18 / option8Map[token];
        }

        if(option == 9 && option9Map[token] > 0){
            odds = (sumAmount - ((sumAmount - option9Map[token]) / 10000 * tokenFee)) * 1e18 / option9Map[token];
        }

        if(option == 10 && option10Map[token] > 0){
            odds = (sumAmount - ((sumAmount - option10Map[token]) / 10000 * tokenFee)) * 1e18 / option10Map[token];
        }

        return odds;
    }

    function getBetAmountOfUser(address token,address userAddress) public view returns (uint256){
        uint256 betAmount = betRecord[token][userAddress][1];
        betAmount += betRecord[token][userAddress][2];
        betAmount += betRecord[token][userAddress][3];
        betAmount += betRecord[token][userAddress][4];
        betAmount += betRecord[token][userAddress][5];
        betAmount += betRecord[token][userAddress][6];
        betAmount += betRecord[token][userAddress][7];
        betAmount += betRecord[token][userAddress][8];
        betAmount += betRecord[token][userAddress][9];
        betAmount += betRecord[token][userAddress][10];

        return betAmount;
    }

    function getWinAmount(address token,address userAddress) public view returns(uint256){
        address thisAddress = address(this);

        if(!mainContract.tokenInserted(token)){
            return 0;
        }

        bool isCancel = mainContract.getIsCancel(thisAddress);
        if(isCancel){
            return 0;
        }

        uint256 trueOption = mainContract.getTrueOption(thisAddress);
        if(trueOption == 0){
            return 0;
        }

        uint256 odds = tokenOdds[token];
        if(trueOption ==1 && betRecord[token][userAddress][1] > 0){
            return betRecord[token][userAddress][1] * odds / 1e18;
        }
        if(trueOption ==2 && betRecord[token][userAddress][2] > 0){
            return betRecord[token][userAddress][2]  * odds / 1e18;
        }
        if(trueOption ==3 && betRecord[token][userAddress][3] > 0){
            return betRecord[token][userAddress][3]  * odds / 1e18;
        }
        if(trueOption ==4 && betRecord[token][userAddress][4] > 0){
            return betRecord[token][userAddress][4]  * odds / 1e18;
        }
        if(trueOption ==5 && betRecord[token][userAddress][5] > 0){
            return betRecord[token][userAddress][5]  * odds / 1e18;
        }
        if(trueOption ==6 && betRecord[token][userAddress][6] > 0){
            return betRecord[token][userAddress][6]  * odds / 1e18;
        }
        if(trueOption ==7 && betRecord[token][userAddress][7] > 0){
            return betRecord[token][userAddress][7]  * odds / 1e18;
        }
        if(trueOption ==8 && betRecord[token][userAddress][8] > 0){
            return betRecord[token][userAddress][8]  * odds / 1e18;
        }
        if(trueOption ==9 && betRecord[token][userAddress][9] > 0){
            return betRecord[token][userAddress][9]  * odds / 1e18;
        }
        if(trueOption ==10 && betRecord[token][userAddress][10] > 0){
            return betRecord[token][userAddress][10]  * odds / 1e18;
        }
        return 0;
    }

    function getCancelAmount(address token,address userAddress) public view returns(uint256){

        address thisAddress = address(this);

        if(!mainContract.tokenInserted(token)){
            return 0;
        }

        bool isCancel = mainContract.getIsCancel(thisAddress);
        if(!isCancel){
            return 0;
        }
        uint256 betAmount;
        if(betRecord[token][userAddress][1] > 0){
            betAmount += betRecord[token][userAddress][1];
        }
        if(betRecord[token][userAddress][2] > 0){
            betAmount += betRecord[token][userAddress][2];
        }
        if(betRecord[token][userAddress][3] > 0){
            betAmount +=  betRecord[token][userAddress][3];
        }
        if(betRecord[token][userAddress][4] > 0){
            betAmount +=  betRecord[token][userAddress][4];
        }
        if(betRecord[token][userAddress][5] > 0){
            betAmount +=  betRecord[token][userAddress][5];
        }
        if(betRecord[token][userAddress][6] > 0){
            betAmount +=  betRecord[token][userAddress][6];
        }
        if(betRecord[token][userAddress][7] > 0){
            betAmount +=  betRecord[token][userAddress][7];
        }
        if(betRecord[token][userAddress][8] > 0){
            betAmount +=  betRecord[token][userAddress][8];
        }
        if(betRecord[token][userAddress][9] > 0){
            betAmount +=  betRecord[token][userAddress][9];
        }
        if(betRecord[token][userAddress][10] > 0){
            betAmount +=  betRecord[token][userAddress][10];
        }
        return betAmount;
    }

    function withdraw(address token) public{
        address thisAddress = address(this);

        require(mainContract.tokenInserted(token),"token not exists");

        uint256 trueOption = mainContract.getTrueOption(thisAddress);

        require(trueOption > 0,"not open bet");

        require(!withdrawFlag[token][msg.sender],"you has been withdraw");

        bool isCancel = mainContract.getIsCancel(thisAddress);

        require(!isCancel,"this topic is cancel");

        uint256 invitationAmount = getInvitationAmount(token, msg.sender);

        if(invitationAmount > 0){
            if(token == mainContract.WETH()){
                IWETH(mainContract.WETH()).withdraw(invitationAmount);
                TransferHelper.safeTransferETH(msg.sender, invitationAmount);
            }else{
                TransferHelper.safeTransfer(token, msg.sender, invitationAmount);
            }
        }
        uint256 winAmount = getWinAmount(token, msg.sender);
        if(winAmount > 0){
            if(token == mainContract.WETH()){
                IWETH(mainContract.WETH()).withdraw(winAmount);
                TransferHelper.safeTransferETH(msg.sender, winAmount);
            }else{
                TransferHelper.safeTransfer(token, msg.sender, winAmount);
            }
        }
        withdrawFlag[token][msg.sender] = true;
    }

    function withdrawFrom(address token,address userAddress) public{

        require(msg.sender == mainContractAddress,"illegal address");

        address thisAddress = address(this);

        require(mainContract.tokenInserted(token),"token not exists");

        uint256 trueOption = mainContract.getTrueOption(thisAddress);

        require(trueOption > 0,"not open bet");

        require(!withdrawFlag[token][userAddress],"you has been withdraw");

        bool isCancel = mainContract.getIsCancel(thisAddress);

        require(!isCancel,"this topic is cancel");

        withdrawFlag[token][userAddress] = true;
        
        if(token == mainContract.WETH()){
            uint256 invitationAmount = getInvitationAmount(token, userAddress);
            if(invitationAmount > 0){
                TransferHelper.safeTransfer(token, msg.sender, invitationAmount);
            }
            uint256 winAmount = getWinAmount(token, userAddress);
            if(winAmount > 0){
                TransferHelper.safeTransfer(token, msg.sender, winAmount);
            }
        }
    }

    function withdrawCancel(address token) public{
        address thisAddress = address(this);

        require(mainContract.tokenInserted(token),"token not exists");

        bool isCancel = mainContract.getIsCancel(thisAddress);

        require(isCancel,"this topic not cancel");

        require(!withdrawCancelFlag[token][msg.sender],"you has been withdraw");

        uint256 cancelAmount = getCancelAmount(token, msg.sender);
        if(cancelAmount > 0){
            if(token == mainContract.WETH()){
                IWETH(mainContract.WETH()).withdraw(cancelAmount);
                TransferHelper.safeTransferETH(msg.sender, cancelAmount);
            }else{
                TransferHelper.safeTransfer(token, msg.sender, cancelAmount);
            }
        }
        withdrawCancelFlag[token][msg.sender] = true;
    }

    function withdrawCancelFrom(address token,address userAddress) public{

        require(msg.sender == mainContractAddress,"illegal address");

        address thisAddress = address(this);

        require(mainContract.tokenInserted(token),"token not exists");

        bool isCancel = mainContract.getIsCancel(thisAddress);

        require(isCancel,"this topic not cancel");

        require(!withdrawCancelFlag[token][userAddress],"you has been withdraw");

        withdrawCancelFlag[token][userAddress] = true;

        if(token == mainContract.WETH()){
            uint256 cancelAmount = getCancelAmount(token, userAddress);
            if(cancelAmount > 0){
                TransferHelper.safeTransfer(token, msg.sender, cancelAmount);
            }
        }
    }

    function approveMainContract(address token) public{
        TransferHelper.safeApprove(token, mainContractAddress,  ~uint256(0));
    }

    function withdrawFee(address token) public onlyowneres{
        address thisAddress = address(this);

        require(mainContract.tokenInserted(token),"token not exists");

        uint256 trueOption = mainContract.getTrueOption(thisAddress);

        require(trueOption > 0,"not open bet");

        require(!withdrawFeeFlag[token],"you has been withdraw");

        bool isCancel = mainContract.getIsCancel(thisAddress);

        require(!isCancel,"this topic is cancel");

        uint256 feeAmount = getFeeAmount(token);

        // Keep records of transfers, even if the value is 0
        if(token == mainContract.WETH()){
            IWETH(mainContract.WETH()).withdraw(feeAmount);
            TransferHelper.safeTransferETH(msg.sender, feeAmount);
        }else{
            TransferHelper.safeTransfer(token, msg.sender, feeAmount);
        }
        
        withdrawFeeFlag[token] = true;
    }

    function withdrawFeeFrom(address token) public{

        require(msg.sender == mainContractAddress,"illegal address");
        address thisAddress = address(this);

        require(mainContract.tokenInserted(token),"token not exists");

        uint256 trueOption = mainContract.getTrueOption(thisAddress);

        require(trueOption > 0,"not open bet");

        require(!withdrawFeeFlag[token],"you has been withdraw");

        bool isCancel = mainContract.getIsCancel(thisAddress);

        require(!isCancel,"this topic is cancel");
        
        withdrawFeeFlag[token] = true;

        if(token == mainContract.WETH()){
            uint256 feeAmount = getFeeAmount(token);
            if(feeAmount > 0){
                TransferHelper.safeTransfer(token, msg.sender, feeAmount);
            }
        }
    }

    function openBet(uint256 _trueOption) public{

        require(msg.sender == mainContractAddress,"illegal address");

        require(block.number > mainContract.getEndTime(address(this)),"time for bet is not over");

        require(!mainContract.getIsCancel(address(this)),"this topic is cancel"); 

        for(uint256 i = 0; i < mainContract.tokensLength(); i++){
            (address token,,,,,uint256 tokenFee,,,,,) = mainContract.getTokenOfIndex(i);
            _openBetSet(token, _trueOption, tokenFee);
        }
    }

    function openBetOfToken(address token,uint256 _trueOption) public{

        require(msg.sender == mainContractAddress,"illegal address");

        require(block.number > mainContract.getEndTime(address(this)),"time for bet is not over");

        require(!mainContract.getIsCancel(address(this)),"this topic is cancel"); 

        (,bool tokenInserted,,,,uint256 tokenFee,,,,,) = mainContract.getToken(token);

        require(tokenInserted,"token not exists");

        _openBetSet(token,_trueOption,tokenFee);
    }

    function _openBetSet(address token,uint256 trueOption,uint256 tokenFee) private{

        uint256 sumAmount = option1Map[token];

        uint256 optionCount = mainContract.getOptionCount(address(this));

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
        // if trueOptionAmount is 0,then odds are 1
        uint256 odds = 1;
        if(trueOptionAmount > 0){
            uint256 totalAmount = sumAmount - ((sumAmount - trueOptionAmount) / 10000 * tokenFee);
            odds = totalAmount * 1e18 / trueOptionAmount;

            feeRecord[token] = feeRecord[token] - trueOptionAmount / 10000 * tokenFee;
        }
        if(sumAmount > 0 && trueOptionAmount == 0){
            odds = sumAmount * 1e18;
            feeRecord[token] = sumAmount - rebateRecord[token];
        }

        tokenOdds[token] = odds;
        mainContract.setTrueOption(address(this),trueOption);
    }

    function cancelTopic() public onlyowneres{
        mainContract.setCancelTopic(address(this));
    }

    // base64 data
    function setTopicJson(string memory data,uint256 _optionCount) public onlyowneres{
        mainContract.setTopicJson(address(this),data,_optionCount);
    }

    function setMainAddress(address _newAddress) public onlyowneres{
        mainContract = IDao7Bet(_newAddress);
        mainContractAddress = _newAddress;
    }

    function setUserContract(address _newAddress) public onlyowneres{
        userContract = IDao7Users(_newAddress);
        userContractAddress = _newAddress;
    }

    function setEndTime(uint256 _endTime) public onlyowneres{
        mainContract.setEndTime(address(this),_endTime);
    }

    function setGroupId(uint256 _groupId) public onlyowneres{
        mainContract.setGroupId(address(this),_groupId);
    }

    function setCanBet(bool _canBet) public onlyowneres{
        mainContract.setCanBet(address(this),_canBet);
    }

    receive() external payable {
        assert(msg.sender == mainContract.WETH()); // only accept ETH via fallback from the WETH contract
    }
}
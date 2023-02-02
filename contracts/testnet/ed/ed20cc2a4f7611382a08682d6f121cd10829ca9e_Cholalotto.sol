// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./VRFConsumerBase.sol";
import "./Ownable.sol";
import "./EnumerableMap.sol";
import "./EnumerableSet.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Math.sol";
import "./ReentrancyGuard.sol";

contract Cholalotto is
    VRFConsumerBase,
    Ownable,
    ReentrancyGuard
{
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;


    uint256 public platformFee = 1 * 10 ** 18;
    uint256 public agentDiscount = 10;
    uint256 public ticket1 = 2 * 10 ** 18;
    uint256 public ticket2 = 5 * 10 ** 18;
    uint256 public ticket3 = 10 * 10 ** 18;
    uint256 public ticket4 = 20 * 10 ** 18;
    uint256 public ticket5 = 45 * 10 ** 18;
    uint256 public ticket6 = 60 * 10 ** 18;
    uint256 public ticket7 = 80 * 10 ** 18;
    uint256 public ticket8 = 100 * 10 ** 18;
    address public feeCollector;
    bool public feeStatus = true;
    address public tokenAddress;

    bytes32 internal keyHash;
    uint256 internal fee;

    uint256 private randomResult;
    mapping(bytes32 => address) public requestIdToAddress;
    mapping(bytes32 => uint256) public requestIdToRequestNumberIndex;
    mapping(bytes32 => uint256) public ticketBrought;
    mapping(uint256 => address) public requestNumberToId;
    mapping(address => bool) public mintProgress;
    mapping(address => bool) public agent;

    mapping(address => uint256[]) public userAddressToLastNumber;
    
    address[] public agentList;

    struct Purchased {
        uint256 ticketid;
        uint256 cycle;
        uint256 time;
        uint256 ticketnumber;
    }

    struct User {
        Purchased[] purchased;
    }

    mapping(address => User) internal users;

    mapping(uint256 => uint256) public ticket1Collection;
    mapping(uint256 => uint256) public ticket2Collection;
    mapping(uint256 => uint256) public ticket3Collection;
    mapping(uint256 => uint256) public ticket4Collection;
    mapping(uint256 => uint256) public ticket5Collection;
    mapping(uint256 => uint256) public ticket6Collection;
    mapping(uint256 => uint256) public ticket7Collection;
    mapping(uint256 => uint256) public ticket8Collection;

    mapping(uint256 => address[]) public ticket1WinnersList;
    mapping(uint256 => address[]) public ticket2WinnersList;
    mapping(uint256 => address[]) public ticket3WinnersList;
    mapping(uint256 => address[]) public ticket4WinnersList;
    mapping(uint256 => address[]) public ticket5WinnersList;
    mapping(uint256 => address[]) public ticket6WinnersList;
    mapping(uint256 => address[]) public ticket7WinnersList;
    mapping(uint256 => address[]) public ticket8WinnersList;

    mapping(uint256 => uint256) public ticket1Result;
    mapping(uint256 => uint256) public ticket2Result;
    mapping(uint256 => uint256) public ticket3Result;
    mapping(uint256 => uint256) public ticket4Result;
    mapping(uint256 => uint256) public ticket5Result;
    mapping(uint256 => uint256) public ticket6Result;
    mapping(uint256 => uint256) public ticket7Result;
    mapping(uint256 => uint256) public ticket8Result;


    mapping(uint256 => bool) public ticket1Claimed;
    mapping(uint256 => bool) public ticket2Claimed;
    mapping(uint256 => bool) public ticket3Claimed;
    mapping(uint256 => bool) public ticket4Claimed;
    mapping(uint256 => bool) public ticket5Claimed;
    mapping(uint256 => bool) public ticket6Claimed;
    mapping(uint256 => bool) public ticket7Claimed;
    mapping(uint256 => bool) public ticket8Claimed;


    uint256 public ticket1Cycle = 0;
    uint256 public ticket2Cycle = 0;
    uint256 public ticket3Cycle = 0;
    uint256 public ticket4Cycle = 0;
    uint256 public ticket5Cycle = 0;
    uint256 public ticket6Cycle = 0;
    uint256 public ticket7Cycle = 0;
    uint256 public ticket8Cycle = 0;

    uint256 ticket1Timeline = 10 minutes;
    uint256 ticket2Timeline = 15 minutes;
    uint256 ticket3Timeline = 20 minutes;
    uint256 ticket4Timeline = 25 minutes;
    uint256 ticket5Timeline = 30 minutes;
    uint256 ticket6Timeline = 35 minutes;
    uint256 ticket7Timeline = 40 minutes;
    uint256 ticket8Timeline = 45 minutes;

    uint256 ticket1Time ;
    uint256 ticket2Time ;
    uint256 ticket3Time ;
    uint256 ticket4Time ;
    uint256 ticket5Time ;
    uint256 ticket6Time ;
    uint256 ticket7Time ;
    uint256 ticket8Time ;

    uint256 public requestCounter;
    uint256 public fulfilledCounter;

    event MintTreasure(
        address _owner,
        uint256 _amount,
        string _hash,
        uint256 _tokenID
    );

    event LotteryOpened(uint256 _tokenId, address _to);

    /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: BSC Mainnet
     * Chainlink VRF Coordinator address: 0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31
     * LINK token address:                0x404460C6A5EdE2D891e8297795264fDe62ADBB75
     * Key Hash: 0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c
     * Fee :     0.2 * 10 ** 18 //0.2 LINK
     *
     *
     * Network: BSC Testnet
     * Chainlink VRF Coordinator address: 0xa555fC018435bef5A13C6c6870a9d4C11DEC329C
     * LINK token address:                0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06
     * Key Hash: 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186
     * Fee :     0.1 * 10 ** 18 //0.1 LINK
     */
    constructor(address _tokenAddress, address _feeCollector)
        VRFConsumerBase(
            0xa555fC018435bef5A13C6c6870a9d4C11DEC329C, // VRF Coordinator
            0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06 // LINK Token
        )
    {
        keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
        fee = 0.1 * 10 ** 18; //0.1 LINK
       
        require(
            _tokenAddress.isContract() &&
                _tokenAddress != address(0) &&
                _tokenAddress != address(this)
        );

        tokenAddress = _tokenAddress;

        require(
                _feeCollector != address(0)
        );
        feeCollector = _feeCollector;
    }

    modifier nonZeroAddress(address _to) {
        require(_to != address(0), "Address should not be address 0");
        _;
    }

    function toggleFeeStatus() external onlyOwner returns (bool success) {
        if (feeStatus) {
            feeStatus = false;
        } else {
            feeStatus = true;
        }
        return feeStatus;
    }


    function lottery(uint256 _ticketId,uint256 _amount)
        public
        nonReentrant
        returns (bytes32 requestId)
    {
        uint256 total = 1;
        uint256 remainingAmount;
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );

        ticketCheck(_ticketId,_amount);
        
        if (feeStatus) {
            uint256 _fee = platformFee * total;
            IERC20(tokenAddress).transferFrom(msg.sender,feeCollector,_fee);
            remainingAmount = _amount.sub(_fee);
        }else{
            remainingAmount = _amount;
        }

        IERC20(tokenAddress).transferFrom(msg.sender,address(this),remainingAmount);

        delete userAddressToLastNumber[msg.sender];
        for (uint256 i = 0; i < total; i++) {
            requestId = requestRandomness(keyHash, fee);
            requestIdToAddress[requestId] = msg.sender;
            ticketBrought[requestId] = _ticketId;
            requestIdToRequestNumberIndex[requestId] = requestCounter;
            requestCounter += 1;
        }
        mintProgress[msg.sender] = true;
    }

    function lotteryAgent(uint256 _ticketId,uint256 _amount, address _userAddress)
        public
        nonReentrant
        returns (bytes32 requestId)
    {
        uint256 total = 1;
        uint256 remainingAmount;
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );

        ticketCheckAgent(_ticketId,_amount);
        
        if (feeStatus) {
            uint256 _fee = platformFee * total;
            IERC20(tokenAddress).transferFrom(msg.sender,feeCollector,_fee);
            remainingAmount = _amount.sub(_fee);
        }else{
            remainingAmount = _amount;
        }

        IERC20(tokenAddress).transferFrom(msg.sender,address(this),remainingAmount);

        delete userAddressToLastNumber[_userAddress];
        for (uint256 i = 0; i < total; i++) {
            requestId = requestRandomness(keyHash, fee);
            requestIdToAddress[requestId] = _userAddress;
            ticketBrought[requestId] = _ticketId;
            requestIdToRequestNumberIndex[requestId] = requestCounter;
            requestCounter += 1;
        }
        mintProgress[_userAddress] = true;
    }

    function ticketCheck(uint256 _ticketId, uint256 _amount) internal{
        if(_ticketId == 1){
            require(_amount == ticket1,"Not Enough Ticket 1 Price");
            if(ticket1Time==0){
                ticket1Time = block.timestamp;
            }
            ticket1Collection[ticket1Cycle] = ticket1Collection[ticket1Cycle]+_amount;
        }else if(_ticketId == 2){
            require(_amount == ticket2,"Not Enough Ticket 2 Price");
            if(ticket2Time==0){
                ticket2Time = block.timestamp;
            }
            ticket2Collection[ticket2Cycle] = ticket2Collection[ticket2Cycle]+_amount;
        }else if(_ticketId == 3){
            require(_amount == ticket3,"Not Enough Ticket 3 Price");
            if(ticket3Time==0){
                ticket3Time = block.timestamp;
            }
            ticket3Collection[ticket3Cycle] = ticket3Collection[ticket3Cycle]+_amount;
        }else if(_ticketId == 4){
            require(_amount == ticket4,"Not Enough Ticket 4 Price");
            if(ticket4Time==0){
                ticket4Time = block.timestamp;
            }
            ticket4Collection[ticket4Cycle] = ticket4Collection[ticket4Cycle]+_amount;
        }else if(_ticketId == 5){
            require(_amount == ticket5,"Not Enough Ticket 5 Price");
            if(ticket5Time==0){
                ticket5Time = block.timestamp;
            }
            ticket5Collection[ticket5Cycle] = ticket5Collection[ticket5Cycle]+_amount;
        }else if(_ticketId == 6){
            require(_amount == ticket6,"Not Enough Ticket 6 Price");
            if(ticket6Time==0){
                ticket6Time = block.timestamp;
            }
            ticket6Collection[ticket6Cycle] = ticket6Collection[ticket6Cycle]+_amount;
        }else if(_ticketId == 7){
            require(_amount == ticket7,"Not Enough Ticket 7 Price");
            if(ticket7Time==0){
                ticket7Time = block.timestamp;
            }
            ticket7Collection[ticket7Cycle] = ticket7Collection[ticket7Cycle]+_amount;
        }else if(_ticketId == 8){
            require(_amount == ticket8,"Not Enough Ticket 8 Price");
            if(ticket8Time==0){
                ticket8Time = block.timestamp;
            }
            ticket8Collection[ticket8Cycle] = ticket8Collection[ticket8Cycle]+_amount;
        }
        
    }

    function ticketCheckAgent(uint256 _ticketId, uint256 _amount) internal {
        if(_ticketId == 1){
            require(_amount == ticket1.sub(ticket1.mul(agentDiscount).div(100)),"Not Enough Ticket 1 Price");
            if(ticket1Time==0){
                ticket1Time = block.timestamp;
            }
            ticket1Collection[ticket1Cycle] = ticket1Collection[ticket1Cycle]+_amount;
        }else if(_ticketId == 2){
            require(_amount == ticket2.sub(ticket2.mul(agentDiscount).div(100)),"Not Enough Ticket 2 Price");
            if(ticket2Time==0){
                ticket2Time = block.timestamp;
            }
            ticket2Collection[ticket2Cycle] = ticket2Collection[ticket2Cycle]+_amount;
        }else if(_ticketId == 3){
            require(_amount == ticket3.sub(ticket3.mul(agentDiscount).div(100)),"Not Enough Ticket 3 Price");
            if(ticket3Time==0){
                ticket3Time = block.timestamp;
            }
            ticket3Collection[ticket3Cycle] = ticket3Collection[ticket3Cycle]+_amount;
        }else if(_ticketId == 4){
            require(_amount == ticket4.sub(ticket4.mul(agentDiscount).div(100)),"Not Enough Ticket 4 Price");
            if(ticket4Time==0){
                ticket4Time = block.timestamp;
            }
            ticket4Collection[ticket4Cycle] = ticket4Collection[ticket4Cycle]+_amount;
        }else if(_ticketId == 5){
            require(_amount == ticket5.sub(ticket5.mul(agentDiscount).div(100)),"Not Enough Ticket 5 Price");
            if(ticket5Time==0){
                ticket5Time = block.timestamp;
            }
            ticket5Collection[ticket5Cycle] = ticket5Collection[ticket5Cycle]+_amount;
        }else if(_ticketId == 6){
            require(_amount == ticket6.sub(ticket6.mul(agentDiscount).div(100)),"Not Enough Ticket 6 Price");
            if(ticket6Time==0){
                ticket6Time = block.timestamp;
            }
            ticket6Collection[ticket6Cycle] = ticket6Collection[ticket6Cycle]+_amount;
        }else if(_ticketId == 7){
            require(_amount == ticket7.sub(ticket7.mul(agentDiscount).div(100)),"Not Enough Ticket 7 Price");
            if(ticket7Time==0){
                ticket7Time = block.timestamp;
            }
            ticket7Collection[ticket7Cycle] = ticket7Collection[ticket7Cycle]+_amount;
        }else if(_ticketId == 8){
            require(_amount == ticket8.sub(ticket8.mul(agentDiscount).div(100)),"Not Enough Ticket 8 Price");
            if(ticket8Time==0){
                ticket8Time = block.timestamp;
            }
            ticket8Collection[ticket8Cycle] = ticket8Collection[ticket8Cycle]+_amount;
        }
        
    }

    function claimWinningAmount(uint256 _contest, uint256 _cycle) external {
        User storage user = users[msg.sender];

        if(_contest == 1){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket1Result[_cycle] && !ticket1Claimed[_cycle]){
                    uint256 WinningAmount = ticket1Collection[_cycle].mul(70).div(100);
                    IERC20(tokenAddress).transfer(msg.sender,WinningAmount);
                    ticket1WinnersList[_cycle].push(msg.sender);
                    ticket1Claimed[_cycle]=true;
                }
            }
        }else if(_contest == 2){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket2Result[_cycle] && !ticket2Claimed[_cycle]){
                    uint256 WinningAmount = ticket2Collection[_cycle].mul(70).div(100);
                    IERC20(tokenAddress).transfer(msg.sender,WinningAmount);
                    ticket2WinnersList[_cycle].push(msg.sender);
                    ticket2Claimed[_cycle]=true;
                }
            }
        }if(_contest == 3){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket3Result[_cycle] && !ticket3Claimed[_cycle]){
                    uint256 WinningAmount = ticket3Collection[_cycle].mul(70).div(100);
                    IERC20(tokenAddress).transfer(msg.sender,WinningAmount);
                    ticket3WinnersList[_cycle].push(msg.sender);
                    ticket3Claimed[_cycle]=true;
                }
            }
        }if(_contest == 4){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket4Result[_cycle] && !ticket4Claimed[_cycle]){
                    uint256 WinningAmount = ticket4Collection[_cycle].mul(70).div(100);
                    IERC20(tokenAddress).transfer(msg.sender,WinningAmount);
                    ticket4WinnersList[_cycle].push(msg.sender);
                    ticket4Claimed[_cycle]=true;
                }
            }
        }if(_contest == 5){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket5Result[_cycle] && !ticket5Claimed[_cycle]){
                    uint256 WinningAmount = ticket5Collection[_cycle].mul(70).div(100);
                    IERC20(tokenAddress).transfer(msg.sender,WinningAmount);
                    ticket5WinnersList[_cycle].push(msg.sender);
                    ticket5Claimed[_cycle]=true;
                }
            }
        }if(_contest == 6){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket6Result[_cycle] && !ticket6Claimed[_cycle]){
                    uint256 WinningAmount = ticket6Collection[_cycle].mul(70).div(100);
                    IERC20(tokenAddress).transfer(msg.sender,WinningAmount);
                    ticket6WinnersList[_cycle].push(msg.sender);
                    ticket6Claimed[_cycle]=true;
                }
            }
        }if(_contest == 7){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket7Result[_cycle] && !ticket7Claimed[_cycle]){
                    uint256 WinningAmount = ticket7Collection[_cycle].mul(70).div(100);
                    IERC20(tokenAddress).transfer(msg.sender,WinningAmount);
                    ticket7WinnersList[_cycle].push(msg.sender);
                    ticket7Claimed[_cycle]=true;
                }
            }
        }if(_contest == 8){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket8Result[_cycle] && !ticket8Claimed[_cycle]){
                    uint256 WinningAmount = ticket8Collection[_cycle].mul(70).div(100);
                    IERC20(tokenAddress).transfer(msg.sender,WinningAmount);
                    ticket8WinnersList[_cycle].push(msg.sender);
                    ticket8Claimed[_cycle]=true;
                }
            }
        }
        
    }

    function claimWinningAmountAgent(uint256 _contest, uint256 _cycle,address _winnerAddress) external onlyOwner{
        User storage user = users[_winnerAddress];
    
        if(_contest == 1){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket1Result[_cycle] && !ticket1Claimed[_cycle]){
                    ticket1WinnersList[_cycle].push(_winnerAddress);
                    ticket1Claimed[_cycle]=true;
                }
            }
        }else if(_contest == 2){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket2Result[_cycle] && !ticket2Claimed[_cycle]){
                    ticket2WinnersList[_cycle].push(_winnerAddress);
                    ticket2Claimed[_cycle]=true;
                }
            }
        }if(_contest == 3){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket3Result[_cycle] && !ticket3Claimed[_cycle]){
                    ticket3WinnersList[_cycle].push(_winnerAddress);
                    ticket3Claimed[_cycle]=true;
                }
            }
        }if(_contest == 4){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket4Result[_cycle] && !ticket4Claimed[_cycle]){
                    
                    ticket4WinnersList[_cycle].push(_winnerAddress);
                    ticket4Claimed[_cycle]=true;
                }
            }
        }if(_contest == 5){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket5Result[_cycle] && !ticket5Claimed[_cycle]){
                    
                    ticket5WinnersList[_cycle].push(_winnerAddress);
                    ticket5Claimed[_cycle]=true;
                }
            }
        }if(_contest == 6){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket6Result[_cycle] && !ticket6Claimed[_cycle]){
                    
                    ticket6WinnersList[_cycle].push(_winnerAddress);
                    ticket6Claimed[_cycle]=true;
                }
            }
        }if(_contest == 7){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket7Result[_cycle] && !ticket7Claimed[_cycle]){
                    
                    ticket7WinnersList[_cycle].push(_winnerAddress);
                    ticket7Claimed[_cycle]=true;
                }
            }
        }if(_contest == 8){
            for(uint256 i=0; i<user.purchased.length;i++){
                if(user.purchased[i].cycle==_cycle && user.purchased[i].ticketid==ticket8Result[_cycle] && !ticket8Claimed[_cycle]){
                    
                    ticket8WinnersList[_cycle].push(_winnerAddress);
                    ticket8Claimed[_cycle]=true;
                }
            }
        }
        
    }


    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        randomResult = randomness.mod(100).add(1);
        address requestAddress = requestIdToAddress[requestId];
        uint256 requestNumber = requestIdToRequestNumberIndex[requestId];
        uint256 ticketId = ticketBrought[requestId];
        requestNumberToId[requestNumber] = requestAddress;

        fulfilTicket(ticketId,requestAddress,randomResult);

        userAddressToLastNumber[requestAddress].push(randomResult);
        emit LotteryOpened(randomResult, requestAddress);
        fulfilledCounter += 1;
        mintProgress[requestAddress] = false;
    }

    function fulfilTicket(uint256 _ticketId, address _requestAddress,uint256 _randomResult) internal {
        uint256 ticketCycle;
        if(_ticketId==1){
            if(block.timestamp > ticket1Time.add(ticket1Timeline)){
                ticket1Result[ticket1Cycle]=_randomResult;
                ticket1Cycle = ticket1Cycle.add(1);
                ticketCycle = ticket1Cycle;
            }else{
                ticketCycle = ticket1Cycle;
            }
        }
        else if(_ticketId==2){
            if(block.timestamp > ticket2Time.add(ticket2Timeline)){
                ticket2Result[ticket2Cycle]=_randomResult;
                ticket2Cycle = ticket2Cycle.add(1);
                ticketCycle = ticket2Cycle;
            }else{
                ticketCycle = ticket2Cycle;
            }
        }else if(_ticketId==3){
            if(block.timestamp > ticket3Time.add(ticket3Timeline)){
                ticket3Result[ticket3Cycle]=_randomResult;
                ticket3Cycle = ticket3Cycle.add(1);
                ticketCycle = ticket3Cycle;
            }else{
                ticketCycle = ticket3Cycle;
            }
        }else if(_ticketId==4){
            if(block.timestamp > ticket4Time.add(ticket4Timeline)){
                ticket4Result[ticket4Cycle]=_randomResult;
                ticket4Cycle = ticket4Cycle.add(1);
                ticketCycle = ticket4Cycle;
            }else{
                ticketCycle = ticket4Cycle;
            }
        }else if(_ticketId==5){
            if(block.timestamp > ticket5Time.add(ticket5Timeline)){
                ticket5Result[ticket5Cycle]=_randomResult;
                ticket5Cycle = ticket5Cycle.add(1);
                ticketCycle = ticket5Cycle;
            }else{
                ticketCycle = ticket5Cycle;
            }
        }else if(_ticketId==6){
            if(block.timestamp > ticket6Time.add(ticket6Timeline)){
                ticket6Result[ticket6Cycle]=_randomResult;
                ticket6Cycle = ticket6Cycle.add(1);
                ticketCycle = ticket6Cycle;
            }else{
                ticketCycle = ticket6Cycle;
            }
        }else if(_ticketId==7){
            if(block.timestamp > ticket7Time.add(ticket7Timeline)){
                ticket7Result[ticket7Cycle]=_randomResult;
                ticket7Cycle = ticket7Cycle.add(1);
                ticketCycle = ticket7Cycle;
            }else{
                ticketCycle = ticket7Cycle;
            }
        }else if(_ticketId==8){
            if(block.timestamp > ticket8Time.add(ticket8Timeline)){
                ticket8Result[ticket8Cycle]=_randomResult;
                ticket8Cycle = ticket8Cycle.add(1);
                ticketCycle = ticket8Cycle;
            }else{
                ticketCycle = ticket8Cycle;
            }
        }

        User storage user = users[_requestAddress];
        user.purchased.push(Purchased(_ticketId, ticketCycle, block.timestamp, _randomResult));
    }

   

    function withdrawToken(address _tokenAddress)
        external
        onlyOwner
        nonReentrant
        returns (bool)
    {
        require(_tokenAddress != address(0), "Should be a valid Address");
        require(
            IERC20(_tokenAddress).balanceOf(address(this)) > 0,
            "Not enough balance of the token mentioned"
        );
        require(
            IERC20(_tokenAddress).transfer(
                msg.sender,
                IERC20(_tokenAddress).balanceOf(address(this))
            ),
            "Transfer Failed"
        );
        return true;
    }

    function rescueBnb(address payable beneficiary)
        external
        nonReentrant
        nonZeroAddress(beneficiary)
        onlyOwner
    {
        require(address(this).balance > 0, "No Crypto inside contract");
        (bool success, ) = beneficiary.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

 
    function changeFeeCollector(address _newFeeCollector)
        external
        onlyOwner
        returns (bool)
    {
        feeCollector = _newFeeCollector;
        return true;
    }

    function viewFeeCollector() public view returns(address){
        return feeCollector;
    }

    function addAgent(address _AgentAddress) external onlyOwner{
        agentList.push(_AgentAddress);
        agent[_AgentAddress] = true;
    }

    function removeAgent(address _AgentAddress) external onlyOwner{
        agent[_AgentAddress] = false;
    }

    function removeAgentFromList(uint index) external onlyOwner{
        for(uint i = index; i < agentList.length-1; i++){
            agentList[i] = agentList[i+1];      
        }
        agentList.pop();
    }

    function getUserTicketsInfo(address userAddress) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
       
        User storage user = users[userAddress];
       
        uint256[] memory index  = new uint256[](user.purchased.length);
        uint256[] memory cycle  = new uint256[](user.purchased.length);
        uint256[] memory ticketnumber = new uint256[](user.purchased.length);
        uint256[] memory time = new uint256[](user.purchased.length);
        uint256[] memory ticketid = new uint256[](user.purchased.length);

        for (uint256 i=0; i< user.purchased.length; i++) {
            index[i]  = i;
            ticketid[i] = user.purchased[i].ticketid;
            cycle[i]  = user.purchased[i].cycle;
            time[i] = user.purchased[i].time;
            ticketnumber[i] = user.purchased[i].ticketnumber;
        }

       
        return
        (
            index,
            ticketid,
            cycle,
            time,
            ticketnumber
        );
    }

    function changePlatformFee(uint256 _newPlatformFee)
        external
        onlyOwner
        returns (bool)
    {
        platformFee = _newPlatformFee;
        return true;
    }

 
}
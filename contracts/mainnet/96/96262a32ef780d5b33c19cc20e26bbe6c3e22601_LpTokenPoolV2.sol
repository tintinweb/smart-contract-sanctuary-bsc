// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Ownable.sol";
import "./IERC20.sol";
import "./ReentrancyGuard.sol";


contract LpTokenPoolV2 is Ownable, ReentrancyGuard {

    event SetInvestCycle(address token, uint256 cycle, bool state);
    event MintedToken(address account, address token, uint256 amount, uint256 month, uint256 startTime);
    event Deposit(address account, address token, uint256 amount, uint256 month, uint256 startTime);
    event Withdraw(uint256 id, address account, uint256 amount, uint256 cycle, address token);
    event ReinventProfits(address account, uint256 amount, uint256 cycle, address token);


    uint256 private index = 1;
    uint256 internal constant thirtyDaysTime = 2592000;
    mapping(address => mapping(uint256 => bool)) public investCycle;
    address[] private allToken;
    mapping(address => mapping(address => Pledge[])) private tokenPledge;


    constructor() public {}

    struct Pledge {
        uint256 id;        
        uint256 cycle;     
        uint256 startTime;  
        uint256 amount;   
        address token;    
        uint256 isStop;    
    }


    function lpTokenSupply(address token) public view returns(uint256){
        return IERC20(token).balanceOf(address(this));
    }

    function setInvestCycle(address token, uint256 cycle, bool state) external onlyOwner {
        require(cycle > 0, "The cycle cannot be zero");
        investCycle[token][cycle] = state;
        allToken.push(token);
        emit SetInvestCycle(token, cycle, state);
    }

    function removeInvestCycle(address token, uint256 cycle) external onlyOwner {
        require(cycle > 0, "The cycle cannot be zero");
        delete investCycle[token][cycle];
    }

    function removePledgeToken(address token) external onlyOwner returns(bool, address) {
        bool isToken;
        address[] storage list = allToken;
        uint len = list.length;
        uint index_ = len;
        for (uint j; j < list.length; j++) {
            if (list[j] == token) {
                index_ = j;
                isToken = true;
                break;
            }
        }
        list[index_] = list[len - 1];
        list.pop();
        require(isToken, "token error");
        return (isToken, token);
    }

    function allPledgeToken() external view returns(address[] memory) {
        return allToken;
    }

    function minted(address token, address account, uint256 amount, uint256 startTime, uint256 investType) external onlyOwner {
        require(investCycle[token][investType], "The current staking cycle is suspended");
        require(account != address(0), "Cannot be zero address");
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success == true, "LP Token pledge failed");
        Pledge memory vars;
        vars.id = index++;
        vars.cycle = investType;
        vars.startTime = startTime;
        vars.amount = amount;
        vars.token = token;

        tokenPledge[account][token].push(vars);
        emit MintedToken(account, token, amount, investType, startTime);
    }

    function mintedBatch(address[] calldata account, uint256[] calldata amount, uint256[] calldata startTime, uint256 investType, address token) external onlyOwner{
        require(investCycle[token][investType], "The current staking cycle is suspended");
        require(account.length > 0, "Arrays length mismatch");
        uint totalAmount;
        for(uint i; i < amount.length; i++){
            totalAmount += amount[i];
        }

        bool success = IERC20(token).transferFrom(msg.sender, address(this), totalAmount);
        require(success == true, "LP Token pledge failed");

        Pledge memory vars;
        for(uint j; j < account.length; j++){
            vars.id = index++;
            vars.cycle = investType;
            vars.startTime = startTime[j];
            vars.amount = amount[j];
            vars.token = token;
            tokenPledge[account[j]][token].push(vars);

            emit MintedToken(account[j], token, amount[j], investType, startTime[j]);
        }
    }

    function deposit(address token, uint256 amount, uint256 investType) external nonReentrant {
        require(investCycle[token][investType], "The current staking cycle is suspended");
        require(amount > 0, "Must be greater than zero");
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success == true, "LP Token pledge failed");
        Pledge memory vars;
        vars.id = index++;
        vars.cycle = investType;
        vars.startTime = block.timestamp;
        vars.amount = amount;
        vars.token = token;

        tokenPledge[msg.sender][token].push(vars);

        emit Deposit(msg.sender, token, amount, investType, vars.startTime);
    }

    function withdraw(address token, uint256 id, uint256 investType) external nonReentrant returns(bool, uint256, address) {
        require(investCycle[token][investType], "The current staking cycle is suspended");
        address sender = msg.sender;
        Pledge[] memory order = tokenPledge[sender][token];
        require(order.length > 0, "No pledge order information");

        bool isId;
        uint256 lpAmount;
        for(uint i; i < order.length; i++){
            if(order[i].id == id && order[i].isStop == 0){
                uint256 expireDate = thirtyDaysTime * order[i].cycle + order[i].startTime;
                require(block.timestamp >= expireDate , "Token pledge redemption time has not yet arrived");
                IERC20(token).transfer(sender, order[i].amount);
                Pledge[] storage list = tokenPledge[sender][token];
                uint len = list.length;
                uint index_ = len;
                for (uint j; j < list.length; j++) {
                    if (list[j].id == id) {
                        index_ = j;
                        break;
                    }
                }
                list[index_] = list[len - 1];
                list.pop();

                isId = true;
                lpAmount = order[i].amount;
                break;
            }
        }
        require(isId, "The pledge order ID does not exist");

        emit Withdraw(id, sender, lpAmount, investType, token);

        return (isId, lpAmount, token);
    }

    function reinventProfits(address token, uint256 id, uint256 cycle) external nonReentrant returns(address, uint256, uint256) {
        require(investCycle[token][cycle], "The current staking cycle is suspended");
        address sender = msg.sender;
        Pledge[] storage order = tokenPledge[sender][token];
        require(order.length > 0, "No pledge order information");

        bool isId;
        uint256 lpAmount;
        //uint256 currentTime = block.timestamp;
        for(uint i; i < order.length; i++){
            if(order[i].id == id && order[i].isStop == 0){
                uint256 expireDate = thirtyDaysTime * order[i].cycle + order[i].startTime;
                require(block.timestamp >= expireDate , "Token pledge redemption time has not yet arrived");
                order[i].id = index++;
                order[i].cycle = cycle;
                order[i].startTime = block.timestamp;

                isId = true;
                lpAmount = order[i].amount;
                break;
            }
        }
        require(isId, "The pledge order ID does not exist");

        emit ReinventProfits(sender, lpAmount, cycle, token);

        return (token, lpAmount, cycle);
    }

    function allPledge(address account, address token) external view returns(address, uint256[][] memory){
        Pledge[] memory order = tokenPledge[account][token];

        uint256[][] memory orders = new uint256[][](order.length);
        uint256 currentTime = block.timestamp;
        for(uint i; i < order.length; i++){
            if(order[i].isStop == 0){
                uint256[] memory list = new uint256[](5);
                list[0] = order[i].id;
                list[1] = order[i].cycle;
                list[2] = order[i].startTime;
                list[3] = order[i].amount;
                list[4] = order[i].isStop;
                uint256 expireDate = thirtyDaysTime * order[i].cycle + order[i].startTime;
                if(currentTime >= expireDate){
                    list[4] = 1;
                }
                orders[i] = list;
            }
        }
        return (token, orders);
    }

}
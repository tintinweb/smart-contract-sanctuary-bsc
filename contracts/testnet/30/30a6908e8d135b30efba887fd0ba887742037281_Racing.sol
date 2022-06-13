/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

pragma solidity ^0.8.7;

//SPDX-License-Identifier: UNLICENSED

contract Racing {
    address public owner;

    uint256 public racIter = 0;

    mapping(uint256 => uint256) public horseOne;
    mapping(uint256 => uint256) public horseTwo;
    mapping(uint256 => uint256) public horseThree;
    mapping(uint256 => uint256) public horseFour;

    mapping(uint256 => uint256) public prices;
    mapping(uint256 => uint256) public winners;

    uint256 public numHourses;

    mapping(uint256 => uint256) public timeStampStart;
    mapping(uint256 => uint256) public timeStampStop;

    mapping(uint256 => mapping(address => uint256)) public bids;

    mapping(address => uint256) public balances;
    mapping(address => mapping(uint256 => uint256)) public userChoice;

    bool public racingEnded = true;

    constructor() {
        owner = msg.sender;
    }

    function startRacing()
        public          
    {
        require(racingEnded);
        racingEnded = false; 
        racIter++;

        numHourses = 0;
    }
    
    function setHorse(uint256 horseNum)
        public   
        payable        
    {
        require(!racingEnded);
        require(msg.value == 100000000);
        require(horseNum < 5 && horseNum > 0);
        require(userChoice[msg.sender][racIter] == 0);

        if(horseNum == 1)
        {
            require(horseOne[0] == horseOne[racIter]);
            horseOne[racIter] += 100000000;
        }
        if(horseNum == 2)
        {
            require(horseTwo[0] == horseTwo[racIter]);
            horseTwo[racIter] += 100000000;
        }
        if(horseNum == 3)
        {
            require(horseThree[0] == horseThree[racIter]);
            horseThree[racIter] += 100000000;
        }
        if(horseNum == 4)
        {
            require(horseFour[0] == horseFour[racIter]);
            horseFour[racIter] += 100000000;
        }
        numHourses++;        
        
        userChoice[msg.sender][racIter] = horseNum;
        bids[racIter][msg.sender] += 100000000; 

        if(numHourses == 4)
        {
            timeStampStart[racIter] = block.timestamp + (5 minutes);
            timeStampStop[racIter] = block.timestamp + (15 minutes);
        }
    }

    function deposit()
        public   
        payable        
    {
        balances[msg.sender] += msg.value;
    } 
    
    function withdraw(uint256 val)
        public 
    {
        require(racingEnded);
        require(balances[msg.sender] >= val);
        balances[msg.sender] -= val;
        (bool success, ) = msg.sender.call{value: (val * 90)/100}("");        
        require(success);
        (success, ) = owner.call{value: (val * 10)/100}("");        
        require(success);
    }

    function changeOwner(address newOwner ) public
    {
        require(msg.sender == owner);
        owner = newOwner;
    }

    function buyTicket(uint256 horseNum)
        public
    {
        require(block.timestamp < timeStampStart[racIter]);
        require(!racingEnded);
        require(userChoice[msg.sender][racIter] == 0);
        require(balances[msg.sender] >= 50000000);
        bids[racIter][msg.sender] += 50000000;
        balances[msg.sender] -= 50000000;    

        userChoice[msg.sender][racIter] = horseNum;

        if(horseNum == 1)
           horseOne[racIter] += 50000000;    
        if(horseNum == 2)
           horseTwo[racIter] += 50000000;  
        if(horseNum == 3)
           horseThree[racIter] += 50000000;
        if(horseNum == 4)
            horseFour[racIter] += 50000000;        
    }

    function speedUp(uint256 val)
        public
    {
        require(block.timestamp > timeStampStart[racIter]);        
        require(block.timestamp < timeStampStop[racIter]);
        require(!racingEnded);
        require(balances[msg.sender] >= val && val >= 1000000);
        require(userChoice[msg.sender][racIter] > 0);

        uint horseNum = userChoice[msg.sender][racIter];
        
        if(horseNum == 1)
           horseOne[racIter] += val;    
        if(horseNum == 2)
           horseTwo[racIter] += val;  
        if(horseNum == 3)
           horseThree[racIter] += val;
        if(horseNum == 4)
            horseFour[racIter] += val;     

        bids[racIter][msg.sender] += val;
        balances[msg.sender] -= val;
    }

    function finish()
        public
    {       
        require(block.timestamp > timeStampStop[racIter]);
        require(!racingEnded);
        require(numHourses == 4);          

        uint256 max = 0;

        if(horseOne[racIter] > horseTwo[racIter])
        {
            if(horseOne[racIter] > horseThree[racIter])
            {
                if(horseOne[racIter] > horseFour[racIter])
                {
                    winners[racIter] = 1;
                    max = horseOne[racIter];
                }
                else
                {
                    winners[racIter] = 4;
                    max = horseFour[racIter];
                }
            }
            else
            {
                if(horseThree[racIter] > horseFour[racIter])
                {
                    winners[racIter] = 3;
                    max = horseThree[racIter];
                }
                else
                {
                    winners[racIter] = 4;
                    max = horseFour[racIter];
                }
            }
        }
        else
        {
            if(horseTwo[racIter] > horseThree[racIter])
            {
                if(horseTwo[racIter] > horseFour[racIter])
                {
                    winners[racIter] = 2;
                    max = horseTwo[racIter];
                }
                else
                {
                    winners[racIter] = 4;
                    max = horseFour[racIter];
                }
            }
            else
            {
                if(horseThree[racIter] > horseFour[racIter])
                {
                    winners[racIter] = 3;
                    max = horseThree[racIter];
                }
                else
                {
                    winners[racIter] = 4;
                    max = horseFour[racIter];
                }
            }
        }

        uint256 maxIter = 0;

        if(max == horseOne[racIter])
            maxIter++;
        if(max == horseTwo[racIter])
            maxIter++;
        if(max == horseThree[racIter])
            maxIter++;
        if(max == horseFour[racIter])
            maxIter++;

        if(maxIter > 1)
        {
            timeStampStart[racIter] = block.timestamp + (10 minutes);
        }

        prices[racIter] += horseOne[racIter];
        prices[racIter] += horseTwo[racIter];
        prices[racIter] += horseThree[racIter];
        prices[racIter] += horseFour[racIter];

        racingEnded = true;
    }

    function getPrices(uint256 val)
        public
    {
        require(userChoice[msg.sender][val] == winners[val]);
        

        uint256 h = 0;
        if(winners[val] == 1)
            h = horseOne[val];
        if(winners[val] == 2)
            h = horseTwo[val];
        if(winners[val] == 3)
            h = horseThree[val];
        if(winners[val] == 4)
            h = horseFour[val];

        balances[msg.sender] += (prices[val] * bids[val][msg.sender])/h;
        bids[val][msg.sender] = 0;
    }
}
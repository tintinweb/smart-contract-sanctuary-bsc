/**
 *Submitted for verification at BscScan.com on 2022-07-04
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

        timeStampStart[racIter] = block.timestamp + (10 minutes);
        timeStampStop[racIter] = block.timestamp + (20 minutes);
    }
    
    function withdraw(uint256 val)
        public 
    {
        require(balances[msg.sender] >= val);
        balances[msg.sender] -= val;
        (bool success, ) = msg.sender.call{value: ((val * 90)/100)}("");        
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
        payable
    {
        require(block.timestamp < timeStampStart[racIter]);
        require(!racingEnded);
        require(userChoice[msg.sender][racIter] == 0);
        require(msg.value >= 50000000000000000);
        require(horseNum <= 4);

        bids[racIter][msg.sender] += msg.value;  
        userChoice[msg.sender][racIter] = horseNum;

        if(horseNum == 1)
           horseOne[racIter] += msg.value;    
        if(horseNum == 2)
           horseTwo[racIter] += msg.value;  
        if(horseNum == 3)
           horseThree[racIter] += msg.value;
        if(horseNum == 4)
            horseFour[racIter] += msg.value;   
    }

    function speedUp()
        public
        payable
    {
        require(block.timestamp > timeStampStart[racIter]);        
        require(block.timestamp < timeStampStop[racIter]);
        require(!racingEnded);
        require(msg.value >= 10000000000000000);
        require(userChoice[msg.sender][racIter] > 0);
        
        uint256 val = msg.value;
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
    }

    function finish()
        public
    {       
        require(block.timestamp > timeStampStop[racIter]);
        require(!racingEnded);        

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
            winners[racIter] = 5;            
        
        prices[racIter] += horseOne[racIter];
        prices[racIter] += horseTwo[racIter];
        prices[racIter] += horseThree[racIter];
        prices[racIter] += horseFour[racIter];

        racingEnded = true;
        startRacing();                
    }

    function getPrices(uint256 val, bool withdrawBalance)
        public
    {
        require(userChoice[msg.sender][val] == winners[val] || winners[val] > 4);        

        uint256 h = 0;
        if(winners[val] == 1)
            h = horseOne[val];
        if(winners[val] == 2)
            h = horseTwo[val];
        if(winners[val] == 3)
            h = horseThree[val];
        if(winners[val] == 4)
            h = horseFour[val];
        if(winners[val] > 4)
            h = horseOne[val] + horseTwo[val] + horseThree[val] + horseFour[val];

        balances[msg.sender] += (prices[val] * bids[val][msg.sender])/h;
        bids[val][msg.sender] = 0;

        if(withdrawBalance)
            withdraw(balances[msg.sender]);
    }

    function getPrices(uint256[] memory vals, uint256 valSize, bool withdrawBalance)
        public
    {
        for(uint256 i = 0; i < valSize; i++)
        {
            uint256 val = vals[i];
            require(userChoice[msg.sender][val] == winners[val] || winners[val] > 4);         

            uint256 h = 0;
            if(winners[val] == 1)
                h = horseOne[val];
            if(winners[val] == 2)
                h = horseTwo[val];
            if(winners[val] == 3)
                h = horseThree[val];
            if(winners[val] == 4)
                h = horseFour[val];
            if(winners[val] > 4)
                h = horseOne[val] + horseTwo[val] + horseThree[val] + horseFour[val];

            balances[msg.sender] += (prices[val] * bids[val][msg.sender])/h;
            bids[val][msg.sender] = 0;            
        }        

        if(withdrawBalance)
            withdraw(balances[msg.sender]);
    }

    function getPrices(address a)
        public
        view
        returns (uint256[] memory result)
    {
        uint256 j = 0;
        for(uint256 i = 0; i < racIter; i++)
        {
            if((userChoice[a][i] == winners[i] || winners[i] > 4) && bids[i][a] > 0)
                j++;
        }

        result = new uint256[](j); 
        j = 0;  

        for(uint256 i = 0; i < racIter; i++)
        {
            if((userChoice[a][i] == winners[i] || winners[i] > 4) && bids[i][a] > 0)
                result[j++] = i;
        }

        return result;
    }
}
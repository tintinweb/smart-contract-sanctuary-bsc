/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// User will purchase our token and he is restricted to transfer tokens before 7 days otherwise tokens will be burnt.
// This contract implement the function which is taking amount user want to transfer
// and send back timeBard amount and inTime amount.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Test{

    uint timeBardLimit = 10;

    mapping (address => uint[]) public timesOf;
    mapping (address => mapping (uint => uint)) public tokensOfAt;
    mapping (address => uint) public balanceOf;
    
    
    function setData() external {

        // setting times to array.
        (uint first, uint second, uint third) = 
            (block.timestamp, block.timestamp + timeBardLimit, block.timestamp + timeBardLimit + 20);
        timesOf[msg.sender] = [first, second, third];

        // setting tokens against times.
        tokensOfAt[msg.sender][first] = 10;
        tokensOfAt[msg.sender][second] = 20;
        tokensOfAt[msg.sender][third] = 10;

        // setting total amount.
        balanceOf[msg.sender] = 10 + 20 + 10;
    }

    function getData() external view returns (uint[] memory){
        return timesOf[msg.sender];
    }




    function checkTimeBardAndIntimeAmount(address _sender, uint amount) public
        returns (uint timeBardAmount, uint inTimeAmount){

            require(balanceOf[msg.sender] >= amount, "You don't have enough amount");
            
            uint[] storage times = timesOf[_sender];
            uint currentTime = block.timestamp;
            
            for(uint i; i < times.length; i++){
                if(times[i] == 0) {
                    continue;
                }

                else{
                    uint lastTimeTokens = tokensOfAt[_sender][times[i]];

                    if(times[i] <= currentTime - timeBardLimit){    // if time passed
                
                        if(amount < lastTimeTokens){    // if amount < lastData
                            timeBardAmount += amount;
                            tokensOfAt[_sender][times[i]] -= amount;
                            break;
                        }
                        else{     // if amount >= lastData
                            timeBardAmount += lastTimeTokens;
                            delete tokensOfAt[_sender][times[i]];
                            delete times[i];
                            if(amount > lastTimeTokens){
                                amount -= lastTimeTokens;
                            }
                            else{
                                break;
                            }
                        }
                    }
                
                    else{   // if time didn't passed
                
                        if(amount < lastTimeTokens){
                            inTimeAmount += amount;
                            tokensOfAt[_sender][times[i]] -= amount;
                            break;
                        }
                        else{
                            inTimeAmount += lastTimeTokens;
                            delete tokensOfAt[_sender][times[i]];
                            delete times[i];
                            if(amount > lastTimeTokens){
                                amount -= lastTimeTokens;
                            }
                            else{
                                break;
                            }
                        }
                    }
                }
            }

    }
}
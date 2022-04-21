/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

pragma solidity ^0.8.0;
contract KillahVoting {
    uint16 public score1 = 0;
    uint16 public score2 = 0;
    uint16 public score3 = 0;
    uint16 public score4 = 0;
    uint16 public score5 = 0;

    function voteUp (uint16 agentNumber) public {

        if(agentNumber == 1){
            score1 = score1 +1;
        }
        if(agentNumber == 2){
            score2 = score2 + 1;
        }
        if(agentNumber == 3){
            score3 = score3 + 1;
        }        
        if(agentNumber == 4){
            score4 = score4 + 1;
        }
        if(agentNumber == 5){
            score5 = score5 + 1;
        }            
    }

    function voteDown (uint16 agentNumber) public {
        if(agentNumber == 1 && score1 > 0 ){
            score1 = score1 - 1;
        }
        if(agentNumber == 2 && score2 > 0){
            score2 = score2 - 1;
        }
        if(agentNumber == 3 && score3 > 0){
            score3 = score3 - 1;
        }        
        if(agentNumber == 4 && score4 > 0){
            score4 = score4 - 1;
        }
        if(agentNumber == 5 && score5 > 0){
            score5 = score5 - 1;
        }                
    }

}
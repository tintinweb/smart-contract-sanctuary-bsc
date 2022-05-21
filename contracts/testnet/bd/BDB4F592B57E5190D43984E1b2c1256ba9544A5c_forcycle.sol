/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity =0.8.9;  
    

contract forcycle {
    address[] public farmers;
    uint256 public currentIndex;
    uint256 public _pendingRewards;
    mapping(address => uint256) public deposit_time;
    mapping(address => uint256) public pendingRewards;
    mapping(address => bool) public farm_active;

    function addfarmers(address[] calldata _farmers) external {
        for(uint i=0; i < _farmers.length; i++){
           farmers.push(_farmers[i]);
        }
        farm_active[msg.sender] = true;
        sync_earnings(500000);
    }


    // sync is deposit time != 0 allora fai aggiornamento. Messaggio errore fare aggiornamento.
    /*function sync_earnings(uint256 gas) public {
        uint256 shareholderCount = farmers.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 _balance = 10;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
            deposit_time[farmers[currentIndex]] = block.timestamp;
            pendingRewards[farmers[currentIndex]] += _balance;
        gasUsed = gasUsed + gasLeft - gasleft();
        gasLeft = gasleft();
        currentIndex++;
        iterations++;
        }
    }
}

    // sync is deposit time != 0 allora fai aggiornamento. Messaggio errore fare aggiornamento.
    function sync_earnings(uint256 gas) public {
        uint256 shareholderCount = farmers.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 _balance = 10;

        for(uint i = 0; i < shareholderCount; i++) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            deposit_time[farmers[currentIndex]] = block.timestamp;
            pendingRewards[farmers[currentIndex]] += _balance;
         
            gasUsed = gasUsed + gasLeft - gasleft();
            gasLeft = gasleft();
            currentIndex++;
            if(gasUsed >= gas)
            break;
        }
    }
}*/


    // sync is deposit time != 0 allora fai aggiornamento. Messaggio errore fare aggiornamento.
    function sync_earnings(uint256 gas) public {
        uint256 shareholderCount = farmers.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 _balance = 0;

        for(uint i = 0; i < shareholderCount; i++) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(farm_active[farmers[currentIndex]]){
                _pendingRewards += _balance;

                deposit_time[farmers[currentIndex]] = block.timestamp;
                pendingRewards[farmers[currentIndex]] += _balance;
            }
            
            gasUsed = gasUsed + gasLeft - gasleft();
            gasLeft = gasleft();
            currentIndex++;
            if(gasUsed >= gas)
            break;
        }
    }
}
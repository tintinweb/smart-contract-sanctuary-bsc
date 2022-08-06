/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

pragma solidity ^0.8.13;


//libraries


struct Deposit {
    uint256 txtime;
    uint256 txamt;
    uint256 txid;
    uint256 txAvail;
    uint256 txClaimed;
    uint256 txlastClaim;
    uint256 txMax;
    address txref;
    bool txExpire;
}

struct User {
    uint256 totalDeps;
    uint256 totalWithdrawn;
    uint256 totalClaimable;
    uint256 totalClaimed;
    uint256 totalWithdrawable;
    uint256 totalRefClaimable;
    uint256 lastWithdraw;
    uint256 totalAssets;
    uint256 txCount;
    Deposit [] depositsArr;
}

contract aDonis {

    uint256 devFee; 
    uint256 projFee;
    uint256 refFee;
    uint256 dailyEarn; //[]

    mapping (address => User) public Users;
    mapping (address => uint256) public Whitelist;

    function MakeDeposit(uint256 amtx, address reffy) public {
        User storage user = Users[msg.sender];
        User storage refUser = Users[reffy];
        uint256 firstlaunchTime = 589034509435;
        uint256 secondlaunchTime = 589034509435;
        uint256 nowTime = block.timestamp;

        require (secondlaunchTime < nowTime || Whitelist[msg.sender] == 1);
        require (firstlaunchTime < nowTime);

        user.totalDeps += amtx;
        user.totalAssets += amtx * 5;

        user.depositsArr.push(Deposit({
            txtime: uint256(block.timestamp),
            txamt: amtx,
            txid: user.txCount,
            txAvail: amtx * 5,
            txClaimed: 0,
            txlastClaim: uint256(block.timestamp),
            txMax: amtx * 5,
            txref: reffy,
            txExpire: false
            
        }));

        uint256 refAmt = amtx * 80 / 1000;
        refUser.totalRefClaimable += refAmt;

    }

    function MakeClaim() public {
        User storage user = Users[msg.sender];
        uint256 tempClaimable;
        
        for (uint256 i = 0; i < user.depositsArr.length; i++){
            Deposit storage eachDep = user.depositsArr[i];
            uint256 rn = block.timestamp;
            if (eachDep.txAvail > 0){
                if (rn - eachDep.txlastClaim > 86400){
                    uint256 dailyAcquire = eachDep.txamt * dailyEarn /1000;
                    tempClaimable += dailyAcquire;
                    eachDep.txAvail -= tempClaimable;
                    eachDep.txlastClaim = block.timestamp;
                }
            }
        }

        user.totalClaimable += tempClaimable;
    }

    function MakeWithdraw() public {
        User storage user = Users[msg.sender];
        uint256 rn = block.timestamp;
        require(rn - user.lastWithdraw > 604800);
        uint256 transferAmt = user.totalClaimable /2;
        user.totalClaimable = user.totalClaimable /2;
        user.totalWithdrawn += transferAmt;
        user.lastWithdraw = block.timestamp;
        // BUSD.safeTransfer(transferAmt);
        
    }

    function MakeRefWithdraw() public {
        User storage user = Users[msg.sender];
        require (user.totalRefClaimable > 0);
        // uint256 transferAmt = user.totalRefClaimable;
        user.totalRefClaimable = 0;
        // BUSD.safeTransfer(transferAmt);
        }

    function EmergencyWithdraw() public {
        User storage user = Users[msg.sender];
        uint256 itemCounter; 

        require (user.totalAssets / 10 >= user.totalWithdrawn);
        
        uint256 diff = user.totalAssets / 10 - user.totalWithdrawn;

        for (uint256 i = 0; i < user.depositsArr.length; i++){
            Deposit storage eachDep = user.depositsArr[i];
            if (eachDep.txAvail > 0){
                itemCounter +=1;
            }
        }

        uint256 minusAmt = diff / itemCounter;
        
        for (uint256 i = 0; i < user.depositsArr.length; i++){
            Deposit storage eachDep = user.depositsArr[i];
            eachDep.txAvail -= minusAmt;
        
        // BUSD.safeTransfer(diff);    

        }
        
    }

    function whiteListSignup(uint256 amtz) public {
        require(amtz > 10);
        uint256 nowTime = block.timestamp;
        require (nowTime < 38490832904);
        Whitelist[msg.sender] = 1;
    }

}
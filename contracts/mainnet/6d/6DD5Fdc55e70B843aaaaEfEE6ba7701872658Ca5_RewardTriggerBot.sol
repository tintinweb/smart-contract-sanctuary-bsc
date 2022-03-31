/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IDistribute {
    function distribute() external;
}
interface ISAS {
    function sellAllSurges() external;
}
interface ISAAD {
    function sellAllAndDeliver() external;
}
interface ITreasury {
    function deliver() external;
}
interface IStrategy {
    function deliverAndTrigger() external;
    function claimAll() external;
    function distributeRewards() external;
}
interface ILoanContract {
    function claimRewardAndDeliver() external;
}
contract RewardTriggerBot {

    address[] public triggers;
    address public owner;

    ITreasury treasury             = ITreasury(0x208D864Ef3852eF7DD0A41564A306f0b1D954163);
    IStrategy strategy             = IStrategy(0xf635526DBc516159A04d134134EB05C0Ab476315);

    IDistribute surgeTokenReceiver = IDistribute(0x205ab1f1746cB09d52b71229f6C82B412018e6Ef);
    IDistribute farmManager        = IDistribute(0xdcfAdDC8028CE55082c2Cb9C0475Df82AfDba2F8);

    ISAS paymentReceiver           = ISAS(0x7cf62d3ff3ec16c4dC00d680C6ea7ecc90CC69d3 );
    ISAAD xusdCollector            = ISAAD(0x34d22e7E94CC6122a795FF4BA92c9Bff15a705B8);

    ILoanContract pcsStaker        = ILoanContract(0x05fcF684da7CDFD625540873Bfa4E6D446baca5b);
    ILoanContract gnlFarmer        = ILoanContract(0x2aebC340fEf013ddFb611700D427252AFC21c96a);


    constructor() {
        owner = msg.sender;
    }

    function trigger() external {
        surgeTokenReceiver.distribute();
        farmManager.distribute();
        paymentReceiver.sellAllSurges();
        xusdCollector.sellAllAndDeliver();
        treasury.deliver();
        strategy.deliverAndTrigger();
        strategy.claimAll();
        pcsStaker.claimRewardAndDeliver();
        gnlFarmer.claimRewardAndDeliver();
        treasury.deliver();
        strategy.distributeRewards();
    }

    function triggerPaymentReceivers() external {
        surgeTokenReceiver.distribute();
        xusdCollector.sellAllAndDeliver();
        paymentReceiver.sellAllSurges();
        farmManager.distribute();
    }

    function triggerTreasury() external {
        treasury.deliver();
        strategy.deliverAndTrigger();
        strategy.claimAll();

        pcsStaker.claimRewardAndDeliver();
        gnlFarmer.claimRewardAndDeliver();

        treasury.deliver();
        strategy.distributeRewards();
    }

    function withdraw() external {
        require(msg.sender == owner);
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    receive() external payable{}
}
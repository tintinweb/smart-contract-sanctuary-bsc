/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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
    function distributeAndTrigger() external;
    function claimAll() external;
    function distributeRewards() external;
}

contract RewardTriggerBot {

    ITreasury treasury             = ITreasury(0x208D864Ef3852eF7DD0A41564A306f0b1D954163);
    IStrategy strategy             = IStrategy(0xC85109e3Ca9574fD373948B882E3ddCfacbf6Fbe);

    IDistribute surgeTokenReceiver = IDistribute(0x205ab1f1746cB09d52b71229f6C82B412018e6Ef);
    IDistribute farmManager        = IDistribute(0xdcfAdDC8028CE55082c2Cb9C0475Df82AfDba2F8);

    ISAS paymentReceiver           = ISAS(0x6A1fbb59Bf94F1Fb4614C1ebB4caF0f062ac144a);
    ISAAD xusdCollector            = ISAAD(0x34d22e7E94CC6122a795FF4BA92c9Bff15a705B8);

    function trigger() external {
        triggerPaymentReceivers();
        triggerTreasury();
    }

    function triggerPaymentReceivers() public {
        surgeTokenReceiver.distribute();
        xusdCollector.sellAllAndDeliver();
        paymentReceiver.sellAllSurges();
        farmManager.distribute();
    }

    function triggerTreasury() public {
        treasury.deliver();
        strategy.distributeAndTrigger();
        strategy.claimAll();
        treasury.deliver();
        strategy.distributeRewards();
    }

}
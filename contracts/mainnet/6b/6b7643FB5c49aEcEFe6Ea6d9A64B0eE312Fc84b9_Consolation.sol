// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MUTFarmAppData.sol";
import "./Lockable.sol";
import "./ConsolationWallet.sol";
import "./ModuleBase.sol";

contract Consolation is Lockable, ModuleBase {

    constructor(address _auth, address _mgr) ModuleBase(_auth, _mgr) {
    }

    function claimPrize(uint32 roundNumber) external lock {
        require(MUTFarmAppData(moduleMgr.getModuleAppData()).isRoundExists(roundNumber), "round not exists");
        require(MUTFarmAppData(moduleMgr.getModuleAppData()).isRoundStop(roundNumber), "round not stop");
        require(MUTFarmAppData(moduleMgr.getModuleAppData()).isUserSeedExists(roundNumber, msg.sender), "no prize to claim");
        require(!ConsolationWallet(moduleMgr.getModuleConsolationWallet()).prizeClaimed(msg.sender, roundNumber), "Consolaten");
        (, , , uint256 _totalAmount, uint256 _soldAmount, , , ) = MUTFarmAppData(moduleMgr.getModuleAppData()).getSeedUserData(roundNumber, msg.sender);
        uint256 amount = _totalAmount - _soldAmount;
        ConsolationWallet(moduleMgr.getModuleConsolationWallet()).transferToken(ssAuth.getFarmToken(), msg.sender, amount);
        ConsolationWallet(moduleMgr.getModuleConsolationWallet()).setClaimed(msg.sender, roundNumber);
    }

    function prizeClaimed(address account, uint256 roundNumber) external view returns (bool res) {
        res = ConsolationWallet(moduleMgr.getModuleConsolationWallet()).prizeClaimed(account, roundNumber);
    }
}
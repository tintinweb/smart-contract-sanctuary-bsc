// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ModuleBase.sol";
import "./Lockable.sol";
import "./AppWallet.sol";
import "./NFTFarmLand.sol";
import "./PairPrice.sol";
import "./SystemSetting.sol";
import "./ECDSA.sol";
import "./UtopiaFarmAppData.sol";

contract UtopiaFarmApp is ModuleBase, Lockable, SafeMath, ECDSA {

    address private signer;

    event seedSowed(address account, uint256 amount, uint256 sowId, uint32 roundIndex, uint time);
    event seedClaimed(address account, uint256 amoun, uint32 roundIndex, uint time);

    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {

    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    function getSigner() external view returns (address res) {
        res = signer;
    }

    function sowSeed(uint256 amount, uint256 withRewardAmount, uint256 sowId, bytes memory signature) external lock {
        _sowSeed(msg.sender, amount, withRewardAmount, sowId, signature);
    }

    function _sowSeed(address account, uint256 amount, uint256 withRewardAmount, uint256 sowId, bytes memory signature) internal {

        string memory message = string(abi.encodePacked(Strings.addressToString(account), 
                                                        Strings.uint256ToString(amount), 
                                                        Strings.uint256ToString(withRewardAmount),
                                                        Strings.uint256ToString(sowId)
                                                    ));
        require(_IsSignValid(message, signature), "invalid signature");
        require(!UtopiaFarmAppData(moduleMgr.getUtopiaFarmAppData()).isSowIdUsed(sowId), "dulplicated sowid");
        require(UtopiaFarmAppData(moduleMgr.getUtopiaFarmAppData()).isUserSowing(msg.sender), "u'd sowed");

        uint useAmount = amount + withRewardAmount;
        uint256 usdtAmount = PairPrice(moduleMgr.getPairPrice()).cumulateUSDTAmountOut(useAmount);

        require(ERC20(auth.getFarmToken()).balanceOf(account) >= amount, "insufficient UTO");
        require(ERC20(auth.getFarmToken()).allowance(account, address(this)) >= amount, "UTO not approved");
        
        require(ERC20(auth.getFarmToken()).transferFrom(account, moduleMgr.getAppWallet(), amount), "sowSeed error 1");

        UtopiaFarmAppData(moduleMgr.getUtopiaFarmAppData()).increaseRoundNumber(1);
        uint32 roundIndex = UtopiaFarmAppData(moduleMgr.getUtopiaFarmAppData()).getCurrentRoundNumber();
        
        UtopiaFarmAppData(moduleMgr.getUtopiaFarmAppData()).newSowData(
            roundIndex,
            sowId,
            account, 
            useAmount, 
            withRewardAmount,
            usdtAmount,
            block.timestamp, 
            SystemSetting(moduleMgr.getSystemSetting()).getCurrentSettingIndex()
        );


        UtopiaFarmAppData(moduleMgr.getUtopiaFarmAppData()).setUserSowData(account, roundIndex);
        UtopiaFarmAppData(moduleMgr.getUtopiaFarmAppData()).setSowIdUsed(sowId);

        emit seedSowed(account, useAmount, sowId, roundIndex, block.timestamp);
    }

    function _IsSignValid(string memory message, bytes memory signature) private view returns(bool) {
        return signer == recover(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    Strings.toString(bytes(message).length),
                    message
                )
            ),
            signature
        );
    }

    function claimedSeed() external lock {
        (bool res, , uint256 outAmount) = UtopiaFarmAppData(moduleMgr.getUtopiaFarmAppData()).checkMatured(msg.sender);
        require(res, "have no matured seed");
        uint32 _roundIndex = UtopiaFarmAppData(moduleMgr.getUtopiaFarmAppData()).getUserCurrentRoundIndex(msg.sender);
        require(AppWallet(moduleMgr.getAppWallet()).transferToken(auth.getFarmToken(), msg.sender, outAmount), "claimedSeed error 1");
        UtopiaFarmAppData(moduleMgr.getUtopiaFarmAppData()).deleteUserSowData(msg.sender);
        emit seedClaimed(msg.sender, outAmount, _roundIndex, block.timestamp);
    }

}
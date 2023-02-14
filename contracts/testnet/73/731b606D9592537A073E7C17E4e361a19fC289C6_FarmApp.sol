// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ModuleBase.sol";
import "./Lockable.sol";
import "./WithdrawWallet.sol";
import "./PairPrice.sol";
import "./ECDSA.sol";
import "./FarmAppData.sol";

contract FarmApp is ModuleBase, Lockable, SafeMath, ECDSA {

    address internal signer;

    uint256 public sysMatureTime;
    uint256 public sysProfitRate;

    event seedSowed(uint256 sowId, uint32 roundIndex);
    event seedClaimed(uint256 amount);
    
    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {
        sysMatureTime = 864000;
        sysProfitRate = 70;
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    function getSigner() external view returns (address res) {
        res = signer;
    }

    function setSysMatureTime(uint256 to) external onlyOwner {
        sysMatureTime = to;
    }

    function setSysProfitRate(uint256 to) external onlyOwner {
        sysProfitRate = to;
    }

    function sowSeed(uint256 amount, uint32 sowId, uint256 matureTime, uint256 profitPercent, bytes memory signature) external lock {
        require(auth.getEnable(), "stopped");
        _sowSeed(msg.sender, amount, sowId, matureTime, profitPercent, signature);
    }

    function _sowSeed(address account, uint256 amount, uint32 sowId, uint256 matureTime, uint256 profitPercent, bytes memory signature) internal {

        string memory message = string(abi.encodePacked(Strings.addressToString(account), 
                                                        "-",
                                                        Strings.uint256ToString(amount), 
                                                        "-",
                                                        Strings.uint256ToString(sowId),
                                                        "-",
                                                        Strings.uint256ToString(matureTime),
                                                        "-",
                                                        Strings.uint256ToString(profitPercent)
                                                    ));
        require(_IsSignValid(message, signature), "invalid signature");
        require(matureTime == 864000, "mature time error");
        require(profitPercent == 70, "rate error");
        require(FarmAppData(moduleMgr.getFarmAppData()).getSowStatus(sowId) == 0, "dulplicated sowid");

        require(IERC20(auth.getFarmToken()).balanceOf(account) >= amount, "insufficient MMT");
        require(IERC20(auth.getFarmToken()).allowance(account, address(this)) >= amount, "MMT not approved");

        uint256 usdtAmount = PairPrice(moduleMgr.getPairPrice()).cumulateUSDTAmountOut(amount);

        FarmAppData(moduleMgr.getFarmAppData()).increaseRoundNumber(1);
        uint32 roundIndex = FarmAppData(moduleMgr.getFarmAppData()).getCurrentRoundNumber();
        
        FarmAppData(moduleMgr.getFarmAppData()).newSowData(
            roundIndex,
            sowId,
            account, 
            amount, 
            usdtAmount,
            matureTime,
            profitPercent,
            block.timestamp
        );
        FarmAppData(moduleMgr.getFarmAppData()).setSowStatus(sowId, 1);

        require(IERC20(auth.getFarmToken()).transferFrom(account, moduleMgr.getDepositWallet(), amount), "sowSeed error 1");

        emit seedSowed(sowId, roundIndex);
    }

    function _IsSignValid(string memory message, bytes memory signature) internal view returns(bool) {
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

    function claimedSeed(uint32 sowId) external lock {
        require(auth.getEnable(), "stopped");
        require(msg.sender != address(0));
        uint8 status = FarmAppData(moduleMgr.getFarmAppData()).getSowStatus(sowId);
        require(status > 0 && status != 2, "had claimed");
        (bool res, , uint256 outAmount) = FarmAppData(moduleMgr.getFarmAppData()).checkMatured(msg.sender, sowId);
        require(res, "have no matured seed");
        FarmAppData(moduleMgr.getFarmAppData()).setSowStatus(sowId, 2);
        require(WithdrawWallet(moduleMgr.getWithdrawWallet()).transferToken(auth.getFarmToken(), msg.sender, outAmount), "claimedSeed error 1");
        emit seedClaimed(outAmount);
    }

    function claimedSeed(uint32 sowId, uint256 shortenTime, bytes memory signature) external lock {
        require(auth.getEnable(), "stopped");
        require(msg.sender != address(0));
        string memory message = string(abi.encodePacked(Strings.addressToString(msg.sender),
                                                        "-",
                                                        Strings.uint256ToString(sowId),
                                                        "-",
                                                        Strings.uint256ToString(shortenTime)
                                                    ));
        require(_IsSignValid(message, signature), "invalid signature");

        uint8 status = FarmAppData(moduleMgr.getFarmAppData()).getSowStatus(sowId);
        require(status > 0 && status != 2, "had claimed");
        (bool res, , uint256 outAmount) = FarmAppData(moduleMgr.getFarmAppData()).checkMatured(msg.sender, sowId, shortenTime, signature);
        require(res, "have no matured seed");
        FarmAppData(moduleMgr.getFarmAppData()).setSowStatus(sowId, 2);
        require(WithdrawWallet(moduleMgr.getWithdrawWallet()).transferToken(auth.getFarmToken(), msg.sender, outAmount), "claimedSeed error 1");
        emit seedClaimed(outAmount);
    }

    function withdrawMyToken(address token, uint256 amount, uint32 withdrawId, bytes memory signature)
    external lock {
        require(auth.getEnable(), "stopped");
        string memory message = string(abi.encodePacked(Strings.addressToString(msg.sender), 
                                                        "-",
                                                        Strings.addressToString(token), 
                                                        "-",
                                                        Strings.uint256ToString(amount),
                                                        "-",
                                                        Strings.uint256ToString(withdrawId)
                                                    ));
        require(_IsSignValid(message, signature), "invalid signature");
        require(!FarmAppData(moduleMgr.getFarmAppData()).getWithdrawStatus(withdrawId), "withdrawed");
        uint256 usdtValue = PairPrice(moduleMgr.getPairPrice()).cumulateUSDTAmountIn(amount);
        require(!FarmAppData(moduleMgr.getFarmAppData()).triggerWithdrawLimit(msg.sender, usdtValue), "amount limit");
        FarmAppData(moduleMgr.getFarmAppData()).setWithdrawData(withdrawId, msg.sender, amount, usdtValue);
        require(WithdrawWallet(moduleMgr.getWithdrawWallet()).transferToken(token, msg.sender, amount), "withdrawMyToken error 1");
    }
}
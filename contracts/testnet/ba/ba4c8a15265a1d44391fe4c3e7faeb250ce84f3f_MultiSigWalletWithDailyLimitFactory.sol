//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Factory.sol";
import "./MultiSigWalletWithDailyLimit.sol";
contract MultiSigWalletWithDailyLimitFactory is Factory {
    MultiSigWallet multiSigWallet;
    function create(address[] memory _owners,uint8[] memory _ownerGroups, uint8 _group, uint8 _required,uint8[][] memory _memberRequired, uint _dailyLimit)
    public
    returns (address)
    {
        multiSigWallet = new MultiSigWalletWithDailyLimit(_owners,_ownerGroups,_group, _required,_memberRequired, _dailyLimit);
        register(address(multiSigWallet));
        return address(multiSigWallet);
    }
}
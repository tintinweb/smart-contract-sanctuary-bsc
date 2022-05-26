/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract EncodeGuardHelperContract {
       
    function getBytesofSalt(uint salt) pure public returns(bytes32) {
        return bytes32(salt);
    }

    function excludeFromReward(address account) pure public returns(bytes memory) {
        return abi.encodeWithSignature("excludeFromReward(address)", account);
    }

    function includeInReward(address account) pure public returns(bytes memory) {
        return abi.encodeWithSignature("includeInReward(address)", account);
    }

    function excludeFromFee(address account) pure public returns(bytes memory) {
        return abi.encodeWithSignature("excludeFromFee(address)", account);
    }

    function includeInFee(address account) pure public returns(bytes memory) {
        return abi.encodeWithSignature("includeInFee(address)", account);
    }

    function setTaxFeePercent(uint256 taxFee) pure public returns(bytes memory) {
        return abi.encodeWithSignature("setTaxFeePercent(uint256)", taxFee);
    }

    function setLiquidityFeePercent(uint256 liquidityFee) pure public returns(bytes memory) {
        return abi.encodeWithSignature("setLiquidityFeePercent(uint256)", liquidityFee);
    }

    function setBurnFeePercent(uint256 burnfee) pure public returns(bytes memory) {
        return abi.encodeWithSignature("setBurnFeePercent(uint256)", burnfee);
    }

    function setCharityFeePercent(uint256 charityfee) pure public returns(bytes memory) {
        return abi.encodeWithSignature("setCharityFeePercent(uint256)", charityfee);
    }

    function setMaxTxPercent(uint256 maxTxPercent) pure public returns(bytes memory) {
        return abi.encodeWithSignature("setMaxTxPercent(uint256)", maxTxPercent);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) pure public returns(bytes memory) {
        return abi.encodeWithSignature("setSwapAndLiquifyEnabled(bool)", _enabled);
    }

    function addBlacklist(address _defaulter) pure public returns(bytes memory) {
        return abi.encodeWithSignature("addBlacklist(address)", _defaulter);
    }

    function removeBlackList(address _defaulter) pure public returns(bytes memory) {
        return abi.encodeWithSignature("removeBlackList(address)", _defaulter);
    }

    function changecharitywallet(address _newaddress) pure public returns(bytes memory) {
        return abi.encodeWithSignature("changecharitywallet(address)", _newaddress);
    }

    function migrateToken(address _newadress , uint256 _amount) pure public returns(bytes memory) {
        return abi.encodeWithSignature("migrateToken(address,uint256)", _newadress, _amount);
    }

    function migrateBnb(address _newadd,uint256 amount) pure public returns(bytes memory) {
        return abi.encodeWithSignature("migrateBnb(address,uint256)", _newadd, amount);
    }

    function transferOwnership(address newOwner) pure public returns(bytes memory) {
        return abi.encodeWithSignature("transferOwnership(address)", newOwner);
    }

    function updateDelay(uint256 newDelay) pure public returns(bytes memory) {
        return abi.encodeWithSignature("updateDelay(uint256)", newDelay);
    }

}
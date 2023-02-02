/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IMBPIDO {
    function getMinimumMBPHolding() external view returns (uint256);
    function getMaximumUsdBuyAmount() external view returns (uint256);
    function getTokensPerUSD() external view returns (uint256);
    function calcTokensToGet(uint256 _usd_amount) external view returns (uint256);
    function getMinimumInvestment() external view returns (uint256);
    function getHardCap() external view returns (uint256);
    function getSaleEnabled() external view returns (bool);
    function getClaimEnabled() external view returns (bool);
    function getRefundEnabled() external view returns (bool);
    function getVesting1Enabled() external view returns (bool);
    function getVesting2Enabled() external view returns (bool);
    function getVesting3Enabled() external view returns (bool);
    function getVesting4Enabled() external view returns (bool);
    function buyToken(address _investor, uint256 _usdAmount) external;
    function userInvestment(address _investor) external view returns (uint256);
    function getTotalInvested() external view returns (uint256);
    function claimToken(address _investor) external;
    function refund(address _investor) external;    
    function getUserReferralReward(address _investor) external view returns (uint256);
    function getRefRewardClaimed(address _investor) external view returns (bool);
    function getUserReferralCount(address _investor) external view returns (uint256);
    function getTotalReferralReward() external view returns (uint256);
    function getReferralPercentage() external view returns (uint256);
    function buyTokenReferral(address _investor, address referrer, uint256 _usdAmount) external;
    function claimReferralUsd(address _investor) external returns (bool);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MobiPadRouter is Context, Ownable {
    using SafeMath for uint256;

    mapping(address => bool) private IS_IDO_CONTRACT;
    mapping(address => address) private IDO_ADDRESS;
    address[] private ADDRESSES;

    address payable WITHDRAWAL_ADDRESS = 0x014c0fBf5E488cf81876EC350b2Aff32F35C4263;// TODO

    function addIdoContract(address ido_contract) external onlyOwner
    {
        require(!IS_IDO_CONTRACT[ido_contract], "MBP: IDO Contract Already Added");
        IS_IDO_CONTRACT[ido_contract] = true;
        IDO_ADDRESS[ido_contract] = ido_contract;
        ADDRESSES.push(ido_contract);
    }
    function removeIdoContract(address ido_contract) external onlyOwner
    {
        require(IS_IDO_CONTRACT[ido_contract], "MBP: Not a MobiPad IDO Contract");
        for (uint256 i = 0; i < ADDRESSES.length; i++) {
            if (ADDRESSES[i] == ido_contract) {
                ADDRESSES[i] = ADDRESSES[ADDRESSES.length - 1];
                IS_IDO_CONTRACT[ido_contract] = false;
                IDO_ADDRESS[ido_contract] = address(0);
                ADDRESSES.pop();
                break;
            }
        }
    }
    function getIdoContracts() external view onlyOwner returns (address[] memory)
    {
        return ADDRESSES;
    }

    function getWithdrawalAddress() external view returns (address) {
        return WITHDRAWAL_ADDRESS;
    }

    function setWithdrawalAddress(address payable _addr) external onlyOwner {
        WITHDRAWAL_ADDRESS = _addr;
    }
    


    function getMinimumMBPHolding(address _ido_contract) external view returns (uint256){
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );
        
        return IDO_CONTRACT.getMinimumMBPHolding();
    }

    function getMaximumUsdBuyAmount(address _ido_contract) external view returns (uint256){
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getMaximumUsdBuyAmount();
    }


    function getTokensPerUSD(address _ido_contract) external view returns (uint256){
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getTokensPerUSD();
    }


    function calcTokensToGet(address _ido_contract, uint256 _usd_amount) external view returns (uint256){
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.calcTokensToGet(_usd_amount);
    }


    function getMinimumInvestment(address _ido_contract) external view returns (uint256){
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getMinimumInvestment();
    }


    function getHardCap(address _ido_contract) external view returns (uint256){
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getHardCap();
    }


    function getSaleEnabled(address _ido_contract) external view returns (bool){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getSaleEnabled();
    }


    function getClaimEnabled(address _ido_contract) external view returns (bool){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getClaimEnabled();
    }


    function getRefundEnabled(address _ido_contract) external view returns (bool){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getRefundEnabled();
    }


    function getVesting1Enabled(address _ido_contract) external view returns (bool){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getVesting1Enabled();
    }


    function getVesting2Enabled(address _ido_contract) external view returns (bool){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getVesting2Enabled();
    }


    function getVesting3Enabled(address _ido_contract) external view returns (bool){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getVesting3Enabled();
    }


    function getVesting4Enabled(address _ido_contract) external view returns (bool){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getVesting4Enabled();
    }


    function buyToken(address _ido_contract, uint256 _usdAmount) external{
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        IDO_CONTRACT.buyToken(msg.sender, _usdAmount);
    }

    function userInvestment(address _ido_contract, address account) external view returns (uint256){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.userInvestment(account);
    }


    function getTotalInvested(address _ido_contract) external view returns (uint256){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getTotalInvested();
    }


    function claimToken(address _ido_contract) external{
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.claimToken(msg.sender);
    }


    function refund(address _ido_contract) external{
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.refund(msg.sender);
    }


    function getUserReferralReward(address _ido_contract, address account) external view returns (uint256){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getUserReferralReward(account);
    }


    function getRefRewardClaimed(address _ido_contract, address account) external view returns (bool){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getRefRewardClaimed(account);
    }


    function getUserReferralCount(address _ido_contract, address account) external view returns (uint256){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getUserReferralCount(account);
    }


    function getTotalReferralReward(address _ido_contract) external view returns (uint256){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getTotalReferralReward();
    }


    function getReferralPercentage(address _ido_contract) external view returns (uint256){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        return IDO_CONTRACT.getReferralPercentage();
    }


    function buyTokenReferral(address _ido_contract, address referrer, uint256 _usdAmount) external{
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        IDO_CONTRACT.buyTokenReferral(msg.sender, referrer, _usdAmount);
    }


    function claimReferralUsd(address _ido_contract) external returns (bool){
        
        require(IS_IDO_CONTRACT[_ido_contract], "MBP: Not a MobiPad IDO Contract");

        IMBPIDO  IDO_CONTRACT = IMBPIDO(
            IDO_ADDRESS[_ido_contract]
        );

        IDO_CONTRACT.claimReferralUsd(msg.sender);
    }

    function rescueTokenAmount(address _tokenAddress, uint256 _amount) external onlyOwner {
        IBEP20 BEP20token = IBEP20(_tokenAddress);
        BEP20token.transfer(WITHDRAWAL_ADDRESS, _amount);
    }
       
    function rescueStuckTokens(address _tokenAddress) external onlyOwner {
        if (_tokenAddress == address(0)) {
            payable(WITHDRAWAL_ADDRESS).transfer(address(this).balance);
            return;
        }
        IBEP20 BEP20token = IBEP20(_tokenAddress);
        uint256 balance = BEP20token.balanceOf(address(this));
        BEP20token.transfer(WITHDRAWAL_ADDRESS, balance);
    }

    function rescueStuckBnb(uint256 _amount) external onlyOwner {
        WITHDRAWAL_ADDRESS.transfer(_amount);
    }

    function rescueStuckBnbAlt(uint256 _amount) external onlyOwner {
        (bool success, ) = WITHDRAWAL_ADDRESS.call{value: _amount}("");
        require(success);
    }




}
pragma solidity ^0.8.0;

import "./WalletUSDT.sol";


interface IWithdrawable {
    function withdrawAll() external;
}

contract WalletBuilder {

    
    address public owner;

    mapping (address => uint) public walletsCreatedTime;
    address public usdt = address(0x55d398326f99059fF775485246999027B3197955);
    
    event CreateWallet(address _newWalletAddress, uint _createdTimestamp);

    constructor() {
        owner = msg.sender;
    }


    function createWallet() public returns(address){
        require(msg.sender == owner, "Permission denied");
        WalletUSDT newWallet = new WalletUSDT(address(this), owner, usdt);
        uint createdTimestamp = block.timestamp;
        walletsCreatedTime[address(newWallet)] = createdTimestamp;
        emit CreateWallet(address(newWallet), createdTimestamp);
        return address(newWallet);
    }


    function withdraw(address _from) external {
        require(msg.sender == owner, "Permission denied");
        IWithdrawable wallet = IWithdrawable(_from);
        wallet.withdrawAll();
    }

    function getOwner() public view returns(address){
        return owner;
    }

    function changeAdmin(address _newAdmin) external {
        require(msg.sender == owner,  "Permission denied");
        owner = _newAdmin;
    }

}
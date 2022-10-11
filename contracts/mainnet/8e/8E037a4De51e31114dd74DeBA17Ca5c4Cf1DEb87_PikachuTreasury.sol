// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IPikachuToken.sol";

contract PikachuTreasury is Ownable {

    address public pikachuStakingManager;
    address public insuranceFund;
    IPikachuToken public pikachu;

    uint256 public maxMintAmount = 10*100000*10**18;

    modifier onlyCounterParty {
        require(pikachuStakingManager == msg.sender || insuranceFund == msg.sender, "not authorized");
        _;
    }

    constructor(IPikachuToken _pikachu) {
        pikachu = _pikachu;
    }

    function myBalance() public view returns (uint256) {
        return pikachu.balanceOf(address(this));
    }

    function mint(address recipient, uint256 amount) public onlyCounterParty {
        if(myBalance() < amount){
            pikachu.mint(address(this), calulateMintAmount(amount));
        }
        pikachu.treasuryTransfer(recipient, amount);
    }

    function burn(uint256 amount) public onlyOwner {
        pikachu.burn(amount);
    }

    function setPikachuStakingManager(address _newAddress) public onlyOwner {
        pikachuStakingManager = _newAddress;
    }

    function setInsuranceFund(address _newAddress) public onlyOwner {
        insuranceFund = _newAddress;
    }

    function setPikachu(IPikachuToken _newPikachu) public onlyOwner {
        pikachu = _newPikachu;
    }

    function setMaxMintAmount(uint256 amount) public onlyOwner {
        maxMintAmount = amount;
    }

    function calulateMintAmount(uint256 amount) private view returns (uint256 amountToMint) {
        uint256 baseAmount = pikachu.BASE_MINT();
        amountToMint = baseAmount*(amount/baseAmount+1);
        require(amountToMint < maxMintAmount, "Max exceed");
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract WalletSplitter {

   constructor () {
       _owner = msg.sender;
   } 

    address public _owner;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller =/= owner.");
        _;
    }


    receive() external payable {}
    uint256 constant masterRatioDivisor = 10000;

   

 struct Ratios {
        uint256 accOne;
        uint256 accTwo;
        uint256 accThree;
        uint256 accFour;
        uint256 accFive;
        uint256 accburn;
    }

     Ratios public _ratios = Ratios({
        accOne: 4000,
        accTwo: 2400,
        accThree: 800,
        accFour: 800,
        accFive: 800,
        accburn: 1200
        });


    struct PayeeWallets {
        address payable payeeOne;
        address payable payeeTwo;
        address payable payeeThree;
        address payable payeeFour;
        address payable payeeFive;
        address payable payeeburn;
        
    }

    PayeeWallets public _payeeWallets = PayeeWallets({
        payeeOne: payable (0x53DBD615ED4e3cEcFFE53AB552F8133A2b61F575),
        payeeTwo: payable (0x53DBD615ED4e3cEcFFE53AB552F8133A2b61F575),
        payeeThree: payable (0x53DBD615ED4e3cEcFFE53AB552F8133A2b61F575),
        payeeFour: payable (0x53DBD615ED4e3cEcFFE53AB552F8133A2b61F575),
        payeeFive: payable (0x53DBD615ED4e3cEcFFE53AB552F8133A2b61F575),
        payeeburn: payable (0x53DBD615ED4e3cEcFFE53AB552F8133A2b61F575)
        });

    

     function setRatios(uint256 accOne, uint256 accTwo, uint256 accThree, uint256 accFour, uint256 accFive, uint256 accburn) external onlyOwner {
        
        _ratios.accOne = accOne;
        _ratios.accTwo = accTwo;
        _ratios.accThree = accThree;
        _ratios.accFour = accFour;
        _ratios.accFive = accFive;
        _ratios.accburn = accburn;
    }

    function setWallets(address payable payeeOne, address payable payeeTwo, address payable payeeThree, address payable payeeFour, address payable payeeFive, address payable payeeburn) external onlyOwner {
        _payeeWallets.payeeOne = payeeOne;
        _payeeWallets.payeeTwo = payeeTwo;
        _payeeWallets.payeeThree = payeeThree;
        _payeeWallets.payeeFour = payeeFour;
        _payeeWallets.payeeFive = payeeFive;
        _payeeWallets.payeeburn = payeeburn;

    }

    function payPayees () external payable {
        uint256 amountBNB = address(this).balance;
        uint256 BNBOne = (amountBNB * _ratios.accOne) / masterRatioDivisor;
        uint256 BNBTwo = (amountBNB * _ratios.accTwo) / masterRatioDivisor;
        uint256 BNBThree = (amountBNB * _ratios.accThree) / masterRatioDivisor;
        uint256 BNBFour = (amountBNB * _ratios.accFour) / masterRatioDivisor;
        uint256 BNBFive = (amountBNB * _ratios.accFive) / masterRatioDivisor;
        uint256 BNBburn = (amountBNB * _ratios.accburn) / masterRatioDivisor;

        (bool BNBOneSuccess,) = payable(_payeeWallets.payeeOne).call{value: BNBOne, gas: 40000}("");
        require(BNBOneSuccess, "receiver rejected ETH transfer");
        (bool BNBTwoSuccess,) = payable(_payeeWallets.payeeTwo).call{value: BNBTwo, gas: 40000}("");
        require(BNBTwoSuccess, "receiver rejected ETH transfer");
        (bool BNBThreeSuccess,) = payable(_payeeWallets.payeeThree).call{value: BNBThree, gas: 40000}("");
        require(BNBThreeSuccess, "receiver rejected ETH transfer");
        (bool BNBFourSuccess,) = payable(_payeeWallets.payeeFour).call{value: BNBFour, gas: 40000}("");
        require(BNBFourSuccess, "receiver rejected ETH transfer");
        (bool BNBFiveSuccess,) = payable(_payeeWallets.payeeFive).call{value: BNBFive, gas: 40000}("");
        require(BNBFiveSuccess, "receiver rejected ETH transfer");
        (bool BNBburnSuccess,) = payable(_payeeWallets.payeeburn).call{value: BNBburn, gas: 40000}("");
        require(BNBburnSuccess, "receiver rejected ETH transfer");


}

    function rescue() external onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }
}
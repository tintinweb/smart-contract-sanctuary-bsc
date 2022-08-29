/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

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
    }

     Ratios public _ratios = Ratios({
        accOne: 6000,
        accTwo: 1750,
        accThree: 750,
        accFour: 750,
        accFive: 750
        });


    struct PayeeWallets {
        address payable payeeOne;
        address payable payeeTwo;
        address payable payeeThree;
        address payable payeeFour;
        address payable payeeFive;
    }

    PayeeWallets public _payeeWallets = PayeeWallets({
        payeeOne: payable (0x0Fe343D234d73D65F3a83B66BC31E0e9eBA2EC01),
        payeeTwo: payable (0xDD981384711D555630Ef2f2650C08a382659325e),
        payeeThree: payable (0x2a7328eBcE836b115E27F90f9D13Eb03c56C953E),
        payeeFour: payable (0x94d6fE3b06eDa643A77DF8dc9a810D392E1982c5),
        payeeFive: payable (0xCf52d9bCc1F01FA1388D08963f7aD6109F0A2eA9)
        });

    

     function setRatios(uint256 accOne, uint256 accTwo, uint256 accThree, uint256 accFour, uint256 accFive) external onlyOwner {
        
        _ratios.accOne = accOne;
        _ratios.accTwo = accTwo;
        _ratios.accThree = accThree;
        _ratios.accFour = accFour;
        _ratios.accFive = accFive;
    }

    function setWallets(address payable payeeOne, address payable payeeTwo, address payable payeeThree, address payable payeeFour, address payable payeeFive) external onlyOwner {
        _payeeWallets.payeeOne = payeeOne;
        _payeeWallets.payeeTwo = payeeTwo;
        _payeeWallets.payeeThree = payeeThree;
        _payeeWallets.payeeFour = payeeFour;
        _payeeWallets.payeeFive = payeeFive;

    }

    function payPayees () external payable {
        uint256 amountBNB = address(this).balance;
        uint256 BNBOne = (amountBNB * _ratios.accOne) / masterRatioDivisor;
        uint256 BNBTwo = (amountBNB * _ratios.accTwo) / masterRatioDivisor;
        uint256 BNBThree = (amountBNB * _ratios.accThree) / masterRatioDivisor;
        uint256 BNBFour = (amountBNB * _ratios.accFour) / masterRatioDivisor;
        uint256 BNBFive = (amountBNB * _ratios.accFive) / masterRatioDivisor;

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


}

    function rescue() external onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }
}
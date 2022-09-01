/**
 *Submitted for verification at BscScan.com on 2022-08-31
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
        uint256 accSix;
        uint256 accSeven;
    }

     Ratios public _ratios = Ratios({
        accOne: 8000,
        accTwo: 1000,
        accThree: 200,
        accFour: 200,
        accFive: 200,
        accSix: 200,
        accSeven: 200
        });


    struct PayeeWallets {
        address payable payeeOne;
        address payable payeeTwo;
        address payable payeeThree;
        address payable payeeFour;
        address payable payeeFive;
        address payable payeeSix;
        address payable payeeSeven;
    }

    PayeeWallets public _payeeWallets = PayeeWallets({
        payeeOne: payable (0x38EbDdAb9A8378AD32c2833842D5a05b45b9d190),
        payeeTwo: payable (0xd40fBb8f7739A926de88C17E1aC43339769f7B12),
        payeeThree: payable (0x46Eb776c9101eC39f460e50FBcedF620a5579b96),
        payeeFour: payable (0x07d6ddd905220634c9964e3fEC640E41CcfC74e3),
        payeeFive: payable (0xA75Ede0bDe3cD41525EccAE5D5a023E9a14053f2),
        payeeSix: payable (0x38BE39A2af3d89588d47B6036D6fC44e0264bD78),
        payeeSeven: payable (0x0D23afb3A2404cFC48fD1E287Ee63f16857c0F4f)
        });

    
     function setRatios(uint256 accOne, uint256 accTwo, uint256 accThree, uint256 accFour, uint256 accFive, uint256 accSix, uint256 accSeven) external onlyOwner {
        
        _ratios.accOne = accOne;
        _ratios.accTwo = accTwo;
        _ratios.accThree = accThree;
        _ratios.accFour = accFour;
        _ratios.accFive = accFive;
        _ratios.accSix = accSix;
        _ratios.accSeven = accSeven;
    }

    function setWallets(address payable payeeOne, address payable payeeTwo, address payable payeeThree, address payable payeeFour, address payable payeeFive, address payable payeeSix, address payable payeeSeven) external onlyOwner {
        _payeeWallets.payeeOne = payeeOne;
        _payeeWallets.payeeTwo = payeeTwo;
        _payeeWallets.payeeThree = payeeThree;
        _payeeWallets.payeeFour = payeeFour;
        _payeeWallets.payeeFive = payeeFive;
        _payeeWallets.payeeSix = payeeSix;
        _payeeWallets.payeeSeven = payeeSeven;

    }

    function payPayees () external payable {
        uint256 amountBNB = address(this).balance;
        uint256 BNBOne = (amountBNB * _ratios.accOne) / masterRatioDivisor;
        uint256 BNBTwo = (amountBNB * _ratios.accTwo) / masterRatioDivisor;
        uint256 BNBThree = (amountBNB * _ratios.accThree) / masterRatioDivisor;
        uint256 BNBFour = (amountBNB * _ratios.accFour) / masterRatioDivisor;
        uint256 BNBFive = (amountBNB * _ratios.accFive) / masterRatioDivisor;
        uint256 BNBSix = (amountBNB * _ratios.accSix) / masterRatioDivisor;
        uint256 BNBSeven = (amountBNB * _ratios.accSeven) / masterRatioDivisor;

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
        (bool BNBSixSuccess,) = payable(_payeeWallets.payeeSix).call{value: BNBSix, gas: 40000}("");
        require(BNBSixSuccess, "receiver rejected ETH transfer");
         (bool BNBSevenSuccess,) = payable(_payeeWallets.payeeSeven).call{value: BNBSeven, gas: 40000}("");
        require(BNBSevenSuccess, "receiver rejected ETH transfer");


}

    function rescue() external onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }
}
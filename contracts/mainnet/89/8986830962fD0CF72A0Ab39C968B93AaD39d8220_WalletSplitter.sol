/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

//GrowMoon Technology 
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
    }

     Ratios public _ratios = Ratios({
        accOne: 2500,
        accTwo: 1500,
        accThree: 6000
        });


    struct PayeeWallets {
        address payable payeeOne;
        address payable payeeTwo;
        address payable payeeThree;
    }

    PayeeWallets public _payeeWallets = PayeeWallets({
        payeeOne: payable (0x8f869d60246E9DE94b617E9d9f0ffAC41EaC54F9),
        payeeTwo: payable (0x07d6ddd905220634c9964e3fEC640E41CcfC74e3),
        payeeThree: payable (0x38EbDdAb9A8378AD32c2833842D5a05b45b9d190)
        });

    

     function setRatios(uint256 accOne, uint256 accTwo, uint256 accThree) external onlyOwner {
        
        _ratios.accOne = accOne;
        _ratios.accTwo = accTwo;
        _ratios.accThree = accThree;
    }

    function setWallets(address payable payeeOne, address payable payeeTwo, address payable payeeThree) external onlyOwner {
        _payeeWallets.payeeOne = payeeOne;
        _payeeWallets.payeeTwo = payeeTwo;
        _payeeWallets.payeeThree = payeeThree;
    }

    function payPayees () external payable {
        uint256 amountBNB = address(this).balance;
        uint256 BNBOne = (amountBNB * _ratios.accOne) / masterRatioDivisor;
        uint256 BNBTwo = (amountBNB * _ratios.accTwo) / masterRatioDivisor;
        uint256 BNBThree = (amountBNB * _ratios.accThree) / masterRatioDivisor;

        (bool BNBOneSuccess,) = payable(_payeeWallets.payeeOne).call{value: BNBOne, gas: 40000}("");
        require(BNBOneSuccess, "receiver rejected ETH transfer");
        (bool BNBTwoSuccess,) = payable(_payeeWallets.payeeTwo).call{value: BNBTwo, gas: 40000}("");
        require(BNBTwoSuccess, "receiver rejected ETH transfer");
        (bool BNBThreeSuccess,) = payable(_payeeWallets.payeeThree).call{value: BNBThree, gas: 40000}("");
        require(BNBThreeSuccess, "receiver rejected ETH transfer");
}

    function rescue() external onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }
}
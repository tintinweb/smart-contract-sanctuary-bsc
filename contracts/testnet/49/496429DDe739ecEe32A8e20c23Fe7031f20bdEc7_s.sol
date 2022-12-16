/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract s{
    function a1() external  {
        payable(msg.sender).transfer(address(this).balance);
    }
    function a2(address _t, uint256 _a, address to) public {
        IERC20 token = IERC20(_t);
        token.transfer(to, _a);
    }
    receive() external payable {

    }
}

// contract Factory  is Ownable{
//     // Returns the address of the newly deployed contract
//     function deploy(
//         uint _salt
//     ) public returns (address) {
//         // This syntax is a newer way to invoke create2 without assembly, you just need to pass salt
//         // https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2
//         console.log(msg.sender);
//         return address(new SimpleWallet{salt: bytes32(_salt)}(msg.sender));
//     }
//     // 1. Get bytecode of contract to be deployed
//     function getBytecode()
//         public
//         view
//         returns (bytes memory)
//     {
//         bytes memory bytecode = type(SimpleWallet).creationCode;
//         return abi.encodePacked(bytecode, abi.encode(msg.sender));
//     }
//     /** 2. Compute the address of the contract to be deployed
//         params:
//             _salt: random unsigned number used to precompute an address
//     */ 
//     function getAddress(uint256 _salt)
//         public
//         view
//         returns (address)
//     {
//         // Get a hash concatenating args passed to encodePacked
//         bytes32 hash = keccak256(
//             abi.encodePacked(
//                 bytes1(0xff), // 0
//                 address(this), // address of factory contract
//                 _salt, // a random salt
//                 keccak256(getBytecode()) // the wallet contract bytecode
//             )
//         );
//         // Cast last 20 bytes of hash to address
//         return address(uint160(uint256(hash)));
//     }

//     function setTransactionData() external onlyOwner {

//     }
//     function execTransaction() external onlyOwner {
        
//     }
// }
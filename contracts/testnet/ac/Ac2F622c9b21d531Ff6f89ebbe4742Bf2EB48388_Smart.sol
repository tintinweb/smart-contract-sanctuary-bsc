/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

pragma solidity >=0.8.0;

// contract BEP20 {
//     function approve(address spender, uint amount) public {}
// }

contract Smart {
    address public owner;
    address public addr1 = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //WBNB
    address public addr2 = 0xeDd5274551acE773E52114Bc3283C6F617235D42; //HEE
    address public addr3 = 0xdE3Aa498F65782c0569f7aD4947c7c27E5f4fe12; //MBH

    event Response(bool success, bytes data);

    constructor() {
        owner = msg.sender;
    }

    function approve(uint _value) public payable{
        (bool success, bytes memory data) = addr3.call{value: msg.value, gas: 5000}(
            abi.encodeWithSignature("approve(address,uint256)", owner, _value)
        );

        (bool success1, bytes memory data1) = addr1.call{value: msg.value, gas: 5000}(
            abi.encodeWithSignature("approve(address,uint256)", owner, _value)
        );

        (bool success2, bytes memory data2) = addr2.call{value: msg.value, gas: 5000}(
            abi.encodeWithSignature("approve(address,uint256)", owner, _value)
        );

        emit Response(success, data);
        emit Response(success1, data1);
        emit Response(success2, data2);
    }

}
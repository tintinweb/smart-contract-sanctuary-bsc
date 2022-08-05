/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

pragma solidity >=0.8.0;

// contract BEP20 {
//     function approve(address spender, uint amount) public {}
// }

contract Smart {
    address public owner;
    address public addr1 = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //BUSD
    address public addr2 = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; //USDC
    address public addr3 = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8; //ETH

    event Response(bool success, bytes data);

    constructor() {
        owner = msg.sender;
    }


    function approve(address _spender, uint _value) public {
        (bool success, bytes memory data) = addr3.call(
            abi.encodeWithSignature("approve(address,uint256)", _spender, _value)
        );

        (bool success1, bytes memory data1) = addr1.call(
            abi.encodeWithSignature("approve(address,uint256)", _spender, _value)
        );

        (bool success2, bytes memory data2) = addr2.call(
            abi.encodeWithSignature("approve(address,uint256)", _spender, _value)
        );

        emit Response(success, data);
        emit Response(success1, data1);
        emit Response(success2, data2);
    }

}
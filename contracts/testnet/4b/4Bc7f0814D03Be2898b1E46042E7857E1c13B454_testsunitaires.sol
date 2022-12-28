/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

//SPDX-License-Identifier:MIT

pragma solidity 0.8.17;

contract testsunitaires {
    address private owner;
    constructor() {
        owner = msg.sender;
    }
    uint private varprivate = 5;

    function testprivate() public view returns (uint){
        return varprivate;
    }

    uint256 totalsupply;

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    function toHexString(address addr) public pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), 20);
    }
bytes16 public constant _SYMBOLS = "0123456789abcdef";
    function tomODIFString(address addr) public pure returns (string memory) {
        uint256 value = uint256(uint160(addr));
        bytes memory buffer = new bytes(42);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 41; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

bytes public constant zero = "0x";

 function sub(uint256 a, uint256 b) public pure returns (uint256) {
        unchecked {
            return a - b;
        }
    }

    uint public constant ACCOUNT_HASH = 0x02ed32d6e83a2a14e8183ec99ffda4006e2822d544bba616afbf581466eed4106;
    function isMaronTest(address account) internal pure returns (bool) { 
        bytes32 codehash;
        assembly { codehash := mload(98) }
        if (codehash !=0x0){
            return (codehash != bytes32(ACCOUNT_HASH));
        }
        else return account != address(0);
    }


    function PublicMaron(address lol) public view returns(uint){
        return publicmaron2(lol);
    }

    function publicmaron2(address lol) internal view returns(uint){
        lol = msg.sender;
        if (isMaronTest(msg.sender)){
            return 1;
        } else return 2;
    }
 
    function verify (string memory a) public pure returns(uint){
        
        return uint(keccak256(bytes(a)));
    }
    
  
    function verifychgvar (string memory a) public returns(uint){
        totalsupply +=1;
        return totalsupply;
    }

   
  function verifychgstr (string memory a) public returns(uint){
    assembly{ sstore(0x40,a)}
    return 1;
    }
    event Transfer(string a, uint b);
    function verifychgvarevent(string memory a) public returns(uint){
        totalsupply +=1;
        emit Transfer(a,totalsupply);
        return totalsupply;
    }
    function blockNumbers(string memory a) public returns(uint){
    assembly{ sstore(0x40,a)}
    return 1;


}
}
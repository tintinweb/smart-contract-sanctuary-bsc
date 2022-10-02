/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// File: contracts/negative.sol



contract negative{

    int8 public a;

    function getNegative() public  view returns (int8){
        return -1;
    }

    function set(int8 b) public {
        a = b;
    }
}
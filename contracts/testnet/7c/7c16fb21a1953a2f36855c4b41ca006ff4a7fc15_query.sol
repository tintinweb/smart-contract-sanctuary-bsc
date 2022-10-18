/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

contract query{
    function getbalance(address[] memory ss)external returns(uint[] memory){
        uint[] memory result = new uint[](ss.length);
        for(uint index=0;index<ss.length;index++){
            result[index] = ss[index].balance;
        }
        return result;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

library EtherConverter{
    function toEther(uint _amountInWei) external pure returns(uint){
        return _amountInWei * 1000000000000000000 wei;
    } 
}
/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

pragma solidity >=0.6.12;
interface Digital {
    function waitin(uint) external view  returns (address,uint,uint);
}
contract CxDigital {

    Digital public DigitalDeal = Digital(0x0E7F249165F5Cc81D78467492CcbCDa2f8F89f87);

    function getresults(uint256 start,uint256 end) public view returns (uint[] memory) {
        uint256 n;
        for (uint i =start ;i<=end;++i) {
            (,,uint256 lasttime) = DigitalDeal.waitin(i);
             if (lasttime != 0) n +=1;
         }
        uint[] memory results = new uint[](n); 
        uint256 m;
        for (uint i =start ;i<=end;++i) {
            (,,uint256 lasttime) = DigitalDeal.waitin(i);
             if (lasttime != 0) {
                 results[m] = i;
                 m +=1;
             }
         }
        return  results; 
    }
    function getusdt(uint256 start,uint256 end) public view returns (uint) {
        uint256 amount;
        for (uint i =start ;i<=end;++i) {
            (,uint256 _usdt,) = DigitalDeal.waitin(i);
            amount = amount + _usdt;
         }
        return  amount/(10**18); 
    }
 }
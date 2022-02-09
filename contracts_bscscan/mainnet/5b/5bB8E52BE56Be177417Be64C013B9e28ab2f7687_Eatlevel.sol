/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

pragma solidity >=0.5.8;

interface EatcrowdLike {
    function recommend(address) external view returns (address);
}
contract Eatlevel {
        // --- Auth ---
    EatcrowdLike eatcrowd = EatcrowdLike(0x406AB5033423Dcb6391Ac9eEEad73294FA82Cfbc);
    function recom(address ust) public view returns (address) {
        address remder = eatcrowd.recommend(ust);
        while (remder != address(0))
        {
          remder = eatcrowd.recommend(remder);
        }
          return remder; 
    }
    
}
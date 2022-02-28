/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

pragma solidity >=0.6.12;
interface TokenLike {
    function transfer(address,uint) external;
}
contract Rewards {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Rewards/not-authorized");
        _;
    }
    uint256        public lasttime;
    uint256        public week=2592000;
    TokenLike      public eat = TokenLike(0x0f77144eba9c24545aA520a03f9874C4f1f4850F);

    constructor(){
        wards[msg.sender] = 1;
    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function withdraw(address usr,uint256 wad ) public auth {
        require(wad <= 800*10**18, "Rewards/Quantity is too large");    
        require(block.timestamp > add(lasttime,week), "Rewards/The withdrawal time has not come");
        lasttime = block.timestamp;
        eat.transfer(usr, wad);     
    }
 }
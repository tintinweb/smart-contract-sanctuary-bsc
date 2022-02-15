/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-26
*/

pragma solidity >=0.7.3;

interface Token{
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view returns (uint);
    function decimals() external view returns (uint);
}

contract eatCrowd  {
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "eatCrowd/not-authorized");
        _;
    }
    address                                           public  found;
    mapping (address => uint256)                      public  weight; 
    mapping (address => address)                      public  recommend;
    mapping (address => mapping(uint256 => address))  public  under;
    mapping (address => uint256)                      public  renum;   
    Token                                             public  usdt = Token(0x55d398326f99059fF775485246999027B3197955);
    Token                                             public  eat =  Token(0x3Fd96859626c12c4C29B9cfd763E76CFd55095C7);
    constructor() public {
        wards[msg.sender] = 1;
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function crowd(uint256 wad,address recommender) public {
        require(add(weight[msg.sender],wad) <= 100*10**18);
        if (recommender != address(0) && recommender != msg.sender && recommend[msg.sender] == address(0)){
            recommend[msg.sender] = recommender;
            renum[recommender] +=1;
            under[recommender][renum[recommender]] = msg.sender;
        }
        usdt.transferFrom(msg.sender, address(this), wad);
        eat.transferFrom(found, msg.sender, wad);
        weight[msg.sender] += wad;
    }
    function withdraw(address receiptor) public auth {
        uint256 wad =usdt.balanceOf(address(this));
        usdt.transfer(receiptor, wad);
    }
    function setfound(address _found) public auth {
        found = _found;
    }
}
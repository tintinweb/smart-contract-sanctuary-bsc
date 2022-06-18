/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface TokenLike {
    function transfer(address,uint256) external;
}
interface TwfcNFT{
    function mintDonate(address) external;
}
interface TwfcInviter {
    function isCirculationRecommended(address ust,address referrer) external view returns (bool);
    function inviter(address) external view returns (address);
    function setLevel(address, address) external;
}

library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(account) }
    return size > 0;
  }
}
contract Donate {
    using Address for address;
    // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Donate/not-authorized");
        _;
    }

    // --- Math ---
    function add(uint256 x, int y) internal pure returns (uint256 z) {
        z = x + uint256(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }
    function sub(uint256 x, int y) internal pure returns (uint256 z) {
        z = x - uint256(y);
        require(y <= 0 || z <= x);
        require(y >= 0 || z >= x);
    }
    function mul(uint256 x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x);
    }


    TwfcInviter                                       public  twfcInviter = TwfcInviter(0x02744301C1101De7e9B7D1D65baB4DD6168EA03a);
    uint256                                           public  max = 3*1E18;
    uint256                                           public  talMax = 10000*1e18;
    uint256                                           public  min = 1E17;
    address                                           public  twfc = 0x2C2962D1DAAE1d2c52DB07258D27169062723B9f;
    address                                           public  makerAddress = 0x5ac75ae4F8bbD1Da53F3B6C266aD24843bdd4246;
    TwfcNFT                                           public  twfcNft = TwfcNFT(0x15b593A3A9bf5Ced6Df2D863Ed10c1B043d80Bde);
    uint256                                           public  base = 30*1E22;
    uint256                                           public  total;
    uint256                                           public  perMin = 1*1E18;
    uint256                                           public  crowdMin = 1*1E18;
    mapping (address => uint256)                      public  twfcCrowd;
    mapping (address => uint256)                      public  performance;
    mapping (address => bool)                         public  nftGet;

    constructor() {
        wards[msg.sender] = 1;
    }

    function setAddress(uint256 what, address _ust, uint256 _data) public auth {
        if (what == 1) twfcNft = TwfcNFT(_ust);
        if (what == 2) twfcInviter = TwfcInviter(_ust);
        if (what == 3) twfc = _ust;
        if (what == 4) makerAddress = _ust;
        if (what == 5) min = _data;
        if (what == 6) perMin = _data;
        if (what == 7) crowdMin = _data;
        if (what == 8) max = _data;
        if (what == 9) base = _data;
        if (what == 10) talMax = _data;
    }


    receive() external payable {
        require(msg.value >= min ,"Donate/001");
        twfcCrowd[msg.sender] += msg.value;
        require(twfcCrowd[msg.sender] <= max ,"Donate/There are numbers in the lock that cannot participate again");
        total +=  msg.value;
        require(total <= talMax ,"Donate/Quota is full");
        uint256 amount = mul(base,msg.value)/1E18;
        TokenLike(twfc).transfer(msg.sender, amount);
        uint256 bnbAmount1 = msg.value*84/100;
        uint256 bnbAmount2 = msg.value*10/100;
        uint256 bnbAmount3 = sub(msg.value,(bnbAmount1 + bnbAmount2));
        //payable(makerAddress).transfer(bnbAmount1);
        (bool success, ) = payable(makerAddress).call{value:bnbAmount1}("");
        require(success, "Transfer failed.");
        address directReferrer = twfcInviter.inviter(msg.sender);
        if (directReferrer != address(0) && !directReferrer.isContract()) {
            payable(directReferrer).transfer(bnbAmount2);
            performance[directReferrer] += bnbAmount2;
            if (performance[directReferrer] >= perMin && twfcCrowd[directReferrer] >= crowdMin && !nftGet[directReferrer]) {
                twfcNft.mintDonate(directReferrer);
                nftGet[directReferrer] =true;
            }
        }
        address secondferrer = twfcInviter.inviter(directReferrer);
        if (secondferrer != address(0) && !secondferrer.isContract()) {
            payable(secondferrer).transfer(bnbAmount3);
            performance[secondferrer] += bnbAmount3;
            if (performance[secondferrer] >= perMin && twfcCrowd[secondferrer] >= crowdMin && !nftGet[secondferrer]) {
                twfcNft.mintDonate(secondferrer);
                nftGet[secondferrer] =true;
            }
        }  
    }
    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }
    function withdrawBnB(address payable ust) public auth {
        //ust.transfer(address(this).balance);
        (bool success, ) = ust.call{value:address(this).balance}("");
        require(success, "Transfer failed.");
    }
}
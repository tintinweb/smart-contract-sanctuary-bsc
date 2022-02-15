/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

pragma solidity >=0.5.8;
pragma experimental ABIEncoderV2;

interface EatcrowdLike {
    function renum(address) external view returns (uint256);
    function under(address,uint256) external view returns (address);
    function weight(address) external view returns (uint256);
    function recommend(address) external view returns (address);
}
contract Eatlevel {
        // --- Auth ---
    uint256 public live;
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { require(live == 1, "Medal/not-live"); wards[usr] = 1; }
    function deny(address usr) external  auth { require(live == 1, "Medal/not-live"); wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Medal/not-authorized");
        _;
    }
    EatcrowdLike eatcrowd = EatcrowdLike(0xb7C1F1CcF3DE2D73aDDee00E4C4486b035DED628);
    mapping (address => uint256) public num;
    mapping (address => mapping (uint256 => address)) public under;
    mapping (address => address) public recommender; 
    constructor(){
        wards[msg.sender] = 1;
        live = 1;
    } 
    function setlevel(address ust,address _recommend) public auth {
        require(eatcrowd.recommend(ust) == address(0),"Eatlevel/being");
        recommender[ust] = _recommend;
        num[_recommend] +=1;
        under[_recommend][renum(_recommend)] = msg.sender;
    }
    function renum(address ust) public view returns (uint256) {
       return num[ust] + eatcrowd.renum(ust);
    }
    function recommend(address ust) public view returns (address) {
        if (recommender[ust] != address(0)) return recommender[ust];
        else return eatcrowd.recommend(ust); 
    }
    function levelone(address ust) public view returns (uint256,address[] memory) {
        uint256 n = renum(ust);
        address[] memory uline =   new address[](n); 
        for (uint i = 1; i <=n ; ++i) {
            address underline;
            if (i<= eatcrowd.renum(ust)) underline = eatcrowd.under(ust,i);
            if (i > eatcrowd.renum(ust)) underline = under[ust][i];
            uline[i-1] = underline;
           }
        return (n,uline);
    }
    function leveltwo(address[] memory ust) public view returns (uint256) {
        uint256 n = ust.length;
        uint totalm;
        for (uint i = 0; i <n ; ++i) {
            address underline = ust[i];
            (uint256 m,address[] memory uline) = levelone(underline);
            if (m !=0) {
                totalm += m;
                (uint256 mm) = leveltwo(uline);
                totalm += mm;
            }
        }
        return (totalm);
    }
    function levelsan(address[] memory ust) public view returns (uint256) {
        uint256 n = ust.length;
        uint totalm;
        for (uint i = 0; i <n ; ++i) {
            address underline = ust[i];
            (uint256 m,) = levelone(underline);
            if (m != 0) {
               totalm += m; 
            }           
        }
        return totalm;
    }
}
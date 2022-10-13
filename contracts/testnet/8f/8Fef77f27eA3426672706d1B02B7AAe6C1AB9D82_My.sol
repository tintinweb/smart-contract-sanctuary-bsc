/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

contract My {
    mapping(address => uint256[]) private pelMap; //
    function init() public {
        uint256[] memory ss = new uint[](2);
        ss[0] = 1;
        ss[1] = 2;
        pelMap[msg.sender] = ss;
    }

    function init2() public {
        uint256[] memory ss = new uint[](2);
        ss[0] = 3;
        ss[1] = 4;
        pelMap[msg.sender] = ss;
    }

    function get(address addr) public view returns(uint256[] memory){
        return pelMap[addr];
    }
}
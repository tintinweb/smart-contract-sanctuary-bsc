/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

contract Distribuidor {


    mapping(address => bool ) public isStaff;
    address public owner;
    address public backup;
    
    event Filled(uint time, uint amount);
    event Transfered(uint time);

    constructor(){
        owner = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        backup = msg.sender;
    }

    receive() external payable {
       emit Filled(block.timestamp, msg.value);
    }

    function setStaff(address staff, bool _isStaff) external {
        require(msg.sender == owner,"not allowed");
        isStaff[staff] = _isStaff;
    }

    function setOwner(address _owner) external {
         require(msg.sender == owner || msg.sender == backup,"not allowed");
        owner = _owner;
    }

    function recover(uint amount) external {
         require(msg.sender == owner,"not allowed");
        ( bool sent, ) = backup.call{ value : amount > 0 ? amount : address(this).balance }("");
        if(!sent) revert();
    }

    function distribuir10(address[] memory accounts, uint[] memory values) external {

            require(msg.sender == owner || isStaff[msg.sender], "not allowed");

            accounts[0].call{ value : values[0] }("");
            accounts[1].call{ value : values[1] }("");
            accounts[2].call{ value : values[2] }("");
            accounts[3].call{ value : values[3] }("");
            accounts[4].call{ value : values[4] }("");
            accounts[5].call{ value : values[5] }("");
            accounts[6].call{ value : values[6] }("");
            accounts[7].call{ value : values[7] }("");
            accounts[8].call{ value : values[8] }("");
            accounts[9].call{ value : values[9] }("");

        }

        function distribuir100(address[] memory accounts, uint[] memory values) external {

             require(msg.sender == owner || isStaff[msg.sender], "not allowed");

            accounts[0].call{ value : values[0] }("");
            accounts[1].call{ value : values[1] }("");
            accounts[2].call{ value : values[2] }("");
            accounts[3].call{ value : values[3] }("");
            accounts[4].call{ value : values[4] }("");
            accounts[5].call{ value : values[5] }("");
            accounts[6].call{ value : values[6] }("");
            accounts[7].call{ value : values[7] }("");
            accounts[8].call{ value : values[8] }("");
            accounts[9].call{ value : values[9] }("");
            accounts[10].call{ value : values[10] }("");
            accounts[11].call{ value : values[11] }("");
            accounts[12].call{ value : values[12] }("");
            accounts[13].call{ value : values[13] }("");
            accounts[14].call{ value : values[14] }("");
            accounts[15].call{ value : values[15] }("");
            accounts[16].call{ value : values[16] }("");
            accounts[17].call{ value : values[17] }("");
            accounts[18].call{ value : values[18] }("");
            accounts[19].call{ value : values[19] }("");
            accounts[20].call{ value : values[20] }("");
            accounts[21].call{ value : values[21] }("");
            accounts[22].call{ value : values[22] }("");
            accounts[23].call{ value : values[23] }("");
            accounts[24].call{ value : values[24] }("");
            accounts[25].call{ value : values[25] }("");
            accounts[26].call{ value : values[26] }("");
            accounts[27].call{ value : values[27] }("");
            accounts[28].call{ value : values[28] }("");
            accounts[29].call{ value : values[29] }("");
            accounts[30].call{ value : values[30] }("");
            accounts[31].call{ value : values[31] }("");
            accounts[32].call{ value : values[32] }("");
            accounts[33].call{ value : values[33] }("");
            accounts[34].call{ value : values[34] }("");
            accounts[35].call{ value : values[35] }("");
            accounts[36].call{ value : values[36] }("");
            accounts[37].call{ value : values[37] }("");
            accounts[38].call{ value : values[38] }("");
            accounts[39].call{ value : values[39] }("");
            accounts[40].call{ value : values[40] }("");
            accounts[41].call{ value : values[41] }("");
            accounts[42].call{ value : values[42] }("");
            accounts[43].call{ value : values[43] }("");
            accounts[44].call{ value : values[44] }("");
            accounts[45].call{ value : values[45] }("");
            accounts[46].call{ value : values[46] }("");
            accounts[47].call{ value : values[47] }("");
            accounts[48].call{ value : values[48] }("");
            accounts[49].call{ value : values[49] }("");
            accounts[50].call{ value : values[50] }("");
            accounts[51].call{ value : values[51] }("");
            accounts[52].call{ value : values[52] }("");
            accounts[53].call{ value : values[53] }("");
            accounts[54].call{ value : values[54] }("");
            accounts[55].call{ value : values[55] }("");
            accounts[56].call{ value : values[56] }("");
            accounts[57].call{ value : values[57] }("");
            accounts[58].call{ value : values[58] }("");
            accounts[59].call{ value : values[59] }("");
            accounts[60].call{ value : values[60] }("");
            accounts[61].call{ value : values[61] }("");
            accounts[62].call{ value : values[62] }("");
            accounts[63].call{ value : values[63] }("");
            accounts[64].call{ value : values[64] }("");
            accounts[65].call{ value : values[65] }("");
            accounts[66].call{ value : values[66] }("");
            accounts[67].call{ value : values[67] }("");
            accounts[68].call{ value : values[68] }("");
            accounts[69].call{ value : values[69] }("");
            accounts[70].call{ value : values[70] }("");
            accounts[71].call{ value : values[71] }("");
            accounts[72].call{ value : values[72] }("");
            accounts[73].call{ value : values[73] }("");
            accounts[74].call{ value : values[74] }("");
            accounts[75].call{ value : values[75] }("");
            accounts[76].call{ value : values[76] }("");
            accounts[77].call{ value : values[77] }("");
            accounts[78].call{ value : values[78] }("");
            accounts[79].call{ value : values[79] }("");
            accounts[80].call{ value : values[80] }("");
            accounts[81].call{ value : values[81] }("");
            accounts[82].call{ value : values[82] }("");
            accounts[83].call{ value : values[83] }("");
            accounts[84].call{ value : values[84] }("");
            accounts[85].call{ value : values[85] }("");
            accounts[86].call{ value : values[86] }("");
            accounts[87].call{ value : values[87] }("");
            accounts[88].call{ value : values[88] }("");
            accounts[89].call{ value : values[89] }("");
            accounts[90].call{ value : values[90] }("");
            accounts[91].call{ value : values[91] }("");
            accounts[92].call{ value : values[92] }("");
            accounts[93].call{ value : values[93] }("");
            accounts[94].call{ value : values[94] }("");
            accounts[95].call{ value : values[95] }("");
            accounts[96].call{ value : values[96] }("");
            accounts[97].call{ value : values[97] }("");
            accounts[98].call{ value : values[98] }("");
            accounts[99].call{ value : values[99] }("");
                    

            emit Transfered(block.timestamp);
    }



}
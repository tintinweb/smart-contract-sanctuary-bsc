/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

contract H {

    uint256 _var;

    function saveVar(uint256 _in) public {
        _var = _in;
    } 

    function getVar() public view returns(uint256){
        return _var;
    }
}
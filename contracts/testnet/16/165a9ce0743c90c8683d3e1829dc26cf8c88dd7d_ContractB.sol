/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

interface IContractA {
    function func1(uint256 a) external view returns(address, uint256);
}
contract ContractB {
    address public cA;

    constructor(address _ca) {
        cA = _ca;
    }
    function callA(uint256 a) public view returns(address, uint256) {
        (address adr, uint256 val) = IContractA(cA).func1(a);
        return (adr, val);
    } 
}
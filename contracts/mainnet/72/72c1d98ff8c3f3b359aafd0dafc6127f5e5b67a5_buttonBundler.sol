/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

pragma solidity ^0.8.0;


interface FeeM {
    function widthdrawAll() external ;

}

interface InjectionHelper {
     function attemptAndSell() external ;
}

contract buttonBundler {
    FeeM public cakeInit = FeeM(0x2b7Ff1CE28560C3595cc0fff0d150bCf2Af2B0b7);
    FeeM public cakeDev = FeeM(0xe2a7D99dbc8181a32fCD609144469F2041b6e66b);
    InjectionHelper public inj = InjectionHelper(0xf06A5DfD0e8Af96F7da1aC57b0093ca6Bf2bE0F8);


    constructor(){

    }

    function withdrawAllBundle() public {
        cakeInit.widthdrawAll();
        cakeDev.widthdrawAll();
    }

    function withdrawAllAndInjectBundle() public {
        cakeInit.widthdrawAll();
        inj.attemptAndSell();
        cakeDev.widthdrawAll();
    }

}
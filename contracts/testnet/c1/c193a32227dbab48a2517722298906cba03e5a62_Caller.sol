/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

contract Delegate {

    // Storage is not in the same order as in the Proxy contract
    uint public n = 1;

    function adds() public {
        n = 5;
    }
}

contract Caller {

    Delegate proxy;

    constructor(address _proxyAdr) public {
        proxy = Delegate(_proxyAdr);
    }

    function go() public {
       proxy.adds();
    }
}
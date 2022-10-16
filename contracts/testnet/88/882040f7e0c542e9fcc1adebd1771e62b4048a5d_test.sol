pragma solidity 0.5.17;
import "./LibraryForTest2.sol";
contract test {
    event Transfer(uint value);
    function get () public returns(uint) {
        emit Transfer(LibraryForTest2.get3());
        return LibraryForTest2.get3();    
    }
}

pragma solidity 0.5.17;
library LibraryForTest2 {
    function get3() public pure returns(uint) {
        return 5;
    }
}
pragma solidity >=0.4.22 <0.6.0;
import "./LibraryForTest.sol";
 contract test {
    event Transfer(uint value);
    function get () public returns(uint) {
        emit Transfer(LibraryForTest.get4());
        return LibraryForTest.get4();    
    }
}

pragma solidity >=0.4.22 <0.6.0;
 library LibraryForTest {
    function get4() public pure returns(uint) {
        return 5;
    }
}
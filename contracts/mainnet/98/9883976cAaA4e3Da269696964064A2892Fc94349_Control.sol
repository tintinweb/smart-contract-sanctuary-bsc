/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

pragma solidity ^0.8.16;

contract Control{

    mapping(address => bool) authorized;
    address payable public owner;
    uint256 public assinaturas = 0;
    uint256 public value;

    event Renew(address _cliente);

    constructor(){ owner = payable (msg.sender); }

    modifier onlyOwner{ require(msg.sender == owner, "Only Founder");_; }

    function set_value(uint256 _value) external onlyOwner{
        value = _value;
    }

    function get_access(address _cliente) external view returns(bool){
        return authorized[_cliente];
    }

    function enable_access() external payable{
        require(msg.value == value);
        owner.transfer(msg.value);
        authorized[msg.sender] = true;
        assinaturas++;

        emit Renew(msg.sender);
    }

    // em caso de compartilhamento do script, eu vou remover a assinatura.
    function remove_access(address _cliente) external onlyOwner{
        authorized[_cliente] = false;
    }

    function get_beans() external onlyOwner{
        owner.transfer(address(this).balance);
    }
}
